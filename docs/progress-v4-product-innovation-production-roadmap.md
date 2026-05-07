# Progress V4 Product Innovation & Production Roadmap

Date: 2026-05-07
Mode: Licensed Source Mode, docs-only production roadmap

## 1. Executive summary

Progress V4 is promising, but it is not production-ready. The DEBUG-only Hybrid Candidate has the right strategic center: Training Distribution and Muscle Coverage as the core, Weekly Rhythm as the consistency layer, Strength Trend as a supporting detail, Recent Evidence as the proof timeline, and Baseline/Forming/Established states to avoid fake precision.

The next move should not be more UI polish. Progress needs product innovation: a proof engine that explains what STRQ can know from real training, what is still forming, and what becomes measurable next. V4 should become a phased production system, not a single screen replacement.

Release V1 must be valuable and truthful. It should show real completed-workout evidence, readable weekly rhythm, cautious strength and volume trends, confidence states, and recent proof. It should not ship replay, predictive imbalance, plan-impact claims, or coach feedback loops before the data contracts are proven.

The 2027 vision can be more ambitious. Once STRQ has reliable muscle-volume, plan-change, coach-decision, and evidence-memory contracts, Progress can become one of the app's premium differentiators: coverage replay, predictive training maps, coach-adjusted plan impact, and personalized milestone reports.

Licensed Source Mode note: this roadmap uses the existing source-map docs plus a read-only @Figma metadata check of the V4 source nodes `11604:64937`, `11604:63724`, `11604:63236`, `11604:66184`, Chart `9129:26029`, and Progress `9129:207997`. The Figma source remains pattern reference only; no Figma canvas write, asset export, Swift edit, or runtime change was made.

## 2. Current V4 candidate summary

The V4 Hybrid Candidate is the strongest Progress direction because it is STRQ-specific. It does not lead with generic analytics. It leads with whether training distribution is becoming readable.

| Area | Current V4 candidate state | Production read |
| --- | --- | --- |
| Training Distribution core | The hero combines front/back body coverage, muscle coverage bars, workouts/window/signal, and maturity labels. | Strongest product idea. Keep as the core, but production needs a real data contract before any confident coverage claim. |
| Weekly Rhythm layer | A 35-day grid and week columns show cadence across recent sessions. | High V1 potential because real session dates are likely available. Should become the consistency layer. |
| Strength Trend detail | A restrained trend module shows status, trend value, window, and line chart. | Useful supporting detail, not the main differentiator. Can ship if it uses existing strength/volume data with confidence gates. |
| Recent Evidence timeline | Dated proof rows explain what happened and why STRQ believes a signal exists. | Critical trust layer. Production needs event extraction from completed sessions, PRs, volume deltas, and rhythm changes. |
| Baseline/Forming/Established states | Prototype states keep low-data users from seeing fake conclusions. | Must survive production. Production labels should likely become Baseline, Forming, Readable, and High Confidence. |
| Demo-data-only status | All V4 data is local DEBUG demo data inside `ProgressV4HybridCandidateView.swift`. | Nothing is production-wired. No V4 product claim should be treated as real until contracts are audited. |
| Current visual caveats | Body coverage is compelling, but still prototype-heavy. Training mix labels are clearer after refinement. Anatomy and coverage can overpromise if data is weak. | Design is directionally valuable, but production should prioritize truthful states over exact prototype visuals. |
| Why stronger than old Progress | V4 has a distinct STRQ identity: muscle coverage, rhythm, evidence, and confidence. Existing Progress is improved, but can still read like a chart/report stack. | V4 should guide production Progress away from a generic dashboard wall toward an owned proof system. |

Demo-only pieces:

- Local baseline/forming/established demo values.
- Local front/back overlay layer choices.
- Local percent coverage values.
- Local training mix distribution.
- Local evidence rows and tags.
- Any implied four-week conclusion that is not backed by real production data.

Production candidates:

- Weekly Rhythm from completed session dates.
- Training Distribution summary from real completed workouts and exercise muscle metadata.
- Strength/Volume Trend from existing workout history and chart sources.
- Recent Evidence Timeline from real session events.
- Proof Confidence states from data maturity, sample size, recency, and comparison-window health.

## 3. Product innovation thesis

STRQ Progress should become the proof engine for an intelligent training coach app.

Generic fitness apps show charts. STRQ should show why the app believes training is becoming consistent, balanced, and coachable. The difference is not more metrics. The difference is readable signals with honest confidence.

