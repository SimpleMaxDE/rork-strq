# STRQ UI Technical Baseline Report

Last updated: 2026-05-02

## Scope

This is a read-only technical UI baseline for STRQ's next UI migration prompts. It records the current app shell, production screen structure, styling systems, STRQ design-system adoption, protected flows, visual risk areas, and recommended work packages.

No production Swift code, assets, localization catalogs, tests, view models, services, models, watch/widget targets, `ContentView.swift`, `STRQApp.swift`, or project files are changed by this report.

## Method

Inputs read:

- `docs/README.md`
- `docs/strq-ui-migration-master-plan.md`
- `docs/project-ui-audit.md`
- `docs/protected-logic-map.md`
- `docs/figma-source-map.md`
- `docs/design-system-import-plan.md`
- `docs/component-migration-plan.md`
- `docs/component-primitive-qa-report.md`
- `docs/figma-token-parity-report.md`
- `docs/asset-import-plan.md`
- `docs/qa-validation-plan.md`
- `docs/migration-progress-log.md`
- `ios/STRQ/Utilities/STRQDesignSystem.swift`
- `ios/STRQ/Utilities/STRQPalette.swift`
- `ios/STRQ/Utilities/ForgeTheme.swift`
- `ios/STRQ/ContentView.swift`

Targeted code searches inspected navigation, sheets, alerts, design-system usage, Forge usage, SF Symbols, RevenueCat, active workout, plan generation, progression, HealthKit, watch/widget, Sandow references, and orange/accent references.

This report infers visual risk from code structure only. It does not judge screenshots.

## Current App Navigation Structure

`ios/STRQ/ContentView.swift` owns the top-level runtime shell.

Root routing order:

| Root condition | Destination | Notes |
|---|---|---|
| Onboarding incomplete and phase is `.form` | `OnboardingView(vm:)` | User profile and setup input flow. |
| Onboarding incomplete and phase is `.generating` | `PlanGenerationView(profile:onComplete:)` | Calls `vm.finishPlanGeneration()`. |
| Onboarding incomplete and phase is `.reveal` | `PlanRevealView(plan:profile:planQuality:onStart:impacts:)` | Calls `vm.completeOnboarding()` and may prepare workout handoff. |
| Active workout visible, or completed workout handoff exists | `ActiveWorkoutView(vm:onClose:)` | Full-screen live workout or completion handoff path. |
| Pre-workout handoff visible | `PreWorkoutHandoffView(vm:day:onStart:onCancel:)` | Starts with `vm.confirmStartWorkout()` or cancels handoff. |
| Main app state | `TabView` with five `NavigationStack` tabs | System tab bar hidden; custom `STRQTabBar` in `ContentView.swift`. |

Main app tabs:

| Tab | Root screen | Key reachable flows |
|---|---|---|
| Today | `DashboardView` | Readiness check-in, weekly review, nutrition log, sleep log, body weight log, start/resume/prep workout, training week pulse, activation/comeback cards. |
| Coach | `CoachTabView` | Daily coach, readiness check-in, weekly review, more signals sheet, coaching history, plan/phase insights, start/resume workout, coach recommendations/actions through `ExpandableCoachCard`. |
| Train | `TrainingPlanView` | Plan overview, regenerate-plan dialog, exercise detail, exercise library, session editor, schedule editor, swap exercise, prescription sheet, review/start workout. |
| Progress | `ProgressAnalyticsView` | Progress dashboard, personal records, session history route through `ProgressRoute.history`, body weight, recovery, nutrition, muscle balance, weekly workouts, movement balance. |
| Profile | `ProfileView` | Account/sync/restore, subscription/paywall, nutrition settings, sleep log, media diagnostics, notification settings, coaching preferences, plan regeneration, DEBUG Design System Lab route, reset/sign-out. |

Additional root-level deep-link sheets:

- `ReadinessCheckInView` from notification route `.readinessCheckIn`.
- `SleepLogView` from notification route `.sleepLog`.
- `.resumeWorkout` route selects Today and either expands the active workout or prepares handoff.

Navigation baseline conclusion:

- The existing five-tab structure is materially aligned with the product: Today, Coach, Train, Progress, Profile.
- New tabs should not be proposed unless a future product decision proves a repeated high-value workflow cannot fit these roots.
- `ContentView.swift` and tab routing are protected. Do not visually migrate navigation or tab behavior in early passes.

## Major Production Screens

