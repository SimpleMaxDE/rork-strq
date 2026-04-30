# STRQ Protected Logic Map

Last updated: 2026-04-30

## Purpose

This document defines app logic that must not be changed during the STRQ frontend/UI migration unless the user explicitly approves that scope. UI migration may wrap, restyle, or recompose views around these systems, but it must not alter their contracts, side effects, identifiers, persistence, or behavior.

Current pass note: this is a documentation-only control pass. No protected Swift files, production screens, assets, localization catalogs, or runtime behavior should be changed as part of this pass.

## Global Migration Rule

Allowed UI migration changes:

- Read existing state from view models and services.
- Pass existing actions through unchanged.
- Replace visual shells with STRQ-owned components after a separate implementation pass is approved.
- Add isolated preview/demo surfaces under DEBUG only.
- Add docs, manifests, and checklists.

Forbidden during UI migration:

- Change workout/training/progression algorithms.
- Change persisted schema, keys, filenames, app group identifiers, product IDs, analytics event names, notification route IDs, or exercise IDs.
- Change onboarding completion semantics.
- Change active workout set/exercise cursor behavior, rest behavior, Live Activity behavior, Watch action behavior, or HealthKit write behavior.
- Change localization catalogs or introduce raw localization keys without approval.

## Protected Areas

