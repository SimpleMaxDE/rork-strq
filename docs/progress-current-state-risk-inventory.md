# Progress Current State Risk Inventory

## 1. Executive summary

Progress is not safe for a broad visual shell pass yet. A narrow display-only shell can be planned, but Rork screenshots and state capture are required first because the screen has many data-dependent branches, fixed time windows, local calculations, chart visibility gates, route behavior, and a few current data-source risks that could make a redesign look correct in one state and misleading in another.

This inventory is docs-only and was created from static inspection. No Swift, assets, project files, localization, models, services, view models, analytics, tests, Watch, Widget, Live Activity, or runtime behavior were changed.

Source note: the required source docs were read in this pass, including `docs/progress-analytics-signature-direction-plan.md` and `docs/exercise-info-anatomy-v1-freeze-report.md`. Those two files were added to `origin/main` while this branch was being pushed, so the inventory was corrected during rebase resolution to reflect the current source set.

Conclusion: the best immediate next prompt is A. Progress screenshot/state capture checklist only. The first later implementation phase should be a Progress Hero / Proof Summary shell-only pass, but only after screenshots confirm early, populated, body, volume, and history states.

## 2. Current file and route inventory

| Area | File | Current role | Routes/actions | Risk |
|---|---|---|---|---|
| Progress tab entry | `ios/STRQ/ContentView.swift` | Tab index 3 wraps `ProgressAnalyticsView(vm: vm)` in a `NavigationStack`. Custom bottom tab uses SF Symbol `chart.line.uptrend.xyaxis` and label `Progress`. | Selecting bottom tab mutates `selectedTab`; active workout, completion handoff, onboarding, and pre-workout handoff can override normal tabs. | High for route/app-shell changes; read-only mapping only. |
| Progress root | `ios/STRQ/Views/ProgressAnalyticsView.swift` | Three-tab proof surface with hero, improvement summary, signals, Strength/Body/Volume modules, charts, and recent workouts. | `onAppear` animates `appeared` and tracks `Analytics.shared.track(.progress_viewed)`. | Medium/high because display logic is dense and calculation-adjacent. |
| Progress route enum | `ios/STRQ/Views/ProgressAnalyticsView.swift` | `ProgressRoute.history`. | Used by recent workout "All" link. | Protected route contract. |
| Session history route | `ios/STRQ/Views/ProgressAnalyticsView.swift` -> `ios/STRQ/Views/SessionHistoryView.swift` | `NavigationLink(value: ProgressRoute.history)` appears only when recent completed sessions exist. | `.navigationDestination(for: ProgressRoute.self)` opens `SessionHistoryView(vm: vm)`. | Medium; do not move or remove without route QA. |
| Session history root | `ios/STRQ/Views/SessionHistoryView.swift` | Grouped completed workout log with summary stats, rows, empty state, and modal details. | Row tap sets `selectedSession`; `.sheet(item:)` presents `SessionDetailView` in a nested `NavigationStack`. | Medium; display rows are tempting but route and sheet behavior are protected. |
| Session detail sheet | `ios/STRQ/Views/SessionHistoryView.swift` | Detail view with verdict banner, stats, optional note, exercise cards, set table. | `Done` toolbar button dismisses sheet. | Medium/high because it reads workout history, set data, and highlight verdicts. |
| Adjacent stats/report views | `BodyWeightLogView`, `WeeklyCheckInView`, `WorkoutCompletionView`, `SleepLogView`, `WeightQuickLogSheet` | Related chart/report/logging surfaces, not directly routed from Progress in the inspected Progress root. | Body/weekly/workout completion routes originate from Today, Coach, Profile, or Active Workout. | Out of scope for first Progress implementation except as visual references. |

Licensed Source Mode context from existing docs: Progress-relevant licensed Figma sources include Activity Tracker `11611:134946`, Chart `9129:26029`, Progress `9129:207997`, Achievement Badge `9064:106798`, Chart icons such as `chart-bar-1` `8997:14737`, `chart-trend-up` `8997:15175`, and `chart-donut-1` `8997:14897`. These are source material for later visual work, not runtime changes in this pass.

## 3. Current Progress screen/module inventory

Visible root order in `ProgressAnalyticsView`:

| Module | Visibility | Current job | Data source | Notes |
|---|---|---|---|---|
| Headline hero | Always | Main proof summary: workouts logged, lifts progressing, PRs, or streak. | `vm.dataMaturityTier`, `vm.totalCompletedWorkouts`, `vm.progressingExercises`, `vm.personalRecords`, `vm.streak`. | Strong candidate for later display-only shell work if values remain untouched. |
| Achievement chips | Always, but chips appear conditionally | Shows PR, streak, volume-up, consistency badges. | Local PR/month, local week-over-week volume, `vm.weeklyStats.sessions`, `vm.profile.daysPerWeek`. | Display shell is safer than badge logic. |
| What's improving card | Always | Picks one strongest improvement signal. | Local conditions plus `vm.totalCompletedWorkouts`, `vm.progressingExercises`, `vm.stalledExercises`, `vm.workoutHistory`, `vm.weeklyStats`, `vm.effectiveRecoveryScore`. | High narrative value, but the ranking logic is protected. |
| Signal strip | Always | Four compact pills for logged/target/streak/recovery or progressing/streak/workouts/recovery. | `vm.isEarlyStage`, `vm.totalCompletedWorkouts`, `vm.weeklyStats`, `vm.profile.daysPerWeek`, `vm.streak`, `vm.effectiveRecoveryScore`. | Safe for visual shell if exact pill set and values remain. |
| Recent improvement | Established only | Four cells for volume, workouts, new PRs, progressing vs last week. | Local 7-day/14-day history slices, `vm.personalRecords`, `vm.progressingExercises`. | Calculation-adjacent. Needs screenshots before shell changes. |
| Momentum | Established only | Strength, optional Physique, and Consistency momentum rows. | `vm.progressingExercises`, `vm.stalledExercises`, `vm.profile.nutritionTrackingEnabled`, `vm.physiqueOutcome`, `vm.streak`, `vm.totalCompletedWorkouts`. | Optional body row can appear/disappear. |
| Strength/Body/Volume selector | Always | Local segmented control. | `@State selectedTab`. | Behavior must preserve index mapping: 0 Strength, 1 Body, 2 Volume. |
| Strength baseline | Strength tab when chart gate fails | Early strength runway. | `vm.hasEnoughDataForStrengthChart`, `vm.totalCompletedWorkouts`. | Low-risk empty shell candidate. |
| Strength chart | Strength tab when chart gate passes | Estimated 1RM lines. | `vm.strengthProgress`. | Chart container shell only; do not change marks/data. |
| Personal Records | Strength tab if established or PRs exist | Latest PR and up to 3 compact rows, or PR empty text. | `vm.personalRecords`, `vm.library.exercise(byId:)`. | Static search did not find current PR creation; treat as fragile/legacy data. |
| Recent Workouts | Strength tab always | Up to 3 recent completed sessions and optional "All" history route. | `vm.workoutHistory.filter(\.isCompleted)`. | Route-adjacent. Row shell possible later with QA. |
| 28-Day Consistency | Strength tab always | Heatmap of trained days. | Local 28-day `vm.workoutHistory` scan. | Custom grid, not Swift Charts. |
| Body runway | Body tab when all body inputs are absent | Empty/early body signal card. | `vm.goalPace`, `vm.bodyWeightEntries`, `vm.recoveryTrendData`, `vm.nutritionLogs`. | Likely masked because `recoveryTrendData` returns synthetic 14-day data. |
| Goal Pace | Body tab when `vm.goalPace` exists | Bodyweight/nutrition pace verdict. | Nutrition/physique coordinator via `vm.goalPace`. | Protected nutrition/body logic. |
| Body Weight chart | Body tab with at least 2 weights | Weight trend area/line chart. | `vm.bodyWeightEntries`, `vm.weightTrendDescription`, `vm.nutritionTarget`. | Body/HealthKit-adjacent. |
| Recovery Trend chart | Body tab with at least 3 recovery data points | Recovery score trend with 70 rule line. | `vm.recoveryTrendData`. | Synthetic score logic, not raw HealthKit. |
| Nutrition adherence | Body tab with nutrition logs | 7-day protein/calorie bars. | `vm.nutritionLogs`, `vm.nutritionTarget`. | Custom bars, nutrition opt-in behavior protected. |
| Volume runway | Volume tab when fewer than 2 completed workouts | Volume empty/early card. | `vm.totalCompletedWorkouts`. | Good empty shell candidate. |
| Muscle Balance | Volume tab after 2 workouts | Muscle volume vs 4-week average capsule bars. | `vm.muscleBalance`. | High risk because current workout completion does not populate muscle volume map. |
| Weekly Workouts chart | Volume tab after 2 workouts | 8-week workout-count bar chart. | Local 8-week `vm.workoutHistory` scan. | Chart shell possible with no data changes. |
| Movement Balance | Volume tab after 2 workouts | Push/Pull/Legs/Core volume shares. | Local aggregation from `vm.muscleBalance`. | Shares are zero if muscle volumes absent. |