| Screen / area | File path | Purpose | Important user actions | Protected logic risk | Early visual migration candidate | Reason |
|---|---|---|---|---|---|---|
| Root shell and tab bar | `ios/STRQ/ContentView.swift` | Top-level routing, onboarding gates, active workout handoff, main tabs, notification deep links | Complete onboarding, start handoff, select tabs, handle notification routes | High | No | Owns protected routing and active workout/onboarding branching. Leave until a dedicated navigation pass. |
| Today dashboard | `ios/STRQ/Views/DashboardView.swift` | Daily coaching surface: readiness, workout status, activation/comeback, weekly pulse, logs | Readiness check-in, weekly review, nutrition/sleep/weight logs, start/resume workout, apply comeback lighter session | High | Partial only | Good visual value, but dense and behavior-coupled. Only migrate one display-only metric/card module after Profile proves primitives. |
| Coach tab | `ios/STRQ/Views/CoachTabView.swift` | Daily coach, plan signals, readiness, lift tracker, weekly review, coach memory/history | Check in, start/resume workout, generate weekly review, open more signals/history | High | Not early | Uses coach logic, analytics, actions, multiple sheets, many local cards. Better after card/list primitives and coach action guardrails. |
| Coach action cards | `ios/STRQ/Views/ExpandableCoachCard.swift` | Applies recommendations such as swaps, volume reduction, lighter session, regeneration, deload | Apply/undo volume changes, swaps, deloads, regenerated weeks | High | No | Directly mutates training plan and applied action state. Do not touch early. |
| Train plan | `ios/STRQ/Views/TrainingPlanView.swift` | Plan overview, selected day, session details, schedule control, start workout | Regenerate plan, open library/detail/editor/schedule/swap/prescription, remove/restore exercise, skip/move day, start | High | Not early | High action density and plan mutation. A later row/card pass may target display wrappers only. |
| Session editor | `ios/STRQ/Views/SessionEditorSheet.swift` | Edit a workout day: add, reorder, update prescription, swap, remove | Add exercise, reorder, edit sets/reps/load/rest, swap, restore default, remove | High | No | Mutates plan structure. Needs behavior audit before any visual shell work. |
| Schedule editor | `ios/STRQ/Views/ScheduleEditorSheet.swift` | Assign workout days to weekdays | Assign/unassign weekday, auto-schedule days | Medium/High | Later | Good eventual schedule-row target, but schedule semantics must stay exact. |
| Week regeneration/deload sheets | `ios/STRQ/Views/WeekPreviewSheet.swift` | Preview regenerated/deload week before applying | Apply regenerated week or deload week, cancel | High | No | Plan generation/progression-adjacent. Owner approval required. |
| Active workout | `ios/STRQ/Views/ActiveWorkoutView.swift` | Live workout logging, set table, rest timer, notes, exercise swaps, completion | Update load/reps, complete set, rest adjustments, quality, jump exercise/set, undo, note, save/leave, discard, complete workout | High | No | Highest-risk UI surface. Mutates live workout, persistence, rest, HealthKit export, watch/live activity indirectly. Last among core screens. |
| Pre-workout handoff | `ios/STRQ/Views/PreWorkoutHandoffView.swift` | Pre-start review of workout, briefing, exercise/prescription detail | Start workout, cancel, inspect prescription | High | Not early | Starts protected active workout flow. Visual work must wait until workout card primitives are stable. |
| Workout completion | `ios/STRQ/Views/WorkoutCompletionView.swift` | Completion summary, progress signals, next workout, rewards | Review completed session; close through active workout handoff path | Medium/High | Partial later | Good reward/summary visual value, but tied to workout history and completion state. Candidate only for contained display module. |
| Progress analytics | `ios/STRQ/Views/ProgressAnalyticsView.swift` | Metrics, PRs, session history entry, body/recovery/nutrition trends, balance charts | Open session history; scan analytics modules | Medium/High | Yes, after Profile | Mostly display logic, but calculation and history contracts are important. Good for metric/card/chart shell migration after one Dashboard metric. |
| Session history | `ios/STRQ/Views/SessionHistoryView.swift` | Historical workout list and detail | Open completed session detail | Medium | Later | Useful row/card target after Progress shell rules exist. Preserve history data. |
| Profile/settings | `ios/STRQ/Views/ProfileView.swift` | Profile, account, sync, subscription entry, coaching prefs, settings, debug, danger zone | Sign in/out, restore cloud, manage subscription, open paywall, restore purchases, toggle nutrition tracking, open settings, regenerate plan, reset data | Medium | Yes | Best early candidate if limited to one low-risk row cluster. Current controls-section micro-migration is already present. |
| Paywall/subscription | `ios/STRQ/Views/STRQPaywallView.swift` | RevenueCat package display, purchase, restore, pro-state fallback/error views | Select package, purchase, restore, retry offerings | High | No | Revenue-sensitive. Needs owner-approved paywall visual scope and exact RevenueCat preservation. |
| Onboarding form | `ios/STRQ/Views/OnboardingView.swift` | Captures profile, metrics, goals, schedule, equipment, muscles, recovery | Edit profile fields, select goals/equipment/focus, begin plan generation | High | No | State and plan-generation inputs are protected. Visual migration must be phased and approved. |
| Plan generation | `ios/STRQ/Views/PlanGenerationView.swift` | Loading/generation interstitial | Automatic transition via callback | High | Later | Low interaction but part of onboarding phase contract. Good only after onboarding visual direction is approved. |
| Plan reveal | `ios/STRQ/Views/PlanRevealView.swift` | Shows generated plan, plan quality, roadmap, first start | Start plan/onboarding completion | High | Later | High first-run value but completes onboarding and may prepare handoff. |
| Exercise library | `ios/STRQ/Views/ExerciseLibraryView.swift` | Browse/search/filter exercises, favorites, progression clusters | Search, filter, select detail, favorite/unfavorite | Medium/High | Yes, after filter audit | Strong card/search/chip opportunity. Preserve exercise identity, filters, favorites, and progression badges. |
| Exercise detail | `ios/STRQ/Views/ExerciseDetailView.swift` | Exercise metadata, prescription, progression, media, muscles, alternatives | Favorite, inspect alternatives, open alternative detail | Medium/High | Later | Good anatomy/media value, but many local sections and progression reads. Asset pass needed before anatomy changes. |
| Swap exercise | `ios/STRQ/Views/SwapExerciseSheet.swift` | Select replacement exercise with intent/context | Choose replacement option | High | No | Feeds plan/active workout mutation through callers. Visual row/card work must preserve selection semantics. |
| Exercise prescription | `ios/STRQ/Views/ExercisePrescriptionSheet.swift` | Explain prescription, guidance, progression note | Display-only, dismiss | Medium | Later | Safer than editors, but relies on prescription logic. Good after exercise detail pattern exists. |
| Readiness check-in | `ios/STRQ/Views/ReadinessCheckInView.swift` | Collect daily readiness, pain, sleep, soreness, stress signals | Submit readiness; expand details; pain choices | Medium/High | Later | Writes daily state and coach response. Visual form migration requires exact binding preservation. |
| Sleep log | `ios/STRQ/Views/SleepLogView.swift` | Log sleep and view recovery impact | Save sleep; expand training impact | Medium | Later | Useful input/card target after form primitives are production-proven. |
| Nutrition log | `ios/STRQ/Views/NutritionLogView.swift` | Log calories/protein/macros, show targets and history | Save nutrition log | Medium | Later | Form and persistence-adjacent. Not first. |
| Body weight log | `ios/STRQ/Views/BodyWeightLogView.swift` | Log body weight/body fat, physique trend and projections | Save body weight | Medium | Later | Health/body data and trend displays; preserve HealthKit side effects through `AppViewModel`. |
| Notification settings | `ios/STRQ/Views/NotificationSettingsView.swift` | Smart reminders, authorization, dates, HealthKit toggle | Request notification permission, change toggles/times/day, open Settings, enable HealthKit | Medium/High | Yes, after Profile | Good row/toggle target, but HealthKit and notification scheduling are protected. |
| Nutrition settings | `ios/STRQ/Views/NutritionSettingsView.swift` | Nutrition target setup, computed/custom targets, target weight | Recompute/save custom targets, save target weight | Medium | Later | Form inputs and profile/nutrition state. Needs form primitive pass. |
| Coaching preferences | `ios/STRQ/Views/CoachingPreferencesView.swift` | Coach tone, density, emphasis preferences | Select preference rows | Medium | Later | Good row/card target after Profile, but affects coach surface behavior. |
| Watch app | `ios/STRQWatch/*` | Watch workout companion | Watch set logging/actions | High | No | Separate target. Do not touch during main iOS migration. |
| Widgets/Live Activity | `ios/STRQWidget/*`, `ios/STRQShared/*` | Widget snapshots and Live Activity UI | Widget render, Live Activity state | High | No | Separate target and active workout synchronization surface. |

