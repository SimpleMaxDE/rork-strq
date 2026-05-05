# STRQ Human Body Overlay Xcode Smoke

Date: 2026-05-06

Mode: Licensed Source Mode

Source folders:

- `docs/figma-exports/human-body-overlay-pilot/`
- `docs/figma-exports/human-body-overlay-visual-qa/`

This is a QA-only asset-rendering smoke pass for the licensed Human Body base and overlay candidates. It does not import anything into the production app, and it does not modify Swift, app asset catalogs, project files, localization, tests, Widget, Watch, fonts, or runtime assets.

## Smoke-Test Asset List

- Male Front Base: `STRQHumanBodyMaleFrontBase`
- Male Front Chest Overlay: `STRQHumanBodyMaleFrontChestOverlay`
- Male Front Shoulder Overlay: `STRQHumanBodyMaleFrontShoulderOverlay`
- Male Back Base: `STRQHumanBodyMaleBackBase`
- Male Back Back Overlay: `STRQHumanBodyMaleBackBackOverlay`
- Female Front Base: `STRQHumanBodyFemaleFrontBase`
- Female Front Chest Overlay: `STRQHumanBodyFemaleFrontChestOverlay`
- Female Back Base: `STRQHumanBodyFemaleBackBase`
- Female Back Glute Overlay: `STRQHumanBodyFemaleBackGluteOverlay`

Copied source SVGs are in `svg/`. Normalized SVG variants are in `svg-normalized/`. Vector PDF candidates are in `pdf/`. A docs-only scratch asset catalog is in `HumanBodyOverlaySmoke.xcassets/`.

## What Was Checked

- `viewBox` presence and base/overlay coordinate pairing.
- `width` and `height` source attributes.
- `currentColor` usage on overlays.
- Base and overlay `fill` / `stroke` semantics.
- Transparent background risk.
- Raster `<image>` usage.
- Mask, clip-path, filter, gradient, `use`, script, animation, and other likely Xcode SVG risk elements.
- Local vector PDF conversion from normalized SVG copies.
- Scratch `.xcassets` packaging for later macOS/Xcode smoke testing.

## What Was Not Checked

- Real Xcode asset-catalog import.
- SwiftUI `Image` rendering.
- SwiftUI `template tint` behavior in app runtime.
- Device, simulator, or Rork runtime screenshots.
- Production `ios/STRQ/Assets.xcassets` behavior.
- Owner approval of muscle semantics.

This pass ran on Windows, so macOS/Xcode validation is still required before any production import.

## SVG Compatibility Findings

All nine smoke SVGs have an explicit `viewBox`, no embedded raster images, no root background canvas, and no mask, clip-path, filter, foreignObject, pattern, gradient, `use`, script, or animation elements. The overlays share the exact full-body `viewBox` of their matching base asset, which preserves overlay alignment in the source coordinate system.

The SVGs are still not ideal for direct Xcode runtime import as-is:

- Source SVGs use `width="100%"` and `height="100%"`.
- Overlay SVGs rely on inherited `currentColor`.
- Base SVGs use fixed white/gray paint, including CSS `var(...)` paint attributes from the source export.
- Root `preserveAspectRatio="none"` means base and overlay images must be rendered in exactly the same frame to avoid drift.
- Windows static checks cannot prove how Xcode resolves these attributes.

Direct SVG import may work, but SwiftUI template tint is not proven here.

## PDF Conversion Findings

CairoSVG was attempted first, but it could not run on this Windows host because the native Cairo library was unavailable.

A Node-based vector conversion using `pdfkit` and `svg-to-pdfkit` succeeded for all nine smoke assets. The generated PDF candidates are in `pdf/`, and the scratch `.xcassets` package uses those PDFs with vector preservation enabled. Base image sets are marked as original rendering. Overlay image sets are marked as template rendering.

The normalized SVG variants set numeric `width` and `height` from each `viewBox` and resolve CSS `var(...)` paint fallbacks before PDF conversion. Overlay `currentColor` is resolved into monochrome vector PDF paint, so tinting should be handled by the asset catalog template setting rather than by SVG inheritance.

Overlay alignment should be preserved after conversion because the PDFs use the same viewBox-derived dimensions as their normalized SVG sources. Real macOS/Xcode rendering still needs to confirm this visually.

## Runtime Decision

Recommended runtime format: vector PDF.

Recommended next path: B. convert to vector PDF first, then import.

Reason: the smoke set is vector-only and structurally clean, but direct SVG import still depends on Xcode handling percentage sizing, inherited `currentColor`, and source CSS paint attributes. Vector PDF with template rendering is the safer runtime import path for overlays, while base bodies can stay original-rendered vector PDFs.

Rork QA is not required to complete this static rendering smoke pass. Rork or owner visual QA is still required before treating final anatomy visuals as production-approved.

## Exact Next Prompt

```text
Use Licensed Source Mode. On macOS with Xcode available, run a QA-only asset-catalog smoke test using docs/figma-exports/human-body-overlay-xcode-smoke/HumanBodyOverlaySmoke.xcassets and the vector PDFs in docs/figma-exports/human-body-overlay-xcode-smoke/pdf/: verify original rendering for base PDFs, SwiftUI template tint for overlay PDFs, and base/overlay alignment in a temporary preview target or scratch asset catalog only. Do not edit ios/STRQ, ios/STRQWidget, ios/STRQWatch, production Assets.xcassets, project files, Swift files, localization, tests, fonts, or production runtime assets. Document whether the vector PDF path is ready for a later production import.
```
