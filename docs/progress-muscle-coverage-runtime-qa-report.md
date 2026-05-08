# Progress Muscle Coverage Runtime QA Report

Date: 2026-05-08

## 1. Executive summary

Release-readiness classification: blocked.

This pass attempted to run real macOS/Rork simulator QA for Progress Muscle Coverage Data Contract V1 from the current Codex workspace. The runtime pass is still blocked here because the workspace is Windows PowerShell and does not expose macOS simulator controls, XcodeBuildMCP tools, `xcodebuild`, `xcrun simctl`, Swift, or a `rork` CLI. No disposable simulator state could be created or inspected, and no non-disposable user data was accessed.

Preflight is otherwise healthy: the working tree was clean before edits, `main` includes `dcf9ac9 ci: enable STRQTests scheme action` and `bc2356c docs: validate progress muscle coverage runtime`, the latest iOS Build passed on `bc2356c`, and the focused iOS Tests workflow also passed on `bc2356c`.

No runtime observations are claimed in this report. Each scenario below records the exact blocker plus the static/CI evidence available. No Swift bug was confirmed, no code fix was made, and Progress V4 remains DEBUG-only.

## 2. Runtime environment

- Local workspace: `C:\Users\maxwa\Documents\GitHub\rork-strq`
- Local shell: Windows PowerShell
- Branch at preflight: `main`
- Head at preflight: `bc2356cc8c0683aad94910b3047dbeab3a3e362a`
- Required commits present:
  - `bc2356c docs: validate progress muscle coverage runtime`
  - `dcf9ac9 ci: enable STRQTests scheme action`
- Preflight working tree: clean before docs edits
- `rork.json`: app `STRQ`, path `ios`, framework `swift`
- Local runtime tooling: `xcodebuild`, `xcrun`, `simctl`, Swift, `rork`, and `rork-cli` were not available
- XcodeBuildMCP simulator tools: not exposed in this tool session
- Disposable simulator data: not created because no simulator/Rork runtime was available
- Non-disposable user data: not accessed
- iOS Build: passed on `bc2356cc8c0683aad94910b3047dbeab3a3e362a`, run `25571693952`
- iOS Tests: passed on `bc2356cc8c0683aad94910b3047dbeab3a3e362a`, run `25572288082`
- V4 remains DEBUG-only: Progress V4 candidate files remain under `ios/STRQ/Views/Debug`, and production Progress was not wired to V4

## 3. Weighted workout result

Runtime status: blocked, not executed.

Exact blocker: the local environment has no macOS simulator, Rork runtime, XcodeBuildMCP simulator tools, `xcodebuild`, or `simctl`, so a disposable Bench Press or loaded workout could not be created or completed.

Static/CI evidence only: `ProgressMuscleCoverageCalculatorTests/weightedExerciseUsesLoadedVolumeWithSecondaryWeight()` verifies loaded sets contribute `weight * reps`, with Bench Press style coverage of `chest = 1000`, `triceps = 350`, `shoulders = 350`, and `push = 1700` in the calculator result. `WorkoutController.completeWorkout()` writes only `muscleCoverage.muscleGroupVolume` into `ProgressEntry.muscleGroupVolume`.

Unverified runtime checks: workout completion, crash-free Progress opening, total volume reasonableness, inspectable muscle coverage population, Muscle Balance labels, and absence of missing-baseline `-100%` rows.

## 4. Bodyweight workout result

Runtime status: blocked, not executed.

Exact blocker: the local environment could not create or complete a disposable Push-up, Pull-up, bodyweight squat, or other zero-load simulator workout.

Static/CI evidence only: `ProgressMuscleCoverageCalculatorTests/unloadedExerciseFallsBackToSetExposure()` verifies zero-load completed sets use exposure points instead of disappearing from coverage. The Push-up style fixture produces `chest = 3`, secondary `triceps = 1.05`, `shoulders = 1.05`, `coreStability = 1.05`, `push = 5.1`, and `core = 1.05`.

Unverified runtime checks: exposure fallback safety in the actual completion flow, Progress opening after a bodyweight-only workout, UI wording clarity, and Muscle Balance low-data gating.

## 5. Mixed workout result

Runtime status: blocked, not executed.

Exact blocker: the local environment could not create a disposable workout containing one loaded movement and one zero-load movement.

Static evidence only: the calculator evaluates each exercise log independently. A loaded exercise uses loaded volume when its completed sets have positive load, while a zero-load exercise in the same session uses completed-set exposure fallback. This supports coexistence in the same session, but the mixed path has not been runtime-observed in Rork/simulator.

Unverified runtime checks: no crash after mixed completion, Progress opening, understandable Muscle Balance state, and absence of visible double-counting.

## 6. 1-workout Progress result

Runtime status: blocked, not executed.

Exact blocker: no disposable simulator data state could be prepared with exactly one completed workout.

Static evidence only: `ProgressAnalyticsView.volumeSignals` shows the Volume Signals baseline card when `vm.totalCompletedWorkouts < 2`. Muscle Balance is not presented as confident comparison data in that path.

Expected but unverified runtime behavior: no fake conclusions, no missing-baseline `-100%` rows, no crash or blank Progress state, and no production-visible V4 prototype data.

## 7. 3-workout Progress result

Runtime status: blocked, not executed.

Exact blocker: no disposable simulator data state could be prepared with exactly three completed workouts.

Static evidence only: `hasTrustworthyMuscleBalance` requires `vm.totalCompletedWorkouts >= 4`, current Muscle Balance volume `> 0`, and comparison average volume `> 0`. At three workouts, production Progress should show the Muscle Balance baseline-forming card rather than confident comparison rows.

Expected but unverified runtime behavior: no fake conclusions and no missing-baseline `-100%` rows.

## 8. 4+ workout Progress result

