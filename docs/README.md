# STRQ UI Migration Docs

Last updated: 2026-04-30

## Purpose

This folder is the project control layer for the STRQ frontend migration. It keeps Source/provenance docs, codebase audit notes, Figma source map findings, design-system planning, asset import rules, component migration sequencing, QA expectations, and the append-only progress log in one place.

These docs do not authorize production UI changes by themselves. They exist to keep future implementation passes small, traceable, and protective of STRQ app behavior.

## Current Migration Status

- The 10 project-control docs are present in `docs/`.
- This docs QA pass is documentation-only.
- No Swift files, runtime screens, app logic, localization catalogs, assets, fonts, or Figma exports were changed in this pass.
- The Purchased Figma UI Kit has been inspected enough to define Source/provenance docs and pending queues, but full Figma inspection is not complete.
- STRQ-owned runtime naming is required for all runtime code, assets, localization keys, analytics, and product identifiers.
- Work Sans fidelity is pending because font files are not present in the checkout.
- Anatomy, body type, organ anatomy, badge, equipment, illustration, avatar, and reward assets are not imported.

## Key Docs

- [STRQ UI Migration Master Plan](strq-ui-migration-master-plan.md)
- [Project UI Audit](project-ui-audit.md)
- [Figma Source Map](figma-source-map.md)
- [Design System Import Plan](design-system-import-plan.md)
- [Asset Import Plan](asset-import-plan.md)
- [Component Migration Plan](component-migration-plan.md)
- [Protected Logic Map](protected-logic-map.md)
- [UI Direction Options](ui-direction-options.md)
- [QA Validation Plan](qa-validation-plan.md)
- [Migration Progress Log](migration-progress-log.md)
- [Localization Guidelines](localization-guidelines.md)

Related Source/provenance docs in the iOS tree:

- [STRQ Design System Roadmap](../ios/STRQ/Utilities/STRQDesignSystemRoadmap.md)
- [STRQ Design System Naming Plan](../ios/STRQ/Utilities/STRQDesignSystemNamingPlan.md)
- [STRQ Icon Coverage Plan](../ios/STRQ/Utilities/STRQIconCoveragePlan.md)
- [Sandow Import Manifest](../ios/STRQ/Utilities/SandowImportManifest.md)
- [Sandow Anatomy Import Plan](../ios/STRQ/Utilities/SandowAnatomyImportPlan.md)

## Recommended Reading Order

1. [STRQ UI Migration Master Plan](strq-ui-migration-master-plan.md)
2. [Project UI Audit](project-ui-audit.md)
3. [Protected Logic Map](protected-logic-map.md)
4. [Figma Source Map](figma-source-map.md)
5. [Design System Import Plan](design-system-import-plan.md)
6. [Asset Import Plan](asset-import-plan.md)
7. [Component Migration Plan](component-migration-plan.md)
8. [UI Direction Options](ui-direction-options.md)
9. [QA Validation Plan](qa-validation-plan.md)
10. [Migration Progress Log](migration-progress-log.md)

## Current Next Step

Recommended next pass:

1. Figma token parity pass: map Figma variables/styles to `STRQColors`, `STRQTypography`, `STRQSpacing`, `STRQRadii`, and `STRQEffects`; update docs/foundation only; do not touch production screens.
2. Component primitive QA pass: verify `STRQButton`, chips, badges, cards, rows, and progress primitives in the Design System Lab.
3. First production micro-migration: only after foundation QA; choose one low-risk area such as a Profile/settings row cluster or one Dashboard metric group.

## Rules

- Protect STRQ app logic and all protected app logic named in the [Protected Logic Map](protected-logic-map.md).
- Use the Purchased Figma UI Kit as the visual source/foundation, not as runtime identity.
- Use STRQ-owned runtime naming everywhere outside Source/provenance docs.
- Do not blindly copy full screens from Figma.
- Do not dump random assets into `Assets.xcassets`.
- Do not start production screen migration until foundation tokens and primitives are ready.
- Do not imply Work Sans is active until font files and runtime registration are verified.
- Do not imply anatomy assets are imported until an approved asset import pass does that work.
- Keep Sandow/source terms in Source/provenance docs only.

## Coverage Index

- Project/codebase coverage lives in the [Project UI Audit](project-ui-audit.md): tech stack, app targets, navigation, view models, services, models, theme/design system, assets, icons, localization, debug tools, watch/widget, and tests.
- Protected logic coverage lives in the [Protected Logic Map](protected-logic-map.md): active workout, workout controller, rest timer, plan generation, progression, persistence, exercise identity/catalog, analytics, RevenueCat/product IDs, onboarding, notifications/deep links, HealthKit, widgets/watch, and localization.
- Figma coverage lives in the [Figma Source Map](figma-source-map.md): foundations, colors, gradients, typography, effects, size/spacing, icons, general components, app components, dark mode screens, anatomy/muscle/body assets, achievement/leaderboard, paywall, onboarding, profile/settings, progress/analytics, workout/exercise, nutrition/sleep/recovery, empty/loading/error states, and pending inspection queue.
- Asset coverage lives in the [Asset Import Plan](asset-import-plan.md): icons, anatomy, full-body vectors, body type, badges, equipment, illustrations, avatar, reward/confetti, organ anatomy, and excluded assets.
- Design-system coverage lives in the [Design System Import Plan](design-system-import-plan.md): STRQ-owned runtime naming, Work Sans pending status, colors, spacing, radii, effects, components, Design System Lab, and runtime versus source/provenance separation.
- QA coverage lives in the [QA Validation Plan](qa-validation-plan.md): `rg` checks, icon/asset sync, localization checks, no Sandow runtime refs, protected logic checks, Windows limitations, macOS/GitHub Actions expectations, simulator screenshot review, accessibility basics, and rollback strategy.

## Updating Docs In Future Passes

- Start by reading this README, the [Master Plan](strq-ui-migration-master-plan.md), the [Protected Logic Map](protected-logic-map.md), and the [QA Validation Plan](qa-validation-plan.md).
- Update the specific doc that owns the area being changed.
- Keep Source/provenance docs and runtime decisions separate.
- Mark unknowns as pending instead of implying completed work.
- Add relative markdown links when a pass creates or depends on another doc.
- Preserve append-only history in the [Migration Progress Log](migration-progress-log.md).
- For implementation passes, update docs after verification so the docs match the actual diff.

## Appending To The Progress Log

Append a new dated entry to [Migration Progress Log](migration-progress-log.md) before the template section.

Each entry should include:

- scope
- files changed
- Figma inspected, if any
- code inspected, if any
- verification run
- intentionally not changed
- pending work
- warnings or risks

Never remove prior log content. If a pass discovers that an older entry is stale, add a new correction note instead of rewriting history.