## Current Production Styling Systems Found

Production UI currently mixes several systems:

| System | Current role | Evidence |
|---|---|---|
| `STRQPalette` | Active production semantic/dark palette for backgrounds, surfaces, text, state colors, and score mappings | Used broadly across production views and `ContentView`. |
| `STRQBrand` | Graphite/obsidian/slate/steel/accent gradients and legacy card colors | Used broadly across production views. |
| `ForgeTheme` | Color mapping, recovery/sleep colors, volume formatting, and bridge to `STRQPalette`/`STRQBrand` | Used in Dashboard, Coach, Training, Profile, Progress, weight/nutrition sheets, and others. |
| `ForgeSurface` | Main production card/surface shell for Dashboard modules | Found repeatedly in `DashboardView`. |
| `ForgeCard` | Simpler older card shell | Defined in `ForgeTheme.swift`; less visible in current key screens than `ForgeSurface`. |
| `ForgeSectionHeader` | Older section header | Used in Profile, Progress, Coach, WeightQuickLog, and other views. |
| `ForgeChip` | Older chip | Used in Profile focus muscles. |
| `STRQMetricTile` | Current production metric tile | Used heavily in Dashboard and signal buttons. |
| `STRQBadgeChip` | Current production badge/chip helper | Used heavily in Dashboard and weekly pulse. |
| `STRQPrimaryCTA`, `ForgePrimaryButton`, `ForgeSecondaryButton` | Current production CTA systems, often using warm/orange accent gradients | Used in Dashboard, Coach, Training, Forge utilities. |
| Local helper rows/cards/chips | Per-screen visual language | Many screens define local `row`, `card`, `chip`, `section`, and `tile` helpers. |
| `Image(systemName:)` | Main production icon source | Heavy usage across all major views and custom tab bar. |
| `STRQDesignSystem` primitives | Future design-system foundation | Production adoption is minimal; broad use is DEBUG lab only. |