## 4. Data source and calculation map

| Data/calculation | Source | Current calculation | Protected notes |
|---|---|---|---|
| Workout/session history | `AppViewModel.workoutHistory`; persisted in `PersistedAppState`; appended by `WorkoutController.completeWorkout()` | Completed sessions are filtered by `isCompleted`, sorted by `startTime`, and used throughout Progress and Session History. | Protect ordering, completion flag semantics, persistence, and active workout completion handoff. |
| Total completed workouts | `AppViewModel.totalCompletedWorkouts` | Count of completed `workoutHistory`. | Used for maturity, hero, empty states, volume gate. |
| Weekly stats | `AppViewModel.weeklyStats` | Last 7 days: sessions, total volume, completed set count. | Used in hero badges, signal strip, consistency. |
| Monthly stats | `AppViewModel.monthlyStats` | Last 30 days sessions, volume, sets. | Not directly prominent in current Progress root, but protected as shared metric. |
| Strength progress | `AppViewModel.strengthProgress` | Builds 8 weekly `StrengthEntry` points from completed sessions. Detects anchor IDs by movement pattern; computes best estimated 1RM as `weight * (1 + reps / 30)`, carries last known values forward. | Protect formula, anchor detection, and chart gate. Current labels say Bench/Squat/Deadlift while data maps horizontal push/squat/hip hinge; pull/OHP is computed but not charted. |
| Strength chart gate | `AppViewModel.hasEnoughDataForStrengthChart` | Requires at least 2 `strengthProgress` entries and at least one series with 2 positive points. | Protect; visual changes must not force the chart visible. |
| Personal records | `AppViewModel.personalRecords`; persisted. | Progress displays count, latest PR, and compact rows. Static search did not find current creation/insertion of `PersonalRecord` or `SetLog.isPR` in the active workout path. | Treat as fragile/legacy or future data. Do not fabricate PRs visually. |
| Progression states | `CoachingCoordinator.refreshProgressionStates()` -> `AppViewModel.progressionStates` | Top relevant exercise IDs are analyzed by `ProgressionEngine.analyzeProgression`; `progressingExercises` and `stalledExercises` filter `PlateauStatus`. | Core training logic. Do not change thresholds, statuses, or interpretation. |
| Volume week-over-week | Local in `ProgressAnalyticsView` | Slices `workoutHistory` into this week and previous week; compares `totalVolume`. | Local duplicated calculations appear in multiple modules. Shell work should not consolidate/refactor them. |
| Session volume delta | Local in `SessionHistoryView.volumeDelta(for:)` | Compares a session to previous completed session with the same `dayName`; returns percent delta. | Protected display behavior because row tags and detail trust depend on it. |
| Muscle group volume | `AppViewModel.muscleBalance` from `progressEntries.muscleGroupVolume` | Uses last 7 days vs last 28 days for Chest/Back/Shoulders/Quads/Hamstrings/Glutes/Arms/Abs. | High risk: `WorkoutController.completeWorkout()` creates `ProgressEntry` without `muscleGroupVolume`, so new sessions appear to add no muscle volume unless legacy data exists. Do not visually present this as reliable without QA/data fix planning. |
| Movement balance | Local in `ProgressAnalyticsView.movementBalanceData` | Push = Chest + Shoulders, Pull = Back, Legs = Quads + Hamstrings + Glutes, Core = Abs, all from `vm.muscleBalance`. | Depends on the muscle-volume gap above. |
| Bodyweight data | `AppViewModel.bodyWeightEntries`; `completeOnboarding()` seeds from profile if empty; `logBodyWeight()` and HealthKit sync can add. | Body chart requires at least 2 entries. Trend description requires at least 4 entries and compares first 3 vs recent 3. | Health/body data and HealthKit write/read behavior are protected. |
| Goal pace and physique | `NutritionPhysiqueCoordinator` and `PhysiqueIntelligenceEngine` via `vm.goalPace`, `vm.physiqueOutcome`. | Only active when nutrition tracking is enabled; goal pace needs at least 3 weight entries in last 14 days. | Opt-in behavior is protected; missing logs must not become negative for non-tracking users. |
| Recovery score | `AppViewModel.recoveryScore`, `effectiveRecoveryScore`, `recoveryTrendData`. | Recovery trend returns synthetic daily scores from sleep, readiness, and workouts over 14 days. Base score is 70 even with no entries. | Do not imply raw medical/HealthKit precision. |
| Nutrition adherence | `vm.nutritionLogs`, `vm.nutritionTarget`. | Last 7 logs, average protein, custom bar height from average of protein and calorie target percentages. | Nutrition opt-in and target calculations are protected. |
| Persistence | `PersistenceStore`, `SnapshotBuilder`, `AppViewModel.persist()` | Persists `workoutHistory`, `personalRecords`, `progressEntries`, `progressionStates`, bodyweight, sleep, nutrition, active workout drafts, etc. | No schema/key/write timing changes in Progress visual work. |
| Analytics | `Analytics.shared.track(.progress_viewed)` in `ProgressAnalyticsView.onAppear`; related workout/body/nutrition/sleep events elsewhere. | Progress root view event on appear. | Do not add/remove/rename or change trigger timing. |

