# STRQ Project UI Audit

Last updated: 2026-04-30

## Purpose

This audit documents the current STRQ frontend and app architecture before any production UI migration. It is a control document for future design-system work. It does not authorize screen redesigns, production component swaps, asset imports, or business-logic changes.

Existing related docs that remain source material:

- `ios/STRQ/Utilities/STRQDesignSystemRoadmap.md`
- `ios/STRQ/Utilities/STRQDesignSystemNamingPlan.md`
- `ios/STRQ/Utilities/STRQIconCoveragePlan.md`
- `ios/STRQ/Utilities/SandowImportManifest.md`
- `ios/STRQ/Utilities/SandowAnatomyImportPlan.md`

## Repository State At Audit

| Item | Result |
|---|---|
| Working directory | `C:\Users\maxwa\Documents\GitHub\rork-strq` |
| Current branch | `main` |
| Git available | Yes |
| Initial `git status --short` | Dirty before this pass: untracked docs under `docs/` |
| `rg` available | Yes, `C:\Users\maxwa\AppData\Local\OpenAI\Codex\bin\rg.exe` |
| `rg --version` | `ripgrep 15.1.0 (rev af60c2de9d)` |
| Windows build note | `xcodebuild` was not run and is not expected on Windows |

Initial untracked files observed before this documentation pass:

- `docs/component-migration-plan.md`
- `docs/figma-source-map.md`
- `docs/project-ui-audit.md`
- `docs/protected-logic-map.md`

These files were in the requested documentation scope, so this pass continued with docs-only updates.

## Tech Stack

| Area | Current state |
|---|---|
| App framework | SwiftUI |
| Language | Swift |
| State model | Swift Observation with `@Observable`, `@Bindable`, and `@State` |
| Platform targets | iOS app, watchOS app, WidgetKit extension, unit tests, UI tests |
| Persistence | File-backed JSON in Application Support through `PersistenceStore`, plus iCloud KVS through `CloudSyncService` |
| Subscriptions | RevenueCat and StoreKit via `StoreViewModel` |
| Analytics | `Analytics` singleton with debug console provider and release no-op provider |
| Notifications | `UNUserNotificationCenter`, smart scheduler, deep-link routing |
| Health | HealthKit service for body weight, sleep, and workout export |
| Live Activity | ActivityKit through `WorkoutLiveActivityManager` and shared attributes |
| Watch | WatchConnectivity service plus a watch app logging surface |
| Widget | WidgetKit snapshots via app group storage |
| Localization | `Localizable.xcstrings`, `L10n` wrapper, watch/widget `.strings` files |

## Xcode Targets

The project file contains these native targets:

| Target | Purpose | Notes |
|---|---|---|
| `STRQ` | Main iOS app | Generated Info.plist; app icon and accent color from asset catalog |
| `STRQTests` | Unit tests | Uses Swift Testing and `@testable import STRQ` |
| `STRQUITests` | UI tests | Launch and launch performance skeletons |
| `STRQWatch` | watchOS app | Own `ContentView`, `WatchWorkoutStore`, localized `.strings` |
| `STRQWidget` | WidgetKit extension | Today, streak, and workout Live Activity surfaces |

Important generated Info.plist keys include HealthKit usage strings, Live Activity support, iPhone/iPad families, and watch companion bundle configuration. Do not add `UIAppFonts` in a UI pass without a separate font/resource decision, because the app currently relies on generated Info.plist settings and runtime font registration.

## Project Structure

