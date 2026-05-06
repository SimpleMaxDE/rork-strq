# Progress / Analytics Signature Direction Plan

## 1. Executive summary

Progress should become STRQ's proof surface, not a dashboard wall. Its job is to turn training history into a clear progress story: consistency, strength trend, muscle coverage, milestones, recovery-readiness context, and coach-relevant proof the user can trust.

The direction is premium analysis, not generic analytics. Progress should answer whether the user is improving, what changed, what is strong, what is falling behind, which signal is reliable, and why STRQ is worth continuing to use.

Licensed Source Mode is useful here because the Figma kit has real chart, report, progress, trend-label, legend, and activity/dashboard primitives. STRQ should adopt those primitives as evidence language, adapt them to STRQ's training intelligence, and avoid raw dashboard copying.

## 2. Current STRQ Progress inventory

This is a static inventory only. No Swift, asset, model, service, localization, project, test, Widget, Watch, Live Activity, or runtime behavior was changed.

| Area | Current implementation |
| --- | --- |
| Progress tab entry point | `ios/STRQ/ContentView.swift` puts `ProgressAnalyticsView(vm: vm)` inside tab index `3`, wrapped in a `NavigationStack`. The custom tab bar still labels the tab `Progress` and uses SF Symbol `chart.line.uptrend.xyaxis`. |
| Main view | `ios/STRQ/Views/ProgressAnalyticsView.swift` imports `Charts`, defines `ProgressRoute.history`, owns local `selectedTab` and `appeared` state, tracks `.progress_viewed` on appear, and uses `navigationTitle("Progress")`. |
| Top story modules | `headlineHero`, `achievementChips`, `whatsImprovingCard`, `signalStrip`, `recentImprovementCard`, and `momentumBreakdown`. These already try to create a proof hierarchy from workouts logged, lifts progressing, PRs, streak, recovery, volume change, and stalled/progressing exercises. |
| Section selector | A segmented `tabSelector` switches between `Strength`, `Body`, and `Volume`. There is no explicit user-facing time-range control yet. Time windows are mostly hardcoded in each module. |
| Strength modules | `strengthSignals` renders either `strengthChart` or `strengthBaselineCard`, then `prHighlights`, `recentSessionsCard`, and `consistencyHeatmap`. `strengthChart` uses Apple Charts `LineMark` for bench/squat/deadlift labels, while `AppViewModel.strengthProgress` actually derives anchor-lift pattern groups for push, squat, hinge, and pull. |
| Body modules | `bodySignals` gates early/no-signal state through `signalRunwayCard`. When data exists, it shows `goalPaceCard`, `bodyWeightChart`, `recoveryTrend`, and `nutritionAdherence`. Body weight and recovery use `AreaMark` plus `LineMark`; recovery also uses a `RuleMark`. Nutrition adherence uses local bar shapes, not Apple Charts. |
| Volume modules | `volumeSignals` gates early/no-signal state through `signalRunwayCard`. When data exists, it shows `muscleBalanceChart`, `weeklySessionsChart`, and `movementBalanceCard`. Weekly sessions use `BarMark`; muscle and movement balance use custom bars. |
| Empty and early states | Current empty states exist for fresh Progress hero, strength baseline, PRs, recent workouts, consistency heatmap, Body Signals, Volume Signals, and `SessionHistoryView`. They are functional but not yet a premium proof/report system. |
| Filters/time ranges | Current visible filter is the Strength/Body/Volume segment. Internal ranges include 7 days, 14 days, 28 days, 8 weeks, 4-week average, and current month. There is no cohesive range model such as Week/Month/Quarter or "this week vs last week." |
| Muscle or volume signals | `vm.muscleBalance`, `weeklyVolumeByMuscle`, `weeklyStats`, `strengthProgress`, `workoutHistory`, and `progressEntries` provide the current surface. Static read shows `WorkoutController.completeWorkout()` inserts a `ProgressEntry` without populating `muscleGroupVolume`, so any future muscle-coverage/anatomy claim must verify real data before implying precision. |
| Actions/routes | Main route is `NavigationLink(value: ProgressRoute.history)` to `SessionHistoryView(vm: vm)`. `SessionHistoryView` groups completed workouts by month, shows totals, opens `SessionDetailView` in a sheet, and has its own empty state. |
| Analytics touched by Progress | `ProgressAnalyticsView` tracks `.progress_viewed`. Workout completion tracks workout events and inserts `ProgressEntry`. No new analytics should be added in a visual-only Progress pass. |
| View model/data touched by Progress | `AppViewModel` exposes `workoutHistory`, `personalRecords`, `progressEntries`, `progressionStates`, `weeklyStats`, `streak`, `muscleBalance`, `strengthProgress`, `bodyWeightEntries`, `recoveryTrendData`, `nutritionLogs`, `goalPace`, `physiqueOutcome`, `dataMaturityTier`, `isEarlyStage`, and `hasEnoughDataForStrengthChart`. |
| Services/models adjacent to Progress | `ProgressionEngine`, `WorkoutController`, `PersistenceStore`, `Analytics`, `HealthKitService`, and `WorkoutSession.ProgressEntry` are adjacent. They are protected and must not be changed by a visual direction pass. |

