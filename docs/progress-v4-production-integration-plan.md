# Progress V4 Production Integration Plan

Date: 2026-05-08
Mode: Licensed Source Mode, docs-only production integration plan

## 1. Executive summary

Progress V4 is the chosen Progress direction candidate. The accepted DEBUG-only Hybrid Candidate has the right product center: Training Distribution and Muscle Coverage as the signature proof idea, Weekly Rhythm as the consistency layer, Strength Trend as a supporting analysis layer, Training Mix as a distribution summary, Recent Evidence as the trust layer, and maturity language that prevents fake precision.

V4 should not be productionized all at once. Production Progress has not been replaced, the V4 candidate remains DEBUG-only, and the prototype's local demo structs must not be promoted into runtime code.

The build/test foundation is improved. The current iOS Build is green, the focused Progress Muscle Coverage calculator tests pass in GitHub Actions, and the Progress Muscle Coverage Data Contract V1 is implemented.

The release gate that is still open is real macOS/Rork runtime QA for Muscle Coverage. Weighted, bodyweight, mixed, 1-workout, 3-workout, 4+ workout, Muscle Balance, and Movement Balance scenarios have not been observed in a simulator-capable runtime. The Windows workspace cannot complete that gate, and repeated Windows-only runtime QA reports are no longer useful.

The next work should be phased production integration, not another blocked QA loop. The first production slice should use safe real data that is independent of the open Muscle Coverage runtime QA gate, while keeping Training Distribution and Muscle Coverage blocked from release confidence until runtime QA passes or passes with documented caveats.

## 2. Current validation status

| Area | Status | Production implication |
| --- | --- | --- |
| iOS build status | Green in GitHub Actions on current head `bc2356cc8c0683aad94910b3047dbeab3a3e362a`, run `25571693952`. | The project has a viable build foundation for planning and scoped follow-up work. |
| iOS Tests status | Focused iOS Tests passed in GitHub Actions on current head `bc2356cc8c0683aad94910b3047dbeab3a3e362a`, run `25572288082`. | Calculator validation is real CI evidence, but this is not a substitute for simulator/Rork runtime QA. |
| Muscle Coverage calculator test status | Focused `ProgressMuscleCoverageCalculatorTests` pass. | The read/write data contract has test coverage for weighted, unloaded/bodyweight-style fallback, secondary weighting, broad categories, and unresolved exercise handling. |
| Runtime QA status | Blocked and incomplete in this Windows environment. | Muscle Coverage remains a release gate. No release plan may call it complete from static or CI evidence alone. |
| V4 prototype status | Accepted direction candidate, DEBUG-only, local demo data only in `ios/STRQ/Views/Debug/ProgressV4HybridCandidateView.swift`. | Use as product and component reference only. Do not wire its demo state, copy, or data into production. |
| Production Progress status | `ProgressAnalyticsView` still owns the real Progress tab and uses existing real data sources. | Integration must preserve current Progress behavior until a replacement is proven. |
| Remaining gates | Muscle Coverage runtime QA, copy/semantics review, low/partial/full data Rork QA, accessibility, localization plan, owner approval. | V4 can be integrated in slices, but cannot fully replace Progress until these gates are closed. |

## 3. V4 module inventory

