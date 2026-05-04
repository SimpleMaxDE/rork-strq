# CoachTab Risk Plan

## 1. Executive summary

CoachTab is a high-value STRQ differentiation surface. It is where readiness, training state, coaching memory, comeback guidance, weekly review, and next-session handoff can make STRQ feel like an intelligent training coach rather than a generic feed.

It should feel like an intelligent training coach, not a generic feed. The screen needs to communicate a clear next decision, why that decision is appropriate, and which supporting signals matter today.

CoachTab is behavior-heavy and must not be broadly redesigned first. It touches readiness submission, workout handoff, weekly review generation, comeback adjustment application, coaching history, recommendation actions, analytics, and preference-driven density/emphasis filtering.

This pass makes no Swift changes. It only documents the current behavior, visual risk, and safe planning path.

Future implementation must start with a small display-only shell, not action logic. Do not begin with `coachPrimaryCTA`, workout handoff, weekly review actions, readiness submit behavior, More Signals action cards, or progression-affecting recommendation flows.

## 2. Current implementation inventory

### Main `CoachTabView`

`CoachTabView` is a `ScrollView` with a vertical stack:

- `authorityHero`
- early-state branch: `earlyStateCard` and optional `calibrationChecklist`
- established branch: optional `ComebackCard` and `decisionStack`
- optional `PhaseOutlookCard`
- `recentChangeBridge`
- `weeklyCheckInRow`

The screen uses `.navigationTitle("Coach")`, `.navigationBarTitleDisplayMode(.large)`, and `Color(.systemBackground)`.

On appear, it animates `appeared`, copies `vm.appliedActionIds.count` into `lastAppliedCount`, and tracks `Analytics.shared.track(.coach_viewed)`.

It observes `vm.appliedActionIds.count`; if the new count is greater than the old count, it shows an applied adjustment toast through `.strqToast($toast)`.

### State variables

Top-level `CoachTabView` state:

- `appeared: Bool` - drives entrance opacity/offset and recovery ring animation.
- `expandedInsightIds: Set<String>` - declared at top level but expansion for More Signals is owned by `MoreSignalsSheet`; this top-level state is currently unused.
- `expandedRecIds: Set<String>` - declared at top level but expansion for More Signals is owned by `MoreSignalsSheet`; this top-level state is currently unused.
- `showWeeklyReview: Bool` - controls the weekly review sheet.
- `showReadinessCheckIn: Bool` - controls the readiness check-in sheet.
- `showMoreSignals: Bool` - controls the More Signals sheet.
- `showCoachingHistory: Bool` - controls the Coaching History sheet.
- `showWatchDetails: Bool` - expands/collapses the watch-card detail text.
- `toast: STRQToast?` - rendered by `.strqToast($toast)`.
- `lastAppliedCount: Int` - set on appear and on applied-action count changes; currently not used as the comparison source.

Nested `MoreSignalsSheet` state:

- `expandedInsightIds: Set<String>` - controls expansion of secondary insight cards.
- `expandedRecIds: Set<String>` - controls expansion of secondary recommendation cards.

### `authorityHero`

Inputs:

- `vm.effectiveRecoveryScore`
- `ForgeTheme.recoveryColor(for: score)`
- `vm.currentPhase`
- `vm.readinessBasedRecoveryStatus`
- `headline`
- `vm.trainingPhaseState.weeksInPhase`
- `vm.hasCheckedInToday`
- `appeared`
- `reduceMotion`

Behavior:

- Shows a recovery/readiness ring with `STRQCountUpText`.
- Shows the current phase chip and week count.
- If `!vm.hasCheckedInToday`, shows a compact `Check in` chip button that sets `showReadinessCheckIn = true`.

Visual system:

- Uses `ForgeTheme.recoveryColor`.
- Uses `STRQBrand.steel`.
- Uses `STRQBrand.accentGradient` for the check-in chip background.
- Uses `STRQBrand.accentGradient` as a top overlay stripe.
- Uses a local dark gradient `[Color(white: 0.14), Color(white: 0.09)]`.

### `headline`

Priority order:

- `vm.dailyBriefing?.primary.title`
- `vm.earlyStateGuidance?.headline`
- `vm.nextBestAction?.title`
- fallback: `You're on plan. Stay the course.`

This means CoachTab hero copy depends on daily briefing first, then early-state guidance, then progression next-best-action.

### `earlyStateCard`

Rendered only when `vm.isEarlyStage` and `vm.earlyStateGuidance` exists.

Inputs:

- `vm.earlyStateGuidance`
- `vm.dataMaturityTier`
- `coachEarlyStateMessage`

Visual system:

- Uses `STRQBrand.accentGradient` as a leading mini bar.
- Uses `STRQBrand.steel` and `STRQBrand.steelGradient`.
- Uses local grouped card styling.

### `coachEarlyStateMessage`

Maps `vm.dataMaturityTier`:

- `.fresh`: baseline/start guidance
- `.firstSession`: baseline set guidance
- `.earlyWeek`: more real training data guidance
- `.established`: fallback "You're on plan. Stay the course."

### `calibrationChecklist`

Rendered only in the early-state branch when `shouldShowCalibrationChecklist` is true.

`shouldShowCalibrationChecklist` is `vm.dataMaturityTier != .firstSession`; therefore it currently appears for `.fresh` and `.earlyWeek`, and is hidden for `.firstSession`.

Checklist inputs:

- `vm.currentPlan != nil`
- `vm.totalCompletedWorkouts >= 1`
- `vm.hasCheckedInToday || vm.todaysReadiness != nil`
- `vm.weeklyStats.sessions >= 1`

Visual system:

- Uses `ForgeSectionHeader`.
- Uses `STRQPalette.success` for completed checkmarks.
- Uses `STRQBrand.steel.opacity(0.55)` for incomplete circles.
- Uses `STRQBrand.cardBorder`.

### `decisionStack`

Rendered only in the established branch when `vm.dailyBriefing` exists.

Inputs:

- `vm.dailyBriefing`
- `vm.profile.coachingPreferences.density`
- `vm.profile.coachingPreferences.density.sideSignalsLimit`
- `vm.profile.coachingPreferences.emphasis`
- `vm.coachingConfidence`

Behavior:

- Always renders `primaryMoveCard(briefing.primary)`.
- Renders `watchCard` when `briefing.watch != nil && sideLimit >= 1`.
- Renders `momentumCard` when `briefing.momentum != nil`, the density side-signal limit permits it, and emphasis is not `.simplicity`.
- Renders More Signals button when `briefing.moreSignalsCount > 0 && density != .focused`; tapping sets `showMoreSignals = true`.
- Renders `liftTrackerSection` only when `vm.coachingConfidence >= .moderate`.

Preference effect:

- `CoachingDensity.sideSignalsLimit` directly changes Watch/Momentum visibility.
- `CoachingEmphasis.simplicity` suppresses the Momentum card.
- Focused density suppresses the More Signals entry.

### `primaryMoveCard`

Input:

- `DailyBriefing.Primary`
- `ForgeTheme.color(for: primary.colorName)`
- `vm.dailyBriefing?.sinceLast`

Behavior:

- Renders `COACH RECOMMENDS`, primary icon/title/detail, `coachPrimaryCTA`, and optional since-last result bridge.

Visual system:

- Uses `ForgeTheme.color(for:)`; when `primary.colorName == "orange"`, this maps to `STRQPalette.energyAccent`.
- Uses `STRQPalette.success` and `STRQPalette.successSoft` for since-last positive icon.
- Uses a local gradient card background from grouped surface to tint opacity.

### `coachPrimaryCTA`

This is action logic and should not be an early visual migration target.

Switches on `DailyBriefing.Primary.kind`:

- `.checkInBeforeTraining`: `ForgePrimaryButton` sets `showReadinessCheckIn = true`.
- `.startFirstSession`: if `vm.todaysWorkout ?? vm.nextWorkout` exists, `ForgePrimaryButton` calls `vm.prepareWorkoutHandoff(day:)`.
- `.resumeWorkout`: if `vm.todaysWorkout` exists, `ForgePrimaryButton` calls `vm.prepareWorkoutHandoff(day:)`.
- `.trainToday` / `.recoverToday`: if `vm.todaysWorkout` exists, `ForgePrimaryButton` calls `vm.prepareWorkoutHandoff(day:)`.
- default: `EmptyView()`.

Visual system:

- Uses `ForgePrimaryButton`, which uses `STRQBrand.accentGradient` and `STRQPalette.energyAccent` shadowing through Forge.

### `watchCard`

Input:

- `DailyBriefing.Watch`
- `ForgeTheme.color(for: watch.colorName)`
- `showWatchDetails`

Behavior:

- Details button toggles `showWatchDetails` inside a reduce-motion-aware animation.
- No analytics are tracked for watch expand/collapse.

Visual system:

- Uses `ForgeTheme.color(for:)`.
- Uses local grouped card background and `STRQBrand.cardBorder`.

### `momentumCard`

Input:

- `DailyBriefing.Momentum`

Visual system:

- Uses `STRQPalette.success` and `STRQPalette.successSoft`.
- Uses local grouped card background and `STRQBrand.cardBorder`.

### `liftTrackerSection`

Rendered inside `decisionStack` only when `vm.coachingConfidence >= .moderate`, and only if there are stalled or progressing states.

Inputs:

- `vm.stalledExercises.prefix(2)`
- `vm.progressingExercises.prefix(2)`
- `vm.library.exercise(byId:)`
- `ExerciseProgressionState.plateauStatus`
- `ExerciseProgressionState.suggestedNextWeight`
- `ExerciseProgressionState.recommendedStrategy`

Visual system:

- Uses `ForgeSectionHeader`.
- Uses `STRQPalette.danger` for regressing stalled rows.
- Uses `STRQPalette.warning` for non-regressing stalled rows.
- Uses `STRQPalette.success` for progressing rows.

### `recentChangeBridge`

Builds a coaching-memory timeline through `CoachingMemoryService().buildTimeline(...)` with `limit: 1`.

Inputs:

- `vm.coachAdjustments`
- `vm.trainingPhaseState`
- `vm.planEvolutionSignals`
- `vm.phaseOutlook`
- `vm.physiqueOutcome`
- `vm.weekAdjustmentActive`
- `vm.profile.nutritionTrackingEnabled`

Behavior:

- If a latest timeline entry exists, renders `CoachMemoryBridgeRow` in a button.
- Tapping latest-entry row sets `showCoachingHistory = true` and tracks `Analytics.shared.track(.coach_viewed, ["surface": "memory_bridge"])`.
- If no latest entry exists and `!vm.isEarlyStage`, renders an empty Coaching Memory button that sets `showCoachingHistory = true` with no bridge analytics.
- If no latest entry exists and `vm.isEarlyStage`, renders nothing.

`totalMemoryCount` separately builds the timeline with `limit: 30`.

### `weeklyCheckInRow`

Inputs:

- `vm.isEarlyStage`
- `vm.planQuality`
- `vm.isWeeklyReviewReady`
- `vm.sessionsUntilReviewReady`

Behavior:

- If established and `vm.planQuality` exists, renders `planQualityRow`.
- If `vm.isWeeklyReviewReady`, renders a button that calls `vm.generateWeeklyReview()` then sets `showWeeklyReview = true`.
- If early stage, renders a disabled-looking `weeklyReviewLabel` with sessions-until-ready copy and no button.
- If established but not weekly-ready, still renders a button that calls `vm.generateWeeklyReview()` then sets `showWeeklyReview = true`.

Important analytics note:

- `AppViewModel.openWeeklyReview()` tracks `.weekly_review_opened`, but CoachTab currently does not call it. CoachTab calls `vm.generateWeeklyReview()` directly and sets local sheet state. Do not switch to `openWeeklyReview()` unless analytics changes are explicitly scoped.

### `planQualityRow`

Input:

- `PlanQualityScore`
- `ForgeTheme.color(for: quality.overallColor)`

Visual system:

- Uses grouped card styling.
- Uses a semantic score badge based on `quality.overallColor`.

### Sheets

Top-level CoachTab sheets:

- `$showWeeklyReview`: renders `WeeklyCheckInView(vm: vm, review: review)` only if `vm.weeklyReview` exists.
- `$showReadinessCheckIn`: renders `ReadinessCheckInView(vm: vm)` and passes `vm.submitReadiness(readiness)` as `onComplete`.
- `$showMoreSignals`: renders `NavigationStack { MoreSignalsSheet(vm: vm) }` with large detent, visible drag indicator, and scrolls presentation interaction.
- `$showCoachingHistory`: renders `NavigationStack { CoachingHistoryView(vm: vm) }` with large detent, visible drag indicator, and scrolls presentation interaction.

Nested sheets from `MoreSignalsSheet` content:

- `ExpandableInsightCard` and `ExpandableRecommendationCard` can present `SwapExerciseSheet`, `WeekRegenerationSheet`, and `DeloadWeekSheet` through their own local state.
- These nested cards can mutate plan state and analytics through `AppViewModel` action methods.

There is no Watch Details sheet; `showWatchDetails` is inline expand/collapse state.

### `MoreSignalsSheet`

Inputs:

- `vm.highPriorityInsights.dropFirst()`
- `vm.recommendations.dropFirst(vm.highPriorityInsights.isEmpty ? 1 : 0)`

Behavior:

- Secondary insights render as `ExpandableInsightCard`.
- Secondary recommendations render as `ExpandableRecommendationCard`.
- Empty state renders "Nothing else to flag".
- Done toolbar button dismisses the sheet.

Action warning:

- Even though the More Signals entry can look like secondary display content, its expandable cards are action-capable. They can apply volume reduction, lighter sessions, swaps, week regeneration, deload, undo adjustments, and insert IDs into `vm.appliedActionIds`.

### Button actions in or directly launched by CoachTab

Direct `CoachTabView` buttons:

- Authority hero Check in chip: `showReadinessCheckIn = true`.
- Comeback "Ease next workout": tracks `.comeback_cta_tapped` with action `ease`, then calls `vm.applyComebackLighterSession()`.
- Comeback "Check in": tracks `.comeback_cta_tapped` with action `checkin`, then sets `showReadinessCheckIn = true`.
- More Signals row: `showMoreSignals = true`.
- `coachPrimaryCTA` Check in: `showReadinessCheckIn = true`.
- `coachPrimaryCTA` Start Workout 1 / Resume Workout / Start Workout / Start Light Workout: `vm.prepareWorkoutHandoff(day:)`.
- Watch details: toggles `showWatchDetails`.
- Coaching memory latest row: `showCoachingHistory = true`; tracks `.coach_viewed` surface `memory_bridge`.
- Coaching memory empty row: `showCoachingHistory = true`; no analytics.
- Weekly Check-In ready/established row: `vm.generateWeeklyReview()` then `showWeeklyReview = true`.

Buttons inside top-level sheets:

- `MoreSignalsSheet` Done: dismiss.
- `CoachingHistoryView` Done: dismiss; the history view tracks `.coach_viewed` surface `memory` on appear.
- `ReadinessCheckInView` close/back/continue/result controls: local step/result state until final result button calls `onComplete(readiness)` and dismisses.
- `WeeklyCheckInView` close button: dismiss only.
- `WeeklyCheckInView` action rows: set `selectedAction`, show confirmation; confirmation calls `vm.applyReviewAction(selected)`.

Action-capable buttons inside `ExpandableInsightCard` / `ExpandableRecommendationCard`:

- Reduce volume: `vm.applyVolumeReduction(dayId:preview:)`, sets local `actionApplied`, inserts current insight/recommendation ID into `vm.appliedActionIds`.
- Swap exercise: opens `SwapExerciseSheet`; selection calls `vm.applyExerciseSwap(...)`, sets local `actionApplied`, inserts ID.
- Lighter session: `vm.applyLighterSession(dayId:)`, sets local `actionApplied`, inserts ID.
- Regenerate week: gets `vm.previewWeekRegeneration()`, opens `WeekRegenerationSheet`, confirmation calls `vm.applyWeekRegeneration()`, sets local `actionApplied`, inserts ID.
- Deload: gets `vm.previewDeloadWeek()`, opens `DeloadWeekSheet`, confirmation calls `vm.applyDeloadWeek()`, sets local `actionApplied`, inserts ID.
- Undo: `vm.undoAdjustment(adj)`, clears local `actionApplied`, removes ID from `vm.appliedActionIds`.
- Default action types: set local `actionApplied`, insert ID into `vm.appliedActionIds`, then call `onAction(action)`. In `MoreSignalsSheet`, `onAction` is currently `{ _ in }`.

### Analytics events and payloads

Directly in `CoachTabView`:

- `Analytics.shared.track(.coach_viewed)` on CoachTab appear. Payload is empty before Analytics adds environment.
- `Analytics.shared.track(.comeback_card_viewed, ["tier": comeback.tier.rawValue, "days_since": String(comeback.daysSinceLastWorkout), "surface": "coach"])` when the comeback card appears.
- `Analytics.shared.track(.comeback_cta_tapped, ["action": "ease", "tier": comeback.tier.rawValue, "surface": "coach"])` before `vm.applyComebackLighterSession()`.
- `Analytics.shared.track(.comeback_cta_tapped, ["action": "checkin", "tier": comeback.tier.rawValue, "surface": "coach"])` before opening readiness check-in from comeback.
- `Analytics.shared.track(.coach_viewed, ["surface": "memory_bridge"])` when the latest coaching memory bridge is tapped.

In views directly presented from CoachTab:

- `CoachingHistoryView` tracks `Analytics.shared.track(.coach_viewed, ["surface": "memory"])` on appear.
- `WeeklyCheckInView` does not track on appear.
- `ReadinessCheckInView` does not track on appear; final submission is tracked by `vm.submitReadiness`.
- `MoreSignalsSheet` does not track on appear.

In `AppViewModel` paths triggered by CoachTab:

- `vm.submitReadiness(_:)` tracks `.readiness_logged` with `["score": String(readiness.readinessScore), "bucket": readinessBucket]`, then computes coach response, refreshes daily state, and persists through `defer`.
- `vm.applyComebackLighterSession()` calls `applyLighterSession(dayId:)`, which tracks `.coach_action_applied` with `["type": "lighter_session", "day_id": dayId]`; then it tracks `.comeback_ease_applied` with `["tier": lapseTier.rawValue, "days_since": String(retentionSignals.daysSinceLastWorkout)]`.
- `vm.generateWeeklyReview()` itself does not track analytics.
- `vm.applyReviewAction(_:)` tracks `.weekly_review_action_applied` with `["type": String(describing: action.type)]`; depending on action, it may also call week/action methods that track `.coach_action_applied`.
- `vm.applyVolumeReduction(dayId:preview:)` tracks `.coach_action_applied` with `["type": "volume_reduced", "day_id": dayId]`.
- `vm.applyLighterSession(dayId:)` tracks `.coach_action_applied` with `["type": "lighter_session", "day_id": dayId]`.
- `vm.applyExerciseSwap(dayId:oldExerciseId:newExercise:)` tracks `.coach_action_applied` with `["type": "exercise_swapped", "day_id": dayId, "old": oldExerciseId, "new": newExercise.id]`.
- `vm.applyWeekRegeneration()` tracks `.coach_action_applied` with `["type": "week_regenerated"]`.
- `vm.applyDeloadWeek()` tracks `.coach_action_applied` with `["type": "deload_week"]`.
- `vm.undoAdjustment(_:)` tracks `.coach_action_undone` with `["type": String(describing: adjustment.type)]`.

Important current analytics gap:

- CoachTab weekly review row uses `generateWeeklyReview()` and local sheet state. It does not track `.weekly_review_opened`, even though `AppViewModel.openWeeklyReview()` exists and does. Preserve this unless explicitly scoped.

### Workout handoff actions

Current CoachTab handoff calls are all through `vm.prepareWorkoutHandoff(day:)`.

`prepareWorkoutHandoff(day:)` behavior:

- If `activeWorkout != nil`, set `workoutMinimized = false`, `showPreWorkoutHandoff = false`, `handoffDay = nil`, and return.
- Otherwise, set `handoffDay = day` and `showPreWorkoutHandoff = true`.

This is protected because the visible Coach CTA may resume an existing workout or open the pre-workout handoff rather than starting a session immediately.

### Weekly review actions

CoachTab opening behavior:

- The row calls `vm.generateWeeklyReview()`.
- Then it sets `showWeeklyReview = true`.
- The sheet renders only if `vm.weeklyReview` exists.

Inside `WeeklyCheckInView`:

- Action rows open a confirmation dialog.
- Confirmed action calls `vm.applyReviewAction(selected)`.
- `applyReviewAction` tracks `.weekly_review_action_applied`, executes the selected action, dismisses the weekly review, persists dismissal, and refreshes coaching insights.

### Coaching history actions

CoachTab opens coaching history from:

- latest `recentChangeBridge` entry: opens and tracks `coach_viewed` surface `memory_bridge`
- empty established memory row: opens without bridge analytics

`CoachingHistoryView` is read-only and builds a timeline using `CoachingMemoryService`. It tracks `coach_viewed` surface `memory` on appear.

### Daily briefing source

`vm.dailyBriefing` is assigned by `DailyStateCoordinator.refreshBriefing()`.

Key inputs include:

- plan/onboarding/active-workout state
- today/next workout names and focus
- readiness and pain state
- effective recovery score
- streak and weekly completion
- last completed session verdict
- top insight and top momentum
- missing weight/sleep days
- total insights and recommendations count
- hour of day
- `vm.isEarlyStage`
- coaching preference tone
- coaching preference emphasis

`DailyBriefingEngine` resolves the primary move, watch, momentum, since-last bridge, rest prep, and more-signal count. `CoachTabView` then applies density and emphasis display filtering on top.

### Forge/STRQBrand/STRQPalette/STRQColors usage

In `CoachTabView`:

- Uses `ForgeTheme.recoveryColor(for:)`.
- Uses `ForgeTheme.color(for:)`.
- Uses `ForgePrimaryButton`.
- Uses `ForgeSectionHeader`.
- Uses `STRQBrand.accentGradient`, `steel`, `steelGradient`, and `cardBorder`.
- Uses `STRQPalette.success`, `successSoft`, `warning`, and `danger`.
- Does not directly use `STRQColors`.
- Does not directly call `STRQPalette.energyAccent`, but `ForgeTheme.color(for: "orange")`, `STRQBrand.accentGradient`, and `ForgePrimaryButton` route orange/energy-accent styling into this screen.

In directly related Coach surfaces:

- `ComebackCard` uses `ForgeTheme.color(for:)`, `STRQBrand.steelGradient`, and `STRQBrand.accentGradient` for "Ease next workout".
- `PhaseOutlookCard` uses `STRQBrand.accentGradient` for a leading bar and progress track.
- `CoachingHistoryView` uses `STRQPalette.color(for:)`, `STRQPalette.soft(for:)`, `STRQBrand.steel`, `STRQBrand.steelGradient`, and `STRQBrand.cardBorder`.
- `ExpandableInsightCard` / `ExpandableRecommendationCard` use STRQ semantic colors and can render action buttons with accent-colored backgrounds.

### Orange/accent-gradient usage

Orange/accent-gradient usage remains present in and around CoachTab:

- `authorityHero` check-in chip background uses `STRQBrand.accentGradient`.
- `authorityHero` top overlay stripe uses `STRQBrand.accentGradient`.
- `earlyStateCard` leading mini bar uses `STRQBrand.accentGradient`.
- `coachPrimaryCTA` uses `ForgePrimaryButton`, which uses `STRQBrand.accentGradient` and `STRQPalette.energyAccent` shadowing.
- `primaryMoveCard` can become orange when `primary.colorName == "orange"` through `ForgeTheme.color(for:)`.
- `ComebackCard` "Ease next workout" uses `STRQBrand.accentGradient`.
- `PhaseOutlookCard` uses `STRQBrand.accentGradient` for its leading accent and progress track.

### Readiness/recovery colors

- `authorityHero` uses `ForgeTheme.recoveryColor(for: vm.effectiveRecoveryScore)`.
- `ForgeTheme.recoveryColor` maps through `STRQPalette.recovery(for:)`.
- `STRQPalette.recovery(for:)` returns success for 80+, warning for 60..<80, and danger below 60.
- `ReadinessCheckInView` uses its own readiness/soreness color mapping and accent-gradient CTA; do not touch in a CoachTab visual shell pass.
- `liftTrackerSection` uses danger/warning/success for progression state.

## 3. Protected behavior map

