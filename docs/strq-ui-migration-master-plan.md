# STRQ UI Migration Master Plan

Last updated: 2026-04-30

## Purpose

This is the master control document for the STRQ frontend migration. It organizes the work needed to rebuild the STRQ visual and component foundation using the Purchased Figma UI Kit as an internal source reference while preserving STRQ product identity, runtime behavior, app logic, data, copy, training intelligence, and business contracts.

This pass is documentation only. It does not authorize production UI changes, asset imports, business logic changes, workout/training logic changes, navigation changes, localization changes, analytics changes, paywall changes, persistence changes, or workout behavior changes.

## Source And Ownership

| Area | Rule |
|---|---|
| Purchased Figma UI Kit | Internal visual/component source and provenance only |
| STRQ runtime code | STRQ-owned runtime naming, components, assets, copy, and product behavior |
| Source/provenance docs | Sandow/Figma may appear in docs, manifests, audits, and source maps |
| Runtime naming | Use STRQ-owned runtime naming such as `STRQColors`, `STRQTypography`, `STRQSpacing`, `STRQIcon`, `STRQButton`, `STRQCard`, and related STRQ names |
| Screen strategy | Use UI kit patterns as building blocks, not full-screen copies |

Related existing STRQ planning docs remain authoritative inputs:

- [STRQ Design System Roadmap](../ios/STRQ/Utilities/STRQDesignSystemRoadmap.md)
- [STRQ Design System Naming Plan](../ios/STRQ/Utilities/STRQDesignSystemNamingPlan.md)
- [STRQ Icon Coverage Plan](../ios/STRQ/Utilities/STRQIconCoveragePlan.md)
- [Sandow Import Manifest](../ios/STRQ/Utilities/SandowImportManifest.md)
- [Sandow Anatomy Import Plan](../ios/STRQ/Utilities/SandowAnatomyImportPlan.md)

## Project Control Docs

- [Docs README](README.md)
- [Project UI Audit](project-ui-audit.md)
- [Figma Source Map](figma-source-map.md)
- [Design System Import Plan](design-system-import-plan.md)
- [Asset Import Plan](asset-import-plan.md)
- [Component Migration Plan](component-migration-plan.md)
- [Protected Logic Map](protected-logic-map.md)
- [UI Direction Options](ui-direction-options.md)
- [Migration Progress Log](migration-progress-log.md)
- [QA Validation Plan](qa-validation-plan.md)

## Current Repository State

| Item | Current result |
|---|---|
| Working directory | `C:\Users\maxwa\Documents\GitHub\rork-strq` |
| Branch | `main` |
| Git availability | Available |
| `rg` availability | Available at `C:\Users\maxwa\AppData\Local\OpenAI\Codex\bin\rg.exe` |
| `rg` version | `ripgrep 15.1.0 (rev af60c2de9d)` |
| Initial working tree for docs QA pass | Clean at the start of the 2026-04-30 docs QA pass |
| Project-control docs in checkout | 10 tracked docs under `docs/`; `docs/README.md` added by the docs QA pass |
| Build status | Not run on Windows. `xcodebuild` is not expected here |

Historical note from the previous master-control documentation pass: the earlier pass recorded these docs as initially untracked:

- `docs/component-migration-plan.md`
- `docs/figma-source-map.md`
- `docs/project-ui-audit.md`
- `docs/protected-logic-map.md`

In the current docs QA checkout, those files are tracked and remain in the documentation scope.

## Architecture Summary

STRQ is a SwiftUI iOS app with watchOS, WidgetKit, unit test, and UI test targets. The main app entry point is `ios/STRQ/STRQApp.swift`; the top-level runtime shell is `ios/STRQ/ContentView.swift`; app state is composed in `ios/STRQ/ViewModels/AppViewModel.swift`.

The app currently has mature product logic across workout control, training plan generation, progression, persistence, HealthKit, notifications, RevenueCat, analytics, onboarding, widgets, watch connectivity, and localization. These systems are protected during UI migration.

Current production UI mostly uses:

- `STRQPalette`
- `STRQBrand`
- `ForgeTheme`
- `ForgeSurface`
- `ForgeCard`
- `STRQMetricTile`
- `STRQBadgeChip`
- local per-screen SwiftUI view structs
- heavy `Image(systemName:)` usage

An isolated future design-system layer exists in `ios/STRQ/Utilities/STRQDesignSystem.swift`, including STRQ-owned token and component names. It should remain isolated until a controlled implementation pass proves each primitive and applies it to a small production surface.

