# Progress V3 Figma Source Map

Date: 2026-05-06
Mode: Licensed Source Mode, read-only Figma inspection
File key: `LBvxljax0ixoTvbvvUeWVC`

## User-Selected Figma Nodes Inspected

All mandatory user-selected nodes were inspected before implementation:

| Node | Useful Pattern Extracted | Used In |
|---|---|---|
| `11604:63074` | Dark smart-metric overview with compact metric tiles, small inline chart previews, and an insight CTA. | Concept A supporting metrics and compact proof rail. |
| `11604:63099` | Editable metric-list density with simple rows and low visual noise. | Not directly used; the list density informed compact switcher sizing. |
| `11604:63115` | Long metric insight report with header, filters, chart modules, status labels, and recommendation blocks. | Concept A report structure. |
| `11604:63236` | Full-screen chart/detail anatomy with dominant graph area, active value, low/high context, and time-range tabs. | Concept A large chart hero and stateful baseline skeleton. |
| `11604:63379` | Date-grouped history list with timestamp, value, and status rows. | Concept A recent proof snippet and Concept B session evidence. |
| `11604:63397` | Filter sheet pattern with stacked controls and bottom action. | Intentionally not used; filtering is not part of this prototype goal. |
| `11604:63410` | Metric detail page with one dominant value, status, recommendation checklist, key stats, and additional stats. | Concept A trend/detail panel and compact supporting metrics. |
| `11604:63465` | Gradient-backed metric insight variant with chart-first proof and a compact recommendation area. | Concept A hero depth, but not its red identity. |
| `11604:63511` | Extended insight report with multiple chart/detail modules and supporting evidence sections. | Concept A source for report pacing and compact evidence hierarchy. |
| `11604:63616` | Zone/detail screen with high/low values and educational zone cards. | Partly adapted into Concept A status rail; educational cards were not copied. |
| `11604:63709` | Manual logging form with fields and notes. | Not used; V3 lab is read-only concept exploration, not entry flow. |
| `11604:63679` | Result confirmation screen with large result readout and CTA. | Not used; completion/CTA flows are outside scope. |
| `11604:63724` | Steps board with insight, history, details, goal setting, empty goal, active goal, and completed-goal states. | Concept B goal progress, baseline/forming/established goal variations, and rhythm proof. |
| `11604:64200` | Weight board with trend chart, history, deadline/calendar, goal setup, goal progress, and completed-goal screens. | Concept B goal scale and weekly target anatomy. |
| `11604:64937` | Hydration board with dashboard, history, detail, calendar rhythm, level ladder, and suggested goal. | Concept B rhythm grid and Concept C distribution/level thinking. |
| `11604:66184` | Mood board with streak, weekly logged grid, history, detail, insight bars, and tags. | Concept B consistency rhythm and Concept A proof/history pacing. |

Helpful optional nodes also inspected:

| Node | Contribution |
|---|---|
| `11604:62728` | Dark smart fitness dashboard density and compact metric modules. |
| `9129:26029` | Chart primitive grammar for line, bar, donut, and thumbnail chart spacing. |
| `9129:207997` | Progress primitive grammar for bars, rings, labels, and baseline percent states. |
| `11611:134946` | Activity tracker patterns for activity choice, rhythm, and insight language. |
| `5643:11291` | Dense dashboard proof cards and dark report modules. |

## Concrete Patterns Adapted

1. Chart-first report hero from `11604:63115`, `11604:63236`, and `11604:63465`.
2. Dominant metric plus status chip from `11604:63236`, `11604:63410`, and `11604:63679`.
3. Compact metric rail from `11604:63074`, `11604:63616`, and `5643:11291`.
4. Recent proof/history rows from `11604:63379`, `11604:63724`, `11604:64200`, and `11604:66184`.
5. Goal progress hero from `11604:63724` and `11604:64200`.
6. Calendar/rhythm grid from `11604:63724`, `11604:64937`, and `11604:66184`.
7. Weekly proof bars from `9129:26029`, `11604:63724`, and `11604:66184`.
8. Progress ring/target scale from `9129:207997`, `11604:63724`, and `11604:64200`.
9. Distribution/level thinking from `11604:64937` and chart primitives.
10. STRQ muscle coverage direction using existing local anatomy assets plus metric dashboard patterns from `11604:62728`.

## Concept Mapping

