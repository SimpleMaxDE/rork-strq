# STRQ Figma Source Map

Last updated: 2026-04-30

## Purpose

This document maps the Purchased Figma UI Kit file to future STRQ-owned runtime targets. It records what was actually inspected in Figma during this pass, what was discovered adjacent to known nodes, and what remains pending.

Figma source:

- File: `SH-sandow-UI-Kit--v3.0-`
- URL: `https://www.figma.com/design/LBvxljax0ixoTvbvvUeWVC/SH-sandow-UI-Kit--v3.0-?m=auto&t=Cm2KJRPJnU51BdTq-6`
- File key: `LBvxljax0ixoTvbvvUeWVC`

Related control docs:

- [Docs README](README.md)
- [STRQ UI Migration Master Plan](strq-ui-migration-master-plan.md)
- [Design System Import Plan](design-system-import-plan.md)
- [Asset Import Plan](asset-import-plan.md)
- [Component Migration Plan](component-migration-plan.md)
- [UI Direction Options](ui-direction-options.md)

## Inspection Method

Figma was inspected with bounded Plugin API calls:

- Page/top-level inventory across the file.
- Exact node inspection for known foundation, component, screen, and asset anchors.
- Local variable and style inventory.
- Component-set inventory for General Components, App Components, and Foundations.
- Bounded keyword sweeps with max depth and per-keyword result limits.
- Targeted search for pricing/paywall/subscription/settings/error after a broad keyword pass timed out.

No production code was generated from Figma. No assets were imported. No full unbounded metadata scan was completed.

## Figma Access Result

| Area | Result |
|---|---|
| File access | Successful |
| Page inventory | Successful |
| Known node access | Successful for requested anchors sampled in this pass after read-only property guard fixes |
| Variable/style inventory | Successful: 1,082 variables, 184 paint styles, 73 text styles, 25 effect styles, 3 grid styles |
| Component-set inventory | Successful for General Components, App Components, and Foundations |
| Keyword discovery | Successful in shallow/bounded form, but some large pages hit deliberate node caps |
| `search_design_system` for `paywall subscription pricing plan card` | Returned no library components |
| `search_design_system` for `Pricing Card` | Returned Pricing Card and related pricing/card components |
| Timeout/error | One broad keyword sweep timed out at 120s; two earlier read-only scripts failed on page-node property guards and made no changes |

Large pages intentionally capped during keyword sweeps:

- `Main - Light Mode`
- `Main - Dark Mode`
- `Design System - General Components`
- `Design System - App Components`
- `Design System - Foundations`

Those pages should be inspected by exact node/frame in later passes, not via broad scans.

## Variable And Style Inventory

| Area | Current pass result |
|---|---|
| Local variables | 1,082 total |
| Variable types | 608 color, 444 float, 30 string |
| Variable collections | `Semantics`, `Primitives` |
| Semantic modes | `Light`, `Dark` |
| Primitive modes | `Light` |
| Paint styles | 184 |
| Text styles | 73 |
| Effect styles | 25 |
| Grid styles | 3 |

Sample text styles include `Display lg/Medium`, `Display lg/SemiBold`, `Display lg/Bold`, heading families, text families, paragraph families, and label families.

Sample effect styles include focus rings, shadows from `xs` through `2xl`, and background/layer blur levels.

Grid styles include `Desktop Grid`, `Tablet Grid`, and `Mobile Grid`.

## Page Inventory

| Page name | Page ID | Top-level contents | STRQ relevance |
|---|---:|---|---|
| `sandow UI Kit` | `5358:4029` | Placeholder | Low |
| `Main - Light Mode` | `8839:195620` | 18 mobile screen groups | Source for light-mode patterns, onboarding, profile, workout, nutrition, activity, sleep, community |
| `Main - Dark Mode` | `11602:73423` | 18 mobile screen groups | High relevance for STRQ dark-mode direction |
| `Design System - General Components` | `5358:4030` | 28 component sections | High reusable component source |
| `Design System - App Components` | `5643:11300` | 15 app-specific component sections | High mobile app component source |
| `Design System - Foundations` | `5358:6096` | 9 foundation sections | High token/foundation source |
| `Design System - Icon Set` | `5367:38988` | Icon container, featured icon, icon library | High icon source |
| `Bonus - Dashboard` | `5643:11291` | 7 dashboard frames | Medium source for analytics/admin/card density patterns |
| `Bonus - Mobile Patterns` | `5367:35452` | 19 mobile pattern frames | Medium source for secondary mobile flows |
| `---` | `8486:2909` | Empty divider page | None |
| `Thumbnail` | `5428:17729` | File thumbnail | None |

