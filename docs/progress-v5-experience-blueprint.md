# Progress V5 Experience Blueprint

Date: 2026-05-09
Mode: Licensed Source Mode, docs-only experience blueprint

## 1. Executive summary

Current Progress is not good enough for STRQ's product ambition. The recent production slices made Progress more useful and more truthful, but the experience can still read as grey, analytical, modular, and too close to a dashboard. That is below the bar for an app that should feel like one of the best fitness products in the category.

Progress V4 has useful pieces: Weekly Rhythm, Strength/Volume Trend, Recent Evidence, confidence language, and the Training Distribution idea. Those pieces should not be thrown away. They are ingredients, not the final experience.

Progress V5 should make Progress a simple user-facing training story powered by complex data. Users should not feel they are reading a scientific report. They should feel STRQ is showing them what their training is becoming, what is proven, what is still forming, and what the next workout can unlock.

The V5 mandate is: simple on the surface, visually strong in the first viewport, honest about confidence, and complex only under the hood.

## 2. Product thesis

Progress should become the flagship proof surface for STRQ, not a metrics tab.

| Thesis layer | Definition | User-facing promise |
| --- | --- | --- |
| Training Map | A readable map of covered, forming, light, locked, and improving training areas. | "I can see what my training is building." |
| Rhythm Story | A week-by-week cadence story that shows repeatability without streak pressure. | "I understand my training rhythm." |
| Progress Confidence System | A simple confidence state for each claim: calibrating, forming, readable, or confident. | "STRQ is not pretending thin data is proof." |
| Evidence Timeline | A traceable timeline of the sessions, weeks, anchors, and milestones behind each claim. | "I know why STRQ is saying this." |
| Next Unlock Engine | A beginner-friendly explanation of what becomes visible after the next workout, repeated lift, or completed week. | "I have a reason to come back." |
| Future Plan-Impact Loop | A 2027 path where Progress explains how evidence changed training plans and coaching decisions. | "STRQ adapts because of what I have proven." |

Progress V5 should feel like a training map first, an evidence story second, and an analytics surface only when the user asks for depth.

## 3. User layers

| User layer | What they need to understand | What they should see first | What should be hidden or simplified | What motivates return |
| --- | --- | --- | --- | --- |
| First-time gym user | One completed workout starts the record. They do not need to understand charts, anchors, or coverage math. | One next unlock: complete a first session to open the Training Map. | Muscle precision, comparisons, volume deltas, advanced charts, and athlete language. | The promise that the next session makes STRQ more useful. |
| Beginner | Training consistency and broad coverage matter more than perfect metrics. | Weekly Rhythm Fingerprint plus simple Training Map states like Covered, Forming, and Next. | Exact percentages, per-muscle claims, PR claims, plan-impact causality, and dense trend cards. | Visible progress unlocks: repeat a lift, complete a week, fill one light area. |
| Regular lifter | Their recent training has a pattern, and STRQ can show proof without overclaiming. | Training Map, rhythm, strength/volume proof, and recent evidence. | Deep raw charts, full table-style history, unresolved confidence math, and medical/body-report language. | Seeing training areas become more readable and getting proof that sessions are adding up. |
| Athlete | The system should respect that they care about detail, gaps, load, and planning impact. | Confidence, coverage gaps, trend proof, evidence timeline, and deeper analytics doorway. | Beginner reassurance, generic motivation, fake gamification, and simplified labels that erase useful nuance. | Better decisions: what is light, what is stable, what is overexposed, and what the plan should change next. |

The adaptive layer should change density and emphasis, not create four different products. First-time users get a runway; athletes get more surfaced evidence.

## 4. Experience architecture

Progress V5 should not be a normal card stack. It should be a guided surface with one signature first-viewport composition and then progressively deeper proof.

Ideal structure:

1. Top visual hero
   - A dark, visually strong first viewport with the Training Map as the primary signal.
   - Shows one plain-language state: Calibrating, Forming, Readable, Confident, or Needs attention.
   - Uses color as semantic signal only: green for good/completed, amber for forming/caution, red/pink for true risk, steel/teal for system/proof.

2. Training Map
   - The core V5 module.
   - Shows broad training areas as covered, forming, light, locked, or improving.
   - Should feel spatial and memorable, not like another metric card.

3. Weekly Rhythm
   - A rhythm fingerprint from completed workout dates.
   - Shows cadence and repeatability, not a streak game.
   - Keeps open days neutral.

4. Trend proof
   - Strength and volume proof stays secondary.
   - Uses restrained chart grammar and confidence labels.
   - Shows trends only when gates are met.

5. Next unlocks
   - Especially important for first-time users and beginners.
   - Gives one to three clear unlocks, such as "repeat one lift", "complete two training days", or "train one pull movement".

6. Recent evidence
   - A short timeline of real completed sessions and proven events.
   - Each row should answer why the screen is saying what it says.

7. Deeper analytics
   - A doorway for advanced users.
   - Contains raw charts, detailed history, movement breakdowns, and later plan-impact detail.

The first viewport should make the user want to inspect Progress again. The rest of the screen should make them trust it.

## 5. Visual direction from Figma

Licensed Source Mode was used read-only for the selected Figma Progress, Metrics, Health, Goal, History, Chart, Progress primitive, Activity Tracker, and dark smart-fitness sources. Figma is licensed source material for layout, rhythm, density, primitives, and state ideas. STRQ should not copy source branding, copy, assets, or raw screens.

### Adopt directly

| Figma source | What to adopt for STRQ |
| --- | --- |
| `9129:26029` Chart primitives | Restrained line, bar, area, legend, axis, trend-label, and chart-base grammar. Use for trend proof, not a chart wall. |
| `9129:207997` Progress primitives | Linear bars, circular progress, inactive tracks, active tracks, and compact progress states. Use for Training Map, unlocks, rhythm, and confidence. |
| `11604:63724` Steps board | Goal/rhythm/history structure, circular goal treatments, compact metric grid, history rows, and empty/complete goal states. |
| `11604:64937` Hydration board | Calendar grid, level/unlock pacing, suggested-goal concept, and progress ladder thinking. |
| `11604:66184` Mood board | Streak/rhythm grid, monthly proof, history rows, and tag/progress-bar pacing. |
| `11604:63379`, `11604:63724`, `11604:64200`, `11604:66184` | Compact dated history/evidence row anatomy. |

### Adapt

| Figma source | STRQ adaptation |
| --- | --- |
| `11604:62728` Dark Home / Smart Fitness Metrics | Adapt the premium dark density, compact score block, smart metric rail, circular progress, and dashboard pacing. Do not copy the dashboard wall. |
| `11604:63115`, `11604:63236`, `11604:63410`, `11604:63511` | Adapt the dominant value, chart-first detail page, key stats, recommendation/proof sections, and report pacing into restrained trend proof. |
| `11611:134946` Activity Tracker | Adapt onboarding-to-empty-to-goal-complete states, activity-level scaling, circular weekly goal, and first-run progression into beginner/athlete adaptive states. |
| `11604:64200` Weight board | Adapt target scale and goal progress anatomy into Next Progress Unlocks and long-term training target states. |

### Avoid

- Source app branding, source copy, source route structure, and source assets.
- Health or medical claims.
- Manual logging flows from `11604:63709`.
- Filter sheets from `11604:63397`.
- Result confirmation flows from `11604:63679`.
- Orange/red/violet identity from source screens unless semantic meaning requires it.
- Stock-like imagery as the main Progress identity.
- Raw copied layouts.
- Chart walls and repeated generic metric cards.

### Layout anchors