## 5. Chart usage map

| Chart/module | File/function | Chart type | Data source | Visible states | Risk | Visual shell-only safe? |
|---|---|---|---|---|---|---|
| Estimated 1RM | `ProgressAnalyticsView.strengthChart` | Swift Charts `LineMark` for Bench/Squat/Deadlift. | `vm.strengthProgress`; gate is `vm.hasEnoughDataForStrengthChart`. | Strength tab with enough anchor data. | High for data interpretation, medium for container visuals. | Yes, container/header/legend shell only; do not change marks, series, gate, or labels without plan. |
| Body Weight | `ProgressAnalyticsView.bodyWeightChart` | Swift Charts `AreaMark` + `LineMark`. | Sorted `vm.bodyWeightEntries`; trend from `vm.weightTrendDescription`. | Body tab when at least 2 bodyweight entries exist. | Medium/high due body/HealthKit/nutrition target adjacency. | Container shell only after body present/absent screenshots. |
| Recovery Trend | `ProgressAnalyticsView.recoveryTrend` | Swift Charts `AreaMark` + `LineMark` + `RuleMark` at 70. | `vm.recoveryTrendData`, synthetic recovery score. | Body tab whenever data count >= 3, likely almost always. | High for fake precision and empty-state masking. | Container shell only; avoid changing explanation or data until plan. |
| Weekly Workouts | `ProgressAnalyticsView.weeklySessionsChart` | Swift Charts `BarMark`. | Local 8-week count from `vm.workoutHistory`. | Volume tab after 2 completed workouts. | Medium; fixed time window and animated appeared state. | Yes for shell only; do not change week labels/counting. |
| Muscle Balance | `ProgressAnalyticsView.muscleBalanceChart` | Custom capsule progress bars, not Swift Charts. | `vm.muscleBalance` from `progressEntries.muscleGroupVolume`. | Volume tab after 2 completed workouts. | High because current entries may have empty muscle volume. | No meaningful visual redesign before data-state screenshots and plan. |
| Movement Balance | `ProgressAnalyticsView.movementBalanceCard` | Custom vertical bars. | Local aggregate from `vm.muscleBalance`. | Volume tab after 2 completed workouts. | High due same muscle volume dependency and zero-total handling. | Shell only is possible, but do not elevate this module first. |
| Nutrition adherence | `ProgressAnalyticsView.nutritionAdherence` | Custom mini bars. | Last 7 `vm.nutritionLogs`, `vm.nutritionTarget`. | Body tab when nutrition logs exist. | Medium/high due opt-in nutrition logic. | Low priority; shell only after nutrition-on screenshots. |
| 28-Day Consistency | `ProgressAnalyticsView.consistencyHeatmap` | Custom 7-column grid. | Local 28-day workout history scan. | Strength tab always; empty copy if no trained days. | Medium; no Swift Charts but time-window behavior matters. | Possible after screenshot QA. |
| Session history stats/rows | `SessionHistoryView.summaryBar`, `sessionRow`, `SessionDetailView.statsRow` | Metric rows and tables, not Charts. | Completed sessions, sets, reps, duration, volume. | History route. | Medium because route/sheet and workout records are trust-critical. | Row shell later only. |

## 6. State map

