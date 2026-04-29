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

Previous audit conclusion was blocked by Figma connector failure and is superseded. On 2026-04-29, the Figma connector successfully inspected the requested Sandow Foundations, Media, and Illustration nodes.

The current status remains audit and manifest only. No Sandow assets were imported. No runtime screens, Swift files, asset catalogs, localization, product IDs, workout logic, persistence, analytics, onboarding logic, or data models were modified.

Figma recheck completed:

- Foundations page `5358:6096` exists and contains the expected top-level sections.
- Media node `9125:50816` exists.
- Illustration node `9125:148813` exists.
- Anatomy Muscle node `8673:69673` exists and was inspected with metadata plus screenshot.
- Body Type node `9025:207456` exists and was inspected with metadata plus screenshot.
- Organ Anatomy node `9139:70026` exists and was inspected with metadata plus screenshot; its base type set is `_OrganAnatomyBase` at `8860:134805`.
- Large anatomy/body vector groups parent `9192:5535` exists and was inspected with metadata plus screenshot.
- Fitness Equipment Image area `11536:90366` exists and was inspected with metadata plus screenshot.
- Anatomy Muscle import strategy is documented in `SandowAnatomyImportPlan.md`.

This manifest is no longer blocked for the body/anatomy/muscle conclusion. It is still not a full file-wide inventory of every Sandow page, component, token, icon, and screen group.

## Inspected STRQ Files

- `ios/STRQ/Utilities/SandowDesignSystem.swift`
- `ios/STRQ/Assets.xcassets/SandowIcon*.imageset`
- `ios/STRQ/Views/BodyMapView.swift`
- `ios/STRQ/Views/MuscleFocusView.swift`
- `ios/STRQ/Views/MuscleRegionPaths.swift`
- Runtime view search scope: `ios/STRQ/Views/**/*.swift` and `ios/STRQ/ContentView.swift`

For this correction pass, only `ios/STRQ/Utilities/SandowImportManifest.md` was edited. Runtime files remain unchanged.

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

These are the currently known nodes from the purchased Sandow file. The Foundations, Media, and Illustration nodes below were rechecked directly through the Figma connector on 2026-04-29.

| Area | Node | Status |
|---|---:|---|
| Foundations page | `5358:6096` | Verified; top-level sections enumerated |
| Colors | `5359:9002` | Verified as Foundations top-level section |
| Gradients | `5442:13546` | Verified as Foundations top-level section |
| Typography | `9119:6481` | Verified as Foundations top-level section |
| Logo | `9120:37139` | Verified as Foundations top-level section |
| Effects | `9120:58753` | Verified as Foundations top-level section |
| Grid | `9122:4683` | Verified as Foundations top-level section |
| Size & Spacing | `9122:6944` | Verified as Foundations top-level section |
| Media | `9125:50816` | Verified as Foundations top-level section |
| Illustration | `9125:148813` | Verified as Foundations top-level section |
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
| Illustration / Anatomy Muscle | `8673:69673` | Verified; 60-variant component set |
| Illustration / Body Type | `9025:207456` | Verified; 12-variant component set |
| Illustration / Organ Anatomy | `9139:70026` | Verified size wrapper; base types at `8860:134805` |
| Illustration / large anatomy vector groups | `9192:5535` | Verified; 4 generic groups, 225 vectors |
| Media / Fitness Equipment Image | `11536:90366` | Verified; image/demo asset area |

## Full Page Inventory

Full page enumeration was not completed in this correction pass. The Figma connector can access the purchased file, but this pass was intentionally limited to the requested Foundations, Media, Illustration, body/anatomy/muscle, and equipment nodes. Public Sandow product pages indicate the v3 kit contains a large reusable system: 500+ screens, 500+ components, 7 bonus dashboards, dark mode support, accessibility guidance, smart tokens and variables, Sandow icon set, Sandow design system, Work Sans font, and v3 semantic token updates.

Known page-level areas from the current STRQ source and provided node list:

