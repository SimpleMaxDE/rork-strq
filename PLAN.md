# Phase 4 — Active Logger Exactness

Turn ActiveWorkoutView into a precise, fast, confident real-time training tool.

**Hero / current-task clarity**
- [x] Fuse exercise hero + active-set header into one compact "current task" block (exercise · set X/Y · planned reps × RPE)
- [x] Add always-visible context strip: previous best · last session · target — inline, numeric, monospaced
- [x] Move progression guidance (coach "do this now") into the current-task block, not a separate row below

**Set table precision**
- [x] Active row gets strong accent (bright border + subtle glow), completed rows drop opacity, pending rows get dotted/ghost state
- [x] Show target column (planned reps / suggested kg) next to actual logged value so drift is visible
- [x] Compact delta indicator on completed rows (+2.5, +1 rep vs last session) — small semantic chip

**Inputs: faster, more deliberate**
- [x] Tap the active weight/reps number → quick numeric edit sheet for direct typing (keeps steppers for nudges)
- [x] Long-press +/- for ±5 step; plate-math helper label under weight (2×20+1×2.5)
- [x] "Match last" and "Match target" one-tap chips above inputs when their values differ from current

**Rest / between-set context**
- [x] Rest overlay leads with "Just logged: X kg × Y reps · e1RM Z" — not abstract
- [x] Next-set recommendation block: explicit suggested kg × reps for the next set based on last set quality/RPE
- [x] Keep SET FEEL chips but move them above the timer (highest-value action first)

**Compression / utility-first**
- [x] Collapse "Up Next" preview while a set is active; only show between exercises or after all sets done
- [x] Previous session table becomes a single compact strip (not full table) under set table
- [x] Reduce vertical space before the active-set block (trim hero height, tighten spacing)
