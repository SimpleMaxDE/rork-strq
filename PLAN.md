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