## Main Screen Groups

The light and dark main pages share a similar top-level screen taxonomy:

| Group | Light node | Dark node | STRQ relevance |
|---|---:|---:|---|
| Splash & Loading | `11579:58588` | `11602:73424` | Loader/splash patterns only |
| Welcome Screen | `11579:58703` | `11603:111144` | Onboarding/welcome reference |
| Authentication | `11579:58773` | `11603:112253` | Account flows if STRQ expands auth |
| Comprehensive Fitness Assessment | `11579:59846` | `11603:112700` | Onboarding assessment patterns |
| Profile Setup & Account Completion | `11579:65445` | `11604:59713` | Profile/onboarding setup |
| Home & Smart Fitness Metrics | `11580:93652` | dark nested `11604:62728` under `22406:57497` | Dashboard/today metrics source |
| AI Fitness Coach | `11581:101616` | `11605:86057` | Coach/chat/insight patterns |
| Nutrition & Meal Management | `11581:102945` | `11607:100771` | Nutrition/meal card patterns |
| Personalized Workout Library | `11582:103188` | `11608:96542` | Exercise/workout library patterns |
| Coaching Session & Appointment | `11584:57433` | `11609:117371` | Scheduling/coach appointment patterns |
| Activity Tracker | `11586:78369` | `11611:134946` | Activity/metrics/progress patterns |
| Sleep Monitoring | `11589:57806` | `11611:141689` | Sleep/recovery patterns |
| Notification & Search | `11589:57946` | `11611:145261` | Search/notification patterns |
| Error & Utility | `11589:58128` | `11612:154006` | Empty/error/loading utility flows |
| Fitness Resources | `11589:63330` | `11612:154441` | Low unless STRQ adds content |
| Fitness Community | `11589:67412` | `11612:161938` | Low/medium if social features expand |
| Profile Settings & Help Center | `11589:83741` | `11613:167073` | Profile/settings/support patterns |
| Achievements & Leaderboard | `11590:76623` | `11613:176012`; exact group `11613:176014` | Achievement and leaderboard patterns |

## Foundation Source Map

| Source | Node ID | Type | STRQ relevance | Priority | Notes |
|---|---:|---|---|---|---|
| Foundations page | `5358:6096` | page | Token source | High | Contains colors, gradients, typography, logo, effects, grid, spacing, media, illustration |
| Colors | `5359:9002` | foundation | `STRQColors`, semantic surfaces | High | Exact variable taxonomy still needs dedicated token pass |
| Gradients | `5442:13546` | foundation | `STRQGradients`/effects | Medium | Use sparingly for action/progress/reward only |
| Typography | `9119:6481` | foundation | `STRQTypography` | High | Work Sans source; local font binaries absent in current repo |
| Logo | `9120:37139` | foundation/brand | Reference only | Low | STRQ identity should not adopt Sandow logo |
| Effects | `9120:58753` | foundation | `STRQEffects` | High | Shadows, blur, focus/selected effects need exact parity pass |
| Grid | `9122:4683` | foundation | Layout spacing guidance | Medium | Useful for margins/grid decisions |
| Size & Spacing | `9122:6944` | foundation | `STRQSpacing`, dimensions | High | Needs exact mobile dimensions pass |
| Media | `9125:50816` | asset/system | Avatar/media/gallery/equipment | Medium | Import only approved categories |
| Illustration | `9125:148813` | asset/system | Anatomy/body/badge/illustration source | High | Key source for STRQ anatomy/reward assets |

## General Components Source Map

Top-level General Components page `5358:4030` contains 28 sections:

| Component section | Node ID | STRQ target | Priority |
|---|---:|---|---|
| Accordion | `9126:59236` | Optional disclosure pattern | Low |
| Badge & Chip | `9126:59240` | `STRQBadge`, `STRQChip` | High |
| Button | `9128:103928` | `STRQButton`, `STRQIconButton` | High |
| Button Group | `9207:120520` | Segmented actions | Medium |
| Breadcrumb | `9128:160037` | Not primary for iOS | Low |
| Carousel | `9128:160401` | Onboarding/resource modules | Low/Medium |
| Counter | `9128:160876` | Numeric controls | Medium |
| Chat | `9128:164508` | Coach/chat surfaces | Medium/High |
| Chart | `9129:26029` | `STRQChartCard` | High |
| Date Picker | `9129:41888` | Schedule/date controls | Medium |
| Divider | `9129:56696` | `STRQDivider`/list separators | Low |
| Dropdown | `9129:67870` | Filters/selectors | Medium |
| Feedback | `9129:146840` | Feedback/rating prompts | Low/Medium |
| File Upload | `9129:147561` | Not current STRQ need | Low |
| Form Control | `9129:175150` | Toggles/check/radio | High |
| Input | `9129:190574` | `STRQInputField` | High |
| Loader | `9129:191044` | `STRQLoader` | Medium |
| Modal | `9129:50010` | `STRQModal` | Medium/High |
| Notification | `9126:59232` | Notification rows/toasts | Medium |
| Pagination | `9129:193740` | Not primary for iOS | Low |
| Progress | `9129:207997` | `STRQProgressBar`, `STRQProgressRing` | High |
| Scroll Bar | `9131:34597` | Not primary for iOS | Low |
| Slider | `9131:38247` | Settings/numeric preferences | Medium |
| Step | `9131:45359` | Onboarding/progress steps | Medium |
| Table | `9131:53575` | Not primary for app UI | Low |
| Tab | `9131:172586` | Segmented tabs | High |
| Tooltip & Popover | `9131:180714` | Help/info | Low/Medium |
| Miscellaneous | `9131:226849` | Inspect only when needed | Low |

Button `9128:103928` was verified as a large component source with hierarchy, size, state, and tone variants including primary/secondary/tertiary, selected/default/disabled/focus/hover, brand/destructive/accent/gray.

## App Components Source Map

Top-level App Components page `5643:11300` contains:

| Component section | Node ID | STRQ target | Priority |
|---|---:|---|---|
| App Bar | `9131:289488` | `STRQNavigationBar` | High |
| Bottom Sheet | `9131:299492` | `STRQBottomSheet` | High |
| Card - App Specific | `9160:324200` | Workout/meal/metric/achievement cards | High |
| Card - General | `9131:326493` | `STRQCard` | High |
| FAB | `9131:301834` | `STRQFAB` if needed | Medium |
| List Item | `9134:89206` | `STRQListItem`, settings rows | High |
| Map Pin | `9131:326045` | Not current | Low |
| Navigation | `11614:57585` | Navigation patterns | High |
| Picker | `9131:280615` | Form/onboarding pickers | Medium |
| Schedule | `9132:170645` | `STRQScheduleRow/Card` | High |
| Section Header | `9131:291060` | Section header/action | Medium |
| Side Sheet | `9131:286894` | iPad or secondary sheet | Low/Medium |
| Social Media | `9131:284000` | Not current | Low |
| Tab Bar | `9131:291579` | Runtime tab bar foundation | High |
| Toolbar | `9131:290751` | Toolbars/actions | Medium |

Keyword discovery also found app component matches for Anatomy Organ, Anatomy Muscle, Leaderboard Card, Meal Search Result Card, Search, Empty, and Pricing Card.

## Icon Source Map

| Source | Node ID | Finding | STRQ relevance |
|---|---:|---|---|
| Icon Set page | `5367:38988` | Page contains Icon Container, Icon Featured, Icons | High |
| Icon Container | `9131:300866` | Component set with size variants | Medium |
| Icon Featured | `5546:2332` | Featured icon component source | Medium |
| Icons | `5454:22014` | Large icon frame; bounded scan saw hundreds of component sets with Light/Regular/Bold/Fill/Duotone/Duoline styles | High |

Current STRQ has 60 `STRQIcon*.imageset` assets and `STRQIcon` enum coverage documented in the [STRQ Icon Coverage Plan](../ios/STRQ/Utilities/STRQIconCoveragePlan.md). Future icon imports should stay one base template icon per concept unless multicolor artwork is truly required.

## Visual And Asset Source Map

| Source | Node ID | Type | Finding | STRQ relevance | Priority |
|---|---:|---|---|---|---|
| Home & Smart Fitness Metrics | `11604:62728` | screen pattern | Dark mobile screen with metric cards, workout card, sleep/support/chat snippets, tab bar | Dashboard module inspiration, not full-screen copy | High |
| Achievements & Leaderboard | `11613:176014` | screen pattern | 8 mobile frames, achievement cards, badges, leaderboard-style patterns | Reward/progress surfaces | Medium/High |
| Anatomy Muscle | `8673:69673` | component set | 60 variants: 2 genders x 15 body areas x selected/unselected; vector-only | Muscle focus/exercise detail/progress/onboarding | High |
| Body Type | `9025:207456` | component set | 12 variants: male/female, ectomorph/mesomorph/endomorph, default/selected | Optional onboarding/profile | Medium |
| Organ Anatomy | `9139:70026` | component set | Size wrapper sm through 2xl | Optional recovery/health education | Low |
| `_OrganAnatomyBase` | `8860:134805` | component set | 19 organ/body types including lung, brain, kidney, heart, stomach, liver, spine, knee, etc. | Optional only | Low |
| Large anatomy vector groups | `9192:5535` | frame/group | 4 generic groups, 225 vectors, likely large body line art | Possible full-body anatomy base | High pending QA |
| Fitness Equipment Image | `11536:90366` | media frame | 20 128x128 equipment image rectangles inside a media frame | Exercise library/onboarding equipment, pending licensing | Medium |
| Achievement Badge | `9064:106798` | component set | 6 size variants md/sm/lg/xl/2xl/3xl | Reward moments | Medium/High |
| `_AchievementBadgeBase` | `9063:203904` | component set | 60 variants across shape and tone | Badge shape/tone source | Medium/High |
| `_IllustrationBase` | `8912:62197` | component set | 32 256x256 illustration types | Empty/onboarding/reward illustration source | Medium |

