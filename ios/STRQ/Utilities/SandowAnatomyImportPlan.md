# Sandow Anatomy Muscle Import Plan

Last prepared: 2026-04-29

## Scope

This is an import strategy only. No assets were imported, no Swift files were modified, and no runtime screens or app logic were changed.

Allowed future work described here must remain separate from runtime screen migration. Do not touch `DashboardView`, `ContentView`, `ProgressAnalyticsView`, `ExerciseDetailView`, `ActiveWorkoutView`, onboarding, paywall, profile, workout completion, data models, workout logic, progression logic, persistence, analytics, product IDs, localization, or existing assets unless a later prompt explicitly authorizes that scope.

## Figma Nodes Inspected

| Node | Name | Finding |
|---:|---|---|
| `8673:69673` | Anatomy Muscle | Primary component set. 60 component variants across gender, body area, and selected state. |
| `9125:148813` | Illustration | Contains Anatomy Muscle, Body Type, Organ Anatomy, Achievement Badge, large anatomy vector groups, and illustration base assets. |
| `9025:207456` | Body Type | 12 component variants across type, gender, and selected/default state. Related to onboarding/profile, not first anatomy import priority. |
| `9192:5535` | Frame | 4 large anatomy line-art groups, 225 vectors total. Screenshot shows male/female front/back body anatomy line art; metadata labels remain generic `Group` and `Vector`. |

STRQ code read for mapping only:

- `ios/STRQ/Models/MuscleGroup.swift`
- `ios/STRQ/Views/MuscleFocusView.swift`
- `ios/STRQ/Views/BodyMapView.swift`
- `ios/STRQ/Views/MuscleRegionPaths.swift`

## Anatomy Muscle Structure Findings

`8673:69673` is a Figma `COMPONENT_SET`. Figma metadata labels its children as symbols, but the plugin API reports all 60 direct children as `COMPONENT` nodes.

Variant axes:

- Gender: `Male`, `Female`
- Body Area: `Lower Leg`, `Upper Leg`, `Abs`, `Chest`, `Shoulder`, `Bicep`, `Forearm`, `Hand`, `Neck`, `Tricep`, `Hamstring`, `Glute`, `Calf`, `Back`, `Trap`
- State: Figma property `Is Selected` with values `false` and `true`

Asset structure:

- Every direct variant is a component, not an image.
- Total inspected structure: 60 components, 780 vector nodes, 3 group wrappers.
- No image paints were found.
- No gradients were found.
- No text nodes were found.
- All variants are exportable through Figma as vector assets.
- Variant dimensions are 88 x 128.

State implementation:

- Selected and unselected are separate Figma component variants.
- The state difference is primarily color, not different imagery.
- Unselected fills include neutral whites/grays such as `#FFFFFF`, `#FAFAFA`, and `#E4E4E7`.
- Selected fills include warm highlight colors such as `#FFF7ED`, `#FED7AA`, and one inspected male bicep selected fill of `#FDBA74`.
- Strokes remain vector strokes, with inspected neutral stroke colors including `#52525B`, `#A1A1AA`, and `#D4D4D8`.
- Most selected/unselected pairs have the same direct child type structure. The notable exception is male `Lower Leg`, where the selected state wraps the same vector count in a group.

Gender structure:

- Male and female share the same conceptual variant axes and visual language.
- Male and female do not always share identical vector topology or vector counts. Treat them as separate base/mask families, not one geometry with a gender tint.

Per-area vector counts:

| Body Area | Male vector count | Female vector count | Notes |
|---|---:|---:|---|
| Abs | 20 | 20 | Same count across genders. |
| Back | 17 | 17 | Same count across genders. |
| Bicep | 10 | 12 | Gender-specific topology. |
| Calf | 7 | 9 | Gender-specific topology. |
| Chest | 20 | 20 | Same count across genders. |
| Forearm | 11 | 10 | Gender-specific topology. |
| Glute | 18 | 20 | Gender-specific topology. |
| Hamstring | 14 | 12 | Gender-specific topology. |
| Hand | 6 plus one male group wrapper | 6 | Hand has no direct STRQ muscle group. |
| Lower Leg | 7 plus one selected male group wrapper | 10 | Overlaps STRQ tibialis/calves concepts. |
| Neck | 11 | 12 | Gender-specific topology. |
| Shoulder | 12 | 10 | Gender-specific topology. |
| Trap | 12 | 14 | Gender-specific topology. |
| Tricep | 14 | 13 | Gender-specific topology. |
| Upper Leg | 13 | 13 | Same count across genders; maps to several STRQ lower-body groups. |

