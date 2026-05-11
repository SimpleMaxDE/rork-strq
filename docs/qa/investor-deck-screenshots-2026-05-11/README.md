# STRQ investor deck screenshots - 2026-05-11

Focused real simulator screenshots captured for the Figma Slides investor deck. These are current STRQ iOS app screens from the simulator, not generated mockups.

## Capture environment

- Source app commit: `33daeb5`
- Xcode: 26.3, build 17C529
- Simulator: iPhone 17 Pro, iOS 26.2
- Simulator UDID: `D0B148E5-33DC-4B9C-8843-CD44A06E869D`
- Build command: `xcodebuild -project ios/STRQ.xcodeproj -scheme STRQ -configuration Debug -sdk iphonesimulator -destination 'generic/platform=iOS Simulator' CODE_SIGNING_ALLOWED=NO build`

## Selected screenshots

- `selected/01-training-map-readable-top.png` - Training Map / Progress V5 candidate, readable 8-workout top state.
- `selected/02-training-map-evidence-signal.png` - Training Map / Progress V5 candidate, signal readiness and evidence state.
- `selected/03-training-map-start-state.png` - Training Map / Progress V5 candidate, empty first-workout journey state.
- `selected/04-exercise-anatomy-target.png` - Exercise Detail, Barbell Bench Press anatomy target map.
- `selected/05-workout-execution.png` - Active Workout, first set tracking for Barbell Bench Press.
- `selected/06-coach-or-plan.png` - Training Plan, current Oberkoerper A plan guidance.
- `selected/07-today-home-optional.png` - Today/Home dashboard, optional.
- `selected/08-current-progress-optional.png` - Production Progress tab with restored 8-workout QA evidence state.

The `raw/` folder contains matching raw captures for each selected screenshot. `contact-sheet.jpg` shows all selected screenshots with labels.

## Recommended deck images

Recommended for investor material:

- `01-training-map-readable-top.png`
- `02-training-map-evidence-signal.png`
- `03-training-map-start-state.png`
- `04-exercise-anatomy-target.png`
- `05-workout-execution.png`
- `06-coach-or-plan.png`
- `08-current-progress-optional.png`

Use `07-today-home-optional.png` only if a Today/Home slide is needed and the visual caveat below is acceptable.

## Internal candidate screens

- `01-training-map-readable-top.png`
- `02-training-map-evidence-signal.png`
- `03-training-map-start-state.png`

These were opened via Profile -> Internal Preview: Training Map. They are real app screens wired to simulator state, but they are internal Progress V5 candidate screens rather than the production Progress tab.

## Production screens

- `04-exercise-anatomy-target.png`
- `05-workout-execution.png`
- `06-coach-or-plan.png`
- `07-today-home-optional.png`
- `08-current-progress-optional.png`

The plan and active workout shots were captured from disposable simulator state after creating a real plan through the app's own profile plan regeneration flow. The Progress tab shot uses the restored 8-workout QA simulator state to show meaningful progress evidence.

## Visual caveats

- The Training Map images are internal candidate screens and should be described that way if shown externally before launch.
- Several production screens mix German UI chrome with English exercise or product copy. This may be acceptable for internal pitch draft work, but a final investor deck should use a consistent locale.
- `07-today-home-optional.png` has visible malformed text in the Today card body (`W?rm`). Do not use it in final investor material unless that copy is fixed or cropped out.
- `05-workout-execution.png` is an in-progress workout state from disposable simulator data; it is strong for execution flow, but it is not a completed-workout proof screen.
- `08-current-progress-optional.png` is useful production evidence, but it uses QA workout history and includes "Proof" language that should be checked against the deck narrative.
- The simulator profile name visible in the Today screen is `QA`; no sensitive local personal data is included.

## Not captured

- Profile debug / internal menu screens were not selected because they are not investor-facing product visuals.
- A separate Coach tab screenshot was not shortlisted because the real Training Plan and pre-workout guidance surfaces were stronger and more concrete for the deck.
- Additional lower-value screens were intentionally skipped to keep the shortlist focused on 6-8 high-signal images.