## Pattern Discovery Results

Verified by page/top-level inventory or bounded keyword search:

| Pattern | Source evidence | STRQ use |
|---|---|---|
| Dark mode app screens | `Main - Dark Mode` page | Primary UI direction reference |
| Onboarding/welcome | Welcome Screen, Comprehensive Fitness Assessment, Profile Setup, Bonus Mobile Patterns Onboarding | Onboarding visual migration |
| Paywall/pricing | `Pricing Card` component `8751:102794`, pricing instances, text "Pick Your Right Plan" | Paywall cards without changing RevenueCat logic |
| Profile/settings/help | Profile Settings & Help Center light/dark groups | Profile/settings migration |
| Analytics/progress/chart | Chart `9129:26029`, Progress `9129:207997`, bonus dashboards | Progress and dashboard modules |
| Workout/exercise | Personalized Workout Library, workout cards, exercise imagery, app-specific cards | Training plan and exercise library |
| Sleep/recovery | Sleep Monitoring, activity/readiness patterns, progress charts | Sleep/readiness screens |
| Nutrition | Nutrition & Meal Management, Card Nutrition, Meal Search Result Card | Nutrition screens if retained |
| Coach/chat | AI Fitness Coach, Chat component, chat bubbles | Coach screens |
| Feedback | Feedback component, Bonus Mobile Patterns feedback | Optional post-session/support |
| Modal/bottom sheet/input/search/list/schedule | General and app components plus live instances | Foundation primitives |
| Empty/loading/error | Splash & Loading, Error & Utility, Loader, Empty components | `STRQStates` and utility states |

Not found by exact keyword:

| Keyword | Result | Interpretation |
|---|---|---|
| `paywall` | No named node found | Use pricing/plan card evidence instead |
| `subscription` | No named node found | Use pricing/plan card evidence instead |
| `settings` in capped broad search | Only text matches; top-level Profile Settings groups are verified separately | Inspect exact profile/settings frames later |
| `error` | No direct keyword result in bounded search | Error & Utility top-level groups are verified and need exact follow-up |

## Figma-To-Code Mapping Table

