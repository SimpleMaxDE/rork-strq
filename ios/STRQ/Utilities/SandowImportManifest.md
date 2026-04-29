# Sandow UI Kit Import Manifest

Last audit: 2026-04-29

## Scope

This pass is audit and manifest only. No runtime screens, workout logic, progression logic, persistence, analytics keys, product IDs, exercise data, active workout, rest timer, plan generation, onboarding logic, or paywall logic were modified.

Figma source file: [SH Sandow UI Kit v3.0](https://www.figma.com/design/LBvxljax0ixoTvbvvUeWVC/SH-sandow-UI-Kit--v3.0-?m=auto&t=Cm2KJRPJnU51BdTq-6)

Public product references used only as non-node-level corroboration:

- [strangehelix Sandow UI Kit product page](https://www.strangehelix.bio/product/sandow-ui-kit)
- [UI Custom Sandow UI Kit listing](https://uicustom.com/sandow-ui-kit-ai-fitness--nutrition-app)
- [Freebiesbug free Sandow listing](https://freebiesbug.com/figma-freebies/fitness-nutrition-app/)

## Audit Status

The local STRQ implementation was inspected. The Figma plugin was invoked for the purchased file, but all Figma app calls failed before file access with:

`MCP startup failed: handshaking with MCP server failed ... HTTP request failed ... https://chatgpt.com/backend-api/wham/apps`

Fallback checks:

- Figma REST API without an auth token returned 403.
- Direct unauthenticated file URL fetch returned 404.
- Therefore the purchased Figma file could not be enumerated in this pass.

This manifest must be treated as a coverage manifest plus blocked-inspection ledger, not as a final complete node-by-node inventory. The next audit pass must rerun the Figma inventory when the Figma connector is available.

## Inspected STRQ Files

- `ios/STRQ/Utilities/SandowDesignSystem.swift`
- `ios/STRQ/Assets.xcassets/SandowIcon*.imageset`
- `ios/STRQ/Views/BodyMapView.swift`
- `ios/STRQ/Views/MuscleFocusView.swift`
- `ios/STRQ/Views/MuscleRegionPaths.swift`
- Runtime view search scope: `ios/STRQ/Views/**/*.swift` and `ios/STRQ/ContentView.swift`

No existing `ios/STRQ/Utilities/SandowImportManifest.md` was found before this pass.

## Practical Searches Run

- `SandowDesignSystem`
- `SandowImportManifest`
- `SandowIcon`
- `SandowIconView`
- `SandowButton`
- `SandowCard`
- `SandowChip`
- `SandowMetricCard`
- `SandowProgressBar`
- `SandowProgressRing`
- `SandowTabBar`
- `SandowSchedule`
- `DashboardView Sandow`
- `ContentView Sandow`
- `Image(systemName:)` inside Sandow files
- `exercise.singular`
- `set.plural`
- `Start Session`
- `Per Session`

Results:

- Sandow implementation is isolated in `SandowDesignSystem.swift`.
- No Sandow runtime usage was found in `ios/STRQ/Views` or `ios/STRQ/ContentView.swift`.
- No `Image(systemName:)` usage was found inside `SandowDesignSystem.swift`.
- No raw localization key usage for `exercise.singular` or `set.plural` was found; one unrelated comment contained the phrase "per session".

## Known Figma Nodes To Inspect

These are the currently known nodes from the purchased Sandow file. They are listed here so a follow-up pass can verify them directly when Figma access works.

| Area | Node | Status |
|---|---:|---|
| Foundations page | `5358:6096` | Known, not enumerated in this pass |
| Colors | `5359:9002` | Known, not enumerated in this pass |
| Gradients | `5442:13546` | Known, not enumerated in this pass |
| Typography | `9119:6481` | Known, not enumerated in this pass |
| Effects | `9120:58753` | Known, not enumerated in this pass |
| Size & Spacing | `9122:6944` | Known, not enumerated in this pass |
| Icon Set page | `5367:38988` | Known, not enumerated in this pass |
| Icons | `5454:22014` | Known, not enumerated in this pass |
| General Components page | `5358:4030` | Known, not enumerated in this pass |
| Button | `9128:103928` | Known, not enumerated in this pass |
| Badge & Chip | `9126:59240` | Known, not enumerated in this pass |
| Progress | `9129:207997` | Known, not enumerated in this pass |
| Tab | `9131:172586` | Known, not enumerated in this pass |
| App Components page | `5643:11300` | Known, not enumerated in this pass |
| Navigation | `11614:57585` | Known, not enumerated in this pass |
| Tab Bar | `9131:291579` | Known, not enumerated in this pass |
| List Item | `9134:89206` | Known, not enumerated in this pass |
| Schedule | `9132:170645` | Known, not enumerated in this pass |
| Card - General | `9131:326493` | Known, not enumerated in this pass |
| Card - App Specific | `9160:324200` | Known, not enumerated in this pass |
| Home & Smart Fitness Metrics | `11604:62728` | Known, not enumerated in this pass |
| Achievements / Leaderboard | `11613:176014` | Known, not enumerated in this pass |

## Full Page Inventory

Full page enumeration is blocked until the Figma connector can access the purchased file. Public Sandow product pages indicate the v3 kit contains a large reusable system: 500+ screens, 500+ components, 7 bonus dashboards, dark mode support, accessibility guidance, smart tokens and variables, Sandow icon set, Sandow design system, Work Sans font, and v3 semantic token updates.

Known page-level areas from the current STRQ source and provided node list:

| Page / Area | Known Node | Expected Contents | Inventory Status |
|---|---:|---|---|
| Foundations | `5358:6096` | Colors, gradients, typography, effects, size and spacing | Partial - node IDs known only |
| Icon Set | `5367:38988` | Full Sandow icon library | Partial - node IDs known only |
| General Components | `5358:4030` | Reusable UI primitives | Partial - node IDs known only |
| App Components | `5643:11300` | Mobile app components and fitness-specific modules | Partial - node IDs known only |
| Screen groups | Unknown beyond known screen refs | Home, smart metrics, achievements, leaderboard, likely onboarding, coach, nutrition, progress, paywall, settings, profile, workout patterns | Publicly indicated, exact nodes not verified |
| Asset/media/illustration groups | Unknown | Product imagery, demo photos, avatars, icons, possible illustration/media placeholders | Not verified |

## Body / Muscle / Anatomy / Exercise Asset Audit

Critical status: inconclusive for the purchased Figma file because file-level Figma search was blocked.

No reusable body/anatomy/muscle asset found in inspected areas.

Inspected areas for this statement:

- Current STRQ Sandow implementation
- Current Sandow asset catalog imports
- Current STRQ body/muscle views
- Public Sandow product/listing text available without purchased-file access

| Asset Type | Found In Figma | Page / Node | Current STRQ Equivalent | Reusable For STRQ | Later Import? | Notes |
|---|---|---|---|---|---|---|
| Human body front/back layouts | Not verified | Unknown | Yes, non-Sandow local/remote assets in `MuscleFocusView` and generated body assets | Current STRQ assets are reusable, Sandow status unknown | Decide after Figma search works | Existing STRQ uses generated front/back body images and custom callout overlays |
| Muscle maps | Not verified | Unknown | Yes, custom `BodyMapView` and `MuscleRegionPaths` | Current STRQ implementation is reusable | Import Sandow only if vector anatomy assets exist | Existing muscle paths are code-native and not Sandow-based |
| Anatomy visuals | Not verified | Unknown | Partial, current STRQ generated body imagery | Maybe | Pending Figma search | No Sandow anatomy vector was verified |
| Exercise illustrations | Not verified | Unknown | Exercise media comes from catalog/provider paths, not Sandow | Maybe | Pending Figma search | Do not replace exercise media without separate data/media pass |
| Exercise media placeholders | Not verified | Unknown | `ExerciseThumbnail`, `RemoteExerciseImage`, `GIFImageView` | Maybe | Pending Figma search | Could later adopt placeholder styling only |
| Workout visual cards | Publicly likely | Unknown | Existing STRQ workout/card views, non-Sandow | Yes as pattern | High after components | Figma node IDs not verified |
| Body-part selectors | Not verified | Unknown | `MuscleFocusView` mode/front-back selector | Yes as pattern | High only if found | Existing selector is not Sandow |
| Muscle focus layouts | Not verified | Unknown | `MuscleFocusView` | Yes | Pending decision | STRQ already has a domain-specific implementation |
| Fitness/person silhouettes | Not verified | Unknown | Generated local/remote body images | Maybe | Pending search | No Sandow silhouette asset verified |
| Body scan / health score visuals | Not verified | Unknown | Partial readiness/physique cards | Maybe | Medium if present | Likely relevant to smart metrics but unverified |
| SVG/vector body assets | Not verified | Unknown | Code-native paths, not imported SVGs | Yes if found | High if present | Requires direct Figma search for `body`, `muscle`, `anatomy`, `human`, `front`, `back` |

Required Figma follow-up keywords:

`muscle`, `muscles`, `anatomy`, `body`, `body map`, `human`, `front`, `back`, `exercise`, `workout`, `gym`, `fitness`, `illustration`, `media`, `image`, `avatar`, `coach`, `nutrition`, `sleep`, `progress`, `analytics`, `chart`, `score`, `achievement`, `leaderboard`, `paywall`, `subscription`, `onboarding`, `profile`, `settings`, `watch`, `device`, `tab bar`, `navigation`, `modal`, `bottom sheet`, `card`, `list item`, `schedule`, `icon`.

## Foundation Coverage

| Foundation Area | Figma Inventory | Current STRQ Sandow Implementation | Missing / Extra | Status |
|---|---|---|---|---|
| Colors | Known node `5359:9002`; public v3 source indicates semantic tokens and variables | `SandowColors` includes black/white, gray 50-950, orange 50-950, accent blue/purple/lime/amber/rose, dark surfaces, text, borders, brand, success/warning/danger aliases | Missing exact Figma variable names, modes, full semantic taxonomy, light-mode aliases, accessibility/contrast modes if present. Extra STRQ aliases preserve earlier pass compatibility | Partial |
| Gradients | Known node `5442:13546`; exact count not verified | `SandowGradients` includes orange CTA, orange glow, dark card, inset card, subtle overlay, progress orange/success/warning/danger | Missing full Figma gradient inventory, mesh/dashboard/media gradients, real component usage map | Partial |
| Typography | Known node `9119:6481`; public source confirms Work Sans font included | `SandowTypography` uses Work Sans, display/heading/title/metric/body/caption/label/chip/button/tab roles, selected line heights and tracking | Work Sans files are not bundled (`workSansFontFilesBundled = false`). Missing exact Figma text style list, all roles, font fallback policy, complete line-height/tracking mapping | Partial |
| Effects | Known node `9120:58753`; exact style inventory not verified | `SandowEffects` includes hairline, selected border, focus ring width, card/divider borders, soft/card/subtle/orange shadows, background blurs, dark glass background/stroke | Missing exact Figma effects, glows, blur styles, selected/focus/error state effects, style names | Partial |
| Size & Spacing | Known node `9122:6944`; exact tokens not verified | `SandowSpacing` includes 0, 2, 4, 6, 8, 10, 12, 14, 16, 20, 24, 32, 40, 48, 56, 64, 80, 96, 128 plus card/list/chip/button/icon/tab/nav sizes. `SandowRadii` includes 0, 2, 4, 8, 12, 16, 20, 24, 32, full plus component radii | Missing exact Figma token names, responsive frame sizes, all component dimensions, modal/bottom sheet/input/chart heights if present | Partial |

## Component Coverage

| Category | Figma Exists | Figma Node(s) | SwiftUI Exists | Current Status | Missing Variants / Notes | Import Priority |
|---|---|---:|---|---|---|---|
| Buttons | Yes, known | `9128:103928` | Yes, `SandowButton` | Partial | Needs verified loading, pressed, disabled, icon position, destructive, text-only, size/state parity | High |
| Icon Buttons | Likely via Button | `9128:103928` | Yes, `SandowButton(icon:)` | Partial | Needs exact Figma size/state/radius/tone parity | High |
| Chips | Yes, known | `9126:59240` | Yes, `SandowChip` | Partial | Needs all tones, selected/removable/icon variants verified | High |
| Badges | Yes, known | `9126:59240` | Yes, `SandowBadge` | Partial | Needs count/status/achievement parity verified | High |
| Cards | Yes, known | `9131:326493` | Yes, `SandowCard`, `SandowSurface` | Partial | General card shells exist; exact Figma variants and media cards not mapped | High |
| Metric Cards | Yes, screen/app likely | `11604:62728`, app card nodes unknown | Yes, `SandowMetricCard` | Partial | Needs smart fitness metric and dashboard variants | High |
| App-specific Cards | Yes, known | `9160:324200` | No dedicated app card set | Missing | Workout, nutrition, coach, achievement, paywall, article cards not modeled | High |
| Progress Bars | Yes, known | `9129:207997` | Yes, `SandowProgressBar` | Partial | Needs labels, statuses, sizes, stacked/loader variants verified | High |
| Progress Rings | Yes, likely | `9129:207997` | Yes, `SandowProgressRing` | Partial | Needs exact ring sizing, score/activity variants, labels | Medium |
| Tabs | Yes, known | `9131:172586` | Partial | Partial | Tab bar item exists; independent segmented tabs are not implemented | High |
| Tab Bar | Yes, known | `9131:291579` | Yes, `SandowTabBar` | Partial | Needs exact layout, safe-area behavior, center action variants | High |
| Navigation/App Bar | Yes, known | `11614:57585` | No dedicated Sandow nav/app bar | Missing | Current app screens use existing STRQ navigation patterns | High |
| Bottom Sheet | Unknown | Unknown | No Sandow primitive | Missing | Needs Figma search before import | Medium |
| Modal | Unknown | Unknown | No Sandow primitive | Missing | Needs Figma search before import | Medium |
| Inputs | Public changelog indicates improved inputs | Unknown | No Sandow input | Missing | Text field, number input, search, radio, file upload may exist in kit | High |
| Search | Public changelog indicates search screens | Unknown | No Sandow search component | Missing | Search field and result rows needed for STRQ library/settings | High |
| List Items | Yes, known | `9134:89206` | Yes, `SandowListItem` | Partial | Needs avatar, icon, chevron, divider, selection, settings row variants | High |
| Schedule Rows | Yes, known | `9132:170645` | Yes, `SandowScheduleRow`, `SandowScheduleCard` | Partial | Needs exact day/session/date variants | High |
| Sliders / Toggles | Unknown, likely | Unknown | No Sandow primitive | Missing | Settings and preference controls needed | Medium |
| Charts | Public source indicates data-driven metrics | Unknown | No Sandow chart primitives | Missing | Analytics and dashboard chart patterns likely required | High |
| Avatars | Search not possible; likely | Unknown | Partial via text avatar in `SandowListItem` | Partial | Image/avatar stack/status variants missing | Medium |
| Rating / Feedback | Likely screen pattern | Unknown | No Sandow primitive | Missing | Useful for feedback flows only | Low |
| Empty States | Unknown | Unknown | No Sandow primitive | Missing | Later import if Figma has reusable empty states | Medium |
| Coach/message bubbles | Public source indicates AI chatbot | Unknown | No Sandow chat primitive | Missing | Coach tab/chat bubbles should be imported before coach UI migration | High |
| Article/news cards | Unknown | Unknown | No Sandow primitive | Missing | Low relevance unless STRQ adds content feed | Low |
| Paywall plan cards | Likely screen pattern | Unknown | No Sandow primitive | Missing | Needed for paywall visual migration, but runtime paywall untouched now | Medium |
| Achievement cards | Yes, known screen ref | `11613:176014` | Partial badge only | Missing | Cards, trophies, progress/earned states not implemented | Medium |
| Leaderboard rows | Yes, known screen ref | `11613:176014` | Partial via list item | Missing | Rank, avatar, score, streak variants missing | Medium |
| Settings rows | Likely screen pattern | Unknown | Partial via list item | Partial | Toggles, destructive rows, disclosure groups missing | Medium |
| Workout cards | Likely screen/app pattern | Unknown | No dedicated Sandow workout card | Missing | Needed for TrainingPlan/Workout migration, not runtime now | High |
| Exercise cards | Likely screen/app pattern | Unknown | No dedicated Sandow exercise card | Missing | Exercise media/thumbnail variants pending Figma search | High |
| Muscle/body selectors | Not verified | Unknown | No Sandow primitive; STRQ has non-Sandow `MuscleFocusView` | Missing / Manual decision | Do not import until anatomy audit can verify assets | High if found |

## Icon Coverage

### Figma Icon Set

The provided known icon set nodes are:

- Icon Set page: `5367:38988`
- Icons: `5454:22014`

The full Figma icon base count and style/variant count could not be enumerated because Figma access was blocked. Public product/listing sources indicate Sandow includes a large custom icon set, with listings describing 765+ to 1,000+ icons across versions and v3 "revamped UI icons". Exact v3 base icons and style variants must be verified directly in Figma.

### Current STRQ Icons

Current `SandowIcon` enum and matching `.imageset` assets include 21 icons:

- `home`
- `coach`
- `train`
- `progress`
- `profile`
- `recovery`
- `calendar`
- `sleep`
- `check`
- `search`
- `plus`
- `chevronRight`
- `arrowRight`
- `checkCircle`
- `clock`
- `target`
- `trophy`
- `barbell`
- `weightScale`
- `bell`
- `star`

### Missing Core App Icons

High-value missing icons for STRQ:

- Navigation/actions: back, close, menu, more, edit, trash, share, filter, sort, info, alert, lock, crown, premium, settings
- Training: dumbbell, workout, exercise, sets, reps, timer, rest, swap, history, calendar-day, intensity, volume
- Progress/analytics: chart, line-chart, activity, trend-up, trend-down, score, gauge, target variants
- Coach/chat: chat, send, sparkle/AI, microphone, attachment, insight
- Health/body: body, muscle, heart, recovery, sleep detail, nutrition, water, weight, watch/device
- Account/settings: profile variants, notification, privacy, support, feedback, logout

### Import Strategy

- Import each base icon once as a template SVG or vector PDF.
- Name assets `SandowIcon<Name>.imageset`.
- Preserve vector representation and template rendering intent.
- Tint via `SandowIconView` in SwiftUI.
- Do not import duplicate color variants or state variants unless the icon is truly multicolor or custom-rendered.
- Use color/state in SwiftUI components instead of duplicating Figma icon styles.
- Keep `SandowIcon` as the single enum registry.

### Next Icons To Import First

1. `settings`
2. `close`
3. `back`
4. `more`
5. `edit`
6. `trash`
7. `filter`
8. `chart`
9. `activity`
10. `dumbbell`
11. `timer`
12. `swap`
13. `chat`
14. `send`
15. `sparkle`
16. `nutrition`
17. `water`
18. `heart`
19. `watch`
20. `lock`
21. `crown`

## Screen / Pattern Inventory

Full screen group enumeration is blocked until the Figma connector can inspect the purchased file. Public Sandow materials and known nodes indicate the following screen/pattern coverage should exist or be searched for:

| Pattern | Page / Node | Useful Patterns | STRQ Needs It | Later Migration Target |
|---|---:|---|---|---|
| Home / Dashboard | `11604:62728` | Smart fitness metrics, dashboard cards, app-specific metric layout | Yes | `DashboardView` only in a dedicated later pass |
| Progress / Analytics | Unknown | Charts, scores, trend cards, progress visualization | Yes | `ProgressAnalyticsView` |
| Achievements | `11613:176014` | Achievement cards, badge states, empty/earned states | Maybe | Progress/achievements module |
| Leaderboard | `11613:176014` | Rank rows, avatar rows, score comparison | Maybe | Social/progress feature if retained |
| Paywall / Subscription | Unknown | Plan cards, feature lists, CTA hierarchy | Yes | `STRQPaywallView` later |
| Onboarding / Welcome | Unknown; public free listing mentions welcome screens | Hero/welcome, account setup, preference capture | Yes | `OnboardingView` later |
| Profile | Unknown | Account summary, stats, profile cards | Yes | `ProfileView` later |
| Settings | Unknown | Rows, toggles, sections, account actions | Yes | Settings/profile flows |
| Coach / AI Coach | Unknown; public product page mentions AI chatbot | Message bubbles, coach cards, chat input, insights | Yes | `CoachTabView`, coaching cards |
| Nutrition | Unknown; public product page positions kit for fitness and nutrition | Food/nutrition logs, macros, meal cards | Maybe | `NutritionLogView`, nutrition settings |
| Sleep | Unknown | Sleep score cards, trend rows | Maybe | `SleepLogView`, readiness surfaces |
| Workout | Unknown | Workout cards, activity tracking, session states | Yes | `TrainingPlanView`, workout surfaces |
| Exercise Detail | Unknown | Exercise cards, media placeholders, detail stats | Yes | `ExerciseDetailView`, `ExerciseHeroView` |
| Activity | Unknown; public product page mentions activity tracker | Activity cards, score rings, daily summaries | Yes | Dashboard/readiness/progress |
| Watch / Device | Unknown | Device cards, sync states, wearable stats | Maybe | Watch connectivity/settings |
| Support / Chat | Unknown | Help/chat rows, support threads | Maybe | Support/settings |
| Feedback / Rating | Unknown | Rating prompts, feedback forms | Low | Post-session feedback if needed |

## Current STRQ Coverage

### Imported Foundation

Current `SandowDesignSystem.swift` includes:

- Source metadata and known node IDs.
- Isolated Sandow colors, gradients, typography, spacing, radii, effects.
- Component style helpers for surfaces, borders, radii, tones.
- Icon registry and `SandowIconView`.
- Sandow primitives: icon container, surface, card, button, chip, badge, metric card, progress bar, progress ring, progress row, list item, section header/action, tab bar primitives, schedule row/card, preview-only samples.

### Imported Assets

Current Sandow icon assets:

- `SandowIconArrowRight.imageset`
- `SandowIconBarbell.imageset`
- `SandowIconBell.imageset`
- `SandowIconCalendar.imageset`
- `SandowIconCheck.imageset`
- `SandowIconCheckCircle.imageset`
- `SandowIconChevronRight.imageset`
- `SandowIconClock.imageset`
- `SandowIconCoach.imageset`
- `SandowIconHome.imageset`
- `SandowIconPlus.imageset`
- `SandowIconProfile.imageset`
- `SandowIconProgress.imageset`
- `SandowIconRecovery.imageset`
- `SandowIconSearch.imageset`
- `SandowIconSleep.imageset`
- `SandowIconStar.imageset`
- `SandowIconTarget.imageset`
- `SandowIconTrain.imageset`
- `SandowIconTrophy.imageset`
- `SandowIconWeightScale.imageset`

Other body assets exist in `Assets.xcassets`, but they are not Sandow imports:

- `body_female_back.imageset`
- `body_female_front.imageset`
- `body_male_back.imageset`
- `body_male_front.imageset`
- `male_back_premium.imageset`
- `male_front_premium.imageset`

### Runtime Usage

No Sandow references were found in runtime views or `ContentView.swift`. Sandow foundation remains optional and isolated.

## Missing Items

Foundation:

- Exact Figma variable collections, modes, token names, values, scopes, and aliases.
- Full color/gradient/text/effect/grid style inventory.
- Work Sans font file bundling decision.
- Exact light/dark mode mapping and accessibility/contrast modes.

Components:

- Navigation/app bar.
- Inputs, search, toggles, sliders, number inputs, radio controls.
- Bottom sheet and modal primitives.
- Chart primitives and analytics cards.
- Coach/chat components.
- Paywall plan cards.
- Workout/exercise cards.
- Achievement/leaderboard components.
- Empty states and feedback/rating components.
- Muscle/body selector components if present in Sandow.

Icons:

- Full Sandow icon set inventory.
- Icon category map.
- Base icon count and style count.
- Missing core UI/action/fitness/health/chat/settings icons listed above.

Screens:

- Full page and screen group inventory.
- Exact node IDs for onboarding, paywall, profile, settings, coach, nutrition, sleep, workout, exercise detail, watch/device, support/chat, feedback/rating.

Body/anatomy:

- No verified Sandow body/anatomy/muscle SVG/vector asset.
- Needs direct Figma keyword search before any import decision.

## Intentionally Excluded Items

- Runtime screens in this pass:
  - `DashboardView`
  - `ContentView`
  - `ProgressAnalyticsView`
  - `STRQPaywallView`
  - `ProfileView`
  - `OnboardingView`
  - `ActiveWorkoutView`
  - `WorkoutCompletionView`
- Workout logic, progression logic, persistence, analytics keys, product IDs, exercise data, active workout, rest timer, plan generation, and onboarding logic.
- Sandow demo photos, marketing mockups, full source Figma export, full ZIP contents, and any nonessential media assets.
- Duplicate icon color/style/state variants that can be represented by one template asset plus SwiftUI tint.
- Raw localization keys.

## Recommended Next Import Passes

1. Figma connector recovery and full inventory pass.
   - Enumerate all pages, top-level sections, component sets, variables, styles, screen groups, asset/media groups, and keyword matches.
   - Save exact page/node inventory back into this manifest.

2. Icon base-template import pass.
   - Import missing core action, settings, training, analytics, coach, nutrition, and health icons as template SVGs.
   - Keep one base icon per concept unless truly multicolor.

3. Foundation parity pass.
   - Compare exact Figma variables/styles against `SandowColors`, `SandowGradients`, `SandowTypography`, `SandowEffects`, `SandowSpacing`, and `SandowRadii`.
   - Add missing tokens without changing runtime screens.

4. General primitive parity pass.
   - Button, chip, badge, card, progress, tabs, inputs, search, modal, sheet, toggles, sliders.

5. App component parity pass.
   - Navigation, tab bar, list item, schedule, app-specific cards, metric cards, chart cards, workout/exercise cards.

6. Body/anatomy decision pass.
   - If Sandow includes reusable body/anatomy/muscle assets, import the vector base assets and bind STRQ muscle overlays to them.
   - If Sandow has only demo/person imagery, keep STRQ's existing body map system and only apply Sandow surface/tokens later.

7. Screen migration planning pass.
   - Plan one runtime screen at a time, starting with the least risky contained surfaces.
   - Do not migrate `DashboardView` until component/icon/foundation parity is complete.

## Rules For Using Sandow Foundation In STRQ

- Sandow remains an optional visual layer until a dedicated migration pass.
- Do not override `STRQPalette` or existing brand systems globally.
- Use Sandow components explicitly and locally.
- Replace one contained surface at a time.
- Never mix a runtime logic change with a visual migration.
- Use `L10n.tr` for user-facing copy; do not introduce raw localization keys.
- Use one template icon per base concept and tint in SwiftUI.
- Do not import duplicate icon variants for color, hover, selected, disabled, or size states.
- Do not import demo photos, marketing mockups, or unused media.
- Preserve exercise data and media-provider ownership unless a separate media migration is approved.
- Treat anatomy/body assets as a special decision area: direct Figma verification is required before importing.