STRQ-owned Progress language:

| Product idea | What makes it different |
| --- | --- |
| Readable signals instead of fake metrics | STRQ should say "forming" when the evidence is thin and "readable" only when the baseline exists. |
| Muscle/training coverage instead of only charts | The user should understand which training areas are covered, light, or not yet known. |
| Rhythm and consistency as proof | Training cadence should be treated as evidence, not just streak decoration. |
| Evidence Timeline | Every conclusion should be traceable to recent workouts, PRs, volume shifts, or rhythm events. |
| Next Progress Unlocks | Early users need to know what becomes measurable after the next workout, week, or repeat exercise. |
| Future Coach-plan loop | Progress should eventually explain how Coach changed the plan because of proved training evidence. |

The product promise: Progress proves what STRQ has learned from the user's actual training, shows what is still forming, and creates a reason to keep logging because each session unlocks sharper coaching.

## 4. Feature candidate inventory

| Feature candidate | User value | Monetization value | Data required | Current data availability | Implementation risk | Product trust risk | Visual value | Release priority | Notes |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Training Coverage Map | Shows whether recent training covers the user's program instead of only listing sessions. | High if tied to Pro coaching and plan adaptation. | Completed sessions, exercises, muscle metadata, pattern mapping, confidence gate. | Partly available; session/exercise data likely exists, stable coverage contract does not. | High. | High if coverage is wrong or too precise. | Very high. | V1, cautious | Ship as a summary and baseline/forming/readable state first, not predictive heat-map precision. |
| Muscle Coverage / Distribution | Reveals push, pull, legs, posterior, core, and muscle-group emphasis over time. | High for Pro differentiation if trustworthy. | Primary/secondary muscles, set or volume weighting, muscleGroupVolume or derived sets, four-week baseline. | Source uncertain; `ProgressEntry.muscleGroupVolume` exists but workout completion currently creates entries with an empty map. | High. | Very high. | Very high. | V1.5 or V1 only if audited | This is the signature idea, but it needs the real data contract audit before production confidence. |
| Weekly Rhythm Fingerprint | Shows whether the user's week has a repeatable cadence. | Medium-high for retention; can support Pro habit coaching. | Completed session dates, profile target days, current week and recent weeks. | Existing source likely available through `workoutHistory`, `weeklyStats`, and streak logic. | Low-medium. | Low if phrased as cadence, not discipline judgment. | High. | V1 | Best first real module after contract audit. |
| Strength Trend | Shows whether anchor strength is moving and whether the trend is reliable. | Medium; supports Pro coaching value but is common if chart-only. | Completed sets, reps, weight, exercise movement patterns, repeat anchors. | Existing source likely available through `strengthProgress` and `hasEnoughDataForStrengthChart`. | Medium. | Medium if anchor labels mismatch movement-pattern reality. | Medium-high. | V1 | Keep supporting, not hero. Add confidence and timeframe copy. |
| Volume Trend | Shows workload direction and whether training load is rising, stable, or lighter. | Medium; useful for trust and plan value. | Completed sessions, total volume, sets, week windows, prior comparison. | Existing source likely available through `WorkoutSession.totalVolume`, `ProgressEntry.totalVolume`, and `weeklyStats`. | Medium. | Medium if comparing random weeks or ignoring low-data states. | Medium. | V1 | More monetizable when tied to plan quality or recovery later. |
| Recent Evidence Timeline | Explains the proof behind the state: session, PR, volume, rhythm, gap filled, recovery slot. | High for trust and retention; makes intelligence visible. | Event extraction from sessions, PRs, highlights, volume deltas, rhythm days. | Partly available; WorkoutHighlights exists, PR generation path is uncertain. | Medium-high. | Medium if events are stale, duplicated, or overclaimed. | High. | V1 | Start with completed sessions and simple volume/rhythm evidence. Add PRs only when verified. |
| Proof Confidence States | Tells users whether STRQ is calibrating, forming, readable, or high confidence. | High because it makes paid intelligence feel honest. | Completed count, recency, weeks trained, repeat anchors, comparison windows, optional readiness/body logs. | Partly available through `DataMaturityTier` and `CoachingConfidence`; V4-specific confidence is missing. | Medium. | High if label math is vague or inconsistent. | Medium-high. | V1 | Must ship to protect trust. Keep thresholds simple and documented. |
| Next Progress Unlocks | Shows what becomes measurable next, especially in early states. | Medium-high for activation and retention; light Pro upsell possible. | Data maturity, missing contracts, target next workout/week/repeat anchor. | Partly available through early-state guidance; V4 unlock taxonomy is missing. | Low-medium. | Low if phrased as educational and truthful. | Medium. | V1.5, maybe V1 empty states | Strong activation value. Avoid gamification. |
| Progress Replay | Animated history of coverage and rhythm evolving week by week. | High Pro feature if the underlying memory is real. | Week snapshots, historical coverage, rhythm, evidence memory, animation model. | Missing/new required. | High. | High if generated from thin or backfilled data. | Very high. | 2027 | Do not ship in 2026 V1. Needs snapshot history. |
| Plan Impact Explanation | Shows how progress evidence changed the plan. | Very high Pro monetization and coach value. | Plan before/after, coach adjustment, evidence reason, user acceptance, outcome tracking. | Partly available via `coachAdjustments`, `PlanEvolutionSignal`, current plan, previous plan, but impact narrative contract is missing. | High. | Very high if it claims causality without tracking. | High. | 2027 | Needs plan-change provenance and outcome memory. |
| Coach + Progress Feedback Loop | Lets Coach use Progress proof and lets Progress show Coach decisions based on proof. | Very high; this is premium intelligent coach territory. | Shared evidence store, coach decision logs, plan changes, confidence, outcomes. | Source uncertain; insights/recommendations exist, stable feedback-loop contract does not. | Very high. | Very high if Coach and Progress disagree. | High. | 2027 | Build after V1 proof modules and plan-impact audit. |

