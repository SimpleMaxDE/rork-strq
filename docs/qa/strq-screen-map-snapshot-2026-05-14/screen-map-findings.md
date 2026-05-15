# STRQ Screen Map Findings - 2026-05-15 Safety Update

## Snapshot Summary

Source: `screen-map.json` regenerated at `2026-05-14T22:49:41Z` from commit `145e88fd0f8a63fd6bc864b245c1e585f8acfe43` with the current Screen Map harness safety changes.

| Metric | Total | English | German |
| --- | ---: | ---: | ---: |
| Locales captured | 2 (`en_US`, `de_DE`) | 1 | 1 |
| Screen records | 36 | 18 | 18 |
| Total elements | 2,164 | 1,085 | 1,079 |
| Hittable elements | 862 | 431 | 431 |
| Missing identifier candidates | 212 | 106 | 106 |
| Forbidden controls observed | 14 | 7 | 7 |
| Warnings | 0 | 0 | 0 |

Screens captured per locale:

- `today`: base + scroll 1
- `coach`: base + scroll 1
- `train`: base + scroll 1
- `train-options-menu`: base
- `exercise-library`: base + scroll 1
- `exercise-library-search-squat`: base + scroll 1
- `progress`: base + scroll 1
- `profile`: base + scroll 1 + scroll 2
- `profile-pro-preview`: base + scroll 1

Delta from the 2026-05-14 findings snapshot:

- Missing identifier candidates dropped from 400 to 212.
- Forbidden controls increased from 7 to 14 because German sensitive controls are now classified with the same never-tap guardrail as English controls.
- Warnings dropped from 2 to 0.
- STRQ Pro Preview is now captured from Profile via `strq.profile.subscription`.

## Accessibility Candidate Signal

The candidate pool is now smaller and higher value:

- 200 candidates are `Button` / `observeOnly`.
- 12 candidates are `Button` / `allowedTap`.
- Static text, repeated body copy, empty wrapper controls that overlap identified interactive containers, and system keyboard controls are suppressed.
- Switches, search fields, text fields, tabs, sheet close buttons, primary CTAs, detail-opening rows, chips, toggles, segmented controls, and buttons remain eligible.

This pass did not add product accessibility identifiers and did not broaden crawler tapping behavior.

## Top 20 Accessibility Identifier Priorities

These remain the highest-value identifier targets/families after low-value suppression. Suggested identifiers are conceptual only; no product Swift was changed in this pass.

| Rank | Missing target | Observed labels | Screens | Why it matters |
| ---: | --- | --- | --- | --- |
| 1 | Train primary CTA | `Review & Start`, `Überprüfen und starten` | `train`, `exercise-library`, `exercise-library-search-squat` | Primary workout entry CTA and screenshot QA anchor. |
| 2 | Today week progress card | `Your first week, 4/5 done`, `Deine erste Woche, 4/5 erledigt` | `today` | Safe Today state assertion and navigation target. |
| 3 | Training week day cell - Sunday | `Sun, Lower`, `So., Lower` | `train`, sheet-backed screens | Calendar navigation/state selection. |
| 4 | Training week day cell - Monday | `Mon`, `Mo.` | `train`, sheet-backed screens | Calendar navigation/state selection. |
| 5 | Training week day cell - Tuesday | `Tue, Pull`, `Di., Pull` | `train`, sheet-backed screens | Calendar navigation/state selection. |
| 6 | Training week day cell - Wednesday | `Wed`, `Mi.` | `train`, sheet-backed screens | Calendar navigation/state selection. |
| 7 | Training week day cell - Thursday | `Thu`, `Do.` | `train`, sheet-backed screens | Selected training-day state and navigation. |
| 8 | Training week day cell - Friday | `Fri, Upper`, `Fr., Upper` | `train`, sheet-backed screens | Calendar navigation/state selection. |
| 9 | Training week day cell - Saturday | `Sat`, `Sa.` | `train`, sheet-backed screens | Calendar navigation/state selection. |
| 10 | Train day skip action | `Skip`, `Überspringen` | `train`, sheet-backed screens | Non-destructive plan-day action that needs stable observation even if not auto-tapped. |
| 11 | Train day move action | `Move`, `Verschieben` | `train`, sheet-backed screens | Non-destructive sheet/action entry and QA landmark. |
| 12 | Workout exercise row 1 | `1, Barbell Bench Press, ...` | `train`, sheet-backed screens | Key detail-navigation row and screenshot anchor. |
| 13 | Workout exercise row 2 | `2, Lat Pulldown, ...` | `train`, sheet-backed screens | Key detail-navigation row and screenshot anchor. |
| 14 | Workout exercise row 3 | `3, Dumbbell Row, ...` | `train`, sheet-backed screens | Key detail-navigation row and screenshot anchor. |
| 15 | Workout exercise row 4 | `4, Dumbbell Shoulder Press, ...` | `train`, sheet-backed screens | Key detail-navigation row and screenshot anchor. |
| 16 | Workout exercise row 5 | `5, Tricep Pushdown, ...` | `train`, sheet-backed screens | Key detail-navigation row and screenshot anchor. |
| 17 | Sheet grabber / sheet framing affordance | `Sheet Grabber`, `Aufzeichnungsblatt` | `exercise-library`, `exercise-library-search-squat`, `profile-pro-preview` | Sheet open/close/dismiss landmark for screenshot QA framing. |
| 18 | Exercise Library tracked exercise rows | `Dumbbell Row`, `Romanian Deadlift`, `Barbell Back Squat`, `Leg Press`, fixture equivalents | `exercise-library` | Tappable content rows not covered by catalog-card identifiers. |
| 19 | Exercise Library training-world chips | `Gym Strength`, `Home Gym`, `Home (No Equipment)`, `Zuhause ohne Equipment`, `Calisthenics` | `exercise-library`, search state | Horizontal filter/category controls not covered by the bottom filter-chip identifiers. |
| 20 | Secondary screenshot QA actions | `Strength`, `Body`, `Volume`, `Privacy`, `Terms`, `Support`, `Details` | `progress`, `profile`, `profile-pro-preview` | Safe bottom-region and Pro Preview anchors now visible in the map. |

