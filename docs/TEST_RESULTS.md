# Validation results

Executed during the October 26, 2026 session. These are actual test results, not a completed submission or independent peer review.

## Environment

Flutter 3.47.2 stable; Dart 3.13.2. Two separate Android API-37 ARM64 emulator instances: Pixel_8 (emulator-5554, 1080x2400, density 420) and Activity09Fresh (emulator-5556, display overridden to 1200x1920, density 240). Both are derived from Pixel 8 AVDs using the same OS image. This tests separate app-data/display configurations, not OS-version or physical-hardware diversity.

## Automated checks

| Check | Actual result | Evidence |
| --- | --- | --- |
| Analyzer | PASS, no issues | evidence/analyze.txt |
| Logic/widget suite | PASS, 14 tests | evidence/unit-widget-tests.txt |
| Pixel_8 integration | PASS, 3 tests | evidence/android-pixel8-integration.txt |
| Second display integration | PASS, 3 tests | evidence/android-second-integration.txt |
| Release APK | PASS, 53.7 MB build output | evidence/release-build.txt |

Logic tests cover exact money parsing/rejection, H1-H5, rounding, future/other-meal exclusion and ties. Widget tests cover navigation/settings, validation, injected failed writes retaining drafts, and helper no-data/dismiss. Unit/widget line coverage: 391/774 = 50.5%; no coverage bonus is claimed.

Device tests use the actual sqflite plugin: both entities' CRUD; 450+600=1050, correction to 1000, deletion to 550; repeated token same ID; parent restriction, orphan/negative rejection; database reopen, preference reload and UI navigation. A version-1 REAL-price fixture migrates preserving ID 17 and 650 cents. A separately labeled fictional fixture supports local testing.

Initial development runs found stale starter-test references and offscreen test-harness scroll targeting. These were corrected and rerun; final passing outputs are retained. The first run did not pass.

## Actual installed release restart

Installed the release on both emulators, enabled airplane mode and disabled Wi-Fi/mobile data within each emulator. Saved through the actual UI, force-stopped the package and relaunched.

- Pixel_8: created QA_Release_Meal and a fictional $4.50 purchase; changed budget to $14.00 and dark mode. Restart preserved the meal (verified via search), receipt #1 and $4.50 total, budget and dark mode. See pixel8-persisted-meal.png, pixel8-history-after-restart.png, pixel8-restart.png and related XML/text.
- Second display: saved a fictional $4.50 Campus wrap purchase. After process restart, History still showed $4.50. See second-release-restart.png/.txt.
- Second display landscape, font scale 1.4: captured and inspected History filters, total and action buttons. See second-landscape-large-text.png. This is a targeted check, not exhaustive accessibility certification.

Screenshots genuinely capture the running app; QA fixture purchases are not actual spending. The APK ships only two fictional meals and no purchase history. Test device data is not embedded in it. Release mode uses the coursework scaffold's debug signing certificate; intended for direct coursework installation, not store publication.

## Remaining limitations

No physical-device run, older-Android run, independent peer task/revision or exhaustive screen-reader/contrast audit. Real storage-full/OS termination during a pending commit are not exhaustively tested. A.J.'s separate History UI has not been received/reviewed; integration requires regression checks. Historical board snapshots are missing and steady contribution targets are not met. Final video/slides, questions upload, ClickUp PDF, written approval attachment and individual upload receipts remain outstanding.

## October 30 final integration

A.J.'s final History page is integrated in lib/screens/meal_history.dart. The original 14 tests plus 3 targeted History checks pass (17 total). Analyzer is clean. Final SQLite/migration/navigation fixture suite passes 3 tests per emulator. Logs: final-analyze.txt, final-unit-widget-tests.txt, final-phone-integration.txt and final-large-integration.txt. The fixture aggregate check now preserves unrelated existing receipts rather than assuming the app database is empty. Final release build and install/restart evidence have separate final-prefixed files. The October 26 coverage percentage above belongs to that older run and is not claimed as current coverage.
