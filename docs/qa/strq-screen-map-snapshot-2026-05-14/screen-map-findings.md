# STRQ Screen Map Findings - 2026-05-14

## Snapshot Summary

Source: `screen-map.json` generated at `2026-05-14T20:32:43Z` from commit `3dd0979f9233f936d931027b19b896994f3333b1`.

| Metric | Total | English | German |
| --- | ---: | ---: | ---: |
| Locales captured | 2 (`en_US`, `de_DE`) | 1 | 1 |
| Screen records | 32 | 16 | 16 |
| Total elements | 1,943 | 972 | 971 |
| Hittable elements | 789 | 394 | 395 |
| Missing identifier candidates | 400 | 200 | 200 |
| Forbidden controls observed | 7 | 6 | 1 |
| Warnings | 2 | 1 | 1 |

Screens captured per locale:

- `today`: base + scroll 1
- `coach`: base + scroll 1
- `train`: base + scroll 1
- `train-options-menu`: base
- `exercise-library`: base + scroll 1
- `exercise-library-search-squat`: base + scroll 1
- `progress`: base + scroll 1
- `profile`: base + scroll 1 + scroll 2

Missing identifier shape:

- 393 candidates are `Button` / `observeOnly`.
- 4 candidates are `Switch` / `observeOnly`.
- 3 candidates are `Button` / `allowedTap`.
- 196 candidates have an empty label, mostly repeated tab-bar/icon wrappers, menu wrappers, or container artifacts. These should not drive bulk Accessibility identifier work.
- The high-value gaps are repeated across locales and scroll states, so the useful next step is a small identifier slice, not a blind 400-item pass.

Already covered and therefore not part of the priority missing list:

- Tab navigation uses `strq.tab.*`.
- Train options menu uses `strq.train.menu.*`.
- Exercise Library search uses `strq.exercise-library.search` and clear uses `strq.exercise-library.search.clear`.
- Bottom filter chips use `strq.exercise-library.filters`, `strq.exercise-library.pattern-menu`, `strq.exercise-library.region.upper`, and `strq.exercise-library.region.core`.
- Profile STRQ Pro card is present as `strq.profile.subscription`.

## Top 20 Accessibility Identifier Priorities

These are ranked as identifier targets/families, not every repeated locale or scroll duplicate. Suggested identifiers are conceptual only; no Swift was changed in this pass.

| Rank | Missing target | Observed labels | Screens | Why it matters |
| ---: | --- | --- | --- | --- |
| 1 | Train primary CTA | `Review & Start`, `Überprüfen und starten` | `train`, `exercise-library`, `exercise-library-search-squat` | Primary workout entry CTA and screenshot QA anchor. |
| 2 | Today week progress card | `Your first week, 4/5 done`, `Deine erste Woche, 4/5 erledigt` | `today` | Only `allowedTap` missing target outside Exercise Library; useful for Today state assertions. |
| 3 | Training week day cell - Sunday | `Sun`, `So.` | `train`, sheet-backed screens | Calendar navigation/state selection. |
| 4 | Training week day cell - Monday | `Mon, Pull`, `Mo., Pull` | `train`, sheet-backed screens | Calendar navigation/state selection. |
| 5 | Training week day cell - Tuesday | `Tue`, `Di.` | `train`, sheet-backed screens | Calendar navigation/state selection. |
| 6 | Training week day cell - Wednesday | `Wed`, `Mi.` | `train`, sheet-backed screens | Calendar navigation/state selection. |
| 7 | Training week day cell - Thursday | `Thu, Upper`, `Do., Upper` | `train`, sheet-backed screens | Selected training-day state and navigation. |
| 8 | Training week day cell - Friday | `Fri`, `Fr.` | `train`, sheet-backed screens | Calendar navigation/state selection. |
| 9 | Training week day cell - Saturday | `Sat, Lower`, `Sa., Lower` | `train`, sheet-backed screens | Calendar navigation/state selection. |
| 10 | Train day skip action | `Skip`, `Überspringen` | `train`, sheet-backed screens | Non-destructive plan-day action that needs stable observation even if not auto-tapped. |
| 11 | Train day move action | `Move`, `Verschieben` | `train`, sheet-backed screens | Non-destructive sheet/action entry and QA landmark. |
| 12 | Workout exercise row 1 | `1, Barbell Bench Press, ...` | `train`, sheet-backed screens | Key detail-navigation row and screenshot anchor. |
| 13 | Workout exercise row 2 | `2, Lat Pulldown, ...` | `train`, sheet-backed screens | Key detail-navigation row and screenshot anchor. |
| 14 | Workout exercise row 3 | `3, Dumbbell Row, ...` | `train`, sheet-backed screens | Key detail-navigation row and screenshot anchor. |
| 15 | Workout exercise row 4 | `4, Dumbbell Shoulder Press, ...` | `train`, sheet-backed screens | Key detail-navigation row and screenshot anchor. |
| 16 | Workout exercise row 5 | `5, Tricep Pushdown, ...` | `train`, sheet-backed screens | Key detail-navigation row and screenshot anchor. |
| 17 | Exercise Library sheet grabber | `Sheet Grabber`, `Aufzeichnungsblatt` | `exercise-library`, `exercise-library-search-squat` | Sheet open/close/dismiss affordance for screenshot QA framing. |
| 18 | Exercise Library tracked exercise rows | `Barbell Back Squat`, `Pull-Up`, `Hammer Curl`; German fixture equivalents | `exercise-library` | The top "Your Exercises" rows are tappable content not covered by existing catalog-card identifiers. |
| 19 | Exercise Library training-world chips | `Gym Strength`, `Home Gym`, `Home (No Equipment)`, `Calisthenics` | `exercise-library`, search state | Horizontal filter/category controls not covered by the bottom filter-chip identifiers. |
| 20 | Progress segment controls and Profile footer links | `Strength`, `Body`, `Volume`; `Privacy`, `Terms`, `Support` | `progress`, `profile` | Safe, screenshot-relevant navigation/actions near the bottom of scrollable surfaces. |

