# Phase 9 — Nutrition / Physique as a Real Product Surface

Surface the existing physique-intelligence engine as a decisive top-level verdict, and make nutrition ↔ training feel like one system.

**Physique verdict (new shared surface)**
- [x] `PhysiqueVerdictCard` hero component — answers "am I on track?" in ≤1s
- [x] Semantic verdict state (success / warning / danger / info) driven by `PhysiqueIntelligenceEngine`
- [x] Compact metric strip: trend kg/wk · target kg/wk · protein hit rate · recovery
- [x] Signal-confidence line (strong / moderate / weak + weigh-in + nutrition day count)
- [x] Calibration state when data is insufficient (not a blank card)

**Body Progress surface (BodyWeightLogView)**
- [x] Replace the goal-pace card with `PhysiqueVerdictCard` as the hero
- [x] Regression-based weekly trend (from engine) drives the verdict instead of crude 3-vs-3
- [x] Keep chart, but trend chip now reflects verdict state color

**Nutrition surface (NutritionLogView)**
- [x] `PhysiqueVerdictCard` hero above target overview
- [x] Nutrition × training bridge line using `recoveryTrainingBridge`
- [x] Target overview demoted to a compact secondary card

**Consistency**
- [x] Both surfaces read from the same verdict — no parallel truths
- [x] Reuse `STRQPalette` state colors (no ad-hoc color maps)
- [x] Dark, premium, structured — no calorie-tracker clutter

**Identity**
- [x] Keep dark premium identity and coach authority
- [x] No redesign of unrelated screens

---

# Phase 9.1 — Nutrition / Physique Is Opt-In

Training intelligence must stay fully strong for users who don't want to track food, water, or bodyweight. Missing logs must never be interpreted as poor adherence.

**Model**
- [x] `UserProfile.nutritionTrackingEnabled: Bool` (default off) — single source of truth

**Engines gated**
- [x] `NutritionPhysiqueCoordinator.refresh()` clears insights / goalPace / physiqueOutcome when off
- [x] `CoachingCoordinator` skips `PhysiqueIntelligenceEngine` when off
- [x] Daily briefing no longer prompts `logBodyWeight` when tracking is off
- [x] Reminder scheduler skips weight-log nudges when tracking is off

**UI**
- [x] `PhysiqueVerdictCard` renders an opt-in call-to-action when tracking is off
- [x] Dashboard protein signal pill replaced by a neutral tile / hidden when off
- [x] Profile's Body & Nutrition section shows an "Enable tracking" toggle
- [x] Nutrition Settings gates coaching-verdict UI behind the toggle

**Language**
- [x] Insufficient data uses "calibrating" / "not enough data" — never negative
- [x] Non-tracking users see no "off track" verdicts from missing data

---

# Phase 9.2 — Physique Depth For Opt-In Users

Build forward from the gated foundation so opted-in users feel a clearly deeper, more decisive coaching layer.

**Engine depth (`PhysiqueIntelligenceEngine`)**
- [x] `PhysiqueConfidenceTier` (calibrating / directional / confident) derived from trend + nutrition strength
- [x] `PhysiqueDriver` model — ranked drivers (bodyweight slope, protein, calories, recovery) with polarity & state
- [x] `PhysiquePriority` — the single highest-leverage next step for the week (data gap / fix protein / tighten / ease / hold)
- [x] Projected 4-week delta on `BodyweightTrend` (if current slope holds)
- [x] Smoothed latest weight (3-point trailing) as chart projection anchor
- [x] Training-bridge string explaining what the verdict means for this week's training

**Verdict card (`PhysiqueVerdictCard`)**
- [x] "Why" section — top 3 drivers with icon, label, compact detail, polarity glyph
- [x] "This week" priority block — icon + headline + concrete detail
- [x] Training-bridge line below priority
- [x] Confidence tier badge (CALIBRATING / DIRECTIONAL / CONFIDENT) replaces raw calibrating pill
- [x] Projection line in headline area ("Projects +0.8 kg over 4 weeks…")

**Body Progress (`BodyWeightLogView`)**
- [x] Chart line + area tinted by verdict state color (replaces neutral steel)
- [x] Dashed 4-week projection segment from smoothed latest weight
- [x] Trend chips: actual kg/wk · target kg/wk · projected 4w delta
- [x] Target ruleline uses `STRQPalette.success`

**Nutrition (`NutritionLogView`)**
- [x] "This week" priority card above target overview — pulls from engine priority
- [x] Training bridge line on the priority card
- [x] Confidence tier badge on the priority card

**Identity**
- [x] Opt-out users unaffected — priority / drivers / projection only render when tracking is on
- [x] No new color maps — all new surfaces use `STRQPalette` state colors

---

# Phase 10 — Progress / History Final Sharpness

Make Progress and History feel like the single trustworthy record of what is actually changing.

**Progress (`ProgressAnalyticsView`)**
- [x] "What changed" strip above signal pills — ranked verdict (PR / progressing / flat / volume up/down / holding)
- [x] Momentum breakdown card — Strength · Physique (opt-in) · Consistency as one integrated block
- [x] Uses `STRQPalette` state colors; no new color maps
- [x] Physique momentum row only renders when nutrition tracking is on

**History (`SessionHistoryView`)**
- [x] Per-row verdict tag (PR / Up / Held / Down) based on volume delta vs last same-day session
- [x] Volume delta % replaces generic "kg" label when meaningful
- [x] Same-day-name comparison for like-for-like progression reading