| UI/action | Protected call/state | Current trigger | Risk if changed | Must preserve | Notes |
|---|---|---|---|---|---|
| Coach tab onAppear analytics | `Analytics.shared.track(.coach_viewed)` | CoachTab appears | Event stream loses Coach surface views or gains unintended payloads | Yes | Payload is currently empty before Analytics adds `env`. |
| Coach tab entrance state | `appeared = true` with reduce-motion-aware animation | CoachTab appears | Hero/ring/cards may animate incorrectly or ignore Reduce Motion | Yes | Visual-only work can adjust shell later, but should not remove Reduce Motion handling casually. |
| Applied count baseline | `lastAppliedCount = vm.appliedActionIds.count` | CoachTab appears | Applied toast timing can regress | Yes | `lastAppliedCount` is currently not the comparison source, but it is existing state and should not be removed in visual work. |
| Applied adjustment toast | `.onChange(of: vm.appliedActionIds.count)`, `toast = STRQToast(...)` when `new > old` | Any action inserts a new applied ID | User loses feedback after plan adjustment or sees false positives | Yes | Applies to More Signals and other action-card flows. |
| Readiness check-in sheet opening from hero | `showReadinessCheckIn = true` | Tap hero Check in chip when not checked in today | User loses quick readiness route | Yes | No analytics currently tracked for this specific tap. |
| Readiness check-in sheet opening from primary CTA | `showReadinessCheckIn = true` | Tap `coachPrimaryCTA` for `.checkInBeforeTraining` | Training-day readiness flow breaks | Yes | Uses `ForgePrimaryButton`. |
| Readiness check-in sheet opening from comeback | `Analytics.shared.track(.comeback_cta_tapped, ["action": "checkin", "tier": ..., "surface": "coach"])`, then `showReadinessCheckIn = true` | Tap Comeback Check in | Comeback analytics or readiness route changes | Yes | Only available when `!vm.hasCheckedInToday`. |
| Readiness submit behavior | `ReadinessCheckInView` final result button calls `onComplete(readiness)`; CoachTab passes `vm.submitReadiness(readiness)` | Tap final "Done" / "See today's plan" in readiness result | Readiness may be submitted too early, not persisted, or not refresh daily state | Yes | `vm.submitReadiness` tracks, stores, generates coach response, refreshes daily state, and persists. |
| Readiness analytics payload | `.readiness_logged` with `score` and `bucket` | `vm.submitReadiness` | Analytics contract changes | Yes | Bucket uses current `readinessBucket` after storing today's readiness. |
| Weekly review generation and sheet | `vm.generateWeeklyReview(); showWeeklyReview = true` | Tap weekly row when ready or established | Sheet may open with nil review or event stream may change | Yes | Current CoachTab does not call `vm.openWeeklyReview()`. |
| Weekly review early-state locked row | No button; `weeklyReviewLabel(..., ready: false).opacity(0.7)` | Early-stage user | Early users may access review before enough data | Yes | Copy depends on `vm.sessionsUntilReviewReady`. |
| Weekly review sheet content | `$showWeeklyReview` sheet renders only if `vm.weeklyReview` exists | Local sheet state true | Empty/broken sheet if review generation changes | Yes | Preserve `if let review = vm.weeklyReview`. |
| Weekly review actions | `vm.applyReviewAction(selected)` after confirmation | Confirm action in `WeeklyCheckInView` | Plan changes, dismissal, persistence, and analytics can regress | Yes | Tracks `.weekly_review_action_applied`; may call plan-changing coach actions. |
| Workout handoff - start first session | `vm.prepareWorkoutHandoff(day: vm.todaysWorkout ?? vm.nextWorkout)` | Primary kind `.startFirstSession` | First workout may bypass handoff or start wrong day | Yes | Do not start workout directly from CoachTab. |
| Workout handoff - resume | `vm.prepareWorkoutHandoff(day: vm.todaysWorkout)` | Primary kind `.resumeWorkout` | Active workout unminimize behavior may break | Yes | `prepareWorkoutHandoff` has active-workout special case. |
| Workout handoff - train/recover today | `vm.prepareWorkoutHandoff(day: vm.todaysWorkout)` | Primary kind `.trainToday` or `.recoverToday` | Start Light Workout / Start Workout can point at wrong flow | Yes | Do not alter day selection or call order. |
| Comeback lighter session action | Track `.comeback_cta_tapped` action `ease`, then `vm.applyComebackLighterSession()` | Tap Comeback Ease next workout | Lighter-session application, toast, memory, and analytics can regress | Yes | `applyComebackLighterSession` also tracks `.comeback_ease_applied` after `applyLighterSession`. |
| Comeback card viewed analytics | `.comeback_card_viewed` with `tier`, `days_since`, `surface` | Comeback card appears | Retention analytics changes | Yes | Trigger is card `.onAppear`. |
| Comeback check-in action | Track `.comeback_cta_tapped` action `checkin`, then open readiness sheet | Tap comeback Check in | Check-in route or retention analytics changes | Yes | Hidden when already checked in today. |
| More Signals sheet opening | `showMoreSignals = true` | Tap More Signals row | Secondary signals become inaccessible | Yes | No analytics currently tracked for this tap. |
| More Signals visibility | `briefing.moreSignalsCount > 0 && density != .focused` | `decisionStack` render | Focused density preference can be ignored | Yes | More Signals is preference-sensitive. |
| More Signals insight expansion | `MoreSignalsSheet.expandedInsightIds` binding | Tap expandable insight card | Secondary details/actions may not expand | Yes | Top-level `CoachTabView.expandedInsightIds` is not used here. |
| More Signals recommendation expansion | `MoreSignalsSheet.expandedRecIds` binding | Tap expandable recommendation card | Recommendation details/actions may not expand | Yes | Do not merge with top-level state without scope. |
| More Signals action cards | `ExpandableInsightCard` / `ExpandableRecommendationCard` call `vm.apply*`, open nested sheets, insert/remove `vm.appliedActionIds` | Tap action buttons inside More Signals | Plan mutation, undo, toast, and analytics can regress | Yes | This is action/progression flow, not display-only. |
| Coaching history sheet opening from latest bridge | `showCoachingHistory = true`; track `.coach_viewed` surface `memory_bridge` | Tap latest memory bridge row | History route or bridge analytics changes | Yes | Latest row exists when timeline limit 1 returns an entry. |
| Coaching history sheet opening from empty row | `showCoachingHistory = true` | Tap empty established memory row | History route becomes inaccessible for established users with no changes | Yes | No bridge analytics currently tracked. |
| Coaching history viewed analytics | `CoachingHistoryView.onAppear` tracks `.coach_viewed` with surface `memory` | History sheet appears | Memory views disappear from analytics | Yes | This is outside `CoachTabView.swift` but directly presented by CoachTab. |
| Watch details expand/collapse | `showWatchDetails.toggle()` inside animation | Tap Details in watch card | Detail text can get stuck or ignore Reduce Motion | Yes | No analytics currently tracked. |
| Watch card visibility | `briefing.watch != nil && sideLimit >= 1` | `decisionStack` render | Density preference can be ignored | Yes | Watch is first side signal. |
| Momentum visibility | `briefing.momentum != nil && sideLimit >= (showWatch ? 2 : 1) && emphasis != .simplicity` | `decisionStack` render | Density/emphasis preference effects can regress | Yes | Simplicity currently suppresses momentum. |
| Daily briefing primary | `vm.dailyBriefing.primary` | `decisionStack` render and hero headline | Coach decision can become stale or unrelated to daily state | Yes | Built by `DailyStateCoordinator.refreshBriefing()`. |
| Daily briefing density/emphasis filtering | `vm.profile.coachingPreferences.density.sideSignalsLimit`; `emphasis != .simplicity` | `decisionStack` render | CoachingPreferences effects stop affecting CoachTab | Yes | Directly connects accepted CoachingPreferences to CoachTab. |
| Daily briefing tone/emphasis generation | `DailyStateCoordinator` maps coaching preference tone/emphasis into `DailyBriefingInput` | `vm.refreshDailyState()` | Coach voice and emphasis become inconsistent with preferences | Yes | Do not bypass daily-state refresh path. |
| Early-state branch | `if vm.isEarlyStage` | CoachTab body render | New users may see advanced decisions too early | Yes | Established branch, comeback, and decision stack are skipped for early users. |
| Early-state card | `vm.earlyStateGuidance`; `coachEarlyStateMessage` | `vm.isEarlyStage` | Calibration messaging can misstate readiness of Coach | Yes | Data maturity tier drives copy. |
| Calibration checklist | `shouldShowCalibrationChecklist`; checklist inputs from plan/workout/readiness/week state | Early-stage branch | User may see wrong calibration completion state | Yes | Hidden for `.firstSession`. |
| Phase outlook visibility | `!vm.isEarlyStage && vm.phaseOutlook != nil` | CoachTab body render | Long-term block context appears too early or disappears for established users | Yes | `PhaseOutlookCard` is display-only but shared with Train. |
| Lift tracker display conditions | `vm.coachingConfidence >= .moderate`; non-empty stalled/progressing prefixes | `decisionStack` render | Low-signal users may see overconfident lift analysis | Yes | This is trust-critical. |
| Lift tracker row semantics | regressing -> danger; stalled -> warning; progressing -> success | Lift tracker rows | Training signal colors mislead users | Yes | Semantic colors are behavior-adjacent. |
| Recent change bridge timeline | `CoachingMemoryService().buildTimeline(... limit: 1)` | CoachTab body render | Memory bridge may stop reflecting latest coach state | Yes | Inputs include adjustments, phase, evolution, physique, active week adjustment. |
| Total memory count | `buildTimeline(... limit: 30).count` | Latest memory bridge row | Count can misrepresent history | Yes | Keep separate from display limit. |
| All direct CoachTab analytics payloads | `coach_viewed`, `comeback_card_viewed`, `comeback_cta_tapped`, bridge `coach_viewed` | Appears/taps | Analytics regressions or accidental new events | Yes | Preserve event names and payload keys unless explicitly scoped. |
| AppViewModel action analytics from Coach surfaces | `coach_action_applied`, `coach_action_undone`, `weekly_review_action_applied`, `readiness_logged`, `comeback_ease_applied` | Sheet/action flows launched from CoachTab | Downstream analytics contract changes | Yes | Do not touch in visual work. |
| Copy/localization | Existing `L10n.tr` and hardcoded strings in inspected surfaces | Render and actions | Localization diffs or owner copy changes sneak into visual work | Yes | Copy changes require explicit scope. |