Defer for now:

- Empty-label tab/icon wrapper candidates.
- System keyboard candidates (`Next keyboard`, `Nächste Tastatur`).
- Static text labels inside already identified parent rows.
- Profile Body & Nutrition switch thumb duplicates, because the parent switch/section already has `strq.profile.body-nutrition`.

## Forbidden Controls

The crawler correctly did not tap purchase/destructive/account-sensitive controls in this run. The exported `forbidden` controls are:

| Locale | Screen | Control | Safe action |
| --- | --- | --- | --- |
| en | `train-options-menu` | `Regenerate Plan` | `forbidden` |
| de | `train-options-menu` | `Plan neu erstellen` | `forbidden` |
| en | `profile` scroll 1 | `Restore Purchases` | `forbidden` |
| en | `profile` scroll 1 | `Regenerate Plan` | `forbidden` |
| en | `profile` scroll 2 | `Restore Purchases` | `forbidden` |
| en | `profile` scroll 2 | `Regenerate Plan` | `forbidden` |
| en | `profile` scroll 2 | `Reset All Data, Reset All Data` | `forbidden` |

Important guardrail note: the German Profile equivalents were observed but are not classified as `forbidden` in this snapshot:

- `Käufe wiederherstellen` is `observeOnly`.
- `Plan neu erstellen` is `observeOnly` when hittable on Profile scroll 2 and `none` when offscreen on Profile scroll 1.
- `Alle Daten zurücksetzen, Alle Daten zurücksetzen` is `observeOnly`.
- `Mit Apple anmelden` is `observeOnly`.

They were still not tapped, but the export cannot fully confirm that all localized purchase/destructive/account actions "remain forbidden"; it confirms they remain untapped. The likely reason is that the current safe-action classifier recognizes English destructive terms, while these German Profile controls expose a generic identifier (`strq.profile.controls`) plus localized labels.

## STRQ Pro Preview Warning

Warning in both locales:

`STRQ Pro Preview card was not available from Profile.`

Likely cause: stale discovery identifier, not visibility or fixture state.

Evidence:

- Profile base screenshots show the STRQ Pro card above the fold in both locales.
- The screen map contains `strq.profile.subscription` twice, once per locale.
- The screen map contains zero elements with `strq.profile.pro-preview-card`.
- The warning path in `STRQScreenMapSnapshotTests` attempts to tap `strq.profile.pro-preview-card`.
- The visible label is `STRQ Pro, Deeper coaching, evolving plans, and richer progress evidence.`, not `STRQ Pro Preview`.

Not likely based on the snapshot:

- Not hidden by scroll position: card is in `profile` scroll 0.
- Not hidden because the fixture is Pro: the non-Pro STRQ Pro entry is visible.
- Not a locale mismatch alone: the same identifier mismatch appears in both locales.
- Not a missing accessibility identifier in general: the card has `strq.profile.subscription`; the harness is looking for a different one.

## Recommendation

Chosen next slice: **C. Add safer scroll-region crawler improvements.**

Scope it narrowly to crawler safety and screen-map hygiene:

- Make forbidden-action classification robust to localized labels and/or action-specific identifiers before any broader autonomous tapping.
- Keep Restore Purchases, Regenerate Plan, Reset All Data, purchase/subscribe, sign-in/account, sign-out, delete, discard, finish, and destructive confirmations blocked from crawler tapping.
- De-duplicate or suppress known low-value wrapper candidates from tab bars, keyboard controls, and icon-only containers so future reports point at product controls.
- Preserve the current allowlist behavior for tabs, search, filters, menu open, close, back, cancel, and done.

After that safety slice, the Top 20 identifier list above is the right implementation queue. The Pro Preview warning can be cleared with a small follow-up by aligning screen-map discovery with `strq.profile.subscription` or by adding an intentional alias, but it should not be the only next slice while localized destructive controls are underclassified.
