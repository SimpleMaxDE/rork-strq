# STRQ Human Body Overlay V1 Import

Date: 2026-05-06

Mode: Licensed Source Mode

## Summary

This pass expands the Exercise Detail Human Body Overlay pilot from the narrow first import to a controlled V1 muscle coverage set. The production runtime import remains vector PDF only, with SwiftUI owning primary and secondary tint, opacity, and role hierarchy.

Exercise Detail now uses a consistent default male artwork variant. The primary muscle chooses the target orientation: front for chest, shoulders, biceps, forearms, abs/core, upper leg/quads, and lower leg/tibialis; back for back/lats/lower back, traps, triceps, glutes, hamstrings, and calves. Secondary muscles render only when they are available on that same orientation. The exact primary and secondary text list remains visible as the source of truth.

## Sources Used

- Primary Human Body source: `9192:5535`
- Male Front base group: `9192:5245`
- Male Back base group: `9192:5428`
- Existing pilot exports: `docs/figma-exports/human-body-overlay-pilot/`
- Existing vector-PDF smoke path: `docs/figma-exports/human-body-overlay-xcode-smoke/`
- Figma metadata was re-read for `9192:5535` in this pass to verify the missing V1 path groups.

No Hand, Neck, Body Type, Organ Anatomy, Equipment Image, Achievements, Illustration Base, selected/unselected duplicate states, or SVG runtime assets were imported.

## Assets Imported

New vector PDF image sets added to `ios/STRQ/Assets.xcassets`:

- `STRQHumanBodyMaleFrontAbsOverlay`
- `STRQHumanBodyMaleFrontBicepOverlay`
- `STRQHumanBodyMaleFrontForearmOverlay`
- `STRQHumanBodyMaleFrontLowerLegOverlay`
- `STRQHumanBodyMaleFrontUpperLegOverlay`
- `STRQHumanBodyMaleBackCalfOverlay`
- `STRQHumanBodyMaleBackGluteOverlay`
- `STRQHumanBodyMaleBackHamstringOverlay`
- `STRQHumanBodyMaleBackTrapOverlay`
- `STRQHumanBodyMaleBackTricepOverlay`

Existing pilot assets kept and used:

- `STRQHumanBodyMaleFrontBase`
- `STRQHumanBodyMaleFrontChestOverlay`
- `STRQHumanBodyMaleFrontShoulderOverlay`
- `STRQHumanBodyMaleBackBase`
- `STRQHumanBodyMaleBackBackOverlay`

## Assets Intentionally Not Imported

- Female V1 expansion overlays were not added in this pass. Existing female pilot assets remain in the catalog, but Exercise Detail does not use them because V1 is locked to a consistent male artwork variant.
- `STRQHumanBodyMaleBackShoulderOverlay` was available as a pilot SVG candidate but was not imported because Exercise Detail maps shoulders to the front orientation for V1.
- Hand and Neck were deferred by product direction.
- Anatomy Muscle `8673:69673` small-card assets were not imported because they do not share the full Human Body coordinate system.

## Exercise Detail Mapping

V1 maps STRQ muscle groups locally inside `ExerciseDetailView.swift`:

- Chest -> `MaleFrontChestOverlay`
- Shoulders -> `MaleFrontShoulderOverlay`
- Biceps -> `MaleFrontBicepOverlay`
- Forearms -> `MaleFrontForearmOverlay`
- Arms -> front bicep + forearm, or back tricep when the chosen orientation is back
- Abs, Obliques, Core Stability, Rotation -> `MaleFrontAbsOverlay`
- Quads, Adductors, Abductors, Hip Flexors -> `MaleFrontUpperLegOverlay`
- Tibialis -> `MaleFrontLowerLegOverlay`
- Back, Lats, Lower Back -> `MaleBackBackOverlay`
- Traps -> `MaleBackTrapOverlay`
- Triceps -> `MaleBackTricepOverlay`
- Glutes -> `MaleBackGluteOverlay`
- Hamstrings -> `MaleBackHamstringOverlay`
- Calves -> `MaleBackCalfOverlay`

Unsupported or non-compatible secondary muscles remain visible in the exact existing text list and are not visually faked.

## Caveats

- Several derived V1 overlays use path groups selected from the full Human Body base SVG and verified against Figma metadata. They need Rork visual QA for semantic accuracy, especially biceps, forearms, lower leg, triceps, calves, and traps.
- Back, Upper Leg, Hamstring, Trap, and Lower Leg are broad source-backed regions, not final precision anatomy.
- This pass ran on Windows. It does not claim Xcode, simulator, or final SwiftUI asset-rendering validation.
- macOS/CI build validation and Rork visual QA are still required before release.