## 4. Current visual diagnosis

CoachTab has strong product value but mixed visual systems. It already contains differentiated STRQ ideas: daily briefing, readiness-aware primary decisions, comeback guidance, calibration, phase outlook, coaching memory, and lift tracking. The problem is not lack of product substance; it is that the visual language has not yet caught up to the intelligence.

Orange/accent gradients still appear in `authorityHero`, the check-in chip, the early-state card, and primary CTA areas. They also flow indirectly through `ForgePrimaryButton`, `ForgeTheme.color(for: "orange")`, `ComebackCard`, and `PhaseOutlookCard`.

Some cards still use Forge/local grouped styles: `ForgePrimaryButton`, `ForgeSectionHeader`, local `Color(.secondarySystemGroupedBackground)` card shells, local gradient cards, `STRQBrand.cardBorder`, and mixed STRQBrand/STRQPalette semantics.

It likely feels more like a mixed dashboard/feed than a premium coach surface. The screen contains many cards with similar weight: hero, comeback, primary decision, watch, momentum, phase outlook, recent change bridge, plan quality, weekly review, and optional More Signals. That can make the next decision feel less singular than it should.

The current screen has high action density and should not be broadly rewritten. Several modules are not passive display: primary CTA, comeback CTA, weekly review, More Signals recommendation actions, and readiness submission can mutate training state or persistence.

Visual work should begin with display-only modules. The safest candidates are read-only shells after state screenshots prove which one is visible and valuable. Do not begin with action buttons.

## 5. Product goal for CoachTab

CoachTab should communicate:

- intelligent coaching
- one clear next decision
- trust in the reasoning behind that decision
- readiness awareness
- training reasoning, not generic motivation
- calm confidence
- a sense that STRQ is learning from the user's real training
- enough supporting context to feel earned, but not a noisy feed

CoachTab should not communicate:

- a gamified reward board
- a generic notification feed
- an orange CTA screen
- a random analytics dashboard
- a collection of unrelated cards
- overconfident coaching before sufficient data exists

