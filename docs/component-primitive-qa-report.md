# STRQ Component Primitive QA Report

Last updated: 2026-05-01

## Scope

This report records the Component Primitive QA Pass for the isolated STRQ design-system foundation and DEBUG Design System Lab.

This pass does not migrate production screens, redesign Dashboard, replace production `Image(systemName:)` usage, import assets, modify workout/training logic, modify app/business logic, or change protected flows.

Runtime Swift remains STRQ-owned. Figma node IDs and source notes are recorded here as docs-only provenance.

## Environment And Git Gate

| Check | Result |
|---|---|
| Branch at start | `main` |
| Working tree at start | Clean |
| Unexpected pre-existing modified files | None |
| `rg` path | `C:\Users\maxwa\AppData\Local\OpenAI\Codex\bin\rg.exe` |
| `rg` version | `ripgrep 15.1.0 (rev af60c2de9d)` |
| Build status | Not run; `xcodebuild` is not expected on Windows |

## Figma Nodes Inspected

| Component group | Node ID | Inspection result |
|---|---:|---|
| Button | `9128:103928` | Inspected with 1,400-descendant cap; large node capped intentionally |
| Badge & Chip | `9126:59240` | Inspected with 1,400-descendant cap; large node capped intentionally |
| Progress | `9129:207997` | Inspected with 1,400-descendant cap; large node capped intentionally |
| Tab | `9131:172586` | Inspected with 900-descendant cap; large node capped intentionally |
| Navigation | `11614:57585` | Inspected fully in bounded read |
| Tab Bar | `9131:291579` | Inspected with 900-descendant cap; large node capped intentionally |
| List Item | `9134:89206` | Inspected with 900-descendant cap; large node capped intentionally |
| Schedule | `9132:170645` | Inspected fully in bounded read |
| Card - General | `9131:326493` | Inspected with 900-descendant cap; large node capped intentionally |
| Card - App Specific | `9160:324200` | Inspected with 900-descendant cap; large node capped intentionally |

No broad full-file Figma scan was attempted.

## Figma Component-State Comparison

