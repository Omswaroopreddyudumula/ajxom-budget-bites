# Budget Bites

AjxOm's offline meal and purchase notebook for undergraduate Project One. Save meals, compare estimates with a lunch budget, record purchases and correct receipt history. Venue notes and prices are personal entries; the two starter meals are explicitly fictional.

## Team

| Member | GitHub | Responsibilities |
| --- | --- | --- |
| Om Swaroop Reddy Udumula | Omswaroopreddyudumula | UI, demo section, documentation and current integration branch |
| Anton “A.J.” Orea | ajorea-lab | Original Meal model/database and History page, testing, documentation |

The user confirmed instructor-team approval on October 26, 2026. The written approval and submitted proposal/signatures should remain with the private course submission. The final app integrates both branches, including A.J.'s History page. 

## Features

- Meal catalog, meal editor, detail/activity, purchase History and settings.
- Meal and PurchaseLog SQLite CRUD with generated IDs, foreign keys and restricted parent deletion.
- Integer-cent prices; independent receipt corrections and refreshed totals.
- Start, draft progress, explicit save/finish and confirmed reset that retains history.
- Cuisine/search/favorites filters; favorites is a Meal flag. History has meal/date filters and a spending total.
- Lunch Lens local moving mean with inputs, explanation, last-price baseline and dismiss. No cloud service or trained model.
- Persistent budget slider and dark mode; visible validation, save failures and empty states.
- Swipe-to-edit and long-press-to-edit shortcuts with visible button alternatives.

## Setup

Validated with Flutter 3.47.2 stable, Dart 3.13.2, Android API 37 emulators. Dependencies are pinned in pubspec.lock; key packages are sqflite, path and shared_preferences. Requires Flutter plus Android SDK and an emulator/device.

```sh
flutter pub get
flutter analyze
flutter test --coverage
flutter test integration_test/notebook_test.dart -d DEVICE_ID
flutter run -d DEVICE_ID
flutter build apk --release
```

Run `./scripts/check.sh` from any directory to install dependencies, analyze the app and run the unit/widget suite with coverage. The command stops on the first failure; device integration tests remain separate.

Release output: `build/app/outputs/flutter-apk/app-release.apk`. The coursework scaffold signs release mode with the local debug certificate. This build is intended for coursework installation, not Play Store publishing. The APK is distributed separately rather than committed as a large binary.

## User guide

1. Home: Add meal, enter name/venue/items and USD amounts, choose cuisine and save. View meal opens the activity. Edit changes the catalog estimate; it never changes previous actual purchases.
2. Meal activity: inspect Lunch Lens, choose Start plan, enter actual amount/date/note and Save purchase and finish. Confirm an over-budget purchase explicitly. Reset discards only the active unsaved draft.
3. History: add, view, correct or delete a receipt. The displayed total applies to the selected meal/date scope. Deleting a meal is blocked until its receipts are deleted or moved to another meal.
4. Settings: adjust budget or toggle dark mode. Changes persist locally. No account or network connection is needed.

All money fields use USD with at most two decimal places. A separate new purchase creates a new receipt; repeated pending/retried saves of the same draft do not.

## Evidence and documentation

- [Architecture and schema](ARCHITECTURE.md)
- [Local helper evaluation](AI_FEATURE.md)
- [Test results and limitations](docs/TEST_RESULTS.md)
- [Contribution and missing evidence record](docs/CONTRIBUTIONS.md)
- [Presentation run of show](docs/SHOWCASE.md)
- [Prepared PowerPoint](submission/Project1_Presentation.pptx)
- [Questions only Word document](submission/AjxOm_Project1_SelectedQuestions.docx)
- [Project report](submission/PROJECT_REPORT.pdf)
- [ClickUp board](https://app.clickup.com/90141772424/v/g/2kydwjm8-434)
- [Kanban and contribution evidence](Kanban_Contribution_Evidence.pdf) — contains repository contribution traces; A.J. holds the team’s ClickUp screenshots/export for the submission.

Raw analyzer/test/build logs and actual emulator screenshots are under `evidence/`. Test fixtures are fictional and labeled. Both emulators use the same API level; the second runs a larger display configuration. See test results for which checks are automated versus manually observed.

## Check the prepared submission package

Run `python3 scripts/verify_package.py /path/to/Budget_Bites_Final` against the extracted final package. It checks required deliverables, every manifest file size and SHA-256 checksum, and ZIP-based file integrity (including APK, PPTX and DOCX). It exits with an error for missing or changed files. This is a file-integrity check; manually verify the video link, signatures and course submission receipt.

## Known limits and future work

Only USD, device-local data, no account/sync, no active-draft restoration after process death, and limited Android-version diversity. The three-purchase mean is sensitive to outliers and performs worse than last-price baseline on the small deliberately challenging fixture set. Future work: median comparison on new cases, import/export and broader device coverage. No license has been granted for reuse of team-authored code; agree one before external distribution. Flutter scaffold retains its upstream notices.

## Course references

[Overview](https://codd.cs.gsu.edu/~lhenry23/mad/Projects/Project1/ver2/index.html) · [Rubric](https://codd.cs.gsu.edu/~lhenry23/mad/Projects/Project1/ver2/assessment/grading-rubric.html) · [Submission](https://codd.cs.gsu.edu/~lhenry23/mad/Projects/Project1/ver2/submission/About_Submission.html)