## 5. Data contract map

| Data need | Existing source likely available | Existing source uncertain | Missing/new required | Protected system involved | Model/service change required |
| --- | --- | --- | --- | --- | --- |
| Completed workouts | `AppViewModel.workoutHistory.filter(\.isCompleted)` and `totalCompletedWorkouts`. | No major uncertainty. | None for read-only V1. | Workout history, persistence, active workout completion. | No for V1 display. |
| Session dates | `WorkoutSession.startTime`, `endTime`, weekly scans, `weeklyActivity`. | No major uncertainty. | Centralized rhythm-window helper may be useful. | Workout history and date logic. | No for V1, yes if centralizing. |
| Session duration | `WorkoutSession.endTime - startTime`, `ProgressEntry.workoutDuration`, `averageSessionDuration`. | Duration can be zero if session has no end time. | Duration validity rules for evidence events. | Workout completion, persistence, HealthKit export. | No for simple V1 display. |
| Total sets | Completed `SetLog` count and `ProgressEntry.totalSets`. | No major uncertainty. | None for V1. | Workout completion, set logging. | No. |
| Total volume | `WorkoutSession.totalVolume`, `ProgressEntry.totalVolume`, `weeklyStats.volume`. | Existing local week comparisons are duplicated in views. | Stable comparison-window contract for V4. | Workout completion, persistence, charts. | No for read-only V1; yes for shared service. |
| Exercises performed | `WorkoutSession.exerciseLogs`, `ExerciseLog.exerciseId`, `ExerciseLibrary`. | Need to define whether partial logs count. | Evidence extraction rules. | Exercise library, workout session. | No for V1 read-only. |
| Primary/secondary muscles | Exercise metadata and ExerciseDBPro `targetMuscles`/`secondaryMuscles`; local exercise model exposes primary/secondary muscle concepts. | Mapping between imported source terms and STRQ major groups is not fully documented for Progress. | Stable STRQ muscle taxonomy for Progress. | Exercise data, ExerciseLibrary, anatomy mapping. | Yes for robust coverage. |
| Muscle group volume | `ProgressEntry.muscleGroupVolume` field and `vm.muscleBalance`. | Current completion creates `ProgressEntry` with empty `muscleGroupVolume`; legacy/demo data may differ. | Real population or derived fallback contract. | `WorkoutController`, `ProgressEntry`, persistence, exercise mapping, SmartVolumeEngine. | Yes. |
| Push/pull/legs/posterior/core mapping | SmartVolumeEngine has major-group set counting; Progress V4 uses Push, Pull, Legs, Core, Posterior labels. | Posterior/core rules need product definition and consistency with plan logic. | Production mapping table and weighting rules. | Exercise library, SmartVolumeEngine, plan balance, Progress. | Yes. |
| Recent weeks baseline | `workoutHistory`, `progressEntries`, and existing 7/28-day local calculations. | Baseline window differs across current modules. | Shared V4 baseline-window rules. | Progress charts, Weekly Review, plan evolution. | Yes if shared. |
| Four-week comparison window | `muscleBalance` uses four-week `progressEntries`; PlanEvolution uses lookback weeks. | Current `muscleBalance` window depends on entry count and empty volume map. | Audited four-week comparison contract. | ProgressEntry, PlanEvolution, WeeklyReview. | Yes for muscle coverage. |
| Recovery/readiness context | `recoveryScore`, `effectiveRecoveryScore`, `readinessHistory`, `sleepEntries`, recovery trend data. | Recovery trend can be synthetic/contextual rather than direct user input. | V4-specific rule for when recovery can support a progress claim. | Readiness, sleep, HealthKit-adjacent logic, Coach. | No for context labels; yes for confidence integration. |
| PR/anchor events | `PersonalRecord`, `SetLog.isPR`, `WorkoutHighlights`, `strengthProgress` anchors. | Static inspection suggests display exists but PR creation/insertion path is unclear. | Verified PR event source or PR-free evidence fallback. | Workout completion, highlights, progression. | Yes if PR timeline is V1. |
| Plan changes | `currentPlan`, `coachAdjustments`, `previousPlanBeforeWeekAction`, plan edit/action methods. | Plan-change provenance is not a clean Progress contract. | Plan impact event model with before/after and reason. | Plan generator, coach actions, persistence, analytics. | Yes. |
| Coach decisions | `SmartInsight`, `Recommendation`, `PlanEvolutionSignal`, `CoachAction`, coaching memory. | Decision history and outcome tracking are not stable as a Progress source. | Shared coach-decision/evidence memory. | Coach, PlanEvolution, CoachingMemory, analytics. | Yes. |
| Consistency cadence | `weeklyStats.sessions`, `streak`, `weeklyActivity`, session dates, profile `daysPerWeek`. | Need separate "rhythm" from streak/readiness activity. | Weekly Rhythm Fingerprint contract: trained days, target, gaps, repeatability. | Workout history, notifications/reminders if linked later. | No for V1 display, yes for advanced cadence. |