| Module | Current prototype source | Real data readiness | Production readiness | Risk | Dependencies |
| --- | --- | --- | --- | --- | --- |
| Training Distribution / Muscle Coverage | `ProgressV4MuscleProofHero`, `ProgressV4BodyFigure`, `ProgressV4CoverageBar`, `ProgressV4Factory.coverage` in the DEBUG candidate. | Partial. `ProgressEntry.muscleGroupVolume` is now populated through Data Contract V1, but runtime QA is still open. | Blocked from confident production launch until runtime QA passes or passes with caveats. Can be represented only as locked/forming if shown earlier. | High. Wrong coverage or over-precise anatomy would damage trust. | `ProgressMuscleCoverageCalculator`, `WorkoutController.completeWorkout`, `ProgressEntry.muscleGroupVolume`, `ExerciseLibrary`, completed sessions, Muscle Balance runtime QA, copy semantics. |
| Weekly Rhythm | `ProgressV4RhythmLayer`, `ProgressV4RhythmGrid`, `ProgressV4WeekColumn`, `ProgressV4Factory.days/weeks`. | High. Completed session dates and current production consistency heatmap already exist from `workoutHistory`. | Best first production slice if implemented with workout-only completed dates and conservative gates. | Low to medium. Date windows and target semantics must stay clear. | `workoutHistory`, `WorkoutSession.startTime`, `isCompleted`, `profile.daysPerWeek`, calendar window rules, Rork state screenshots. |
| Strength Trend | `ProgressV4TrendDetailLayer`, `ProgressV4LineChart`; production has `strengthChart` and `hasEnoughDataForStrengthChart`. | Partial. Existing `strengthProgress` works, but the current Bench/Squat/Deadlift labels are movement-anchor approximations. | Suitable after anchor naming and confidence rules are tightened. | Medium. Misnamed anchors can overclaim literal lift progress. | `AppViewModel.strengthProgress`, `SetLog`, `Exercise.movementPattern`, repeated exposure gates, chart QA. |
| Training Mix | `ProgressV4TrainingMix`, `ProgressV4MixRail`, `ProgressV4MixRow`, `ProgressV4Factory.mix`. | Partial. Broad push/pull/legs/core/posterior totals exist in calculator result, but persisted Progress currently stores per-muscle coverage only. | Should wait until the Muscle Coverage runtime gate passes and a read-only distribution adapter is approved. | High if presented as exact percentage mix before unit semantics are explained. | Muscle Coverage contract, broad-category mapping, movement vs muscle copy, runtime QA. |
| Recent Evidence | `ProgressV4RecentEvidence`, `ProgressV4EvidenceRow`, demo evidence rows. | Partial. Safe event facts can come from completed sessions, weekly rhythm, and total volume. PR, muscle-gap, and plan-impact events are not safe yet. | Good later slice after a centralized event builder exists. Start with session/rhythm/volume only. | Medium. Stale, duplicate, fake, or causal evidence rows would reduce trust. | `workoutHistory`, `weeklyStats`, volume windows, optional strength anchors, future event builder, copy/localization plan. |
| Baseline/Forming/Established states | `ProgressV4DemoState` and local `ProgressV4DemoData`. | Partial. Production already has some baseline-forming language, but V4 needs module-specific gates. | Keep the concept, replace the demo enum with production confidence states. | Medium. Loose gates create fake certainty. | Completed count, recency, comparison windows, anchor repeats, Muscle Coverage gate. |
| Proof/confidence state language | Prototype labels include Locked, Baseline forming, Early signal, Readable, and High confidence. | Partial. The words are strong, but thresholds are not yet centralized in production. | Should become a production helper vocabulary, not view-local optimism. | Medium. Confidence labels must be earned by data. | Module-specific confidence evaluator, copy review, localization plan. |

## 4. Recommended production architecture

Do not replace `ProgressAnalyticsView` directly in one pass. Create a new internal Progress proof component tree gradually, while the existing Progress screen remains the production owner until release readiness is met.

Recommended production view/component names:

- `ProgressProofSurface`
- `ProgressProofSummarySection`
- `ProgressWeeklyRhythmSection`
- `ProgressStrengthTrendSection`
- `ProgressVolumeTrendSection`
- `ProgressTrainingDistributionSection`
- `ProgressTrainingMixSection`
- `ProgressRecentEvidenceSection`
- `ProgressConfidenceState`
- `ProgressEvidenceEvent`
- `ProgressRhythmSnapshot`
- `ProgressTrendSnapshot`
- `ProgressDistributionSnapshot`

Local V4 helpers that should become production helpers only after real data wiring:

- Weekly rhythm date/window builder from the prototype grid concept.
- Week summary builder for recent session counts and target comparison.
- Confidence-state vocabulary for Baseline, Forming, Readable, and High confidence.
- Distribution row/bar presentation, after Muscle Coverage runtime QA.
- Evidence timeline row presentation, after a real event builder exists.

