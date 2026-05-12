# Active Workout Runtime QA - 2026-05-12

## Environment
- Primary simulator: iPhone 17 Pro, iOS 26.5
- Small simulator: iPhone 17e, iOS 26.5
- Commit SHA: `0c2e05e`
- Build: Passed
- Build command: `xcodebuild -project ios/STRQ.xcodeproj -scheme STRQ -configuration Debug -sdk iphonesimulator -destination 'generic/platform=iOS Simulator' CODE_SIGNING_ALLOWED=NO build`
- Code changed: No persistent code changes. A temporary UI-test/scheme harness was used and reverted; final changes are QA artifacts only.

## States Passed
- Current set before logging: `01-current-set-before.png`
- Weight numeric edit sheet: `02-weight-edit-sheet.png`
- Reps numeric edit sheet: `03-reps-edit-sheet.png`
- One logged set with table/current set progression: `04-after-one-set.png`
- Rest overlay: `05-rest-overlay.png`
- Two logged sets with set history progression: `06-after-two-sets.png`
- Undo after a logged set returned to the correct current set/table state: `07-after-undo.png`
- Finish workout completion flow: `08-finish-flow.png`
- Small iPhone current set pass: `09-small-iphone-current-set.png`

## Not Reachable
- No separate finish confirmation dialog appeared from the header `Workout beenden` CTA; it completed directly into the workout summary.

## Visual Issues Found
- Minor: on the rest overlay, the transient “Satz geloggt” reward toast overlaps the top of the “Gerade geloggt” card while both are visible.
- Minor: the undo banner title text renders as `2 protokolliert festlegen`, which appears to be an awkward German localization for “Set 2 logged.”

## Behavior Issues Found
- No blocking runtime behavior bugs found in the checked flow.
- Rest overlay, set progression, undo, and completion state all functioned during runtime QA.

## Notes
- The primary simulator state was backed up before destructive finish-flow testing and restored afterward.
