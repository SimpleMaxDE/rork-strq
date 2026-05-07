# Progress V4 Real Data Contract Audit

Date: 2026-05-07
Mode: Licensed Source Mode
Scope: docs-only static audit. No Swift, asset, project, localization, test, model, service, controller, widget, watch, live activity, or runtime behavior changes were made.

## 1. Executive summary

V4 production integration is not currently safe as a whole. The V4 direction is product-strong, but its signature module, Training Distribution / Muscle Coverage, does not yet have a production-safe data contract. The specific blocker is confirmed: `ProgressEntry.muscleGroupVolume` exists, is read by progress and coaching surfaces, but is not populated by the current workout completion path.

Data-ready modules:

- Weekly Rhythm is the safest first production module from existing real data. Completed sessions, dates, 7-day stats, 28-day consistency, weekly target, and recent workout history already exist.
- Volume Trend is mostly data-ready for total workout volume, weekly volume comparisons, and completed set counts.
- Strength Trend is partially data-ready from completed set/rep/weight logs and existing estimated 1RM derivation, but needs safer naming and anchor/confidence rules before V4 copy presents it as proof.

Blocked or unsafe modules:

- Muscle Coverage and per-muscle distribution are blocked for production if they depend on `ProgressEntry.muscleGroupVolume`.
- Training Distribution is partial: push/pull can be derived from movement patterns, but legs/core/posterior and per-muscle coverage need a shared mapping contract.
- Recent Evidence is partial: individual facts can be derived, but V4 needs a centralized event builder and confidence rules.
- Progress Replay, Plan Impact, and Coach + Progress Feedback Loop require new durable provenance before they should be presented as proof.

Muscle coverage is the main blocker because it is the central V4 proof metaphor and already affects adjacent signals such as muscle balance, movement balance, smart volume analysis, plan evolution muscle drift, and weekly review balance scoring.

Exactly what should happen next: choose C, fix/build the muscle coverage data contract first. Build a read-only derivation contract from completed workouts plus exercise muscle metadata before any V4 production UI uses muscle coverage, anatomy heatmaps, or coverage confidence.

## 2. Current data source inventory

| Data area | Current source | Current contract quality | Notes |
| --- | --- | --- | --- |
| Workout/session data | `WorkoutSession` in `ios/STRQ/Models/WorkoutSession.swift`; `workoutHistory` in `ios/STRQ/ViewModels/AppViewModel.swift`; completion in `ios/STRQ/Services/WorkoutController.swift` | High for completed sessions | Completed sessions include `startTime`, optional `endTime`, `isCompleted`, exercise logs, total volume, and notes. |
| Exercise data | `Exercise` in `ios/STRQ/Models/Exercise.swift`; curated library in `ios/STRQ/Services/ExerciseLibrary*.swift`; imported data in `ios/STRQ/Services/ExerciseDBProImporter.swift` | High for primary/secondary muscle metadata, medium for production coverage semantics | Exercises expose `primaryMuscle`, `secondaryMuscles`, `category`, `family`, and `movementPattern`. Mapping exists, but V4 weighting and category grouping do not. |
| Set/rep/weight data | `ExerciseLog` and `SetLog` in `WorkoutSession.swift` | High | Completed sets provide `weight`, `reps`, `isCompleted`, optional RPE/quality, and `isPR`. Current completion path marks completed sets. |
| Total volume data | `WorkoutSession.totalVolume`; `ProgressEntry.totalVolume`; `AppViewModel.weeklyStats`; `WeeklyReviewGenerator` | High for total session volume | Completion computes `weight * reps` for completed sets and stores total volume on session and progress entry. |
| Per-muscle volume data | `ProgressEntry.muscleGroupVolume`; `AppViewModel.muscleBalance`; `AppViewModel.weeklyVolumeByMuscle` | Low / blocked | The field defaults to `[:]` and is not populated by `WorkoutController.completeWorkout()`. Current muscle-balance readers therefore cannot be trusted for new completed workouts. |
| Body/recovery data | `readinessHistory`, `bodyWeightEntries`, `sleepEntries`; `HealthKitService`; `AppViewModel.recoveryScore`; `AppViewModel.recoveryTrendData` | Medium for context, low for proof | Readiness/body/sleep can support context. Recovery trend is a synthesized score and should not be used as hard proof without clear copy. |
| Streak/target data | `AppViewModel.streak`; `profile.daysPerWeek`; `AppViewModel.weeklyStats`; `ProgressAnalyticsView.consistencyHeatmap` | High for rhythm if derived directly from workouts; medium if using `streak` | `streak` counts completed workouts or readiness check-ins, so V4 workout rhythm should derive from completed workouts directly. |
| Progress entries | `ProgressEntry`; `progressEntries`; persisted in `PersistenceStore` | High for total sets/reps/volume/duration; low for muscle coverage | Completion writes total sets, reps, volume, and duration, but not bodyweight or muscle map. |
| Session history | `workoutHistory`; `SessionHistoryView`; `ProgressAnalyticsView.recentSessionsCard` | High | Recent sessions can power evidence timeline facts such as session completed, duration, sets, and volume. |
| Persistence sources | `PersistenceStore`, `SnapshotBuilder`, `CloudSyncService` references | High for existing fields | Local JSON persists workout history, progress entries, personal records, progression state, coach adjustments, body/recovery/nutrition data, and active drafts. |
| HealthKit references | `HealthKitService` | Medium, optional | Writes completed strength workouts and syncs weight/sleep. It does not provide muscle coverage data. |
| Progression/plan provenance | `ProgressionEngine`, `PlanEvolutionEngine`, `CoachActionManager`, `CoachingMemoryService`, `WeeklyReviewGenerator` | Medium | Plan and coach events exist, but not as a durable Progress causal impact model. |