| State | Current behavior | Risks to preserve/check |
|---|---|---|
| No workout data | Hero shows `0 workouts logged`; improvement card says clear trends appear after a few workouts; early signal strip shows Logged/Target/Streak/Recovery; recent improvement and momentum hidden; Strength baseline appears; PR section hidden; recent workouts empty; consistency empty; Body likely shows recovery trend rather than runway because `recoveryTrendData` has synthetic points; Volume runway appears. | Capture screenshots. Body empty state may not appear despite no real body data. Do not make charts imply real progress. |
| One workout | Hero shows `1 workout logged`; early subtitle; volume runway still appears because Volume requires at least 2 completed workouts; Strength baseline remains unless chart gate passes; recent sessions row appears with history route. | Recent history route becomes available. Early state and route both need QA. |
| Little data, 2-3 workouts | Hero uses earlyWeek; recent improvement and momentum still hidden until established; Volume modules become visible after 2 workouts; Strength chart may still be baseline; history and consistency populate. | Volume modules can show zero/red muscle balance if `muscleGroupVolume` is absent. |
| Normal data, 4+ workouts | Recent improvement and momentum appear; Strength/Body/Volume tab content depends on gates; signal strip switches to Progressing/Streak/Workouts/Recovery. | This is the minimum screenshot state before a visual shell pass. |
| Strong progress | PR badges/cards if `personalRecords` exists; progressing count wins over stalled; volume-up badge/cell; weekly target consistency badge; streak and high recovery states; session rows can show PR/Up tags. | PR data may be absent in current generation path. Do not invent milestones. |
| Regression/decline | Stalled > progressing yields warning "lifts flat"; volume down vs previous week yields warning "Lighter week"; session row volume down tag appears at <= -8%; body/physique can show warning/danger verdicts; recovery average can move yellow/red. | Negative states need screenshots so visual design does not turn caution into celebration. |
| Bodyweight present | Body Weight chart appears at 2+ entries; latest kg shown; trend pill may still say "Not enough data" until 4 entries. | Preserve count thresholds and copy. |
| Bodyweight absent | Body Weight chart silently omitted. Body tab may still show recovery trend. | Risk of an apparently populated Body tab with no real weight/body proof. |
| Muscle group volume present | Muscle Balance bars and Movement Balance percentages can show meaningful values. | Requires `ProgressEntry.muscleGroupVolume` data. Need fixture or real data capture. |
| Muscle group volume absent | `vm.muscleBalance` still returns all eight muscles with `average == 0`, `percentOfAverage == 0`, labels around `-100%`, and zero-width bars after 2 workouts. | High risk. Do not redesign this as a confident anatomy/proof module until data source is planned. |
| Time range/filter | No user-selectable time range. Only local tab selector. Fixed windows: 7 days, 14 days, 28 days, 8 weeks, 4-week average, 7 nutrition logs, 14 recovery days. | Do not add range controls in first visual pass. Changing windows is behavior. |
| Small iPhone | 56pt hero number, four equal signal pills, four recent-improvement cells, chart axes, 68pt muscle labels, compact PR rows, and history stats can crowd. | Screenshot QA required on small iPhone. Text truncation and fake precision risk are high. |
| Large iPhone | Card stack may read as generic dashboard wall because many equal cards repeat. | Need hierarchy/proof narrative, not more cards. |

## 7. Empty and early-stage behavior

Current empty/early behaviors:

- Progress root never shows a full-screen empty state. It always renders the hero, improvement card, signal strip, tab selector, and selected tab content.
- Strength has an explicit baseline card when `vm.hasEnoughDataForStrengthChart` is false.
- PR card has empty copy, but the PR section is hidden for early users unless PR data exists.
- Recent Workouts card shows an empty row when no completed sessions exist. The "All" history route is hidden when there are no recent sessions.
- 28-Day Consistency shows an empty copy row if no trained days exist.
- Body Signals has a runway card intended for missing body signals, but the condition includes `vm.recoveryTrendData.count < 3`. Since `recoveryTrendData` currently returns 14 synthetic daily points in normal circumstances, this runway may be effectively unreachable after onboarding.
- Body Weight chart is omitted unless there are at least two weight entries.
- Recovery Trend chart appears when recovery data count is at least 3; current synthetic data means it can appear without real sleep/readiness data.
- Nutrition adherence is omitted unless there are nutrition logs.
- Volume Signals shows a runway card until `vm.totalCompletedWorkouts >= 2`.
- Session History has a full empty state, but Progress hides the link when there are no recent completed workouts, so the empty history route may not be user-reachable from Progress.

Early-stage risk: Progress currently communicates "STRQ is reading" before several downstream sources are genuinely populated. A visual redesign should make early proof feel earned rather than dressing synthetic or missing data as premium analysis.

## 8. Navigation/action map

