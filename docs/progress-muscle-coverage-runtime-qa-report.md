# Progress Muscle Coverage Runtime QA Report

Date: 2026-05-08

## 1. Executive summary

Runtime QA is blocked in this workspace because the local environment is Windows PowerShell and does not provide `xcodebuild`, `xcrun`, Swift, an iOS simulator, or the `rork` CLI. No disposable simulator data state could be prepared locally.

Static review plus GitHub Actions evidence did not find a code bug in the Progress Muscle Coverage Data Contract V1 path. `WorkoutController.completeWorkout()` populates `ProgressEntry.muscleGroupVolume`, the calculator persists per-muscle keys only, and production Muscle Balance remains gated. This is not a runtime pass, so the release-readiness classification is blocked until macOS/Rork simulator QA completes.

## 2. Environment / build status

- Local workspace: `C:\Users\maxwa\Documents\GitHub\rork-strq`
- Local shell: Windows PowerShell
- Branch: `main`
- Head: `dcf9ac9 ci: enable STRQTests scheme action`
- Preflight working tree: clean before docs edits
- `rork.json`: app `STRQ`, path `ios`, framework `swift`
- Local runtime tooling: `xcodebuild`, `xcrun`, `swift`, and `rork` were not available
- iOS Build: success on full SHA `dcf9ac94a984a2c97888d9919192cbbf9df05eae`, run `25570802185`, Xcode 16.4, macOS 15.7.4
- iOS Tests: success on full SHA `dcf9ac94a984a2c97888d9919192cbbf9df05eae`, run `25570824557`, Xcode 16.4, iPhone 16 simulator
- Progress V4 remains DEBUG-only: `ProfileView` exposes the Design System Lab under `#if DEBUG`, and V4 candidate files remain under `ios/STRQ/Views/Debug`

## 3. Test status summary

The focused CI run passed the required calculator tests:

- `ProgressMuscleCoverageCalculatorTests/unresolvedExerciseIsSkippedSafely()`
- `ProgressMuscleCoverageCalculatorTests/unloadedExerciseFallsBackToSetExposure()`
- `ProgressMuscleCoverageCalculatorTests/weightedExerciseUsesLoadedVolumeWithSecondaryWeight()`

The app build also passed on the same head commit. Local test execution was not possible because the Windows workspace has no Swift/Xcode toolchain.

## 4. Runtime scenarios tested

No real Rork/simulator runtime scenarios were executed locally. The following items were reviewed from code and CI evidence only:

- weighted calculator semantics
- bodyweight / zero-load exposure fallback semantics
- mixed-workout calculator loop safety
- `completeWorkout()` population of `ProgressEntry.muscleGroupVolume`
- low-data and 4+ Muscle Balance gating
- production Progress labels and DEBUG-only V4 containment

## 5. Weighted workout result

Runtime status: not executed.

Code and CI evidence: weighted completed sets use loaded contribution `weight * reps`. The focused weighted test verifies Bench Press style coverage as `chest = 1000`, secondary `triceps = 350`, secondary `shoulders = 350`, and loaded exercise count `1`.

Completion-path evidence: `WorkoutController.completeWorkout()` computes existing `session.totalVolume` unchanged, then calculates coverage and writes the per-muscle dictionary into `ProgressEntry.muscleGroupVolume`.

## 6. Bodyweight workout result

Runtime status: not executed.

Code and CI evidence: completed exercises with zero loaded volume use completed-set exposure fallback. The focused bodyweight test verifies Push-up style coverage as primary `chest = 3` and secondary `triceps`, `shoulders`, and `coreStability = 1.05` each for three completed unloaded sets.

Copy risk: existing total workout volume remains kg-style load and can remain `0` for bodyweight-only work. The coverage field is not directly shown as kg in Muscle Balance rows, but current labels still use "volume" language.

## 7. Mixed workout result

Runtime status: not executed.

Static result: the calculator loops each exercise log independently, so a loaded exercise can use loaded volume while a zero-load exercise in the same session uses exposure fallback. No dedicated mixed runtime scenario or mixed unit test was run in this pass.

## 8. 1-workout Progress result

Runtime status: not executed.

Static result: with one completed workout, `ProgressAnalyticsView.volumeSignals` uses the Volume Signals baseline card because `totalCompletedWorkouts < 2`. Muscle Balance is not shown as confident data.