The ideal CoachTab hierarchy:

- primary decision first
- reason and readiness state second
- supporting signals third
- history/explainability available but quiet
- action/progression flows protected until explicitly scoped

## 6. What must not change

Protect:

- workout start/resume/handoff behavior
- `vm.prepareWorkoutHandoff(day:)` and its active-workout special case
- readiness sheet route and readiness submit behavior
- `vm.submitReadiness(_:)` storage, analytics, daily-state refresh, coach response, and persistence
- weekly review generation
- weekly review sheet route
- weekly review action confirmation and `vm.applyReviewAction(_:)`
- comeback apply/check-in behavior
- `vm.applyComebackLighterSession()`
- More Signals sheet route
- More Signals expansion state and action-card behavior
- Coaching History sheet route
- Coaching Memory timeline inputs and limits
- Watch Details inline expand/collapse
- applied adjustment toast behavior
- analytics events and payloads
- daily briefing logic
- density and emphasis preference effects
- lift tracker visibility and row logic
- active workout, persistence, progression, and plan mutation paths
- copy/localization unless explicitly scoped

Do not touch:

- Active Workout behavior
- workout controller behavior
- pre-workout handoff behavior
- progression engines
- persistence
- DailyStateCoordinator
- CoachingMemoryService
- Notification services
- Models
- Services
- Analytics files
- STRQ design-system files
- assets, fonts, localization, project files, tests, Watch, Widget, or Live Activity

## 7. Visual redesign direction

Recommended direction:

- Start with display-only planning.
- Do not touch `coachPrimaryCTA` early.
- Do not touch workout handoff buttons early.
- Do not touch readiness submit, weekly review actions, or More Signals action cards early.
- Avoid broad orange replacement in one pass.
- Define CoachTab semantic accents separately from Pro, Health, Streak, and Notification colors.
- Prefer dark/carbon card shells with restrained borders and hierarchy.
- Keep coaching hierarchy: primary decision first, supporting signals second.
- Reduce feed clutter gradually.
- Avoid a full-screen rewrite.
- Treat `ForgePrimaryButton`, `STRQBrand.accentGradient`, and `ForgeTheme.color(for: "orange")` as known debt, not as immediate mass-replacement targets.

Possible future CoachTab semantic accent direction:

- Coach intelligence: muted steel blue or graphite-blue, distinct from Notification Coach Nudges.
- Readiness/recovery: semantic recovery scale, but less neon and not generic green/yellow/red decoration.
- Training decision: neutral/white/graphite-first primary hierarchy.
- Warning/protection: deliberate caution tone, not orange CTA energy.
- History/explainability: quiet steel/graphite, not primary action color.

Implementation guardrail:

- First Swift pass, when approved, should migrate one small display-only shell while preserving all bindings, actions, analytics, copy, and sheet routes.
- Any module that contains a button should be treated as action-adjacent even if the desired change is visual.

## 8. State coverage requirements

Before any Swift visual implementation, CoachTab needs state coverage for:

- early-stage user with zero completed workouts
- early-stage user after first session
- early-week user before established state
- established user
- comeback guidance absent
- comeback guidance `.pause` with no lighter session
- comeback guidance `.extendedBreak` or `.longAbsence` with lighter session
- readiness checked in today
- readiness not checked in today
- daily briefing exists
- daily briefing absent
- primary move `.checkInBeforeTraining`
- primary move `.startFirstSession`
- primary move `.resumeWorkout`
- primary move `.trainToday`
- primary move `.recoverToday`
- primary move rest-day kinds with no CTA
- Watch details collapsed
- Watch details expanded
- More Signals available
- More Signals hidden by focused density
- Momentum visible
- Momentum hidden by simplicity emphasis
- weekly review ready
- weekly review not ready but established
- weekly review locked/disabled in early stage
- lift tracker visible
- lift tracker hidden for low coaching confidence
- lift tracker hidden with no stalled/progressing states
- applied adjustment toast visible
- Coaching Memory latest entry state
- Coaching Memory empty established state
- small iPhone viewport
- large iPhone viewport
- Reduce Motion on, if possible
- Reduce Motion off

Rork QA should capture at least the key visible combinations before selecting a first Swift target. Static inspection cannot prove hierarchy, clipping, button wrapping, or whether the surface reads like a coach instead of a feed.

## 9. Risk rating

| Risk area | Rating | Reason |
|---|---:|---|
| Behavior risk | High | CoachTab opens readiness, weekly review, More Signals actions, coaching history, comeback actions, and workout handoff. |
| Training-flow risk | High | Primary CTAs and More Signals actions can affect workout start/resume, plan adjustments, deloads, lighter sessions, and swaps. |
| Product trust risk | High | Early-state calibration, lift tracker confidence, readiness state, and coach reasoning can overpromise if visual hierarchy changes carelessly. |
| Visual risk | Medium/High | Current screen has mixed Forge/local/STRQBrand/STRQPalette styling and visible orange/accent debt, but broad replacement would be risky. |
| Owner approval need | High | Any Swift implementation should be owner-approved with screenshots/states and exact target scope. |

Overall risk: High for implementation, Low for this docs-only pass.

## 10. Recommended implementation phases

1. Plan completed.
2. Choose one display-only candidate after screenshots/states are available.
3. Migrate one display-only shell only.
4. Run Rork QA on the exact states affected by that shell.
5. Plan one action-adjacent card only after behavior mapping and owner approval.
6. Defer CTA/action migration.
7. Defer Active Workout, handoff, progression, plan mutation, More Signals action cards, weekly review actions, and readiness submission changes.

Suggested display-only candidate classes, in order of safety after screenshots:

- read-only phase/context module
- coaching memory row shell if route/action is preserved
- noninteractive plan-quality display
- watch/momentum shell only after density/emphasis states are captured

Avoid first:

- `coachPrimaryCTA`
- `ForgePrimaryButton`
- workout handoff buttons
- comeback "Ease next workout"
- readiness submit
- weekly review action row
- `ExpandableInsightCard` / `ExpandableRecommendationCard` action buttons

## 11. Exactly one recommended next implementation prompt

Chosen option: E. no implementation; require CoachTab screenshots/states first.