| Group | Figma variants / sizes / states | STRQ needs now | Deferred |
|---|---|---|---|
| Button | Button supports leading/trailing icon booleans, text, hierarchy Primary/Secondary/Tertiary/Outlined/Link, sizes xs-sm-md-lg-xl, states Default/Hover/Selected/Focus/Disabled, tones Gray/Brand/Destructive/Accent. Button Icon adds xs-sm-md-lg-xl-2xl. Swipe button has Default/Loading/Swiped. | Primary, secondary, ghost, destructive, compact, icon-only, disabled, optional leading/trailing icons, simple loading placeholder, neutral monochrome default. | Web hover/focus parity, brand/accent as defaults, social/store buttons, swipe behavior, all five sizes. |
| Badge & Chip | Chip supports leading/trailing icon, hierarchy Primary/Secondary/Tertiary/Outlined, sizes xs-sm-md-lg-xl, states Default/Hover/Selected/Disabled, tones Brand/Gray/Destructive/Accent. Badge supports digit/text, dot/icon booleans, sizes sm-md-lg-xl, states Default/Hover/Disabled, tones Brand/Gray/Destructive/Warning/Success/Accent. | Neutral, selected, success, warning, danger, disabled chips, compact chip, status/count/achievement badges, semantic tones. | Full hierarchy matrix, dot badges, hover state, all badge sizes, brand/accent tone parity. |
| Progress | Linear progress supports values 0-100, sizes sm-md-lg, labels None/Bottom/Top/Inline. Circular progress supports sweep 50/75/100, sizes xs-sm-md-lg-xl-2xl, linear/step, text/icon content. | Neutral, success, warning, danger bars and rings, compact variants, optional label/value. | Exact 10% component variants, step rings, icon-content circular progress, every source size. |
| Tab | Tabs support orientation vertical/horizontal, size xs-sm-md-lg, styles Default/Border Bottom/Border Left/Button, flow horizontal/vertical. Items support leading/trailing icons, badge, text, Default/Hover/Active/Disabled. | Keep tab primitives isolated; tab bar item selected behavior is enough for now. | Segmented tab primitive, vertical tabs, badge/tab item variants, hover/focus. |
| Navigation | Fixed side navigation supports left/right position and Default/Inverse/Brand tones. | STRQ iPhone app needs top navigation bar with title, subtitle, leading, trailing actions. | Side navigation is not relevant for current iPhone production migration. |
| Tab Bar | Tab Bar supports Default/With FAB, Docked/Floating, indicators Default/Fill/Line/Notch/Dot. Items support Default/Hover/Active/Focus and icon/text/dot. | Docked/floating shell, selected neutral item, center action, background modifier, all isolated only. | Notch/dot/line indicator parity, production routing integration. |
| List Item | List Item supports Default/Fill/Fill Selected, slots None/Leading/Trailing/Leading + Trailing, text Leading/Leading + Trailing, 1/2/3 lines. Slot types include icon, avatar, badge, rating, toggle, radio, checkbox, circular progress, date badge, anatomy, and more. | Leading icon/avatar, title/subtitle, trailing value/icon/chevron, divider, selected, disabled, compact. | Full slot taxonomy, 3-line complex rows, payment/logo/media/anatomy slots. |
| Schedule | Schedule supports Empty/Event/Event Swiped. Schedule item supports leading/trailing slots, metadata, actions, strip indicator, title/supporting/prefix labels, Default/Fill style. | Date/time tile, title/subtitle, duration/status, selected/completed, compact. | Swiped actions, empty schedule primitive, strip indicators, multi-action rows. |
| Card - General | Includes article, video, simple, choice, metric, category, profile, CTA, cart, hero, image, review, pricing, row, course, notification, product, metadata sets. Simple and choice cards include selected/disabled states. | STRQCard standard/elevated/selected/compact/hero, STRQSurface, metric card with icon/value/unit/label/delta/progress. | Media-heavy cards, pricing/paywall cards, notification/product/course cards, exact Figma media layouts. |
| Card - App Specific | Includes appointment, activity, nutrition, health metric, challenge badge, workout, workout progress, coach, meal cards, light/dark modes, in-progress/completed states. | Use as inspiration only for STRQMetricCard, schedule shells, and future workout/card wrappers. | Dedicated workout, coach, nutrition, paywall, meal, appointment, and health-metric wrappers. |

## Component Coverage Table