Layering and selection:

- Anatomy Muscle is not a single full-body asset with independently selectable layers.
- Each variant is a separate mini silhouette/tile for one gender, one body area, and one selected state.
- Individual body areas can be represented independently at the asset level by using one body-area variant or mask per gender/body area.
- If exported as flattened SVG/PDF composites, in-app per-vector selection should not be assumed. Preserve body-area independence by exporting separate area masks/shapes or by recreating overlays in SwiftUI.

Front/back representation:

- Anatomy Muscle provides area-focused mini silhouettes, not one unified front/back anatomy map.
- Some body areas imply front-facing targets, such as chest, abs, bicep, forearm, hand, lower leg, upper leg, shoulder, and neck.
- Some body areas imply back-facing targets, such as back, trap, tricep, hamstring, glute, and calf.
- The related `9192:5535` node is the better candidate for full male/female front/back base anatomy line art.

Template SVG/PDF feasibility:

- Vector export is feasible.
- Pure template rendering is not ideal for the full composite variants because the artwork uses separate context, highlight, fill, and stroke colors.
- Template-style tinting is best reserved for extracted masks or isolated target-area shapes.
- Preserve neutral body context separately from selected-state styling when possible.

## STRQ Muscle Mapping

| Sandow Body Area | STRQ Muscle Group(s) | Notes |
|---|---|---|
| Lower Leg | `.tibialis`, `.calves` | Best fit for anterior/lower-leg work. STRQ has a separate `.calves`; avoid double-counting calf work unless the exercise targets the whole lower leg. |
| Upper Leg | `.quads`, `.adductors`, `.abductors`, `.hipFlexors` | Sandow uses a broad upper-leg bucket. STRQ is more granular, especially for quads, adductors, abductors, and hip flexors. |
| Abs | `.abs`, `.obliques`, `.coreStability`, `.rotationAntiRotation` | Visual is primarily abs. STRQ core concepts are broader than the Sandow asset. |
| Chest | `.chest` | Direct mapping. |
| Shoulder | `.shoulders` | Direct mapping. |
| Bicep | `.biceps`, `.arms` | Direct for biceps; can contribute to aggregate `.arms`. |
| Forearm | `.forearms`, `.arms` | Direct for forearms; can contribute to aggregate `.arms`. |
| Hand | None | STRQ has no hand muscle group. Probably skip for exercise focus unless grip/hand rehab content is added later. |
| Neck | `.neck` | Direct mapping, but likely low exercise-frequency priority. |
| Tricep | `.triceps`, `.arms` | Direct for triceps; can contribute to aggregate `.arms`. |
| Hamstring | `.hamstrings` | Direct mapping. |
| Glute | `.glutes` | Direct mapping. |
| Calf | `.calves` | Direct mapping; keep separate from lower-leg/tibialis use. |
| Back | `.back`, `.lats`, `.lowerBack` | Sandow is broad. STRQ separates lats and lower back, so this asset loses detail unless paired with STRQ-specific overlays later. |
| Trap | `.traps` | Direct mapping. Keep separate from `.back`; this is one of Sandow's useful granular matches. |

STRQ-only concepts without direct Sandow body-area assets:

- `.lats`
- `.obliques`
- `.lowerBack`
- `.adductors`
- `.abductors`
- `.hipFlexors`
- `.tibialis` as a distinct lower-leg/anterior-shin concept
- `.coreStability`
- `.rotationAntiRotation`
- `.arms` as an aggregate group

## Import Strategy Comparison

