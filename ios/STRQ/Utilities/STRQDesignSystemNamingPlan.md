# STRQ Design System Naming Plan

Last prepared: 2026-04-29

## Scope

This is a naming and ownership cleanup plan only. No runtime screens, workout logic, progression logic, persistence, analytics, product IDs, exercise data, active workout, rest timer, onboarding, localization, UI behavior, source files, or asset image sets are renamed in this pass.

STRQ uses the purchased Sandow UI Kit as a design source, but production/runtime code should use STRQ-owned design-system names over time. Sandow provenance should remain in import, audit, attribution, and roadmap documentation rather than leaking through reusable production APIs.

Files read for this pass:

- `ios/STRQ/Utilities/SandowDesignSystem.swift`
- `ios/STRQ/Utilities/SandowImportManifest.md`
- `ios/STRQ/Utilities/SandowAnatomyImportPlan.md`
- `ios/STRQ/Utilities/SandowImportRoadmap.md` was checked and does not currently exist.
- `ios/STRQ/Assets.xcassets/SandowIcon*.imageset`

## Current Sandow Naming Audit

The requested Sandow identifiers are currently isolated to documentation, one foundation utility file, and Sandow-named icon assets. No requested Sandow identifiers were found in runtime production views, `ContentView.swift`, localization, or the iOS test targets.

| Area | Result |
|---|---|
| Documentation only | `ios/STRQ/Utilities/SandowImportManifest.md` and `ios/STRQ/Utilities/SandowAnatomyImportPlan.md` intentionally mention Sandow as source/import/audit documentation. This naming plan also intentionally mentions Sandow as an audit doc. |
| Isolated foundation file | `ios/STRQ/Utilities/SandowDesignSystem.swift` defines the current Sandow tokens, primitives, components, icon registry, and debug previews. |
| Assets | `ios/STRQ/Assets.xcassets/SandowIcon*.imageset` contains the current Sandow-named icon assets and matching `Contents.json` filename references. |
| Runtime production views | No matches found in `ios/STRQ/Views/**/*.swift` or `ios/STRQ/ContentView.swift` for the requested Sandow identifiers. |
| Tests/previews | No matches found in `ios/STRQTests` or `ios/STRQUITests`. The only preview usage is inside `#if DEBUG` preview structs in `SandowDesignSystem.swift`. |
| Localization/user-facing strings | No `Sandow` matches found in `ios/STRQ/Localizable.xcstrings` or `ios/STRQ/Localization`. |
| Analytics/product identifiers | No `Sandow` matches found outside the utility docs/foundation file and asset catalog, so there is no evidence of Sandow in analytics events or product identifiers. |

Requested identifier locations:

| Identifier | Current location |
|---|---|
| `SandowDesignSystem` | `SandowDesignSystem.swift`, `SandowImportManifest.md` |
| `SandowColors` | `SandowDesignSystem.swift`, `SandowImportManifest.md` |
| `SandowTypography` | `SandowDesignSystem.swift`, `SandowImportManifest.md` |
| `SandowSpacing` | `SandowDesignSystem.swift`, `SandowImportManifest.md` |
| `SandowRadii` | `SandowDesignSystem.swift`, `SandowImportManifest.md` |
| `SandowEffects` | `SandowDesignSystem.swift`, `SandowImportManifest.md` |
| `SandowGradients` | `SandowDesignSystem.swift`, `SandowImportManifest.md` |
| `SandowIcon` | `SandowDesignSystem.swift`, `SandowImportManifest.md`, `SandowIcon*.imageset/Contents.json` |
| `SandowIconView` | `SandowDesignSystem.swift`, `SandowImportManifest.md` |
| `SandowCard` | `SandowDesignSystem.swift`, `SandowImportManifest.md` |
| `SandowButton` | `SandowDesignSystem.swift`, `SandowImportManifest.md` |
| `SandowChip` | `SandowDesignSystem.swift`, `SandowImportManifest.md` |
| `SandowBadge` | `SandowDesignSystem.swift`, `SandowImportManifest.md` |
| `SandowMetricCard` | `SandowDesignSystem.swift`, `SandowImportManifest.md` |
| `SandowProgressBar` | `SandowDesignSystem.swift`, `SandowImportManifest.md` |
| `SandowProgressRing` | `SandowDesignSystem.swift`, `SandowImportManifest.md` |
| `SandowTabBar` | `SandowDesignSystem.swift`, `SandowImportManifest.md` |
| `SandowSchedule` | `SandowDesignSystem.swift`, `SandowImportManifest.md` |
| `SandowAnatomy` | `SandowAnatomyImportPlan.md`, `SandowImportManifest.md` |
| `SandowIcon*.imageset` | `ios/STRQ/Assets.xcassets` |