| Page / Area | Known Node | Expected Contents | Inventory Status |
|---|---:|---|---|
| Foundations | `5358:6096` | Colors, gradients, typography, logo, effects, grid, size and spacing, media, illustration | Verified top-level section list |
| Icon Set | `5367:38988` | Full Sandow icon library | Partial - node IDs known only |
| General Components | `5358:4030` | Reusable UI primitives | Partial - node IDs known only |
| App Components | `5643:11300` | Mobile app components and fitness-specific modules | Partial - node IDs known only |
| Screen groups | Unknown beyond known screen refs | Home, smart metrics, achievements, leaderboard, likely onboarding, coach, nutrition, progress, paywall, settings, profile, workout patterns | Publicly indicated, exact nodes not verified |
| Asset/media/illustration groups | `9125:50816`, `9125:148813` | Media component groups, image/demo assets, illustration assets, anatomy/body/muscle component sets | Partial - requested nodes verified |

## Body / Muscle / Anatomy / Exercise Asset Audit

Critical correction: the previous body/anatomy conclusion was blocked by Figma connector failure and is superseded. Reusable body/anatomy/muscle assets were found in the Figma Foundations > Illustration section.

Direct Figma inspection confirmed:

- `9125:148813` Illustration contains `8673:69673` Anatomy Muscle, `9025:207456` Body Type, `9139:70026` Organ Anatomy, `9192:5535` large anatomy/body vector groups, `9064:106798` Achievement Badge, `_AchievementBadgeBase` `9063:203904`, `_OrganAnatomyBase` `8860:134805`, and `_IllustrationBase` `8912:62197`.
- `9125:50816` Media contains `11536:90366` Fitness Equipment Image area, plus Avatar, Flag, Video Player, Image Thumbnail, Gallery, Gallery Row, Credit Card, Credit Card Thumbnail, File Types, and Street Map component groups.

| Area | Node ID | Variants | STRQ relevance | Import priority | Status | Notes |
|---|---:|---|---|---|---|---|
| Illustration / Anatomy Muscle | `8673:69673` | 60 variants; Gender: Male, Female; Is Selected: true, false; Body Area: Lower Leg, Upper Leg, Abs, Chest, Shoulder, Bicep, Forearm, Hand, Neck, Tricep, Hamstring, Glute, Calf, Back, Trap | Muscle focus visuals, exercise details, onboarding body selectors, workout analytics | High | Found; metadata and screenshot verified | Reusable for STRQ: yes. Figma names use `Is Selected=true/false`, which maps to selected/not selected state. Prefer base assets plus SwiftUI state styling rather than importing every state blindly. |
| Illustration / Body Type | `9025:207456` | 12 variants; Gender: Male, Female; Type: Ectomorph, Mesomorph, Endomorph; State: Default, Selected | Onboarding/profile/body goal visuals | Medium | Found; metadata and screenshot verified | Reusable for STRQ: yes, but not first import priority. |
| Illustration / Organ Anatomy | `9139:70026`; base `8860:134805` | Size wrapper: sm, md, lg, xl, 2xl; base types: Lung, Brain, Kidney, Heart, Stomach, Small Intestine, Large Intestine, Liver, Pancreas, Urinary Bladder, Spine, Knee, Skin, Eye, Gallbladder, Tooth, Breast, Genital Male, Genital Female | Health, recovery, coach, educational visuals | Low/medium | Found; metadata and screenshot verified | Reusable for STRQ: maybe. `9139:70026` controls size; `_OrganAnatomyBase` `8860:134805` holds exact organ/body type variants. |
| Media / Fitness Equipment Image | `11536:90366` | No component variants; image area contains 20 equipment image rectangles under `11536:90365`, each 128x128 | Equipment visuals, exercise filters, gym setup/onboarding | Medium | Found; metadata and screenshot verified | Reusable for STRQ: maybe. Screenshot shows photo/demo-style equipment imagery, so inspect licensing/export quality before importing. |
| Illustration / large anatomy vector groups | `9192:5535` | 4 generic `Group` children with 225 vectors total | Possible large body/anatomy visuals for selectors, analytics, or exercise detail | Pending | Found; metadata and screenshot verified; export strategy pending | Reusable for STRQ: likely, pending export feasibility. Screenshot shows large male/female front/back anatomy line-art groups, but metadata labels remain generic `Group`/`Vector`. |

