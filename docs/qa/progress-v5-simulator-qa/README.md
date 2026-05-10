# Progress V5 Simulator QA

Run date: 2026-05-10

## Environment

- Host: macOS Cloud Mac with Xcode/simulator access
- Xcode: 26.3 (Build 17C529)
- Simulator used for screenshots: iPhone 17 Pro, iOS 26.2 (`D0B148E5-33DC-4B9C-8843-CD44A06E869D`)
- Commit tested: `29c3081`
- App bundle: `app.rork.40gfu7dywfru7n82xfoy4`

## Access Path

V5 was already reachable in the running Debug app through:

`Profile` -> `Internal Preview: Progress V5 Experience`

No repository access patch was needed. The fresh simulator was seeded with a minimal local app-container state to mark onboarding complete so the existing Profile route could be reached. This was simulator-local QA setup only and did not change app code.

## Screenshots

- `progress-v5-entry.png` - Profile entry point with the internal V5 row visible
- `progress-v5-beginner-top.png` - Beginner scenario top area
- `progress-v5-beginner-bottom.png` - Beginner scenario lower area
- `progress-v5-athlete-top.png` - Athlete scenario top area
- `progress-v5-athlete-bottom.png` - Athlete scenario lower area
- `progress-v5-switcher.png` - State switcher visible

All screenshots are 1206 x 2622 PNG captures from the simulator display.

## Findings

- V5 was visible in the simulator.
- The state switcher worked for Beginner and Athlete.
- Athlete top: the hero title truncates at the end (`gui...`) on iPhone 17 Pro.
- Lower-area captures can sit close to the translucent nav/tab chrome while scrolling, especially near the Evidence Timeline and Deeper Analytics sections.
- No visible `demo`, `prototype`, `mock`, or `sample` wording was seen inside the V5 surface. The entry route uses `Internal Preview`.

## Scope Confirmations

- `ios/STRQ/Views/ProgressAnalyticsView.swift` was not changed.
- The real Progress tab was not replaced.
- V5 continued to use local scenario data only.
- No models, services, analytics, persistence, localization, assets, tests, widgets, watch targets, fonts, workout execution, plan generation, or HealthKit files were changed.

## Caveats

- The focused `ProgressMuscleCoverageCalculatorTests` command did not complete because the explicit `name=iPhone 16` destination resolved to `OS:latest` and then the explicit iPhone 16 device-id retry failed to launch the test runner with Mach error `-308`.
- The same focused test suite passed on the iPhone 17 Pro iOS 26.2 simulator used for screenshot QA.
- Screenshot QA used the iPhone 17 Pro iOS 26.2 simulator because it was already booted and the Debug app launched successfully there.