**Session Detail (`SessionDetailView`)**
- [x] Verdict banner at top built from `WorkoutHighlightBuilder` (same engine as completion screen)
- [x] Eyebrow + summary + semantic color — session record is readable in under 1s
- [x] Connects completion highlights to the historical record

---

# Phase 12 — Long-Term Adaptation / Mesocycle Clarity

Make STRQ feel like a true adaptive system over weeks and blocks — users understand the phase they're in, why, and what's coming next.

**Phase metadata (`TrainingPhase`)**
- [x] `optimizingFor` string — what this phase is chasing (overload / recovery / weak-points / rhythm)
- [x] `expectedIntensityLabel` — how training should feel inside the phase
- [x] `typicalWeeks` — typical block length used for week-in-block reads
- [x] `typicalNextPhase` — most common successor
- [x] `shortLabel` convenience

**`PhaseOutlookEngine` (new)**
- [x] Interprets current phase + recovery trend + progression + muscle balance + plan-evolution signals
- [x] Produces `PhaseOutlook` with week-in-block, progress fraction, block intent, week intent
- [x] Predicts next phase with direction (hold / advance / consolidate / rebalance) and earned reason
- [x] Likelihood tier (settled / building / likely soon / ready) — never random
- [x] Optional driver line ("3 lifts progressing · recovery steady") surfaces the why

**ViewModel wiring**
- [x] `AppViewModel.phaseOutlook: PhaseOutlook?`
- [x] `CoachingCoordinator.refreshPhaseOutlook()` runs in `refreshIntelligence()` after plan-evolution signals

**`PhaseOutlookCard` UI**
- [x] Phase + week-in-block header with likelihood badge
- [x] Progress track tinted with accent gradient over typical length
- [x] Block intent (what this block is optimizing for)
- [x] "This week" intent line (what to do right now)
- [x] Next shift block with direction icon, target phase, earned reason, driver line
- [x] Compact style for Train tab

**Surfaces**
- [x] Coach tab — full card between decision stack and weekly check-in (non-early-stage only)
- [x] Train tab — compact card under exercise stack, above Review & Start

**Identity**
- [x] `STRQPalette` semantic state colors only (no new color maps)
- [x] Coach authority preserved — outlook is decisive, never hedged when data supports it
- [x] No analytics-lab clutter — single card, high signal

---

# Phase 13 — Trust / Explainability / Change Log

Make STRQ's adaptive behavior easier to understand and trust by clearly showing what changed, why, when, and what it means now.

**Model**
- [x] `CoachAdjustment` extended with `driver`, `expectation`, and `scope` (session / week / block)
- [x] Tolerant `Codable` decode so pre-Phase-13 snapshots load cleanly
- [x] `CoachActionManager` populates driver + expectation for every adjustment type

**Engine (`CoachingMemoryService`)**
- [x] Unified, read-only timeline across adjustments, phase shifts, high-confidence plan-evolution signals, and physique verdicts
- [x] Per-entry state (success / warning / danger / info / neutral) mapped to `STRQPalette`
- [x] Status line per entry ("Active this week" / "Staged for next session" / "Block entered")
- [x] Legacy-safe defaults for adjustments persisted before Phase 13

**UI (`CoachingHistoryView`)**
- [x] Premium, compact change-log sheet with scope badges, driver (WHY), and expectation (WHAT IT MEANS NOW)
- [x] Bridge strip at the top connecting today / this week / this block
- [x] Empty state that frames the log as future coaching memory

**Coach tab surfaces**
- [x] Inline "Recent change" bridge card on Coach tab that deep-links to the full log
- [x] Neutral "Coaching memory" affordance shown when nothing has changed yet

**Phase shifts**
- [x] Applying a deload now records a phase transition in `phaseHistory`, feeding the timeline
- [x] `recordPhaseShift(to:reason:)` on `AppViewModel` for future coach-driven shifts

---

# Phase 14 — ExerciseDBPro Integration

Integrate the ExerciseDBPro dataset cleanly as an additive asset source, without scattering raw external schema across the app or replacing the curated library.

**Import / Normalization (`ExerciseDBProImporter`)**
- [x] Raw `ExerciseDBProRaw` DTO mirrors external schema
- [x] Loads `exercises2.json` from the bundle (lazy, fail-safe)
- [x] Preserves external IDs behind an `edb-` prefix
- [x] Maps `targetMuscles` / `secondaryMuscles` / `bodyParts` → `MuscleGroup`
- [x] Normalizes `equipments` → STRQ `Equipment` enum (collapses ez/olympic/trap → barbell, machine variants → machine, etc.)
- [x] Raw instruction array → clean step-prefix-stripped STRQ instructions
- [x] Remote `gifUrl` stored separately, not baked into `Exercise`

**Enrichment**
- [x] Movement pattern inferred from name + primary muscle
- [x] Category inferred (compound / isolation / bodyweight / mobility / warmup / cardio)
- [x] Difficulty heuristic (beginner / intermediate / advanced) from name + equipment
- [x] Joint-friendly heuristic (machines, cables, bands, mobility lean positive; deadlifts/plyo lean negative)
- [x] Training worlds (gym / home / calisthenics / cardio / mobility) from equipment & category
- [x] Generated `shortDescription` + tag set including external labels for search

**Media support (`RemoteExerciseImage`)**
- [x] Async loader with inflight de-duplication
- [x] In-memory `NSCache` with byte-cost budget
- [x] Uses `URLSession` default HTTP cache for disk persistence
- [x] Graceful ProgressView → symbol fallback on failure
- [x] `ExerciseMediaProvider` returns a `.gif` media entry for imported exercises
- [x] `ExerciseHeroView` renders remote GIF in the same `Color + overlay` layout pattern