Demo structs that should be deleted or replaced rather than promoted:

- `ProgressV4DemoState`
- `ProgressV4DemoData`
- `ProgressV4Factory`
- Prototype evidence rows and hardcoded dates.
- Prototype coverage values, trend values, and mix percentages.

Real data should be injected safely through small read-only snapshot structs built from existing `AppViewModel` sources. A production section should receive already-derived values such as dates, counts, confidence state, display copy, and chart points. The section should not reach into unrelated models or recompute protected business logic unless that helper is explicitly scoped.

Avoid global components too early. Keep early production sections private or Progress-scoped until at least two production modules prove the same primitive is needed. Do not move V4 visual helpers into the global design system just to tidy one screen.

Feature flag/internal switch guidance:

- If a new composed V4 surface is introduced before replacement, put it behind an internal switch or DEBUG-only preview path.
- If a single safe module is added to current Progress, prefer a narrow section integration over a broad feature flag.
- No flag should expose demo data or bypass module confidence gates.

## 5. Phased integration plan

| Phase | Scope | Allowed files in that future phase | Forbidden files in that future phase | Data dependencies | QA required | Risk | Expected value |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Phase 1: Weekly Rhythm production slice | Add a real-data Weekly Rhythm section using completed workout dates and target-day context. Keep current Progress as owner. Do not wire Training Distribution. | `ios/STRQ/Views/ProgressAnalyticsView.swift`; optionally one new Progress-scoped view file only if the project already supports it without project churn; `docs/migration-progress-log.md`. | Models, Services, ViewModels, assets, project file, localization catalog, analytics, tests unless explicitly scoped, Widget, Watch, Live Activity, `ProgressV4HybridCandidateView.swift`. | Completed `workoutHistory`, `WorkoutSession.startTime`, `isCompleted`, `profile.daysPerWeek`, calendar windows. | Static diff, iOS build/CI when available, Rork screenshots for 0/1/3/4+ workouts, small and large iPhone, date-window sanity. | Low to medium. Date math and target copy are the main risks. | First real V4 idea in production without touching the open Muscle Coverage gate. |
| Phase 2: Strength/Volume Trend production slice | Integrate a restrained trend module from existing chart data and total volume, with honest naming around movement anchors. | Progress view file(s) only, plus a narrow read-only helper if explicitly needed. | Strength formula changes, progression engine, workout completion, models, services, persistence, analytics, localization, assets, tests unless scoped. | `strengthProgress`, `hasEnoughDataForStrengthChart`, completed sets, total volume, weekly volume windows. | Chart state QA, low-data gate QA, label/copy review, no PR claims unless PR write path is proven. | Medium. Anchor naming and trend confidence can overclaim. | Gives Progress analysis depth while staying independent of Muscle Coverage release gate. |
| Phase 3: Internal Progress proof surface behind feature flag/internal switch | Compose the accepted proof hierarchy using only modules already wired to real safe data. Muscle sections remain locked/forming placeholders if the QA gate is open. | `ProgressAnalyticsView.swift` and Progress-scoped view files; docs log. | Broad app navigation, ContentView tab replacement, models, services, assets, project file, localization, analytics, Watch/Widget/Live Activity. | Phase 1 and Phase 2 snapshots, existing current Progress data. | Rork side-by-side screenshots, current Progress fallback check, no demo data search, performance smoke check. | Medium. Old and new Progress can mix badly if hierarchy is not controlled. | Creates the landing zone for phased replacement without claiming full V4 is ready. |
| Phase 4: Training Distribution / Muscle Coverage integration | Wire Training Distribution, Muscle Coverage, and Training Mix from real `muscleGroupVolume` and/or read-only distribution adapters only after runtime QA passes. | Progress view file(s), a narrow read-only adapter/helper if needed, focused tests if helper logic changes, docs log. | Workout completion changes, model schema changes, assets, project file, localization, analytics, plan/coach logic, Widget/Watch, unless a separate approved prompt scopes them. | `ProgressEntry.muscleGroupVolume`, calculator semantics, broad category mapping, current/comparison windows, Muscle Balance runtime QA. | Required macOS/Rork runtime QA for weighted/bodyweight/mixed and 1/3/4+ states, copy/semantics screenshots, accessibility summaries. | High. This is the signature module and highest trust risk. | Makes V4 distinctly STRQ-owned once the data is proven in runtime. |
| Phase 5: Recent Evidence from safe real events | Add a real evidence timeline from completed sessions, rhythm, and volume facts first. Add muscle-gap or PR events only after their contracts are proven. | Progress view file(s), optional `ProgressEvidenceBuilder` helper, focused tests if builder logic is nontrivial, docs log. | PR generation, workout completion, coach actions, plan mutation, persistence schema, analytics, localization unless separately scoped. | Completed sessions, dates, volume deltas, rhythm target, optional strength anchors, later muscle coverage. | Duplicate/stale event QA, low-data QA, copy review, localization plan. | Medium. Evidence must be traceable and non-causal unless provenance exists. | Converts Progress from metrics into explainable proof. |
| Phase 6: Replace old Progress surface | Make the new Progress proof surface the production default only after all release readiness criteria are met. | Progress view files, docs log, localization only if separately approved, tests if helper logic changes. | Any unrelated app shell, Coach, Train, Profile, models, services, assets, Watch/Widget/Live Activity changes. | All accepted production module snapshots, release QA outputs, owner approval. | Full Rork QA across low/partial/full data, accessibility, localization plan, build/test green, no demo data. | High. This is the actual replacement point. | Ships the accepted V4 direction as the real Progress experience. |

