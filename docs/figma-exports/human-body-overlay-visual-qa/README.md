# STRQ Human Body Overlay Visual QA

Date: 2026-05-06

Mode: Licensed Source Mode

Source pilot folder: `docs/figma-exports/human-body-overlay-pilot/`

This QA-only pass validates the licensed Human Body base SVG candidates and transparent `currentColor` overlay candidates exported in the previous pilot. No Swift files, app asset catalogs, project files, localization files, tests, fonts, production runtime assets, or existing pilot exports were edited.

## Visual QA Summary

The current Human Body base plus overlay direction is visually viable for STRQ. All 20 SVG files referenced by `human-body-overlay-manifest.json` exist, render successfully, and stay on transparent backgrounds. The generated PNG previews show the four base bodies on a dark/carbon surface, all 16 overlays alone in STRQ-like teal/blue, each overlay composited over its matching base, four multi-select examples, and one semantic-state comparison.

Generated previews:

- `contact-sheet-bases.png`
- `contact-sheet-overlays-alone.png`
- `contact-sheet-overlays-on-base.png`
- `preview-male-front-multiselect.png`
- `preview-male-back-multiselect.png`
- `preview-female-front-multiselect.png`
- `preview-female-back-multiselect.png`
- `preview-semantic-states.png`

## SVG Structure Findings

- Base candidates: 4 files for Male Front, Male Back, Female Front, and Female Back.
- Overlay candidates: 16 files for Chest, Back, Shoulder, Abs, Glute, Upper Leg, and Hamstring across the relevant gender/orientation views.
- All referenced SVG files exist.
- All SVGs use `width="100%"` and `height="100%"` with explicit `viewBox` values.
- No embedded raster `<image>` elements were found.
- No clipping or `clipPath` usage was found.
- No source card background, rounded border, or white canvas appeared in the rendered previews.
- Base SVGs use fixed source fills/strokes and are not `currentColor` template assets.
- Overlay SVGs use `currentColor` for fill and stroke and preserve transparent backgrounds.

Path counts are recorded per asset in `visual-qa-manifest.json`. The overlay counts match the expected isolated candidate complexity: small two-path regions for Chest, Shoulder, and Glute; larger segmented clusters for Abs, Upper Leg, Back, and Hamstring.

## Alignment Findings

Alignment confidence is high for the exported overlay system. Each overlay shares the exact `viewBox` of its matching base body and was derived from the same full-body Human Body coordinate system.

The visual previews confirm:

- Male Front: Chest, Shoulder, Abs, and Upper Leg sit correctly over the base.
- Male Back: Back, Shoulder, Glute, and Hamstring sit correctly over the base.
- Female Front: Chest, Shoulder, Abs, and Upper Leg sit correctly over the base.
- Female Back: Back, Shoulder, Glute, and Hamstring sit correctly over the base.

Semantic isolation still needs owner review for the medium-confidence candidates:

- Back appears visually useful, but it is a broad upper/mid-back cluster rather than a narrowly named muscle mask.
- Upper Leg reads as an anterior thigh/quads candidate, but STRQ should decide whether to name it Quads or keep the source-backed Upper Leg concept in asset provenance.
- Hamstring aligns well but should be reviewed for posterior-thigh specificity before production naming.

## Tinting Findings

The bundled preview renderer respected SVG `currentColor` when the root color attribute was changed. A probe on `STRQHumanBodyMaleFrontChestOverlay` rendered distinct teal and amber outputs, confirming that the exported overlay SVGs can be recolored by a renderer that supports inherited `currentColor`.

This is promising, but it does not prove Xcode asset-catalog or SwiftUI template tint behavior. The current SVG files should be treated as QA/provenance and conversion sources until a targeted Xcode import smoke test proves `currentColor` survives app import.

## Multi-overlay Findings

All requested multi-select previews were generated without fake overlays:

- Male Front: Chest + Shoulder + Abs
- Male Back: Back + Glute + Hamstring
- Female Front: Chest + Abs + Upper Leg
- Female Back: Back + Glute + Hamstring

The stacks align cleanly and do not introduce card/background artifacts. Primary and secondary intensity can be simulated by changing tint and opacity at composition time, which supports the preferred runtime architecture: base body first, transparent overlays above it, state handled by code rather than duplicated selected/unselected assets.

## Semantic-state Findings

`preview-semantic-states.png` simulates:

- selected = STRQ teal/blue
- primary = stronger teal/blue
- secondary = softer teal/blue opacity
- warning / volume low = amber
- recovery / overload = red/pink

The semantic colors remain legible on carbon without becoming neon. Primary versus secondary is best handled by intensity and opacity, not unrelated hues. Amber and red/pink should be reserved for training meaning such as low volume, caution, recovery, or overload.

## Dark Background Suitability

The base bodies and overlays are suitable on a dark/carbon background. The base line art stays readable, teal/blue overlays are visible without overwhelming the body, and no preview introduced a white canvas. The dark treatment matches STRQ's product direction better than the source orange selected-state language.

## Import Readiness Recommendation

Decision: suitable after minor cleanup, not suitable for app asset import as-is.

The current SVG `currentColor` overlay candidates are strong visual QA candidates and good conversion sources. They are not ready to drop directly into `Assets.xcassets` because the app import path still needs Xcode validation:

- Normalize `width` and `height` away from percentage values before app import.
- Confirm whether Xcode preserves `currentColor`/template tint behavior for these SVGs.
- Prefer vector PDF conversion for runtime import if SVG tint behavior is not proven.
- Preserve the shared viewBox and transparent backgrounds during any cleanup/conversion.
- Owner-review Back, Upper Leg, and Hamstring semantics before production asset naming.

Recommended format: keep SVG as source/provenance; prefer normalized vector PDF for runtime import unless a focused Xcode SVG/template-tint smoke test passes. A new Figma export approach is not needed based on this visual QA pass.

## Limitations

- This pass used local SVG-to-PNG composition, not Xcode, SwiftUI, Rork, or device runtime rendering.
- It validates visual composition and renderer-level `currentColor` behavior, not app asset-catalog behavior.
- Figma layer names remain generic, so semantic confidence still comes from the pilot manifest and visual review.

## Next Recommended Prompt

```text
Use Licensed Source Mode. Run a QA-only Xcode asset-rendering smoke test for the Human Body overlay candidates: copy the approved base and overlay SVGs/PDF conversions into a temporary non-runtime scratch asset catalog or standalone preview target, compare SVG currentColor tint against normalized vector PDF output, document whether Xcode/SwiftUI preserves template tinting, and do not edit ios/STRQ, ios/STRQWidget, ios/STRQWatch, production Assets.xcassets, project files, Swift files, localization, tests, fonts, or existing pilot exports.
```
