# STRQ Adaptive Progression Engine

## Status: Complete — Build verified.

### 1. AdaptivePrescriptionEngine
- [x] New service producing per-exercise TodayPrescription
- [x] ProgressionDecision enum: baseline / increaseLoad / increaseReps / hold / reduceLoad / reduceSets / holdRecovery / rebuild
- [x] Double-progression logic using planned rep range (bump load only when every set hits the top)
- [x] Exercise-family-aware load increments (barbell 2.5 / dumbbell 2.0 / machine-cable 2.5 / kettlebell 4.0 / isolation 1.25)
- [x] Fail-safe: 3 consecutive stalls trigger rebuild at -10%
- [x] 2 stalls below rep floor trigger reduceLoad
- [x] Readiness adjustments (<50 drop a set + hold, <65 hold load, deload phase hold+reduce)

### 2. Wiring
- [x] AppViewModel.todayPrescription(for:) exposes engine
- [x] startWorkout uses TodayPrescription for set count + weight prefill
- [x] Readiness-driven set reduction lands in the actual active workout

### 3. Visible Reasoning
- [x] ExercisePrescriptionSheet shows TODAY card with decision, weight delta, adjusted sets × rep range, plain-language reasoning, readiness note, and progression rule
- [x] Rule text explains exactly what unlocks the next bump

### Files Changed
- `ios/STRQ/Services/AdaptivePrescriptionEngine.swift` — NEW
- `ios/STRQ/ViewModels/AppViewModel.swift` — wire engine + use in startWorkout
- `ios/STRQ/Views/ExercisePrescriptionSheet.swift` — TODAY prescription card