| Area | File paths | What it does | Why protected | UI changes allowed | Forbidden changes |
|---|---|---|---|---|---|
| App composition/root state | `ios/STRQ/ViewModels/AppViewModel.swift`, `ios/STRQ/STRQApp.swift`, `ios/STRQ/ContentView.swift` | Owns app state, onboarding, plan, workout history, active workout, daily state, persistence, reminders, tab flow | It is the central runtime contract used by nearly every screen | Read state, call existing actions, document boundaries | Reorder lifecycle side effects, rename state fields, change app routing conditions, mutate persistence timing |
| Active workout controller | `ios/STRQ/Services/WorkoutController.swift`, `ios/STRQ/ViewModels/AppViewModel.swift`, `ios/STRQ/Views/ActiveWorkoutView.swift` | Starts/completes/discards workouts, updates sets, advances cursor, handles undo, swaps active exercise, handles watch actions | Incorrect changes can lose workout data or corrupt a live session | Restyle controls in a later approved screen pass while preserving exact calls | Change `startWorkout`, `completeCurrentSet`, `completeWorkout`, `undoLastCompletedSet`, `handleWatchAction`, active workout mutation order |
| Rest timer / Live Activity handoff | `WorkoutController.swift`, `WorkoutLiveActivityManager.swift`, `ios/STRQShared/WorkoutActivityAttributes.swift`, `ios/STRQWidget/WorkoutLiveActivity.swift` | Sends active workout state to ActivityKit and lock-screen/dynamic surfaces | Live Activity state must remain synchronized with active workout | Visual-only widget/live activity changes in a separately scoped target pass | Change state attributes, update/end timing, rest end handling, workout ID semantics |
| Watch workout behavior | `ios/STRQ/Services/WatchConnectivityService.swift`, `ios/STRQWatch/WatchWorkoutStore.swift`, `ios/STRQWatch/ContentView.swift`, `WorkoutController.swift` | Syncs active workout to Apple Watch and routes watch actions back to iPhone | Watch actions mutate real active workout state | Later visual-only watch UI pass preserving action names and payloads | Change action strings, payload keys, WatchConnectivity activation, set logging behavior |
| Plan generation | `ios/STRQ/Services/PlanGenerator.swift`, `PlanQAHarness.swift`, `AppViewModel.generatePlan()` | Generates training plans from profile, muscle balance, recovery, phase, history, response profile | Core product intelligence | Show generated data differently | Change exercise selection, generated sets/reps/rest/RPE, scheduling logic, QA thresholds |
| Progression and prescription logic | `ProgressionEngine.swift`, `AdaptivePrescriptionEngine.swift`, `StartingLoadEngine.swift`, `ToleranceEngine.swift`, `SmartVolumeEngine.swift`, `AppViewModel.todayPrescription()` | Computes progression, load suggestions, recovery adjustments, volume and tolerance decisions | Core training correctness | Visualize decisions/cards differently | Alter formulas, thresholds, phase behavior, load increments, plateau logic |
| Coach actions and intelligence | `CoachingCoordinator.swift`, `CoachingEngine.swift`, `CoachActionManager.swift`, `DailyCoachEngine.swift`, `DailyBriefingEngine.swift`, `WeeklyReviewGenerator.swift`, `ExpandableCoachCard.swift` | Produces and applies coaching guidance, weekly actions, daily messages | Logic changes can alter product recommendations | Re-skin cards, rows, message views later | Change action semantics, apply/undo behavior, guidance conditions, analytics events |
| Persistence schema | `PersistenceStore.swift`, `SnapshotBuilder.swift`, `ContinuityCoordinator.swift`, `CloudSyncService.swift` | Serializes app state, active drafts, cloud restore/upload | Schema/key changes can lose user data | Display sync/persistence states differently | Change `strq_state_v1.json`, `PersistedAppState` schema, snapshot keys, restore conflict behavior |
| Exercise identity/catalog | `ExerciseLibrary.swift`, `ExerciseCatalog.swift`, `ExerciseDBProImporter.swift`, `ExerciseIdentity.swift`, `ExerciseFamilyService.swift`, `ExerciseFamilyPriors.swift`, `Data/External/ExerciseDBPro/*` | Maintains curated/imported exercise IDs, aliases, families, media eligibility, external JSON | IDs and families drive plans, history, progression, media, swaps | Display exercise cards/media using existing IDs | Rename IDs, change canonicalization, re-map families, replace JSON data, change import gates |
| Exercise media provider | `ExerciseMediaProvider.swift`, `CuratedImportedMediaBridge.swift`, `RemoteExerciseImage.swift`, `ExerciseThumbnail.swift`, `ExerciseHeroView.swift` | Chooses exercise imagery, symbols, gradients, GIF fallbacks | Visual migration could accidentally alter exercise identity/media availability | Swap visual container only, keep provider output unchanged | Change media URL mapping, fallback order, canonical coverage, external media assumptions |
| Analytics | `Analytics.swift`, call sites in views/services | Tracks lifecycle, onboarding, training, purchases, coaching, progress, persistence, account/sync | Event names are data contracts | Preserve event calls while restyling | Rename/remove/add events casually, change properties or trigger timing |
| RevenueCat/store/product identifiers | `STRQApp.swift`, `StoreViewModel.swift`, `STRQPaywallView.swift`, `Config.swift`, `EnvironmentValidator.swift` | Configures RevenueCat, loads offerings, purchases/restores, maps entitlement `pro` | Revenue and App Store behavior are high risk | Visual-only paywall redesign later preserving calls and package selection | Change API keys, entitlement ID, package/product logic, restore behavior, product ID interpretation |
| Onboarding state | `ContentView.swift`, `OnboardingView.swift`, `PlanGenerationView.swift`, `PlanRevealView.swift`, `AppViewModel.finishPlanGeneration()`, `completeOnboarding()` | Controls form/generation/reveal/completion and initial plan creation | Incorrect changes can block onboarding or change user data | Restyle screens later with same state transitions | Change phase order, completion flags, legacy flag behavior, generation timing |
| Localization behavior | `Localizable.xcstrings`, `Localization/L10n.swift`, watch/widget `.strings` | Provides localized strings and formatting helpers | Raw keys or catalog churn can break user-facing copy | Keep existing `L10n.tr`/`format` calls when moving UI | Replace with raw keys, remove fallbacks, edit catalogs without approved copy scope |
| Notifications and deep links | `NotificationScheduler.swift`, `NotificationDeepLinkCenter.swift`, `NotificationDeepLinkRoute.swift`, `AppDelegate.swift`, `ContentView.handlePendingNotificationRoute()` | Schedules smart reminders and routes resume/readiness/sleep notification actions | Notification IDs and routes affect user entry flows | Restyle settings UI around existing settings | Change identifiers, userInfo keys, route handling, permission behavior |
| HealthKit | `HealthKitService.swift`, `NotificationSettingsView.swift`, `AppViewModel.syncHealthKitOnEnable()`, workout/weight logging call sites | Requests HealthKit access, reads weight/sleep, writes body weight and workouts | Privacy and data integrity sensitive | Restyle permission/settings rows | Change entitlements, request scope, read/write behavior, enabled-state semantics |
| Watch/widget/app group | `WidgetBridge.swift`, `ReminderWidgetCoordinator.swift`, `ios/STRQWidget/*`, `ios/STRQWidget/Info.plist`, `ios/STRQWatch/*` | Shares snapshots and workout state to widgets/watch | Separate targets can break with unrelated iOS UI edits | Document and later separately scope visual passes | Change app group `group.app.rork.40gfu7dywfru7n82xfoy4`, snapshot key, widget kind strings, watch bundle linkage |
| Tests and QA harnesses | `ios/STRQTests/STRQTests.swift`, `AdaptiveResponseQAHarness.swift`, `PlanQAHarness.swift`, `ios/STRQUITests/*` | Protects persistence, active workout, progression, RevenueCat fallback, cloud restore, environment validation | Tests encode contracts that UI migration must preserve | Add UI snapshot tests in future | Weaken/remove tests, change expected behavior to fit UI migration |

## Screen-Specific Protection

These production screens are not to be modified in this planning pass:

- `DashboardView`
- `ContentView`
- `ActiveWorkoutView`
- `ExerciseDetailView`
- `ExerciseLibraryView`
- `ProgressAnalyticsView`
- `STRQPaywallView`
- `ProfileView`, except not touching the existing debug route
- Onboarding views
- `WorkoutCompletionView`
- Coach views
- Sleep/readiness views
- Watch/widget targets

## Future Approval Checklist For Any UI Implementation Pass

Before a future implementation pass touches a production screen, confirm:

| Check | Required answer |
|---|---|
| Does the pass alter any protected files? | No, or explicitly approved |
| Does the pass change action call sites? | No behavior change |
| Does the pass change `L10n` keys/catalogs? | No, unless copy/localization scope approved |
| Does the pass change analytics events? | No |
| Does the pass change persisted data or schema? | No |
| Does the pass change RevenueCat/Product IDs? | No |
| Does the pass change active workout/watch/live activity behavior? | No |
| Does the pass import assets? | Only from an approved asset plan |
