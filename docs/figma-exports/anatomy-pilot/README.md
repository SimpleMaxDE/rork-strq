# STRQ Licensed Anatomy Muscle Export QA Pilot

## Scope

This folder contains an export-only QA pilot for the licensed Figma Anatomy Muscle component set.

- Figma source: Anatomy Muscle `8673:69673`
- Context inspected only: Large anatomy vector groups `9192:5535`
- Exported subset: Chest, Back, Abs, Glute
- Variants: Male, Female, Selected, Unselected
- Output: 16 SVG files plus `export-manifest.json` and `anatomy-pilot-contact-sheet.png`
- App/runtime status: no Swift, asset catalog, project file, localization, test, font, or production runtime asset changes

## Why These Assets

The STRQ Licensed Figma Icon & Anatomy Adoption Map recommends the Anatomy Muscle subset as the first pilot because muscle visuals can make Exercise Library, Exercise Detail, onboarding muscle focus, progress muscle coverage, and training education feel like a serious strength product instead of generic card stacks or SF Symbols.

This pilot is intentionally narrow: Chest, Back, Abs, and Glute give a useful front/back and upper/core/lower spread without exporting the full licensed anatomy set.

## Exported Assets

| STRQ file | Figma node | Source label |
| --- | --- | --- |
| `STRQAnatomyMaleChestSelected.svg` | `9024:101237` | Body Area=Chest, Is Selected=true, Gender=Male |
| `STRQAnatomyMaleChestUnselected.svg` | `9024:97738` | Body Area=Chest, Is Selected=false, Gender=Male |
| `STRQAnatomyFemaleChestSelected.svg` | `9025:100270` | Body Area=Chest, Is Selected=true, Gender=Female |
| `STRQAnatomyFemaleChestUnselected.svg` | `9024:102739` | Body Area=Chest, Is Selected=false, Gender=Female |
| `STRQAnatomyMaleBackSelected.svg` | `9024:101868` | Body Area=Back, Is Selected=true, Gender=Male |
| `STRQAnatomyMaleBackUnselected.svg` | `9024:99348` | Body Area=Back, Is Selected=false, Gender=Male |
| `STRQAnatomyFemaleBackSelected.svg` | `9025:100900` | Body Area=Back, Is Selected=true, Gender=Female |
| `STRQAnatomyFemaleBackUnselected.svg` | `9025:98731` | Body Area=Back, Is Selected=false, Gender=Female |
| `STRQAnatomyMaleAbsSelected.svg` | `9024:101162` | Body Area=Abs, Is Selected=true, Gender=Male |
| `STRQAnatomyMaleAbsUnselected.svg` | `9023:268361` | Body Area=Abs, Is Selected=false, Gender=Male |
| `STRQAnatomyFemaleAbsSelected.svg` | `9025:100122` | Body Area=Abs, Is Selected=true, Gender=Female |
| `STRQAnatomyFemaleAbsUnselected.svg` | `9024:102664` | Body Area=Abs, Is Selected=false, Gender=Female |
| `STRQAnatomyMaleGluteSelected.svg` | `9024:101740` | Body Area=Glute, Is Selected=true, Gender=Male |
| `STRQAnatomyMaleGluteUnselected.svg` | `9024:99220` | Body Area=Glute, Is Selected=false, Gender=Male |
| `STRQAnatomyFemaleGluteSelected.svg` | `9025:100770` | Body Area=Glute, Is Selected=true, Gender=Female |
| `STRQAnatomyFemaleGluteUnselected.svg` | `9025:98471` | Body Area=Glute, Is Selected=false, Gender=Female |

## QA Findings

- Vector: yes. All exports are SVG and contain no raster `<image>` elements.
- Dimensions: consistent. Every export has `width="88"`, `height="128"`, and `viewBox="0 0 88 128"`.
- Naming: clear. Files use STRQ-owned names rather than Figma source names.
- Selected vs Unselected: clear. Selected variants use the source warm orange/cream muscle emphasis; Unselected variants use gray/white styling.
- Male vs Female: clear. Anatomy silhouettes and muscle geometry differ across Male and Female variants.
- Fitness tone: suitable. The visuals read as training/fitness education rather than clinical organ diagrams.
- Dark carbon preview: usable for QA. The contact sheet shows the assets remain legible on a STRQ-style dark background.
- Transparency: not suitable as-is. Each raw SVG includes a rounded 88x128 component background rect and border, so the exports do not have transparent backgrounds.
- Clipping/artifacts: no obvious missing shapes or broken fills in the pilot contact sheet; internal anatomy content is clipped by the intended rounded component frame.
- App import: suitable as licensed vector source/provenance exports, but not suitable for direct asset catalog import until background-free and STRQ-tokenized variants are prepared.

## How To Evaluate

Review `anatomy-pilot-contact-sheet.png` first for quick visual comparison on dark carbon. Then open individual SVGs to inspect selected/unselected contrast, Male/Female geometry, and whether the rounded source background should be preserved, stripped, or converted into STRQ UI chrome.

For import readiness, evaluate whether the final app should use complete colored SVGs, transparent muscle masks, or a single neutral anatomy base with SwiftUI state coloring. The current exports should be treated as source QA evidence, not runtime-ready assets.

## Known Uncertainties

- Variant labels for Chest, Back, Abs, Glute, Selected, Unselected, Male, and Female were clear in the Anatomy Muscle component set.
- The large anatomy vector groups under `9192:5535` were useful only for context; their child groups were unlabeled and were not exported.
- The main uncertainty is import shape: raw component SVGs include background and border, so the best production path is likely background-free anatomy masks or STRQ-tokenized SVGs rather than direct import.

## Next Recommended Import Path

Run a follow-up normalization pass in the QA folder only:

1. Derive transparent, background-free anatomy/muscle candidates from these 16 licensed SVG exports.
2. Decide whether STRQ should import per-state SVGs or use neutral masks with SwiftUI state coloring.
3. Re-run contact sheet QA on dark carbon and light surfaces.
4. After approval, import the smallest normalized subset into the app asset catalog with STRQ-owned names.

Recommended next prompt:

```text
Use Licensed Source Mode. Normalize the docs/figma-exports/anatomy-pilot SVGs into transparent background-free QA candidates only, preserving provenance in export-manifest.json, and do not edit Swift, asset catalogs, project files, or production runtime assets.
```