Representative risk counts from targeted inspection:

| File | Lines | `Image(systemName:)` refs | Local row/card/chip helpers | Sheet count | Alert/dialog count | `STRQPalette`/Forge/brand refs |
|---|---:|---:|---:|---:|---:|---:|
| `ActiveWorkoutView.swift` | 2187 | 24 | 13 | 5 | 2 | 45 |
| `ProgressAnalyticsView.swift` | 1441 | 16 | 5 | 0 | 0 | 86 |
| `ExerciseDetailView.swift` | 1040 | 27 | 10 | 1 | 0 | 56 |
| `DashboardView.swift` | 993 | 14 | 5 | 5 | 0 | 84 |
| `ExerciseLibraryView.swift` | 933 | 18 | 6 | 2 | 0 | 39 |
| `ExpandableCoachCard.swift` | 914 | 24 | 6 | 6 | 0 | 49 |
| `OnboardingView.swift` | 881 | 14 | 7 | 1 | 0 | 10 |
| `ProfileView.swift` | 865 | 18 | 9 | 4 | 5 | 48 |
| `SessionEditorSheet.swift` | 855 | 12 | 8 | 3 | 0 | 46 |
| `CoachTabView.swift` | 863 | 19 | 5 | 4 | 0 | 36 |
| `TrainingPlanView.swift` | 755 | 11 | 6 | 6 | 0 | 33 |
| `STRQPaywallView.swift` | 704 | 11 | 3 | 0 | 0 | 21 |
| `ReadinessCheckInView.swift` | 652 | 8 | 3 | 0 | 0 | 20 |
| `WeeklyCheckInView.swift` | 585 | 9 | 4 | 0 | 1 | 50 |

Interpretation:

- STRQ has a coherent carbon/graphite identity in tokens, but production views still implement much of their own visual structure.
- The highest visual risk is partial migration that adds a third style layer instead of replacing local helpers in one controlled module.
- SF Symbols are still expected at this stage and should be inventoried, not mass-replaced.

## Current STRQDesignSystem Adoption

The isolated `STRQDesignSystem.swift` foundation contains:

- `STRQColors`
- `STRQGradients`
- `STRQTypography`
- `STRQSpacing`
- `STRQRadii`
- `STRQEffects`
- `STRQIcon`
- `STRQIconView`
- `STRQIconContainer`
- `STRQSurface`
- `STRQCard`
- `STRQButton`
- `STRQIconButton`
- `STRQChip`
- `STRQBadge`
- `STRQMetricCard`
- `STRQProgressBar`
- `STRQProgressRing`
- `STRQProgressRow`
- `STRQListItem`
- `STRQSectionHeader`
- `STRQSearchField`
- `STRQInputField`
- `STRQToggleRow`
- `STRQModalSurface`
- `STRQBottomSheetSurface`
- `STRQNavigationBar`
- `STRQAvatar`
- `STRQRatingStars`
- `STRQEmptyStateCard`
- `STRQTabBarContainer`
- `STRQTabBarItem`
- `STRQTabBarBackground`
- `STRQScheduleRow`
- `STRQScheduleCard`

Production use found:

| File | Production adoption |
|---|---|
| `ios/STRQ/Views/ProfileView.swift` | `controlsSection` uses `STRQSectionHeader`, `STRQListItem`, `STRQIcon`, and `STRQColors` for the `Notifications & Tools` row cluster. |

DEBUG-only use found:

| File | DEBUG adoption |
|---|---|
| `ios/STRQ/Views/Debug/STRQDesignSystemPreviewView.swift` | Uses the full primitive set for token, typography, button, chip, badge, card, surface, metric, progress, list, schedule, icon, input, modal, sheet, avatar, rating, and tab bar samples. |
| `ios/STRQ/Utilities/STRQDesignSystem.swift` | Contains DEBUG previews `STRQFoundationPreview` and `STRQComponentsPreview`. |

Profile controls-section micro-migration status:

- Present.
- It is limited to `ProfileView.controlsSection`.
- It uses `STRQSectionHeader` and `STRQListItem` for Notifications, Restore Purchases, and Regenerate Plan rows.
- It preserves the DEBUG Design System Lab route, but that DEBUG row still uses the older local `controlRowContent` helper.
- It does not migrate the rest of Profile: sync/account/subscription/profile summary/training setup/body/nutrition/danger sections still use older local helpers, Forge, SF Symbols, and system grouped backgrounds.

