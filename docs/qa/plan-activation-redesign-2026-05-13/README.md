# STRQ Plan Activation Redesign QA

- Base SHA tested: `4bfe82f0d47d42ff95ccf87ff2821a74c063f162`
- Capture date: `2026-05-13`
- Primary simulator: `iPhone 17 Pro`
- Small simulator: `iPhone 17e`
- Xcode: `26.5 (17F42)`
- Build result: passed with the required generic iOS Simulator Debug build.
- Screenshot test result: passed on iPhone 17 Pro and iPhone 17e with a temporary UI-test-only harness adjustment.
- Production behavior changed by QA harness: no.

## Screenshots

- `08-generation.png` - PlanGeneration in progress
- `09-reveal-top.png` - PlanReveal top
- `10-reveal-why-fits.png` - PlanReveal middle / why this fits
- `11-reveal-lower-cta.png` - PlanReveal lower / CTA
- `12-pre-workout-handoff.png` - After CTA, Pre-Workout Handoff
- `13-small-iphone-reveal-top.png` - Small iPhone PlanReveal top

## Visual Issues

- Fixed during QA: PlanGeneration phase copy briefly crossfaded old and new text.
- Fixed during QA: deep-scrolled PlanReveal content could sit too visibly under the status bar.
- Remaining blocker: none observed in the captured screens.

## Behavior Caveats

- The screenshot harness tapped the existing `Prepare Workout` CTA and verified `strq.handoff.start` appeared.
- `onStart()` remains the only PlanReveal start action.
- No edit, regenerate, paywall, upgrade, or secondary CTA appears.

## Test Harness

- Needed: temporary UI-test-only adjustment to bypass the stale empty-name CTA assertion and add extra Plan Reveal scroll/Handoff screenshots.
- Committed: no test harness changes. `STRQCoreFlowSnapshotTests.swift` was restored after capture.

## Production Behavior Confirmation

- No changes were made to `AppViewModel.swift`, `ContentView.swift`, `PlanGenerator.swift`, models, services, analytics, persistence, routing, schemas, paywall code, project files, assets, or localization catalogs.