## 3. V4 module contract matrix

| Module | Required data | Current availability | Source files/functions | Confidence | Missing contract | Production readiness | Risk |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Training Distribution | Push, pull, legs, core, posterior volume or set evidence by week and 4-week window | Partial | `Exercise.movementPattern`; `WeeklyReviewGenerator.computePushPullRatio`; `SmartVolumeEngine.countWeeklySetsByMuscle`; `ProgressAnalyticsView.movementBalanceData` | Medium | Shared category mapper, posterior definition, core definition, set vs volume weighting, confidence thresholds | Partial | Medium |
| Muscle Coverage | Per-muscle primary/secondary coverage, weekly and 4-week distribution, readable confidence | Blocked as persisted data; derivable as a new helper | `ProgressEntry.muscleGroupVolume`; `AppViewModel.muscleBalance`; `Exercise.primaryMuscle`; `Exercise.secondaryMuscles`; `WorkoutSession.exerciseLogs` | Low for current field, medium for future derivation | Canonical muscle mapper, primary/secondary weighting, grouping, windows, low-data states | Blocked | High |
| Weekly Rhythm | Completed dates, sessions/day, sessions/week, rolling 28-day cadence, target adherence | Available | `workoutHistory`; `weeklyStats`; `weeklyActivity`; `ProgressAnalyticsView.consistencyHeatmap`; `profile.daysPerWeek` | High | Unified target semantics and confidence thresholds | Ready | Low |
| Strength Trend | Completed set/rep/weight logs, movement anchors, repeated exposures, e1RM trend | Available with naming caveats | `AppViewModel.strengthProgress`; `AppViewModel.hasEnoughDataForStrengthChart`; `SetLog`; `Exercise.movementPattern` | Medium | Anchor taxonomy, repeated lift rules, copy that avoids literal lift overclaiming | Partial | Medium |
| Volume Trend | Session total volume, completed sets, weekly comparison windows | Available | `WorkoutController.completeWorkout`; `WorkoutSession.totalVolume`; `ProgressEntry.totalVolume`; `weeklyStats`; `WeeklyReviewGenerator` | High for total volume | Window contract, low-data gates, deload/recovery interpretation | Ready / partial | Low |
| Recent Evidence | Timeline event facts, dates, labels, confidence, no fake PRs | Partial | `workoutHistory`; `WorkoutHighlights`; `weeklyStats`; `strengthProgress`; `ProgressAnalyticsView.recentImprovementCard`; `WorkoutCompletionView.dominantFocus` | Medium | Central event builder, event priority, copy, persistence decision | Partial | Medium |
| Proof Confidence | Locked, Baseline forming, Early signal, Readable, High confidence per module | Partial | `DataMaturityTier`; `CoachingConfidence`; `hasEnoughDataForStrengthChart`; `hasTrustworthyMuscleBalance` | Medium | V4-specific thresholds and module-specific gates | Partial | Medium |
| Next Unlocks | Remaining sessions/weeks/lift anchors/muscle categories needed for readability | Partial | `sessionsUntilReviewReady`; `activationRoadmap`; target adherence counts can be derived | Medium | V4 unlock helper and copy/localization | Partial / defer | Medium |
| Progress Replay | Week snapshots of muscle, rhythm, strength, plan impact | Not available as durable replay | `workoutHistory`; `progressEntries`; `coachAdjustments` | Low | Snapshot/event history, weekly frozen summaries, copy model | Defer | High |
| Plan Impact | Before/after plan change, reason, expected result, actual outcome | Partial | `PlanEvolutionEngine`; `CoachActionManager`; `CoachAdjustment`; `CoachingMemoryService`; `previousPlanBeforeWeekAction` | Low / medium | Durable causal link from progress signal to plan change and later outcome | Defer | High |
| Coach Feedback Loop | Progress informs Coach, Coach changes plan, user sees why, Progress shows impact | Partial | `CoachingMemoryService`; `PlanEvolutionSignal`; `CoachActionManager`; `WeeklyReviewGenerator` | Low / medium | Bidirectional event contract, privacy-safe memory, outcome measurement | Defer | High |

