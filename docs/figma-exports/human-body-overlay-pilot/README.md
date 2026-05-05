# STRQ Human Body Overlay Pilot

Date: 2026-05-05

Mode: Licensed Source Mode

Figma file key: `LBvxljax0ixoTvbvvUeWVC`

Primary sources:

- Human Body / large anatomy vector groups: `9192:5535`
- Anatomy Muscle: `8673:69673`
- Existing pilot reference: `docs/figma-exports/anatomy-pilot/`

## What Was Exported

This is a QA-only export pass. It does not import assets into the runtime app.

Base body candidates:

- `STRQHumanBodyMaleFrontBase.candidate.svg` from `9192:5245`
- `STRQHumanBodyMaleBackBase.candidate.svg` from `9192:5428`
- `STRQHumanBodyFemaleFrontBase.candidate.svg` from `9192:5304`
- `STRQHumanBodyFemaleBackBase.candidate.svg` from `9192:5480`

Overlay candidates:

- Chest: male front, female front
- Back: male back, female back
- Shoulder: male front, male back, female front, female back
- Abs: male front, female front
- Glute: male back, female back
- Upper Leg: male front, female front
- Hamstring: male back, female back

No Swift, asset catalog, project, localization, test, font, or production runtime asset files were edited.

## Full Body Groups Inspected

The four large body groups under `9192:5535` are visually labelable from the Figma screenshot:

| Label | Node ID | Source name | Vector count | Label confidence |
|---|---:|---|---:|---|
| Male Front | `9192:5245` | `Group` | 58 | High |
| Male Back | `9192:5428` | `Group` | 51 | High |
| Female Front | `9192:5304` | `Group` | 64 | High |
| Female Back | `9192:5480` | `Group` | 52 | High |

The source layer names are still generic. The labels are visual labels, not semantic names provided by the Figma layer tree.

## Feasibility Result

Base + overlay is feasible for the full Human Body source.

Why:

- The four base bodies are neutral full-body vector artwork.
- The visible muscle regions are separate vector paths inside each full-body group.
- Transparent overlay candidates can be built from selected path groups on the same viewBox as their base body.
- The overlay candidates use `currentColor`, so SwiftUI can plausibly apply semantic tint through template/vector rendering after Xcode QA.
- Multiple overlays can be stacked because the candidate files contain only selected transparent paths, not full selected/unselected body composites.

The caveat is semantic isolation, not pixel alignment. The overlay candidates align with their base body because they were derived from the same full-body SVG coordinate system. Some muscle labels still need visual QA because the Figma child paths are generically named `Vector`.

## Muscle Isolation

High-confidence isolations:

- Chest, Abs, Glute
- Front Shoulder
- Most back-view Shoulder paths

Medium-confidence isolations:

- Back, because the full-body paths appear to cover a broad upper/mid-back cluster rather than a precisely labeled source area.
- Upper Leg / Quads, because the source area is an anterior upper-leg cluster and should be validated against STRQ's quads concept.
- Hamstrings, because the exported cluster is posterior upper leg and should be checked for thigh-versus-hamstring specificity.

No muscle path was exported where the layer separation looked too ambiguous for a useful QA candidate.

## Anatomy Muscle Comparison

`8673:69673` remains valuable, but it does not directly align to the full-body groups.

Findings:

- `Anatomy Muscle` is a 60-component set.
- Each component is `88x128`.
- It covers 15 body areas across Male/Female and Selected/Unselected.
- The full Human Body groups are separate large body vectors around 232-286 x 496.
- The coordinate systems are different, so `8673:69673` should not be treated as pixel-aligned overlays for `9192:5535`.

Recommended role for `8673:69673`:

- Use selected/unselected diffs as mask-source evidence if a full-body path cannot be confidently isolated.
- Keep the 88x128 components as a fallback mini-body renderer source, not as direct full-body overlays.

## Runtime Architecture Recommendation

Preferred architecture:

- Render one neutral base body SVG/PDF.
- Stack transparent, monochrome muscle overlays above it.
- Let SwiftUI apply color, opacity, blend, and priority.
- Support multiple active muscle groups by stacking overlays rather than importing selected-state composites.
- Keep primary/secondary/warning/recovery/progress semantics in code, not duplicated image assets.

Suggested visual roles:

- Onboarding selected: STRQ teal/blue.
- Exercise primary muscle: stronger blue/teal.
- Exercise secondary muscle: softer blue/teal opacity.
- Progress trained: green.
- Progress undertrained / volume low: amber.
- Warning / overload: red or pink.
- Inactive: neutral base line body only.

Avoid:

- Importing all 60 Anatomy Muscle variants as runtime assets.
- Duplicating selected/unselected full body composites.
- Using source orange as the default selected color unless the owner approves it.

## Import Recommendation

These files are not suitable for app import yet.

They are suitable as licensed QA/provenance candidates. Before importing into `Assets.xcassets`, run:

- Rork visual QA on all four bases and overlay stacks.
- Xcode SVG/PDF rendering QA for `currentColor` and template tint behavior.
- Multi-overlay QA for primary/secondary states.
- Specific checks for Back, Upper Leg, and Hamstring isolation.
- A conversion decision: keep SVG if Xcode renders/tints correctly, otherwise convert normalized candidates to vector PDF.

## Contact Sheet

No PNG contact sheet was created in this pass. The local runtime did not have a simple SVG-to-PNG renderer available, and the contact sheet was optional. The exported SVGs are still available for direct visual inspection.

## Next Prompt Recommendation

```text
Use Licensed Source Mode. From docs/figma-exports/human-body-overlay-pilot/, run a QA normalization pass for the full Human Body base + overlay candidates: visually validate the four bases and the Chest, Back, Shoulder, Abs, Glute, Upper Leg, and Hamstring overlays; create a dark-background preview/contact sheet; decide whether SVG currentColor or vector PDF is safer for SwiftUI tinting; do not edit Swift, Assets.xcassets, project files, localization, tests, widgets, watch targets, or production runtime assets.
```