| Action/route | Current behavior | Protected behavior |
|---|---|---|
| Select Progress tab | Custom `STRQTabBar` sets `selectedTab = 3`; `ContentView` displays `ProgressAnalyticsView` in a `NavigationStack`. | Do not change tab index, app-shell routing, onboarding/active-workout gating, or notification deep-link behavior. |
| Progress appear | `appeared = true` animation; tracks `.progress_viewed`. | Preserve analytics event name and trigger timing. |
| Strength/Body/Volume selector | Local buttons animate `selectedTab` 0/1/2 and trigger selection haptic. | Preserve tab order, labels, and selected content mapping unless explicitly scoped. |
| Recent Workouts "All" | `NavigationLink(value: ProgressRoute.history)` visible only when recent completed sessions exist. | Preserve visibility gate and route destination. |
| Progress history destination | `.navigationDestination(for: ProgressRoute.self)` maps `.history` to `SessionHistoryView(vm: vm)`. | Do not move route in a way that breaks navigation stack. |
| Session history row tap | Button assigns `selectedSession = session`. | Preserve exact session object and tap target. |
| Session detail sheet | `.sheet(item: $selectedSession)` opens nested `NavigationStack` with `SessionDetailView`; large detent and visible drag indicator. | Preserve modal route, detent, and dismiss behavior. |
| Session detail Done | Toolbar button calls `dismiss()`. | Do not add edit/delete/share actions in visual shell pass. |
| Adjacent body logs | Body weight, sleep, nutrition logs are not launched from Progress root in inspected code. | Do not add logging actions to Progress in first pass. |

## 9. Protected behavior map

Protect these areas in any future Progress work:

| Protected area | Why |
|---|---|
| Workout history | It is the trust source for recent workouts, history rows, session detail, volume, consistency, and workout completion. |
| WorkoutController completion path | It writes `workoutHistory`, `ProgressEntry`, persistence, HealthKit workout export, handoff, analytics, family response, and intelligence refresh. |
| Volume calculations | Week-over-week volume, session volume, total training volume, history summary, and row verdicts must not change in a visual pass. |
| Bodyweight calculations | Body weight logs, goal pace, weight trend, HealthKit sync, profile weight/body fat updates, and nutrition physique outcome are protected. |
| Muscle group volume calculations | `vm.muscleBalance`, `weeklyVolumeByMuscle`, and downstream plan/coaching logic are protected. The current data gap should be documented, not patched in a visual pass. |
| Chart data calculations | `strengthProgress`, `hasEnoughDataForStrengthChart`, `recoveryTrendData`, local 8-week workouts, and chart gates are behavior. |
| Navigation routes | `ContentView` tab routing, `ProgressRoute.history`, `SessionHistoryView` sheet routing, and detail dismissal are protected. |
| Analytics | `.progress_viewed` and related workout/body/nutrition/sleep events must not be added/removed/renamed or moved. |
| Persistence | `PersistedAppState`, `SnapshotBuilder`, local persistence files/keys, active workout draft persistence, and restore behavior are out of scope. |
| Model/service/controller logic | `WorkoutSession`, `ProgressEntry`, `SetLog`, `ExerciseProgressionState`, `ProgressionEngine`, `CoachingCoordinator`, `NutritionPhysiqueCoordinator`, `WorkoutHighlightBuilder`, `HealthKitService`. |
| HealthKit | Body weight and workout HealthKit read/write behavior is privacy/data-integrity sensitive. |
| Plan/progression logic | Any changes to plateau, progression readiness, load suggestions, training phase, plan regeneration, or adaptive prescriptions require plan-first approval. |
| Localization | Do not edit `Localizable.xcstrings` or introduce copy-key churn in shell-only work. |
| Watch/Widget/Live Activity | No Progress visual pass should touch shared workout or widget targets. |

## 10. Visual/product diagnosis

Progress already knows its product role better than a generic dashboard: it has a proof headline, "What's improving", recent improvement, momentum, strength/body/volume tabs, and history. The problem is execution risk and hierarchy, not lack of modules.

Current risks:

- Generic dashboard: many modules share the same rounded card treatment and can read as a stack of metrics rather than a guided proof narrative.
- Equal card stack: hero, improving, signal strip, recent improvement, momentum, charts, and history compete instead of clearly escalating from "proof summary" to "evidence".
- Charts without explanation: Strength, recovery, weight, and weekly workouts show data but do not always explain confidence, data maturity, or why the chart matters.
- Fake precision: recovery trend can be synthetic with no real recovery logs; muscle balance can show negative-looking values with absent muscle volume; PRs may be display-ready but not generated.
- Weak hierarchy: the 56pt hero number is strong, but the modules after it have similar visual weight.
- Old STRQ/Forge styling: `ForgeSectionHeader`, `ForgeTheme.accentGradient`, SF Symbols, and repeated secondary grouped backgrounds keep the screen in the older visual language.
- Unclear empty states: Body runway may be masked, history empty route may be unreachable, and Volume after 2 workouts can look populated even when muscle volume is missing.
- Missing proof narrative: there is no single "what STRQ has proven about you" progression from headline to evidence to history.
- Missing anatomy/progress connection: existing licensed anatomy assets are not connected to Progress. This should wait because muscle group data is not reliable enough yet.
- Licensed Figma risk: Chart/report primitives are useful, but copying dashboard/report widgets before data states are captured would make STRQ feel like a purchased analytics kit instead of a coach proof surface.

