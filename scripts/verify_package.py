#!/usr/bin/env python3
"""Check a prepared package folder without changing it or asserting course completion."""
import argparse
import hashlib
import json
from pathlib import Path
import sys
from zipfile import BadZipFile, ZipFile

REQUIRED = {
    'app-release.apk', 'Project1_Presentation.pptx',
    'AjxOm_Project1_SelectedQuestions.docx', 'Flutter_Source.zip',
    'GitHub_Repository_Link.txt', 'PROJECT_REPORT.pdf',
    'Kanban_Contribution_Evidence.pdf', 'AI_FEATURE.md', 'CONTRIBUTIONS.md',
}


def verify(folder):
    root = folder.resolve()
    manifest = json.loads((root / 'PACKAGE_MANIFEST.json').read_text())
    errors = []
    listed = set()
    for entry in manifest['files']:
        name = entry['path']
        path = (root / name).resolve()
        if not path.is_relative_to(root):
            errors.append(f'Unsafe manifest path: {name}')
            continue
        if name in listed:
            errors.append(f'Duplicate manifest entry: {name}')
        listed.add(name)
        if not path.is_file():
            errors.append(f'Missing file: {name}')
            continue
        data = path.read_bytes()
        if len(data) != entry['bytes']:
            errors.append(f'Size mismatch: {name}')
        if hashlib.sha256(data).hexdigest() != entry['sha256']:
            errors.append(f'Checksum mismatch: {name}')
        if path.suffix.lower() in {'.zip', '.pptx', '.docx', '.apk'}:
            try:
                with ZipFile(path) as archive:
                    bad = archive.testzip()
                    if bad:
                        errors.append(f'Corrupt archive entry: {name}: {bad}')
            except BadZipFile:
                errors.append(f'Invalid archive: {name}')
    for name in sorted(REQUIRED - listed):
        errors.append(f'Required deliverable absent from manifest: {name}')
    for error in errors:
        print(error, file=sys.stderr)
    if errors:
        return 1
    print(f'Package integrity passed: {len(listed)} listed files verified.')
    print('This does not verify video access, signatures, rubric compliance or submission.')
    return 0


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('folder', type=Path, help='Extracted folder containing PACKAGE_MANIFEST.json')
    args = parser.parse_args()
    try:
        sys.exit(verify(args.folder))
    except (OSError, ValueError, KeyError, TypeError) as error:
        print(f'Cannot verify package: {error}', file=sys.stderr)
        sys.exit(1)