| Path | Role |
|---|---|
| `ios/STRQ/STRQApp.swift` | App entry, RevenueCat setup, app lifecycle analytics, watch activation, scene-phase persistence |
| `ios/STRQ/ContentView.swift` | Main routing shell, onboarding/active workout/handoff/main tabs, custom current tab bar |
| `ios/STRQ/Views` | Production SwiftUI screens and sheets |
| `ios/STRQ/Views/Debug` | DEBUG-only design-system lab |
| `ios/STRQ/Views/Components` | Small reusable production effects/components |
| `ios/STRQ/ViewModels` | `AppViewModel` and `StoreViewModel` |
| `ios/STRQ/Services` | Domain services, engines, persistence, integrations |
| `ios/STRQ/Models` | Codable/domain models |
| `ios/STRQ/Utilities` | Palette/theme/design-system utilities and planning docs |
| `ios/STRQ/Assets.xcassets` | App icons, STRQ icon assets, body PNG assets, sigil |
| `ios/STRQ/Localization` | `L10n` wrapper |
| `ios/STRQ/Data/External/ExerciseDBPro` | Imported exercise JSON data and docs |
| `ios/STRQShared` | Shared ActivityKit attributes |
| `ios/STRQWidget` | Widget and Live Activity UI |
| `ios/STRQWatch` | Watch app and watch workout store |

## Navigation And Runtime Shell

`ContentView` currently owns the top-level flow:

| State | Runtime destination |
|---|---|
| Onboarding incomplete, form | `OnboardingView` |
| Onboarding incomplete, generating | `PlanGenerationView` |
| Onboarding incomplete, reveal | `PlanRevealView` |
| Active workout visible or completion handoff | `ActiveWorkoutView` |
| Pre-workout handoff | `PreWorkoutHandoffView` |
| Main app | `TabView` with five `NavigationStack` tabs |

Main app tabs:

| Tab | View | Notes |
|---|---|---|
| Today | `DashboardView` | Current dashboard/today surface |
| Coach | `CoachTabView` | Coaching, readiness, weekly review, history |
| Train | `TrainingPlanView` | Plan, session editor, exercise detail, schedule editor |
| Progress | `ProgressAnalyticsView` | Analytics routes through `ProgressRoute` |
| Profile | `ProfileView` | Settings, subscription, debug lab route, diagnostics |

The main `TabView` hides the system tab bar and uses a custom `STRQTabBar` defined inside `ContentView.swift`. That current production tab bar still uses SF Symbols and `STRQPalette`, not the isolated `STRQDesignSystem` tab primitives.

## State Management

| File | Role |
|---|---|
| `ios/STRQ/ViewModels/AppViewModel.swift` | Main `@Observable @MainActor` app state and composition root |
| `ios/STRQ/ViewModels/StoreViewModel.swift` | RevenueCat offerings, purchase, restore, pro state |
| `ios/STRQ/Services/*Coordinator.swift` | Delegated state/domain coordination from `AppViewModel` |
| `ios/STRQ/Services/WorkoutController.swift` | Active workout mutation subsystem |
| `ios/STRQWatch/WatchWorkoutStore.swift` | Watch workout state and WatchConnectivity interface |

The UI migration must treat `AppViewModel` as state contract, not a visual target. Screens may read existing published/observable state, but a visual migration should not change what state means, how it is persisted, or when side effects fire.

## Important Services And Engines

| Area | Key files |
|---|---|
| Active workout | `WorkoutController.swift`, `WorkoutLiveActivityManager.swift`, `WatchConnectivityService.swift` |
| Plan generation | `PlanGenerator.swift`, `PlanQAHarness.swift` |
| Progression and prescriptions | `ProgressionEngine.swift`, `AdaptivePrescriptionEngine.swift`, `StartingLoadEngine.swift` |
| Coaching | `CoachingCoordinator.swift`, `CoachingEngine.swift`, `CoachActionManager.swift`, `DailyCoachEngine.swift`, `WeeklyReviewGenerator.swift` |
| Recovery/readiness | `DailyStateCoordinator.swift`, `DailyBriefingEngine.swift`, `HealthKitService.swift` |
| Nutrition/physique | `NutritionPhysiqueCoordinator.swift`, `NutritionCoachEngine.swift`, `PhysiqueIntelligenceEngine.swift` |
| Persistence/sync | `PersistenceStore.swift`, `SnapshotBuilder.swift`, `CloudSyncService.swift`, `ContinuityCoordinator.swift` |
| Exercise data | `ExerciseLibrary.swift`, `ExerciseCatalog.swift`, `ExerciseDBProImporter.swift`, `ExerciseIdentity.swift`, `ExerciseFamilyService.swift` |
| Notifications | `NotificationScheduler.swift`, `NotificationDeepLinkCenter.swift`, `NotificationDeepLinkRoute.swift` |
| Analytics/errors | `Analytics.swift`, `ErrorReporter.swift`, `EnvironmentValidator.swift` |