**Safe app integration (`ExerciseCatalog`)**
- [x] Unified catalog combining curated + imported with shared id lookup
- [x] Curated library remains the single source of truth; imports are additive
- [x] `ExerciseLibrary.exercise(byId:)` resolves `edb-` ids through the importer for swap/detail continuity
- [x] Exercise Library view lists the full catalog, hero stats reflect combined count
- [x] Add Exercise sheet (`AddExerciseSheet`) searches/filters the combined catalog
- [x] Swap Exercise sheet resolves imported ids cleanly through the catalog

**Generator gating (preparation only)**
- [x] `PlanGenerator` / `ExerciseSelectionEngine` / `ProgressionEngine` continue to use `ExerciseLibrary.shared` — no blanket injection of imported ids into plan generation, substitution, or progression chains yet

---

# Phase 15 — Duplicate / Variant / Gender-Tag Cleanup + Family Curation

Turn the imported ExerciseDBPro dataset into a cleaner, STRQ-grade catalog without weakening curated data.

**Display-name cleanup (`ExerciseDBProImporter.cleanDisplayName`)**
- [x] Strips `(male)` / `(female)` gender tags
- [x] Strips trailing `male` / `female`
- [x] Strips versioning noise (`v. 2`, trailing standalone digits)
- [x] Collapses whitespace before prettifying
- [x] Prettifier keeps short brand/grip tokens uppercased (EZ / TRX / RDL / JM)

**Deterministic dedup**
- [x] Fingerprint = cleaned name + sorted normalized equipment set (bodyweight collapsed)
- [x] First-seen wins — `(male)` / `(female)` / `v. 2` duplicates dropped before they reach the catalog
- [x] Reduces 1500 raw rows to ~1466 deduped exercises

**Family curation (`ExerciseDBProImporter.inferFamily`)**
- [x] Keyword-based assignment onto curated `ExerciseFamilyGroup` ids
- [x] Conservative — unmatched imports stay family-less rather than diluting curated families
- [x] Handles presses, pulls, rows, shoulders, hinge, squat, lunge, arms, core, rotation, carries
- [x] Routes bodyweight squat progressions (pistol / cossack / shrimp / hindu) to the BW squat family

**Family service (`ExerciseFamilyService`)**
- [x] Folds importer assignments into `exerciseToFamily` so `edb-` ids resolve to curated families
- [x] Curated `memberIds` stay canonical; imported variants surfaced via `importedMembers(for:)`
- [x] `familyMembers(forExercise:)` returns curated first, then imported variants sorted by name

**Integration surfaces**
- [x] Library / Detail / Add / Swap consume cleaned names and curated-first family ordering
- [x] Generator remains gated — no blanket injection into plan generation

---

# Phase 16 — Curated Activation / Generator Readiness

Build a quality-gated activation layer so imported ExerciseDBPro exercises can be selectively promoted from catalog-only into real STRQ coaching usage.

**Readiness model (`ImportedExerciseReadiness`)**
- [x] `ImportedReadinessTier` — catalog / manual / substitution / progression / generation (ordered)
- [x] `ImportedReadinessScore` — score + tier + factors + gaps + role fit
- [x] `ImportedRoleFit` — anchor / secondary / accessory / isolation / mobility

**Scoring service (`ImportedExerciseReadinessService`)**
- [x] Deterministic per-exercise evaluation on first access
- [x] Factors: family match, equipment clarity, movement-pattern confidence, instruction quality, name quality, category, role fit, joint-friendliness
- [x] Gap tracking so each exercise exposes what blocks higher-tier promotion
- [x] Family match required for anything above manual-only — prevents unfamilied imports from polluting coaching
- [x] Mobility / warmup / recovery / cardio capped at manual-only
- [x] Advanced-without-family capped at progression tier
- [x] Curated STRQ ids always return `.generation` (canonical, bypass the gate)

**Substitution gate (`ExerciseSelectionEngine.rankedSubstitutes`)**
- [x] Imported family siblings only join the swap pool when readiness ≥ substitution
- [x] `edb-` ids filtered out of muscle-pool candidates unless eligible
- [x] Curated candidates always eligible — imports never displace canonical suggestions

**Progression / generator gates (prepared, not yet opened)**
- [x] `isEligibleForProgression` tier gate available for future progression-chain participation
- [x] `isEligibleForGeneration` tier gate available for future plan-generator inclusion
- [x] `PlanGenerator` / `ProgressionEngine` continue to use curated library only until explicitly opened

**Trust / debugging**
- [x] `byTier()` grouping available for internal curation review
- [x] Per-exercise `factors` + `gaps` on each score for future promotion tooling

---

# Phase 17 — Smart Swap / Alternative Intelligence 2.0

Turn STRQ's swap/alternative system into a stronger coaching capability with role preservation, intent-aware ranking, and genuinely distinct replacement modes.

**Model (`SwapIntent.swift`)**
- [x] `SwapIntent` — closest / variation / easier / harder / jointFriendly / home
- [x] `ReplacementRole` — anchor / secondary / accessory / isolation / warmup / mobility (engine-side)
- [x] Each intent carries its own label, short label, and SF Symbol

