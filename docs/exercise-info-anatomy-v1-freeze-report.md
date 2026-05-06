# Exercise Info Anatomy V1 Freeze Report

Date: 2026-05-06

Mode: Licensed Source Mode

## 1. Executive summary

Exercise Info Anatomy V1 is accepted as a V1 product candidate for Exercise Detail. It is a display-only Human Body Overlay target visualization that helps users understand the primary and secondary muscle intent of an exercise without changing the app's training logic.

The feature is not the final full anatomy system. It is safe enough to keep in Exercise Detail pending macOS/CI build validation and continued Rork QA, with caveats around broad source regions such as Back/Lats, Abs/Core, and Hamstrings/RDL semantics.

This pass is a docs-only QA freeze. It does not change exercise data, models, services, analytics, localization, workout behavior, plan behavior, assets, Swift code, project files, widgets, watch targets, live activities, fonts, or runtime behavior.

## 2. Implementation summary

Exercise Detail now renders a local Human Body Overlay inside the Target card. The implementation composes a neutral licensed body base with vector PDF overlay assets in a shared fixed-aspect canvas. Primary overlays render with stronger emphasis; secondary overlays render with lower emphasis when the overlay is compatible with the primary orientation.

The primary and secondary text lists remain the source-of-truth and stay visible. The anatomy overlay is a visual aid, not the data source. If a muscle cannot be represented honestly, the text list still carries the exact exercise data while the overlay avoids pretending to have precision it does not have.

Support-only or stabilizer-style secondary terms are intentionally text-only. Terms such as Core Stability, bracing, grip, support, balance, stabilizer, and stabilizers do not render misleading overlays.

## 3. Licensed Figma source summary

The anatomy artwork comes from the licensed Figma Human Body source inspected in Licensed Source Mode. The relevant source family is the large Human Body vector group documented in `docs/figma-exports/human-body-overlay-v1-import/README.md`, with runtime assets derived as STRQ-owned vector PDF image sets.

The Figma source is treated as licensed provenance and asset source material, not as runtime naming, product copy, or product behavior. Runtime naming remains STRQ-owned. Hand, Neck, Body Type, Organ Anatomy, Equipment Image, Achievements, Illustration Base, selected/unselected duplicate states, and SVG runtime assets are intentionally out of scope for Exercise Info Anatomy V1.

## 4. Runtime asset summary

Exercise Detail currently uses the male body variant as the consistent default. The male body variant avoids switching art styles inside the same Exercise Detail surface and keeps V1 predictable while female variants and user body preference remain deferred.

Runtime coverage used by Exercise Detail includes:

- Male Front base: chest, shoulder, bicep, forearm, abs, upper leg/quads, and lower leg overlays.
- Male Back base: broad back/lats/lower back, trap, tricep, glute, hamstring, and calf overlays.

The imported runtime candidates are vector PDF assets. Base body assets render as neutral line art; overlays are tintable display layers. Recent visual tuning reduced large-region overlays slightly and strengthened the top line-art preservation pass so large highlights keep anatomical definition.

## 5. Exercise examples QA summary

Rork QA accepted the following Exercise Detail examples:

- Incline Dumbbell Press and Bench Press: Chest primary works.
- Landmine Row, Dumbbell Row, Pull-Up, and Pullover: Back/Lats primary works.
- Landmine Squat and Zercher Squat: Quads primary works after support-overlay filtering.
- Dumbbell Hip Thrust and Glute Kickback: Glutes/Hamstrings work.
- Cable Hammer Curl: Biceps works.
- Abs/Core examples work, with the caveat that core semantics are broad and should stay user-QA sensitive.

Rork QA also verified that secondary support terms such as Core Stability, bracing, grip, support, balance, and stabilizers remain text-only and no longer create misleading overlays.

## 6. Accepted behavior

Exercise Info Anatomy V1 is accepted with the following behavior:

- The overlay is display-only.
- Exercise data, models, services, analytics, localization, workout behavior, and plan behavior are unchanged.
- Text primary and secondary lists remain source-of-truth and visible.
- The anatomy overlay is a visual aid, not the data source.
- Primary overlays may choose the front or back body orientation based on the target muscle.
- Secondary overlays render only when compatible with the selected orientation and V1 asset coverage.
- Support and stabilizer terms are intentionally text-only and do not render overlays.
- Male body variant is currently the consistent default for Exercise Detail.
- Missing or unsupported visual coverage degrades honestly instead of faking precision.

## 7. Known caveats

Back/Lats is improved but still broad by nature of the current overlay asset. Further precision would require asset segmentation into lats, upper back, and lower back, not more opacity tuning.

Abs/Core examples work, but Abs/Core may need later semantic refinement only if user QA shows confusion. The same applies to Hamstrings/RDL if users read the overlay as too broad or incorrectly targeted.

Large-region overlays were reduced slightly and top line-art preservation was strengthened. Do not keep tuning opacity unless a specific regression appears.

The Target Card visual polish can be a later pass. It is not a release blocker for this V1 candidate as long as the current visual remains legible, stable, and non-misleading.

This Windows pass does not claim macOS/Xcode build validation or final asset-rendering validation.

## 8. Deferred work

Deferred from Exercise Info Anatomy V1:

- Female variants and user body preference.
- Neutral body variant.
- Onboarding integration.
- Progress integration.
- Coach integration.
- Exercise Library filter integration.
- Final anatomy color tokens.
- Back/Lats segmentation into lats, upper back, and lower back.
- Abs/Core semantic refinement, only if user QA shows confusion.
- Hamstrings/RDL semantic refinement, only if user QA shows confusion.
- Target Card visual polish.
- Broader full anatomy system architecture beyond the local Exercise Detail implementation.

## 9. Release-readiness classification

Release-readiness classification:

- V1 feature candidate: accepted with caveats.
- Not final full anatomy system.
- Safe enough to keep in Exercise Detail pending macOS/CI build validation and continued Rork QA.

The feature should be frozen as accepted V1 product work unless a specific regression appears. Future work should focus on validation, segmentation, or semantic refinement rather than repeated opacity tuning.

## 10. Regression guardrails

Protect these guardrails in future passes:

- Do not edit exercise data, models, services, analytics, localization, workout behavior, or plan behavior for anatomy polish.
- Do not hide or replace the primary and secondary text lists.
- Do not let the anatomy overlay become the data source.
- Do not render support, stabilizer, bracing, grip, balance, or support-only secondary concepts as anatomy overlays.
- Do not switch body variants inside Exercise Detail until user body preference is intentionally scoped.
- Do not introduce female variant switching, Onboarding, Progress, Coach, or Exercise Library behavior in a minor polish pass.
- Do not import additional anatomy assets without source provenance, asset naming, and Rork QA expectations.
- Do not keep tuning opacity unless a specific regression appears.
- Do not treat Back/Lats, Abs/Core, or Hamstrings/RDL as final precision anatomy.
- Do not change Target Card behavior while doing visual polish.

## 11. Rork QA checklist

Accepted Rork QA coverage:

- Chest primary: Incline Dumbbell Press, Bench Press.
- Back/Lats primary: Landmine Row, Dumbbell Row, Pull-Up, Pullover.
- Quads primary: Landmine Squat, Zercher Squat.
- Glutes/Hamstrings: Dumbbell Hip Thrust, Glute Kickback.
- Biceps primary: Cable Hammer Curl.
- Abs/Core examples: accepted with caveat.
- Support/stabilizer filtering: Core Stability, bracing, grip, support, balance, stabilizers remain text-only.

Rork QA still useful before release:

- Spot-check the accepted examples after any build, asset, or Exercise Detail layout change.
- Re-check Back/Lats only if a visual regression appears or if asset segmentation is introduced.
- Re-check Abs/Core and Hamstrings/RDL only if user QA shows confusion.
- Confirm no secondary support term creates a misleading overlay after future exercise-data changes.

## 12. Recommended next step

Freeze Exercise Info Anatomy V1 as accepted with caveats. The next step is macOS/CI build validation plus continued Rork QA during release validation. Do not reopen opacity tuning unless a specific regression appears; future anatomy precision should come from asset segmentation or semantic mapping refinement.