## 6. Release V1 scope recommendation

Release V1 should prove the product idea without overbuilding. It should use real completed-workout data and conservative confidence states. It should not try to deliver the full 2027 coach intelligence loop.

| Classification | Features | Reason |
| --- | --- | --- |
| Must ship | Training Distribution summary, Weekly Rhythm, Strength/Volume Trend, Recent Evidence, Proof Confidence | These make Progress feel like STRQ's proof engine while staying achievable if data contracts are audited first. |
| Should ship | Early-user Next Progress Unlocks, cautious Muscle Coverage / Distribution if real data is verified, evidence labels explaining what counts | These improve activation and trust, but should degrade to baseline/forming states if data is missing. |
| Nice to have | Anatomy-enhanced muscle progress, richer volume trend explanations, compact comparison chips, Pro preview affordance for deeper analysis | Useful, but not required for the first truthful production version. |
| Do not ship yet | Progress Replay, Plan Impact Explanation, full Coach + Progress Feedback Loop, predictive coverage, imbalance forecast, milestone narrative reports | These need historical snapshots, coach-decision provenance, and stronger service/data contracts. |

Recommended Release V1 product shape:

- Training Distribution summary: show covered/forming/locked areas from verified real data, with no precision beyond the contract.
- Weekly Rhythm: show recent cadence from completed session dates and profile target.
- Strength/Volume Trend: show existing trend data with baseline/readable gates.
- Recent Evidence Timeline: show completed sessions and simple evidence events from real data.
- Proof Confidence: show Baseline, Forming, Readable, and High Confidence based on documented thresholds.
- No Progress Replay yet.
- No Plan Impact Explanation yet.
- No full Coach feedback loop yet.

## 7. 2027 forward-looking differentiators