## 6. Recommended first production implementation

Choose exactly one first implementation slice: **A. Weekly Rhythm production slice**.

Why A:

- Weekly Rhythm is the safest real-data V4 module because completed workout dates already exist and current Progress already uses similar date scanning.
- It does not depend on the open Muscle Coverage runtime QA gate.
- It gives users real value: cadence, target context, and what STRQ can safely read from training rhythm.
- It creates a production component boundary without forcing a full V4 shell or replacement.
- It reduces the temptation to repeat blocked Windows-only QA attempts.

Why not B first: Strength/Volume Trend is useful, but strength anchor naming and chart semantics need more care than rhythm dates.

Why not C first: a full V4 production shell can freeze broad architecture before the first safe module proves itself.

Why not D first: Training Distribution depends on Muscle Coverage runtime QA.

Why not E first: Recent Evidence needs an event builder and can accidentally imply causal proof too early.

## 7. Data gates and confidence rules

Baseline, Forming, Readable, and High confidence are production confidence states. They are not decoration. Each module earns them independently.

| Module | Baseline | Forming | Readable | High confidence |
| --- | --- | --- | --- | --- |
| Weekly Rhythm | 0-1 completed workouts. Show an empty or first-session cadence runway. | 2-3 completed workouts or one partially observed training week. Show marks, not conclusions. | At least 2 weeks with workouts and at least 4 total completed sessions. Show cadence and target context cautiously. | At least 4 observed weeks, 8+ sessions, and 3+ weeks with target-bearing evidence. |
| Strength Trend | No completed weighted/reppable anchor, or only one anchor exposure. | 2 anchor exposures in one movement bucket or 3 total anchor sessions. | Repeated exposures across at least 2 movement buckets and 2+ weeks. Use movement-anchor language. | 4+ weeks, 3+ repeated exposures in at least 2 movement buckets, and no displayed anchor ambiguity. |
| Volume Trend | 0-1 completed workouts with completed-set volume. | 2-3 completed workouts with total volume. | 4+ sessions or 2 comparison weeks. Show workload direction with caveats. | 4+ weeks and 8+ sessions with enough context to separate spikes, deloads, and target adherence. |
| Muscle Coverage | 0 completed workouts, no resolved primary muscles, or runtime QA gate still open for confident display. | 1-3 sessions with resolved primary muscles. Primary-only coverage may be shown as forming if copy is cautious. | Only after runtime QA gate passes: 4+ sessions over 2+ weeks, current and comparison data nonzero, displayed categories repeated. | 4+ weeks, 8+ sessions, repeated evidence in all displayed categories, validated secondary weighting, and low unresolved-exercise rate. |
| Recent Evidence | No completed events or one basic session fact. | 2-3 real facts from sessions, rhythm, or volume. No muscle-gap or PR claims yet. | Events across 2+ weeks with deduping, clear dates, and a real source for each row. | 4+ weeks of events from multiple proven sources with stale-event expiry and no causal claims without provenance. |