Expected behavior remains: no missing-baseline `-100%` Muscle Balance rows, no fake conclusions, and no V4 production surface.

## 9. 3-workout Progress result

Runtime status: not executed.

Static result: with three completed workouts, `hasTrustworthyMuscleBalance` remains false because it requires `totalCompletedWorkouts >= 4`. The view shows the Muscle Balance baseline card rather than the chart.

Expected behavior remains: no confident Muscle Balance read, no missing-baseline `-100%` rows, and no fake conclusions.

## 10. 4+ workout Progress result

Runtime status: not executed.

Static result: with four or more completed workouts, Muscle Balance may appear only when current volume and comparison average are both greater than zero. Chart rows are filtered to `average > 0`.

Muscle Balance row labels come from `ProgressMuscleCoverageCalculator.progressDisplayMuscleNames`: Chest, Back, Shoulders, Quads, Hamstrings, Glutes, Arms, and Abs. The persisted data path does not write broad bucket keys. A separate existing `Movement Balance` card can show Push, Pull, Legs, and Core labels when Muscle Balance is trusted; see Data-shape / label findings.

## 11. Muscle Balance behavior

Production Muscle Balance behavior remains conservative in static review:

- display gate: `totalCompletedWorkouts >= 4`
- display gate: current Muscle Balance volume sum `> 0`
- display gate: comparison average volume sum `> 0`
- row filter: `vm.muscleBalance.filter { $0.average > 0 }`
- zero-average rows return `percentOfAverage = 0` and are filtered out of the chart

No concrete Muscle Balance runtime bug was confirmed because runtime QA could not be executed.

## 12. Data-shape / label findings

Data-shape finding: `ProgressEntry.muscleGroupVolume` stores per-muscle `MuscleGroup.rawValue` keys only. The calculator also returns broad bucket data in `broadCategoryVolume`, but `WorkoutController.completeWorkout()` does not persist those broad buckets.

Label finding: Muscle Balance rows use understandable display labels: Chest, Back, Shoulders, Quads, Hamstrings, Glutes, Arms, and Abs. Broad bucket labels do not appear as Muscle Balance row labels.

Potential acceptance caveat: the existing production `Movement Balance` card can display Push, Pull, Legs, and Core labels. Static review indicates those labels are derived from current display muscles, not from persisted broad bucket keys, and `posterior` is not shown. If the acceptance criterion means no broad bucket words anywhere in production UI, this should be treated as a pre-existing production Progress label issue and resolved in a scoped follow-up.

## 13. Unit semantics / copy risk

The current UI wording around "volume" is acceptable for a blocked runtime report but carries product-copy risk. `muscleGroupVolume` now mixes loaded kg-style contribution for weighted exercises with set-exposure points for bodyweight or unloaded exercises.

Users could misunderstand coverage/exposure as exact kg muscle volume if future UI makes the value explicit. A future copy pass should clarify this as coverage, exposure, or training contribution rather than precise muscle volume.

## 14. Bugs found and fixes made, if any

No code bugs were confirmed and no Swift fixes were made.

Blocked runtime finding: real weighted, bodyweight, mixed, low-data, 4+ workout, and unresolved-metadata scenarios were not executed in Rork/simulator because the local environment lacks the required iOS runtime tooling.

## 15. Remaining blockers

- Run real Rork/simulator QA on macOS or another environment with Xcode and simulator access.
- Use a disposable simulator state only; do not reset or corrupt non-disposable user data.
- Complete weighted, bodyweight, mixed, 1-workout, 3-workout, 4+ workout, Progress UI, and safe unresolved-metadata checks.
- Decide whether the existing Movement Balance Push/Pull/Legs/Core labels conflict with the no broad bucket labels acceptance criterion.

## 16. Release-readiness classification

blocked: GitHub Actions build/tests are green and static review did not find a data-contract bug, but runtime QA was not executed. This is not ready to call pass or pass with caveats until real Rork/simulator scenarios are completed.

## 17. Recommended next step

Run the same QA prompt from a macOS/Rork simulator-capable environment and record real app observations for weighted, bodyweight, mixed, low-data, and 4+ workout states. Keep Progress V4 DEBUG-only and make no product/UI changes unless that runtime pass finds a concrete bug.