## Current Design And Theme Files

| File | Current role |
|---|---|
| `ios/STRQ/Utilities/STRQPalette.swift` | Active production palette and state badges |
| `ios/STRQ/Utilities/ForgeTheme.swift` | Current production surfaces, cards, metric tiles, CTAs, chips |
| `ios/STRQ/Utilities/STRQDesignSystem.swift` | Isolated purchased-kit-derived STRQ-owned token/component foundation |
| `ios/STRQ/Utilities/STRQFontRegistrar.swift` | Runtime Work Sans registration hook |
| `ios/STRQ/Views/Debug/STRQDesignSystemPreviewView.swift` | DEBUG-only design-system lab |

Current production screens largely use `STRQPalette`, `STRQBrand`, `ForgeSurface`, `ForgeCard`, `STRQMetricTile`, SF Symbols, and local per-screen view structs. The isolated `STRQDesignSystem.swift` contains the future foundation but is not broadly applied to production screens.

## Current Reusable Components

Production/current reusable UI includes:

| Area | Files/components |
|---|---|
| Theme surfaces | `ForgeSurface`, `ForgeCard`, `ForgeSectionHeader`, `ForgeEmptyState` |
| Production STRQ helpers | `STRQMetricTile`, `STRQBadgeChip`, `STRQPrimaryCTA`, `STRQSectionTitle` |
| State UI | `STRQPremiumLoader`, `STRQEmptyState`, `STRQToastView`, `STRQAppliedPill` |
| Rewards | `STRQSuccessPulse`, `STRQPulseMark`, `STRQCountUpText`, `STRQCelebrationBadge`, `STRQRewardToast` |
| Exercise media | `ExerciseThumbnail`, `ExerciseMediaPreview`, `RemoteExerciseImage`, `ExerciseHeroView` |
| Body/muscle | `BodyMapView`, `MuscleFocusView`, `MuscleRegionPaths` |
| Debug-only | `STRQDesignSystemPreviewView` |

Isolated future primitives in `STRQDesignSystem.swift` include `STRQCard`, `STRQButton`, `STRQIconButton`, `STRQChip`, `STRQBadge`, `STRQMetricCard`, `STRQProgressBar`, `STRQProgressRing`, `STRQListItem`, `STRQSearchField`, `STRQInputField`, `STRQToggleRow`, `STRQModalSurface`, `STRQBottomSheetSurface`, `STRQNavigationBar`, `STRQAvatar`, `STRQRatingStars`, `STRQEmptyStateCard`, `STRQTabBarContainer`, and `STRQScheduleRow/Card`.

## Asset Catalog

Current `ios/STRQ/Assets.xcassets` contains:

| Asset type | Current state |
|---|---|
| App icon/accent | `AppIcon.appiconset`, `AccentColor.colorset` |
| STRQ sigil | `STRQSigil.imageset` |
| STRQ icons | 60 `STRQIcon*.imageset` folders, SVG based |
| Body PNGs | `body_male_front`, `body_male_back`, `body_female_front`, `body_female_back`, plus premium male front/back PNGs |

The icon coverage doc says the 60 `STRQIcon` enum cases and `STRQIcon*.imageset` assets are synced, template-rendered, and vector-preserved. This pass did not import or alter assets.

## Icon Usage

Production views still use many SF Symbols through `Image(systemName:)`. This is expected before migration and should be treated as inventory, not a bug. Future design-system passes should migrate icons only through approved STRQ-owned assets and `STRQIcon`/`STRQIconView`, one screen or component at a time.

Do not blindly replace all SF Symbols. Some runtime/system concepts may remain better as SF Symbols until a STRQ-owned equivalent is approved.

## Font Usage

