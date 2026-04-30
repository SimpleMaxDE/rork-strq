# STRQ Component Migration Plan

Last updated: 2026-04-30

## Purpose

This plan inventories current STRQ production screens and major UI components, then maps them to possible Purchased Figma UI Kit source patterns for later implementation. It is not an implementation pass. No screen should be redesigned from this document alone.

Related control docs:

- [Docs README](README.md)
- [STRQ UI Migration Master Plan](strq-ui-migration-master-plan.md)
- [Project UI Audit](project-ui-audit.md)
- [Protected Logic Map](protected-logic-map.md)
- [Figma Source Map](figma-source-map.md)
- [Design System Import Plan](design-system-import-plan.md)
- [Asset Import Plan](asset-import-plan.md)
- [QA Validation Plan](qa-validation-plan.md)

## Migration Principles

- Build STRQ-owned reusable primitives first.
- Prove each primitive in DEBUG or isolated previews before production use.
- Migrate one contained module at a time.
- Preserve all state, actions, analytics, localization, navigation, and training behavior.
- Treat protected app logic as off-limits unless explicitly approved.
- Do not copy whole Figma screens into STRQ. Use the Purchased Figma UI Kit as a visual/component source, not as STRQ product identity.

## Figma Component Inventory Notes

Current pass verified these adjacent reusable Figma component sets beyond the original anchor list:

| Figma area | Useful discovered component sets | STRQ relevance |
|---|---|---|
| General/Button | `Button`, `Button Digit`, `Button Icon`, `Button Swipe` | Buttons, steppers, icon actions, workout controls |
| General/Chat | `Chat Bubble`, `Chat Top Nav`, `Chat Input`, `Chat Item`, `Chat Custom Widget` | Coach and support-style surfaces |
| General/Chart | `Line Chart`, `Pie Chart`, `Donut Chart`, `Bar Chart`, `Area Chart`, `Trend Label`, `Legend` | Progress, dashboard, readiness, sleep |
| General/Form/Input | `Checkbox`, `Radio`, `Toggle`, `Input Field`, `Input OTP`, `Input Textarea` | Onboarding, settings, filters |
| General/Modal/Progress/Slider/Step | `Modal`, `Progress Bar`, `Progress Bar Circular`, `Slider`, `Range Slider`, `Step Item` | Sheets, preferences, onboarding steps, progress |
| App/Card Specific | `Health Metric Card`, `Workout Card`, `Workout Progress Card`, `Coach Card`, `Card Nutrition`, `Meal Search Result Card` | STRQ app-specific wrappers |
| App/Card General | `Simple Card`, `Choice Card`, `Metric Card`, `Profile Card`, `CTA Card`, `Hero Card`, `Pricing Card`, `Row Card` | Core reusable card primitives |
| App/List/Schedule/Tab Bar | `List Item`, `_ListItemSlot`, `Schedule`, `_ScheduleItem`, `Tab Bar`, `_TabBarItem` | Settings rows, training schedule, navigation |
| Foundations/Illustration | `Achievement Badge`, `Body Type`, `Anatomy Muscle`, `Avatar Illustration`, `_IllustrationBase` | Rewards, onboarding/body, anatomy, empty states |

## Current Production Screens