| Option | Description | Pros | Cons | Recommendation |
|---|---|---|---|---|
| A | Import every gender/state/body-area asset separately. | Fastest path to exact Figma appearance. Lowest renderer complexity. | 60 assets before any sizing variants. Duplicates selected/unselected state. Harder to recolor for STRQ focus/reduce/secondary states. | Avoid unless export masking fails. |
| B | Import one base male/female body-area asset per area and control selected/unselected state in SwiftUI. | 30 area assets. Better than duplicating state. | If each asset is a full composite, template tinting can recolor the neutral body context too. Needs careful asset preparation. | Acceptable fallback if masks are cleanly exportable as area composites. |
| C | Import base anatomy line art plus body-area masks/shapes, then recreate selected/unselected through SwiftUI fills, strokes, masks, or overlays. | Smallest state surface. Supports selected, unselected, focus, reduce, primary, secondary, analytics intensity, and future theme states without duplicate assets. Best fit for STRQ. | More export QA. Requires consistent viewBox/canvas alignment and a renderer component. | Recommended. |
| D | Do not import yet; use Figma screenshots only as visual reference. | Zero runtime and asset risk. Useful if export quality is uncertain. | Does not advance reusable STRQ anatomy assets. | Use only if vector export QA fails. |

Recommended strategy: Option C.

Use `9192:5535` for full-body base line art if its four groups can be cleanly separated into male front, male back, female front, and female back. Use `8673:69673` to extract per-gender, per-body-area target masks or overlay shapes. Recreate selected/unselected and STRQ-specific states in SwiftUI instead of importing state variants.

If alignment between `9192:5535` full-body groups and `8673:69673` mini silhouettes is too expensive, fall back to Option B with 30 body-area assets, still avoiding selected-state duplicates.

## Naming Plan

Runtime-facing anatomy assets and components should use STRQ-owned names. Sandow remains the source/reference label in this import plan and manifest documentation.

Preferred base anatomy assets:

- `STRQAnatomyMaleFrontBase`
- `STRQAnatomyMaleBackBase`
- `STRQAnatomyFemaleFrontBase`
- `STRQAnatomyFemaleBackBase`

Preferred body-area mask assets:

| Body Area | Male asset | Female asset |
|---|---|---|
| Lower Leg | `STRQAnatomyMaleLowerLegMask` | `STRQAnatomyFemaleLowerLegMask` |
| Upper Leg | `STRQAnatomyMaleUpperLegMask` | `STRQAnatomyFemaleUpperLegMask` |
| Abs | `STRQAnatomyMaleAbsMask` | `STRQAnatomyFemaleAbsMask` |
| Chest | `STRQAnatomyMaleChestMask` | `STRQAnatomyFemaleChestMask` |
| Shoulder | `STRQAnatomyMaleShoulderMask` | `STRQAnatomyFemaleShoulderMask` |
| Bicep | `STRQAnatomyMaleBicepMask` | `STRQAnatomyFemaleBicepMask` |
| Forearm | `STRQAnatomyMaleForearmMask` | `STRQAnatomyFemaleForearmMask` |
| Hand | `STRQAnatomyMaleHandMask` | `STRQAnatomyFemaleHandMask` |
| Neck | `STRQAnatomyMaleNeckMask` | `STRQAnatomyFemaleNeckMask` |
| Tricep | `STRQAnatomyMaleTricepMask` | `STRQAnatomyFemaleTricepMask` |
| Hamstring | `STRQAnatomyMaleHamstringMask` | `STRQAnatomyFemaleHamstringMask` |
| Glute | `STRQAnatomyMaleGluteMask` | `STRQAnatomyFemaleGluteMask` |
| Calf | `STRQAnatomyMaleCalfMask` | `STRQAnatomyFemaleCalfMask` |
| Back | `STRQAnatomyMaleBackMask` | `STRQAnatomyFemaleBackMask` |
| Trap | `STRQAnatomyMaleTrapMask` | `STRQAnatomyFemaleTrapMask` |

If the later import uses composite body-area assets instead of masks, drop the `Mask` suffix:

- `STRQAnatomyMaleChest`
- `STRQAnatomyFemaleChest`