## 4. Muscle coverage audit

### Is `ProgressEntry.muscleGroupVolume` written anywhere?

No production write path was found. `ProgressEntry.muscleGroupVolume` is defined with a default empty map and decodes missing values as `[:]`. The current workout completion path creates:

```swift
ProgressEntry(
    date: Date(),
    totalSets: workout.session.completedSetCount,
    totalReps: workout.session.completedRepCount,
    totalVolume: workout.session.totalVolume,
    workoutDuration: ...
)
```

Because no `muscleGroupVolume` argument is passed, completed workouts create progress entries with an empty muscle map.

### Is it read anywhere?

Yes. It is read by:

- `AppViewModel.muscleBalance`, which sums weekly and 4-week values by hardcoded display keys.
- `AppViewModel.weeklyVolumeByMuscle`, which sums the last 7 days of `progressEntries`.
- `ProgressAnalyticsView.muscleBalanceChart` and `movementBalanceData`, when `hasTrustworthyMuscleBalance` passes.
- `SmartVolumeEngine.analyzeBalance`, `WeeklyReviewGenerator.computeUpperLowerRatio`, and plan/coaching surfaces that consume `MuscleBalanceEntry`.

### Does workout completion compute it?

No. `WorkoutController.completeWorkout()` computes total session volume from completed sets and writes total sets/reps/volume/duration, but it does not resolve exercises, primary muscles, secondary muscles, or muscle-group volumes for the `ProgressEntry`.

### Can it be derived from completed workouts plus exercise muscle metadata?

Yes, but only after a contract is defined. The necessary raw data exists:

- Completed sessions and sets in `WorkoutSession`.
- Exercise IDs in `ExerciseLog`.
- Exercise metadata from `ExerciseLibrary.exercise(byId:)`, including `primaryMuscle`, `secondaryMuscles`, `category`, `family`, and `movementPattern`.
- Imported ExerciseDBPro normalization in `ExerciseDBProImporter`.

There are already partial derivation examples:

- `SmartVolumeEngine.countWeeklySetsByMuscle` counts completed sets by primary muscle and gives secondary muscles partial credit.
- `WorkoutCompletionView.dominantFocus` derives session focus from primary muscles.
- `WeeklyReviewGenerator.computePushPullRatio` derives push/pull volume from movement patterns.

These examples prove derivability, but they are not a shared production V4 data contract.

### What mapping would be needed?

V4 needs one canonical contract that defines:

- Muscle identity: canonical STRQ `MuscleGroup` values and display group names.
- Primary weighting: whether one completed set counts as 1.0 set, full `weight * reps`, or another load unit.
- Secondary weighting: likely 0.25 to 0.5 of primary contribution, with no integer truncation.
- Movement buckets: push, pull, legs, core, posterior.
- Posterior definition: likely glutes, hamstrings, lower back, possibly back/lats depending copy.
- Legs definition: quads, hamstrings, glutes, calves, adductors, abductors, hip flexors, tibialis.
- Core definition: abs, obliques, lower back, core stability, rotation/anti-rotation, with copy that avoids overstating stabilizers.
- Body overlay grouping: broad visual regions rather than exact anatomical heatmaps.
- Windowing: current week, last 7 days, last 28 days, and 4-week comparison.
- Confidence gates: completed sessions, repeated category exposure, exercise diversity, and minimum muscle evidence.

### Risks of primary/secondary weighting

- Double counting can make total muscle volume exceed workout volume.
- Secondary muscles vary by exercise and should not be presented with the same confidence as primary muscles.
- Existing `SmartVolumeEngine` secondary weighting uses integer division, so one-set and odd-set sessions can lose secondary contribution.
- Bodyweight, assisted, cable, machine, cardio, mobility, and Pilates exercises do not compare cleanly through `weight * reps`.
- ExerciseDBPro includes support/stabilizer muscles that may be technically true but product-misleading if treated as trained coverage.
- Some broad groups, especially back/lats/lower back and abs/core/obliques, need V1 simplification.

### What should V1 do safely?

V1 should not ship per-muscle coverage from `ProgressEntry.muscleGroupVolume`. The safe path is:

1. Build a read-only muscle coverage derivation service from completed workouts and exercise metadata.
2. Use completed-set evidence as the first unit of coverage, not exact hypertrophy volume.
3. Treat primary muscle contribution as higher confidence than secondary muscle contribution.
4. Show broad coverage states and proof confidence, not precise percentages, until validation is complete.
5. Keep anatomy visuals in locked/baseline/readable states rather than fake heatmaps.
6. Only write persisted muscle snapshots later if replay or performance requires it.

## 5. Weekly rhythm audit

Weekly Rhythm can be powered by current real data.

Current session date availability:

- Completed workout sessions include `startTime`, optional `endTime`, and `isCompleted`.
- `workoutHistory` stores completed sessions and is persisted by `PersistenceStore`.
- `weeklyStats` filters completed workouts from the last 7 days.
- `weeklyActivity` returns 7 days of train/no-train activity with volume and duration.
- `ProgressAnalyticsView.consistencyHeatmap` derives a 28-day workout consistency grid.

Weekly target availability:

- `profile.daysPerWeek` is the user target source.
- Existing UI sometimes clamps target to `min(3, daysPerWeek)` or `min(4, daysPerWeek)`, so V4 needs one explicit target contract before production copy says `0/3`, `3/3`, or similar.

Current streak logic:

- `AppViewModel.streak` counts a day if the user completed a workout or logged readiness.
- That is useful for general engagement, but not safe for a workout rhythm proof claim.
- V4 rhythm should derive workout-only streak/cadence from `workoutHistory`.

Existing 28-day consistency:

- The production progress view already renders a 28-day heatmap from completed workout dates.
- This is a reliable base for rolling cadence, rhythm visible/readable states, and weekly target adherence.

Recommended Weekly Rhythm thresholds:

- Locked: 0 completed workouts.
- Baseline forming: 1-2 completed workouts.
- Early signal: at least 3 completed workouts or 1 target-bearing week.
- Readable: at least 2 weeks with completed workouts and at least 4 total sessions.
- High confidence: at least 4 weeks observed, at least 8 completed sessions, and at least 3 target-bearing weeks.

Production conclusion: Weekly Rhythm is ready as the safest V4 production slice if it uses workout-only completed session data and conservative copy.

## 6. Strength/volume audit

### Existing Estimated 1RM data path

`AppViewModel.strengthProgress` derives estimated 1RM points from completed workout history. It resolves exercise IDs through `ExerciseLibrary`, filters completed sets, and computes:

```text
estimated 1RM = weight * (1 + reps / 30)
```

It groups anchors by movement pattern:

- Horizontal push compounds are stored in the `bench` field.
- Squat pattern compounds are stored in the `squat` field.
- Hip hinge compounds are stored in the `deadlift` field.
- Horizontal and vertical pulls are stored in the `ohp` field.

