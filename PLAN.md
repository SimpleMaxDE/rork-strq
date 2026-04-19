# Phase 6 — Completion Highlight Ordering + Progress Bridge

Make the post-workout moment more useful, ranked, and better connected to progress + next session.

**Ranked highlights**
- [x] Add explicit score to each highlight in `WorkoutHighlightBuilder` and sort by score
- [x] Promote the top highlight into a "session verdict" consumed by the completion hero
- [x] Demote lower-value context (streak/sets milestones) below meaningful performance wins
- [x] Mark one highlight as the primary so the UI can style it distinctly

**What improved — instant**
- [x] Replace generic "Session Logged" eyebrow with the actual win (PR / Best Set / Volume Up / First Session / Consolidated)
- [x] Add a single-line summary beneath hero: "beat last [exercise]" / "most volume yet" / "baseline set"
- [x] Style the primary highlight row so the strongest achievement clearly wins

**Progress bridge**
- [x] Add a "Next session" card: day name, what STRQ will push/hold/drop, based on this session's data
- [x] Surface 1–2 exercises that confirmed progression (or suggest hold) from progressionStates delta
- [x] Keep celebration premium but disciplined — no clutter, no gamification

**System consistency**
- [x] Keep STRQ dark premium identity, semantic palette, calm motion
- [x] Align section header treatment with the rest of STRQ