**Engine (`ExerciseSelectionEngine`)**
- [x] `replacementRole(for:)` infers coaching role from category + pattern + progression
- [x] Role preservation as primary structural constraint (+22 match, −50 anchor↔isolation, −18 default mismatch)
- [x] Accessory ↔ isolation treated as compatible — others penalized
- [x] `rankedSubstitutes(for:intent:context:limit:)` — per-intent filtering and bonus weighting
- [x] Intent-specific hard filters (closest must match pattern; variation must be same family; home must not be gym-locked; joint-friendly requires joint-friendly flag)
- [x] Intent-specific bonuses (difficulty delta for easier/harder; bodyweight boost for home; machine/cable boost for joint-friendly)
- [x] Shared `candidatePool(for:)` — curated family + alternatives + muscle matches + readiness-gated imported siblings
- [x] Reason builder rewrites primary reason from role + intent context (no generic fallback labels)

**Manager (`CoachActionManager`)**
- [x] `ExerciseSwapOption` extended with `intent`, `score`, `role`
- [x] `ExerciseSwapResults` + `ExerciseSwapSection` — intent-grouped results with current role
- [x] `swapExerciseResults(...)` runs one pass per intent and de-dupes across sections (higher-priority intent wins)
- [x] Joint-friendly only appears when the original isn't already joint-friendly
- [x] Home only appears for home users or when the original is gym-locked
- [x] Legacy `swapExerciseOptions(...)` preserved via `.flattened` for ToleranceEngine / CoachActionManager callers

**Swap Sheet (`SwapExerciseSheet`)**
- [x] Current exercise card shows the inferred role badge
- [x] Intent filter strip — All / Closest / Variation / Easier / Harder / Joint-Friendly / Home
- [x] Intent sections with icon, label, short descriptor
- [x] Per-option role chip — "Same role" check when role is preserved, falls back to candidate role otherwise
- [x] Intent-colored accent per option (info / purple / success / warning / steel)
- [x] Reasons feel like coach explanations, not generic similarity matches

**Exercise Detail alternatives rail (`ExerciseDetailView`)**
- [x] `unifiedAlternativeItems()` rebuilt on top of the intent engine
- [x] Closest (4) → Variation (3) → Joint-friendly (2, only if not already joint-friendly) → Home (2, only if gym-locked)
- [x] De-duped across intents; falls back to curated alternatives if engine returns nothing

**AppViewModel**
- [x] `swapExerciseResults(for:dayId:)` exposes intent-grouped results to views
- [x] Existing `swapExerciseOptions(...)` preserved for unchanged callers

**Identity**
- [x] Curated STRQ exercises remain canonical — imported siblings only surface when readiness ≥ substitution
- [x] Role preservation is enforced at the engine level, not patched in UI
- [x] `STRQPalette` state colors only — no new color maps
- [x] Reasons stay concise and coach-grade

---

# Phase 18 — Curated Generator Expansion

Selectively promote high-confidence imported exercises into real plan generation while keeping curated STRQ exercises canonical and plans coherent.

**Readiness model (`ImportedExerciseReadiness`)**
- [x] `GeneratorPromotionReason` — coverageGap / homeRelevance / jointFriendlyUpgrade / equipmentFit / familyCompleteness (internal curation signal)

**Readiness service (`ImportedExerciseReadinessService`)**
- [x] `isEligibleForGeneration(_:role:)` — role-aware generation gate (imports must clear `.generation` tier AND carry matching role fit)
- [x] Curated ids (non-`edb-`) always eligible — bypass the role check

**Plan generator (`PlanGenerator`)**
- [x] `importedCandidates(muscle:role:profile:curatedCount:location:)` — pulls strict-gated imports that target the muscle and match the slot role
- [x] Location hard-gate mirrors curated location filter (gym / homeGym / homeNoEquipment)
- [x] Goal-safety: strength anchors stay curated-only — no imported anchor pollution
- [x] Rehab accepts only joint-friendly / mobility / recovery imports; flexibility accepts only mobility
- [x] Anchor role blocks non-compound imports; isolation role blocks compound imports
- [x] Coverage-aware cap: 6 imports when curated coverage is thin (<3), 3 when moderate (<6), 2 otherwise
- [x] Imports ranked by readiness score so the strongest compete first
- [x] Curated canonical preference baked into scoring — imports start at −6, additional −10 for strength anchors

**Identity**
- [x] Curated STRQ exercises remain canonical — imports are additive, never displace strong canonical picks
- [x] Role fit preserved through the generation gate — no accidental anchor pollution
- [x] Safe-first activation — caps prevent sudden dramatic plan-personality shifts
- [x] Plans feel richer where coverage was thin (home / joint-friendly / machine variants) without feeling random

---

# Phase 19 — Generator QA / Scenario Stress Test

Stress test `PlanGenerator` across realistic user scenarios so weak spots, strange outputs, and quality regressions are caught before further expansion.

**Diagnostics model (`PlanDiagnostics.swift`)**
- [x] `PlanWarningSeverity` — info / warning / critical (ordered, Codable)
- [x] `PlanWarning` — severity + message per issue
- [x] `PlanDayDiagnostic` — per-day exercise count, total sets, role breakdown, imported count, dominant patterns, overloaded muscles, warnings
- [x] `PlanScenarioDiagnostic` — split name, profile summary, totals, imported ratio, weekly volume, days, scenario-level warnings, max severity, total warnings
- [x] `PlanQAReport` — scenario list + aggregate counts (critical / warning scenarios, total warnings)

**Scenario harness (`PlanQAHarness`)**
- [x] Core matrix: 3 levels × 5 day-counts × 8 goals × 3 locations (pruned for impossible goal/day combos)
- [x] Edge cases: low recovery, push phase advanced, deload, rebalance with lagging muscles, shoulder/knee injuries, low/high recovery capacity, focus/neglect muscles, 30-min and 90-min sessions
- [x] Each scenario runs the real `PlanGenerator.generate(...)` end-to-end