Current adoption conclusion:

- `STRQDesignSystem` is ready as an isolated foundation and partially proven in DEBUG.
- Production adoption is only a micro-slice. Future prompts must not assume the app has already migrated to the new design system.

## Likely Visual Risk Areas

Inferred from code structure:

| Risk area | Why it is risky |
|---|---|
| Active Workout | Largest production view, many local helpers, many buttons, sheets, dialogs, live set mutations, rest timer overlay, and workout completion calls. |
| Exercise Detail | Many local section/card/row helpers, highest SF Symbol density among major display screens, progression and prescription reads, media/anatomy opportunity but no approved asset pass yet. |
| Dashboard | Heavy Forge/Palette usage, many CTAs, many sheets, workout start/resume actions, weekly pulse modules, activation/comeback actions. |
| Progress Analytics | Very high styling reference count, chart-like local layouts, many derived metrics, history navigation. |
| Expandable Coach Cards | Dense action flows, plan/regeneration/deload/swap mutation, high SF Symbol and style usage. |
| Session Editor | Many local helpers and plan mutation actions. |
| Profile | Mixed systems: current micro-migration plus older Forge/local controls, subscription/sync/reset/account risks. |
| Exercise Library | Search/filter/card/favorite flows, many local chips/cards, exercise identity and progression tags. |
| Onboarding | Many local controls and profile bindings; plan generation depends on captured state. |
| Paywall | Visually self-contained but revenue-sensitive; CTA and plan-card styling cannot be separated from purchase/restore semantics. |
| Notification Settings | Good row/toggle migration surface, but notification scheduling and HealthKit authorization are protected. |
| Watch/Widget/Live Activity | Separate targets and active workout synchronization surfaces; exclude from main app visual work. |

Screens with old Forge components:

- `DashboardView.swift`
- `CoachTabView.swift`
- `TrainingPlanView.swift`
- `ProfileView.swift`
- `ProgressAnalyticsView.swift`
- `WeightQuickLogSheet.swift`

Screens with many local helpers:

- `ActiveWorkoutView.swift`
- `ExerciseDetailView.swift`
- `ProfileView.swift`
- `SessionEditorSheet.swift`
- `OnboardingView.swift`
- `TrainingPlanView.swift`
- `ExerciseLibraryView.swift`
- `ExpandableCoachCard.swift`

Screens with heavy direct SF Symbol usage:

- `ExerciseDetailView.swift`
- `ActiveWorkoutView.swift`
- `ExpandableCoachCard.swift`
- `CoachTabView.swift`
- `ProfileView.swift`
- `ExerciseLibraryView.swift`
- `ProgressAnalyticsView.swift`
- `DashboardView.swift`
- `OnboardingView.swift`

## Protected Screens And Flows Not To Touch Early

Do not touch early:

| Area | Protected reason |
|---|---|
| Active Workout | Live data mutation, rest timer, undo, set cursor, completion, HealthKit export, watch/live activity sync, persistence. |
| Plan generation and regeneration | Core STRQ training intelligence; driven by `PlanGenerator`, profile inputs, `AppViewModel`, coach actions, and plan QA. |
| Progression and prescriptions | Core adaptive training product; affects load suggestions, plateau calls, next best actions, and coach logic. |
| Persistence and cloud restore/sync | User data protection; file schema, snapshots, app group, iCloud restore logic. |
| RevenueCat / Paywall | Product IDs, entitlement `pro`, package selection, restore, analytics, purchase states. |
| Onboarding state | Phase ordering and completion semantics feed plan creation and first workout handoff. |
| Watch / Widget / Live Activity | Separate runtime surfaces and synchronized active workout state. |
| HealthKit | Privacy/permission sensitive; body weight, sleep, workout export. |
| Notification scheduling and deep links | Reminder IDs, routes, user entry flows. |
| Localization catalogs | `Localizable.xcstrings` and watch/widget strings are not UI-migration scratch space. |
| Analytics event keys and timing | Existing events are product/data contracts. |
| Exercise identity/catalog/media provider | Exercise IDs and fallback media affect plans, history, swaps, and progression. |

## Migration Strategy That Reduces Codex Decision Power

Future prompts should be narrowly structured and should specify:

- Exact target file(s).
- Exact module or function names to migrate.
- Exact primitives allowed, for example `STRQListItem` and `STRQSectionHeader` only.
- Exact styling objective, such as "replace local row visuals with STRQ list rows while preserving labels, actions, navigation, analytics, and bindings."
- Explicit non-goals.
- Explicit protected calls that must remain unchanged.
- Whether copy changes are allowed. Default: no.
- Whether localization catalogs are allowed. Default: no.
- Whether assets are allowed. Default: no.
- Whether SF Symbols may be replaced. Default: no, unless an exact `STRQIcon` mapping is listed.
- Rork simulator screenshots required after the pass.