## Figma Source Result

Figma file:

- `SH-sandow-UI-Kit--v3.0-`
- File key: `LBvxljax0ixoTvbvvUeWVC`
- URL: `https://www.figma.com/design/LBvxljax0ixoTvbvvUeWVC/SH-sandow-UI-Kit--v3.0-?m=auto&t=Cm2KJRPJnU51BdTq-6`

Current pass result:

- Figma file access succeeded.
- Page inventory succeeded.
- Known node inspection succeeded after non-mutating Plugin API guard fixes.
- Local variable/style inventory succeeded.
- Shallow keyword and component-set discovery succeeded.
- A broad full-file keyword sweep timed out after 120 seconds and is recorded as pending.

Known accessible pages:

- `sandow UI Kit`
- `Main - Light Mode`
- `Main - Dark Mode`
- `Design System - General Components`
- `Design System - App Components`
- `Design System - Foundations`
- `Design System - Icon Set`
- `Bonus - Dashboard`
- `Bonus - Mobile Patterns`
- divider page
- `Thumbnail`

Figma design-system inventory found:

- 1,082 local variables: 608 color, 444 float, 30 string
- Variable collections: `Semantics` with Light/Dark modes, `Primitives` with Light mode
- 184 paint styles, 73 text styles, 25 effect styles, 3 grid styles
- General component sections for buttons, chips, badges, chat, charts, date picker, form controls, inputs, loaders, modals, progress, sliders, tabs, feedback, and more
- App component sections for app bar, bottom sheet, app-specific cards, general cards, list item, navigation, schedule, tab bar, toolbar, and more
- Screen groups covering welcome, onboarding/assessment, dashboard/home, coach, nutrition, workout library, activity, sleep, notifications/search, error/utility, profile/settings/help, achievements/leaderboard
- Asset areas for anatomy muscle, body type, organ anatomy, achievement badges, avatar illustrations, base illustrations, media, avatars, equipment imagery, and related components

## Design System Status

Current isolated STRQ design-system coverage includes:

- `STRQColors`
- `STRQGradients`
- `STRQTypography`
- `STRQSpacing`
- `STRQRadii`
- `STRQEffects`
- `STRQIcon`
- `STRQIconView`
- `STRQCard`
- `STRQButton`
- `STRQIconButton`
- `STRQChip`
- `STRQBadge`
- `STRQMetricCard`
- `STRQProgressBar`
- `STRQProgressRing`
- `STRQListItem`
- `STRQSearchField`
- `STRQInputField`
- `STRQToggleRow`
- `STRQModalSurface`
- `STRQBottomSheetSurface`
- `STRQNavigationBar`
- `STRQAvatar`
- `STRQRatingStars`
- `STRQEmptyStateCard`
- `STRQTabBarContainer`
- `STRQScheduleRow`
- `STRQScheduleCard`

The design-system layer is not yet the production UI foundation. Future work should first reconcile exact Figma variables/styles with STRQ token names, then apply primitives one controlled component or screen module at a time.

Work Sans status:

- `STRQFontRegistrar.registerBundledFonts()` is called from `STRQApp.init()`.
- No `.ttf`, `.otf`, `.woff`, or `.woff2` font files were found in the repo during this pass.
- Exact Work Sans fidelity remains pending until licensed font files are added and verified.

## Asset Status

Current asset state:

- 60 `STRQIcon*.imageset` folders exist.
- Body PNG assets exist for male/female front/back and premium male front/back.
- `STRQSigil.imageset` exists.
- No new assets were imported in this pass.

Future imports must be controlled by the [Asset Import Plan](asset-import-plan.md). Do not import the full source ZIP, demo photos, unused media, redundant state variants, social/payment/brand logos, coach/person photos, or large marketing mockups without explicit approval.

## Protected Logic Summary

The following areas are protected during UI migration:

- app composition and top-level routing
- active workout controller
- rest timer behavior
- Live Activity behavior
- watch workout behavior
- plan generation
- progression and adaptive prescription logic
- coach intelligence and coach actions
- persistence schema and sync
- exercise identity and exercise catalog
- analytics event keys and trigger timing
- RevenueCat configuration and product/entitlement behavior
- onboarding state transitions
- localization behavior
- notifications and deep links
- HealthKit reads/writes
- widget/app group behavior
- test and QA harnesses

See the [Protected Logic Map](protected-logic-map.md) for file-level guardrails.