| Component | Current Swift type | Figma source node/group | Current status | Variants supported | Missing variants | STRQ priority | Action taken in this pass | Remaining action |
|---|---|---|---|---|---|---|---|---|
| STRQSurface | `STRQSurface<Content>` | Card - General `9131:326493` | complete | base/elevated/card/inset/selected, subtle/selected/danger borders, custom radius/padding | explicit disabled surface | High | Shown directly in DEBUG lab | Keep as primitive shell |
| STRQCard | `STRQCard<Content>` | Card - General `9131:326493` | complete | standard/elevated/selected/compact/hero | media card wrappers | High | DEBUG lab now shows all variants | Build dedicated wrappers only per screen |
| STRQButton | `STRQButton` | Button `9128:103928` | complete | primary/secondary/ghost/destructive/compact/icon-only, disabled, leading/trailing icon, loading placeholder | focus/hover, selected, all source sizes | High | Added trailing icon, icon-only sizing, loading placeholder, cleaner accessibility | Ready for micro-migration after macOS build |
| STRQIconButton | `STRQIconButton` | Button Icon `9128:103928` | complete | regular/compact, primary/neutral/selected/ghost/destructive, disabled | focus/hover, all source sizes | High | Added compact and selected state APIs | Ready for low-risk rows/actions |
| STRQChip | `STRQChip` | Badge & Chip `9126:59240` | complete | neutral/selected/success/warning/danger/disabled, compact/regular/large, leading/trailing icons | hierarchy matrix, hover | High | Added trailing icon and explicit disabled flag | Ready for filter/status micro-migration |
| STRQBadge | `STRQBadge` | Badge & Chip `9126:59240` | complete | small/status/count/achievement, semantic tones | dot badge, all source sizes | High | Added accessibility label and lab coverage | Ready for status/count usage |
| STRQMetricCard | `STRQMetricCard` | Metric Card `9131:326493`, Health Metric Card `9160:324200` | complete | icon/value/unit/label/detail/delta/progress, selected/active, compact/standard | dedicated health metric row/col variants | High | Added delta and compact variant | Ready for small metric-card micro-migration |
| STRQProgressBar | `STRQProgressBar` | Progress `9129:207997` | complete | neutral/success/warning/danger, label/value, compact, custom tint | source label placement variants, step states | High | Added semantic tone API and accessibility label | Ready for metric/progress usage |
| STRQProgressRing | `STRQProgressRing` | Progress `9129:207997` | complete | compact/score/activity, semantic tones, label/value | step rings, all source sizes | High | Added semantic tone API and accessibility label | Ready for score/progress display |
| STRQListItem | `STRQListItem` | List Item `9134:89206` | complete | leading icon/avatar, title/subtitle, trailing value/icon/chevron, divider, selected, disabled, compact | full slot taxonomy, 3-line dense rows | High | Added trailing icon, selected, disabled, compact | First recommended production micro-migration candidate |
| STRQSectionHeader | `STRQSectionHeader<Trailing>` | Card/List patterns | complete | title, optional trailing content | subtitle variant | Medium | DEBUG lab now shows header/action | Use with list/card modules |
| STRQTabBarContainer | `STRQTabBarContainer<Content>` | Tab Bar `9131:291579` | partial | docked/floating-like glass shell | configuration API, indicators | Medium | DEBUG lab coverage retained | Keep isolated until navigation pass |
| STRQTabBarItem | `STRQTabBarItem` | Tab Bar `9131:291579` | partial | icon/text selected/unselected | focus/dot/line/notch indicators | Medium | DEBUG lab coverage retained | Do not production-migrate routing yet |
| STRQTabBarBackground | `STRQTabBarBackground` | Tab Bar `9131:291579` | partial | background modifier with divider/shadow | floating/docked config | Low | DEBUG lab now shows modifier | Keep isolated |
| STRQScheduleRow | `STRQScheduleRow` | Schedule `9132:170645` | complete | date tile, title/subtitle, duration/status, selected/completed, compact | empty/swiped/action rows | Medium | Added status, completed, compact | Ready for future schedule micro-module |
| STRQScheduleCard | `STRQScheduleCard` | Schedule `9132:170645` | complete | title/subtitle, row list | empty state | Medium | DEBUG lab now shows selected/completed rows inside card | Use after list-row migration |
| STRQSearchField | `STRQSearchField` | Input/Search patterns | partial | binding, placeholder, clear, disabled, error | focus state, leading slot customization | Medium | Added disabled/error state | Keep DEBUG-only until target module |
| STRQInputField | `STRQInputField` | Input patterns | partial | title, binding, placeholder, icon, helper, secure, disabled, error | textarea, OTP, validation callbacks | Medium | Added disabled/error state | Keep DEBUG-only until form pass |
| STRQToggleRow | `STRQToggleRow` | Form/List Item `9134:89206` | complete | title/subtitle, icon, binding, disabled, compact | left/right alignment variants | Medium | Added disabled and compact | Ready after settings-row target approval |
| STRQModalSurface | `STRQModalSurface<Content>` | Modal component | complete | title, elevated surface, content slot | presentation logic | Low | DEBUG lab coverage retained | Surface only; no production presentation changes |
| STRQBottomSheetSurface | `STRQBottomSheetSurface<Content>` | Bottom Sheet component | complete | handle, title, glass surface, content slot | presentation logic, detents | Low | DEBUG lab coverage retained | Surface only; no production presentation changes |
| STRQNavigationBar | `STRQNavigationBar<Leading, Trailing>` | Navigation `11614:57585` | complete for STRQ | title/subtitle, leading, trailing actions | side navigation parity | Medium | DEBUG lab coverage retained | Use only in approved screen pass |
| STRQAvatar | `STRQAvatar` | List/Card avatar slots | complete | initials, image name, icon placeholder, sm/md/lg/xl | avatar group | Medium | Added icon placeholder and xl size | Ready for list/card usage |
| STRQRatingStars | `STRQRatingStars` | List Item rating slot | partial | display-only rating, max count, custom size/tints | half-star visual | Low | DEBUG lab coverage retained | Keep display-only |
| STRQEmptyStateCard | `STRQEmptyStateCard` | Empty/error utility patterns | complete | icon/title/body/action | loading/error variants | Medium | Added action icon option and lab coverage | Ready for empty-state micro use |
| STRQIconContainer | `STRQIconContainer` | List/Card icon slots | complete | sm/md/lg/xl, tint/background | selected/disabled convenience API | High | DEBUG lab coverage retained through icon samples | Use inside primitives |