## 11. Low-risk implementation candidates

Candidates for later implementation after screenshot/state capture:

| Candidate | Why it is lower risk | Required guardrails |
|---|---|---|
| Progress Hero / Proof Summary shell | Highest visible value and mostly display-only if it keeps exact headline/subtitle/badge calculations. | Target only `ProgressAnalyticsView`; no data gates, no new metrics, no route changes, no analytics changes; Licensed Source Mode visual references required. |
| Display-only metric card shell | Signal strip or recent improvement cells can gain stronger hierarchy without changing values. | Preserve all values, labels, ordering, and early/established branch behavior. |
| Empty-state visual shell | Strength baseline, Volume runway, Recent Workouts empty, Consistency empty are display-only. | Do not alter visibility gates; avoid adding fake progress. |
| Section header rhythm | `ForgeSectionHeader` usage can be visually harmonized later. | Do not extract broad shared components or touch localization without scope. |
| Chart container shell without chart logic changes | Improve card chrome around existing Charts. | Leave `Chart`, marks, axes, series, domains, gates, and data sources untouched. |
| Recent history row shell | Session rows can become easier to scan. | Preserve route, row tap, sorting, summary stats, volume delta, PR/down/up tags. |

Best first implementation phase after capture: Progress Hero / Proof Summary shell-only pass. It gives visible value, improves proof hierarchy, and avoids chart/data/model changes if strictly scoped.

## 12. High-risk areas

| Area | Why high risk |
|---|---|
| Chart calculation changes | Charts are tied to fixed windows, chart gates, synthetic recovery, and strength anchor logic. |
| Muscle group data model changes | Current `ProgressEntry.muscleGroupVolume` appears unpopulated on new workout completion; fixing it touches workout completion, models/persistence expectations, exercise muscle mapping, coaching, and plan balance. |
| Bodyweight/HealthKit changes | Body weight can be seeded, logged, synced from HealthKit, and used in nutrition/physique outcomes. |
| Time-range logic | No user-visible range controls exist; adding/changing ranges would alter product behavior and state surface. |
| Session history actions/routes | History row taps, modal sheet, session detail, note display, and workout stats are trust-critical. |
| Analytics/persistence changes | Progress viewed, workout completed, body/nutrition/sleep logging, and persistence contracts must remain stable. |
| PR generation | Display exists, but searched code does not show current PR creation. Adding PR generation is not visual work. |
| Anatomy/progress connection | Licensed anatomy could differentiate Progress, but muscle volume reliability must be solved first. |
| Broad component extraction | The screen has many local calculations; refactoring while restyling risks behavior changes. |
| Small-device chart polish | Axis labels, hero number, four-cell rows, and muscle labels need screenshot QA before changing dimensions. |

## 13. Recommended first implementation phase

Recommended first implementation phase after screenshot/state capture: Progress Hero / Proof Summary shell-only pass.

Why this phase:

- It improves the first viewport and proof narrative without touching models, services, persistence, routes, analytics, assets, localization, or chart data.
- It can use licensed Figma Activity Tracker, Chart, Progress, Trend Label, Badge, and Achievement sources as visual source material while keeping STRQ-owned copy and runtime names.
- It avoids the highest-risk chart, muscle volume, bodyweight/HealthKit, time-range, and session detail areas.
- It can make Progress feel less like a generic dashboard wall by giving the screen one clear proof anchor before the existing evidence modules.

Scope boundary for that future phase:

- Target only the display shell of `headlineHero`, `achievementChips`, and possibly the immediate proof summary wrapper.
- Preserve all current values, conditional branches, `Analytics.shared.track(.progress_viewed)`, `selectedTab`, routes, charts, history, and data sources.
- Require Rork screenshots for fresh, first session, early week, established with charts, body data absent/present, volume data absent/present, small iPhone, and large iPhone before and after.

## 14. Exactly one next implementation prompt

Chosen prompt: A. Progress screenshot/state capture checklist only.

Reason: Progress should not move into Swift visual implementation until current states are captured. Static inspection found state risks that screenshots need to confirm first: synthetic recovery can populate Body with little real data, muscle balance can show negative values when muscle volume is absent, PR display may have no current generation path, and the history empty route may be hidden from the root.