If a module fails its gate, it should show a runway or forming state rather than disappearing into fake certainty.

## 8. Runtime QA gates

Muscle Coverage runtime QA is still required before release confidence or V4 replacement.

Required simulator/Rork scenarios:

- Weighted workout coverage.
- Bodyweight or unloaded workout coverage.
- Mixed weighted plus bodyweight/unloaded workout coverage.
- 1-workout Progress state.
- 3-workout Progress state.
- 4+ workout Progress state.
- Muscle Balance display with real current and comparison data.
- Movement Balance display as movement-category based, separate from per-muscle Muscle Balance.
- Unresolved exercise metadata safety, if reproducible with disposable data.

Required checks:

- No fake precision.
- No broad bucket confusion inside Muscle Balance rows.
- Muscle Balance and Movement Balance are visually and semantically distinct.
- `muscleGroupVolume` copy reads as coverage/exposure contribution, not pure kg muscle volume.
- Bodyweight/unloaded training does not vanish from coverage.
- Missing comparison baseline does not show misleading `-100%` rows.
- Copy/semantics check on all visible muscle, movement, balance, coverage, and volume language.

This gate must be completed from a macOS/Rork simulator-capable environment with disposable data. The Windows workspace cannot complete it.

## 9. Production copy and semantics

`muscleGroupVolume` is coverage/exposure contribution, not pure kg volume. Weighted exercises contribute kg-style load. Bodyweight, unloaded, mobility, and similar zero-load exercises contribute exposure points.

Production UI should avoid overclaiming "volume" when mixed unit semantics are shown. Safer language includes:

- coverage
- exposure
- contribution
- training mix
- current signal
- comparison window

V4 copy should avoid debug/prototype language such as candidate, demo, lab, local state, or sample data. User-facing Progress should also avoid AI-ish wording. Do not imply STRQ "knows", "diagnoses", or "predicts" more than the data supports.

Localization will be needed later. Early production slices may follow the existing codebase pattern, but replacement readiness requires a localization plan for confidence states, evidence rows, and module captions.

## 10. Risks and guardrails

| Risk | Guardrail |
| --- | --- |
| Fake precision | Use confidence gates, broad states, and evidence language instead of exact claims from thin data. |
| Premature V4 launch | Keep V4 DEBUG-only until real modules are wired, QA is complete, and owner approval is recorded. |
| Runtime QA skipped | Muscle Coverage and Training Distribution cannot be release-confident until macOS/Rork runtime QA is done. |
| Muscle coverage wrong or misleading | Use the V1 contract cautiously, verify runtime states, and avoid anatomy heat confidence until proven. |
| Old and new Progress mixing badly | Integrate in slices with one hierarchy. Do not stack V4 modules randomly under the old dashboard. |
| Data gates too loose | Define module-specific thresholds. Do not reuse a generic confidence label for every signal. |
| Performance | Derive from bounded windows first. Cache only after profiling or visible need. |
| Accessibility | Charts, grids, and body coverage need textual summaries and non-color state labels before replacement. |
| Localization | Do not ship a replacement surface without a plan for strings and evidence templates. |
| Overbuilding before release | Defer replay, plan impact, prediction, coach feedback loops, and premium reports. |

Release scope boundary:

- In scope for phased V4 production: Weekly Rhythm, safe Strength/Volume Trend, Training Distribution after the runtime gate, safe Recent Evidence, confidence states.
- Out of scope for the first release: Progress Replay, predictive imbalance, plan-impact causality, Coach + Progress feedback loop, broad new persistence models, Pro paywall hooks.