Detailed strategy: see `ios/STRQ/Utilities/SandowAnatomyImportPlan.md`.

Anatomy Muscle strategy summary:

- `8673:69673` is a 60-variant vector-only Figma component set: 2 genders x 15 body areas x selected/unselected state.
- All direct variants are Figma components; no image paints, gradients, or text nodes were found.
- Selected/unselected state is represented by separate Figma component variants, but the state difference is primarily color.
- Recommended future import strategy is base anatomy line art plus per-area masks/overlays, with selected/unselected/focus/reduce styling controlled in SwiftUI.
- Do not import all 60 state variants unless later export QA proves masks/overlays are not viable.

Required Figma follow-up keywords for the broader, file-wide audit:

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
| Muscle/body selectors | Yes, verified | `8673:69673`, `9025:207456`, `9192:5535` | No Sandow primitive; STRQ has non-Sandow `MuscleFocusView` | Found / import strategy pending | Anatomy Muscle and Body Type component sets verified; large anatomy line-art groups verified but metadata labels are generic | High for Anatomy Muscle; medium for Body Type |

## Icon Coverage

### Figma Icon Set

The provided known icon set nodes are:

- Icon Set page: `5367:38988`
- Icons: `5454:22014`

The full Figma icon base count and style/variant count were not enumerated in this correction pass. Public product/listing sources indicate Sandow includes a large custom icon set, with listings describing 765+ to 1,000+ icons across versions and v3 "revamped UI icons". Exact v3 base icons and style variants must be verified directly in Figma.

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

Full screen group enumeration was not part of this correction pass. Public Sandow materials and known nodes indicate the following screen/pattern coverage should exist or be searched for:

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
- Muscle/body selector components exist in Figma, but no import/component strategy has been chosen yet.

Icons:

- Full Sandow icon set inventory.
- Icon category map.
- Base icon count and style count.
- Missing core UI/action/fitness/health/chat/settings icons listed above.

Screens:

- Full page and screen group inventory.
- Exact node IDs for onboarding, paywall, profile, settings, coach, nutrition, sleep, workout, exercise detail, watch/device, support/chat, feedback/rating.

Body/anatomy:

- Reusable Sandow body/anatomy/muscle assets were verified in Figma.
- Remaining work is import strategy, export feasibility, and deciding which variants should become base assets versus SwiftUI state styling.

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

1. Pass 1 - Anatomy Muscle verification and import strategy.
   - Use `SandowAnatomyImportPlan.md` as the source of truth for the next anatomy pass.
   - Export sample Anatomy Muscle SVGs/PDFs for one male and one female area in both states, then verify vector-only output before adding assets.
   - Prefer base anatomy line art plus per-area masks/overlays with SwiftUI state styling.
   - Do not import every selected/unselected/gender variant blindly.

2. Pass 2 - Secondary reusable assets.
   - Body Type assets.
   - Fitness equipment images.
   - Achievement badges.
   - Illustration base assets.

3. Pass 3 - Organ anatomy only if product scope needs it.
   - Import Organ Anatomy assets only if STRQ actually uses health/recovery educational screens.

4. Figma full inventory pass.
   - Enumerate all pages, top-level sections, component sets, variables, styles, screen groups, asset/media groups, and keyword matches.
   - Save exact page/node inventory back into this manifest.

5. Icon base-template import pass.
   - Import missing core action, settings, training, analytics, coach, nutrition, and health icons as template SVGs.
   - Keep one base icon per concept unless truly multicolor.

6. Foundation parity pass.
   - Compare exact Figma variables/styles against `SandowColors`, `SandowGradients`, `SandowTypography`, `SandowEffects`, `SandowSpacing`, and `SandowRadii`.
   - Add missing tokens without changing runtime screens.

7. General/app primitive parity pass.
   - Button, chip, badge, card, progress, tabs, inputs, search, modal, sheet, toggles, sliders, navigation, tab bar, list item, schedule, metric cards, chart cards, workout/exercise cards.

8. Screen migration planning pass.
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