Each future implementation prompt must include:

1. Scope: one module, not a screen rewrite.
2. Files allowed to edit.
3. Files forbidden to edit.
4. Allowed design-system primitives.
5. Exact visual acceptance criteria.
6. State/actions/analytics/localization that must be preserved.
7. Screenshot checklist for Rork.
8. Verification commands, including `git diff --name-only -- ios/...` protected paths.

Codex must not decide:

- New tabs or root navigation changes.
- Orange as the default CTA identity.
- Full-screen Figma copying.
- New runtime Sandow/source names.
- New coach/person/demo images.
- Anatomy asset imports.
- New assets or fonts.
- Paywall package hierarchy/copy beyond approved visual scope.
- RevenueCat product/entitlement behavior.
- New localization strings/catalog edits.
- Analytics event renames or trigger timing.
- Training/plan/progression logic.
- Watch/widget/live activity visual changes during main iOS passes.

Owner approval is required for:

- Any change to navigation/root shell/tab bar.
- Any paywall visual or copy pass.
- Any onboarding visual or copy pass.
- Any Active Workout visual pass.
- Any asset import, especially anatomy, people, coach, badges, illustrations, equipment, or fonts.
- Any Work Sans bundling or typography runtime switch.
- Any copy/localization scope.
- Any new product surface, new tab, or new repeated feature area.
- Any use of orange as a prominent CTA/accent beyond rare intentional states.
- Any change touching watch/widget/live activity/HealthKit/RevenueCat/persistence/progression behavior.

Rork simulator screenshot use after each UI pass:

- Capture before and after when possible.
- Capture the changed screen at minimum on a small iPhone and a large iPhone.
- Include the exact state changed by the pass, plus adjacent entry/exit states.
- Inspect text clipping, overlap, tap targets, contrast, disabled/loading/empty/error states, and bottom safe-area behavior.
- Do not approve a visual pass from code diff alone.

## Ranked Next UI Work Packages

