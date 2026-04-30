# STRQ Design System Import Plan

Last updated: 2026-04-30

## Purpose

This plan maps the Purchased Figma UI Kit foundations and reusable components into a STRQ-owned runtime design system. It is an import and implementation plan only. It does not authorize production screen migration.

Related control docs:

- [Docs README](README.md)
- [STRQ UI Migration Master Plan](strq-ui-migration-master-plan.md)
- [Figma Source Map](figma-source-map.md)
- [Asset Import Plan](asset-import-plan.md)
- [Component Migration Plan](component-migration-plan.md)
- [QA Validation Plan](qa-validation-plan.md)
- [STRQ Design System Roadmap](../ios/STRQ/Utilities/STRQDesignSystemRoadmap.md)
- [STRQ Design System Naming Plan](../ios/STRQ/Utilities/STRQDesignSystemNamingPlan.md)
- [STRQ Icon Coverage Plan](../ios/STRQ/Utilities/STRQIconCoveragePlan.md)

## Ownership Rules

| Rule | Direction |
|---|---|
| Source/provenance docs | May mention source file names, Figma, Sandow, and inspection details in docs, manifests, source maps, and planning files |
| Runtime APIs | Must use STRQ-owned runtime naming |
| Screen code | Must not depend on Sandow names |
| Visual direction | Must remain ownable to STRQ |
| Product logic | Must stay unchanged |

Future runtime names should include:

- `STRQColors`
- `STRQTypography`
- `STRQSpacing`
- `STRQRadii`
- `STRQEffects`
- `STRQGradients`
- `STRQIcon`
- `STRQIconView`
- `STRQButton`
- `STRQIconButton`
- `STRQCard`
- `STRQMetricCard`
- `STRQProgressBar`
- `STRQScheduleRow`
- `STRQAnatomyView`

## Figma Foundation Inventory

Current pass verified:

| Figma source | Node ID | Status |
|---|---:|---|
| Foundations page | `5358:6096` | Accessible |
| Colors | `5359:9002` | Accessible |
| Gradients | `5442:13546` | Accessible |
| Typography | `9119:6481` | Accessible |
| Logo | `9120:37139` | Accessible, provenance only |
| Effects | `9120:58753` | Accessible |
| Grid | `9122:4683` | Accessible |
| Size & Spacing | `9122:6944` | Accessible |
| Media | `9125:50816` | Accessible |
| Illustration | `9125:148813` | Accessible |

Figma variable/style inventory:

| Item | Count / detail |
|---|---|
| Local variables | 1,082 |
| Color variables | 608 |
| Float variables | 444 |
| String variables | 30 |
| Variable collections | `Semantics`, `Primitives` |
| Semantic modes | `Light`, `Dark` |
| Primitive modes | `Light` |
| Paint styles | 184 |
| Text styles | 73 |
| Effect styles | 25 |
| Grid styles | 3 |

Important style examples:

- Text styles include `Display lg/Medium`, `Display lg/SemiBold`, `Display lg/Bold`, heading styles, text styles, paragraph styles, and label styles.
- Effect styles include focus rings, shadows from `xs` through `2xl`, and background/layer blur levels.
- Grid styles include `Desktop Grid`, `Tablet Grid`, and `Mobile Grid`.

## Current STRQ Coverage

Existing isolated runtime foundation:

| STRQ area | Current state |
|---|---|
| Colors | `STRQColors` exists, partial parity with Figma |
| Gradients | `STRQGradients` exists, partial |
| Typography | `STRQTypography` exists, Work Sans source noted |
| Spacing | `STRQSpacing` exists, partial |
| Radii | `STRQRadii` exists |
| Effects | `STRQEffects` exists, partial |
| Icons | `STRQIcon` and `STRQIconView` exist |
| Components | Many isolated primitives exist |
| Design System Lab | DEBUG-only preview exists in Profile route |

## Runtime Versus Source Provenance

Source/provenance docs may describe the Purchased Figma UI Kit, source node names, and historical Sandow source labels. Runtime Swift symbols, asset names, localization keys, analytics events, product identifiers, and user-facing strings must use STRQ-owned runtime naming.

The Design System Lab is the only current place to verify future STRQ primitives before production adoption. It is not proof that production screens have migrated.

Current production screens mostly still use `STRQPalette`, `STRQBrand`, Forge components, local SwiftUI structs, and SF Symbols. This is expected until controlled migration starts.

## Missing Foundation Work

| Area | Missing work |
|---|---|
| Colors | Exact variable mapping from Figma `Semantics` and `Primitives` to STRQ semantic tokens |
| Dark mode | Confirm STRQ dark surfaces against Figma dark mode without copying full screens |
| Typography | Add licensed Work Sans font files and verify PostScript names, or formally approve system fallback |
| Spacing/grid | Map exact mobile grid, margins, gaps, row heights, and component dimensions |
| Radii | Confirm card, button, chip, tab, modal, sheet, and input radius policy |
| Effects | Map focus rings, shadows, blur, selected strokes, and disabled/pressed states |
| Components | Confirm variant coverage before production adoption |
| Accessibility | Contrast checks for semantic text, backgrounds, borders, disabled states, and accent tones |

