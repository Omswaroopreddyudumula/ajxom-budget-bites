#!/usr/bin/env bash
# Run from any directory. Device-based integration tests remain a separate step.
set -euo pipefail
cd "$(dirname "$0")/.."
if ! command -v flutter >/dev/null 2>&1; then
  echo "Flutter is required on PATH." >&2
  exit 1
fi
flutter pub get
flutter analyze
flutter test --coverage
printf '\nLocal checks passed. Run integration_test/notebook_test.dart on each target device separately.\n'
