# STRQ Anatomy Overlay System Plan

## 1. Executive summary

STRQ should build the anatomy system as base body artwork plus transparent muscle overlays or masks. The licensed Figma `Anatomy Muscle` source is strong enough to support that direction, but the raw selected/unselected full-body SVG exports should stay QA/provenance assets until a normalization pass removes the source card background, rounded border, clip-frame assumptions, and source colors.

Recommended direction:

- Use neutral base body assets for front/back body maps.
- Use transparent per-muscle masks or overlays for runtime tint.
- Let SwiftUI own selected, unselected, primary, secondary, warning, overload, recovery, disabled, and reduced-emphasis states.
- Avoid importing duplicate selected/unselected full composites unless mask extraction fails for a specific muscle.
- Use the Figma selected/unselected pairs as source evidence for deriving masks, not as final runtime assets.
- Keep the experience fitness-focused by using training muscle groups and coaching language, not medical anatomy labels or organ visuals.

Base plus overlay is feasible, with one caveat: the large anatomy vector groups and the 88x128 `Anatomy Muscle` components are not proven to share a coordinate system yet. V1 should therefore include an export normalization QA pass that either aligns all masks to the large base bodies or deliberately ships the 88x128 muscle-card system as a separate normalized tile renderer.

## 2. Figma source inventory

Figma usage:

- Mode: Licensed Source Mode.
- Tooling: [@Figma](plugin://figma@openai-curated) read-only, with `figma-use` loaded first.
- No Figma canvas writes, app asset exports, Swift edits, asset catalog edits, project edits, localization edits, or test edits were made.
- Figma file key requested by existing manifest: `LBvxljax0ixoTvbvvUeWVC`.
- Plugin API runtime note: `figma.fileKey` reported `headless` while operating on the requested file.

Primary source:

| Source | Node | Type | Count | Canvas |
|---|---:|---|---:|---|
| Anatomy Muscle | `8673:69673` | `COMPONENT_SET` | 60 components | Every component is `88x128` |
| Large anatomy vector groups | `9192:5535` | `FRAME` | 4 generic groups, 225 vectors | Parent is about `1099.6x496.4` |

Full `Anatomy Muscle` inventory:

| Body Area | Male Unselected | Male Selected | Female Unselected | Female Selected |
|---|---:|---:|---:|---:|
| Lower Leg | `9023:267766` | `9024:101012` | `9024:102146` | `9025:100048` |
| Upper Leg | `9023:268211` | `9024:101087` | `9024:102516` | `9025:100196` |
| Abs | `9023:268361` | `9024:101162` | `9024:102664` | `9025:100122` |
| Chest | `9024:97738` | `9024:101237` | `9024:102739` | `9025:100270` |
| Shoulder | `9024:97814` | `9024:101312` | `9024:102960` | `9025:100344` |
| Bicep | `9024:98188` | `9024:101387` | `9025:97596` | `9025:100418` |
| Forearm | `9024:98338` | `9024:101462` | `9025:97671` | `9025:100492` |
| Hand | `9024:98564` | `9024:101996` | `9025:97819` | `9025:100566` |
| Neck | `9024:98414` | `9024:101537` | `9025:97967` | `9025:101030` |
| Tricep | `9024:98705` | `9024:101612` | `9025:98263` | `9025:100640` |
| Hamstring | `9024:99092` | `9024:101676` | `9025:98405` | `9025:100705` |
| Glute | `9024:99220` | `9024:101740` | `9025:98471` | `9025:100770` |
| Calf | `9024:99284` | `9024:101804` | `9025:98601` | `9025:100835` |
| Back | `9024:99348` | `9024:101868` | `9025:98731` | `9025:100900` |
| Trap | `9024:99412` | `9024:101932` | `9025:98927` | `9025:100965` |

Inventory conclusions:

- Body areas: Abs, Back, Bicep, Calf, Chest, Forearm, Glute, Hamstring, Hand, Lower Leg, Neck, Shoulder, Trap, Tricep, Upper Leg.
- Genders/body variants in source: Male and Female.
- States in source: Selected and Unselected.
- Full source count: 15 body areas x 2 genders x 2 states = 60 components.
- Canvas consistency: all `Anatomy Muscle` variants are `88x128`; pilot SVGs share `viewBox="0 0 88 128"`.
- Selected/unselected source colors are systematic. Selected uses warm source tones such as `#FFF7ED`, `#FDBA74`, `#FED7AA`, and `#F97316`; unselected uses neutral source tones such as `#FAFAFA`, `#A1A1AA`, `#E4E4E7`, `#52525B`, and `#D4D4D8`.
- Layer names are not semantic enough for direct muscle extraction. Descendant vectors are generically named `Vector`, so the component variant name tells us the muscle, while individual paths do not.

Large anatomy vector group inventory:

| Group | Node | Size | Vectors | Fill/stroke pattern |
|---|---:|---|---:|---|
| Group 0 | `9192:5245` | about `271.61x495.99` | 58 | Neutral fills, `#A1A1AA` strokes |
| Group 1 | `9192:5428` | about `285.67x496.00` | 51 | Neutral fills, `#A1A1AA` strokes |
| Group 2 | `9192:5304` | about `232.64x496.38` | 64 | Neutral fills, `#A1A1AA` strokes |
| Group 3 | `9192:5480` | about `237.68x496.40` | 52 | Neutral fills, `#A1A1AA` strokes |

The large groups look like candidate full-body base artwork, likely male/female and front/back, but their names are all `Group`. They need visual labeling and coordinate normalization before runtime use.

## 3. Pilot export findings

Existing pilot folder:

- `docs/figma-exports/anatomy-pilot/`
- `export-manifest.json`
- `README.md`
- 16 QA SVG exports for Chest, Back, Abs, and Glute across Male/Female and Selected/Unselected.

Pilot findings to preserve:

- All 16 exports are vector SVGs.
- No raster `<image>` elements were found.
- Every export is `width="88"`, `height="128"`, with `viewBox="0 0 88 128"`.
- Male and Female variants are visually distinct.
- Selected and Unselected variants are visually distinct.
- Raw SVGs include a source rounded component background, border, and clip path.
- Raw SVGs are suitable as provenance/QA exports, not direct production runtime assets.

Important structural finding from the pilot SVGs:

- The source card background appears as a full `88x128` rounded rect.
- The source border appears as a rounded rect stroke, for example selected border `#F97316` and unselected border `#D4D4D8`.
- These card shapes must be stripped before producing transparent overlays or masks.

## 4. Base vs overlay feasibility

Base vs overlay is feasible and recommended.

Why it works:

- The Anatomy Muscle source is a complete 15-area matrix across Male/Female and Selected/Unselected.
- Every component uses the same `88x128` component canvas.
- Targeted Plugin API comparisons found selected/unselected sample pairs with identical indexed geometry and paint-only differences, including Male Chest, Female Chest, Male Back, Male Abs, and Male Lower Leg.
- Most selected/unselected pairs share the same child count and type counts. The earlier broad pass flagged one Male Lower Leg child-count inconsistency, but a targeted leaf pass still found 7 selected leaves and 7 unselected leaves with identical indexed bounds.
- Selected body-area shapes can be identified from color role: the actual emphasized muscle paths use selected fill/stroke `#FED7AA` and `#F97316`; their unselected counterparts use `#E4E4E7` and `#52525B`.

Why raw selected components should not be runtime assets:

- In selected variants, many non-highlight body strokes also become warm `#FDBA74`.
- The selected component is a full composite, not a transparent muscle-only overlay.
- If multiple full selected composites are stacked, full-body strokes and card backgrounds will conflict.
- Source orange is not STRQ's default selected-state direction.

Layer isolation conclusion:

- Muscle highlights are not cleanly isolated by semantic layer names in Figma.
- Direct layer extraction is possible only by using component variant context plus paint rules and geometry comparison.
- A selected-minus-unselected diff workflow is needed for trustworthy mask derivation, especially to avoid accidentally treating the whole warm selected outline as a muscle overlay.

Recommended strategy:

- Primary: derive transparent per-area masks from selected/unselected pairs using geometry matching and selected highlight paint roles.
- Secondary: use selected-minus-unselected diffing to validate the mask and catch cases where color filtering captures too much or too little.
- Fallback: if a muscle cannot be isolated cleanly, export a transparent full body-area composite for that specific area only, still without selected/unselected duplicates.

Large base body conclusion:

- Large anatomy vector groups `9192:5535` can probably serve as neutral base bodies because they are all-vector, neutral-filled, and full-body scale.
- They are not runtime-ready because they are generically named and not proven to align with `Anatomy Muscle` overlays.
- Before implementation, label them as Male/Female and Front/Back, export QA samples only, and normalize them to a shared viewBox.

## 5. Recommended anatomy runtime architecture

Runtime asset families:

| Asset family | Purpose | Source |
|---|---|---|
| Base body | Neutral body line art that provides silhouette and context | Prefer large groups `9192:5535` after labeling and normalization |
| Muscle mask | Transparent per-muscle shape used for tint, opacity, and blend state | Derived from Anatomy Muscle `8673:69673` selected/unselected pairs |
| Optional fallback composite | Transparent body-area composite when a mask is not reliable | Derived from one Anatomy Muscle component, stripped of card chrome |

Runtime model:

- Keep the existing STRQ `MuscleGroup` domain model as the product source of truth.
- Add an anatomy rendering adapter later, not in this docs pass.
- The adapter should map each `MuscleGroup` to one or more anatomy overlays, an orientation, and a confidence level.
- Use a body variant dimension, but avoid making the UI feel like a clinical gender selector. Runtime can support `male`, `female`, and eventually `neutral` or `default` presentation if product direction wants a non-gendered choice.
- Use orientation-aware rendering: front muscles, back muscles, and muscles that can appear on both views.

Renderer behavior:

- Render base body first.
- Render all active transparent overlays above the base.
- Allow multiple selected muscles at once.
- Resolve primary/secondary conflicts by strongest role winning, then render secondary at lower opacity.
- Keep warning, overload, recovery, focus, and reduce states as semantic visual roles, not duplicated assets.

Base body strategy:

- Use `STRQAnatomyMaleFrontBase`, `STRQAnatomyMaleBackBase`, `STRQAnatomyFemaleFrontBase`, and `STRQAnatomyFemaleBackBase` if large groups can be labeled and normalized.
- If the large groups do not align with derived masks, do not force them. Use normalized `Anatomy Muscle` tile composites for V1 and treat full-body map alignment as V2.
- Do not use the raw 88x128 selected/unselected card exports as the base.

Overlay/mask strategy:

- Prefer mask assets with transparent background and a single black/white or template-fill silhouette.
- Apply SwiftUI tint/foreground style at runtime.
- If Xcode/SVG mask behavior is unreliable, convert masks to vector PDF or use a known SwiftUI-compatible template path import path in a later implementation pass.
- Do not export all 60 selected/unselected full composites into `Assets.xcassets`.

## 6. Muscle group mapping

The source has 15 Figma body areas. STRQ has a richer `MuscleGroup` enum. V1 should map the richer product model onto a smaller set of source-backed anatomy areas.

| STRQ MuscleGroup | Figma area or overlay | Orientation | Mapping decision |
|---|---|---|---|
| `chest` | Chest | Front | Direct |
| `back` | Back | Back | Direct |
| `lats` | Back, optionally side portions of Back if a later mask split is approved | Back | Merge into Back for V1 |
| `shoulders` | Shoulder | Front/Back | Direct |
| `biceps` | Bicep | Front | Direct |
| `triceps` | Tricep | Back | Direct |
| `forearms` | Forearm | Front/Back | Direct |
| `traps` | Trap | Back | Direct, with Back overlap QA |
| `neck` | Neck | Front/Back | Defer unless exercise data needs it |
| `arms` | Bicep + Tricep + Forearm | Front/Back | Aggregate |
| `abs` | Abs | Front | Direct |
| `obliques` | Abs, optionally side edges if later split is possible | Front | Merge into Abs for V1 |
| `lowerBack` | Back | Back | Merge into Back for V1 |
| `glutes` | Glute | Back | Direct |
| `quads` | Upper Leg | Front | Map Upper Leg to Quads for V1 |
| `hamstrings` | Hamstring | Back | Direct |
| `calves` | Calf | Back | Direct |
| `adductors` | Upper Leg | Front | Merge into Upper Leg for V1 |
| `abductors` | Upper Leg/Glute boundary | Front/Back | Merge into Upper Leg or Glute by exercise context |
| `hipFlexors` | Upper Leg/Abs boundary | Front | Merge into Upper Leg for V1 |
| `tibialis` | Lower Leg | Front | Direct enough for V1, label as lower leg if needed |
| `coreStability` | Abs | Front | Aggregate |
| `rotationAntiRotation` | Abs/Obliques | Front | Aggregate |

Mapping/merging notes:

- Abs/Obliques: source only has Abs, so obliques should map to Abs unless a later path split is manually curated.
- Upper Leg/Quads: source uses Upper Leg; STRQ should expose Quads to users and map it to Upper Leg.
- Back/Lats/Lower Back: source has Back but not Lats or Lower Back. Use Back in V1, and only split if export QA can isolate subregions reliably.
- Trap/Back: source has both Trap and Back. QA must ensure they do not visually overpaint in confusing ways when both are active.
- Arms: source has Bicep, Tricep, and Forearm, while STRQ also has aggregate Arms. Render aggregate Arms as a composite overlay set.
- Hand: source includes Hand, but STRQ does not currently need hand as a primary fitness body area. Exclude from V1.
- Neck: source includes Neck, but it is low-priority and can make the app feel more clinical. Exclude from V1 unless exercise coverage requires it.

## 7. Asset naming convention

Use STRQ-owned names only. Keep Figma source labels and node IDs in docs/manifests, not runtime symbols or user-facing strings.

Base body assets:

- `STRQAnatomyMaleFrontBase`
- `STRQAnatomyMaleBackBase`
- `STRQAnatomyFemaleFrontBase`
- `STRQAnatomyFemaleBackBase`

Mask assets:

- `STRQAnatomyMaleFrontChestMask`
- `STRQAnatomyFemaleFrontChestMask`
- `STRQAnatomyMaleBackBackMask`
- `STRQAnatomyFemaleBackBackMask`
- Pattern: `STRQAnatomy{BodyVariant}{Orientation}{Area}Mask`

Area names:

- Use UpperCamelCase: `Chest`, `Back`, `Shoulder`, `Bicep`, `Tricep`, `Forearm`, `Abs`, `Glute`, `UpperLeg`, `Hamstring`, `Calf`, `Trap`, `LowerLeg`.
- Avoid runtime asset names `Selected` and `Unselected` for masks.
- Use `Composite` only for approved fallback assets, for example `STRQAnatomyMaleFrontChestComposite`.

Manifest fields for future exports:

- STRQ asset name
- Figma source node
- Body variant
- Orientation
- Figma body area
- STRQ `MuscleGroup` mapping
- Export method
- ViewBox
- Transparent background true/false
- Card background removed true/false
- Border removed true/false
- Mask/source confidence

## 8. Export normalization requirements

Required for all runtime candidates:

- Remove source card background.
- Remove source rounded border.
- Preserve transparent background.
- Preserve shared viewBox and alignment within each asset family.
- Normalize paths and fills so masks are tintable.
- Remove or normalize clip paths that only exist to support the source rounded card.
- Keep source provenance in docs and manifests.
- Avoid duplicate selected/unselected full composites when masks are possible.

Mask derivation requirements:

- Start from matching Selected and Unselected components for the same Body Area, Gender, and canvas.
- Strip the background `rect` and outer border before comparison.
- Treat `#FED7AA` fill plus `#F97316` stroke as the strongest selected highlight signal.
- Do not treat every `#FDBA74` selected stroke as a muscle mask; many non-highlight body outlines use it.
- Use geometry matching to confirm selected/unselected path pairs before extracting the mask.
- Produce a transparent output where the mask alone occupies the same coordinate space as the source component or the normalized base body.

Base-body normalization requirements:

- Label the four large groups as Male/Female and Front/Back before runtime import.
- Export neutral base candidates to QA/provenance only first.
- Normalize all base candidates to one shared viewBox per orientation/body-variant family.
- Verify whether base body candidates align with 88x128 Anatomy Muscle overlays.
- If they do not align, derive a transform or keep tile and full-body renderers separate.

## 9. SwiftUI rendering strategy

No Swift should be edited in this pass. Future implementation should follow this shape:

- `STRQAnatomyRenderer` receives selected/active muscles, body variant, orientation, and display mode.
- `STRQAnatomyMuscleRole` describes roles such as selected, primary, secondary, warning, overload, recovery, focus, reduce, and inactive.
- `STRQAnatomyAssetMap` maps `MuscleGroup` to one or more mask assets and an orientation.
- Base art renders once.
- Overlays render as template/tintable images or vector masks.
- Primary overlays use the strongest opacity and stroke.
- Secondary overlays use lower opacity.
- Warning/overload/recovery colors override selected/focus color.
- Multiple selected muscles render together by stacking masks, not full body composites.

For Exercise Info:

- Primary muscles should use high-intensity tint and optional thin outline.
- Secondary muscles should use the same hue or a nearby neutral/steel hue at lower opacity.
- If primary and secondary overlap, primary wins.

For Onboarding muscle focus:

- Focus muscles and reduce muscles need different roles.
- Focus should feel positive and goal-oriented.
- Reduce should feel low-volume or managed, not negative or injured.

For Progress and Coach:

- Coverage can use opacity or small multiples by muscle volume.
- Overload and recovery constraints should use semantic warning/recovery colors, not generic selected colors.
- Coach explanations should connect the highlight to training volume, balance, recovery, or exercise role.

## 10. Visual state system

Recommended visual roles:

| State | Visual treatment |
|---|---|
| Unselected | Base body only or very low-opacity neutral mask |
| Selected | STRQ-owned blue/teal/steel selected tint, not source orange |
| Primary | Strongest selected intensity, about 85-100 percent opacity |
| Secondary | Same family at about 40-60 percent opacity |
| Focus | Positive selected treatment, possibly same as selected with stronger emphasis |
| Reduce | Muted cool/neutral treatment, not danger |
| Warning | Semantic warning color |
| Overload | Warning or danger-adjacent semantic color, depending on severity |
| Recovery | Recovery/readiness semantic color, distinct from success and warning |
| Disabled/unavailable | Neutral low opacity |

Answers to key color questions:

- Blue/teal should be the default selected color only if it is STRQ's approved anatomy selected accent. It is a better default than source orange because current STRQ direction treats orange as legacy or scoped energy, not broad selection.
- Source warm orange should remain QA/provenance only unless owner-approved for a narrow training-energy role.
- Semantic colors should absolutely be used for warning, overload, and recovery states. Warning/overload must not look like selected or reward.
- Primary vs secondary should be shown by intensity, not by unrelated colors.

Multiple muscle handling:

- Multiple muscles can be highlighted at the same time if the renderer uses masks/overlays.
- Full selected composites cannot support multi-select cleanly because each composite restyles the whole body.
- When multiple overlays overlap, render by role priority: warning/overload, primary, selected/focus, secondary, inactive.

Fitness tone:

- Use labels such as Chest, Back, Quads, Hamstrings, Glutes, Abs, and Shoulders.
- Avoid clinical labels unless STRQ already uses them for training purposes.
- Do not use organ anatomy as default fitness visuals.
- Avoid injury diagnosis language. Use training terms such as recovery load, volume, stimulus, and balance.

## 11. Screen integration opportunities

Onboarding muscle focus:

- Replace generic muscle chips and simple body map regions with a guided anatomy selector.
- Support multiple focus muscles and reduce muscles together.
- Keep copy goal-oriented and inclusive.

Exercise Info primary/secondary display:

- Show primary muscles with high-intensity overlays.
- Show secondary muscles with low-intensity overlays.
- Support front/back toggle or automatic orientation based on muscles.

Exercise Library filters:

- Use anatomy chips or mini maps for body-region filters after filter behavior is protected.
- Keep search and filter semantics unchanged in a later implementation pass.

Progress muscle coverage:

- Use overlay opacity, rings, or small multiples to show weekly coverage.
- Use direct STRQ muscle-balance categories rather than medical precision.

Coach muscle imbalance and volume explanations:

- Highlight undertrained and overworked muscles in Coach explanations.
- Use semantic warning/recovery states for overload and fatigue.
- Keep the visual as explanation support, not a diagnosis.

## 12. Risks and guardrails

| Risk | Guardrail |
|---|---|
| Importing all 60 source composites | Import only normalized base/mask assets that support real screens |
| Source card chrome leaking into runtime | Strip rounded background, border, and source clip frame |
| Selected/unselected duplicate bloat | Use SwiftUI visual state where possible |
| Orange becoming the default brand state | Use STRQ-owned selected tint and semantic colors |
| Medical tone | Use fitness group names, avoid organ visuals and diagnostic claims |
| Body variant sensitivity | Treat Male/Female as artwork variants, not product judgment |
| Mapping ambiguity | Document direct, merged, and deferred mappings |
| Mask overpaint conflict | QA multi-select, primary/secondary, Trap/Back, Abs/Obliques, and Upper Leg/Quads |
| Base-body alignment mismatch | Normalize and QA coordinate systems before app import |
| Accessibility regression | Provide product labels from STRQ muscle names and state roles |

Rork QA is not required for this docs-only plan. It will be required for any future SwiftUI renderer, app asset import, or production visual integration.

## 13. QA checklist

Source inventory QA:

- Confirm 60 Anatomy Muscle variants remain present.
- Confirm 15 body areas, Male/Female, and Selected/Unselected are still complete.
- Confirm every Anatomy Muscle variant remains `88x128`.
- Confirm large anatomy groups are still four groups and all-vector.

Export normalization QA:

- Confirm no exported runtime candidate includes a source rounded background.
- Confirm no exported runtime candidate includes a source border.
- Confirm transparent backgrounds.
- Confirm shared viewBox and alignment within a family.
- Confirm no raster image tags.
- Confirm mask paths are the intended muscle area only.
- Confirm selected-minus-unselected diff agrees with color-derived masks.

Overlay accuracy QA:

- Chest, Back, Abs, Glute pilot masks align with their neutral source counterparts.
- Upper Leg/Quads and Hamstring do not visually conflict.
- Trap and Back can be shown together without unreadable overpaint.
- Abs and Obliques mapping is visually understandable.
- Lower Leg/Tibialis and Calf are not confused on front/back views.
- Multiple selected muscles render together without card/background artifacts.
- Primary vs secondary intensity remains legible on dark carbon and light surfaces.
- Warning, overload, and recovery states are semantically distinct.

Runtime QA for a later implementation pass:

- Exercise Detail routes and primary/secondary muscle data remain unchanged.
- Exercise Library search/filter behavior remains unchanged.
- Onboarding focus/reduce persistence remains unchanged.
- Progress and Coach calculations remain unchanged.
- Accessibility labels use STRQ muscle names and state roles.

## 14. Recommended V1 muscle subset

Recommended V1 direct source areas:

- Chest
- Back
- Shoulder
- Bicep
- Tricep
- Forearm
- Abs
- Glute
- Upper Leg
- Hamstring
- Calf
- Trap
- Lower Leg

Recommended V1 STRQ product coverage:

- `chest`
- `back`
- `lats` via Back
- `shoulders`
- `biceps`
- `triceps`
- `forearms`
- `traps`
- `arms` via Bicep + Tricep + Forearm
- `abs`
- `obliques` via Abs
- `lowerBack` via Back
- `glutes`
- `quads` via Upper Leg
- `hamstrings`
- `calves`
- `adductors` via Upper Leg
- `abductors` via Upper Leg/Glute context
- `hipFlexors` via Upper Leg
- `tibialis` via Lower Leg
- `coreStability` via Abs
- `rotationAntiRotation` via Abs

Defer from V1:

- Hand, because STRQ does not currently expose it as a primary muscle group.
- Neck, because it is low priority and can pull the experience toward clinical anatomy unless a real exercise surface needs it.

V1 should prioritize the screens that already have strong STRQ muscle data: Exercise Detail, Exercise Library filters, Onboarding muscle focus, Progress muscle coverage, and Coach volume/imbalance explanations.

## 15. Exactly one next prompt

```text
Use Licensed Source Mode. Create a docs/figma-exports/anatomy-overlay-normalization/ QA-only normalization pass from Figma Anatomy Muscle node 8673:69673 and large anatomy vector groups 9192:5535: label the four large base-body groups, derive transparent background-free mask candidates for the V1 source areas, validate selected-minus-unselected diffs against the source colors, write a manifest and README, and do not edit Swift, Assets.xcassets, project files, localization, tests, widgets, watch targets, live activities, or production runtime assets.
```
