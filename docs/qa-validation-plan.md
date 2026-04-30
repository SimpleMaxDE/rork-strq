# STRQ UI Migration QA Validation Plan

Last updated: 2026-04-30

## Purpose

This plan defines validation checks for future STRQ UI migration passes. It protects runtime behavior while allowing the frontend foundation to improve in controlled steps.

This current pass did not run an iOS build because it ran on Windows. Do not claim a build unless one is actually run on macOS or CI.

## QA Principles

- Validate source references before implementation.
- Keep production behavior unchanged unless explicitly approved.
- Use `rg` for fast source checks.
- Treat all protected logic as off-limits unless approved.
- Verify icons/assets are named, synced, vector-safe, and not randomly imported.
- Use screenshots for any visual production change.
- Keep rollback simple by scoping changes narrowly.

## Source Search Checks

Run after every UI implementation pass:

```bash
rg -n "Sandow" ios/STRQ/Views ios/STRQ/ContentView.swift
rg -n -g "*.swift" "Sandow" ios/STRQ/Utilities
rg -n "STRQDesignSystem|STRQColors|STRQTypography|STRQIcon|STRQIconView" ios/STRQ
rg -n "Image\\(systemName:" ios/STRQ/Views ios/STRQ/ContentView.swift
rg -n "exercise\\.singular|set\\.plural|Start Session|Per Session" ios/STRQ
rg -n "resetAllData|generatePlan|activeWorkout" ios/STRQ
rg -n "RevenueCat|product|analytics|Analytics" ios/STRQ
rg -n "WorkSans|Work Sans|STRQFontRegistrar|UIAppFonts" ios/STRQ ios/STRQ.xcodeproj
rg -n "STRQIcon[A-Za-z]+\\.imageset" ios/STRQ/Assets.xcassets
```

Expected:

- no Sandow refs in production views
- Sandow refs in utilities only where intentionally documented
- STRQ design-system names appear only where expected
- SF Symbol usage is inventoried and not mass-replaced casually
- no raw localization keys are introduced
- protected logic references are reviewed if touched
- RevenueCat and analytics references are not changed by visual work
- Work Sans status is explicit
- icon assets remain synced with the enum

## Icon And Asset Validation

After any icon import:

- every `STRQIcon<Name>.imageset` has a valid `Contents.json`
- every `Contents.json` references an existing file
- vector preservation is enabled where applicable
- template rendering intent is enabled for tintable icons
- `STRQIcon` enum has matching cases
- no `SandowIcon*` runtime asset names remain
- no duplicate selected/disabled/hover state assets are imported without approval

After any anatomy or illustration import:

- verify transparent background
- verify dark and light surfaces
- verify scale on 1x, 2x, and 3x
- verify alignment against component frame
- verify selected/unselected state is SwiftUI-driven when possible
- verify file size
- update `docs/asset-import-plan.md` and manifest docs

## Localization Checks

UI migration should preserve existing localization behavior.

Checks:

```bash
rg -n "Text\\(\"[a-zA-Z0-9_.-]+\"\\)" ios/STRQ/Views ios/STRQ/ContentView.swift
rg -n "exercise\\.singular|set\\.plural|Start Session|Per Session" ios/STRQ
rg -n "L10n\\.tr|L10n\\.format|L10n\\.countLabel" ios/STRQ/Views ios/STRQ/ContentView.swift
```

Do not change `Localizable.xcstrings` unless copy/localization work is explicitly scoped.

## No Sandow Runtime References

Allowed:

- docs
- manifests
- source maps
- planning files

Not allowed:

- production views
- runtime components consumed by production views
- analytics events
- product identifiers
- localization keys
- asset names
- user-facing strings

## Production Screen Isolation Checks

For planning/docs-only passes:

```bash
git diff -- ios/STRQ/Views ios/STRQ/ContentView.swift ios/STRQ/ViewModels ios/STRQ/Services ios/STRQ/Models
```

Expected:

- no runtime code diff

For future implementation passes:

- confirm the exact screen/module scope before editing
- verify no unrelated screens changed
- verify no protected action call sites changed
- preserve navigation and sheet presentation behavior

## Protected Logic Change Checks

Any diff touching these areas requires explicit review:

- `ios/STRQ/ViewModels/AppViewModel.swift`
- `ios/STRQ/Services/WorkoutController.swift`
- `PlanGenerator.swift`
- `ProgressionEngine.swift`
- `AdaptivePrescriptionEngine.swift`
- `PersistenceStore.swift`
- `ExerciseIdentity.swift`
- `ExerciseCatalog.swift`
- `Analytics.swift`
- `StoreViewModel.swift`
- `STRQPaywallView.swift`
- `NotificationScheduler.swift`
- `HealthKitService.swift`
- watch/widget targets

If the pass is visual-only, expected result is no changes to these files.

## Build Expectations

Windows:

- `xcodebuild` is not expected.
- Do not fail the docs workflow because `xcodebuild` is unavailable.
- Do not claim build verification.

macOS or GitHub Actions:

- run the app target build
- run unit tests if behavior-adjacent files changed
- run UI tests or smoke tests if navigation/onboarding/paywall/workout screens changed
- capture simulator screenshots for changed screens

Suggested macOS commands:

```bash
xcodebuild -project ios/STRQ.xcodeproj -scheme STRQ -destination 'platform=iOS Simulator,name=iPhone 16' build
xcodebuild -project ios/STRQ.xcodeproj -scheme STRQ -destination 'platform=iOS Simulator,name=iPhone 16' test
```

Use the actual available simulator name on the macOS machine.

## Simulator Screenshot Review

For any production UI change:

- capture before/after where possible
- check small iPhone viewport
- check large iPhone viewport
- check dark mode
- check dynamic type basics if the changed surface has text-heavy UI
- check empty/loading/error states if the screen has them
- check no overlap, clipping, or unexpected layout shift
- check touch targets and disabled states

## Accessibility Basics

Validate:

- text contrast
- semantic color is not the only state indicator
- minimum touch target sizes
- readable dynamic type behavior
- accessible labels for icon-only buttons
- VoiceOver order for changed rows/cards
- reduce motion behavior for new animation

## Empty, Loading, Error State Review

Any migrated screen should document:

- loading state
- empty state
- error state
- offline or missing data state if applicable
- premium locked state if applicable
- disabled action state

Use Figma Error & Utility and Loader sources as reference, but implement STRQ-owned copy and behavior.

## Rollback Strategy

Keep every implementation pass small enough to revert safely.

Before merging a visual migration:

- know the files changed
- know the protected files untouched
- keep assets in one batch
- avoid mixing code, assets, and logic changes
- preserve a clear diff
- update the progress log

If a change fails QA:

1. Revert only the scoped visual change.
2. Keep docs unless they are inaccurate.
3. Record the failure and reason in `docs/migration-progress-log.md`.
4. Rescope the next pass smaller.