Use this exact next prompt:

```text
Use Licensed Source Mode.

Goal:
Create a docs-only Progress Rork screenshot and state capture checklist before any Progress Swift implementation. This is a QA-prep pass only. Do not modify Swift code, assets, models, services, view models, analytics, localization, tests, Watch, Widget, Live Activity, project files, fonts, or runtime behavior.

Read first:
- docs/strq-product-design-north-star.md
- docs/strq-licensed-figma-foundation-adoption-plan.md
- docs/progress-current-state-risk-inventory.md
- docs/migration-progress-log.md

Target files:
- Create docs/progress-rork-screenshot-state-capture-checklist.md
- Append one concise entry to docs/migration-progress-log.md

Allowed edits:
- Docs only in the two target files above.

Forbidden edits:
- ios/STRQ Swift files
- Assets.xcassets
- project.pbxproj
- Models
- Services
- ViewModels
- Analytics files
- Localizable.xcstrings
- Widget/Watch/Live Activity
- tests
- fonts
- production runtime files

Behavior preservation:
- No runtime behavior changes.
- Do not change Progress calculations, chart gates, chart marks, tab behavior, history routes, analytics, persistence, workout history, bodyweight, nutrition, HealthKit, muscle balance, progression, or PR logic.

Figma Licensed Source Mode:
- No new Figma exports and no implementation in this pass.
- If the checklist references visual inspiration, cite existing licensed source categories only: Activity Tracker 11611:134946, Chart 9129:26029, Progress 9129:207997, Trend Label/Legend, Achievement Badge 9064:106798.

Checklist must cover Rork captures for:
- Progress fresh/no workout
- first workout
- early week with 2-3 workouts
- established normal data
- strong progress/PR/progressing if available
- stalled/regression/volume-down if available
- Body tab with no bodyweight logs
- Body tab with 1 bodyweight seed only
- Body tab with 2+ bodyweight entries
- nutrition off/on if available
- recovery with and without sleep/readiness if available
- Volume tab with absent muscleGroupVolume
- Volume tab with meaningful muscleGroupVolume if available
- Recent Workouts empty/populated
- History route and Session Detail sheet
- small iPhone and large iPhone

Verification commands:
- git status --short --branch
- git diff --name-only
- git diff -- docs/progress-rork-screenshot-state-capture-checklist.md docs/migration-progress-log.md
- git diff --name-only -- ios/STRQ ios/STRQWidget ios/STRQWatch
- rg -n "Progress Rork Screenshot|fresh|first workout|early week|established|strong progress|regression|bodyweight|muscleGroupVolume|History route|Session Detail|small iPhone|large iPhone|Rork QA" docs/progress-rork-screenshot-state-capture-checklist.md
- git diff --check

Rork QA checklist:
- Mark which states can be produced in current Rork data.
- Mark which states need seeded data or owner-provided screenshots.
- Confirm whether Body runway appears or is masked by recovery trend.
- Confirm whether Muscle Balance shows zero/red values when muscleGroupVolume is absent.
- Confirm whether PR cards can appear with current data.
- Confirm no route, action, analytics, or persistence changes occurred.

Push command after successful verification:
git status --short --branch
git add docs/progress-rork-screenshot-state-capture-checklist.md docs/migration-progress-log.md
git commit -m "docs: add progress rork state capture checklist"
git push
```

## 15. Rork QA checklist

Rork QA is required before any Progress visual implementation. It is not required to validate this docs-only inventory, but it is required before changing `ProgressAnalyticsView` or `SessionHistoryView`.

Minimum QA before implementation:

- Capture Progress root on small iPhone and large iPhone.
- Capture Strength tab in no-data baseline and chart-populated states.
- Capture Body tab with body signals absent, bodyweight absent, bodyweight present, nutrition off, and nutrition on where possible.
- Capture Volume tab before 2 workouts, after 2 workouts with absent `muscleGroupVolume`, and with meaningful muscle volume if a fixture exists.
- Capture established state with recent improvement and momentum visible.
- Capture strong progress if PR/progressing data exists.
- Capture regression/stalled/volume-down state if available.
- Capture Recent Workouts empty and populated states.
- Open History route from Progress and capture grouped history.
- Tap a session row and capture Session Detail sheet.
- Check text fit in hero, signal strip, recent improvement cells, chart axes, muscle labels, history rows, and set tables.
- Confirm no in-app actions, routes, analytics events, HealthKit, persistence, workout history, or body/nutrition data change during screenshot capture.
