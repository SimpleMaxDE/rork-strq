# Fresh User Journey QA Snapshot - 2026-05-13

## Tested Build

- Commit tested: `60cd0f734aabb2d85d7dbe8180ef65fcff1b4791`
- Branch: `main`
- Xcode: Xcode 26.5, Build version 17F42
- Simulator: iPhone 17 Pro, iOS 26.5 (`2DFD062E-297A-4E7F-9674-2D9EC522AF27`)
- Preflight pull: `git pull --ff-only` returned `Already up to date.`
- Build command: `xcodebuild -project ios/STRQ.xcodeproj -scheme STRQ -configuration Debug -sdk iphonesimulator -destination 'generic/platform=iOS Simulator' CODE_SIGNING_ALLOWED=NO build`
- Build result: passed

## Screenshots

1. `01-onboarding-welcome.png`
2. `02-onboarding-goal.png`
3. `03-onboarding-training.png`
4. `04-onboarding-setup-equipment.png`
5. `05-onboarding-lifestyle-final-cta.png`
6. `06-plan-generation.png`
7. `07-plan-reveal-top.png`
8. `08-plan-reveal-why-fit-section.png`
9. `09-plan-reveal-lower-cta.png`
10. `10-pre-workout-handoff-top.png`
11. `11-pre-workout-handoff-lower.png`
12. `12-active-workout-first-set.png`
13. `13-active-workout-after-one-logged-set.png`

Optional Today and Progress/Training Map screens were not captured because the required journey did not naturally land there during this pass.

Contact sheet: `contact-sheet.jpg`

## Strongest Screens

- Plan Reveal top and why/fit sections: clear plan summary, confident hierarchy, and good continuity into the sticky prepare CTA.
- Pre-Workout Handoff: the top and lower states clearly explain the next workout, readiness context, exercise list, and why this workout fits.
- Active Workout first set: strong task focus, legible controls, and clear set table state.
- Onboarding welcome: concise positioning and the refreshed shell feels consistent with the later screens.

## Weakest Screens

- Lifestyle/final CTA is the densest onboarding step. The sticky CTA works, but it leaves less breathing room around the sleep/stress controls.
- Plan Generation is visually aligned, but much of the supporting content begins below the first viewport, so the first impression leans heavily on the loader card.
- Active Workout after one logged set verifies progression, but the header still reads `0/5` while the set table reads `1/3`, which may be interpreted as no progress unless users understand it is exercise-level progress.

## Visual Inconsistencies

- The sticky bottom CTA treatment is consistent across reveal and handoff, but the lower-scroll captures show content fading under the bottom overlay. It is intentional-looking, though it slightly reduces readability at the fold.
- Long exercise names truncate in plan and handoff rows, for example `Kettlebell Alternating Reneg...`. This appears expected and still usable because rows have a detail affordance.
- The after-one-logged-set screenshot is German because it was captured via direct simulator relaunch after the XCTest run; the XCTest launch path captured the earlier screens in English.

## Clipping And Localization

- No hard clipping or overlapping text was found in the required English onboarding, plan, reveal, handoff, or first active workout screenshots.
- The German after-log screenshot does not show clipping, but it should not be treated as a localization audit for the full flow because only that state was captured after relaunch.

## Behavior Issues

- The fresh-journey XCTest capture timed out after tapping `Log Set` while querying the optional rest/continue control. The persisted app state was then verified with a live simulator screenshot showing set 1 logged and set 2 active.
- No production behavior was changed for this snapshot.

## Recommended Next Priority

Stabilize the screenshot harness around the active workout post-log/rest transition, then capture the after-log state through the same English XCTest launch path. Product-wise, consider clarifying the active workout `0/5` header progress versus set progress so first-time users do not read it as a failed log.