## Component Visual QA Table

| Component | DEBUG lab visible | Monochrome STRQ style | Accessibility/readability risk | Spacing/radius risk | Compile-risk | Notes |
|---|---|---|---|---|---|---|
| STRQSurface | yes | yes | low | low | low | Inset shell shown without source identity |
| STRQCard | yes | yes | low | low | low | Standard/elevated/selected/compact/hero shown |
| STRQButton | yes | yes | low | low | medium | New API is source-compatible with existing debug usage; build pending on macOS |
| STRQIconButton | yes | yes | low | low | medium | Custom initializer replaces memberwise init; current call sites updated |
| STRQChip | yes | yes | low | low | low | Disabled can be explicit or tone-driven |
| STRQBadge | yes | yes | low | low | low | Count/status/achievement visible |
| STRQMetricCard | yes | yes | low | low | low | Delta badges use semantic color only where meaningful |
| STRQProgressBar | yes | yes | low | low | low | Neutral default preserved |
| STRQProgressRing | yes | yes | low | low | low | Score and compact rings visible |
| STRQListItem | yes | yes | low | low | low | Good first production primitive candidate |
| STRQSectionHeader | yes | yes | low | low | low | Header plus action shown |
| STRQTabBarContainer | yes | yes | medium | medium | low | Routing not migrated |
| STRQTabBarItem | yes | yes | medium | medium | low | Selected state is neutral high contrast |
| STRQTabBarBackground | yes | yes | low | low | low | Modifier visible as standalone debug sample |
| STRQScheduleRow | yes | yes | low | low | low | Selected/completed/compact shown |
| STRQScheduleCard | yes | yes | low | low | low | Uses schedule rows |
| STRQSearchField | yes | yes | medium | low | low | TextField behavior must be built on macOS before production use |
| STRQInputField | yes | yes | medium | low | low | Error/disabled shown; form validation remains outside primitive |
| STRQToggleRow | yes | yes | low | low | low | Binding-only primitive |
| STRQModalSurface | yes | yes | low | low | low | Surface only |
| STRQBottomSheetSurface | yes | yes | low | low | low | Surface only |
| STRQNavigationBar | yes | yes | low | low | low | Top bar is STRQ-relevant; side navigation deferred |
| STRQAvatar | yes | yes | low | low | low | Initials and icon placeholder visible |
| STRQRatingStars | yes | partial | low | low | low | Warning tint example is semantic/accented, not default |
| STRQEmptyStateCard | yes | yes | low | low | low | Action remains optional |
| STRQIconContainer | yes | yes | low | low | low | Used throughout lab and icon section |

## Recommended Component Migration Readiness

