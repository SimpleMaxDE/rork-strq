# Phase 8 — Recovery / Check-in as a Premium Operating Flow

Make the daily check-in + recovery logging feel like one coherent, fast, high-confidence operating flow.

**Check-in flow (ReadinessCheckInView)**
- [x] Compress 5-step questionnaire into 3 decision blocks (sleep+energy, load, mindset+pain)
- [x] Strong selected states — colored fills, white text, shadow lift, clear contrast
- [x] Semantic color per option (danger → warning → success) instead of flat gradient
- [x] Context-aware header: "Before training" vs "Rest day check"
- [x] Compact 1–5 segmented pickers with short labels (replaces long emoji rows)
- [x] Invert stress mapping so green = low stress
- [x] Pain step inline on step 3 with proper FocusState + submit-to-dismiss

**Coach output (DailyCoachEngine)**
- [x] Split every readiness tier by hasWorkoutToday for train-day vs rest-day copy
- [x] Sharper, more specific adjustments (actual load % / rep targets / time caps)
- [x] Pain response adapts: "train around it" vs "protect it"
- [x] Rest-day peak readiness = "bank recovery" instead of "train anyway"

**Output screen**
- [x] Larger readiness dial (128pt) with real status badge
- [x] Advice card with colored icon tile + label chip + specific adjustments
- [x] Signal breakdown table showing sleep/energy/stress/soreness at a glance
- [x] Contextual CTA: "Go to today's session" vs "Done"

**Identity**
- [x] Keep STRQ dark premium palette, typography, motion
- [x] Semantic color discipline (green/amber/red) without over-coloring
- [x] No redesign of unrelated screens