`STRQDesignSystem.swift` expects Work Sans as the purchased UI kit source font. `STRQFontRegistrar.registerBundledFonts()` runs in `STRQApp.init()`, but this checkout currently has no `.ttf`, `.otf`, `.woff`, or `.woff2` font files under `ios/STRQ`. The runtime design-system layer falls back to system fonts when Work Sans is absent.

Current implication: typography strategy can be documented and tokenized, but exact Work Sans fidelity is pending licensed font files and app-bundle verification.

## Localization Setup

| Area | Current state |
|---|---|
| App strings | `ios/STRQ/Localizable.xcstrings` |
| Runtime wrapper | `ios/STRQ/Localization/L10n.swift` |
| Watch/widget strings | `ios/STRQWatch/en.lproj`, `ios/STRQWatch/de.lproj`, `ios/STRQWidget/en.lproj`, `ios/STRQWidget/de.lproj` |
| Patterns | `L10n.tr`, `L10n.format`, `L10n.countLabel` |

UI migration must not introduce raw localization keys in runtime text or alter localization catalogs unless the user explicitly approves copy/localization work.

## Debug-Only Tools

`ios/STRQ/Views/Debug/STRQDesignSystemPreviewView.swift` is the isolated design-system lab. It is reachable from the profile/debug path and should remain DEBUG-only. Production screens must not depend on the lab, and this pass did not touch the existing debug route.

## Current Production Screens

Key production views include:

| Area | File(s) |
|---|---|
| Dashboard / Today | `DashboardView.swift`, `ActivationRoadmapCard.swift`, `ComebackCard.swift` |
| Train / Plan | `TrainingPlanView.swift`, `SessionEditorSheet.swift`, `ScheduleEditorSheet.swift`, `WeekPreviewSheet.swift` |
| Active workout | `ActiveWorkoutView.swift`, `PreWorkoutHandoffView.swift`, `WorkoutCompletionView.swift` |
| Progress | `ProgressAnalyticsView.swift`, `SessionHistoryView.swift` |
| Coach | `CoachTabView.swift`, `ExpandableCoachCard.swift`, `CoachingHistoryView.swift`, `CoachingPreferencesView.swift` |
| Profile/settings | `ProfileView.swift`, `NotificationSettingsView.swift`, `NutritionSettingsView.swift`, `MediaDiagnosticsView.swift` |
| Paywall | `STRQPaywallView.swift` |
| Onboarding | `OnboardingView.swift`, `PlanGenerationView.swift`, `PlanRevealView.swift` |
| Exercise library/detail | `ExerciseLibraryView.swift`, `ExerciseDetailView.swift`, `ExercisePrescriptionSheet.swift`, `ExerciseHeroView.swift`, `ExerciseThumbnail.swift`, `SwapExerciseSheet.swift` |
| Recovery/nutrition | `ReadinessCheckInView.swift`, `SleepLogView.swift`, `NutritionLogView.swift`, `BodyWeightLogView.swift`, `WeightQuickLogSheet.swift` |
| Watch/widget | `ios/STRQWatch/*`, `ios/STRQWidget/*` |

## Current Risk Areas

| Risk | Why it matters |
|---|---|
| Mixed design foundations | Production uses `STRQPalette`/Forge while `STRQDesignSystem` is isolated. A random partial migration would fragment the UI further. |
| High SF Symbol usage | Needs deliberate STRQ icon replacement map, not mass replacement. |
| Large `AppViewModel` surface | Many screens call directly into domain state and mutations. Visual work must not change state semantics. |
| Active workout complexity | iPhone, watch, Live Activity, persistence, analytics, and HealthKit all intersect here. |
| Paywall/product sensitivity | RevenueCat identifiers, package selection, trial copy, restore behavior, and analytics are protected. |
| Missing Work Sans binaries | Exact Figma typography cannot be claimed until fonts are added and verified. |
| Figma file size | Full scans can timeout. Continue bounded node/page inspection and record pending queues. |
| Localization spread | Some user-facing strings are literal fallback strings through `L10n.tr`; migration must not add raw keys or remove existing localized behavior. |
| Watch/widget surfaces | They are production runtime surfaces and should be excluded from main iOS visual migration until separately scoped. |