## Migration Strategy

The migration should move from foundations to primitives to small screen modules. Avoid full-screen replacement until the foundation proves stable and the user approves a UI direction.

Recommended sequencing:

1. Validate tokens and naming.
2. Validate icon registry and current asset sync.
3. Stabilize low-risk primitives: buttons, chips, badges, list rows.
4. Stabilize surfaces/cards and progress/metric primitives.
5. Decide STRQ UI direction.
6. Apply one small module in a production screen.
7. Validate with search checks, build/simulator checks on macOS, screenshots, accessibility basics, and rollback readiness.

## Phases

| Phase | Name | Scope | Exit criteria |
|---:|---|---|---|
| 0 | Project control docs | Create master docs, audit maps, QA plan, progress log | All docs exist and are internally linked |
| 1 | Codebase audit | Confirm architecture, screens, components, assets, protected systems | [Project UI Audit](project-ui-audit.md) and [Protected Logic Map](protected-logic-map.md) stay current |
| 2 | Figma source map | Inspect pages, known nodes, adjacent groups, variables/styles, pending queues | [Figma Source Map](figma-source-map.md) has verified sources and pending items |
| 3 | Figma-to-code mapping | Map source nodes to STRQ-owned files/components/assets | Mapping table exists and uses STRQ names |
| 4 | Asset/icon foundation | Validate icon sync, choose controlled import batches, plan anatomy assets | No random assets; import only approved categories |
| 5 | Design tokens/theme | Align Figma variables/styles to STRQ tokens | Tokens documented and tested in isolated previews |
| 6 | Reusable component library | Build/verify primitives in isolation | Components stable before production usage |
| 7 | UI direction selection | Choose 1 product direction from documented options | User-approved direction before screen migration |
| 8 | Screen-by-screen migration | Migrate one contained module or screen at a time | No protected logic changes, behavior verified |
| 9 | QA / cleanup / polish | Build, simulator screenshots, accessibility, source searches, rollback | Checks pass and residual risks logged |

## Screen Migration Strategy

High-risk screens should wait:

- `ActiveWorkoutView`
- `DashboardView`
- onboarding flow
- `STRQPaywallView`
- watch/widget surfaces

Better first production candidates after primitives are stable:

- a contained Profile/settings row cluster
- an isolated Dashboard metric card
- Exercise Library card shell
- Progress metric card shell
- Workout Completion reward/badge area

Each screen migration must preserve actions, state reads, analytics, localization, navigation, and domain calculations.

## QA Strategy

QA is defined in the [QA Validation Plan](qa-validation-plan.md). At minimum every future implementation pass should include:

- `rg` checks for forbidden source/runtime references
- `rg` checks for protected logic files
- icon/asset sync checks
- localization key checks
- no Sandow runtime refs check
- no protected logic change check
- Windows limitation note if no build is run
- macOS/GitHub Actions build expectation
- simulator screenshot review for changed screens
- accessibility basics
- rollback plan

## Environment Limitations

- This pass ran on Windows.
- `xcodebuild` was not run and should not be claimed.
- Figma access is available, but broad full-file scans can time out.
- Figma inspection should continue with exact nodes, bounded page scans, and pending queues.

## Open Decisions

| Decision | Why it matters |
|---|---|
| Primary STRQ visual direction | Determines how heavily to use black/white/carbon, warm accent, semantic color, and premium contrast |
| Work Sans bundling | Needed for exact typography fidelity |
| First production migration surface | Controls risk and validation effort |
| Anatomy strategy | Determines whether to import masks, composites, or defer assets |
| Achievement scope | Decides whether badges are product features or only reward visuals |
| Paywall visual scope | Must preserve RevenueCat behavior exactly |
| Icon replacement policy | Avoids mass replacing SF Symbols without semantic review |

## Next Recommended Implementation Passes

1. Figma token parity pass: map Figma variables/styles to `STRQColors`, `STRQTypography`, `STRQSpacing`, `STRQRadii`, and `STRQEffects`; update docs/foundation only; do not modify production screens.
2. Component primitive QA pass: verify `STRQButton`, chips, badges, cards, rows, and progress primitives in the Design System Lab.
3. First production micro-migration pass: only after foundation QA; choose one low-risk area such as a Profile/settings row cluster or one Dashboard metric group, preserving all state and actions.

## Acceptance Status For This Pass

This pass is complete only as a control and planning pass. Implementation is not complete. No production UI migration is claimed.