Current Sandow icon image sets:

- `SandowIconArrowRight.imageset`
- `SandowIconBarbell.imageset`
- `SandowIconBell.imageset`
- `SandowIconCalendar.imageset`
- `SandowIconCheck.imageset`
- `SandowIconCheckCircle.imageset`
- `SandowIconChevronRight.imageset`
- `SandowIconClock.imageset`
- `SandowIconCoach.imageset`
- `SandowIconHome.imageset`
- `SandowIconPlus.imageset`
- `SandowIconProfile.imageset`
- `SandowIconProgress.imageset`
- `SandowIconRecovery.imageset`
- `SandowIconSearch.imageset`
- `SandowIconSleep.imageset`
- `SandowIconStar.imageset`
- `SandowIconTarget.imageset`
- `SandowIconTrain.imageset`
- `SandowIconTrophy.imageset`
- `SandowIconWeightScale.imageset`

## STRQ Naming Standard

Runtime/UI code should use STRQ-owned naming for reusable foundations and production-facing component APIs.

Canonical direction:

- Use `STRQ` prefixes for reusable design-system tokens, icon registries, view primitives, and production component names.
- Keep vendor/source provenance in docs and manifest comments, not in names consumed by runtime screens.
- Prefer `STRQDesignSystem.swift` as the eventual source filename. `STRQFoundation.swift` is acceptable only if the team deliberately wants this file to own broader non-visual foundation primitives.
- Use `STRQIcon<Name>` as the asset prefix for imported reusable icons.
- Keep user-facing strings, analytics events, product identifiers, localization keys, and app-facing copy Sandow-free.

Recommended type and file mappings:

| Current name | STRQ-owned name |
|---|---|
| `SandowDesignSystem.swift` | `STRQDesignSystem.swift` |
| `SandowDesignSystem` | `STRQDesignSystem` |
| `SandowColors` | `STRQColors` |
| `SandowTypography` | `STRQTypography` |
| `SandowSpacing` | `STRQSpacing` |
| `SandowRadii` | `STRQRadii` |
| `SandowEffects` | `STRQEffects` |
| `SandowGradients` | `STRQGradients` |
| `SandowBorderToken` | `STRQBorderToken` |
| `SandowShadowToken` | `STRQShadowToken` |
| `SandowComponentStyle` | `STRQComponentStyle` |
| `SandowIcon` | `STRQIcon` |
| `SandowIconAsset` | `STRQIconAsset` |
| `SandowIconView` | `STRQIconView` |
| `SandowIconContainer` | `STRQIconContainer` |
| `SandowSurface` | `STRQSurface` |
| `SandowCard` | `STRQCard` |
| `SandowButton` | `STRQButton` |
| `SandowChip` | `STRQChip` |
| `SandowBadge` | `STRQBadge` |
| `SandowMetricCard` | `STRQMetricCard` |
| `SandowProgressBar` | `STRQProgressBar` |
| `SandowProgressRing` | `STRQProgressRing` |
| `SandowProgressRow` | `STRQProgressRow` |
| `SandowListItem` | `STRQListItem` |
| `SandowSectionHeader` | `STRQSectionHeader` |
| `SandowSectionAction` | `STRQSectionAction` |
| `SandowTabBarItem` | `STRQTabBarItem` |
| `SandowTabBarCenterAction` | `STRQTabBarCenterAction` |
| `SandowTabBar` | `STRQTabBar` |
| `SandowTabBarBackground` | `STRQTabBarBackground` |
| `sandowTabBarBackground()` | `strqTabBarBackground()` |
| `SandowScheduleRow` | `STRQScheduleRow` |
| `SandowScheduleCard` | `STRQScheduleCard` |
| `SandowFoundationPreview` | `STRQFoundationPreview` |
| `SandowComponentsPreview` | `STRQComponentsPreview` |
| `SandowAnatomy*` | `STRQAnatomy*` |