Runtime status: blocked, not executed.

Exact blocker: no disposable simulator data state could be prepared or inspected with four or more completed workouts.

Static evidence only: after four or more completed workouts, Muscle Balance may appear only when both current and comparison data exist. The Muscle Balance chart filters rows with `vm.muscleBalance.filter { $0.average > 0 }`, so muscles without a real comparison baseline should not render as misleading `-100%` regressions.

Expected but unverified runtime behavior: rows should show understandable per-muscle labels only, no broad bucket labels as Muscle Balance rows, no crash, and no blank state.

## 9. Progress UI result

Runtime status: blocked, not executed.

Exact blocker: the existing Progress UI could not be opened in Rork/simulator from this workspace.

Static evidence only: production `ProgressAnalyticsView` still owns the Strength, Body, Volume, Muscle Balance, Movement Balance, and Recent Workouts sections. The DEBUG Progress V4 candidate remains isolated under `ios/STRQ/Views/Debug` and was not productionized.

Unverified runtime checks: Strength, Body, Volume, Muscle Balance, Movement Balance, and Recent Workouts loading without blank/crash states; no demo/prototype data appearing in production Progress.

## 10. Muscle Balance behavior

Runtime status: blocked, not executed.

Static findings:

- Display gate: `vm.totalCompletedWorkouts >= 4`
- Display gate: current Muscle Balance volume sum `> 0`
- Display gate: comparison average volume sum `> 0`
- Row filter: `vm.muscleBalance.filter { $0.average > 0 }`
- Display labels: Chest, Back, Shoulders, Quads, Hamstrings, Glutes, Arms, Abs

Static review found no broad bucket labels as Muscle Balance row labels. Missing-baseline rows should be filtered before rendering. Runtime confirmation remains required because only the live app can prove the visible state, scroll behavior, and copy hierarchy.

## 11. Movement Balance behavior

Runtime status: blocked, not executed.

Static findings: the existing production Movement Balance card is separate from Muscle Balance, titled `Movement Balance`, and uses the subtitle `Movement mix from current volume`. It displays Push, Pull, Legs, and Core as movement-category labels, not per-muscle labels.

Data distinction: `movementBalanceData` derives Push/Pull/Legs/Core from the current `vm.muscleBalance` display muscles. It does not read persisted broad buckets from `ProgressEntry.muscleGroupVolume`, and `WorkoutController.completeWorkout()` does not persist `broadCategoryVolume`.

Caveat: Push/Pull/Legs/Core labels are acceptable only if runtime presentation makes the card feel movement-category based. If screenshots show users could confuse it with per-muscle Muscle Balance, that should be logged as a copy/UX caveat rather than a data-contract bug.

## 12. Unresolved metadata scenario

Runtime status: blocked, not executed.

Exact blocker: safely creating or simulating a missing exercise metadata workout was not possible without a disposable runtime state. No data was corrupted to force this scenario.

Static/CI evidence only: `ProgressMuscleCoverageCalculatorTests/unresolvedExerciseIsSkippedSafely()` verifies unresolved exercise IDs are skipped, produce empty coverage, and are reported in `unresolvedExerciseIds` without crashing the calculator.

## 13. Data-shape / label findings

Static data-shape finding: `ProgressEntry.muscleGroupVolume` stores per-muscle `MuscleGroup.rawValue` keys only. The calculator also derives `broadCategoryVolume` for push/pull/legs/core/posterior, but `WorkoutController.completeWorkout()` does not persist those broad buckets to `ProgressEntry`.

Static label finding: Muscle Balance rows use per-muscle display labels. Broad bucket labels do not appear as Muscle Balance row labels. Movement Balance may show Push/Pull/Legs/Core, but those are movement-category labels in a separate card.

Runtime label finding: blocked. Simulator screenshots are still required to verify that the visual distinction between Muscle Balance and Movement Balance is clear.

## 14. Unit semantics / copy risk

The current semantics remain a copy/naming caveat, not a confirmed runtime bug from this pass.

`muscleGroupVolume` is coverage/exposure, not pure kg muscle volume. Weighted exercises contribute kg-style loaded volume. Bodyweight, mobility, and unloaded work contribute exposure points. Existing UI language still uses "volume" in several places, and users could misunderstand future explicit values as exact kg muscle volume.

Current recommendation: acceptable for now behind the existing gated Progress UI, but future Progress V4 production planning should include a copy pass that prefers coverage, exposure, contribution, or training mix language when showing muscle-level values.

## 15. Bugs found and fixes made

No runtime bug was confirmed.

No Swift files were changed. No production Progress UI, Progress V4 DEBUG prototype, assets, localization, analytics, project file, Widget, Watch, or Live Activity files were changed.

## 16. Remaining blockers

- Run real Rork/simulator QA from macOS or another simulator-capable environment.
- Use disposable simulator data only.
- Complete weighted, bodyweight, mixed, 1-workout, 3-workout, 4+ workout, Progress UI, Muscle Balance, Movement Balance, and safely reproducible unresolved-metadata checks.
- Capture whether Movement Balance visually reads as movement-category based and separate from per-muscle Muscle Balance.
- Update this report with actual simulator observations before reclassifying release readiness.

## 17. Release-readiness classification

blocked: build/test/static evidence is healthy, but this is still not a completed runtime QA pass. The data contract should not be marked pass or pass with caveats until real Rork/simulator observations are recorded with disposable simulator data.

## 18. Recommended next prompt

Run this QA prompt from a macOS/Rork simulator-capable environment with disposable data. Record actual observations for weighted, bodyweight, mixed, 1-workout, 3-workout, 4+ workout, Progress UI, Muscle Balance, and Movement Balance. Make no code changes unless that runtime pass finds a concrete bug, and keep Progress V4 DEBUG-only.