Concept A: Metric Insight Report
- Uses metric insight/detail sources most strongly: `11604:63115`, `11604:63236`, `11604:63410`, `11604:63465`, and `11604:63511`.
- Directly adopted the idea of one dominant metric report, a chart-first proof surface, compact status labels, key stats, and recent history.
- Adapted the source health metric language into STRQ training proof: anchors, volume, workouts, and recent sessions.

Concept B: Progress Goal / Rhythm System
- Uses goal/history/calendar sources most strongly: `11604:63724`, `11604:64200`, `11604:64937`, and `11604:66184`.
- Directly adopted the goal progress hero, target scale, calendar grid, weekly proof bars, and recent-session evidence.
- Adapted source step/weight/hydration/mood patterns into training rhythm without score-chasing or gamified noise.

Concept C: Training Distribution / Muscle Proof
- Uses distribution/dashboard patterns from `11604:62728`, `11604:64937`, `9129:26029`, and the selected metric boards.
- Directly adopted the idea that progress can be shown as coverage, mix, balance, and recent proof.
- Adapted the source level/distribution grammar into STRQ-owned muscle coverage using existing in-repo anatomy assets only.

## Directly Adopted

- Large report-first chart area.
- Dominant metric value paired with a short status label.
- Compact proof rail instead of a wall of cards.
- Grouped recent proof/history rows.
- Goal progress hero plus target scale.
- Calendar/rhythm grid.
- Weekly proof bars.
- State-aware baseline/forming/established visuals.

## Adapted

- Health metric values became training-proof demo values.
- Source goals became STRQ training baseline/rhythm goals.
- Source history rows became workout evidence rows.
- Source calendar/logging patterns became consistency proof, not input forms.
- Source level/distribution patterns became muscle coverage and training mix.
- Source colors were converted to STRQ carbon, steel, teal, amber, and semantic green where meaningful.

## Deliberately Not Copied

- Source app branding or text.
- Health-specific claims such as medical heart-rate recommendations.
- Raw screen layouts, raw copy, and raw CTA flows.
- Orange default identity, Pro violet styling, rainbow metric dashboards, and source red gradient as a brand direction.
- Device connection, filtering, manual logging, result confirmation, and onboarding flows.
- Any Figma assets or new asset imports.

## Why This Is STRQ-Owned

The final lab uses Figma as licensed source anatomy, not as a pasted screen. The implementation changes the domain from generic health metrics to STRQ training proof, keeps data local and clearly marked as prototype/demo, uses existing STRQ tokens and existing STRQ anatomy assets, and separates the concepts into product directions that could become Progress surfaces later. No source text, source branding, or raw source route is copied.

## Why The Three Concepts Are Distinct

- Concept A is a report: one dominant metric, one chart, compact evidence.
- Concept B is a rhythm system: goal progress, calendar grid, weekly sessions, and proof cadence.
- Concept C is a distribution map: muscle coverage, training mix, balance bars, and recent muscle focus.

## Strongest Concept

Concept C is strongest. It is the most STRQ-specific because muscle coverage and training distribution are harder for a generic dashboard to fake, and it connects directly to STRQ's existing anatomy direction.

## V4 Hybrid Candidate Decision

Progress V4 Hybrid Candidate keeps Concept C as the core direction and folds in the strongest support patterns from Concepts B and A:

- Concept C core: training distribution, front/back muscle coverage, coverage bars, and training mix.
- Concept B rhythm layer: weekly rhythm grid, week-by-week cadence bars, baseline/forming/established state language, and recent session pacing from `11604:63724`, `11604:64937`, and `11604:66184`.
- Concept A detail layer: one restrained strength trend chart and compact status treatment from `11604:63236`, `11604:63410`, and `11604:63074`.

The V4 pass deliberately avoids promoting any V3 concept directly. It uses the selected Figma nodes as licensed source patterns, not copied screens, and keeps all values local to the DEBUG-only candidate.

## Weakest Concept

Concept A is weakest. It is useful and visually clearer than the current card stack, but chart-first metric reports are common enough that it needs the strongest STRQ copy and production data model to avoid drifting generic.

## Production Integration Later

Production integration would require:

- A real Progress data contract for training anchors, volume trend, consistency windows, and muscle distribution.
- Trust gates for baseline/forming/established states.
- A production design decision on which concept, or hybrid, is chosen.
- Accessibility QA for charts, body coverage, and calendar grids.
- Rork screenshot QA across 0, early, and established user states.
- macOS/CI build validation.
- No production route replacement until the selected concept has data semantics and tests.