Recommended asset mappings:

| Current asset | STRQ-owned asset |
|---|---|
| `SandowIconArrowRight` | `STRQIconArrowRight` |
| `SandowIconBarbell` | `STRQIconBarbell` |
| `SandowIconBell` | `STRQIconBell` |
| `SandowIconCalendar` | `STRQIconCalendar` |
| `SandowIconCheck` | `STRQIconCheck` |
| `SandowIconCheckCircle` | `STRQIconCheckCircle` |
| `SandowIconChevronRight` | `STRQIconChevronRight` |
| `SandowIconClock` | `STRQIconClock` |
| `SandowIconCoach` | `STRQIconCoach` |
| `SandowIconHome` | `STRQIconHome` |
| `SandowIconPlus` | `STRQIconPlus` |
| `SandowIconProfile` | `STRQIconProfile` |
| `SandowIconProgress` | `STRQIconProgress` |
| `SandowIconRecovery` | `STRQIconRecovery` |
| `SandowIconSearch` | `STRQIconSearch` |
| `SandowIconSleep` | `STRQIconSleep` |
| `SandowIconStar` | `STRQIconStar` |
| `SandowIconTarget` | `STRQIconTarget` |
| `SandowIconTrain` | `STRQIconTrain` |
| `SandowIconTrophy` | `STRQIconTrophy` |
| `SandowIconWeightScale` | `STRQIconWeightScale` |

## What May Keep Sandow Naming

Sandow naming is allowed only in:

- Import manifests.
- Audit documents.
- Legal/source attribution documents.
- Internal roadmap documents.
- Comments explaining the purchased UI kit source, when needed for provenance.

Sandow naming should not appear in:

- Runtime view names.
- Reusable component names used by production screens.
- App-facing strings.
- Localization keys.
- Analytics events.
- Product identifiers.
- Public-facing names.

## Safe Staged Migration Plan

Do not execute this rename as part of this planning pass.

### Stage 1 - Add STRQ aliases

Add compile-safe aliases beside the current Sandow definitions so production code can start using STRQ-owned names without immediately moving or renaming the implementation.

Example aliases:

```swift
typealias STRQDesignSystem = SandowDesignSystem
typealias STRQColors = SandowColors
typealias STRQTypography = SandowTypography
typealias STRQSpacing = SandowSpacing
typealias STRQRadii = SandowRadii
typealias STRQEffects = SandowEffects
typealias STRQGradients = SandowGradients
typealias STRQIcon = SandowIcon
typealias STRQIconView = SandowIconView
typealias STRQCard = SandowCard
typealias STRQButton = SandowButton
typealias STRQChip = SandowChip
typealias STRQBadge = SandowBadge
typealias STRQMetricCard = SandowMetricCard
typealias STRQProgressBar = SandowProgressBar
typealias STRQProgressRing = SandowProgressRing
typealias STRQTabBar = SandowTabBar
typealias STRQScheduleRow = SandowScheduleRow
typealias STRQScheduleCard = SandowScheduleCard
```

For generic component aliases, use explicit generic typealiases:

```swift
typealias STRQSurface<Content: View> = SandowSurface<Content>
typealias STRQCard<Content: View> = SandowCard<Content>
typealias STRQTabBar<Content: View> = SandowTabBar<Content>
```

Stage 1 validation:

- Build the app.
- Confirm no production screen behavior changes.
- Confirm no asset catalog changes.
- Start new design-system usages with STRQ aliases only.