| Screen / area | File path(s) | Current purpose | UI quality/risk | Redesign later? | Keep? | Figma pattern candidates | Priority | Risk |
|---|---|---|---|---|---|---|---|---|
| Dashboard / Today | `ios/STRQ/Views/DashboardView.swift`, `ActivationRoadmapCard.swift`, `ComebackCard.swift` | Daily briefing, workout status, readiness, activation/comeback, weekly pulse | Dense, important, high behavioral coupling | Yes, after primitives | Keep logic and layout behavior until planned | Dark `Home & Smart Fitness Metrics` `11604:62728`, smart metric cards, schedule, progress cards | High | High |
| Train / Training Plan | `TrainingPlanView.swift`, `SessionEditorSheet.swift`, `ScheduleEditorSheet.swift`, `WeekPreviewSheet.swift` | Plan overview, session editing, exercise detail entry, schedule editing | Functional but component-heavy | Yes | Keep behavior | Workout library, schedule `9132:170645`, app-specific cards `9160:324200`, bottom sheet `9131:299492`, list item `9134:89206` | High | High |
| Active Workout | `ActiveWorkoutView.swift`, `WorkoutController.swift` call sites | Live set logging, rest, notes, swaps, completion | High-value but most dangerous | Yes, much later | Keep behavior fully | Button, progress, list, workout cards, modal/bottom sheet, but no direct full copy | High | High |
| Workout Completion | `WorkoutCompletionView.swift`, `STRQRewardEffects.swift` | Completion summary, learned signals, next workout, reward moments | Strong product logic, visual opportunity | Yes | Keep logic | Achievement badge `9064:106798`, achievement cards from `11613:176014`, reward/empty states | Medium | Medium/High |
| Progress / Analytics | `ProgressAnalyticsView.swift`, `SessionHistoryView.swift` | Training metrics, charts, history, progress routes | Visual complexity and chart debt | Yes | Keep data contracts | Chart `9129:26029`, progress `9129:207997`, metric cards, dashboard/bonus dashboard patterns | High | Medium/High |
| Coach | `CoachTabView.swift`, `ExpandableCoachCard.swift`, `CoachingHistoryView.swift`, `CoachingPreferencesView.swift` | Daily coach, readiness, actions, weekly reviews, preferences | Copy/data heavy; card structure can improve | Yes | Keep coach logic | Chat `9128:164508`, AI Fitness Coach screen groups, feedback, cards, list items | Medium/High | High |
| Profile | `ProfileView.swift` | Profile, account, settings, subscription, debug route | Mixes settings, diagnostics, subscription entry | Yes | Keep debug route | Profile Settings & Help Center `11589:83741` / `11613:167073`, list item, toggles, navigation, pricing cards | Medium | Medium |
| Paywall | `STRQPaywallView.swift`, `StoreViewModel.swift` | RevenueCat package selection, restore, subscription state | Sensitive purchase flow | Yes, after component proof | Keep all RevenueCat behavior | Pricing Card `8751:102794`, plan/pricing screen patterns, buttons, badges | Medium | High |
| Onboarding | `OnboardingView.swift`, `PlanGenerationView.swift`, `PlanRevealView.swift` | Captures user inputs, generates plan, reveals plan | High first-run value, high state risk | Yes, phased | Keep state flow | Welcome Screen, Comprehensive Fitness Assessment, Profile Setup, Body Type `9025:207456`, inputs, steps | High | High |
| Exercise Library | `ExerciseLibraryView.swift`, `ExerciseCard`, `SwapExerciseSheet.swift`, `ExerciseThumbnail.swift` | Browse/filter/search exercises, favorites, family/world views | Heavy content and filter UI | Yes | Keep exercise data | Personalized Workout Library, search/input, chips, cards, list item, equipment media | High | Medium/High |
| Exercise Detail | `ExerciseDetailView.swift`, `ExerciseHeroView.swift`, `ExercisePrescriptionSheet.swift`, `MuscleFocusView.swift`, `BodyMapView.swift` | Exercise metadata, prescriptions, media, muscle focus | Good candidate for anatomy enhancement | Yes | Keep domain data | Anatomy Muscle `8673:69673`, large anatomy groups `9192:5535`, card general/app, media | High | Medium/High |
| Sleep / Readiness | `SleepLogView.swift`, `ReadinessCheckInView.swift`, `BodyWeightLogView.swift`, `WeightQuickLogSheet.swift` | Recovery, sleep logging, readiness check-ins, weight | Important support flows | Yes | Keep logic | Sleep Monitoring, Activity Tracker, progress, chart, input, modal | Medium | Medium |
| Nutrition | `NutritionLogView.swift`, `NutritionSettingsView.swift`, `PhysiqueVerdictCard.swift` | Nutrition logs, targets, physique feedback | Medium product scope; strong card opportunity | Maybe | Keep logic | Nutrition & Meal Management, nutrition cards, charts, inputs | Medium | Medium |
| Settings / Notifications | `NotificationSettingsView.swift`, `ProfileView.swift` | Reminder settings, HealthKit toggle, subscription/account links | Needs consistent rows/toggles | Yes | Keep settings behavior | Profile Settings & Help Center, list item, toggle row, input, notification | Medium | Medium |
| Watch | `ios/STRQWatch/ContentView.swift`, `WatchWorkoutStore.swift` | Watch set logging and active workout controls | Tiny surface, behavior sensitive | Later only if scoped | Keep now | Watch/device patterns not deeply inspected; icons and compact controls | Low | High |
| Widget / Live Activity | `ios/STRQWidget/*`, `ios/STRQShared/*` | Today/streak widgets and active workout Live Activity | Separate target; runtime sensitive | Later only if scoped | Keep now | Bonus dashboard cards, progress rings, widget-specific design later | Low | High |

## Current Reusable Components And Migration Targets