| Rank | Package | Target files | Visual objective | Product value | Risk | Dependencies | Must preserve | Rork simulator QA checklist | Owner approval before implementation |
|---:|---|---|---|---|---|---|---|---|---|
| 1 | Profile controls-section completion | `ios/STRQ/Views/ProfileView.swift` | Finish the existing `controlsSection` micro-migration so all rows in that cluster use STRQ-owned row/header/icon treatment, including DEBUG route if in DEBUG. | Proves production list-row pattern in a low-risk area. | Low/Medium | Current `STRQListItem`, `STRQSectionHeader`, `STRQIcon` adoption. | Notification navigation, restore purchases action, plan-regeneration dialog, DEBUG lab route. | Profile root; Notifications row opens settings; Restore Purchases shows expected state; Regenerate Plan dialog opens; DEBUG lab route still visible in debug; no text clipping. | No, if exact scope stays in current controls section and no copy/assets/actions change. |
| 2 | Profile non-danger settings rows | `ios/STRQ/Views/ProfileView.swift` | Migrate one additional Profile row group, preferably coaching preferences or nutrition/sleep tools, to `STRQListItem`/`STRQSectionHeader`. | Extends consistency without touching core training flow. | Medium | Package 1. | Navigation links, nutrition toggle behavior, coaching preferences route, paywall route untouched unless explicitly scoped. | Profile root; target rows tap correctly; subscription area still works; sign-in/sync/danger sections unchanged. | Yes if subscription/account/sync rows are included; otherwise no for one low-risk row group. |
| 3 | Notification settings row/toggle visual pass | `ios/STRQ/Views/NotificationSettingsView.swift` | Replace local `toggleRow`/section header visuals with `STRQToggleRow` and `STRQSectionHeader` while preserving bindings. | Settings polish and repeated row pattern proof. | Medium/High | Package 1; owner agrees HealthKit row is in or out. | `vm.rescheduleSmartReminders()`, notification permission request, DatePicker/Picker values, HealthKit authorization/sync behavior. | Permission banner states; each toggle; time pickers; weekly review day picker; HealthKit unavailable/available state; back navigation. | Yes, because HealthKit/notification scheduling are protected. |
| 4 | Dashboard single metric module | `ios/STRQ/Views/DashboardView.swift` | Migrate one display-only metric group from `STRQMetricTile`/local style to `STRQMetricCard` or approved wrapper. | Visible premium payoff on Today without rewriting the screen. | Medium/High | Packages 1-2; choose exact module by prompt. | Readiness/weekly stats calculations, start/resume actions, sheets, analytics. | Today root with workout/no workout if possible; metric module; dynamic data values; no overlap in weekly pulse; unchanged CTAs. | Yes, to choose exact module and before touching Today. |
| 5 | Progress metric card shell | `ios/STRQ/Views/ProgressAnalyticsView.swift` | Convert one display-only metric/card cluster to STRQ card/metric primitives. | Makes analytics feel more premium and precise. | Medium | Package 4 or equivalent metric proof. | Derived calculations, `ProgressRoute.history`, workout history reads, PR data. | Progress root; early-stage and mature states if available; history link; selected metric module; no chart clipping. | Yes, to choose exact cluster. |
| 6 | Exercise Library filter chip cluster | `ios/STRQ/Views/ExerciseLibraryView.swift` | Replace one filter chip group with `STRQChip` using exact selected/unselected rules. | Improves browse/filter polish and validates chips. | Medium/High | Target filter behavior audit; exact icon/color map. | Search text, selected pattern/muscle/equipment filters, favorites, exercise identity, sheet presentation. | Library root; search; filter sheet; select/clear filters; favorites; open exercise detail. | Yes, because filters affect exercise discovery. |
| 7 | Exercise Library card shell | `ios/STRQ/Views/ExerciseLibraryView.swift` | Migrate `ExerciseCard` visual shell only, preserving current tap/favorite/progression data. | High visible value in Train/library flow. | Medium/High | Package 6; card primitive proof. | `onTap`, `onFavorite`, progression badges, exercise media/fallbacks, accessibility. | Library list/grid; favorite toggle; open detail; empty/search states; dark-mode contrast. | Yes. |
| 8 | Progress session-history row/card | `ios/STRQ/Views/SessionHistoryView.swift`, possibly `ios/STRQ/Views/ProgressAnalyticsView.swift` | Replace recent session/history rows with `STRQListItem`/card shell. | History becomes easier to scan and strengthens product trust. | Medium | Package 5. | Session ordering, detail navigation, completed-session data, notes/sets display. | Progress history route; session detail; empty history; long exercise names. | Yes, to confirm route and exact rows. |
| 9 | Workout completion reward summary module | `ios/STRQ/Views/WorkoutCompletionView.swift`, `ios/STRQ/Views/Components/STRQRewardEffects.swift` only if explicitly scoped | Migrate one display-only highlight/reward area to calmer STRQ reward styling. | Premium end-of-workout moment without noisy gamification. | Medium/High | No new assets; exact module chosen; reward tone policy approved. | Completion session data, close/handoff behavior, activation roadmap, analytics, reward effects timing unless explicitly scoped. | Completion screen after workout; no PR and PR states if available; next workout section; close flow. | Yes. |
| 10 | Exercise Detail information card stack | `ios/STRQ/Views/ExerciseDetailView.swift` | Migrate one low-action info section, not alternatives or progression chain first. | Improves a high-value screen while avoiding mutations. | Medium/High | Exercise card/list proof; no anatomy asset import. | Favorite action, alternative sheet, progression reads, media provider output. | Exercise detail; favorite button; media load/fallback; long exercise names; alternative sheet still opens. | Yes. |
| 11 | Readiness/Sleep form primitive pilot | `ios/STRQ/Views/ReadinessCheckInView.swift` or `ios/STRQ/Views/SleepLogView.swift` | Migrate one form subsection to calmer STRQ inputs/rows. | Improves daily habit logging and coach feel. | Medium/High | Form primitive behavior audit; exact binding list. | Submit/save calls, validation, recovery score/coaching response, dynamic input values. | Open sheet from Today/Coach/Profile; edit values; submit/save; error/disabled states; keyboard layout. | Yes. |
| 12 | Paywall visual planning and static shell only | `ios/STRQ/Views/STRQPaywallView.swift` | Design an approved `STRQPaywallPlanCard` wrapper without changing purchase logic. | Revenue surface can become premium, but must be controlled. | High | Owner-approved paywall direction; RevenueCat preservation checklist. | Package selection, `store.purchase`, `store.restore`, offering loading/error/pro states, entitlement behavior, analytics. | Paywall loading; product unavailable; annual/monthly package selection; purchase disabled/loading; restore; pro active state. | Yes, mandatory before implementation. |

Packages intentionally not ranked for early implementation:

- Active Workout redesign.
- Root tab/navigation migration.
- Onboarding visual rewrite.
- Watch app visual migration.
- Widget/Live Activity migration.
- Anatomy asset import.
- Work Sans/font import.

## How STRQ Avoids Becoming A Generic UI-Kit Clone

STRQ should use the purchased Figma UI kit as a pattern source and component reference, not as runtime identity.

Required guardrails:

- No Sandow runtime identity in Swift symbols, assets, localization keys, analytics, product IDs, or user-facing copy.
- No full-screen copying from Figma.
- No demo copy from the source kit.
- No coach/person/demo image imports.
- No generic fitness app page names that obscure STRQ's training-coach purpose.
- STRQ-owned naming for runtime components, assets, tokens, wrappers, and docs outside source/provenance sections.
- Carbon, graphite, black, white, and precise neutral hierarchy remain the core identity.
- Accent use stays restrained and semantic.
- The product must feel like an adaptive strength-training coach: specific, calm, serious, data-aware, and performance-oriented.
- Components should serve STRQ workflows: training plans, live workouts, progression, readiness, exercise identity, and long-term consistency.