## Forbidden Controls

The crawler now classifies the observed English and German sensitive controls as `forbidden` and did not tap them.

| Locale | Screen | Control | Safe action |
| --- | --- | --- | --- |
| en | `train-options-menu` | `Regenerate Plan` | `forbidden` |
| de | `train-options-menu` | `Plan neu erstellen` | `forbidden` |
| en | `profile` scroll 1 | `Restore Purchases` | `forbidden` |
| de | `profile` scroll 1 | `Käufe wiederherstellen` | `forbidden` |
| en | `profile` scroll 1 | `Regenerate Plan` | `forbidden` |
| de | `profile` scroll 1 | `Plan neu erstellen` | `forbidden` |
| en | `profile` scroll 2 | `Restore Purchases` | `forbidden` |
| de | `profile` scroll 2 | `Käufe wiederherstellen` | `forbidden` |
| en | `profile` scroll 2 | `Regenerate Plan` | `forbidden` |
| de | `profile` scroll 2 | `Plan neu erstellen` | `forbidden` |
| en | `profile` scroll 2 | `Sign in with Apple` | `forbidden` |
| de | `profile` scroll 2 | `Mit Apple anmelden` | `forbidden` |
| en | `profile` scroll 2 | `Reset All Data, Reset All Data` | `forbidden` |
| de | `profile` scroll 2 | `Alle Daten zurücksetzen, Alle Daten zurücksetzen` | `forbidden` |

The classifier also treats purchase/subscribe/buy, `kaufen`, `kaufen starten`, `abonnieren`, delete/`löschen`, discard/`verwerfen`, sign-out, finish-workout, destructive confirmation, and restore/reset/regenerate variants as never-tap terms when they appear.

## STRQ Pro Preview Warning

Resolved.

Likely cause confirmed: stale harness discovery ID. The Profile card is exposed as `strq.profile.subscription`; the previous harness looked for `strq.profile.pro-preview-card`.

Evidence after the safety pass:

- Warnings are now `0`.
- `profile-pro-preview` is captured in both locales.
- English and German Pro Preview screenshots are present as `17-profile-pro-preview.png` and `18-profile-pro-preview-scroll-1.png`.
- The close control `strq.pro-preview.close` still works from the harness.
- No ProfileView or product Swift changes were made.

## Scroll-Region Reporting

Scrollable captures now report bounded positions:

- `top`: 16 screen records
- `middle`: 2 screen records
- `max-depth`: 16 screen records
- `single`: 2 screen records

Each screen record also includes a `scrollableContainers` array containing visible `ScrollView`, `Table`, and `CollectionView` elements, so follow-up reports can distinguish scrollable surfaces from regular content.

`max-depth` means the harness reached its configured scroll bound; it is not proof that the physical bottom of the scroll view was reached. This keeps the report honest while avoiding blind full-depth scroll assumptions. Broad autonomous click crawling remains deferred.

## Recommendation

Safety slice **C. Add safer scroll-region crawler improvements** is implemented.

Recommended next slice: **A. Add top 20 missing accessibility identifiers**, using the ranked list above. Keep broad autonomous tap coverage deferred until the identifier surface is stable and the never-tap classifier has one more snapshot run behind it.