The current chart displays Bench, Squat, and Deadlift labels. This is production-risky because the data is movement-pattern based, not necessarily literal bench press, squat, or deadlift performance. The pull/OHP field also has naming mismatch risk.

### Volume chart data path

Total volume is stronger:

- `WorkoutController.completeWorkout()` computes total volume from completed sets.
- `WorkoutSession.totalVolume` stores the completed session total.
- `ProgressEntry.totalVolume` stores the same workout total at completion.
- `weeklyStats.volume`, `recentImprovementCard`, and `WeeklyReviewGenerator` compare this week versus previous windows.

### Set/rep/weight source

`SetLog` provides `weight`, `reps`, `isCompleted`, optional `rpe`, optional `quality`, and `isPR`. This is enough for:

- Completed set counts.
- Total reps.
- Total loaded volume.
- Best set per exercise.
- Estimated 1RM trend.
- Repeated anchor detection by exercise ID or movement pattern.

### PR/anchor availability

`PersonalRecord` and `SetLog.isPR` exist, but static inspection did not find a current workout completion writer that creates personal records or marks new PRs. V4 should not claim PR events from these fields until that generation path is verified or implemented.

Safe V1 anchor events can instead use:

- "Strength anchor logged" when a completed set exists for a tracked movement pattern.
- "Anchor repeated" when the same exercise or movement bucket has two or more exposures.
- "Best set improved" when current estimated 1RM exceeds prior completed evidence for the same exercise.

### Can V4 trend be powered now?

Strength Trend is partially safe. It can be powered by existing completed set data if V4 labels it as movement anchors and gates it until repeated evidence exists.

Volume Trend is safer. Total volume, sets, and session counts are production-usable now with low-data states and deload/recovery caveats.

Missing pieces:

- V4 anchor taxonomy and display names.
- Repeated lift anchor thresholds.
- PR generation contract, if PR copy is desired.
- Whether bodyweight sets, assisted sets, unloaded movements, and mobility work count toward strength/volume trend.
- Whether trends compare calendar weeks, rolling 7-day windows, or training weeks.

## 7. Recent Evidence event audit

| Event type | Can derive now? | Needs new event builder? | Needs persistence? | Safe for V1? | Notes |
| --- | --- | --- | --- | --- | --- |
| Session completed | Yes | Yes, for V4 timeline ordering/copy | No | Yes | Source from completed `WorkoutSession` date, sets, volume, duration. |
| Target met | Yes | Yes | No | Yes | Derive completed sessions in target week against `profile.daysPerWeek`; target semantics must be unified. |
| Streak maintained | Partial | Yes | No | Yes with workout-only definition | Do not use current `streak` unless copy includes readiness check-ins. |
| Lift anchor logged | Yes | Yes | No | Yes | Completed set for selected movement/exercise anchor. |
| Muscle category touched | Yes | Yes | No | Yes, primary-only V1 | Derive from primary muscles on completed exercise logs. |
| Muscle category repeated | Yes | Yes | No | Yes, primary-only V1 | Require at least two sessions or exposures in the window. |
| Coverage gap improved | Derivable later | Yes | Optional | Not yet | Requires stable muscle coverage baseline and window comparison. |
| Volume trend readable | Yes | Yes | No | Yes | Require minimum sessions and comparison window. |
| Recovery context available | Yes | Yes | No | Yes as context only | Readiness/sleep/body data can contextualize, not prove adaptation. |

Candidate V4 timeline facts:

- Upper strength anchor: derivable from completed horizontal/vertical push or pull anchor sets, but needs anchor naming.
- Lower strength anchor: derivable from squat, hinge, and lunge anchors.
- Pull focus filled: derivable from pull movement pattern or back/lats primary-muscle evidence, but requires coverage contract.
- Legs returned: derivable from lower-body primary-muscle evidence after a previous gap, but requires event builder.
- Recovery slot preserved: unsafe unless plan/rest/recovery slot semantics are defined.
- Rhythm visible: derivable now from completed session cadence.
- Trend readable: derivable now for volume and partially for strength after thresholds.
- Coverage gap closed: unsafe until muscle coverage baseline and weighting contract exist.