| 2027 differentiator | Why it is valuable | What it needs |
| --- | --- | --- |
| Progress Replay animation | Makes training history feel alive and premium: users can watch coverage and rhythm evolve over weeks. | Weekly snapshots, stable coverage history, replay state model, Reduce Motion support. |
| Predictive training coverage | Shows where the plan is likely to leave gaps before the week ends. | Current plan, scheduled workouts, completed workouts, muscle mapping, confidence and uncertainty display. |
| Muscle imbalance forecast | Warns that a pattern may become undertrained before it becomes a problem. | Multi-week muscle volume or set coverage, thresholds, focus-muscle context, false-positive controls. |
| Coach-adjusted plan impact | Explains "Coach changed this because your Progress showed that." | Plan before/after, adjustment reason, evidence link, accepted/ignored state, outcome tracking. |
| Next unlock prompts | Gives each user a clear reason to keep training: repeat anchor, complete week, fill pull gap, log recovery. | Unlock taxonomy, maturity rules, personalized missing-signal detection. |
| Confidence-ranked insights | Sorts progress insights by evidence quality, not visual flash. | Confidence scoring per module, recency, sample size, source quality, contradiction handling. |
| Weekly body/training map evolution | Shows body/map changes week by week without pretending medical precision. | Anatomy coverage assets, stable mapping, weekly snapshots, accessibility summaries. |
| Personalized evidence memory | Lets STRQ remember what proved useful for this user and surface it later. | Evidence event store, coach memory, privacy-safe persistence, stale-event expiry. |
| Milestone narrative reports | Creates premium weekly/monthly reports that feel authored by STRQ, not generated by a dashboard. | Evidence extraction, milestones, confidence labels, natural-language templates, localization strategy. |

These features can make STRQ feel ahead in 2027 because they connect training history, plan reasoning, and coach behavior. They should be Pro-tier candidates only after V1 proves the data is real.

## 8. Monetization / retention relevance

| Product value | Features that help | Honest read |
| --- | --- | --- |
| User retention | Weekly Rhythm, Evidence Timeline, Next Progress Unlocks, milestone reports | Retention comes from showing that each logged session makes STRQ smarter. |
| Pro conversion | Coach + Progress Feedback Loop, Plan Impact Explanation, predictive coverage, confidence-ranked insights | The most monetizable features explain why Pro coaching changes are intelligent. |
| Trust | Proof Confidence, Evidence Timeline, Baseline/Forming states | Trust is monetizable indirectly because users keep paying for systems that do not fake certainty. |
| Habit formation | Weekly Rhythm Fingerprint, unlock prompts, recent proof | These are retention engines more than direct paywall features. |
| Perceived intelligence | Training Coverage Map, muscle distribution, plan impact, coach loop | Intelligence must be backed by data. Fake intelligence is worse than plain UI. |
| Coaching value | Plan Impact Explanation, muscle imbalance forecast, personalized evidence memory | Best Pro fit, but requires strong service/data contracts. |
| App differentiation | Anatomy-enhanced coverage, Progress Replay, STRQ-owned proof language | Strong visual and product distinctiveness if not overused. |

Likely monetizable:

- Plan Impact Explanation.
- Coach + Progress Feedback Loop.
- Predictive coverage and imbalance forecast.
- Progress Replay as a premium report feature.
- Confidence-ranked insights and personalized evidence memory.

Mostly retention/trust, not direct monetization:

- Weekly Rhythm.
- Basic Evidence Timeline.
- Proof Confidence states.
- Release V1 Training Distribution summary.

Mostly nice UI unless backed by data:

- A prettier chart shell.
- Anatomy visuals without verified muscle coverage.
- Animated replay without real historical snapshots.
- Vague "balanced" labels that do not explain the evidence.

## 9. Production integration phases