## Color Strategy

STRQ should use semantic tokens in production:

- background
- surface
- surface elevated
- surface inset
- surface selected
- text primary
- text secondary
- text muted
- border
- border selected
- accent
- success
- warning
- danger
- info

Primitive Figma scales may remain implementation details. Production screens should not reach into vendor-style primitive names directly.

Recommended next color pass:

1. Export or inspect variable names and values for `Semantics` and `Primitives`.
2. Map each Figma semantic role to a STRQ role.
3. Decide whether warm/orange is the primary STRQ action color or only a supporting accent.
4. Validate contrast for dark mode first.
5. Keep `STRQPalette` untouched until a dedicated migration pass.

## Typography Strategy

Figma Typography uses Work Sans. STRQ currently has runtime registration logic but no font binaries in this checkout.

Current state:

- `STRQFontRegistrar.registerBundledFonts()` runs in `STRQApp.init()`.
- `STRQTypography` probes likely Work Sans names and falls back to system fonts.
- `rg --files -g "*.ttf" -g "*.otf" -g "*.woff" -g "*.woff2"` found no font files.
- The app target uses generated Info.plist settings; no `UIAppFonts` entry is present.

Recommended next typography pass:

1. Add licensed Work Sans `.ttf` or `.otf` files only if the user provides/approves them.
2. Keep font files under `ios/STRQ/Resources/Fonts/` or another app-bundled location.
3. Verify registration on macOS/simulator.
4. Update the DEBUG design-system lab with actual registered names.
5. Do not change production screen font usage until tokens are approved.

## Spacing And Grid Strategy

Use Figma `Size & Spacing` and `Grid` as the source for:

- screen margins
- section gaps
- card padding
- row padding
- chip padding
- input height
- button height
- icon container sizes
- tab bar height
- navigation height
- sheet/modal padding
- chart/card minimum dimensions

Runtime should expose semantic spacing through `STRQSpacing`, with primitive values available internally.

## Radii Strategy

Cards should remain restrained and app-like. Use 8px or less where practical unless an existing STRQ or Figma primitive explicitly needs more. Reserve large radii for pills, avatars, progress rings, and touch surfaces where the pattern requires it.

Runtime roles:

- `STRQRadii.sm`
- `STRQRadii.md`
- `STRQRadii.lg`
- `STRQRadii.card`
- `STRQRadii.button`
- `STRQRadii.chip`
- `STRQRadii.sheet`
- `STRQRadii.full`

## Effects Strategy

Use effects for hierarchy and state, not decoration.

Allowed effect categories:

- subtle card shadows
- hairline borders
- selected/focus rings
- sheet/modal blur only where useful
- reward glow for milestone moments

Avoid:

- decorative background blobs
- screen-wide gradients as default app chrome
- heavy shadows in dense training workflows
- importing separate image assets for state changes that SwiftUI can style

## Icon System Strategy

Current STRQ icon state:

- 60 `STRQIcon*.imageset` assets
- `STRQIcon` enum exists
- `STRQIconView` exists
- Assets are documented in the [STRQ Icon Coverage Plan](../ios/STRQ/Utilities/STRQIconCoveragePlan.md)

Import rules:

- One template vector asset per icon concept.
- Prefer SVG or vector PDF.
- Use SwiftUI tint for selected, disabled, warning, success, destructive, and premium states.
- Do not import every Figma icon style or state.
- Do not import social/payment/brand icons unless a STRQ feature needs them.
- Do not mass replace SF Symbols without semantic review.

## Component Primitive Strategy

Build STRQ-owned primitives in this order:

| Order | Primitive group | Figma sources | STRQ target |
|---:|---|---|---|
| 1 | Buttons/icon buttons | Button `9128:103928` | `STRQButton`, `STRQIconButton` |
| 2 | Chips/badges | Badge & Chip `9126:59240` | `STRQChip`, `STRQBadge` |
| 3 | List/settings rows | List Item `9134:89206` | `STRQListItem`, `STRQSettingsRow` |
| 4 | Cards/surfaces | Card General `9131:326493`, Card App Specific `9160:324200` | `STRQCard`, `STRQSurface` |
| 5 | Progress/metrics | Progress `9129:207997`, Chart `9129:26029` | `STRQProgressBar`, `STRQMetricCard`, `STRQChartCard` |
| 6 | Inputs/search/form | Input `9129:190574`, Form Control `9129:175150` | `STRQInputField`, `STRQSearchField`, `STRQToggleRow` |
| 7 | Navigation/tabs | App Bar, Navigation, Tab, Tab Bar | `STRQNavigationBar`, `STRQTabBar` |
| 8 | Sheets/modals | Bottom Sheet, Modal, Side Sheet | `STRQBottomSheet`, `STRQModal` |
| 9 | Fitness app cards | Workout Card, Coach Card, Health Metric Card, Nutrition Card | STRQ-specific card wrappers |
| 10 | Anatomy/reward | Anatomy Muscle, Achievement Badge | `STRQAnatomyView`, `STRQAchievementBadge` |