| Figma source | Node ID | Type | STRQ target file/folder | Import format | Status | Priority | Notes |
|---|---:|---|---|---|---|---|---|
| Colors | `5359:9002` | foundation | `ios/STRQ/Utilities/STRQDesignSystem.swift` future `STRQColors` | Swift tokens | Partial | High | Exact variable/mode parity pending |
| Typography | `9119:6481` | foundation | `STRQTypography`, `STRQFontRegistrar` | Swift tokens plus font files later | Partial | High | Work Sans binaries absent |
| Size & Spacing | `9122:6944` | foundation | `STRQSpacing`, `STRQRadii` | Swift tokens | Partial | High | Exact grid/spacing pass pending |
| Effects | `9120:58753` | foundation | `STRQEffects` | Swift tokens | Partial | High | Shadow/blur/focus parity pending |
| Icon Set | `5454:22014` | icon | `Assets.xcassets/STRQIcon*.imageset`, `STRQIcon`, `STRQIconView` | SVG/PDF template vectors | Partial | High | Current 60 icons synced; import only needed gaps |
| Button | `9128:103928` | component | `STRQButton`, `STRQIconButton` | SwiftUI component | Partial | High | Current isolated primitive exists; not production-wide |
| Badge & Chip | `9126:59240` | component | `STRQBadge`, `STRQChip` | SwiftUI component | Partial | High | Useful first production primitive |
| Progress | `9129:207997` | component | `STRQProgressBar`, `STRQProgressRing` | SwiftUI component | Partial | High | Needed by analytics/dashboard |
| Chart | `9129:26029` | component | future `STRQChartCard` | SwiftUI/Charts if used | Missing | High | Do not hand-roll chart logic without a pass |
| Tab / Tab Bar | `9131:172586`, `9131:291579` | component | `STRQTabBar`, segmented tabs | SwiftUI component | Partial | High | Production `ContentView` tab bar not migrated |
| Navigation/App Bar | `11614:57585`, `9131:289488` | component | `STRQNavigationBar` | SwiftUI component | Partial | High | Exact runtime navigation behavior protected |
| List Item | `9134:89206` | component | `STRQListItem`, `STRQSettingsRow` | SwiftUI component | Partial | High | Good first migration candidate |
| Schedule | `9132:170645` | component | `STRQScheduleRow/Card` | SwiftUI component | Partial | High | Useful for Train/Dashboard |
| Card - General | `9131:326493` | component | `STRQCard`, `STRQSurface` | SwiftUI component | Partial | High | Replace Forge surfaces only after proof |
| Card - App Specific | `9160:324200` | component | `STRQMetricCard`, `STRQWorkoutCard`, `STRQExerciseCard`, `STRQAchievementCard` | SwiftUI component | Missing/partial | High | Needs subcomponent breakdown |
| Bottom Sheet | `9131:299492` | component | `STRQBottomSheet` | SwiftUI component | Partial | Medium/High | Preserve sheet behavior |
| Modal | `9129:50010` | component | `STRQModal` | SwiftUI component | Partial | Medium | Useful for confirmations |
| Input/Form Control/Search | `9129:190574`, `9129:175150`, `8631:71039` | component | `STRQInputField`, `STRQSearchField`, `STRQToggleRow` | SwiftUI component | Partial | High | Needed before onboarding/library/settings |
| Home dark dashboard pattern | `11604:62728` | screen pattern | Future Dashboard modules | No direct import | Reference only | High | Do not copy full screen |
| Achievement patterns | `11613:176014` | screen pattern | Future progress/reward modules | No direct import | Reference only | Medium/High | Use cards/badges selectively |
| Anatomy Muscle | `8673:69673` | asset/component | future `STRQAnatomy*` assets/components | SVG/PDF masks or composites | Pending | High | Prefer base + masks, not 60 state assets |
| Large anatomy vector groups | `9192:5535` | asset | `Assets.xcassets/STRQAnatomy*`, `STRQAnatomyView` | SVG/PDF vectors | Pending | High | Need export alignment QA |
| Body Type | `9025:207456` | asset/component | future onboarding/profile body type assets | SVG/PDF or SwiftUI state | Pending | Medium | Only if product decision approves |
| Achievement Badge | `9064:106798`, `9063:203904` | asset/component | future `STRQAchievementBadge/Card` | SwiftUI vectors or SVG/PDF | Pending | Medium/High | Import only real milestone assets |
| Fitness Equipment Image | `11536:90366` | media | future equipment assets if needed | PNG/WebP/PDF depending source | Pending | Medium | Licensing/export quality must be checked |
| Base Illustrations | `8912:62197` | asset/component | future empty/onboarding/reward assets | SVG/PDF/PNG by source | Pending | Medium | Import only tied to real screens |
| Pricing Card | `8751:102794` | component | future `STRQPaywallPlanCard` | SwiftUI component | Missing | Medium | Preserve RevenueCat logic |

## Pending Figma Inspection Queue

This queue is intentionally pending. It prevents docs from implying that all Figma inspection is complete.

| Item | Why pending | Suggested next bounded node/search |
|---|---|---|
| Exact color variable collections and modes | Current inspection verified sections, not full variable taxonomy | Use Figma variables API on `5359:9002`/local collections |
| Exact spacing/radius/effect token names | Needed before token parity | Dedicated pass for `9122:6944` and `9120:58753` |
| Profile Settings & Help Center details | Top-level groups verified, deep frames not mapped | Inspect `11589:83741` and `11613:167073` |
| Error & Utility details | Top-level groups verified, keyword search missed exact `error` nodes | Inspect `11589:58128` and `11612:154006` |
| Full pricing/paywall pattern source | Search found Pricing Card, no paywall/subscription named node | Inspect `8751:102794` and pricing instances |
| Chart component variants | Chart section verified but not enumerated | Inspect `9129:26029` |
| App-specific cards variants | Important for workout/exercise/achievement | Inspect `9160:324200` |
| Workout/exercise screen details | Top-level groups verified only | Inspect `11582:103188`, `11608:96542` |
| Coach/chat details | Top-level and Chat component verified | Inspect `9128:164508`, `11581:101616`, `11605:86057` |
| Anatomy export feasibility | Metadata confirms vectors but not export fit | Export sample only in a future approved asset pass |