## 11. Release readiness criteria

Progress V4 can replace the current Progress surface only when all of the following are true:

- iOS build is green.
- Focused Progress tests are green.
- Relevant helper tests are green if new helpers are added.
- Muscle Coverage runtime QA passes or passes with documented caveats.
- No misleading Muscle Balance or Movement Balance behavior remains.
- No demo data, prototype state, or DEBUG-only source feeds production UI.
- Weekly Rhythm, Strength Trend, volume, Muscle Coverage, and Recent Evidence each have confidence gates.
- Copy does not overclaim coverage/exposure as pure volume.
- Localization plan exists for all new production copy.
- Accessibility pass covers charts, rhythm grids, coverage bars, body coverage, and evidence rows.
- Rork QA covers low-data, partial-data, and full-data states on small and large iPhone sizes.
- Owner approval is recorded for the replacement.

## 12. Exactly one next prompt

```text
Use Licensed Source Mode.

Goal:
Implement the first Progress V4 production integration slice: Weekly Rhythm from real completed workout dates. This is not a V4 replacement pass and must not wire Training Distribution or Muscle Coverage into production.

Target:
- Add a production Weekly Rhythm section to the existing Progress experience using completed `workoutHistory` session dates only.
- Show a 28-day or 35-day cadence grid and recent week summaries with conservative Baseline/Forming/Readable/High confidence language.
- Use `profile.daysPerWeek` only as target context. Do not use readiness check-ins as workout rhythm.
- Keep the current Progress route, analytics, tabs, charts, and existing sections behaviorally intact.

Allowed edits:
- `ios/STRQ/Views/ProgressAnalyticsView.swift`
- `docs/migration-progress-log.md`

Forbidden edits:
- Do not edit `ios/STRQ/Views/Debug/ProgressV4HybridCandidateView.swift`.
- Do not edit Models, Services, ViewModels, analytics files, assets, `Assets.xcassets`, `project.pbxproj`, `Localizable.xcstrings`, Widget, Watch, Live Activity, tests, fonts, or production runtime files outside the target Progress view.
- Do not change workout completion, persistence, HealthKit, plan generation, coach actions, PR generation, strength calculations, volume calculations, Muscle Balance calculations, Movement Balance calculations, or navigation routes.
- Do not use demo data or prototype structs.
- Do not productionize V4 as a full surface.

Behavior protection:
- Existing Progress tab selection, `ProgressRoute.history`, `SessionHistoryView` navigation, `.progress_viewed` analytics timing, Strength/Body/Volume tabs, chart gates, and current data calculations must remain unchanged.
- Weekly Rhythm must be derived from completed workouts only.
- Empty and low-data users must see honest Baseline/Forming copy, not fake consistency.
- Muscle Coverage runtime QA remains a separate release gate and is not completed by this slice.

Verification:
- git status --short --branch
- git diff --name-only
- git diff -- ios/STRQ/Views/ProgressAnalyticsView.swift docs/migration-progress-log.md
- git diff --name-only -- ios/STRQ/Models ios/STRQ/Services ios/STRQ/ViewModels ios/STRQ/Assets.xcassets ios/STRQ/Localizable.xcstrings ios/STRQWidget ios/STRQWatch ios/STRQ.xcodeproj ios/STRQTests
- rg -n "Weekly Rhythm|Baseline|Forming|Readable|High confidence|workoutHistory|isCompleted|daysPerWeek|ProgressRoute|progress_viewed" ios/STRQ/Views/ProgressAnalyticsView.swift
- git diff --check
- Do not claim local xcodebuild or simulator validation from Windows.

Report back:
1. Files changed
2. Weekly Rhythm behavior summary
3. Data gates used
4. Protected behavior confirmation
5. Verification results
6. Rork QA required or not
7. Muscle Coverage runtime QA gate status

Push command after successful verification:
git status --short --branch
git add ios/STRQ/Views/ProgressAnalyticsView.swift docs/migration-progress-log.md
git commit -m "feat: add progress weekly rhythm slice"
git push
```