| Anchor | Role in V5 |
| --- | --- |
| `11604:63724` | Primary rhythm/goal/history layout anchor. |
| `11604:64937` | Calendar plus level/unlock pacing anchor. |
| `11604:66184` | Rhythm plus evidence pacing anchor. |
| `11611:134946` | First-time, empty, activity-level, and goal-complete state anchor. |
| `11604:62728` | Dark premium density and smart metric overview anchor. |
| `9129:26029` and `9129:207997` | Primitive grammar for charts, progress tracks, rings, legends, and trend labels. |

## 6. New product features

| Feature | User value | Visual idea | Required data | Complexity | Release priority | Monetization value |
| --- | --- | --- | --- | --- | --- | --- |
| Training Map | Makes Progress instantly understandable and STRQ-owned. | A hero map of training areas with covered, forming, light, locked, and improving states. | Completed sessions, exercise metadata, muscle/pattern mapping, volume/exposure, confidence gates. | High. Mapping and copy must avoid fake precision. | Release V1 must-have in honest/limited form. | High. This can become a Pro-level coaching proof surface later. |
| Weekly Rhythm Fingerprint | Helps users see consistency without streak shame. | 28-day rhythm grid plus four-week cadence bars and a simple weekly read. | Completed workout dates, target days per week, week windows. | Low to medium. Existing production slice already supports the direction. | Release V1 must-have. | Medium. Mostly retention, but supports Pro coaching trust. |
| Next Progress Unlocks | Gives beginners a reason to come back and athletes a clear next signal. | One to three unlock tiles or a compact runway below the hero. | Data maturity, missing signals, completed count, repeated anchors, light coverage areas. | Medium. Needs a taxonomy but can start simply. | Release V1 must-have. | Medium-high. Strong activation and retention value. |
| Progress Replay | Makes progress feel alive by replaying training map/rhythm evolution. | Timeline scrubber or weekly replay of coverage, rhythm, and evidence. | Historical weekly snapshots, coverage history, rhythm history, event memory, Reduce Motion fallback. | Very high. Needs real snapshot memory. | 2027 flagship. | High. Strong Pro/report candidate. |
| Plan Impact Explanation | Shows how Progress changed the plan. | Evidence-to-plan chain: "because this became readable, your plan adjusted here." | Plan before/after, adjustment reason, coach decision provenance, user acceptance/ignore state, outcomes. | Very high. Causality risk is severe. | 2027 flagship. | Very high. This is premium intelligent coach value. |
| Evidence Timeline | Builds trust by showing proof behind the state. | Dated timeline rows with source, signal, and confidence tag. | Completed sessions, volume/rhythm facts, later PRs, coverage events, plan events. | Medium. Start with proven session/rhythm/volume events only. | Release V1 must-have. | Medium-high. Trust drives retention and Pro confidence. |
| Confidence States | Prevents fake precision and makes the system feel honest. | Small semantic labels and progress confidence indicators per module. | Completed count, recency, repeat exposure, comparison baseline, source health, unresolved data rate. | Medium-high. Rules must be centralized later. | Release V1 must-have. | High indirectly because trust supports conversion and retention. |
| Beginner/Athlete adaptive layer | Makes the same screen feel simple to new users and useful to serious users. | Density and module emphasis shift by maturity: runway for beginners, proof density for athletes. | Data maturity, training age proxy, completed workouts, repeat anchors, optional goal/training profile. | Medium. Start display-only, avoid personalization overreach. | V1 lightweight; richer in 2027. | High. Better fit increases retention across segments. |

## 7. Release V1 vs 2027 vision

| Classification | Include | Rationale |
| --- | --- | --- |
| Release V1 must-have | Top visual hero, Training Map in honest/limited form, Weekly Rhythm Fingerprint, Next Progress Unlocks, Evidence Timeline, Confidence States, deeper analytics doorway. | These make Progress simpler, more attractive, more retained, and more STRQ-specific without requiring full 2027 data contracts. |
| Release V1 optional | Richer Strength/Volume Trend proof, limited Muscle Coverage if runtime QA gates pass, adaptive beginner/athlete copy density, compact training mix. | Useful, but should not block the flagship shell if the confidence gates are not ready. |
| 2027 flagship | Progress Replay, Plan Impact Explanation, predictive Training Map, personalized evidence memory, coach-progress feedback loop, confidence-ranked insights. | These can make STRQ category-leading, but only after snapshot, plan provenance, and shared evidence contracts exist. |
| Defer | Manual logging, filters, social/share, broad health dashboards, paywall hooks, full replay without historical snapshots, fake precision, medical-style reports. | These either distract from Progress's role or require contracts that do not exist yet. |