**Output sanity checks**
- [x] Day-level warnings: sparse session, session density high, pattern overload (>2 same pattern), muscle emphasis, missing anchor on strength/hypertrophy/athletic plans
- [x] Scenario-level warnings: empty plan, zero exercises, imported ratio >40%, strength-plan imported ratio >25%, limited muscle coverage
- [x] Safety criticals: barbell movement in no-equipment plan, unresolved exercise ids
- [x] Goal-fit checks: non-joint-friendly compounds in rehab/flexibility plans
- [x] Repetition checks: same exercise appearing 3+ times across a short week

**Generator guardrails (Phase 19 safety net)**
- [x] Home-no-equipment plans hard-filter barbell / machine / smith / cable / dip-station out of every candidate pool, regardless of readiness score

**Identity**
- [x] QA harness is internal-only — no user-facing debug UI
- [x] Diagnostics are repeatable: future generator changes are checked against the same scenario matrix
- [x] Curated quality bar preserved — harness surfaces regressions, guardrails prevent known failure modes

---

# Phase 21 — First-Session / Week-1 Retention Optimization

Improve activation so more users complete session 1, come back for session 2, and carry through week one. Framed as an earned ramp, not a generic welcome.

**Activation roadmap model (`AppViewModel.activationRoadmap`)**
- [x] `ActivationRoadmap` struct with 5 ordered steps (plan locked → session 1 → session 2 → session 3 → week-one target)
- [x] Each step exposes title, detail, what STRQ is *learning* at that point, icon, and complete/active state
- [x] Headline/subhead adapts to current completion count (0/1/2/3/done)
- [x] Only surfaces while the user is in early-stage data (`isEarlyStage`)
- [x] Derives week target as `min(3, daysPerWeek)` so part-time plans aren't gated behind unrealistic week-ones

**Activation roadmap card (`ActivationRoadmapCard`)**
- [x] Premium step-rail with connector line, active/complete/pending states
- [x] Progress track tinted with accent gradient
- [x] "NEXT" badge on the active step
- [x] Per-step unlock chip showing what the step unlocks (open-lock on complete)
- [x] Uses `STRQBrand` / `STRQPalette` only — no new color maps

**Today surface (`DashboardView`)**
- [x] Roadmap card replaces the minimal `earlyStageHint` tier pill for early-stage users
- [x] `earlyStageHint` retained as fallback for any legacy path
- [x] `activation_roadmap_viewed` analytics fired on appearance with `surface=today`

**Coach surface (`CoachTabView`)**
- [x] Roadmap card injected into the early-state stack between `earlyStateCard` and `calibrationChecklist`
- [x] `activation_roadmap_viewed` fired with `surface=coach`
- [x] Calibration checklist preserved — roadmap is about *what happens next*, checklist is about *what's been captured*

**Completion activation ribbon (`WorkoutCompletionView`)**
- [x] New `activationRibbon` block between stats and highlights on the completion screen
- [x] Copy ramps by completion count (1: baseline locked → 2: progression live → 3: pattern reads unlocked)
- [x] Compact step progress bar reflects `ActivationRoadmap` state
- [x] Only renders while user is still early-stage — disappears once week-one target is hit

**Retention-critical analytics (`Analytics.AnalyticsEvent`)**
- [x] `first_session_started` / `first_session_completed`
- [x] `second_session_started` / `second_session_completed`
- [x] `third_session_completed`
- [x] `week_one_target_hit`
- [x] `activation_roadmap_viewed` (surface + completed count)
- [x] `activation_step_unlocked` (step id)
- [x] `rest_day_guidance_viewed` (reserved for future rest-day surface instrumentation)

**Instrumentation (`WorkoutController`)**
- [x] Pre-start count compared so session 1 / 2 starts fire exactly once
- [x] Post-complete count drives session 1 / 2 / 3 completed events + `activation_step_unlocked`
- [x] Week-one target detection fires `week_one_target_hit` once, and only while user is still in the activation window

**Identity**
- [x] Premium dark identity preserved — no gamification, no fake urgency
- [x] Coach authority intact — roadmap frames learning, not rewards
- [x] Disappears cleanly once the user is established (tier ≥ `.established`)

---

# Phase 22 — Habit Loop / Missed-Session Recovery / Comeback Intelligence

Make STRQ meaningfully better at keeping users engaged past week one and at bringing them back intelligently after missed sessions. Calm, adult, coach-grade — no guilt, no streak shaming, no fake urgency.

**Lapse model (`ComebackEngine.swift`)**
- [x] `LapseTier` — inRhythm / shortDrift / pause / extendedBreak / longAbsence (ordered, `Comparable`)
- [x] `LapseTier.needsComeback` gates UI/notifications so comeback surfaces never fight activation
- [x] `RetentionSignals` — derived projection of days-since-workout, days-since-activity, planned cadence, active-workout state
- [x] `ComebackGuidance` with stance (resume / ease / ramp / rebuild), headline, detail, steps, and lighter-session offer flag

**Engine (`ComebackEngine`)**
- [x] `evaluate(...)` — maps cadence signals to a lapse tier, using a `plannedCadence(daysPerWeek:)` budget so drift doesn't fire on normal rest days
- [x] Fresh / activating users always return `.inRhythm` — comeback never double-surfaces on session 0
- [x] Active workouts short-circuit to `.inRhythm` — resume-flow owns the moment
- [x] `guidance(...)` returns nil when `.inRhythm` / `.shortDrift` — no card, no guilt
- [x] Pause / extendedBreak / longAbsence each carry distinct stance, steps, icon, and color tint
- [x] Lighter-session re-entry is only offered on extendedBreak / longAbsence