Do not create selected-state asset names unless Option A is deliberately chosen later. Avoid:

- `STRQAnatomyMaleChestSelected`
- `STRQAnatomyFemaleChestSelected`

The selected state should normally be SwiftUI styling.

## Proposed Swift Enum Names

Future enum names, not implemented in this pass:

- `STRQAnatomyGender`
- `STRQAnatomyBodyArea`
- `STRQAnatomyState`
- `STRQAnatomyViewOrientation`
- `STRQAnatomyAsset`

Suggested enum case shapes:

- `STRQAnatomyGender`: `male`, `female`
- `STRQAnatomyBodyArea`: `lowerLeg`, `upperLeg`, `abs`, `chest`, `shoulder`, `bicep`, `forearm`, `hand`, `neck`, `tricep`, `hamstring`, `glute`, `calf`, `back`, `trap`
- `STRQAnatomyState`: `inactive`, `selected`, `primary`, `secondary`, `focus`, `reduce`
- `STRQAnatomyViewOrientation`: `front`, `back`
- `STRQAnatomyAsset`: model a base anatomy asset or a body-area mask asset by gender, orientation, and area.

## Proposed Future SwiftUI Components

Future component names, not implemented in this pass:

- `STRQAnatomyMuscleView`
- `STRQMuscleFocusCard`
- `STRQBodyAreaSelector`
- `STRQMuscleMapView`
- `STRQAnatomyLegend`

Intended use:

- Exercise Detail muscle focus
- Progress/Analytics muscle coverage
- Onboarding body focus
- Workout plan muscle balance
- Coach recommendations

Component responsibilities:

| Component | Intended role |
|---|---|
| `STRQAnatomyMuscleView` | Low-level renderer for one gender/orientation with selected body areas and state styling. |
| `STRQBodyAreaSelector` | Interactive body-area selection UI built on `STRQAnatomyBodyArea`; should not mutate STRQ models directly. |
| `STRQMuscleFocusCard` | Read-only or selectable card for top muscle groups in exercise detail, onboarding, or plan review contexts. |
| `STRQMuscleMapView` | Adapter view that maps `[MuscleGroup]` to Sandow anatomy areas for existing STRQ domain data. |
| `STRQAnatomyLegend` | Optional compact legend for primary/secondary/focus/reduce/intensity colors. |

## Risks And Open Questions

- Alignment risk: `8673:69673` is a mini silhouette component set, while `9192:5535` is a large full-body vector group. Their coordinate systems may not align without manual normalization.
- Granularity mismatch: STRQ has `lats`, `lowerBack`, `obliques`, `adductors`, `abductors`, `hipFlexors`, `tibialis`, and rotational/core-stability concepts that Sandow Anatomy Muscle does not represent directly.
- State styling risk: importing full composite variants as template images may tint the neutral body context, not just the selected muscle area.
- Hand area: Sandow includes `Hand`; STRQ has no hand muscle group and should probably ignore it for exercise focus.
- Full-body interaction: Anatomy Muscle is better for area tiles or focus chips. Full front/back body-map interaction likely needs `9192:5535` plus custom masks or STRQ's existing `MuscleRegionPaths`.
- Export QA: future import must verify SVG/PDF output stays vector-only, keeps transparent backgrounds where needed, and renders crisply in Xcode asset catalogs.

## Next Implementation Steps

1. Run a future import-only pass that exports sample SVGs from `8673:69673` for one male and one female area in both states, without adding them to the app yet.
2. Verify whether target-area shapes can be isolated as clean masks with stable viewBox/canvas dimensions.
3. Inspect the four `9192:5535` groups and label them as male front, male back, female front, and female back before any asset catalog import.
4. If masks and base line art align, import Option C assets only: base line art plus body-area masks, no selected duplicates.
5. If masks do not align, fall back to Option B with one composite asset per gender/body-area and SwiftUI state styling around the asset.
6. Only after assets are imported and verified, add enum/component code in a dedicated utility/component pass.
7. Only after components are stable, plan one runtime screen integration at a time.