## 3. Licensed Figma source inspection

[@Figma](plugin://figma@openai-curated) was used in Licensed Source Mode before writing this plan. The `figma-use` workflow and Plugin API index were loaded first. All Figma access in this pass was read-only metadata inspection; no Figma canvas writes, asset exports, or runtime code changes were attempted.

Figma file key requested: `LBvxljax0ixoTvbvvUeWVC`. The Plugin API reported `headless` as the runtime file key while operating against the requested file key, matching prior STRQ Figma inspection behavior.

| Figma source | Node ID | Availability | Findings |
| --- | --- | --- | --- |
| Chart | `9129:26029` | Available | Confirmed line chart, bar chart, area chart, donut chart, pie chart, trend labels, legends, axes, grid lines, chart lines, and chart base layouts. |
| Progress | `9129:207997` | Available | Confirmed progress bars, circular progress/rings, step tracks, active/inactive tracks, value variants, size variants, and label placement variants. |
| Bonus Dashboard page | `5643:11291` | Available | Page contains 7 dashboard frames with dense chart/report/metric patterns, including chart base layout instances and line chart instances. Useful as report-density reference only. |
| Activity Tracker screen source | `11611:134946` | Available | Large activity-tracker frame set with onboarding/logging/activity score patterns, progress and score language, and activity proof states. Useful for early-stage progress and insight onboarding patterns. |
| Dark Home / Smart Fitness Metrics | `11604:62728` | Available | Contains metric cards, trend labels, circular progress, activity cards, workout card, section headers, and compact health metrics. Useful for small proof modules and trend-label treatment, not for raw Home copying. |

Confirmed chart categories and details:

| Primitive | Confirmed details | Progress use |
| --- | --- | --- |
| Line chart | `Line Chart` component set has Type `Curve/Sharp/Step`, Series `1/2/3`, Points `Dense/Medium/Sparse`. `Line Chart Thumbnail` and `_LineChartThumbnailBase` also exist. | Strength/estimated 1RM trends, volume trend, readiness trend when the story needs continuity over time. |
| Bar chart | `Bar Chart` component set has Series `1/2/3` and Thickness `xs/sm/md/lg`. | Weekly sessions, sets, completed workouts, weekly volume buckets. |
| Area chart | `Area Chart` component set has Series `1/2/3/4`. | Load or body-weight/recovery trend when the filled area communicates accumulation or runway. |
| Donut/pie | `Donut Chart` and `Pie Chart` component sets have Series `2/3/4/5` and half/full variants. | Adherence/completion only when the part-to-whole question is simple. Avoid multi-slice performance decoration. |
| Trend labels | `Trend Label` component set has Size `sm/md/lg/xl`, Trend `Positive/Neutral/Negative`, and Style `Default/Fill`; it uses up/down trend arrows. | Metric deltas, "vs last week", PR count, volume up/down, readiness trend. |
| Legend | `_LegendItem` and `Legend` component sets have Size `sm/md/lg`. | Use only where multiple series need decoding; avoid legends for single obvious signals. |
| Axis/grid/layout | `_ChartBaseLayout`, `_ChartLineLayout`, `_Axis`, `_AxisValueText`, and `_ChartLine` exist. | Adopt spacing, restrained axis density, and baseline/grid hierarchy; do not force axes into tiny mobile cards. |
| Progress bars/rings | `Progress Bar` has 132 variants by Value `0...100`, Size `sm/md/lg`, Label `Bottom/Inline/None/Top`. `Progress Bar Circular` has Sweep `50/75/100`, Size `xs...2xl`, Type `Linear/Step`. | Muscle coverage, plan adherence, goal completion, confidence/readiness proof, and early-stage activation progress. |

Blocked/unavailable Figma nodes: none of the requested nodes were blocked or unavailable in this pass.

Directly adopt:

- Trend label grammar: positive/neutral/negative, compact sizes, icon plus delta.
- Legend grammar where multiple series are genuinely present.
- Progress bar/ring value, size, label-position thinking.
- Chart base layout restraint: light grid, readable axes, clear chart container hierarchy.

Adapt:

- Line/bar/area/donut primitives into STRQ-owned SwiftUI/Charts wrappers and report cards.
- Activity Tracker early-stage patterns into STRQ data-maturity states.
- Bonus Dashboard density into a mobile proof hierarchy, not into a dashboard wall.
- Dark Home metric cards into compact evidence cards with STRQ semantics.

Avoid:

- Raw dashboard frames, source copy, source brand tokens, source orange defaults, leaderboard/reward-wall overuse, dense desktop analytics, fake high-precision charts, and screen-wide kit cloning.

## 4. Product role and user questions

Progress must answer these questions in this order:

1. Am I improving?
2. Did I train consistently?
3. Which muscles are progressing?
4. Which muscles are behind?
5. Is my plan working?
6. What changed this week or month?
7. What should I focus on next?
8. What should I trust?
9. Why should I keep using STRQ?

The product role is proof plus analysis:

| Role | Meaning in STRQ Progress |
| --- | --- |
| Proof | Show earned evidence from real workouts: sessions, PRs, load trends, volume, streak, and training history. |
| Trend understanding | Explain direction, magnitude, and timeframe without pretending every movement is statistically meaningful. |
| Training confidence | Say when the signal is strong, forming, weak, or not yet trustworthy. |
| Muscle coverage | Use anatomy and coverage language to reveal focus, gaps, and imbalance after the data path is verified. |
| Consistency | Show adherence/rhythm as a training signal, not a habit-game scoreboard. |
| Performance signal | Highlight lifts progressing, flat lifts, PRs, and volume changes with coach-relevant interpretation. |
| Coach bridge | Make Progress feed trust back into Coach: "STRQ knows this because your training shows..." |

## 5. Current visual/product diagnosis

The current Progress screen already tries to tell a story and is not a blank stats page. The risk is that future additions could flatten it into many equal cards.

Current likely gaps:

- The screen has many competent modules, but the proof hierarchy can still read as a stack of similarly weighted cards.
- The hero is numeric and energetic, but not yet a full "proof summary" with confidence, timeframe, and strongest evidence.
- Charts use Apple Charts directly with local styling; they do not yet share the licensed Figma report language of trend labels, legends, base layouts, and chart-specific hierarchy.
- There is no cohesive information architecture across Week/Month/8 Weeks/28 Days. Timeframes are internally hardcoded.
- Muscle coverage is currently bar/list based and not yet connected to STRQ's accepted anatomy differentiator.
- Muscle-balance data needs verification before visual anatomy coverage claims, because static inspection shows newly created `ProgressEntry` objects are not obviously populated with muscle volume.
- Empty states exist, but they are mostly explanatory cards rather than premium "signal runway" states that tell the user what STRQ can and cannot know yet.
- The Strength/Body/Volume segments are useful, but they may divide the story before the user sees the answer.
- Recovery/readiness color semantics are still sensitive. Progress uses shared recovery color paths, and prior readiness audit warns against broad global color changes.
- SF Symbols remain visible in Progress. The icon/anatomy map recommends Progress icon replacement later as a report-system pass, not as random icon swaps.

Main risks:

- Generic stats dashboard.
- Too many equal cards.
- Chart overload.
- Fake complexity.
- Unclear metrics.
- Weak empty states.
- No narrative/proof hierarchy.
- Lack of STRQ-specific anatomy/progress integration.

## 6. Information architecture proposal

Do not implement all of this in one sprint. The hierarchy below defines the destination and lets future prompts pick safe slices.

| Section | Job | Primary question | Suggested timing |
| --- | --- | --- | --- |
| Progress Hero / Proof Summary | One-sentence status plus 2-3 proof points and confidence level. | Am I improving, and how sure is STRQ? | First visual shell pass after state inventory. |
| Consistency & adherence | Show sessions, weekly target, 28-day rhythm, streak, and missed/held rhythm. | Did I train consistently? | Early, low risk if display-only. |
| Strength / volume trend | Show estimated strength or workload over time with trend labels and clear timeframe. | What is changing? | Chart primitive adoption pass. |
| Muscle coverage / anatomy map | Show trained vs undertrained areas using anatomy only when data is trustworthy. | Which muscles are strong or behind? | After muscle-volume data verification. |
| PRs / milestones | Surface real records and earned milestones. | What proof should I feel good about? | Low risk if existing PR data only. |
| Recovery-readiness trend | Show whether recovery supports or limits training, without changing readiness logic. | Is my plan working with my recovery? | Later visual pass after color semantics are clear. |
| Weekly/monthly comparison | Compare this week vs last week and this month vs prior baseline. | What changed recently? | Low/medium risk; needs copy clarity. |
| Coach Insight from Progress | One coaching interpretation based on proof modules. | What should I focus on next? | Later, display-only first. |
| Empty / early-stage progress state | Show what is known, unknown, and what unlocks next. | Why should I keep logging? | Early, high retention value. |

Recommended first-screen order:

1. Proof Summary.
2. What Changed.
3. Consistency.
4. Strength/Volume trend.
5. Muscle coverage.
6. Milestones.
7. History/logbook access.

The current Strength/Body/Volume segmented control can remain during transition, but the final direction should lead with a proof narrative before exposing category drill-downs.

## 7. Figma primitive adoption plan

| Figma primitive | STRQ Progress use | Adoption mode | Notes |
| --- | --- | --- | --- |
| Line chart | Strength/estimated 1RM trend, selected lift trend, readiness trend. | Adapt directly. | Use Figma line chart grammar for spacing, line weight, grid restraint, and legends. Do not chart every lift by default. |
| Bar chart | Weekly sessions, weekly sets, volume buckets, consistency. | Adapt directly. | Use for countable periods. Keep labels sparse and readable on small iPhone. |
| Area chart | Load/volume over time, body weight, recovery runway. | Adapt. | Use filled area only when accumulation or runway matters. Avoid decorative fills behind every line. |
| Donut/ring | Adherence, weekly target completion, plan completion, signal confidence. | Adapt selectively. | Use for one simple completion answer. Avoid multi-slice dashboards and fake health-score rings. |
| Pie chart | Rarely needed. | Mostly avoid. | Donut/ring is preferable for mobile adherence. Pie can be ignored unless a clear part-to-whole proof case appears. |
| Trend labels | Metric deltas such as volume up/down, PR count, session change, readiness movement. | Direct adoption as grammar, SwiftUI adaptation as runtime. | This is one of the highest-value primitives because it turns numbers into interpretation. |
| Legend | Multi-series strength or muscle/volume charts. | Direct/adapt. | Use only when series meaning is not obvious. Keep small, horizontal, and near the chart. |
| Axis/grid/layout | Chart readability and premium report structure. | Adapt. | Use restrained grid and axis density. Avoid tiny labels that create chart-wall noise. |
| Progress bars | Muscle coverage, goal completion, weekly target, confidence calibration. | Direct/adapt. | Figma label placement variants map well to compact rows and proof cards. |
| Progress rings | Weekly adherence, signal confidence, readiness support, completion. | Adapt selectively. | One ring per section max unless a true comparison needs more. |
| Anatomy | Muscle coverage and imbalance proof. | Adapt after data check. | Use accepted anatomy as STRQ differentiator, not decoration. Text remains source of truth when anatomy precision is limited. |
| Achievement badge | PRs, milestones, completed streaks. | Adapt. | Use only for real achievements. Avoid gamified badge board. |
| Bonus Dashboard | Report density reference. | Avoid raw copy; adapt only density lessons. | Useful for large charts and metric grouping, but not mobile structure. |
| Activity Tracker | Early signal runway, progress onboarding, activity score style. | Adapt. | Useful for "STRQ is learning" states; ignore source onboarding copy. |
| Dark Home metrics | Compact metric cards and trend-label placement. | Adapt. | Useful for proof cards; do not copy the Home screen into Progress. |

## 8. Progress visual language

Progress should feel:

- Analytical.
- Confident.
- Precise.
- Proof-driven.
- Calm.
- Premium.
- Not gamified.
- Not a generic dashboard.
- Distinct from Coach and Weekly Review.

Screen differentiation:

| Surface | Distinction |
| --- | --- |
| Coach | Decides, explains, and recommends. |
| Weekly Review | Retrospective coach report and action confirmation. |
| Progress | Persistent proof and analysis surface. |

Visual direction by section:

| Section | Visual language |
| --- | --- |
| Proof Summary | Dark, calm, report-like hero with one dominant conclusion, not a celebratory hero. Include timeframe and confidence. |
| Consistency | Compact bars/ring plus clear target language. Avoid streak-only motivation. |
| Strength/Volume | Figma-inspired chart card with title, timeframe, trend label, one chart, and explanation of what counts. |
| Muscle Coverage | Anatomy-first only after data verification; pair with concise coverage bars and "behind/covered" labels. |
| Milestones | Small premium record cards or badge shells tied to real PRs. No trophy wall. |
| Recovery-readiness | Muted evidence card; do not let recovery dominate Progress unless it explains training trend. |
| Empty states | "Signal runway" cards: what STRQ knows, what it cannot know yet, and what unlocks next. |

Color policy:

- Green = improved/completed.
- Amber = monitor/moderate.
- Red/rose = regression/caution.
- Steel/navy = neutral evidence/report.
- Anatomy colors are semantic roles, not final hardcoded values.
- No loud orange default.
- No Pro violet.

Additional color guardrails:

- Do not fill whole sections green, amber, or red.
- Use color as evidence/state, not decoration.
- Do not use red/rose for moderate readiness or normal deload weeks.
- Do not let source orange become STRQ's default chart accent.
- Pro violet is reserved for subscription/value surfaces and should not appear in Progress analytics.

## 9. Data and behavior guardrails

Any implementation following this plan must protect:

- Models.
- Services.
- Analytics.
- Persistence.
- Workout history.
- Plan generation.
- HealthKit.
- Charts data calculations.
- Existing routes/actions.
- Progression state logic.
- Readiness/recovery scoring.
- Nutrition and physique calculations.
- Session history grouping and session detail routing.
- Weekly review generation.
- Coach action logic.
- Widget, Watch, Live Activity, and notification behavior.

Implementation must be view-only unless explicitly scoped. A visual shell pass may restyle static/display cards and chart containers, but it must not change source data, thresholds, time-window calculations, progression decisions, readiness scores, muscle mapping, HealthKit sync, persistence snapshots, analytics events, or route behavior.

Specific muscle/anatomy guardrail:

- Do not claim muscle coverage precision until the `ProgressEntry.muscleGroupVolume` data path is verified. If the data is missing or partial, use early/unknown states or session-derived fallback only after a separately scoped data review.

Specific chart guardrail:

- Chart data calculations should remain existing values in a visual pass. If trend math needs to change, that requires a separate model/data prompt and broader QA.

## 10. Risks and anti-patterns

| Risk | Why it hurts STRQ | Guardrail |
| --- | --- | --- |
| Too many charts | Makes Progress feel like an admin dashboard instead of a training proof surface. | One primary chart per section; use trend labels and prose for the rest. |
| Raw Figma dashboard copy | Would make STRQ feel like a purchased kit with swapped text. | Use primitives, not full dashboard frames. |
| Same card stack as other screens | Erases the screen role distinction from the North Star. | Use report/proof composition unique to Progress. |
| Fake precision | Users lose trust when tiny data becomes confident conclusions. | Show confidence and data maturity. Say when STRQ is still learning. |
| Metrics without explanation | Numbers become trivia. | Pair each key metric with timeframe, delta, and training meaning. |
| Over-coloring | Progress becomes noisy and emotionally misleading. | Steel/navy neutral base, semantic color only for state. |
| Overusing anatomy | Anatomy becomes decoration or implies unavailable precision. | Use anatomy for coverage/imbalance only when data supports it. |
| Hiding empty data badly | Early users leave before proof exists. | Premium signal-runway states that explain what unlocks next. |
| Leaderboard/gamification drift | Makes Progress feel unserious for strength coaching. | Milestones must be earned proof, not reward clutter. |
| Changing behavior during visual work | Risk to training trust and accepted/frozen areas. | View-only by default; protect models/services/routes/analytics. |

## 11. Recommended implementation phases

| Phase | Scope | Risk | Output |
| --- | --- | --- | --- |
| 1. Docs plan | This document and migration-log entry. | Low | Direction, Figma mapping, guardrails, next prompt. |
| 2. Current progress screenshot/state capture | Docs-only or QA-only inventory of early/no data, normal data, strong progress, regression, and device sizes. | Low | Current-state proof before visual changes. |
| 3. Low-risk visual shell pass for static/display cards | Restyle proof summary, signal strip, "what changed", consistency, and empty states without data changes. | Medium | Progress begins to feel like premium proof without touching calculations. |
| 4. Chart primitive adoption pass | Adapt Figma chart base layout, trend labels, legends, and chart card structure around existing chart data. | Medium | STRQ chart/report language. |
| 5. Anatomy muscle coverage plan for Progress | Verify muscle data path, map coverage semantics, define anatomy use before implementation. | Low as docs, high if data changes. | Safe path for Progress anatomy differentiator. |
| 6. Empty-state/early-stage progress pass | Make fresh/first-session/early-week Progress valuable and honest. | Medium | Better activation and trust. |
| 7. Later model/data work only if needed | Populate or recalculate muscle coverage, trend confidence, or time ranges. | High | Only after visual direction and QA show a need. |

## 12. Exactly one immediate next prompt

Recommended next move: **A. docs-only current Progress risk/state inventory**.

Reason: the static implementation is mapped, but safe visual work still needs current screenshots/state capture before changing Progress. This avoids blind Progress redesign, verifies no-data and regression states, and lets the next implementation choose a tight visual shell slice with evidence.

Immediate next prompt:

```text
Use Licensed Source Mode.

Target:
Create a docs-only current Progress / Analytics risk and state inventory before any implementation. Inspect the existing Progress screen statically and capture what states need Rork QA before visual changes: early/no data, first-session, normal data, strong progress, regression/stalled, body-data present/absent, volume/muscle data present/absent, history empty/non-empty, small iPhone, and large iPhone.

Allowed edits:
- Create docs/progress-analytics-current-state-risk-inventory.md
- Append one concise entry to docs/migration-progress-log.md

Forbidden edits:
- Do not modify Swift files.
- Do not modify assets, Assets.xcassets, project.pbxproj, models, services, view models, analytics files, Localizable.xcstrings, Widget, Watch, Live Activity, tests, fonts, or runtime behavior.
- Do not change Progress calculations, data sources, routes, actions, HealthKit, persistence, plan generation, workout history, or analytics events.

Figma usage mode:
- Use @Figma in Licensed Source Mode, read-only only.
- Re-inspect Chart `9129:26029`, Progress `9129:207997`, and any report/dashboard nodes needed only as reference.
- Report what was directly relevant, adapted, ignored, or blocked.
- Do not write to Figma and do not export assets.

Behavior protection:
- This is docs-only. Treat current Progress behavior as protected.
- If a data issue is suspected, document it as a risk; do not fix it.
- If screenshots/Rork capture are not possible in the environment, list required Rork captures explicitly.

Verification:
- git status --short --branch
- git diff --name-only
- git diff -- docs/progress-analytics-current-state-risk-inventory.md docs/migration-progress-log.md
- git diff --name-only -- ios/STRQ ios/STRQWidget ios/STRQWatch
- rg -n "Progress / Analytics Current State Risk Inventory|Figma|early-stage|normal data|strong progress|regression|muscle|history|Rork|guardrail|state inventory" docs/progress-analytics-current-state-risk-inventory.md
- git diff --check

Report back:
1. Files changed
2. Progress states inventoried
3. Figma sources inspected
4. Current risks found
5. Required Rork screenshots
6. Behavior guardrails
7. Verification results
8. Rork QA required or not

Push command after successful verification:
git status --short --branch
git add docs/progress-analytics-current-state-risk-inventory.md docs/migration-progress-log.md
git commit -m "docs: inventory progress analytics current state"
git push
```

## 13. Rork QA checklist

Rork QA is required before a runtime Progress redesign, but not required to accept this docs-only plan.

Future Progress QA should cover:

- Early-stage/no data: 0 workouts, no PRs, no body data, no history.
- First-session: 1 workout, no reliable trends.
- Normal data: several workouts, some sessions/history, limited PRs.
- Strong progress: progressing lifts, PRs this month, volume up, consistency target met.
- Regression/stalled: stalled or regressing lifts, lighter week, missed consistency, lower recovery.
- Different time ranges: 7 days, 28 days, 8 weeks, month, and any future range selector.
- Small iPhone: chart labels readable, cards not cramped, hero text does not wrap badly.
- Large iPhone: hierarchy still feels deliberate, not sparse or dashboard-like.
- Charts readable: axes, legends, trend labels, and bars/lines legible in dark mode.
- No fake conclusions: low-data states say STRQ is still learning.
- No broken empty states: every gated section has a useful runway state.
- Muscle coverage: no anatomy claim without verified coverage data.
- Recovery/readiness: moderate states do not read as danger.
- History route: "All" still opens history and session detail behavior remains intact.
