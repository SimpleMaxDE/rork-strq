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