Production conclusion: Recent Evidence should be a computed V4 event builder, not ad hoc copy inside views. V1 can safely use session, target, rhythm, volume, and anchor facts. Muscle gap and PR facts should wait.

## 8. Proof confidence thresholds proposal

These thresholds are product/data contracts only. They are not implemented code.

### Rhythm

| State | Proposed threshold |
| --- | --- |
| Locked | 0 completed workouts. |
| Baseline forming | 1-2 completed workouts. |
| Early signal | 3 completed workouts or 1 completed target-bearing week. |
| Readable | At least 2 weeks with workouts and at least 4 total completed sessions. |
| High confidence | At least 4 observed weeks, at least 8 completed sessions, and at least 3 weeks with target evidence. |

### Strength

| State | Proposed threshold |
| --- | --- |
| Locked | No completed weighted/reppable anchor sets. |
| Baseline forming | 1 anchor exposure in any tracked movement bucket. |
| Early signal | 2 anchor exposures in one movement bucket or 3 total anchor sessions. |
| Readable | 2 repeated exposures for at least 2 movement buckets across at least 2 weeks. |
| High confidence | 4+ weeks, 3+ repeated exposures in at least 2 movement buckets, and no missing weight/rep ambiguity for displayed anchors. |

### Volume

| State | Proposed threshold |
| --- | --- |
| Locked | 0 completed workouts. |
| Baseline forming | 1 completed workout with completed sets. |
| Early signal | 2 completed workouts with total volume. |
| Readable | At least 2 comparison weeks or at least 4 sessions. |
| High confidence | 4 weeks and at least 8 sessions, with enough context to identify spikes, deloads, and target adherence. |

### Muscle coverage

| State | Proposed threshold |
| --- | --- |
| Locked | No completed workout muscle derivation contract, or 0 completed exercises with resolved primary muscles. |
| Baseline forming | 1-2 completed sessions with at least 2 resolved primary muscle groups. |
| Early signal | 3+ sessions, at least 3 major categories touched, primary-only coverage allowed. |
| Readable | 4+ sessions over at least 2 weeks, push/pull/legs/core/posterior contract available, and repeated evidence for displayed gaps. |
| High confidence | 4+ weeks, at least 8 sessions, repeated evidence in all displayed categories, secondary weighting contract validated, and low unresolved-exercise rate. |

### Recovery/body context

| State | Proposed threshold |
| --- | --- |
| Locked | No readiness, sleep, bodyweight, or recovery-relevant inputs. |
| Baseline forming | 1-2 readiness or sleep/body entries. |
| Early signal | 3+ entries across at least one week. |
| Readable | 2+ weeks of context data with recent workout overlap. |
| High confidence | 4+ weeks of consistent context data and explicit copy that separates recovery context from training proof. |

## 9. Production integration readiness

Safe first production module:

- Weekly Rhythm is safe to implement first from completed workouts, workout dates, target days per week, and 28-day cadence.

Unsafe modules:

- Muscle Coverage from `ProgressEntry.muscleGroupVolume`.
- Per-muscle heatmaps or exact coverage percentages.
- PR timeline events from `PersonalRecord` or `SetLog.isPR` until the write path is proven.
- Plan impact proof that claims Coach changed the plan because Progress proved an outcome.

Docs-only needed:

- None required before starting the next implementation step. The key data blocker is clear enough.

Model/service/controller changes needed later:

- A shared muscle coverage derivation service or contract type.
- A canonical mapping from `MuscleGroup` and movement patterns to push/pull/legs/core/posterior.
- A confidence evaluator for V4 modules.
- A recent evidence event builder.
- Optional persisted weekly snapshots only if Progress Replay or performance requires them.
- Optional PR generation/anchor service if V4 wants to call out PRs.
- Optional plan-impact event model linking signals, coach actions, and later outcomes.

View-only possible:

- Weekly Rhythm can be view-only using existing `workoutHistory`.
- Total Volume Trend can be view-only using existing `WorkoutSession.totalVolume` and `weeklyStats`.
- Strength Trend can be view-only if renamed to movement anchors and gated by repeated evidence.

Feature-flag recommendation:

- Keep V4 production modules behind a feature flag or debug/remote flag until each module is powered by real data contracts.
- Do not let local `ProgressV4DemoData` or prototype copy enter production paths.
- Introduce module-level confidence gates so locked/baseline states are data-driven, not hardcoded optimism.