| Phase | Scope | Allowed files likely | Forbidden files | Risk level | Required QA | Expected payoff |
| --- | --- | --- | --- | --- | --- | --- |
| Phase 0: docs roadmap | This roadmap and migration log. | `docs/progress-v4-product-innovation-production-roadmap.md`, `docs/migration-progress-log.md`. | Swift, assets, project, models, services, localization, tests, runtime files. | Low | Static docs verification. | Aligns product, data, release, monetization, and risk before code. |
| Phase 1: real data contract audit | Docs-only audit of V4 modules against actual models/services. | New docs audit and migration log. | Swift/runtime changes. | Low | `rg` and static contract verification. | Prevents fake production wiring. |
| Phase 2: production skeleton behind feature flag or DEBUG-only production preview | View shell with real module boundaries but no new data claims. | Progress view files only if explicitly scoped; maybe feature flag config if existing. | Models/services/assets/project/localization unless approved. | Medium | Rork screenshots for low-data and established states, build validation. | Creates a safe landing zone. |
| Phase 3: Training Distribution with real completed workout data | Basic distribution from completed sessions and verified muscle/pattern mapping. | Progress UI plus a scoped data adapter/service if approved. | Workout completion mutation unless specifically scoped. | High | Unit/static checks for mapping, Rork states, no fake coverage. | First STRQ-owned proof module. |
| Phase 4: Weekly Rhythm with real session dates | Cadence grid, week summaries, target comparison from completed sessions. | Progress UI or adapter. | Notification scheduling, reminders, onboarding, analytics changes. | Medium | Date/window QA, small/large iPhone screenshots. | High retention value with relatively low data risk. |
| Phase 5: Strength/Volume Trend with existing chart data | Trend modules using existing strengthProgress and volume windows. | Progress UI and read-only adapter. | Strength formula, progression engine, workout history logic. | Medium | Chart gates, low-data states, label consistency. | Makes V1 feel analytical without becoming chart wall. |
| Phase 6: Recent Evidence event extraction | Session, rhythm, volume, anchor, and optional PR evidence rows. | New read-only evidence builder/service if approved. | Workout completion, PR generation, analytics unless scoped. | Medium-high | Event fixtures, stale/duplicate checks, localization plan. | Makes intelligence explainable. |
| Phase 7: Next Unlocks / Coach link | Early unlocks and first read-only bridge to coach insights. | Progress UI plus contract docs/service only after audit. | Plan mutation, coach actions, persistence schema changes unless approved. | High | Cross-screen consistency QA. | Improves activation and Pro narrative. |
| Phase 8: 2027 Progress Replay | Historical coverage/rhythm replay and premium reports. | New snapshot model/service, Progress UI, possibly paywall hooks after approval. | Anything unscoped in training logic, Watch/Widget, HealthKit. | Very high | Snapshot migration, performance, accessibility, Rork, build, regression QA. | Major premium differentiator. |

## 10. Production risk map

| Risk | Why it matters | Guardrail |
| --- | --- | --- |
| Fake precision | Users lose trust if two workouts become a confident body map. | Baseline/Forming/Readable/High Confidence gates must be explicit. |
| Wrong muscle distribution | Bad mapping can make STRQ look like it does not understand training. | Audit primary/secondary muscles, weighting, and major-group mapping before shipping. |
| Misleading confidence | Confidence labels become decoration if thresholds are vague. | Document thresholds and tie labels to sample size, recency, and source health. |
| Low-data overclaiming | Fresh users need motivation, not invented analysis. | Use Next Progress Unlocks and locked/forming states. |
| Stale demo copy accidentally shipping | DEBUG prototype language can leak into production. | No local demo values, no prototype strings, no hardcoded fake evidence in production. |
| Data-model changes breaking training logic | Workout completion, ProgressEntry, SmartVolume, and plan logic are sensitive. | Docs audit first; model/service changes require separate scoped prompt and QA. |
| Overbuilding before release | 2027 ideas could slow 2026 V1. | Ship truthful V1 proof modules first; defer replay/forecast/plan impact. |
| User confusion | Too many modules can feel like a dashboard wall. | One proof hierarchy: distribution, rhythm, trend, evidence. |
| Performance/bundle risk | Anatomy and replay can add assets, rendering, and animation load. | Use existing assets carefully, avoid broad imports, respect Reduce Motion. |
| Accessibility | Body maps and charts can become color-only proof. | Add textual summaries, VoiceOver labels, chart alternatives, and non-color state labels. |
| Localization | Evidence and plan-impact copy can explode into unplanned strings. | Plan copy keys and templates before Swift integration. |

## 11. Design/system guardrails

- Do not return Progress to a generic card stack.
- Do not overuse Anatomy. Anatomy is for muscle coverage and explanation when data supports it, not decoration.
- Do not make Progress a chart wall.
- Avoid loud orange as default Progress identity.
- Keep V4's STRQ-owned muscle/rhythm identity.
- Use Figma patterns as source but adapt to STRQ. Adopt report hierarchy, chart restraint, progress states, rhythm grids, and evidence pacing; do not copy source screens, text, branding, assets, or color identity.
- Keep Baseline/Forming/Readable/High Confidence states.
- No fake conclusions. If the source is missing, show locked, forming, or next unlock.
- Pair every insight with timeframe and evidence source.
- Keep Weekly Rhythm separate from streak gamification.
- Let Training Distribution lead, but keep Strength Trend as a supporting detail.
- Keep Recent Evidence as proof, not a notification feed.
- Do not let Pro styling override semantic training states.
- Do not add a full Coach loop until Coach and Progress share the same evidence contract.

