# Progress Muscle Coverage Data Contract V1

Date: 2026-05-07

## Scope

This contract populates the existing `ProgressEntry.muscleGroupVolume` path from real completed workout data. It does not integrate Progress V4 into production, redesign Progress, change navigation, change workout execution, alter plan generation, or add demo data.

## What V1 Computes

For each completed workout, STRQ derives muscle coverage from:

- completed `WorkoutSession.exerciseLogs`
- completed `SetLog` rows only
- resolved `ExerciseLibrary` metadata
- `Exercise.primaryMuscle`
- `Exercise.secondaryMuscles`

The persisted dictionary uses stable `MuscleGroup.rawValue` keys, for example:

- `chest`
- `lats`
- `triceps`
- `coreStability`
- `hamstrings`
- `lowerBack`

The existing Progress display buckets continue to aggregate these per-muscle keys into the current display groups: Chest, Back, Shoulders, Quads, Hamstrings, Glutes, Arms, and Abs.

## Contribution Unit

V1 prefers loaded volume when it is meaningful:

```text
loaded contribution = sum(completed set weight * reps)
```

If a completed exercise has zero loaded volume, V1 falls back to completed set exposure:

```text
exposure contribution = completed set count
```

This means `muscleGroupVolume` is best read as muscle coverage contribution, not pure kg volume. Weighted exercises contribute kg-style load. Bodyweight, unloaded, mobility, and similar zero-load exercises contribute exposure points so they are not treated as no training.

## Primary And Secondary Weighting

V1 applies role-based weighting:

- primary muscle: `1.0`
- secondary muscles: `0.35`

Secondary muscles are deduplicated and do not receive duplicate credit if they match the primary muscle.

## Broad Category Mapping

`ProgressMuscleCoverageCalculator` also derives broad training distribution buckets for future Progress modules:

- `push`
- `pull`
- `legs`
- `core`
- `posterior`

Simple V1 mapping:

| Muscle source | Categories |
| --- | --- |
| chest, shoulders, triceps | push |
| back, lats, traps, biceps, forearms | pull |
| arms | push, pull |
| quads, calves, adductors, abductors, hip flexors, tibialis | legs |
| hamstrings, glutes | legs, posterior |
| abs, obliques, core stability, rotation/anti-rotation | core |
| lower back | core, posterior |
| neck | no broad category in V1 |

Some muscles intentionally contribute to more than one broad category. Category totals are coverage signals, not mutually exclusive percentages.

## Confidence States

The helper defines future states for Progress V4 modules:

- locked
- baseline forming
- early signal
- readable
- high confidence

These are not production UI states in this pass. They are exposed in the calculator so future Progress V4 work can use one shared vocabulary instead of inventing view-local thresholds.

## Population Path

`WorkoutController.completeWorkout()` now calculates coverage after completed set volume is finalized and before the `ProgressEntry` is inserted:

1. Mark the active session completed.
2. Compute existing total workout volume unchanged.
3. Calculate `ProgressMuscleCoverageCalculator.calculate(for:library:)`.
4. Create `ProgressEntry` with existing total sets, reps, total volume, and duration.
5. Populate only the existing `muscleGroupVolume` field with the real per-muscle coverage dictionary.

No new persisted model field or migration is required because `ProgressEntry.muscleGroupVolume` already exists and decodes missing values as an empty dictionary.

## Missing Or Unknown Metadata

V1 fails safe:

- exercises with no completed sets contribute nothing
- unresolved exercise IDs are skipped
- unresolved exercise IDs are reported by the calculator result
- unknown future broad-category mappings do not crash
- completed workouts with no resolved completed exercises return empty coverage

No exercise metadata is modified.

## Known Caveats

- The field name is `muscleGroupVolume`, but V1 values can mix loaded volume and exposure points.
- Cross-muscle comparisons are useful as coverage signals, not precise hypertrophy attribution.
- Secondary muscle metadata is treated conservatively but remains approximate.
- Category buckets are intentionally simple and product-oriented.
- Existing Progress low-data gates still control when current Muscle Balance appears.
- Historical completed workouts are not backfilled in this pass.

## What This Is Not

This is not Progress V4 productionization. It does not:

- wire the DEBUG Progress V4 prototype into production
- add anatomy heatmaps
- add fake coverage
- change Progress navigation or layout
- change chart calculations
- change plan generation
- change analytics
- change localization
- change assets

## QA Required

Required before release confidence:

- macOS or CI build validation
- focused workout-completion QA with weighted, bodyweight, and mixed workouts
- Rork Progress QA after four or more completed workouts to confirm Muscle Balance remains appropriately gated and not overconfident
- regression check that workout completion, HealthKit save, persistence, and analytics still run in the same order

## Remaining V4 Work

Future Progress V4 production work still needs:

- module-level confidence thresholds wired into real UI states
- read-only weekly and 4-week distribution adapters
- recent evidence event builder
- copy and localization strategy for confidence states
- optional historical backfill or snapshot strategy, if replay becomes scoped
