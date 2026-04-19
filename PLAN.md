# Phase 3 — Train / Session Editor Density

Turn Train + Session Editor into a denser, more professional program-builder.

**Train screen (TrainingPlanView)**
- [x] Group exercises by role (Key / Support / Accessory / Warm-Up) with compact section headers showing set totals
- [x] Denser role-aware rows (role accent bar, ordinal, compact prescription line with rest/RPE/load)
- [x] Quick-edit affordance via context menu (Edit / Swap / Restore / Remove)
- [x] Mission card compressed (tighter padding, single-line title, smaller stats)

**Session Editor (SessionEditorSheet)**
- [x] Replace plain List rows with builder-style role-grouped rows
- [x] Role accent, prescription line (sets×reps · rest · RPE), and coach/custom indicator on every row
- [x] Surface primary inline actions (Edit / Swap buttons) visible per row
- [x] Tighter row height with monospaced prescription line
- [x] Header summary shows volume by role (Key · Support · Accessory · Warm-Up)
- [x] Reorder mode with up/down chevrons replacing hidden drag handles

**Prescription Edit Sheet**
- [x] Denser builder cards — sets/reps/rest/RPE presets prominent
- [x] Clear "Coach default" vs "Custom" state with one-tap restore banner
- [x] CoachDefault model added to PlannedExercise; restore preserves original prescription

**Add Exercise Sheet**
- [x] Contextual "Fits this session" section at top (role gaps + primary muscle matches)
- [x] Compact result rows with role/equipment hints
- [x] Muscle filter chips; grouped results by muscle