Each primitive must be verified in isolation before production screens use it.

## Naming Rules

| Purchased Figma UI Kit source concept | STRQ runtime name |
|---|---|
| Colors | `STRQColors` |
| Typography | `STRQTypography` |
| Spacing | `STRQSpacing` |
| Effects | `STRQEffects` |
| Icon | `STRQIcon` |
| Button | `STRQButton` |
| Card | `STRQCard` |
| Schedule | `STRQScheduleRow` / `STRQScheduleCard` |
| Anatomy Muscle | `STRQAnatomyView` / `STRQMuscleFocusCard` |
| Pricing Card | `STRQPaywallPlanCard` |

Avoid source-kit names in runtime symbols, localization keys, analytics events, product IDs, and user-facing strings.

## Figma-To-Code Mapping

| Figma source | Node ID | Type | STRQ target file/folder | Import format | Status | Priority | Notes |
|---|---:|---|---|---|---|---|---|
| Colors | `5359:9002` | foundation | `ios/STRQ/Utilities/STRQDesignSystem.swift` future `STRQColors` | Swift tokens | Partial | High | Exact variable values pending |
| Typography | `9119:6481` | foundation | `STRQTypography`, `STRQFontRegistrar` | Swift tokens plus fonts later | Partial | High | Work Sans files missing |
| Size & Spacing | `9122:6944` | foundation | `STRQSpacing`, `STRQRadii` | Swift tokens | Partial | High | Exact spacing pass pending |
| Effects | `9120:58753` | foundation | `STRQEffects` | Swift tokens | Partial | High | Effect style mapping pending |
| Icon Set | `5454:22014` | icon | `Assets.xcassets/STRQIcon*.imageset`, `STRQIcon` | SVG/PDF template vector | Partial | High | 60 current assets exist |
| Button | `9128:103928` | component | `STRQButton`, `STRQIconButton` | SwiftUI | Partial | High | Isolated primitive exists |
| Badge & Chip | `9126:59240` | component | `STRQBadge`, `STRQChip` | SwiftUI | Partial | High | Good early primitive |
| Progress | `9129:207997` | component | `STRQProgressBar`, `STRQProgressRing` | SwiftUI | Partial | High | Needed across dashboard/progress |
| Chart | `9129:26029` | component | `STRQChartCard` | SwiftUI/Charts | Missing | High | Requires chart data contract pass |
| Input/Form Control | `9129:190574`, `9129:175150` | component | `STRQInputField`, `STRQSearchField`, `STRQToggleRow` | SwiftUI | Partial | High | Needed for onboarding/settings/library |
| List Item | `9134:89206` | component | `STRQListItem`, `STRQSettingsRow` | SwiftUI | Partial | High | Good first screen primitive |
| Schedule | `9132:170645` | component | `STRQScheduleRow`, `STRQScheduleCard` | SwiftUI | Partial | High | Useful for Train/Dashboard |
| Card General | `9131:326493` | component | `STRQCard`, `STRQSurface` | SwiftUI | Partial | High | Avoid nested cards |
| Card App Specific | `9160:324200` | component | `STRQWorkoutCard`, `STRQCoachCard`, `STRQMetricCard`, `STRQNutritionCard` | SwiftUI | Missing/partial | High | Break into STRQ-specific wrappers |
| Bottom Sheet | `9131:299492` | component | `STRQBottomSheet` | SwiftUI | Partial | Medium | Preserve sheet behavior |
| Modal | `9129:50010` | component | `STRQModal` | SwiftUI | Partial | Medium | Good confirmation shell |
| Tab Bar | `9131:291579` | component | `STRQTabBar` | SwiftUI | Partial | High | Production routing protected |
| Home dark pattern | `11604:62728` | screen pattern | Future Dashboard modules | Reference only | Pending | High | Do not copy full screen |
| Pricing Card | `8751:102794` | component | `STRQPaywallPlanCard` | SwiftUI | Missing | Medium | Preserve RevenueCat |
| Anatomy Muscle | `8673:69673` | asset/component | `STRQAnatomy*` | SVG/PDF masks or composites | Pending | High | Prefer masks/state styling |
| Achievement Badge | `9064:106798`, `9063:203904` | asset/component | `STRQAchievementBadge` | SVG/PDF or SwiftUI | Pending | Medium | Tie to real milestones |
| Fitness Equipment Image | `11536:90366` | media | Future equipment assets if approved | PNG/WebP/PDF | Pending | Medium | Licensing/export QA required |

## Production Adoption Guardrail

No production view should import or depend on a new STRQ primitive until:

1. Token mapping is documented.
2. The primitive is verified in the DEBUG lab or isolated preview.
3. The target screen is approved.
4. Protected logic checks are run before and after.
5. Localization and analytics are preserved.
