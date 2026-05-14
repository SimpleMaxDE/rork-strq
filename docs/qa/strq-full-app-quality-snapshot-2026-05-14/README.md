# STRQ Full App Quality Snapshot - 2026-05-14

## Run Context

- Commit tested: `edeea8f7c68bfcbb85d9dd57f0043912c02fd7e1`
- Branch tested: `main`
- Xcode: `Xcode 26.5` (`17F42`)
- Simulator: iPhone 17 Pro, iOS 26.5 (`2DFD062E-297A-4E7F-9674-2D9EC522AF27`)
- Build command: `xcodebuild -project ios/STRQ.xcodeproj -scheme STRQ -configuration Debug -sdk iphonesimulator -destination 'generic/platform=iOS Simulator' CODE_SIGNING_ALLOWED=NO build`
- Build result: succeeded
- Snapshot capture: XCTest snapshot harness plus live XcodeBuildMCP navigation/screenshots for Exercise Library, Training Map, and Profile follow-up screens.
- Contact sheet: `contact-sheet.jpg`

## Screenshots

1. `01-onboarding-welcome.png` - Onboarding welcome
2. `02-onboarding-goal.png` - Onboarding goal
3. `03-onboarding-training.png` - Onboarding training setup
4. `04-plan-generation.png` - Plan Generation
5. `05-plan-reveal.png` - Plan Reveal
6. `06-today-top.png` - Today top
7. `07-pre-workout-handoff-top.png` - Pre-Workout Handoff top
8. `08-active-workout-current-set.png` - Active Workout current set
9. `09-active-workout-set-history.png` - Active Workout set history
10. `10-exercise-library-default.png` - Exercise Library default
11. `11-exercise-library-search-squat.png` - Exercise Library search `squat`
12. `12-exercise-detail-anatomy.png` - Exercise Detail anatomy target
13. `13-training-map-candidate-top.png` - Progress / Training Map candidate top
14. `14-training-map-candidate-evidence-signal.png` - Progress / Training Map evidence signal
15. `15-strq-pro-profile-card.png` - STRQ Pro Profile card
16. `16-strq-pro-package-preview.png` - STRQ Pro Paywall/package preview
17. `17-production-progress-tab-top.png` - Current production Progress tab top
18. `18-profile-top-settings.png` - Profile top/settings

## Strongest Current Screens

- Today top: clear command hierarchy, strong workout card, and the readiness/plan context lands quickly.
- Pre-Workout Handoff and Active Workout: the training flow feels coherent, focused, and ready for real use.
- Training Map candidate: the node map and evidence timeline feel like the most distinctive STRQ product surface.
- STRQ Pro profile/package preview: strong preview state, clear package-readiness messaging, and no accidental purchase path.
- Exercise Detail anatomy target: the lower-body primary/secondary target view is a strong educational proof point.

## Weakest Current Screens

- Current production Progress tab is useful, but visually less ownable than the Training Map candidate.
- Exercise Library search results are functional, but some result thumbnails still read as placeholders/loading states in the captured `squat` query.
- Exercise detail has strong anatomy lower in the sheet, but the top media treatment is lower contrast and less polished than the newer STRQ surfaces.
- Onboarding is cohesive, but it is quieter and more generic than the later Today/Training Map surfaces.

## Visual Inconsistencies

- Progress has two competing languages: the production report card and the Training Map candidate.
- Accent systems vary across areas: orange Train, green Today/recovery, teal Training Map, and purple Pro. This is workable, but needs a deliberate token story before wider polish.
- The newer command/workout surfaces feel denser and more premium than onboarding.
- Live XcodeBuildMCP captures are lower-resolution optimized screenshots than XCTest attachment exports, so this folder mixes capture resolutions.

## Behavior Issues

- XcodeBuildMCP `snapshot_ui` returned an empty accessibility hierarchy for the running app, so live navigation used MCP coordinate gestures. XCTest identifiers were still usable in the snapshot harness, but external QA automation visibility should be investigated.
- The Today warning body truncates in the top card: `This could slow progress on that muscl...`.
- Exercise Library search shows several gray/loading thumbnails in the `squat` results. Confirm whether those are expected cache states or missing media.
- The Pro package preview remained in a safe preview/no-purchase state as expected.

## Localization / Copy Issues

- Captures were taken in English (`en_US`). German/localized copy was not evaluated in this snapshot.
- Some English copy is strong and product-specific, especially Training Map and Today.
- Truncation in Today warning copy should be tightened or given more room.
- Pro preview copy is clear, but the purple premium language should be reviewed alongside core STRQ tone before production launch.

## Recommended Next Priority

Productionize Progress / Training Map next. It is the clearest candidate for a signature STRQ surface, and it outperforms the current Progress tab visually and conceptually. Before shipping it as the main Progress experience, align the Progress visual language, add stable snapshot coverage for Training Map and Exercise Library, and fix the accessibility visibility issue affecting XcodeBuildMCP live QA.