Reason: CoachTab has too many behavior-critical states to select a first Swift target responsibly from static code alone. The next pass should capture and document representative CoachTab states, then choose one display-only candidate. This keeps the project from starting with action logic or a broad CoachTab rewrite.

Use this exact prompt next:

```text
Work in repo: C:\Users\maxwa\Documents\GitHub\rork-strq

Goal:
Create a docs-only CoachTab screenshot/state inventory before any Swift implementation. Use static inspection plus owner/Rork screenshots if available to choose one future display-only CoachTab shell candidate. Do not implement Swift.

Exact target file:
- docs/coach-tab-state-inventory.md

Exact target section/helper:
- CoachTab state coverage and display-only candidate selection for ios/STRQ/Views/CoachTabView.swift

Allowed edits:
- Create docs/coach-tab-state-inventory.md
- Append one concise entry to docs/migration-progress-log.md

Forbidden edits:
- Any Swift file
- ios/STRQ/Views/CoachTabView.swift
- ios/STRQ/Views/DashboardView.swift
- ios/STRQ/Views/TrainingPlanView.swift
- ios/STRQ/Views/ActiveWorkoutView.swift
- ios/STRQ/Views/ReadinessCheckInView.swift
- ios/STRQ/Views/WeeklyCheckInView.swift
- ios/STRQ/ViewModels/AppViewModel.swift
- ios/STRQ/Services
- ios/STRQ/Models
- ios/STRQ/Utilities/STRQDesignSystem.swift
- ios/STRQ/Utilities/STRQPalette.swift
- ios/STRQ/Utilities/ForgeTheme.swift
- Assets.xcassets
- Localizable.xcstrings
- RevenueCat/store files
- Watch files
- Widget files
- Live Activity files
- project.pbxproj
- tests
- fonts

Behavior preservation list:
- No workout start/resume/handoff behavior changes.
- No readiness submit behavior changes.
- No weekly review generation or action changes.
- No comeback apply/check-in behavior changes.
- No sheet route changes.
- No toast behavior changes.
- No analytics event or payload changes.
- No daily briefing, density, emphasis, early-state, lift tracker, coaching memory, progression, persistence, or active-workout changes.
- No copy/localization changes.

Visual objective:
- Identify which current CoachTab states look most like a mixed dashboard/feed.
- Identify one future display-only shell candidate that can move CoachTab toward a calm, premium, intelligent coach surface without touching action logic.
- Do not recommend a full-screen rewrite.
- Do not recommend starting with `coachPrimaryCTA`, workout handoff, readiness submit, weekly review actions, comeback apply actions, or More Signals action cards.

Verification commands:
- git status --short --branch
- git diff --name-only
- git diff -- docs/coach-tab-state-inventory.md docs/migration-progress-log.md
- git diff --name-only -- ios/STRQ ios/STRQWidget ios/STRQWatch
- rg -n "CoachTab State Inventory|early-stage|established|comeback|readiness|weekly review|workout handoff|display-only|Rork" docs/coach-tab-state-inventory.md

Rork QA checklist:
- Capture or request screenshots for early-stage, established, comeback, readiness checked-in/not checked-in, daily briefing present/absent, watch collapsed/expanded, weekly review ready/not ready, lift tracker visible/hidden, applied toast, small iPhone, and large iPhone.
- Note which screenshots are missing.
- Do not claim Rork QA is complete unless screenshots were actually reviewed.

Report-back format:
1. Files changed
2. States inventoried
3. Screenshots available/missing
4. Display-only candidate selected
5. Behavior protected
6. Verification results
7. Rork QA required/completed

Push command after successful verification:
git status --short --branch
git add docs/coach-tab-state-inventory.md docs/migration-progress-log.md
git commit -m "docs: add coach tab state inventory"
git push
```

This is the only recommended next prompt in this report.

## 12. Rork QA checklist

- [ ] CoachTab early-stage zero-workout state.
- [ ] CoachTab first-session state.
- [ ] CoachTab early-week state.
- [ ] CoachTab established state.
- [ ] Comeback card absent.
- [ ] Comeback card present without lighter-session CTA.
- [ ] Comeback card present with lighter-session CTA.
- [ ] Readiness not checked in: hero check-in chip visible.
- [ ] Readiness checked in: hero check-in chip hidden.
- [ ] Readiness sheet opens from hero.
- [ ] Readiness sheet opens from primary CTA.
- [ ] Readiness sheet opens from comeback Check in.
- [ ] Readiness submit stores state, dismisses, and updates CoachTab.
- [ ] Primary move check-in-before-training state.
- [ ] Primary move first-session state.
- [ ] Primary move resume-workout state.
- [ ] Primary move train-today state.
- [ ] Primary move recover-today/light-workout state.
- [ ] Workout handoff still opens or resumes exactly as before.
- [ ] Watch card collapsed.
- [ ] Watch card expanded.
- [ ] Momentum visible when density/emphasis allow it.
- [ ] Momentum hidden for simplicity emphasis.
- [ ] More Signals hidden for focused density.
- [ ] More Signals opens when available.
- [ ] More Signals expandable insight card expands/collapses.
- [ ] More Signals expandable recommendation card expands/collapses.
- [ ] More Signals action buttons are not tested on real data unless owner approves disposable/safe state.
- [ ] Lift tracker visible with moderate/high coaching confidence and real signal.
- [ ] Lift tracker hidden for low coaching confidence.
- [ ] Phase outlook visible for established users when available.
- [ ] Phase outlook hidden for early-stage users.
- [ ] Coaching memory latest bridge opens history.
- [ ] Coaching memory empty established row opens history.
- [ ] Coaching history Done dismisses.
- [ ] Weekly review locked/disabled for early-stage state.
- [ ] Weekly review ready opens sheet.
- [ ] Weekly review established/not-ready behavior remains as current.
- [ ] Weekly review action confirmation appears, but do not apply plan-changing actions unless owner approves safe test data.
- [ ] Applied adjustment toast appears after a safe applied action.
- [ ] Small iPhone layout has no clipping or text collisions.
- [ ] Large iPhone layout preserves hierarchy and does not feel like a loose feed.
- [ ] Reduce Motion on, if possible.
- [ ] Reduce Motion off.
- [ ] No new orange CTA dominance is introduced.
- [ ] No broad CoachTab rewrite is recommended or performed.