## 10. Risks and guardrails

| Risk | Guardrail |
| --- | --- |
| Fake precision | Prefer states, ranges, and "evidence" language over exact muscle percentages until validated. |
| Wrong muscle mapping | Centralize muscle/category mapping and audit ExerciseDBPro/imported labels. |
| Misleading confidence | Use module-specific thresholds; do not reuse generic coaching confidence for V4 proof. |
| Low data overclaiming | Locked and baseline states must be first-class UI states. |
| Stale demo data | Keep `ProgressV4HybridCandidateView` DEBUG-only and never bridge demo arrays to app models. |
| Prototype copy leaking to production | Require production copy to reference real data source and confidence state. |
| Workout logic risk | Do not change completion behavior until derivation contract and backward compatibility are clear. |
| Persistence risk | Prefer read-only derivation first; persist snapshots later only with migration plan. |
| Localization risk | Next Unlocks and confidence copy will need localized strings before production. |
| Accessibility risk | Do not rely on color/heat alone for muscle coverage; include labels and states. |
| Performance risk | Derive coverage over bounded windows first, cache only if profiling shows need. |

## 11. Recommended immediate next step

Choose exactly one: C. fix/build muscle coverage data contract first.

Why: the audit confirms that `ProgressEntry.muscleGroupVolume` is not populated by workout completion, while Muscle Coverage is the signature V4 module and a dependency for training distribution, movement balance, coverage confidence, several evidence events, smart volume analysis, and future plan-impact explanations. Weekly Rhythm and total Volume Trend are safer, but shipping them first would leave the central V4 promise unresolved and could encourage a production shell around a blocked proof surface.

The next step should build the muscle coverage contract as a read-only derivation from completed workouts and exercise metadata. It should not wire V4 production UI, write new persisted progress fields, or modify workout completion behavior until the contract is reviewed.

## 12. Exactly one next prompt

Use this prompt for the next implementation pass:

```text
Use Licensed Source Mode.

Goal:
Fix/build the Progress muscle coverage data contract first, as a production-safe read-only derivation layer. Do not wire Progress V4 UI to production yet.

Target:
- Create a shared service/helper that derives muscle coverage from completed `WorkoutSession` data plus `ExerciseLibrary` metadata.
- It must support primary muscle coverage, secondary muscle contribution, push/pull/legs/core/posterior buckets, weekly and 4-week windows, unresolved exercise reporting, and confidence inputs.
- Prefer completed-set evidence for V1. Do not present exact hypertrophy precision.
- Keep `ProgressEntry.muscleGroupVolume` untouched unless a migration and write contract are explicitly justified.

Allowed edits:
- A new narrowly scoped service/model file for the read-only muscle coverage contract.
- Minimal AppViewModel read-only computed access only if needed by existing architecture.
- Focused tests if a suitable test target already exists.
- `docs/migration-progress-log.md`.

Forbidden edits:
- Do not edit Progress V4 production UI.
- Do not edit `ProgressV4HybridCandidateView.swift`.
- Do not edit assets, `Assets.xcassets`, `project.pbxproj`, localization, Widget, Watch, Live Activity, fonts, unrelated analytics, or unrelated models/services/controllers.
- Do not change workout completion behavior, persistence schema, HealthKit behavior, plan generation, coach actions, or runtime behavior outside the new read-only derivation.
- Do not use demo data.

Behavior protection:
- Existing Progress screens must behave the same unless explicitly wired through existing read-only values.
- No fake muscle coverage, fake confidence, fake PRs, or prototype copy.
- Unknown or unmapped exercises must lower confidence rather than being silently ignored.
- Keep all states safe for users with low data.

Verification:
- git status --short --branch
- git diff --name-only
- rg -n "muscleGroupVolume|MuscleCoverage|primaryMuscle|secondaryMuscles|posterior|push|pull|legs|core" ios/STRQ
- git diff --check
- Do not claim Xcode/xcodebuild validation in this Windows environment.

Push command after successful verification:
git status --short --branch
git add <changed files>
git commit -m "feat: add progress muscle coverage contract"
git push
```