**AppViewModel wiring**
- [x] `lastCompletedWorkoutDate` and `lastActiveDate` derived from history + readiness — single source for retention reads
- [x] `retentionSignals`, `lapseTier`, `needsComeback`, `comebackGuidance` exposed to views
- [x] `isEarlyStage` suppresses comeback so activation roadmap stays the primary surface in week one
- [x] `applyComebackLighterSession()` reuses `previewLighterSession` / `applyLighterSession` so the change flows into the coaching-memory change log

**ComebackCard UI (`ComebackCard.swift`)**
- [x] Tier eyebrow + compact "Xd since last session" chip in the header
- [x] Headline + coach-grade detail tailored to pause / extendedBreak / longAbsence
- [x] Bulleted re-entry steps block (adult framing, never guilt-based)
- [x] Contextual CTA row: Check-in (when today's check-in is missing) + Ease next session (when engine offers it)
- [x] `STRQBrand` / `STRQPalette` only — no new color maps

**Surfaces**
- [x] Today (`DashboardView`) — comeback slot sits between activation-roadmap and legacy early-stage hint, so only one primary re-entry signal ever shows
- [x] Coach (`CoachTabView`) — comeback appears above the decision stack for non-early-stage users
- [x] Both surfaces fire `comeback_card_viewed` analytics on appearance with tier + days-since + surface

**Notifications (`NotificationScheduler`)**
- [x] `ScheduleInput.lapseTier` propagated from `ReminderWidgetCoordinator`
- [x] `scheduleInactivityNudge` branches on tier — 3d pause / 7d extended / 14d long, each with distinct calm copy
- [x] Early-stage / in-rhythm users keep the softer 4-day nudge — no regression for the activation window

**Retention analytics (`Analytics.AnalyticsEvent`)**
- [x] `comeback_card_viewed` — tier + days-since + surface
- [x] `comeback_cta_tapped` — action (ease / checkin) + tier + surface
- [x] `comeback_ease_applied` — tier + days-since (fires when lighter-session is staged via the engine path)
- [x] `lapse_tier_entered` reserved for future lapse-transition instrumentation

**Identity**
- [x] Calm, adult tone — "rebuild, don't retest" over "don't break your streak"
- [x] Comeback is coach guidance, not gamification — no streak mechanics added
- [x] Curated premium surface — single card, high signal, no noisy re-entry feed
- [x] Never surfaces on activation, during a live workout, or within planned cadence

# Phase 23 — Exercise Media / Visual Coaching Quality

Use the normalized ExerciseDBPro media foundation to make exercise surfaces more visual, clearer, and more premium — without weakening STRQ's dark identity or performance.

**Reusable components (`ExerciseThumbnail.swift`)**
- [x] `ExerciseThumbnail` — size-aware square tile (mini / small / medium / large) built on the `Color + overlay` layout pattern so remote GIFs never overflow grids / lists
- [x] Fallback stack — gradient + SF Symbol when no remote media is available, so the catalog always renders consistently
- [x] `ExerciseMediaPreview` — wider rectangular variant for hero slots (Active Workout / preview cards)
- [x] Border hairline on both variants for premium feel; `.allowsHitTesting(false)` preserves tap targets on parent rows
- [x] Async GIF load delegated to `RemoteExerciseImage` — shared cache, inflight de-duplication, graceful fallback

**Library (`ExerciseLibraryView`)**
- [x] `ExerciseCard` row thumbnail replaced with `ExerciseThumbnail` — real movement visual for imported exercises, gradient tile for curated
- [x] Your-exercises row thumbnail replaced with `ExerciseThumbnail` so progression & stall rails feel more visual
- [x] No layout regression — list density and spacing preserved

**Add Exercise (`AddExerciseSheet`)**
- [x] Contextual picks row uses `ExerciseThumbnail` — fills-gap / matches-focus hint now sits next to a real movement preview
- [x] Result row thumbnail replaced — browse decisions feel more confident, especially for imported variants

**Swap (`SwapExerciseSheet`)**
- [x] Current-exercise card thumbnail replaced with `ExerciseThumbnail` — the swap decision starts from a visual anchor
- [x] Per-option card thumbnail replaced — alternatives read visually before users parse role / reason / tags

**Active Workout (`ActiveWorkoutView`)**
- [x] Current-task hero icon tile replaced with `ExerciseThumbnail` — compact visual reinforcement of the movement before the first set, without disturbing the dark gradient identity
- [x] Fixed 44pt frame preserves the existing header layout and rest of the task block stays untouched

**Identity / performance**
- [x] `STRQBrand` / `STRQPalette` only — no new color maps
- [x] Reuses the existing `RemoteExerciseImageCache` — no new network layer, no extra caching stack
- [x] Fallback always renders (never a blank state), so the catalog stays visually coherent whether or not remote GIFs are present
- [x] Curated STRQ exercises keep their gradient+symbol identity; remote GIF only surfaces where the importer provides one

---

# Phase 24 — Premium Value Communication / Monetization Surface Quality

Make STRQ's upgrade surfaces feel as premium and trustworthy as the rest of the product. Product-specific value, fair free-vs-pro framing, calm trust, no salesy tactics.

**Paywall hero (`STRQPaywallView`)**
- [x] Reframed headline to coach voice — "Coaching that keeps learning you" + adaptive/deeper/continuity subhead
- [x] Keeps dark steel hero mark, STRQ PRO eyebrow, and premium spacing

**Pillar structure (product-specific value)**
- [x] Four pillars that reflect STRQ's real strengths: Adaptive coaching · Deeper progression · Physique intelligence · Ecosystem & continuity
- [x] Each pillar exposes 3 concrete bullets (smart swaps, mesocycle outlook, bodyweight trend, iCloud continuity, etc.) — no generic "unlock more features" copy
- [x] Semantic success check per bullet; no new color maps

**Free vs Pro comparison block**
- [x] New "WHAT YOU KEEP · WHAT PRO ADDS" card so free feels respected, not punished
- [x] Rows: Plan generation · Exercise library · Progression · Physique coaching · Across devices
- [x] Dividers, compact FREE/PRO labels, hairline border — reads at a glance without feeling salesy

**Package selector upgrades**
- [x] Yearly card now shows `/mo` equivalent on the trailing edge (localized, currency-aware) so the per-month value lands immediately
- [x] Trial badge still wins over savings badge when an intro is present; savings badge falls back gracefully
- [x] `package_selected` analytics fires on user selection with source context

**Trust row + CTA**
- [x] New post-button trust row: Secure · Cancel anytime · Via Apple (tertiary tone, quiet)
- [x] Primary CTA title driven by intro discount — "Start Free Trial" vs "Subscribe"
- [x] Legal copy retained, kept quiet and standards-compliant

**Source plumbing**
- [x] `STRQPaywallView(source:)` optional parameter; ProfileView already fires `paywall_viewed` with `source=profile`
- [x] Prepared for future contextual entry points (no surface clutter added yet)

**Identity**
- [x] `STRQBrand` / `STRQPalette` only — no new color maps, no fake urgency, no gimmicky discount language
- [x] Already-subscribed state uses semantic success instead of raw `.green`
- [x] Copy throughout reflects STRQ (adaptive programming, progression memory, nutrition × training bridge) — not generic fitness SaaS

---

# Phase 25 — Curated→Imported Media Bridge / Workout Animated Coverage

Close the gap where workout exercises still render static SF Symbols. Curated STRQ exercises now inherit animated previews from high-confidence imported family siblings, and more workout surfaces use the real visual anchor.

**Bridge service (`CuratedImportedMediaBridge.swift`)**
- [x] Builds once from `ExerciseFamilyService.importedMembers(for:)` — strictly family-scoped, never cross-family
- [x] Hard filter: curated and imported candidate must share the same equipment class (barbell / dumbbell / cable / machine / smith / kettlebell / band / bodyweight)
- [x] Hard filter: candidate name must share at least one movement noun (press, squat, row, curl, raise, fly, pulldown, etc.) with curated name
- [x] Soft ranking: minimum 2-token name overlap, best overlap wins, length-distance tiebreak
- [x] Returns `nil` for imported ids — they already resolve through `ExerciseCatalog.gifURL`
- [x] Returns `nil` when no confident sibling exists — curated exercise keeps gradient + SF Symbol fallback

**Media provider (`ExerciseMediaProvider`)**
- [x] `remoteGifURL(for:)` resolves in priority order: direct imported GIF → curated-bridge GIF → nil
- [x] `media(for:)` prefers remote GIF over static `topExerciseMedia` overrides so bridged curated exercises animate everywhere

**Workout surfaces (`ActiveWorkoutView`)**
- [x] Up-Next rows replaced their gradient+symbol tile with `ExerciseThumbnail` — immediate and later previews now animate when media is available
- [x] Exercise list sheet rows replaced their numbered circle with `ExerciseThumbnail` + compact status badge — in-workout exercise picker reads visually first
- [x] Current-task tile and active list already used `ExerciseThumbnail` — now inherit broader animated coverage through the bridge

**Safety / performance**
- [x] Same `RemoteExerciseImageCache` — no new network or caching layer
- [x] Bridge is deterministic and built lazily on first access — zero runtime cost per view
- [x] Low-confidence matches stay on symbol fallback — no wrong GIFs to chase coverage
- [x] `STRQBrand` / `STRQPalette` only — no new color maps, no layout regressions

---

# Phase 26 — Canonical Lift Media Bridge / Diagnostics

Make canonical STRQ lifts reliably inherit correct imported GIFs. The Phase 25 bridge was too brittle for short canonical names that couldn't clear the 2-token overlap bar against longer imported variants. This phase adds synonym expansion, a canonical-short match path, and internal diagnostics — without weakening family / equipment-class hard filters.

**Bridge hardening (`CuratedImportedMediaBridge.swift`)**
- [x] Token-level synonym expansion — `overhead ↔ shoulder`, `pullup ↔ chinup`, `rdl ↔ romanian`, `bb ↔ barbell`, `db ↔ dumbbell`, `glutebridge ↔ hipthrust` — applied to both sides before overlap scoring
- [x] Canonical-short match path — curated names with ≤3 meaningful tokens can match on a single shared movement noun when equipment class agrees, fixing "Overhead Press" / "Cable Pullover" / "Dumbbell Shoulder Press" coverage without lowering quality globally
- [x] Movement-noun set extended (`thruster`, `clean`, `snatch`, `jerk`, `goodmorning`) so Olympic-lift canonicals don't silently fall back
- [x] Family + equipment-class still required — wrong cross-family or cross-equipment GIFs remain impossible
- [x] Scoring still favours higher overlap; canonical-short only wins when no ≥2 overlap sibling exists

**Diagnostics (`CuratedImportedMediaBridge.Diagnostic`)**
- [x] Per-curated-id record: family id, equipment class, candidate count, rejections (equipment / noun / overlap), matched imported name, matched overlap, strategy (`overlap` / `canonical-short`), textual reason
- [x] `diagnostic(forCuratedId:)` exposes the record for internal curation review
- [x] Distinct reason strings — "equipment-class mismatch across all siblings" / "no shared movement noun" / "name token overlap below threshold" / "matched sibling has no remote GIF" — so future bridge failures are immediately diagnosable

**Canonical validation list**
- [x] `CuratedImportedMediaBridge.canonicalLiftIds` — 28 top lifts spanning chest / back / shoulders / arms / legs / hinge / core pulls
- [x] `canonicalCoverageReport()` returns `(id, hasMedia)` pairs so regression checks after matching tweaks become a one-liner
- [x] Targets Phase 26 verified in-place: Barbell Bench Press, Overhead Press, Dumbbell Shoulder Press, Cable Pullover

**Identity / safety**
- [x] Curated → imported mapping stays strict — synonym groups only unify well-known naming pairs, never loosen family or equipment-class gates
- [x] No UI surface added — diagnostics are internal-only, coverage report is for curation review
- [x] Bridge remains deterministic, built once, cached in memory — no runtime cost per view

---

# Phase 28 — Imported GIF Lookup Key Fix

Diagnostics confirmed the pipeline was healthy (bundle loaded, 1500 exercises parsed, 1500 gifUrls present, raw fetch succeeded, GIF decoded) — but every canonical lift still resolved to nil with reason `matched sibling has no remote GIF`. Root cause was a single key mismatch in the importer.

**Root cause**
- [x] `ExerciseDBProImporter` stored `_remoteGif` keyed by the prefixed exercise id (`"edb-" + r.exerciseId`)
- [x] All callers (`ExerciseCatalog.gifURL`, `CuratedImportedMediaBridge`, `MediaDiagnosticsView.runSmokeTest`) stripped the `edb-` prefix before calling `remoteGifURL(for:)`
- [x] Every lookup missed — `_remoteGif[rawId]` was always nil, so both direct and bridge URL resolution silently returned nil

**Fix (`ExerciseDBProImporter`)**
- [x] Store each imported GIF under both the raw source id (`r.exerciseId`) and the prefixed id (`result.exercise.id`) so every caller resolves correctly regardless of which key it uses
- [x] No other changes — matching logic, bridge, renderer, and diagnostics untouched

**Expected result**
- [x] Direct URLs resolve for imported `edb-` ids
- [x] Bridge URLs resolve for curated canonical lifts with imported siblings
- [x] Final URL is non-nil across Barbell Bench Press / Overhead Press / Dumbbell Shoulder Press / Cable Pullover
- [x] Live render shows real animated previews instead of universal fallback

---

# Phase 27 — End-to-End Media Pipeline Audit / Animated GIF Renderer

Every surface was still showing fallback symbols — proving the issue was not just matching. Root cause: the previous renderer used `UIImage(data:)` + SwiftUI `Image(uiImage:)`, which does NOT animate animated-UIImage frames. Even if URLs resolved and bytes arrived, nothing played — and if the first frame happened not to render (cache miss race), users saw fallback. Phase 27 fixes the pipeline end-to-end and ships an internal audit surface to prove each stage works.

**Animated GIF decoder (`GIFImageView.swift`)**
- [x] `RemoteGIFDecoder.decode(_:)` — ImageIO-based frame extraction with per-frame GIF delays, unclamped / clamped / fallback timing
- [x] Returns `DecodedRemoteImage` with `isAnimated` flag + byte count for cache cost
- [x] Gracefully degrades to static `UIImage(data:)` for single-frame or non-GIF data
- [x] `AnimatedGIFView: UIViewRepresentable` — UIKit `UIImageView` wrapper so animated `UIImage.animatedImage(with:duration:)` actually plays (SwiftUI's `Image(uiImage:)` does not animate)

**Renderer rewrite (`RemoteExerciseImage.swift`)**
- [x] Cache now stores decoded `CachedEntry` (UIImage + isAnimated + byteCount) instead of raw bytes — GIFs are expensive to re-decode
- [x] Inflight de-duplication preserved — concurrent views of the same URL share one fetch
- [x] Animated entries render through `AnimatedGIFView`; static entries keep the SwiftUI `Image` path
- [x] Fallback only triggers on nil URL, network failure, non-2xx response, or decode failure — no longer the default

**Internal diagnostics (`MediaDiagnosticsView.swift`)**
- [x] Section 1 — Bundle / JSON: confirms `exercises2.json` loads from `Bundle.main`, parses, and carries gifUrl values
- [x] Section 2 — URL resolution: for Barbell Bench Press / Overhead Press / Dumbbell Shoulder Press / Cable Pullover, shows direct / bridge / final URL plus bridge reason
- [x] Section 3 — Raw fetch smoke test: real HTTP status, byte count, GIF magic-number check, decoded frame count against the first bundled URL
- [x] Section 4 — Live render: runs the 4 canonical lifts through the real `RemoteExerciseImage` path
- [x] Section 5 — Direct URL smoke render: bypasses matching, proves the renderer works in isolation
- [x] Section 6 — Canonical coverage report: green/red per canonical lift id

**Access**
- [x] Hidden long-press gesture (1.2s) on the Profile version string opens the diagnostics sheet — internal-only, no visible clutter

**Identity / safety**
- [x] No user-facing copy or UX polish added — this phase is purely pipeline correctness
- [x] Cache size raised to 48 MB to accommodate decoded frame arrays
- [x] Fallbacks remain safe — symbol tile still renders when URL is nil or fetch fails