V1 should feel like a flagship surface even if some intelligence is forming. The 2027 vision should feel inevitable because V1 teaches users that each session makes Progress more readable.

## 8. Data complexity hidden from user

Progress V5 can be complex behind the scenes, but the visible UI should stay simple.

| Under-hood logic | User-facing simplification |
| --- | --- |
| Confidence | Show Calibrating, Forming, Readable, or Confident. Do not expose scoring math. |
| Thresholds | Use simple unlock language: "repeat this once", "complete two weeks", "needs more sessions". |
| Muscle coverage | Show broad covered/light/forming areas. Avoid exact per-muscle claims until data is proven. |
| Volume/exposure | Present contribution or training load direction, not raw mixed-unit math. |
| Rhythm | Show cadence and repeat weeks. Do not judge discipline or create streak anxiety. |
| Plan impact | Show only traceable plan changes when provenance exists. Until then, keep it as a future locked insight. |

If the data is thin, the experience should become more helpful, not more vague. The right response to low confidence is Next Progress Unlocks, not empty grey cards.

## 9. Anti-patterns

Progress V5 explicitly rejects:

- Grey dashboard wall.
- Scientific report.
- Repeated cards.
- Fake precision.
- Habit tracker clone.
- Chart wall.
- KI-looking labels or AI-looking labels that sound generated instead of coached.
- Over-explaining.
- Medical/health claims.
- Color used as decoration.
- Anatomy visuals without proven coverage data.
- Pro styling used as ordinary intelligence styling.
- Confetti or reward-board behavior for serious training proof.
- More tabs before the first viewport is strong.

The experience should be visually impressive because it has a strong product idea, not because it has decorative complexity.

## 10. Production path

Recommended path:

1. V5 DEBUG prototype
   - Build a DEBUG-only prototype first.
   - Use demo data only.
   - Include two states: First-time/beginner and Established/athlete.
   - No production Progress route, runtime data, assets, models, services, analytics, localization, Widget, Watch, or Live Activity changes.

2. Rork screenshot review
   - Capture first viewport, full scroll, small iPhone, and large iPhone.
   - Compare whether the screen feels simpler, stronger, and less like a card stack.
   - Confirm first-time/beginner state is not intimidating and established/athlete state is not shallow.

3. Chosen modules
   - Choose which V5 modules graduate: likely Training Map, Weekly Rhythm Fingerprint, Next Progress Unlocks, Evidence Timeline, and Confidence States.
   - Keep deeper analytics as a doorway, not the main surface.

4. Production integration
   - Integrate in slices.
   - Reuse existing production work where useful: Weekly Rhythm, Strength/Volume Trend, and Recent Evidence.
   - Do not productionize demo V5 state.

5. Data gates
   - Every visible claim must have a confidence gate.
   - Muscle coverage and Training Map need runtime QA before confident display.
   - Plan Impact Explanation stays locked until plan-change provenance exists.

6. QA gates
   - Static diff verification.
   - Rork screenshots for first-time, beginner, established, athlete, low-data, readable-data, small iPhone, and large iPhone.
   - Accessibility review for charts, maps, bars, timelines, and non-color labels.
   - Build/CI validation where Swift changes occur in later passes.

## 11. Exactly one next prompt

```text
Create a DEBUG-only Progress V5 Experience Prototype with 2 states:
- First-time/beginner
- Established/athlete

It should use demo data and strong Figma-derived layout, but no production changes.
```