| Current component area | Current file(s) | Current purpose | Figma mapping | Future STRQ component | Priority | Risk |
|---|---|---|---|---|---|---|
| Palette/theme | `STRQPalette.swift`, `ForgeTheme.swift` | Active production colors, surfaces, cards, CTAs | Foundations colors/effects/spacing/typography | `STRQColors`, `STRQEffects`, `STRQSpacing`, `STRQTypography` | High | Medium |
| Isolated design-system primitives | `STRQDesignSystem.swift` | Future token/component set, not widely used | Foundations, Button, Badge/Chip, Progress, Tab, List, Schedule, Cards | Existing `STRQ*` names | High | Medium |
| Current tab bar | `ContentView.swift` | Main five-tab navigation | Tab Bar `9131:291579`, Navigation `11614:57585` | `STRQTabBar` runtime component | High | High |
| Forge surfaces/cards | `ForgeSurface`, `ForgeCard` | Existing cards and sections | Card - General `9131:326493`, Card - App Specific `9160:324200` | `STRQCard`, `STRQSurface` | High | Medium |
| Metric tiles | `STRQMetricTile`, dashboard cards | KPIs and progress summaries | Metric Card in Home `11604:62728`, Chart, Progress | `STRQMetricCard`, `STRQChartCard` | High | Medium |
| Buttons/CTAs | `STRQPrimaryCTA`, local Buttons | Actions across app | Button `9128:103928`, FAB `9131:301834` | `STRQButton`, `STRQIconButton`, `STRQFAB` | High | Medium |
| Chips/badges | `STRQBadgeChip`, local chips | Filter, status, coach tags | Badge & Chip `9126:59240` | `STRQChip`, `STRQBadge` | High | Low/Medium |
| Lists/settings rows | Local rows in many files | Settings, exercise rows, coach history | List Item `9134:89206`, Form Control | `STRQListItem`, `STRQSettingsRow` | High | Medium |
| Search/input | SwiftUI `.searchable`, local forms | Exercise library, onboarding/settings | Input `9129:190574`, Form Control `9129:175150`, Search `8631:71039` | `STRQSearchField`, `STRQInputField` | High | Medium |
| Progress bars/rings | Local bars/charts | Readiness, completion, progress | Progress `9129:207997`, Chart `9129:26029` | `STRQProgressBar`, `STRQProgressRing`, `STRQChartCard` | High | Medium |
| Sheets/modals | SwiftUI `.sheet`, local shells | Editors, filters, confirmations | Bottom Sheet `9131:299492`, Modal `9129:50010`, Side Sheet `9131:286894` | `STRQBottomSheet`, `STRQModal` | Medium/High | Medium |
| Workout cards | Local plan/session cards | Plan and session display | Workout Library, Card - App Specific | `STRQWorkoutCard`, `STRQExerciseCard` | High | High |
| Anatomy/body visuals | `BodyMapView`, `MuscleFocusView`, PNG body assets | Muscle focus and body map | Anatomy Muscle `8673:69673`, large body groups `9192:5535`, Body Type `9025:207456` | `STRQAnatomyView`, `STRQMuscleFocusCard` | High | Medium/High |
| Rewards | `STRQRewardEffects.swift` | Completion/reward animations and badges | Achievement Badge `9064:106798`, `_AchievementBadgeBase` `9063:203904` | `STRQAchievementBadge`, `STRQAchievementCard` | Medium | Medium |
| Empty/loading/error states | `STRQStates.swift`, local views | Empty, loader, toast | Loader `9129:191044`, Error & Utility screen groups, Empty components | `STRQEmptyStateCard`, `STRQLoader`, `STRQErrorState` | Medium | Low/Medium |

## Recommended Component Build Order

| Order | Component group | Why first |
|---:|---|---|
| 1 | Token alignment docs and exact token decisions | Avoid mixing `STRQPalette`, Forge, and isolated tokens randomly |
| 2 | Icon registry coverage and SF Symbol audit | Current production relies heavily on `Image(systemName:)` |
| 3 | Buttons, chips, badges, list rows | Low risk and used everywhere |
| 4 | Cards, surfaces, section headers | Provides stable layout primitives before screens move |
| 5 | Progress/metric/chart primitives | Needed by Dashboard, Progress, readiness, workout completion |
| 6 | Search/input/toggle/sheet/modal primitives | Needed by library, settings, onboarding, editors |
| 7 | Anatomy/reward assets and components | High visual value; requires asset strategy first |
| 8 | Screen module migration | Only after primitives are verified |

## Screen Migration Sequencing

Recommended first production modules, after component foundations are stable:

| Sequence | Candidate | Reason | Guardrail |
|---:|---|---|---|
| 1 | Small settings/list rows inside Profile or Notifications | Lower domain risk, exercises list-row primitives | Do not change toggles, HealthKit calls, notification settings |
| 2 | Isolated metric card in Dashboard | Visible value with limited action surface | Do not change dashboard logic or Today routing |
| 3 | Exercise Library cards/search/filter shell | Good component reuse test | Do not change exercise catalog/filter semantics |
| 4 | Progress metric cards/chart shells | Good visual payoff | Do not alter calculations or history |
| 5 | Workout Completion reward/badge area | Strong controlled reward surface | Do not alter completion effects, history, analytics |
| 6 | Onboarding visual modules | High value, higher risk | Do not change onboarding phase/state |
| 7 | Paywall visual modules | Revenue sensitive | Preserve RevenueCat behavior exactly |
| 8 | Active Workout | Last among core screens | Requires full QA because it mutates live data |

## Known Deferrals

- Full Dashboard replacement is deferred.
- Active Workout redesign is deferred.
- Watch and Widget redesign are deferred.
- Anatomy asset import is deferred to an asset-import pass.
- Work Sans font import is deferred until licensed files are present.
- Figma dark screen groups should inform direction, not replace STRQ screens one-for-one.