Practical rule:

Every migration prompt should answer, "What STRQ product job does this visual change improve?" If the answer is only "it matches the kit," the scope is not ready.

## Accent And CTA Policy

Orange is not the default STRQ CTA system.

Policy:

- Primary CTAs should remain STRQ-owned and premium, using neutral/monochrome carbon identity unless a specific product state requires accent.
- Orange may be used as a rare, intentional accent for energy, warning-adjacent training context, source-compatible provenance, or selected/reward moments approved by the owner.
- Orange must not become the default button, tab, paywall, or primary action identity.
- Destructive states must use deliberate danger styling, not orange.
- Warning states must be semantically distinct from reward or selected states.
- Reward states should stay earned and calm. Avoid noisy gamification styling.
- Selected states should rely on hierarchy, contrast, border, and layout before accent color.
- Avoid one-note orange screens, orange-dominant gradients, and visual systems that feel like a generic template.
- Existing production orange/warm references should be treated as migration debt, not as permission to expand orange usage.

## Screenshot Intake Plan For Owner/Rork QA

The owner should capture screenshots after every UI pass. This list is written for non-technical review and can be reused as a Rork QA checklist.

Root screens:

- Today tab at normal logged-in state.
- Coach tab at normal logged-in state.
- Train tab with a plan loaded.
- Progress tab with available history.
- Profile tab.

Important flows:

- Start workout path from Today.
- Start workout path from Train.
- Exercise library search and filters.
- Exercise detail.
- Session history and a session detail.
- Notification settings.
- Nutrition settings if touched.
- Sleep log and body weight log if touched.

Active workout states:

- First exercise, first set not completed.
- A completed set with undo visible.
- Rest timer visible.
- Exercise list/swap or exercise info sheet.
- Workout options dialog.
- Completion/summary handoff.

Paywall/subscription:

- Paywall loading state.
- Annual/monthly package selection.
- Purchase button idle and purchasing/loading.
- Restore purchases.
- Product unavailable/error state.
- Pro already active state.

Onboarding:

- Welcome/name step.
- Metrics/body step.
- Goal and training level selections.
- Schedule/equipment step.
- Muscle focus step.
- Plan generation screen.
- Plan reveal screen.

Empty/error states:

- No workout history or early-stage Progress.
- Empty exercise search results.
- Paywall product unavailable.
- Notification permission not granted.
- Any offline/error state shown by changed surfaces.

Design system lab:

- DEBUG Profile route to Design System Lab.
- Token/foundation section.
- Buttons, chips, badges.
- Cards/metrics/progress.
- List/schedule.
- Icon grid.

Review checklist for each screenshot:

- Does this still feel like STRQ, not a generic fitness kit?
- Is the screen calm, precise, and premium?
- Is orange rare and intentional?
- Are labels readable and unclipped?
- Are tap targets clear?
- Do buttons and rows look related without becoming noisy?
- Are protected actions still where the user expects them?

## Prompt Template For Future Codex UI Passes

Use this structure:

```text
Work in repo: C:\Users\maxwa\Documents\GitHub\rork-strq

Goal:
Migrate only [specific module/function] in [exact file] to [allowed STRQ primitives].

Allowed edits:
- [exact files]

Do not edit:
- [protected files]
- ContentView.swift unless this is an approved navigation pass
- Assets.xcassets
- Localizable.xcstrings
- ViewModels/Services/Models
- Watch/Widget/Live Activity files
- Tests

Visual objective:
- [specific objective]

Must preserve:
- [exact actions/calls/bindings/navigation/analytics/localization]

Allowed design-system primitives:
- [exact primitive list]

Do not decide:
- No new tabs
- No orange default CTA
- No Figma screen copying
- No copy changes
- No asset imports
- No icon replacement unless listed

Rork screenshot QA required:
- [specific screenshots]

Verification:
- git status --short --branch
- git diff --name-only
- git diff -- [target files]
- git diff --name-only -- [protected paths]
- rg checks for Sandow/protected refs as relevant
```

## Baseline Conclusions

- STRQ's navigation is already product-appropriate: Today, Coach, Train, Progress, Profile.
- Production UI is still mostly `STRQPalette`, `STRQBrand`, Forge components, local helpers, and SF Symbols.
- The isolated `STRQDesignSystem` is broad and useful, but production adoption is currently limited to a small Profile controls-section micro-migration.
- The safest next UI work is continuing Profile/list-row migration, then one Notification settings row/toggle pass, then one display-only Dashboard/Progress metric module.
- Active Workout, Paywall, Onboarding, plan generation, progression, persistence, HealthKit, watch/widget/live activity, localization, and RevenueCat should remain protected until owner-approved dedicated passes.
- Future prompts should be smaller, exact about allowed primitives and files, and require Rork simulator screenshots after every visual implementation.