### Stage 2 - Rename source file and type names

In one controlled compile pass, rename the foundation source file and types from Sandow to STRQ.

Actions:

- Rename `SandowDesignSystem.swift` to `STRQDesignSystem.swift`.
- Rename token/component declarations from `Sandow*` to `STRQ*`.
- Update references inside the foundation file first.
- Update any production references that adopted Stage 1 aliases.
- Keep temporary backwards-compatible `Sandow*` aliases only if needed to keep the compile green during the pass.

Guardrails:

- Do not change component layout, colors, typography values, animation, logic, or behavior in this pass.
- Do not touch workout, progression, persistence, analytics, products, exercise data, active workout, rest timer, onboarding, localization, or runtime behavior.

### Stage 3 - Rename icon assets

Rename asset image sets from `SandowIcon*` to `STRQIcon*` and update enum/raw-value mappings.

Actions:

- Rename each `SandowIcon*.imageset` folder to the matching `STRQIcon*.imageset`.
- Rename image/PDF/SVG filenames inside each image set if needed.
- Update each `Contents.json` filename reference.
- Update `STRQDesignSystem.iconAssetPrefix` to `STRQIcon`.
- Update `STRQIcon` raw values to the new asset names.

Guardrails:

- Keep the visual asset data identical.
- Do not import new icons in the same pass.
- Do not alter tinting, template rendering, or vector-preservation settings except where required by the rename.

### Stage 4 - Remove old Sandow aliases

After all runtime and utility references have moved to STRQ names, remove compatibility aliases.

Actions:

- Search for `Sandow` in runtime code and utilities.
- Remove `typealias Sandow* = STRQ*` compatibility aliases only after no code requires them.
- Keep Sandow references in approved docs only.

### Stage 5 - Keep only source/reference docs

Final cleanup should leave Sandow naming only in source provenance, legal, manifest, audit, and roadmap documentation.

Expected final state:

- Runtime code uses STRQ-owned names.
- Sandow appears only in import/audit/source documentation.
- No user-facing strings mention Sandow.
- App behavior remains unchanged.

## Future Validation Searches

Run these searches after each migration stage. `rg` is preferred when available.

```bash
rg -n "Sandow" ios/STRQ/Views ios/STRQ/ContentView.swift
```

Expected result after the rename: no matches.

```bash
rg -n "Sandow" ios/STRQ/Utilities \
  -g "!SandowImportManifest.md" \
  -g "!SandowAnatomyImportPlan.md" \
  -g "!STRQDesignSystemNamingPlan.md"
```

Expected result after the rename: no matches, unless a new approved attribution/roadmap doc is included in the search scope.

```bash
rg -n "Sandow" ios/STRQ/Assets.xcassets
```

Expected result after asset rename: no matches.

```bash
rg -n "STRQDesignSystem|STRQIconView|STRQCard|STRQButton" ios/STRQ
```

Expected result after the rename: STRQ-owned names appear in the foundation file and any migrated runtime code.

Additional checks:

```bash
rg -n "Sandow" ios/STRQ/Localizable.xcstrings ios/STRQ/Localization
rg -n "Sandow" ios/STRQTests ios/STRQUITests
rg -n "SandowIcon[A-Za-z0-9_-]*\\.imageset" ios/STRQ/Assets.xcassets
```

Expected result after the rename: no matches.

If `rg` is unavailable, use PowerShell fallback searches:

```powershell
Select-String -Path "ios/STRQ/Views/**/*.swift","ios/STRQ/ContentView.swift" -Pattern "Sandow" -SimpleMatch
Get-ChildItem -LiteralPath "ios/STRQ/Assets.xcassets" -Recurse -File | Select-String -Pattern "Sandow" -SimpleMatch
```

## Deliverable Summary

Files changed in this pass:

- `ios/STRQ/Utilities/STRQDesignSystemNamingPlan.md`

No runtime code, source filenames, asset image sets, localization, tests, analytics, product IDs, or app behavior were changed.