| Component | Ready for production micro-migration | First safe target screen/module | Risk level |
|---|---|---|---|
| STRQListItem | yes | Profile/settings row cluster or notification settings rows | low |
| STRQToggleRow | yes | Profile/settings or notification setting row, preserving existing bindings/actions | low |
| STRQChip | yes | Exercise Library filter chip cluster after filter behavior audit | medium |
| STRQBadge | yes | Profile/status labels or Dashboard small status badges after copy audit | low |
| STRQButton | yes | Non-critical Profile/settings action row after macOS build | medium |
| STRQIconButton | yes | Non-critical Profile/settings action affordance after macOS build | medium |
| STRQCard | yes | Profile/settings group container or one low-risk metric shell | medium |
| STRQSurface | yes | Internal wrapper for a settings/card micro-module | medium |
| STRQMetricCard | yes | One isolated Dashboard or Progress metric card only after logic-preserving adapter pass | medium |
| STRQProgressBar | yes | One display-only progress metric | medium |
| STRQProgressRing | yes | Display-only score/progress module | medium |
| STRQScheduleRow | no | Future training schedule row after plan/session behavior audit | medium |
| STRQScheduleCard | no | Future training schedule card after schedule behavior audit | medium |
| STRQSearchField | no | Exercise Library search shell after search behavior audit | medium |
| STRQInputField | no | Future onboarding/settings form pass | medium |
| STRQNavigationBar | no | Later top-bar visual pass | medium |
| STRQTabBarContainer | no | Navigation pass only, not first migration | high |
| STRQTabBarItem | no | Navigation pass only, not first migration | high |
| STRQTabBarBackground | no | Navigation pass only, not first migration | high |
| STRQSectionHeader | yes | Profile/settings group headers | low |
| STRQModalSurface | no | Future sheet/modal shell pass | medium |
| STRQBottomSheetSurface | no | Future sheet/modal shell pass | medium |
| STRQAvatar | yes | Profile/settings row avatar or debug-only surfaces | low |
| STRQRatingStars | no | Only if a display-only rating feature is scoped | low |
| STRQEmptyStateCard | yes | Low-risk empty-state module with existing action preserved | low |
| STRQIconContainer | yes | Internal primitive inside rows/cards | low |

## Inventory Notes

All requested primitives are present in `ios/STRQ/Utilities/STRQDesignSystem.swift`. None are missing.

Current partial components are partial by design because production migration has not started:

- `STRQTabBarContainer`, `STRQTabBarItem`, and `STRQTabBarBackground` remain isolated until a protected navigation pass.
- `STRQSearchField` and `STRQInputField` are visually ready in DEBUG but should not be production-used until target search/form behavior is audited.
- `STRQRatingStars` is intentionally display-only.
- Dedicated workout, coach, paywall, nutrition, anatomy, chart, and media cards remain out of scope.

## First Recommended Production Micro-Migration

First target: a small Profile/settings row cluster using `STRQListItem`, `STRQToggleRow`, `STRQSectionHeader`, `STRQBadge`, and `STRQIconContainer`.

Reason:

- It has lower domain risk than Dashboard, Active Workout, Paywall, Onboarding, Progress Analytics, or Exercise Library.
- It can prove row density, selected/disabled states, icon containers, toggles, and semantic badges without touching workout/training logic.
- It can preserve existing route/actions and keep the DEBUG lab route untouched.

Do not migrate `DashboardView`, `ContentView`, active workout, paywall, onboarding, watch/widget, analytics, RevenueCat, persistence, or training logic in the first production pass.

## Remaining Risks

- No `xcodebuild` or simulator screenshot validation was run on Windows.
- Work Sans files remain missing, so typography fidelity still uses fallback.
- Some Figma nodes were intentionally capped; deep inspection should continue per component family when a production target needs exact detail.
- Hover/focus/source-brand states are intentionally not copied into iOS runtime defaults.
- New Swift component APIs need macOS build validation before production adoption.

## Next Recommended Pass

1. Build and visually inspect the DEBUG Design System Lab in the iOS simulator on macOS.
2. Confirm the primitive states render correctly across the lab: buttons, icon buttons, chips, badges, cards, surfaces, metrics, progress, lists, schedule rows/cards, inputs, modal surfaces, avatars, ratings, empty state, and all 60 STRQ icons.
3. If build and visual QA are clean, run the first production micro-migration on a small Profile/settings row cluster using row, toggle, section header, badge, and icon-container primitives.
4. Keep workout/training logic, persistence, analytics, product IDs, localization, onboarding, navigation, active workout behavior, rest timer, watch/widget code, and data models out of scope.