## 12. Recommended immediate next step

Choose exactly one next step: **A. docs-only real data contract audit for V4 modules**.

Why A: the roadmap shows the product direction is strong, but the production contracts are not clear enough. The biggest blocker is not visual polish; it is whether STRQ can truthfully compute muscle coverage, training distribution, confidence, evidence events, and later plan impact from real data. Weekly Rhythm is likely ready sooner than the rest, but shipping it first without the full V4 data audit risks building a partial Progress architecture that cannot carry the signature muscle/rhythm system.

Do not choose B yet because a skeleton before the audit can freeze weak boundaries. Do not choose C or D yet because both should inherit the same data contract. Do not choose E because more V4 visual polish will not answer the production questions.

## 13. Exactly one next prompt

```text
Use Licensed Source Mode.

Target:
Create a docs-only real data contract audit for Progress V4 production modules. Audit whether Training Distribution, Muscle Coverage / Distribution, Weekly Rhythm, Strength Trend, Volume Trend, Recent Evidence Timeline, Proof Confidence, and Next Progress Unlocks can be produced from current STRQ data without fake precision.

Read first:
- docs/progress-v4-product-innovation-production-roadmap.md
- docs/progress-current-state-risk-inventory.md
- docs/progress-analytics-signature-direction-plan.md
- docs/progress-v3-figma-source-map.md
- docs/strq-human-body-overlay-component-plan.md
- docs/migration-progress-log.md
- ios/STRQ/Models/WorkoutSession.swift for static reference only
- ios/STRQ/ViewModels/AppViewModel.swift for static reference only
- ios/STRQ/Services/WorkoutController.swift for static reference only
- ios/STRQ/Services/SmartVolumeEngine.swift for static reference only
- ios/STRQ/Services/PlanEvolutionEngine.swift for static reference only
- ios/STRQ/Views/ProgressAnalyticsView.swift for static reference only
- ios/STRQ/Views/Debug/ProgressV4HybridCandidateView.swift for static reference only

Allowed edits:
- Create docs/progress-v4-real-data-contract-audit.md
- Append one concise entry to docs/migration-progress-log.md

Forbidden edits:
- Do not edit Swift files.
- Do not edit assets, Assets.xcassets, project.pbxproj, models, services, view models, analytics files, Localizable.xcstrings, Widget, Watch, Live Activity, tests, fonts, or production runtime files.
- Do not wire data.
- Do not modify runtime behavior.
- Do not add feature flags.
- Do not create or edit fixtures.

Behavior protections:
- Treat workout completion, ProgressEntry writing, workout history, muscleBalance, strengthProgress, recovery/readiness, PRs, plan changes, coach decisions, analytics, persistence, HealthKit, and localization as protected.
- If a contract is missing or uncertain, document it. Do not fix it.
- Separate "existing source likely available", "existing source uncertain", and "missing/new required".
- Identify which V4 modules can be V1, V1.5, 2027, or deferred based on real data readiness.
- Call out any fake-precision risk explicitly.

Verification:
- git status --short --branch
- git diff --name-only
- git diff -- docs/progress-v4-real-data-contract-audit.md docs/migration-progress-log.md
- git diff --name-only -- ios/STRQ ios/STRQWidget ios/STRQWatch
- rg -n "Progress V4 Real Data Contract Audit|Training Distribution|Muscle Coverage|Weekly Rhythm|Strength Trend|Volume Trend|Recent Evidence Timeline|Proof Confidence|Next Progress Unlocks|existing source likely available|existing source uncertain|missing/new required|Release V1|V1.5|2027|fake precision" docs/progress-v4-real-data-contract-audit.md
- git diff --check

Report back:
1. Files changed
2. V4 module contract summary
3. Existing sources likely available
4. Existing sources uncertain
5. Missing/new required contracts
6. Release V1 readiness
7. Risks and behavior protections
8. Verification results
9. Rork QA required or not

Push command after successful verification:
git status --short --branch
git add docs/progress-v4-real-data-contract-audit.md docs/migration-progress-log.md
git commit -m "docs: audit progress v4 data contracts"
git push
```
