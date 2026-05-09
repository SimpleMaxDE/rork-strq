# STRQ UI Migration Progress Log

This log is append-only. Add a new entry after every future Codex pass that touches planning, Figma inspection, assets, design-system code, or production UI.

Related control docs:

- [Docs README](README.md)
- [STRQ UI Migration Master Plan](strq-ui-migration-master-plan.md)
- [QA Validation Plan](qa-validation-plan.md)

## 2026-04-30 - Master Control Documentation Pass

### Scope

Planning, audit, mapping, and documentation only.

### Repository State Inspected

| Item | Result |
|---|---|
| Working directory | `C:\Users\maxwa\Documents\GitHub\rork-strq` |
| Branch | `main` |
| Git | Available |
| Initial working tree | Dirty before this pass |
| Initial untracked files | `docs/component-migration-plan.md`, `docs/figma-source-map.md`, `docs/project-ui-audit.md`, `docs/protected-logic-map.md` |
| `rg` path | `C:\Users\maxwa\AppData\Local\OpenAI\Codex\bin\rg.exe` |
| `rg` version | `ripgrep 15.1.0 (rev af60c2de9d)` |

### Existing Docs Read

- `ios/STRQ/Utilities/STRQDesignSystemRoadmap.md`
- `ios/STRQ/Utilities/STRQDesignSystemNamingPlan.md`
- `ios/STRQ/Utilities/STRQIconCoveragePlan.md`
- `ios/STRQ/Utilities/SandowImportManifest.md`
- `ios/STRQ/Utilities/SandowAnatomyImportPlan.md`
- existing untracked `docs/project-ui-audit.md`
- existing untracked `docs/figma-source-map.md`
- existing untracked `docs/component-migration-plan.md`
- existing untracked `docs/protected-logic-map.md`

### Codebase Areas Inspected

- app entry and top-level shell
- SwiftUI targets and Xcode project target list
- view model and protected state boundaries
- current design/theme files
- reusable production components
- isolated STRQ design-system primitives
- asset catalog structure
- font file presence
- localization setup
- watch/widget/test target presence

### Figma Areas Inspected

Figma access succeeded for:

- page inventory across 11 pages
- known foundation, component, icon, screen, and asset nodes
- local variable and style inventory
- shallow keyword discovery
- component-set inventory for General Components, App Components, and Foundations
- targeted search for pricing/paywall/subscription signals

Figma issues:

- two initial non-mutating Plugin API attempts failed due page-node property guards
- one broad full-file keyword sweep timed out after 120 seconds
- smaller bounded searches succeeded after that

### Docs Created Or Updated

Created:

- `docs/strq-ui-migration-master-plan.md`
- `docs/design-system-import-plan.md`
- `docs/asset-import-plan.md`
- `docs/ui-direction-options.md`
- `docs/migration-progress-log.md`
- `docs/qa-validation-plan.md`

Updated:

- `docs/project-ui-audit.md`
- `docs/figma-source-map.md`
- `docs/component-migration-plan.md`
- `docs/protected-logic-map.md`

### Intentionally Not Changed

- no Swift files
- no production screens
- no production UI components
- no app runtime behavior
- no workout logic
- no training/progression logic
- no active workout behavior
- no rest timer behavior
- no persistence/schema
- no analytics keys/events
- no RevenueCat/product identifiers
- no onboarding logic
- no localization catalogs
- no watch/widget code
- no assets imported
- no fonts imported

### Pending Work

- exact Figma variable value mapping
- exact token parity pass for colors, spacing, radii, effects, typography
- Work Sans font file decision and verification
- icon replacement policy for production screens
- anatomy export feasibility
- first production micro-migration target selection
- macOS build and simulator screenshot validation

### Next Recommended Pass

Run a token parity documentation pass:

1. Inspect Figma variables/styles in small exact chunks.
2. Map variables to `STRQColors`, `STRQSpacing`, `STRQRadii`, and `STRQEffects`.
3. Do not modify production screens.
4. Update `docs/design-system-import-plan.md` and `ios/STRQ/Utilities/STRQDesignSystemRoadmap.md`.

### Warnings

- The existing docs were untracked before this pass and should be reviewed/staged intentionally.
- Broad Figma scans can time out.
- No iOS build was run on Windows.
- Work Sans binaries are still missing from the visible checkout.
- Production screens still contain many SF Symbol references by design at this stage.

## 2026-04-30 - Docs QA Gate

### Scope

Documentation quality gate after the master project-control documentation pass.

### Reviewed

- Git state, branch, tracked/untracked docs status, and `rg` availability.
- All 10 project-control docs under `docs/`.
- Cross-link coverage between master plan, audit, Figma source map, design-system import plan, asset import plan, component migration plan, protected logic map, UI direction options, QA validation plan, and progress log.
- Required project/codebase, protected logic, Figma, asset, design-system, and QA coverage areas.
- Terminology around STRQ, STRQ-owned runtime naming, Purchased Figma UI Kit, Source/provenance docs, Design System Lab, protected app logic, screen migration, component migration, asset import, and Figma source map.

### Fixed

- Added `docs/README.md` as the entry point for the STRQ UI migration documentation.
- Added relative markdown links across the project-control docs.
- Normalized source/provenance wording so runtime naming remains STRQ-owned.
- Clarified that Work Sans, anatomy assets, asset import, and full Figma inspection remain pending.
- Updated the master plan and docs README with the recommended next pass order: Figma token parity, component primitive QA in the Design System Lab, then a low-risk production micro-migration only after foundation QA.

### Verification Run

- `where.exe rg`
- `rg --version`
- `git status --short`
- `git branch --show-current`
- `git diff --name-only`
- `git diff --name-only -- ios`
- Documentation and runtime `rg` searches listed in the docs QA request.

### Intentionally Not Changed

- no Swift files
- no production screens
- no runtime app logic
- no workout/training logic
- no persistence or data models
- no analytics, RevenueCat/product IDs, onboarding, navigation, active workout, rest timer, watch/widget, HealthKit, or localization behavior
- no assets or fonts imported
- no Figma assets imported
- no commits or staging

### Pending Work

- Figma token parity pass for colors, typography, spacing, radii, and effects.
- Work Sans font file decision and app-bundle verification.
- Component primitive QA in the Design System Lab.
- Anatomy export feasibility and any future asset import remain pending.
- First production micro-migration target selection after foundation QA.
- macOS or GitHub Actions build/test verification for implementation passes.

### Warnings

- This docs QA pass ran on Windows; no `xcodebuild` verification was run.
- The Purchased Figma UI Kit remains source/provenance only.
- Production screen migration is still blocked until foundation and primitive QA are complete.

## 2026-04-30 - Figma Token Parity Pass

### Scope

Foundation and documentation token parity pass only. No production screens, app logic, assets, fonts, localization, workout/training behavior, analytics, RevenueCat/product IDs, persistence, watch/widget code, or navigation behavior were changed.

### Files Changed

- `docs/figma-token-parity-report.md`
- `docs/design-system-import-plan.md`
- `docs/figma-source-map.md`
- `docs/strq-ui-migration-master-plan.md`
- `docs/migration-progress-log.md`
- `ios/STRQ/Views/Debug/STRQDesignSystemPreviewView.swift`

### Figma Inspected

Exact foundation nodes:

- Colors `5359:9002`
- Gradients `5442:13546`
- Typography `9119:6481`
- Effects `9120:58753`
- Grid `9122:4683`
- Size & Spacing `9122:6944`

Exact component-state nodes:

- Button `9128:103928`
- Badge & Chip `9126:59240`
- Progress `9129:207997`
- Tab `9131:172586`
- Navigation `11614:57585`
- Tab Bar `9131:291579`
- List Item `9134:89206`
- Schedule `9132:170645`
- Card - General `9131:326493`
- Card - App Specific `9160:324200`

Large component nodes were inspected with explicit descendant caps. No Figma timeout occurred in this pass.

### Code Inspected

- `ios/STRQ/Utilities/STRQDesignSystem.swift`
- `ios/STRQ/Views/Debug/STRQDesignSystemPreviewView.swift`
- `ios/STRQ/Utilities/STRQDesignSystemRoadmap.md`
- `ios/STRQ/Utilities/SandowImportManifest.md`

### Fixed

- Added the token parity report with color, gradient, typography, spacing/grid, radius, effects, and component-state parity tables.
- Updated the design-system plan, source map, and master plan with token parity status and the next recommended pass.
- Added a DEBUG-only Token Parity section to the Design System Lab for neutral surfaces, text colors, borders, spacing, radii, shadows, semantic colors, optional warm accent, and typography role samples.

### Verification Run

- `where.exe rg`
- `rg --version`
- `git diff --name-only -- ios/STRQ/Views ios/STRQ/ContentView.swift`
- `rg -n "Sandow" ios/STRQ/Views ios/STRQ/ContentView.swift`
- `rg -n -g "*.swift" "Sandow" ios/STRQ/Utilities`
- `rg -n "STRQColors|STRQTypography|STRQSpacing|STRQRadii|STRQEffects|STRQGradients|STRQComponentStyle" ios/STRQ/Utilities/STRQDesignSystem.swift`
- `rg -n "orangePrimary|warmAccent|primaryAccent|iconPrimary|selectedSurface|selectedBorder|focusGlow" ios/STRQ/Utilities/STRQDesignSystem.swift ios/STRQ/Views/Debug/STRQDesignSystemPreviewView.swift`
- `rg -n "WorkSans|Work Sans|STRQFontRegistrar|UIAppFonts" ios/STRQ docs`
- `rg -n "Image\\(systemName:" ios/STRQ/Views/Debug ios/STRQ/Utilities/STRQDesignSystem.swift`
- `rg -n "exercise\\.singular|set\\.plural|Start Session|Per Session" ios/STRQ`
- `rg -n "resetAllData|generatePlan|activeWorkout" ios/STRQ`
- `rg -n "RevenueCat|product|analytics|Analytics" ios/STRQ`
- `git diff --name-only`
- `git diff --name-only -- ios`
- `git diff --name-only -- ios/STRQ/ViewModels ios/STRQ/Services ios/STRQ/Models ios/STRQ/STRQApp.swift ios/STRQ/Localizable.xcstrings ios/STRQ/ContentView.swift ios/STRQ/Views/DashboardView.swift ios/STRQ/Views/ActiveWorkoutView.swift ios/STRQ/Views/ExerciseDetailView.swift ios/STRQ/Views/ExerciseLibraryView.swift ios/STRQ/Views/ProgressAnalyticsView.swift ios/STRQ/Views/STRQPaywallView.swift ios/STRQ/Views/ProfileView.swift ios/STRQ/Views/WorkoutCompletionView.swift`
- Icon enum/assets sync check: 60 enum cases, 60 image sets, 0 missing, 0 extra.
- Icon image-set validation: 60 checked, 0 errors.
- Font file search for `.ttf`, `.otf`, `.woff`, `.woff2`: no files found.

### Intentionally Not Changed

- no production screens
- no production UI migration
- no app/business logic
- no workout/training logic
- no active workout behavior
- no rest timer behavior
- no persistence/schema/data models
- no analytics keys/events
- no RevenueCat/product IDs
- no onboarding behavior
- no watch/widget code
- no localization catalogs
- no assets or fonts imported

### Pending Work

- Component primitive QA pass in the DEBUG Design System Lab.
- Work Sans font files and runtime fidelity verification.
- Exact two-layer shadow modeling only if a component needs it.
- Per-component deep variant inspection before any implementation.
- First production micro-migration only after foundation and primitive QA.

### Warnings

- This pass ran on Windows; `xcodebuild` was not run and is not expected here.
- STRQ intentionally keeps black/white/carbon/graphite as the default runtime direction; Figma orange remains optional/source-compatible.
- Large Figma component nodes should continue to be inspected one family at a time.

## 2026-05-01 - Component Primitive QA Pass

### Scope

Component primitive QA in the isolated STRQ design-system foundation and DEBUG Design System Lab. No production screens, app logic, assets, fonts, localization catalogs, workout/training behavior, analytics, RevenueCat/product IDs, persistence, watch/widget code, navigation behavior, or protected flows were changed.

### Files Changed

- `ios/STRQ/Utilities/STRQDesignSystem.swift`
- `ios/STRQ/Views/Debug/STRQDesignSystemPreviewView.swift`
- `docs/component-primitive-qa-report.md`
- `docs/component-migration-plan.md`
- `docs/design-system-import-plan.md`
- `docs/migration-progress-log.md`

### Figma Inspected

Exact component nodes:

- Button `9128:103928`
- Badge & Chip `9126:59240`
- Progress `9129:207997`
- Tab `9131:172586`
- Navigation `11614:57585`
- Tab Bar `9131:291579`
- List Item `9134:89206`
- Schedule `9132:170645`
- Card - General `9131:326493`
- Card - App Specific `9160:324200`

Button, Badge & Chip, Progress, Tab, Tab Bar, List Item, Card - General, and Card - App Specific were inspected with explicit descendant caps. Navigation and Schedule completed within bounded reads.

### Code Inspected

- `ios/STRQ/Utilities/STRQDesignSystem.swift`
- `ios/STRQ/Views/Debug/STRQDesignSystemPreviewView.swift`
- `ios/STRQ/Utilities/STRQIconCoveragePlan.md`
- docs listed in the component primitive QA request

### Fixed

- Added `docs/component-primitive-qa-report.md` with component coverage, visual QA, and production-readiness tables.
- Added safe STRQ-owned component states in `STRQDesignSystem.swift`:
  - button trailing icons, icon-only sizing, simple loading placeholder, accessibility label support
  - icon button compact and selected states
  - chip trailing icon, explicit disabled flag, accessibility label support
  - badge accessibility label support
  - metric card compact size and delta badge
  - semantic progress tones for bars and rings
  - list item trailing icon, selected, disabled, and compact states
  - search/input disabled and error states
  - toggle row disabled and compact states
  - avatar icon placeholder and xl size
  - empty-state action icon
  - schedule row status, completed, and compact states
- Expanded the DEBUG Design System Lab to show every requested primitive and key state while keeping the all-60 icon grid through `STRQIcon.allCases`.
- Updated component migration and design-system docs with readiness status and first micro-migration recommendation.

### Verification Run

- `git branch --show-current`
- `git status --short`
- `git diff --name-only`
- `where.exe rg`
- `rg --version`
- Figma exact-node inspection through the Figma Plugin API
- Static source reads of modified Swift component ranges
- Final validation searches are recorded in the final task summary for this pass

### Intentionally Not Changed

- no production screens
- no `DashboardView`
- no `ContentView`
- no `ActiveWorkoutView`
- no `ExerciseDetailView`
- no `ExerciseLibraryView`
- no `ProgressAnalyticsView`
- no `STRQPaywallView`
- no `ProfileView`
- no onboarding views
- no `WorkoutCompletionView`
- no coach, sleep, readiness, watch, or widget targets
- no `Localizable.xcstrings`
- no app/business logic
- no workout/training logic
- no active workout behavior
- no rest timer behavior
- no persistence/schema/data models
- no analytics keys/events
- no RevenueCat/product IDs
- no assets or fonts imported
- no Figma file keys, URLs, or node IDs added to runtime Swift code

### Pending Work

- macOS build validation for the primitive QA Swift diff.
- Simulator screenshot QA of the DEBUG Design System Lab.
- First production micro-migration: small Profile/settings row cluster using `STRQListItem`, `STRQToggleRow`, `STRQSectionHeader`, `STRQBadge`, and `STRQIconContainer`.
- Work Sans font files and runtime fidelity verification remain pending.
- Dedicated workout, coach, paywall, nutrition, anatomy, chart, media, tab/navigation, and schedule behavior passes remain future work.

### Warnings

- This pass ran on Windows; `xcodebuild` was not run and is not expected here.
- Figma component nodes are large; several were intentionally capped rather than full-scanned.
- New Swift component APIs need macOS build validation before any production adoption.

## 2026-05-02 - ChatGPT Project Handoff Prompt Pass

Scope:

- Created a detailed master handoff prompt for restarting ChatGPT from zero.
- Consolidated repo architecture, protected logic, product scope, Figma source mapping, design system status, migration strategy, QA expectations, and ChatGPT-to-Codex operating rules.
- Defined the working model requested by the user: ChatGPT speaks German with the user, writes Codex prompts in English, acts like a project/product/engineering lead, and asks the user mainly for meaningful yes/no decisions.
- Added ready-to-send English Codex prompt templates sized for bounded implementation passes instead of overly broad tasks.

Files changed:

- `docs/chatgpt-strq-master-handoff.md`
- `docs/migration-progress-log.md`

Figma inspected:

- File: `SH-sandow-UI-Kit--v3.0-`
- File key: `LBvxljax0ixoTvbvvUeWVC`
- URL: `https://www.figma.com/design/LBvxljax0ixoTvbvvUeWVC/SH-sandow-UI-Kit--v3.0-?m=auto&t=Cm2KJRPJnU51BdTq-6`
- Direct file inventory: 11 pages, 1082 local variables, 184 paint styles, 73 text styles, 25 effect styles, 3 grid styles.
- Variable collections confirmed: `Semantics` with Light/Dark modes and `Primitives` with Light mode.
- Key source pages and nodes recorded: Foundations, Icon Set, Design System General Components, App Components, Main Light, Main Dark, Bonus Dashboard, Bonus Mobile Patterns.
- Key component/source nodes recorded in the handoff: Profile Settings, dark Home, Badge & Chip, Button, Chart, Form Control, Input, Progress, Tab, App Bar, Bottom Sheet, Card, List Item, Navigation, Schedule, Section Header, Tab Bar, pricing, anatomy, equipment, illustration, and achievement assets.
- Figma search behavior recorded: prefer short exact searches and known node IDs; long compound searches returned weak/no results.

Code inspected:

- `rork.json`
- `.github/workflows/ios-build.yml`
- `.gitignore`
- `PLAN.md`
- `docs/README.md`
- `docs/strq-ui-migration-master-plan.md`
- `docs/migration-progress-log.md`
- `docs/figma-source-map.md`
- `docs/protected-logic-map.md`
- `docs/project-ui-audit.md`
- `docs/design-system-import-plan.md`
- `docs/component-migration-plan.md`
- `docs/component-primitive-qa-report.md`
- `docs/figma-token-parity-report.md`
- `docs/asset-import-plan.md`
- `docs/qa-validation-plan.md`
- `docs/ui-direction-options.md`
- `docs/localization-guidelines.md`
- `ios/STRQ/STRQApp.swift`
- `ios/STRQ/ContentView.swift`
- `ios/STRQ/ViewModels/AppViewModel.swift`
- `ios/STRQ/Utilities/STRQDesignSystem.swift`
- `ios/STRQ/Views/Debug/STRQDesignSystemPreviewView.swift`
- `ios/STRQ/Views/ProfileView.swift`
- `ios/STRQTests/STRQTests.swift`
- app entitlements and Xcode project identifiers

Verification run:

- Static repo inspection with `rg`, `git status`, and targeted `Get-Content` reads.
- Figma exact-node inspection through the Figma Plugin API.
- No Swift build was run in this pass.

Intentionally not changed:

- no Swift production code
- no Figma canvas writes
- no runtime app behavior
- no business logic
- no tests
- no assets
- no fonts
- no localization files
- no RevenueCat, bundle, app group, or iCloud identifiers

Pending work:

- User can use `docs/chatgpt-strq-master-handoff.md` as the new ChatGPT system/project prompt.
- ChatGPT should start by choosing the next bounded implementation prompt, preferably the debug design system lab build/QA or first Profile row-cluster micro-migration.
- macOS/Xcode build validation remains pending for Swift implementation tasks.
- Work Sans font import and visual parity remain pending.
- Figma-driven migrations should continue node-by-node with small Codex prompts.

Warnings:

- This pass is documentation and project orchestration only.
- The Figma file is very large; the handoff captures the actionable nodes and rules, not a full dump of every canvas object.
- The handoff prompt is intentionally detailed and should be treated as living project context, not as permission to change protected logic broadly.

## 2026-05-02 - Technical UI Baseline Report Pass

Scope:

- Created a code-only technical UI baseline for future STRQ UI migration prompts.
- Documented current root navigation, production screens, styling systems, STRQDesignSystem adoption, visual risk areas, protected flows, owner approval gates, Rork screenshot intake, and ranked next work packages.

Files changed:

- `docs/strq-ui-technical-baseline-report.md`
- `docs/migration-progress-log.md`

Code inspected:

- Required STRQ UI migration docs, `ContentView.swift`, `STRQDesignSystem.swift`, `STRQPalette.swift`, `ForgeTheme.swift`, and targeted production screen files under `ios/STRQ/Views`.

Verification run:

- `git status --short --branch`
- `git diff --name-only`
- Targeted `rg` searches for navigation, Forge/Palette styling, STRQDesignSystem adoption, RevenueCat/paywall, active workout/progression/protected flows, Sandow references, and orange/accent usage.

Intentionally not changed:

- no Swift files
- no production screens
- no assets, fonts, localization catalogs, tests, project files, view models, services, models, watch/widget files, `STRQApp.swift`, or `ContentView.swift`

Pending work:

- Owner/Rork screenshot QA after the next actual UI implementation pass.
- Next recommended implementation remains a narrow Profile/settings row-cluster continuation.

Warnings:

- This was documentation-only on Windows; no `xcodebuild` or simulator run was performed.
- Active Workout, onboarding, paywall, plan generation/progression, persistence, HealthKit, watch/widget/live activity, localization, and RevenueCat remain protected.

## 2026-05-02 - Premium Visual Direction Report Pass

Scope:

- Created a docs-only premium visual/product direction control report to restore owner screenshot findings, block orange as the default CTA identity, define protected areas, and make future Codex prompts stricter.

Files changed:

- `docs/strq-premium-visual-direction-report.md`
- `docs/migration-progress-log.md`

Figma inspected:

- None in this pass. The report used existing STRQ project docs and the owner-provided Rork screenshot findings as source input.

Code inspected:

- `ios/STRQ/Utilities/STRQDesignSystem.swift`
- `ios/STRQ/Utilities/STRQPalette.swift`
- `ios/STRQ/Utilities/ForgeTheme.swift`
- `ios/STRQ/Views/ProfileView.swift`
- `ios/STRQ/ContentView.swift`

Verification run:

- `git status --short --branch`
- `git diff --name-only`
- `git diff -- docs/strq-premium-visual-direction-report.md docs/migration-progress-log.md`
- protected-path and report-content `rg` checks recorded in the final task summary

Intentionally not changed:

- no Swift files
- no production screens
- no assets, fonts, localization catalogs, tests, project files, view models, services, models, watch/widget files, `STRQApp.swift`, or `ContentView.swift`

Pending work:

- Foundation hardening for CTA/accent/surface/list policy.
- Design System Lab QA and primitive readiness confirmation.
- Continued Profile migration only after foundation guardrails are stable.

Warnings:

- This was documentation-only on Windows; no `xcodebuild`, Rork simulator run, or screenshot QA was performed.
- Active Workout, Paywall, Onboarding, plan generation/progression, persistence, HealthKit, watch/widget/live activity, localization, RevenueCat, analytics, account/restore, and reset flows remain protected.

## 2026-05-03 - Foundation Hardening Pass 1

Scope:

- Created a docs-only CTA, accent, surface/card/list, chip/badge, progress, primitive-readiness, and migration-policy audit before further production UI migration.

Files changed:

- `docs/strq-foundation-hardening-pass-1.md`
- `docs/migration-progress-log.md`

Figma inspected:

- None in this pass. The audit used existing STRQ control docs and targeted repository inspection.

Code inspected:

- `ios/STRQ/Utilities/STRQDesignSystem.swift`
- `ios/STRQ/Utilities/STRQPalette.swift`
- `ios/STRQ/Utilities/ForgeTheme.swift`
- `ios/STRQ/Utilities/STRQInteraction.swift`
- targeted production SwiftUI views for CTA, accent, surface/list/card, chip/badge, and progress usage

Verification run:

- `git status --short --branch`
- `git diff --name-only`
- targeted `rg` searches for CTA/button systems, orange/accent usage, surfaces/lists/cards, chips/badges/progress, primitives, protected references, source-name references, and report content

Intentionally not changed:

- no Swift source files
- no assets, fonts, localization catalogs, RevenueCat/store files, tests, project files, view models, services, models, watch/widget/live activity files, `STRQApp.swift`, or `ContentView.swift`

Pending work:

- Foundation Hardening Pass 2: Design System Lab primitive readiness QA.
- Profile controlsSection completion only after lab readiness is confirmed.

Warnings:

- This was documentation-only on Windows; no `xcodebuild`, Rork simulator run, or screenshot QA was performed.
- Active Workout, Paywall, Onboarding, Plan Reveal, Train broad migration, Coach action cards, HealthKit, RevenueCat, Watch/Widget/Live Activity, persistence, progression, and plan generation remain explicitly not ready.

## 2026-05-03 - Foundation Hardening Pass 2 Design Lab Readiness

Scope:

- Created a docs-only Design System Lab primitive readiness QA report for `STRQDesignSystem` adoption decisions.

Files changed:

- `docs/strq-foundation-hardening-pass-2-design-lab-readiness.md`
- `docs/migration-progress-log.md`

Figma inspected:

- None in this pass. Local docs and repository code remained the source of truth.

Code inspected:

- `ios/STRQ/Utilities/STRQDesignSystem.swift`
- `ios/STRQ/Views/Debug/STRQDesignSystemPreviewView.swift`
- `ios/STRQ/Views/ProfileView.swift`
- targeted production usage references under `ios/STRQ/Views`

Verification run:

- `git status --short --branch`
- `git diff --name-only`
- targeted `rg` searches for DEBUG route status, primitive definitions/usages, CTA/button state coverage, accent/semantic state coverage, typography/font status, production adoption, protected references, source-name references, and report content

Intentionally not changed:

- no Swift source files
- no assets, fonts, localization catalogs, RevenueCat/store files, tests, project files, view models, services, models, watch/widget/live activity files, `STRQApp.swift`, or `ContentView.swift`

Pending work:

- Small DEBUG-only Design System Lab patch for missing `STRQProgressRow` sample and any explicitly scoped primitive state samples.
- Rork simulator screenshot QA after any future Lab visual edit or production UI implementation.
- Profile controlsSection completion / icon consistency after Lab coverage and Rork QA are clean.

Warnings:

- This was documentation-only on Windows; no `xcodebuild`, Rork simulator run, GitHub remote verification, or screenshot QA was performed.
- `STRQButton` is not ready to replace production CTAs broadly; protected flows still require owner approval.

## 2026-05-03 - DEBUG Design System Lab Progress Row Coverage Patch

Scope:

- Applied a DEBUG-only Design System Lab patch adding visible `STRQProgressRow` coverage in the existing Progress section.

Files changed:

- `ios/STRQ/Views/Debug/STRQDesignSystemPreviewView.swift`
- `docs/migration-progress-log.md`

Figma inspected:

- None. This pass used local docs and code only.

Code inspected:

- `ios/STRQ/Utilities/STRQDesignSystem.swift`
- `ios/STRQ/Views/Debug/STRQDesignSystemPreviewView.swift`
- `ios/STRQ/Views/ProfileView.swift`

Verification run:

- Local static diff, DEBUG route, `STRQProgressRow`, protected-path, and Sandow-reference checks.

Intentionally not changed:

- no production screens
- no `STRQDesignSystem.swift`
- no assets, fonts, localization catalogs, RevenueCat/store files, tests, project files, view models, services, models, watch/widget/live activity files, `STRQApp.swift`, or `ContentView.swift`

Pending work:

- Rork simulator screenshot QA for the DEBUG Design System Lab.
- macOS or CI build validation remains required before shipping.

Warnings:

- This pass ran on Windows; no `xcodebuild` or simulator validation was performed.

## 2026-05-03 - Profile Controls Section Completion / Icon Consistency

Scope:

- Completed a narrow Profile `controlsSection` completion/icon-consistency pass by aligning the DEBUG Design System Lab row with the migrated controls list shell while preserving existing behavior.

Files changed:

- `ios/STRQ/Views/ProfileView.swift`
- `docs/migration-progress-log.md`

Figma inspected:

- None. Local docs and code remained the source of truth.

Code inspected:

- `ios/STRQ/Utilities/STRQDesignSystem.swift`
- `ios/STRQ/Views/ProfileView.swift`
- `ios/STRQ/Views/Debug/STRQDesignSystemPreviewView.swift`

Verification run:

- Profile controls diff, DEBUG route, restore flow, regenerate-plan analytics/dialog, protected-path, and Sandow-reference static checks.

Intentionally not changed:

- no `STRQDesignSystem.swift`
- no `STRQDesignSystemPreviewView.swift`
- no production screens outside the scoped Profile controls row
- no assets, fonts, localization catalogs, RevenueCat/store files, tests, project files, view models, services, models, watch/widget/live activity files, `STRQApp.swift`, or `ContentView.swift`

Pending work:

- Rork simulator QA for the Profile controls section and DEBUG Design System Lab route.
- macOS or CI build validation remains required before shipping.

Warnings:

- This pass ran on Windows; no `xcodebuild` or simulator validation was performed.

## 2026-05-03 - Profile Controls Section Typography Consistency Fix

Scope:

- Applied a tiny Profile `controlsSection` typography consistency fix after Rork QA found the Notifications row title visually smaller than the other controls rows.

Files changed:

- `ios/STRQ/Views/ProfileView.swift`
- `docs/migration-progress-log.md`

Figma inspected:

- None. Figma was intentionally not used.

Code inspected:

- `ios/STRQ/Utilities/STRQDesignSystem.swift`
- `ios/STRQ/Views/ProfileView.swift`
- `ios/STRQ/Views/Debug/STRQDesignSystemPreviewView.swift`

Verification run:

- Targeted Profile controls, DEBUG route, protected-path, Sandow-reference, and diff checks.

Intentionally not changed:

- no protected Profile sections, design-system utility files, Debug Lab source, assets, fonts, localization catalogs, RevenueCat/store files, project files, tests, view models, services, models, watch/widget/live activity files, `STRQApp.swift`, or `ContentView.swift`

Pending work:

- Rork simulator QA for the Profile controls section typography.
- macOS or CI build validation remains required before shipping.

Warnings:

- This pass ran on Windows; no `xcodebuild` or simulator validation was performed.

## 2026-05-03 - Profile Controls Section Row Typography Unification Fix

Scope:

- Applied a second Rork-QA-driven Profile `controlsSection` row typography unification fix so all controls row titles use one controls-specific rendering path.

Files changed:

- `ios/STRQ/Views/ProfileView.swift`
- `docs/migration-progress-log.md`

Figma inspected:

- None. Figma was intentionally not used.

Code inspected:

- `ios/STRQ/Utilities/STRQDesignSystem.swift`
- `ios/STRQ/Views/ProfileView.swift`
- `ios/STRQ/Views/Debug/STRQDesignSystemPreviewView.swift`

Verification run:

- Targeted Profile controls, DEBUG route, protected-path, Sandow-reference, and diff checks.

Intentionally not changed:

- no protected Profile sections, design-system utility files, Debug Lab source, assets, fonts, localization catalogs, RevenueCat/store files, project files, tests, view models, services, models, watch/widget/live activity files, `STRQApp.swift`, or `ContentView.swift`

Pending work:

- Rork simulator QA for the Profile controls section row typography.
- macOS or CI build validation remains required before shipping.

Warnings:

- This pass ran on Windows; no `xcodebuild` or simulator validation was performed.

## 2026-05-03 - Profile Controls Section Notifications Optical Balance Fix

Scope:

- Applied a controlsSection-only optical balance fix for the Notifications row after Rork QA while preserving the visible label and all row behavior.

Files changed:

- `ios/STRQ/Views/ProfileView.swift`
- `docs/migration-progress-log.md`

Figma inspected:

- None. Figma was intentionally not used.

Code inspected:

- `ios/STRQ/Views/ProfileView.swift`
- `ios/STRQ/Utilities/STRQDesignSystem.swift`

Verification run:

- Targeted Profile controls, DEBUG route, protected-path, Sandow-reference, and diff checks.

Intentionally not changed:

- no protected Profile sections, design-system utility files, Debug Lab source, assets, fonts, localization catalogs, RevenueCat/store files, project files, tests, view models, services, models, watch/widget/live activity files, `STRQApp.swift`, or `ContentView.swift`

Pending work:

- Rork simulator QA for the Profile controls section optical balance.
- macOS or CI build validation remains required before shipping.

Warnings:

- This pass ran on Windows; no `xcodebuild` or simulator validation was performed.

## 2026-05-03 - Profile Training Setup Static Row Shell Migration

Scope:

- Applied a narrow Profile `trainingSetup` static row-shell migration to the STRQ design-system visual language while preserving displayed values and leaving focus muscle chips unchanged.

Files changed:

- `ios/STRQ/Views/ProfileView.swift`
- `docs/migration-progress-log.md`

Figma inspected:

- None. Figma was intentionally not used.

Code inspected:

- `ios/STRQ/Utilities/STRQDesignSystem.swift`
- `ios/STRQ/Views/ProfileView.swift`
- `ios/STRQ/Views/Debug/STRQDesignSystemPreviewView.swift`

Verification run:

- Targeted Profile training setup, row-helper reuse, controls section, protected-path, and Sandow-reference static checks.

Intentionally not changed:

- no focus muscle chips, Body & Nutrition, controlsSection, account, subscription, danger, paywall, assets, fonts, localization catalogs, RevenueCat/store files, project files, tests, view models, services, models, watch/widget/live activity files, `STRQApp.swift`, `ContentView.swift`, or design-system utility/debug files

Pending work:

- Rork simulator QA for the Profile Training Setup section.
- macOS or CI build validation remains required before shipping.

Warnings:

- This pass ran on Windows; no `xcodebuild` or simulator validation was performed.

## 2026-05-03 - Profile Body & Nutrition Static Info-Row Shell Migration

Scope:

- Applied a narrow Profile `bodyNutrition` static info-row shell migration to the STRQ design-system visual language while preserving displayed body and nutrition values, conditions, and actions.

Files changed:

- `ios/STRQ/Views/ProfileView.swift`
- `docs/migration-progress-log.md`

Figma inspected:

- None. Figma was intentionally not used.

Code inspected:

- `ios/STRQ/Utilities/STRQDesignSystem.swift`
- `ios/STRQ/Views/ProfileView.swift`
- `ios/STRQ/Views/Debug/STRQDesignSystemPreviewView.swift`

Verification run:

- Targeted Profile bodyNutrition, row-helper reuse, training setup, controls section, protected-path, and Sandow-reference static checks.

Intentionally not changed:

- no `trackingToggleCard`, Edit Targets button, Sleep Log button, Training Setup, controlsSection, account, subscription, danger, paywall, assets, fonts, localization catalogs, RevenueCat/store files, project files, tests, view models, services, models, watch/widget/live activity files, `STRQApp.swift`, `ContentView.swift`, or design-system utility/debug files

Pending work:

- Rork simulator QA for the Profile Body & Nutrition section in nutrition-tracking on and off states.
- macOS or CI build validation remains required before shipping.

Warnings:

- This pass ran on Windows; no `xcodebuild` or simulator validation was performed.

## 2026-05-03 - Profile Remaining Sections Risk Audit

Scope:

- Created a docs-only risk audit for remaining unmigrated Profile sections and selected exactly one next candidate prompt.

Files changed:

- `docs/profile-remaining-sections-risk-audit.md`
- `docs/migration-progress-log.md`

Figma inspected:

- None. Figma was intentionally not used.

Code inspected:

- `docs/README.md`
- `docs/strq-premium-visual-direction-report.md`
- `docs/strq-foundation-hardening-pass-1.md`
- `docs/strq-foundation-hardening-pass-2-design-lab-readiness.md`
- `docs/component-primitive-qa-report.md`
- `docs/qa-validation-plan.md`
- `docs/migration-progress-log.md`
- `docs/protected-logic-map.md`
- `ios/STRQ/Utilities/STRQDesignSystem.swift`
- `ios/STRQ/Views/ProfileView.swift`
- `ios/STRQ/Views/Debug/STRQDesignSystemPreviewView.swift`

Verification run:

- Static Profile helper, visual debt, protected behavior, STRQ primitive, Sandow-reference, protected-path, and docs diff checks.

Intentionally not changed:

- no Swift files
- no production screens
- no accepted Profile sections
- no assets, fonts, localization catalogs, RevenueCat/store files, project files, tests, view models, services, models, watch/widget/live activity files, `STRQApp.swift`, `ContentView.swift`, `STRQDesignSystem.swift`, or `STRQDesignSystemPreviewView.swift`

Pending work:

- Recommended next implementation prompt is `coachingStyleRow` visual shell migration only.
- Rork simulator QA is required after any future Profile UI implementation pass.

Warnings:

- This pass was documentation-only on Windows; no `xcodebuild`, Rork simulator run, GitHub remote verification, or screenshot QA was performed.
- Subscription, account/iCloud, danger/reset, tracking toggle side effects, paywall, RevenueCat, analytics, localization, and protected app logic remain blocked without explicit owner approval.

## 2026-05-03 - Profile Coaching Style Row Shell Migration

Scope:

- Applied a narrow Profile `coachingStyleRow` visual shell migration to the accepted calm dark/carbon Profile style while preserving the coaching preferences navigation and displayed values.

Files changed:

- `ios/STRQ/Views/ProfileView.swift`
- `docs/migration-progress-log.md`

Figma inspected:

- None. Figma was intentionally not used.

Code inspected:

- `docs/README.md`
- `docs/profile-remaining-sections-risk-audit.md`
- `docs/strq-premium-visual-direction-report.md`
- `docs/strq-foundation-hardening-pass-1.md`
- `docs/strq-foundation-hardening-pass-2-design-lab-readiness.md`
- `docs/component-primitive-qa-report.md`
- `docs/qa-validation-plan.md`
- `docs/migration-progress-log.md`
- `ios/STRQ/Utilities/STRQDesignSystem.swift`
- `ios/STRQ/Views/ProfileView.swift`
- `ios/STRQ/Views/Debug/STRQDesignSystemPreviewView.swift`

Verification run:

- Targeted Profile coaching row, accepted-section, protected-reference, protected-path, and Sandow-reference static checks.

Intentionally not changed:

- no accepted `controlsSection`, Training Setup static rows, Body & Nutrition static info rows, `trackingToggleCard`, subscription/account/danger/paywall/iCloud/reset/toggle/sheet behavior, assets, fonts, localization catalogs, RevenueCat/store files, project files, tests, view models, services, models, watch/widget/live activity files, `STRQApp.swift`, `ContentView.swift`, `STRQDesignSystem.swift`, or `STRQDesignSystemPreviewView.swift`

Pending work:

- Rork simulator QA for the Profile Coaching Style row on small and large iPhone viewports.
- macOS or CI build validation remains required before shipping.

Warnings:

- This pass ran on Windows; no `xcodebuild` or simulator validation was performed.

## 2026-05-03 - Coaching Style Experience Redesign Plan

Scope:

- Created a docs-only Coaching Style experience redesign plan after Rork screenshot observations showed the current row and detail screen are functional but not premium enough.

Files changed:

- `docs/coaching-style-experience-redesign-plan.md`
- `docs/migration-progress-log.md`

Figma inspected:

- Read-only bounded Figma inspection only.
- Dark AI Fitness Coach node `11605:86057`.
- Dark AI Fitness Coach subnodes `11605:86093` and `11605:87046`.
- Dark Profile Settings & Help Center node `11613:167073`.
- Dark Profile Settings & Help Center subnodes `11613:167244` and `11613:167256`.
- Design System App Components / List Item node `9134:89206`.
- Design System General Components / Badge & Chip node `9126:59240`.
- Design System General Components / Button node `9128:103928`.

Code inspected:

- Requested migration docs, source map, progress log, `ProfileView.swift`, `CoachingPreferencesView.swift`, and `STRQDesignSystem.swift`.

Verification run:

- Docs-only diff, protected iOS path diff, exact plan-content search, and worktree checks.

Intentionally not changed:

- no Swift files, no ProfileView, no CoachingPreferencesView, no STRQDesignSystem, no ContentView, no STRQApp, no assets, fonts, localization catalogs, RevenueCat/store files, project files, tests, view models, services, models, watch/widget/live activity files, analytics, persistence, account, reset, paywall, onboarding, active workout, plan generation, progression, HealthKit, or Figma canvas writes

Pending work:

- Future implementation should start with exactly one scoped pass: Profile `coachingStyleRow` redesign only.
- Rork simulator QA is required after any future Swift UI implementation.

Warnings:

- This pass was documentation-only on Windows; no `xcodebuild`, Rork simulator run, GitHub remote verification, or screenshot QA was performed.

## 2026-05-03 - Profile Coaching Style Entry Row Redesign

Scope:

- Redesigned only the Profile `coachingStyleRow` entry based on the Coaching Style Experience Redesign Plan so it reads as premium coach personalization instead of a chip-heavy technical settings summary.

Files changed:

- `ios/STRQ/Views/ProfileView.swift`
- `docs/migration-progress-log.md`

Figma inspected:

- None. Figma was intentionally not used.

Code inspected:

- Requested migration docs, `ios/STRQ/Utilities/STRQDesignSystem.swift`, `ios/STRQ/Views/ProfileView.swift`, and `ios/STRQ/Views/CoachingPreferencesView.swift`.

Verification run:

- Targeted Profile coaching row, accepted-section, protected-reference, protected-path, and Sandow-reference static checks.

Intentionally not changed:

- no `CoachingPreferencesView.swift`, accepted `controlsSection`, Training Setup static rows, Body & Nutrition static info rows, `trackingToggleCard`, subscription/account/danger/paywall/iCloud/reset/toggle/sheet behavior, assets, fonts, localization catalogs, RevenueCat/store files, project files, tests, view models, services, models, watch/widget/live activity files, `STRQApp.swift`, `ContentView.swift`, `STRQDesignSystem.swift`, or `STRQDesignSystemPreviewView.swift`

Pending work:

- Rork simulator QA for the Profile Coaching Style row on small and large iPhone viewports.
- macOS or CI build validation remains required before shipping.

Warnings:

- This pass ran on Windows; no `xcodebuild` or simulator validation was performed.

## 2026-05-03 - CoachingPreferencesView Hero-Only Redesign

Scope:

- Redesigned only the `CoachingPreferencesView` hero based on the Coaching Style Experience Redesign Plan so the destination starts as premium coach personalization instead of a dense settings summary.

Files changed:

- `ios/STRQ/Views/CoachingPreferencesView.swift`
- `docs/migration-progress-log.md`

Figma inspected:

- None. Figma was intentionally not used.

Code inspected:

- Requested migration docs, `ios/STRQ/Utilities/STRQDesignSystem.swift`, `ios/STRQ/Views/ProfileView.swift`, and `ios/STRQ/Views/CoachingPreferencesView.swift`.

Verification run:

- Targeted CoachingPreferences hero, Profile coaching row presence, protected-path, and Sandow-reference static checks.

Intentionally not changed:

- no option rows, disabled rows, section groups, footer, update/commit logic, analytics, navigation, ProfileView, design-system utilities, assets, fonts, localization catalogs, RevenueCat/store files, view models, services, models, watch/widget/live activity files, `STRQApp.swift`, or `ContentView.swift`

Pending work:

- Rork simulator QA for the Coaching Preferences hero on small and large iPhone viewports.
- macOS or CI build validation remains required before shipping.

Warnings:

- This pass ran on Windows; no `xcodebuild` or simulator validation was performed.

## 2026-05-04 - CoachingPreferencesView Option Card Selected-State Visual Pass

Scope:

- Updated only the `CoachingPreferencesView` option-card shell and selected-state treatment so coaching choices feel calmer, more premium, and aligned with the accepted hero.

Files changed:

- `ios/STRQ/Views/CoachingPreferencesView.swift`
- `docs/migration-progress-log.md`

Figma inspected:

- None. Figma was intentionally not used.

Code inspected:

- Requested migration docs, `ios/STRQ/Views/CoachingPreferencesView.swift`, `ios/STRQ/Views/ProfileView.swift`, and `ios/STRQ/Utilities/STRQDesignSystem.swift`.

Verification run:

- Scoped CoachingPreferences option-row, Profile reference, protected-path, and Sandow-reference static checks.

Intentionally not changed:

- no hero, section headings/groups, footer, update/commit logic, analytics, navigation, ProfileView, design-system utilities, assets, fonts, localization catalogs, RevenueCat/store files, view models, services, models, watch/widget/live activity files, `STRQApp.swift`, or `ContentView.swift`

Pending work:

- Rork simulator QA for selected/unselected option cards and disabled Physique state.
- macOS or CI build validation remains required before shipping.

Warnings:

- This pass ran on Windows; no `xcodebuild` or simulator validation was performed.

## 2026-05-04 - Profile Body & Nutrition Action-Button Shell Migration

Scope:

- Narrow Profile Body & Nutrition action-button visual shell migration for `Edit Targets` and `Sleep Log`, preserving sheet behavior and existing conditional visibility.

Files changed:

- `ios/STRQ/Views/ProfileView.swift`
- `docs/migration-progress-log.md`

Figma inspected:

- None. Figma was intentionally not used.

Code inspected:

- `ios/STRQ/Views/ProfileView.swift` Body & Nutrition, Training Setup, Controls, Coaching Style, protected sheet/state references, and protected path checks.

Verification run:

- Scoped ProfileView `rg` checks, protected-file diff checks, Sandow-reference check, and git diff/status review.

Intentionally not changed:

- `trackingToggleCard`, Body & Nutrition static info rows, Training Setup, controlsSection, coachingStyleRow, sheets/navigation, analytics, subscription/account/danger/paywall/iCloud/reset/toggle logic, protected files, assets, fonts, localization, RevenueCat/store files, view models, services, models, watch/widget/live activity files, `STRQApp.swift`, `ContentView.swift`, project files, or tests.

Pending work:

- Rork simulator QA for the Profile Body & Nutrition action buttons.
- macOS or CI build validation remains required before shipping.

Warnings:

- This pass ran on Windows; no `xcodebuild` or simulator validation was performed.

## 2026-05-04 - Profile Tracking Toggle Card Visual Shell Migration

Scope:

- Narrow Profile `trackingToggleCard` visual shell migration to the accepted STRQ Profile carbon-card language, preserving the nutrition tracking toggle binding and refresh side effects.

Files changed:

- `ios/STRQ/Views/ProfileView.swift`
- `docs/migration-progress-log.md`

Figma inspected:

- None. Figma was intentionally not used.

Code inspected:

- `ios/STRQ/Views/ProfileView.swift` Body & Nutrition, protected toggle binding, accepted Profile row/card treatments, and protected path checks.

Verification run:

- Scoped ProfileView `rg` checks, protected-file diff checks, Sandow-reference check, and git diff/status review.

Intentionally not changed:

- Body & Nutrition static info rows, Body & Nutrition action buttons, Training Setup, controlsSection, coachingStyleRow, sheets/navigation, analytics, subscription/account/danger/paywall/iCloud/reset behavior, protected files, assets, fonts, localization, RevenueCat/store files, view models, services, models, watch/widget/live activity files, `STRQApp.swift`, `ContentView.swift`, project files, or tests.

Pending work:

- Rork simulator QA for the Profile nutrition tracking toggle in both off and on states.
- macOS or CI build validation remains required before shipping.

Warnings:

- This pass ran on Windows; no `xcodebuild` or simulator validation was performed.

## 2026-05-04 - Profile Tracking Toggle Active-State Accent Refinement

Scope:

- Refined only the active/enabled visual state of Profile `trackingToggleCard` with restrained STRQ semantic green accents while preserving the neutral off state and all nutrition tracking side effects.

Files changed:

- `ios/STRQ/Views/ProfileView.swift`
- `docs/migration-progress-log.md`

Figma inspected:

- None. Figma was intentionally not used.

Code inspected:

- `ios/STRQ/Views/ProfileView.swift` `trackingToggleCard` and existing STRQ semantic success color tokens.

Verification run:

- Scoped ProfileView `rg` checks, protected-file diff checks, Sandow-reference check, and git diff/status review.

Intentionally not changed:

- Body & Nutrition static info rows, Body & Nutrition action buttons, Training Setup, controlsSection, coachingStyleRow, CoachingPreferencesView, sheets/navigation, analytics, subscription/account/danger/paywall/iCloud/reset behavior, protected files, assets, fonts, localization, RevenueCat/store files, view models, services, models, watch/widget/live activity files, `STRQApp.swift`, `ContentView.swift`, project files, or tests.

Pending work:

- Rork simulator QA for the Profile nutrition tracking toggle active and inactive states.
- macOS or CI build validation remains required before shipping.

Warnings:

- This pass ran on Windows; no `xcodebuild` or simulator validation was performed.

## 2026-05-04 - Profile Tracking Toggle Green Accent Softening

Scope:

- Refined only the active green visual treatment of Profile `trackingToggleCard` so the enabled state stays clear while reducing lime intensity in the icon well and card stroke.

Files changed:

- `ios/STRQ/Views/ProfileView.swift`
- `docs/migration-progress-log.md`

Figma inspected:

- None. Figma was intentionally not used.

Code inspected:

- `ios/STRQ/Views/ProfileView.swift` `trackingToggleCard` and existing STRQ semantic success color tokens.

Verification run:

- Scoped ProfileView `rg` checks, protected-file diff checks, Sandow-reference check, and git diff/status review.

Intentionally not changed:

- Body & Nutrition rows/buttons, Edit Targets conditional visibility, Sleep Log behavior, Training Setup, controlsSection, coachingStyleRow, other screens, design-system utilities, localization, assets, fonts, RevenueCat/store files, view models, services, models, watch/widget/live activity files, project files, or tests.

Pending work:

- Rork simulator QA for the softened active green state.
- macOS or CI build validation remains required before shipping.

Warnings:

- This pass ran on Windows; no `xcodebuild` or simulator validation was performed.

## 2026-05-04 - Profile Tracking Toggle Dark Green Hue Correction

Scope:

- Applied a local premium dark-green hue correction to Profile `trackingToggleCard` active state after token audit confirmed `STRQColors.successGreen` maps to lime500.

Files changed:

- `ios/STRQ/Views/ProfileView.swift`
- `docs/migration-progress-log.md`

Figma inspected:

- None. Figma was intentionally not used.

Code inspected:

- `ios/STRQ/Views/ProfileView.swift` `trackingToggleCard`, local active-state color references, and protected toggle binding/refresh side effects.

Verification run:

- Scoped ProfileView color, toggle binding, protected-section, protected-file, Sandow-reference, and git diff/status checks.

Intentionally not changed:

- global STRQ design-system tokens, `STRQPalette`, Body & Nutrition rows/buttons, Edit Targets conditional visibility, Sleep Log behavior, Training Setup, controlsSection, coachingStyleRow, subscription/account/danger sections, other production screens, assets, fonts, localization, RevenueCat/store files, view models, services, models, watch/widget/live activity files, project files, or tests.

Pending work:

- Rork simulator QA for the Profile nutrition tracking toggle active and inactive states.
- macOS or CI build validation remains required before shipping.

Warnings:

- This pass ran on Windows; no `xcodebuild` or simulator validation was performed.

## 2026-05-04 - Profile Fitness Identity Semantic Plan

Scope:

- Created a docs-only semantic and visual planning report for Profile `fitnessIdentity`, separating visual shell work from Recovery, Sleep, Nutrition, and Streak product meaning.

Files changed:

- `docs/profile-fitness-identity-semantic-plan.md`
- `docs/migration-progress-log.md`

Figma inspected:

- None. This pass used repo docs and Swift source only.

Code inspected:

- `docs/README.md`
- `docs/strq-premium-visual-direction-report.md`
- `docs/profile-remaining-sections-risk-audit.md`
- `docs/strq-foundation-hardening-pass-1.md`
- `docs/strq-foundation-hardening-pass-2-design-lab-readiness.md`
- `docs/qa-validation-plan.md`
- `docs/migration-progress-log.md`
- `ios/STRQ/Views/ProfileView.swift`
- `ios/STRQ/Utilities/STRQDesignSystem.swift`
- `ios/STRQ/Utilities/STRQPalette.swift`
- `ios/STRQ/Utilities/ForgeTheme.swift`

Verification run:

- Docs-only diff, protected iOS path diff, Profile fitness identity source checks, token/color source checks, and plan-content search.

Intentionally not changed:

- no Swift files
- no Profile implementation
- no design-system, palette, theme, assets, fonts, localization catalogs, RevenueCat/store files, view models, services, models, watch/widget/live activity files, project files, or tests

Pending work:

- Recommended next prompt is exactly one shell-only `fitnessIdentity` migration that preserves all metric values, thresholds, colors, and the Nutrition/Streak branch.
- Rork simulator QA is required after any future Swift UI implementation.

Warnings:

- This pass ran on Windows; no `xcodebuild` or simulator validation was performed.
- Semantic color changes remain owner-gated because these metrics communicate coaching meaning.

## 2026-05-04 - Profile Fitness Identity Shell Migration

Scope:

- Migrated only the Profile `fitnessIdentity` card shell and local `statusChip` tile presentation to the accepted calm dark/carbon Profile style, preserving all semantic metric colors, displayed data, icons, thresholds, and the Nutrition/Streak branch.

Files changed:

- `ios/STRQ/Views/ProfileView.swift`
- `docs/migration-progress-log.md`

Figma inspected:

- None. Figma was intentionally not used.

Code inspected:

- Requested Profile migration docs, `ios/STRQ/Views/ProfileView.swift`, `ios/STRQ/Utilities/STRQDesignSystem.swift`, `ios/STRQ/Utilities/STRQPalette.swift`, and `ios/STRQ/Utilities/ForgeTheme.swift`.

Verification run:

- Scoped Profile `fitnessIdentity`, `statusChip`, accepted-section, protected-file, Sandow-reference, and git diff/status checks.

Intentionally not changed:

- no metric values, value formats, SF Symbols, semantic color sources, thresholds, Nutrition/Streak branch, `profileHeader`, subscription/account/danger/footer sections, accepted Profile sections, design-system utilities, palette/theme files, assets, fonts, localization catalogs, RevenueCat/store files, view models, services, models, watch/widget/live activity files, project files, or tests

Pending work:

- Rork simulator QA for Profile `fitnessIdentity` on small and large iPhone viewports, including early-stage/established and Nutrition/Streak states.
- macOS or CI build validation remains required before shipping.

Warnings:

- This pass ran on Windows; no `xcodebuild` or simulator validation was performed.
- Semantic color refinement remains owner-gated.

## 2026-05-04 - Profile Fitness Identity Metric-Tile Refinement

Scope:

- Refined only the Profile `fitnessIdentity` `statusChip` metric-tile presentation to feel less blocky and more coach-like while preserving all metric values, labels, icons, semantic color sources, and the Nutrition/Streak branch.

Files changed:

- `ios/STRQ/Views/ProfileView.swift`
- `docs/migration-progress-log.md`

Figma inspected:

- None. Figma was intentionally not used.

Code inspected:

- `ios/STRQ/Views/ProfileView.swift` `fitnessIdentity` metric calls and `statusChip` helper.

Verification run:

- Scoped Profile metric-tile, accepted-section, protected-file, Sandow-reference, and git diff/status checks.

Intentionally not changed:

- no `fitnessIdentity` goal header, outer shell, metric call sites, metric values, labels, icons, semantic color sources, thresholds, Nutrition/Streak branch, accepted Profile sections, protected files, assets, fonts, localization catalogs, view models, services, models, watch/widget/live activity files, project files, or tests

Pending work:

- Rork simulator QA for Profile `fitnessIdentity` metric tiles in Nutrition enabled and disabled states.
- macOS or CI build validation remains required before shipping.

Warnings:

- This pass ran on Windows; no `xcodebuild` or simulator validation was performed.

## 2026-05-04 - Profile Fitness Identity Metric Accent-Marker Polish

Scope:

- Polished only the Profile `fitnessIdentity` `statusChip` metric accent marker, replacing the small horizontal line marker with a subtle circular dot that keeps using the existing metric color parameter.

Files changed:

- `ios/STRQ/Views/ProfileView.swift`
- `docs/migration-progress-log.md`

Figma inspected:

- None. Figma was intentionally not used.

Code inspected:

- `ios/STRQ/Views/ProfileView.swift` `statusChip` marker implementation.

Verification run:

- Scoped Profile marker, metric call-site, protected-file, Sandow-reference, and git diff/status checks.

Intentionally not changed:

- no `fitnessIdentity` outer shell, metric call sites, values, labels, icons, semantic color sources, thresholds, Nutrition/Streak branch, accepted Profile sections, protected files, assets, fonts, localization catalogs, view models, services, models, watch/widget/live activity files, project files, or tests

Pending work:

- Rork simulator QA for Profile `fitnessIdentity` metric markers in Nutrition enabled and disabled states.
- macOS or CI build validation remains required before shipping.

Warnings:

- This pass ran on Windows; no `xcodebuild` or simulator validation was performed.

## 2026-05-04 - Profile Fitness Identity Metric Marker Removal

Scope:

- Removed the decorative Profile `fitnessIdentity` `statusChip` metric marker entirely, keeping icon color as the only semantic accent for each metric tile.

Files changed:

- `ios/STRQ/Views/ProfileView.swift`
- `docs/migration-progress-log.md`

Figma inspected:

- None. Figma was intentionally not used.

Code inspected:

- `ios/STRQ/Views/ProfileView.swift` `statusChip` marker implementation.

Verification run:

- Scoped Profile `statusChip`, metric call-site, protected-file, Sandow-reference, and git diff/status checks.

Intentionally not changed:

- no `fitnessIdentity` outer shell, metric call sites, values, labels, icons, semantic color sources, thresholds, Nutrition/Streak branch, accepted Profile sections, protected files, assets, fonts, localization catalogs, view models, services, models, watch/widget/live activity files, project files, or tests

Pending work:

- Rork simulator QA for Profile `fitnessIdentity` metric tiles in Nutrition enabled and disabled states.
- macOS or CI build validation remains required before shipping.

Warnings:

- This pass ran on Windows; no `xcodebuild` or simulator validation was performed.

## 2026-05-04 - Profile Subscription Section Risk Plan

Scope:

- Created a docs-only risk and redesign plan for the Profile `subscriptionSection` / STRQ Pro entry before any Swift implementation.

Files changed:

- `docs/profile-subscription-section-risk-plan.md`
- `docs/migration-progress-log.md`

Figma inspected:

- None. This pass used repo docs and Swift source only.

Code inspected:

- Requested migration docs, `ios/STRQ/Views/ProfileView.swift`, `ios/STRQ/Views/STRQPaywallView.swift`, `ios/STRQ/ViewModels/StoreViewModel.swift`, and RevenueCat-facing references found by `rg`.

Verification run:

- Docs-only diff, protected iOS path diff, Profile subscription source checks, RevenueCat/store reference checks, Sandow-reference check, and plan-content search.

Intentionally not changed:

- no Swift files, no Profile implementation, no paywall, no StoreViewModel/RevenueCat logic, no design-system/palette/theme files, no assets, fonts, localization catalogs, view models, services, models, watch/widget/live activity files, project files, or tests

Pending work:

- Recommended next prompt is exactly one shell-only non-Pro `subscriptionSection` card pass that preserves paywall analytics and presentation behavior.
- Rork simulator QA is required after any future subscriptionSection Swift implementation.

Warnings:

- This pass ran on Windows; no `xcodebuild` or simulator validation was performed.
- Subscription/paywall behavior remains owner-gated and revenue-sensitive.

## 2026-05-04 - Profile Subscription Non-Pro Shell

Scope:

- Migrated only the non-Pro `subscriptionSection` STRQ Pro card visual shell to a calmer carbon premium treatment while preserving paywall analytics, Button behavior, sheet presentation, store logic, and copy.

Files changed:

- `ios/STRQ/Views/ProfileView.swift`
- `docs/migration-progress-log.md`

Verification run:

- Profile subscription diff and protected-path checks; Windows environment only, so no `xcodebuild` or simulator validation was performed.

Pending work:

- Rork QA should verify tapping the non-Pro STRQ Pro card still opens the paywall.
- macOS or CI build validation remains required before shipping.

## 2026-05-04 - Profile Subscription Pro Accent

Scope:

- Changed the local non-Pro `subscriptionSection` STRQ Pro card accent from orange/warm to deep violet/indigo while preserving paywall analytics, Button behavior, sheet presentation, store logic, layout, and copy.

Files changed:

- `ios/STRQ/Views/ProfileView.swift`
- `docs/migration-progress-log.md`

Verification run:

- Profile subscription accent diff and protected-path checks; Windows environment only, so no `xcodebuild` or simulator validation was performed.

Pending work:

- Rork QA should verify tapping the non-Pro STRQ Pro card still opens the paywall and the new accent reads as premium, not neon.
- macOS or CI build validation remains required before shipping.

## 2026-05-04 - Profile Subscription Pro Accent Visibility

Scope:

- Refined only the local non-Pro `subscriptionSection` STRQ Pro violet/indigo accent visibility so the bolt mark and top accent line read more clearly while preserving paywall analytics, Button behavior, sheet presentation, store logic, layout, and copy.

Files changed:

- `ios/STRQ/Views/ProfileView.swift`
- `docs/migration-progress-log.md`

Verification run:

- Profile subscription accent visibility diff and protected-path checks; Windows environment only, so no `xcodebuild` or simulator validation was performed.

Pending work:

- Rork QA should verify tapping the non-Pro STRQ Pro card still opens the paywall and the refined violet/indigo accent reads as recognizable but restrained.
- macOS or CI build validation remains required before shipping.

## 2026-05-04 - Profile Active Pro Subscription Shell

Scope:

- Migrated only the Pro-active `subscriptionSection` shell to a restrained dark carbon card with local violet/indigo Pro accents while preserving manage-subscription analytics, action, and sheet behavior.

Files changed:

- `ios/STRQ/Views/ProfileView.swift`
- `docs/migration-progress-log.md`

Verification run:

- Profile active Pro subscription shell diff and protected-path checks; Windows environment only, so no `xcodebuild` or simulator validation was performed.

Pending work:

- Rork QA should verify the active membership card reads as premium and already-Pro while Manage Subscription remains clearly tappable but secondary.
- macOS or CI build validation remains required before shipping.

## 2026-05-04 - Profile Account Sync Risk Plan

Scope:

- Created a docs-only risk and redesign plan for `ProfileView.accountSection` / Sync & Restore before any account/iCloud Swift implementation.

Files changed:

- `docs/profile-account-sync-risk-plan.md`
- `docs/migration-progress-log.md`

Code inspected:

- `ios/STRQ/Views/ProfileView.swift`
- `ios/STRQ/ViewModels/AppViewModel.swift`
- `ios/STRQ/Services/AccountManager.swift`
- `ios/STRQ/Services/CloudSyncService.swift`
- `ios/STRQ/Services/ContinuityCoordinator.swift`
- `ios/STRQ/Services/SnapshotBuilder.swift`

Verification run:

- Docs-only diff, protected iOS path diff, Profile account/source checks, account/cloud service reference checks, and plan-content search.

Intentionally not changed:

- no Swift files, no Profile implementation, no account/iCloud services or models, no restore/upload/sign-out behavior, no alerts/copy/localization, no assets, fonts, RevenueCat/store files, Watch, Widget, Live Activity, project files, or tests

Pending work:

- Recommended next prompt is exactly one signed-out `accountSection` shell-only pass that preserves the native Apple sign-in button and all post-sign-in restore/upload behavior.
- Rork simulator QA is required after any future accountSection Swift implementation.

Warnings:

- This pass ran on Windows; no `xcodebuild` or simulator validation was performed.
- Account/iCloud restore behavior remains owner-gated and data-sensitive.

## 2026-05-04 - Profile Signed-Out Sync Shell

Scope:

- Updated only the signed-out `ProfileView.accountSection` Sync & Restore visual shell with a restrained STRQ carbon card, neutral trust icon well, and local-first footer treatment.

Files changed:

- `ios/STRQ/Views/ProfileView.swift`
- `docs/migration-progress-log.md`

Intentionally not changed:

- Native Sign in with Apple request/completion handling, post-sign-in iCloud restore/upload behavior, signed-in account branch, account/cloud helpers, alerts, copy/localization, protected services/models/view models, assets, tests, Watch, Widget, project, and store files.

Pending work:

- Rork QA should verify the signed-out Sync & Restore module feels calm, premium, trustworthy, and not like a subscription upsell.
- macOS or CI build validation remains required before shipping; this pass ran on Windows.

## 2026-05-04 - Profile Danger Zone Shell

Scope:

- Updated only the `ProfileView.dangerSection` visual shell to a restrained STRQ dark card treatment with semantic red danger affordances.

Files changed:

- `ios/STRQ/Views/ProfileView.swift`
- `docs/migration-progress-log.md`

Intentionally not changed:

- Reset All Data button behavior, top-level reset alert copy, destructive reset action, cancel action, `showResetAlert`, `vm.resetAllData()`, accepted Profile sections, protected app logic, assets, localization, tests, Watch, Widget, project, and store files.

Pending work:

- Rork QA should verify Danger Zone remains calm, premium, and unmistakably destructive without reading as a primary CTA.
- macOS or CI build validation remains required before shipping; this pass ran on Windows.

## 2026-05-04 - Global Tint System Accent Audit

Scope:

- Created a read-only audit explaining why the Reset Alert Cancel button inherits the orange app tint, mapping global tint risk, and recommending a broader accent migration plan before any Swift changes.

Files changed:

- `docs/strq-global-tint-system-accent-audit.md`
- `docs/migration-progress-log.md`

Intentionally not changed:

- no Swift files, no `ContentView`, no alerts, no reset behavior, no app tint, no assets, no localization, no protected flows, and no tests

Pending work:

- Owner should approve a global accent migration plan and Rork QA matrix before changing app tint or local alert tint.

## 2026-05-04 - Profile Stage 1 QA Report

Scope:

- Created a docs-only Profile Stage 1 QA and remaining-debt report, marking accepted Profile areas, caveats, protected behavior, required Rork QA, release-readiness status, and exactly one recommended next screen.

Files changed:

- `docs/profile-stage-1-qa-report.md`
- `docs/migration-progress-log.md`

Intentionally not changed:

- no Swift files, no Profile implementation, no `ContentView`, no app tint, no protected logic, no assets, no localization, no project files, and no tests

Pending work:

- Owner Rork QA remains required before treating Profile as release-ready; recommended next screen is NotificationSettings planning.

## 2026-05-04 - NotificationSettings Risk Plan

Scope:

- Created a docs-only risk and redesign plan for `NotificationSettingsView` before any notification settings Swift implementation.

Files changed:

- `docs/notification-settings-risk-plan.md`
- `docs/migration-progress-log.md`

Code inspected:

- `ios/STRQ/Views/NotificationSettingsView.swift`
- `ios/STRQ/Views/ProfileView.swift`
- `ios/STRQ/Models/NotificationSettings.swift`
- `ios/STRQ/Services/NotificationScheduler.swift`
- `ios/STRQ/Services/ReminderWidgetCoordinator.swift`
- `ios/STRQ/Models/NotificationDeepLinkRoute.swift`
- `ios/STRQ/Services/NotificationDeepLinkCenter.swift`
- `ios/STRQ/AppDelegate.swift`
- `ios/STRQ/ContentView.swift`
- `ios/STRQ/STRQApp.swift`
- `ios/STRQ/ViewModels/AppViewModel.swift`
- `ios/STRQ/Services/HealthKitService.swift`

Verification run:

- Docs-only diff, protected iOS path diff, NotificationSettings behavior searches, notification scheduler/deep-link searches, and plan-content search.

Intentionally not changed:

- no Swift files, no `NotificationSettingsView` implementation, no Profile implementation, no notification services/managers, no permissions, no scheduling/canceling behavior, no routes/deep links, no HealthKit behavior, no assets, no localization, no project files, and no tests

Pending work:

- Recommended next prompt is exactly one low-risk non-permission `coachNudges` toggle-row visual pass.
- Rork simulator QA is required after any future NotificationSettings Swift implementation.

Warnings:

- This pass ran on Windows; no `xcodebuild` or simulator validation was performed.
- Notification scheduling, permission requests, deep links, and HealthKit behavior remain owner-gated and protected.

## 2026-05-04 - NotificationSettings Coach Nudges Visual Pass

Scope:

- Updated only the `NotificationSettingsView.coachNudges` visual shell to a restrained STRQ dark card treatment while preserving the Coach Recommendations toggle binding and top-level reminder rescheduling behavior.

Files changed:

- `ios/STRQ/Views/NotificationSettingsView.swift`
- `docs/migration-progress-log.md`

Intentionally not changed:

- Shared `sectionHeader` and `toggleRow`, permission banner, workout/readiness/weekly/streak/HealthKit sections, notification services/models/routes, scheduling calls, permission requests, copy/localization catalogs, assets, tests, Watch, Widget, project files, and Profile were not changed.

Pending work:

- Rork QA should verify Coach Nudges remains compact, calm, non-Pro, and that toggling Coach Recommendations still reschedules reminders through existing behavior.
- macOS or CI build validation remains required before shipping; this pass ran on Windows.

## 2026-05-04 - NotificationSettings Coach Nudges Accent Refinement

Scope:

- Refined only the `NotificationSettingsView.coachNudges` visual treatment with a restrained local cool-blue Coach/Intelligence accent while preserving the toggle binding, copy, placement, and existing reminder rescheduling behavior.

Files changed:

- `ios/STRQ/Views/NotificationSettingsView.swift`
- `docs/migration-progress-log.md`

Intentionally not changed:

- Shared `sectionHeader` and `toggleRow`, permission banner, other notification sections, notification services/models/routes, scheduling calls, permission requests, HealthKit behavior, assets, localization, project files, and Profile were not changed.

Pending work:

- Rork QA should verify the accent reads as Coach/Intelligence, not warm, subscription-coded, neon, or gamified.
- macOS or CI build validation remains required before shipping; this pass ran on Windows.

## 2026-05-04 - NotificationSettings Coach Nudges Steel Blue Tuning

Scope:

- Refined only the local `NotificationSettingsView.coachNudges` accent color values from bright cool-blue to muted Coach Blue / Steel Blue while preserving layout, copy, toggle binding, placement, and existing reminder rescheduling behavior.

Files changed:

- `ios/STRQ/Views/NotificationSettingsView.swift`
- `docs/migration-progress-log.md`

Intentionally not changed:

- Layout, spacing, icon, copy, shared helpers, permission banner, other notification sections, notification services/models/routes, scheduling calls, HealthKit behavior, assets, localization, project files, and Profile were not changed.

Pending work:

- Rork QA should verify Coach Nudges still feels active when enabled without reading as neon, gamified, or subscription-coded.
- macOS or CI build validation remains required before shipping; this pass ran on Windows.

## 2026-05-04 - NotificationSettings Streak Protection Visual Pass

Scope:

- Updated only the `NotificationSettingsView.streakReminders` visual shell to a restrained STRQ dark card with a local muted ember/bronze accent while preserving the Streak at Risk toggle binding and top-level reminder rescheduling behavior.

Files changed:

- `ios/STRQ/Views/NotificationSettingsView.swift`
- `docs/migration-progress-log.md`

Intentionally not changed:

- Shared `sectionHeader` and `toggleRow`, Coach Nudges, permission banner, workout/readiness/weekly/HealthKit sections, notification services/models/routes, scheduling calls, permission requests, HealthKit behavior, assets, localization, project files, and tests were not changed.

Pending work:

- Rork QA should verify Streak Protection reads as calm consistency/risk support, not gamified reward, bright orange CTA, Pro violet, Coach Blue, or green.
- macOS or CI build validation remains required before shipping; this pass ran on Windows.

## 2026-05-04 - NotificationSettings Streak Protection Copper Tuning

Scope:

- Refined only the local `NotificationSettingsView.streakReminders` accent values from ember/orange-leaning bronze to a darker premium Copper/Bronze tone while preserving layout, copy, toggle binding, and existing reminder rescheduling behavior.

Files changed:

- `ios/STRQ/Views/NotificationSettingsView.swift`
- `docs/migration-progress-log.md`

Intentionally not changed:

- Layout, spacing, icon, copy, shared helpers, Coach Nudges, permission banner, other notification sections, notification services/models/routes, scheduling calls, HealthKit behavior, assets, localization, project files, and tests were not changed.

Pending work:

- Rork QA should verify Streak Protection stays warm and active without reading as orange CTA, gamified reward, Pro violet, Coach Blue, or green.
- macOS or CI build validation remains required before shipping; this pass ran on Windows.

## 2026-05-04 - NotificationSettings Weekly Review Visual Pass

Scope:

- Updated only the `NotificationSettingsView.weeklyReviewReminders` visual shell to a restrained STRQ dark card with a muted Sapphire / Review Blue accent while preserving the Weekly Review Ready toggle, Review Day picker binding/tags, and top-level reminder rescheduling behavior.

Files changed:

- `ios/STRQ/Views/NotificationSettingsView.swift`
- `docs/migration-progress-log.md`

Pending work:

- Rork QA should verify Weekly Review feels like calm planning/review and that toggling or changing the review day still reschedules through existing behavior.
- macOS or CI build validation remains required before shipping; this pass ran on Windows.

## 2026-05-04 - NotificationSettings Weekly Review Sapphire Tuning

Scope:

- Refined only the local `NotificationSettingsView.weeklyReviewReminders` accent color values from brighter Review Blue to darker Sapphire/Navy so Weekly Review reads clearly distinct from Coach Nudges while preserving layout, copy, toggle binding, picker binding/tags, and existing reminder rescheduling behavior.

Files changed:

- `ios/STRQ/Views/NotificationSettingsView.swift`
- `docs/migration-progress-log.md`

Pending work:

- Rork QA should verify Weekly Review now reads as Sapphire/Navy planning/review rather than a near-match to Coach Blue.
- macOS or CI build validation remains required before shipping; this pass ran on Windows.

## 2026-05-04 - NotificationSettings Permission Banner Shell Visual Pass

Scope:

- Updated only the `NotificationSettingsView.permissionBanner` visual shell to a muted Trust Steel STRQ card surface while preserving permission request, Settings fallback, `authStatus` update, and reminder rescheduling behavior.

Files changed:

- `ios/STRQ/Views/NotificationSettingsView.swift`
- `docs/migration-progress-log.md`

Pending work:

- Rork QA should verify the permission/status module feels calm and trustworthy, and that Enable and Settings continue to behave as before.
- macOS or CI build validation remains required before shipping; this pass ran on Windows.

## 2026-05-04 - NotificationSettings Daily Check-In Visual Pass

Scope:

- Updated only the `NotificationSettingsView.readinessReminders` visual shell to a restrained STRQ dark card with a muted Readiness Teal accent while preserving the Daily Readiness Check-In toggle binding, Check-In Time DatePicker binding/display, and top-level reminder rescheduling behavior.

Files changed:

- `ios/STRQ/Views/NotificationSettingsView.swift`
- `docs/migration-progress-log.md`

Pending work:

- Rork QA should verify Daily Check-In reads as calm readiness/self-check support and that toggling or changing the check-in time still reschedules through existing behavior.
- macOS or CI build validation remains required before shipping; this pass ran on Windows.

## 2026-05-04 - NotificationSettings Workout Reminders Visual Pass

Scope:

- Updated only the `NotificationSettingsView.workoutReminders` visual shell to a restrained STRQ dark card with muted Steel / Graphite Blue-Grey accents while preserving the Workout Planned Today toggle, Reminder Time DatePicker binding/display, and top-level reminder rescheduling behavior.

Files changed:

- `ios/STRQ/Views/NotificationSettingsView.swift`
- `docs/migration-progress-log.md`

Pending work:

- Rork QA should verify Workout Reminders feels practical and training-structured, and that toggling or changing the reminder time still reschedules through existing behavior.
- macOS or CI build validation remains required before shipping; this pass ran on Windows.

## 2026-05-04 - NotificationSettings Authorized Permission Settings Action

Scope:

- Updated only `NotificationSettingsView.permissionBanner` trailing action logic so `.authorized`, `.provisional`, and `.ephemeral` states show the same secondary `Settings` button as `.denied`, opening `UIApplication.openSettingsURLString`.
- Preserved the `.notDetermined` Enable request flow, banner title/subtitle behavior, and reminder scheduling behavior.

Files changed:

- `ios/STRQ/Views/NotificationSettingsView.swift`
- `docs/migration-progress-log.md`

Verification run:

- `git status --short --branch`
- `git diff --name-only`
- `git diff -- ios/STRQ/Views/NotificationSettingsView.swift docs/migration-progress-log.md`
- targeted `rg` checks for permission-banner status/action symbols, notification scheduler usage, Sandow references, and protected paths

Intentionally not changed:

- no fake permission toggle
- no reminder sections
- no HealthKit section
- no `bannerTitle` or `bannerSubtitle`
- no notification services, models, routes, assets, localization, project files, widget/watch targets, or tests

Pending work:

- Rork QA required to verify enabled notification states expose the secondary Settings action clearly without reading as a CTA.
- macOS or CI build validation remains required before shipping; this pass ran on Windows.

## 2026-05-04 - NotificationSettings Permission Button Wrap Fix

Scope:

- Updated only the trailing `Enable` / `Settings` button styling inside `NotificationSettingsView.permissionBanner` so labels stay on one line using a compact minimum width, one-line limit, and gentle scale factor.
- Preserved permission status conditions, Enable action, Settings action, banner title/subtitle behavior, and reminder scheduling behavior.

Files changed:

- `ios/STRQ/Views/NotificationSettingsView.swift`
- `docs/migration-progress-log.md`

Verification run:

- `git status --short --branch`
- `git diff --name-only`
- `git diff -- ios/STRQ/Views/NotificationSettingsView.swift docs/migration-progress-log.md`
- targeted `rg` checks for permission button layout/action symbols, Sandow references, and protected paths

Intentionally not changed:

- no permission behavior
- no fake permission toggle
- no reminder sections
- no HealthKit section
- no notification services, models, routes, assets, localization, project files, widget/watch targets, or tests

Pending work:

- Rork QA required to verify `Enable` and `Settings` remain compact, secondary, and unwrapped in all permission states.
- macOS or CI build validation remains required before shipping; this pass ran on Windows.

## 2026-05-04 - NotificationSettings Stage 1 QA Report

Scope:

- Created a docs-only NotificationSettings Stage 1 QA consolidation report covering completed visual areas, caveats, protected behavior, required Rork QA, visual consistency, release-readiness, and exactly one recommended next screen.

Files changed:

- `docs/notification-settings-stage-1-qa-report.md`
- `docs/migration-progress-log.md`

Intentionally not changed:

- no Swift files, no `NotificationSettingsView`, no notification services, no HealthKit behavior, no Profile implementation, no app tint, no assets, no localization, no project files, and no tests

Pending work:

- Rork QA remains required before treating NotificationSettings as release-ready; recommended next screen is CoachingPreferences final QA.

## 2026-05-04 - CoachingPreferences Final QA Report

Scope:

- Created a docs-only CoachingPreferences final QA and remaining-risk report covering implementation inventory, protected behavior, visual diagnosis, required state coverage, release-readiness, and exactly one recommended next action and next screen.

Files changed:

- `docs/coaching-preferences-final-qa-report.md`
- `docs/migration-progress-log.md`

Intentionally not changed:

- no Swift files, no `CoachingPreferencesView`, no Profile implementation, no models, no services, no analytics files, no design-system utilities, no assets, no localization, no project files, and no tests

Pending work:

- Rork QA should verify all CoachingPreferences option groups, locked/unlocked Physique behavior, Profile summary updates, persistence/refresh behavior, and small/large layouts before freezing the screen.

## 2026-05-04 - CoachTab Risk Plan

Scope:

- Created a docs-only CoachTab risk, visual direction, protected behavior, and implementation planning report before any Swift implementation.

Files changed:

- `docs/coach-tab-risk-plan.md`
- `docs/migration-progress-log.md`

Code inspected:

- `ios/STRQ/Views/CoachTabView.swift`
- CoachTab-adjacent read-only behavior sources including `AppViewModel`, `DailyStateCoordinator`, `DailyBriefingEngine`, `ComebackEngine`, `ComebackCard`, `PhaseOutlookCard`, `CoachingHistoryView`, `ExpandableCoachCard`, `CoachAction`, `CoachingMemoryService`, `ForgeTheme`, `STRQPalette`, and `Analytics`.

Intentionally not changed:

- no Swift files, no CoachTab implementation, no action logic, no models, no services, no analytics files, no design-system utilities, no assets, no localization, no project files, no tests, no Watch, Widget, or Live Activity files

Pending work:

- Recommended next prompt is exactly one docs-only CoachTab state/screenshot inventory before selecting any display-only Swift shell candidate.

### 2026-05-04 - CoachTab Calibration Checklist Shell

Scope:

- CoachTab calibrationChecklist shell-only visual pass; preserved checklist labels, icons, order, conditions, early-state gating, and non-interactive logic.

Files changed:

- ios/STRQ/Views/CoachTabView.swift
- docs/migration-progress-log.md

Intentionally not changed:

- earlyStateCard, shouldShowCalibrationChecklist, CoachTab actions, sheets, analytics, models, services, design tokens, assets, and localization.

## 2026-05-05 - Coach Weekly Check-In Risk Plan

Scope:

- Created a docs-only risk and visual direction plan for `CoachTabView.weeklyCheckInRow` before any Swift implementation.

Files changed:

- `docs/coach-weekly-checkin-risk-plan.md`
- `docs/migration-progress-log.md`

Figma inspected:

- Bounded read-only scan for broad dark dashboard, compact card/list, progress/step, and coach-summary pattern categories only. No assets, layouts, text, or proprietary details were copied.

Code inspected:

- `ios/STRQ/Views/CoachTabView.swift`
- `ios/STRQ/Views/WeeklyCheckInView.swift`
- `ios/STRQ/ViewModels/AppViewModel.swift`
- weekly review and plan-quality behavior references needed for mapping only

Intentionally not changed:

- no Swift files, no CoachTab implementation, no WeeklyCheckInView implementation, no view models, no models, no services, no analytics files, no design-system utilities, no assets, no localization, no project files, no tests, no Watch, Widget, or Live Activity files

Pending work:

- Recommended next prompt is exactly one early-stage passive/not-ready `weeklyCheckInRow` shell-only pass, followed by Rork QA.

### 2026-05-05 - CoachTab Passive Weekly Check-In Shell

Scope:

- Refined only the passive early-stage Weekly Check-In shell so the upcoming weekly review reads as calm and noninteractive while preserving review generation and sheet behavior.

Files changed:

- ios/STRQ/Views/CoachTabView.swift
- docs/migration-progress-log.md

Intentionally not changed:

- Ready and established Weekly Check-In actions, `planQualityRow`, `WeeklyCheckInView`, review generation, sheet routing, analytics, localization, models, services, and persistence.

## 2026-05-05 - Coach Authority Hero Risk Plan

Scope:

- Created a docs-only risk, behavior map, and visual direction plan for `CoachTabView.authorityHero` before any Swift implementation.

Files changed:

- `docs/coach-authority-hero-risk-plan.md`
- `docs/migration-progress-log.md`

Figma inspected:

- Not used in this pass. The plan references broad pattern categories only and does not copy assets, text, layouts, or proprietary details.

Code inspected:

- `ios/STRQ/Views/CoachTabView.swift`
- `ios/STRQ/Views/ReadinessCheckInView.swift`
- `ios/STRQ/ViewModels/AppViewModel.swift`
- `ios/STRQ/Services/DailyStateCoordinator.swift`
- `ios/STRQ/Services/DailyBriefingEngine.swift`
- readiness, phase, recovery color, and count-up behavior references needed for mapping only

Verification run:

- `git status --short --branch`
- `git diff --name-only`
- `git diff -- docs/coach-authority-hero-risk-plan.md docs/migration-progress-log.md`
- `git diff --name-only -- ios/STRQ ios/STRQWidget ios/STRQWatch`
- `rg -n "Coach Authority Hero Risk Plan|authorityHero|Check in|readiness|effectiveRecoveryScore|recommended next implementation|Rork" docs/coach-authority-hero-risk-plan.md`

Intentionally not changed:

- no Swift files, no CoachTab implementation, no ReadinessCheckInView implementation, no view models, no models, no services, no analytics files, no design-system utilities, no assets, no localization, no project files, no tests, no Watch, Widget, or Live Activity files

Pending work:

- Recommended next prompt is exactly one `authorityHero` shell-only visual pass preserving behavior, followed by Rork QA across high/medium/low readiness and checked-in/not-checked-in states.

### 2026-05-05 - CoachTab Authority Hero Shell

Scope:

- CoachTab authorityHero shell-only visual pass preserving score, status, phase, Check in, Reduce Motion, and sheet behavior.

Files changed:

- `ios/STRQ/Views/CoachTabView.swift`
- `docs/migration-progress-log.md`

Figma inspected:

- Not used; broad command-center/readiness composition was applied from STRQ's existing dark carbon foundation.

Intentionally not changed:

- headline priority, decision stack, primary move, primary CTA, Weekly Check-In, early-state card, calibration checklist, sheets, analytics, models, services, persistence, design-system tokens, assets, localization, Watch, Widget, and tests.

### 2026-05-05 - Readiness Color Semantics Audit

Scope:

- Created a docs-only readiness/recovery color semantics audit explaining the `58` Moderate pink/red mismatch and recommending a CoachTab-specific readiness color resolver before any global palette change.

Files changed:

- `docs/readiness-color-semantics-audit.md`
- `docs/migration-progress-log.md`

Intentionally not changed:

- Swift files, CoachTab implementation, global palette/theme files, readiness views, Dashboard, Profile, models, services, assets, localization, Widget, Watch, project files, and tests.

### 2026-05-05 - CoachTab Readiness Hero Color Semantics Fix

Scope:

- Added a CoachTab-only readiness hero color resolver for the `authorityHero` ring, status dot, status text, and glow so Moderate readiness reads as amber/warning while preserving the premium dark hero shell.

Files changed:

- `ios/STRQ/Views/CoachTabView.swift`
- `docs/migration-progress-log.md`

Code inspected:

- `authorityHero` still uses `vm.effectiveRecoveryScore`, `vm.currentPhase`, `vm.readinessBasedRecoveryStatus`, `STRQCountUpText(value: Double(score), duration: 0.75)`, `CGFloat(score) / 100`, existing Check in visibility/action, and Reduce Motion-aware animation.

Verification run:

- `git status --short --branch`
- `git diff --name-only`
- `git diff -- ios/STRQ/Views/CoachTabView.swift docs/migration-progress-log.md`
- `git diff --name-only -- ios/STRQ/Utilities ios/STRQ/ViewModels ios/STRQ/Services ios/STRQ/Models ios/STRQ/Views/ReadinessCheckInView.swift ios/STRQ/Views/DashboardView.swift ios/STRQ/Views/ProfileView.swift ios/STRQ/Views/ProgressAnalyticsView.swift ios/STRQWidget ios/STRQWatch`
- `rg -n "private var authorityHero|readinessBasedRecoveryStatus|effectiveRecoveryScore|STRQCountUpText|CGFloat\\(score\\) / 100|hasCheckedInToday|showReadinessCheckIn|ForgeTheme\\.recoveryColor|STRQPalette\\.recovery|STRQPalette\\.warning|STRQPalette\\.danger|STRQPalette\\.success|readinessHeroColor|coachReadinessColor" ios/STRQ/Views/CoachTabView.swift`
- `rg -n "STRQPalette\\.recovery|static func recovery|recoveryColor\\(for" ios/STRQ/Utilities ios/STRQ/Views`
- `rg -n "Sandow" ios/STRQ/Views ios/STRQ/ContentView.swift`

Intentionally not changed:

- Global palette/theme/design-system files, status thresholds, score source, status/headline/week/check-in copy, sheets/actions/analytics, models, services, assets, localization, Widget, Watch, project files, and tests.

Warnings:

- Windows environment only; no `xcodebuild` was run. macOS/CI build validation and Rork QA remain required before shipping.

### 2026-05-05 - CoachTab Readiness Green Band Polish

Scope:

- Refined only the CoachTab readiness hero resolver's `70..<85` band so Well Prepared remains green but is visibly more muted than Peak Readiness on the dark hero.

Files changed:

- `ios/STRQ/Views/CoachTabView.swift`
- `docs/migration-progress-log.md`

Verification run:

- `git status --short --branch`
- `git diff --name-only`
- `git diff -- ios/STRQ/Views/CoachTabView.swift docs/migration-progress-log.md`
- `rg -n "coachReadinessColor|STRQPalette\\.success|STRQPalette\\.warning|STRQPalette\\.danger|effectiveRecoveryScore|readinessBasedRecoveryStatus|showReadinessCheckIn" ios/STRQ/Views/CoachTabView.swift`
- `rg -n "Sandow" ios/STRQ/Views ios/STRQ/ContentView.swift`
- `git diff --name-only -- ios/STRQ/Utilities ios/STRQ/ViewModels ios/STRQ/Services ios/STRQ/Models ios/STRQ/Views/ReadinessCheckInView.swift ios/STRQ/Views/DashboardView.swift ios/STRQ/Views/ProfileView.swift ios/STRQ/Views/ProgressAnalyticsView.swift ios/STRQWidget ios/STRQWatch`

Intentionally not changed:

- Authority hero layout, score/status/phase/headline/week/check-in behavior, sheets/actions/analytics, global color tokens, theme/design-system files, AppViewModel, services, models, assets, localization, other screens, Widget, and Watch.

Warnings:

- Windows environment only; no `xcodebuild` was run. Rork QA remains required.

## 2026-05-05 - Coach Decision Stack Risk Plan

Scope:

- Created a docs-only risk, behavior map, and visual direction plan for the established-user CoachTab `decisionStack` before any Swift implementation.

Files changed:

- `docs/coach-decision-stack-risk-plan.md`
- `docs/migration-progress-log.md`

Code inspected:

- `ios/STRQ/Views/CoachTabView.swift`
- `ios/STRQ/Services/DailyBriefingEngine.swift`
- `ios/STRQ/Services/DailyStateCoordinator.swift`
- `ios/STRQ/ViewModels/AppViewModel.swift`
- `ios/STRQ/Models/UserProfile.swift`
- `ios/STRQ/Services/CoachingConfidence.swift`

Intentionally not changed:

- no Swift files, no CoachTab implementation, no ReadinessCheckInView or WeeklyCheckInView changes, no view models, no models, no services, no persistence, no analytics files, no design-system utilities, no assets, no localization, no project files, no tests, no Watch, Widget, or Live Activity files

Pending work:

- Recommended next prompt is exactly one `momentumCard` display-only shell pass, followed by Rork QA across density, emphasis, and established-user decision-stack states.

## 2026-05-05 - STRQ Product Design North Star

Scope:

- Created a docs-only STRQ Product & Design North Star to guide future product/UI prompts, risk modes, screen roles, semantic color rules, prompt requirements, freeze policy, release standard, and the assistant-owner working model.

Files changed:

- `docs/strq-product-design-north-star.md`
- `docs/migration-progress-log.md`

Intentionally not changed:

- no Swift files, no production code, no assets, no localization, no project files, no tests, no Watch, Widget, or Live Activity files

Pending work:

- Use this north star as the control document for future Codex prompts, with the next likely CoachTab sprint being a safe Coach Supporting Signals batch rather than one tiny card at a time.

### 2026-05-05 - CoachTab Supporting Signals Shell

Scope:

- Refined only the established-user CoachTab supporting signal layer: `momentumCard`, `watchCard`, and the More Signals row inside `decisionStack`.
- Preserved decision-stack visibility, density and emphasis gates, watch details expand/collapse behavior, More Signals sheet routing, momentum display-only behavior, primary CTA behavior, workout handoff, readiness routing, sheets, analytics, copy/localization, models, services, design-system tokens, assets, Watch, Widget, project files, and tests.

Files changed:

- `ios/STRQ/Views/CoachTabView.swift`
- `docs/migration-progress-log.md`

Figma inspected:

- Not used; the pass was guided by the STRQ Product & Design North Star and the CoachTab decision-stack risk plan.

Pending work:

- Rork QA should verify established-user primary + watch + momentum + More Signals states, focused density hiding, simplicity emphasis hiding momentum, watch details expanded/collapsed, More Signals sheet opening, and small/large iPhone layouts.
- macOS or CI build validation remains required before shipping; this pass ran on Windows.

### 2026-05-05 - Weekly Review Experience Visual Batch Pass

Scope:

- Refined the active/ready Weekly Check-In gateway in CoachTab and the Weekly Review sheet summary, highlights, coach conclusion, and action-row visual shells as one premium weekly coach report flow.
- Preserved review generation call sites, sheet routing, page order, TabView selection behavior, selected action state, confirmation dialog behavior, review data usage, action application behavior, analytics behavior, model/view-model logic, copy/localization, and global design tokens.
- Left the passive early-stage Weekly Check-In shell and `planQualityRow` unchanged.

Files changed:

- `ios/STRQ/Views/CoachTabView.swift`
- `ios/STRQ/Views/WeeklyCheckInView.swift`
- `docs/migration-progress-log.md`

Figma inspected:

- Not used in this pass. The result was guided by STRQ's Product & Design North Star and broad weekly report / dark analytics / coach summary patterns from the existing STRQ planning docs.

Code inspected:

- `docs/strq-product-design-north-star.md`
- `docs/coach-weekly-checkin-risk-plan.md`
- `docs/coach-tab-risk-plan.md`
- `docs/migration-progress-log.md`
- `ios/STRQ/Views/CoachTabView.swift`
- `ios/STRQ/Views/WeeklyCheckInView.swift`
- Weekly review model/action references for behavior confirmation only

Intentionally not changed:

- no `AppViewModel`, review generator, models, services, persistence, analytics files, design-system utilities, global palette/theme files, assets, localization, Readiness, More Signals, Active Workout, training, handoff, RevenueCat/store, Widget, Watch, Live Activity, project files, tests, or fonts

Pending work:

- Rork QA should verify the active CoachTab Weekly Check-In entry, three-page Weekly Review carousel, summary proof hierarchy, highlights observations, Coach's Take conclusion, action row confirmation dialog, small/large iPhone layouts, and no orange CTA dominance.
- macOS or CI build validation remains required before shipping; this pass ran on Windows.

### 2026-05-05 - Weekly Review Page Scroll Fix

Scope:

- Fixed the Weekly Review sheet page layout so Summary, Highlights, and Coach pages can scroll vertically inside the paged carousel.
- Removed the outer vertical `ScrollView` around the `TabView` and wrapped each page in a local vertical scroll helper.
- Preserved page order, `currentPage`, page tags, page indicator, review data usage, copy/localization, confirmation dialog, `vm.applyReviewAction(selected)`, presentation detents, drag indicator, and visual shells.

Files changed:

- `ios/STRQ/Views/WeeklyCheckInView.swift`
- `docs/migration-progress-log.md`

Intentionally not changed:

- no `CoachTabView`, view models, models, services, analytics files, design-system utilities, global palette/theme files, assets, localization, Widget, Watch, Live Activity, project files, tests, or fonts

Pending work:

- Rork QA should verify all three Weekly Review pages scroll vertically when content exceeds the viewport, horizontal swiping still works, and the action confirmation dialog remains unchanged.
- macOS or CI build validation remains required before shipping; this pass ran on Windows.

### 2026-05-05 - CoachTab Main Screen Cohesion Polish

Scope:

- Ran a visual-only cohesion pass on the main CoachTab surface so the screen reads more like STRQ's coach brain: daily command, supporting reasoning, calibration learning, and weekly review gateway.
- Increased top-level screen rhythm, reduced repeated rail/spine treatments, made established supporting signals quieter and more evidence-like, converted the early calibration checklist into a compact signal board grid, and softened the weekly gateway shells.
- Preserved all CoachTab actions, sheets, analytics, copy/localization, state sources, model/view-model/service behavior, workout handoff, readiness routes, More Signals routing, watch details toggling, weekly review generation, and protected flows.

Files changed:

- `ios/STRQ/Views/CoachTabView.swift`
- `docs/migration-progress-log.md`

Figma inspected:

- Not used. The pass was guided by the STRQ Product & Design North Star, CoachTab risk plans, and prior accepted CoachTab module direction.

Intentionally not changed:

- no `WeeklyCheckInView`, `ReadinessCheckInView`, `AppViewModel`, `DailyStateCoordinator`, `DailyBriefingEngine`, models, services, persistence, analytics files, design-system utilities, global palette/theme files, assets, localization, RevenueCat/store files, Watch, Widget, Live Activity, project files, tests, fonts, or other production screens

Pending work:

- Rork QA should verify early-stage and established CoachTab states, readability of the new calibration grid, supporting-signal hierarchy, More Signals doorway, active/passive Weekly Check-In gateways, watch details collapsed/expanded, and small/large iPhone layouts.
- macOS or CI build validation remains required before shipping; this pass ran on Windows.

## 2026-05-05 - Licensed Figma Foundation Adoption Plan

Scope:

- Created a docs-only STRQ Licensed Figma Foundation Adoption Plan that treats the purchased Figma kit as licensed implementation source, not inspiration only.
- Converted read-only Figma foundation, component, icon, anatomy, chart, pricing, onboarding, and screen-pattern inspection into a STRQ adoption policy, inventory, screen map, roadmap, prompt rules, and exactly one immediate next prompt recommendation.

Files changed:

- `docs/strq-licensed-figma-foundation-adoption-plan.md`
- `docs/migration-progress-log.md`

Figma inspected:

- Used [@Figma](plugin://figma@openai-curated) read-only.
- Inspected the licensed kit pages for Foundations, General Components, App Components, Icon Set, Main Light/Dark mobile screens, Bonus Dashboard, and Bonus Mobile Patterns.
- Inspected key nodes for colors, typography, effects, grid, size/spacing, media, illustration, icons, buttons, chips, charts, forms, inputs, modals, progress, tabs, tab bar, cards, lists, navigation, schedule, bottom sheets, pricing, anatomy, body type, equipment, achievement badges, and illustrations.

Intentionally not changed:

- no Swift files, no assets, no localization, no tests, no Watch, Widget, Live Activity, project files, production code, or Figma canvas writes

Pending work:

- Recommended immediate next prompt is a docs-only Licensed Source Mode icon and anatomy adoption map before any asset export or Swift implementation.

## 2026-05-05 - Licensed Figma Icon Anatomy Adoption Map

Scope:

- Created a docs-only STRQ licensed Figma icon and anatomy adoption map before any asset export, Swift change, asset catalog change, or project-file change.
- Mapped licensed icon categories, current STRQ replacement opportunities, anatomy/body/equipment/achievement/illustration sources, STRQ-owned naming, export/import guardrails, roadmap, risks, exactly one first export pilot, and exactly one immediate next prompt.

Files changed:

- `docs/strq-licensed-figma-icon-anatomy-adoption-map.md`
- `docs/migration-progress-log.md`

Figma inspected:

- Used [@Figma](plugin://figma@openai-curated) read-only in Licensed Source Mode.
- Inspected Design System - Icon Set, Icon Container, Icon Featured, Icon library, Anatomy Muscle, large anatomy vector groups, Body Type, Organ Anatomy, Fitness Equipment Image, Achievement Badge, Achievement Badge Base, Illustration Base, Media, and Illustration nodes.

Intentionally not changed:

- no Swift files, no assets, no asset catalogs, no localization, no tests, no Watch, Widget, Live Activity, project files, production code, Figma canvas writes, or Figma asset exports

Pending work:

- Recommended next prompt is an export-only QA pilot for the Anatomy Muscle subset before any asset catalog import or Swift implementation.

## 2026-05-06 - Human Body Overlay Visual QA

Scope:

- Created a QA-only visual validation pass for licensed Human Body base and transparent `currentColor` overlay candidates, including base contact sheets, overlay contact sheets, multi-select previews, semantic-state examples, README, and manifest.

Files changed:

- `docs/figma-exports/human-body-overlay-visual-qa/`
- `docs/migration-progress-log.md`

Figma inspected:

- No new Figma reads; this pass used the prior Human Body overlay pilot exports from `9192:5535` and its manifest.

Verification run:

- Ran `git status --short --branch`, `git diff --name-only`, QA folder listing, manifest JSON parse, README/manifest keyword search, forbidden app-target diff check, and `git diff --check`.

Intentionally not changed:

- no Swift files, no app assets, no asset catalogs, no localization, no tests, no fonts, no Watch, Widget, project files, production runtime assets, or existing pilot exports

Pending work:

- Xcode SVG/currentColor template-tint smoke test and vector PDF comparison before any app import.

## 2026-05-05 - Licensed Anatomy Muscle Export QA Pilot

Scope:

- Ran an export-only QA pilot for the licensed Anatomy Muscle subset: Chest, Back, Abs, and Glute across Male/Female and Selected/Unselected variants.

Files changed:

- `docs/figma-exports/anatomy-pilot/`
- `docs/migration-progress-log.md`

Figma inspected:

- Used [@Figma](plugin://figma@openai-curated) in Licensed Source Mode, read-only/export-only.
- Inspected Anatomy Muscle `8673:69673` and exported 16 clearly labeled SVG variants from nodes `9024:101237`, `9024:97738`, `9025:100270`, `9024:102739`, `9024:101868`, `9024:99348`, `9025:100900`, `9025:98731`, `9024:101162`, `9023:268361`, `9025:100122`, `9024:102664`, `9024:101740`, `9024:99220`, `9025:100770`, and `9025:98471`.
- Inspected large anatomy vector groups `9192:5535` for context only; no exports were taken from that node.

Verification run:

- Ran export folder listing, manifest JSON parse, README/manifest `rg` checks, `git diff --name-only -- ios/STRQ ios/STRQWidget ios/STRQWatch`, `git diff --check`, and SVG viewBox/raster/background checks.

Intentionally not changed:

- no Swift files, no app assets, no asset catalogs, no localization, no tests, no Watch, Widget, Live Activity, project files, production code, or Figma canvas writes

Pending work:

- Normalize background-free and STRQ-tokenized anatomy candidates before any app asset catalog import.

Warnings:

- Raw SVG exports are vector-only but include the source rounded component background and border, so they are not transparent as-is.

## 2026-05-05 - STRQ Anatomy Overlay System Plan

Scope:

- Created a docs-only plan for turning licensed Figma Anatomy Muscle sources into a base-body plus transparent overlay/mask runtime system.

Files changed:

- `docs/strq-anatomy-overlay-system-plan.md`
- `docs/migration-progress-log.md`

Figma inspected:

- Used [@Figma](plugin://figma@openai-curated) read-only in Licensed Source Mode.
- Inspected Anatomy Muscle `8673:69673` and large anatomy vector groups `9192:5535`.

Intentionally not changed:

- no Swift files, no app assets, no asset catalogs, no localization, no tests, no Watch, Widget, Live Activity, project files, production code, Figma canvas writes, or Figma asset exports

Pending work:

- Run a QA-only normalization pass to derive transparent masks and label base bodies before any app import.

## 2026-05-05 - Human Body Overlay Pilot

Scope:

- QA-only licensed Figma Human Body base + overlay export feasibility pass.

Files changed:

- Created `docs/figma-exports/human-body-overlay-pilot/` with four base SVG candidates, 16 transparent overlay SVG candidates, `README.md`, and `human-body-overlay-manifest.json`.
- Updated `docs/migration-progress-log.md`.

Figma inspected:

- Human Body large anatomy groups `9192:5535`.
- Anatomy Muscle `8673:69673`.

Verification run:

- Manifest parse, README keyword search, QA folder listing, forbidden target diff check, and `git diff --check`.

Intentionally not changed:

- No Swift, asset catalogs, project files, localization, tests, widgets, watch targets, or production runtime assets.

Pending work:

- Rork visual QA and Xcode vector/template rendering QA before any app import.

## 2026-05-06 - Human Body Overlay Xcode Smoke

Scope:

- QA-only asset-rendering smoke pass for the licensed Human Body overlay candidates, using static SVG checks plus local vector PDF conversion on Windows.

Files changed:

- Created `docs/figma-exports/human-body-overlay-xcode-smoke/` with copied smoke SVGs, normalized SVG variants, vector PDF candidates, a docs-only scratch `.xcassets` package, `README.md`, and `xcode-smoke-manifest.json`.
- Updated `docs/migration-progress-log.md`.

Verification run:

- Folder listing, manifest parse, README/manifest keyword search, forbidden production target diff check, and `git diff --check`.

Intentionally not changed:

- No Swift files, production asset catalogs, project files, localization, tests, fonts, Watch, Widget, or app runtime assets.

Pending work:

- macOS/Xcode validation remains required; recommended next path is B, convert to vector PDF first, then import.

## 2026-05-06 - Human Body Overlay Runtime Pilot Import

Scope:

- Imported the minimal approved Human Body vector PDF pilot set into the app asset catalog for DEBUG/Rork rendering QA only.
- Reused the existing DEBUG Design System Lab as the isolated preview surface for base plus overlay composition.

Files changed:

- `ios/STRQ/Assets.xcassets`
- `ios/STRQ/Views/Debug/STRQDesignSystemPreviewView.swift`
- `docs/migration-progress-log.md`

Rendering approach:

- Base body PDFs are asset-catalog image sets with vector preservation and original rendering intent.
- Overlay PDFs are asset-catalog image sets with vector preservation and template rendering intent.
- The DEBUG lab composes SwiftUI `Image` layers in a shared `ZStack` frame using `.renderingMode(.template)` and `.foregroundStyle(...)` for overlays.

Tint/template findings:

- Static import uses template-rendered overlay assets and SwiftUI template tint calls.
- This Windows pass cannot prove Xcode asset rendering, SwiftUI template tint behavior, or runtime color output. No `.colorMultiply(...)` fallback was added because template tint failure has not been observed in Rork/macOS runtime QA yet.

Overlay alignment findings:

- Source smoke findings indicate each overlay PDF keeps the same viewBox-derived dimensions as its matching base PDF.
- The DEBUG lab renders base and overlay images in the same SwiftUI frame for visual alignment inspection. Runtime alignment still requires Rork visual QA.

Intentionally not changed:

- No onboarding, exercise library, exercise detail, progress, coach, model, service, persistence, analytics, localization, RevenueCat/store, Widget, Watch, Live Activity, project file, or test integration.

Pending work:

- Rork runtime visual QA of the DEBUG Design System Lab Human Body Overlay Pilot section.
- macOS/CI build validation remains required; this Windows pass does not claim `xcodebuild` or Xcode asset-rendering validation.

## 2026-05-06 - Human Body Overlay Component Plan

Scope:

- Created a docs-only production component plan for turning the licensed Human Body base plus vector PDF overlays into a reusable STRQ component for Onboarding, Exercise Info, Exercise Library, Progress, and Coach explanations.
- Selected exactly one first production integration target: Exercise Info primary/secondary muscle display.

Files changed:

- `docs/strq-human-body-overlay-component-plan.md`
- `docs/migration-progress-log.md`

Intentionally not changed:

- No Swift files, app assets, asset catalogs, project files, localization files, tests, fonts, Watch, Widget, or production runtime assets.

Pending work:

- Implement only the Exercise Info production component target in a later scoped pass after Rork QA expectations are ready.

## 2026-05-06 - Human Body Overlay Color Role Clarification

Scope:

- Updated the Human Body Overlay component plan to treat selected, primary, secondary, trained, undertrained, warning, overload, recovery caution, and inactive as semantic roles rather than final color decisions.
- Clarified that the current debug selected teal, warning amber, and danger pink/red examples are temporary test states and that final colors should be tokenized and visually QA'd later in real screens.

Files changed:

- `docs/strq-human-body-overlay-component-plan.md`
- `docs/migration-progress-log.md`

Intentionally not changed:

- No Swift files, app assets, asset catalogs, project files, localization files, tests, fonts, Watch, Widget, or production runtime assets.

## 2026-05-06 - Exercise Info Human Body Overlay Pilot

Scope:

- Added the first controlled production Human Body Overlay pilot only to the Exercise Detail Target section.
- Replaced the simple local body-map drawing in that section with a display-only base plus overlay vector PDF composition while preserving the existing primary and secondary muscle text list as the exact source of truth.
- Kept the pilot local to `ExerciseDetailView` to avoid project-file changes and avoid introducing a global anatomy architecture before full asset coverage exists.

Files changed:

- `ios/STRQ/Views/ExerciseDetailView.swift`
- `docs/migration-progress-log.md`

Implementation:

- Added a private local `STRQHumanBodyExerciseTargetView` helper plus local canvas, layer, asset, role, and tone helpers.
- Used a SwiftUI `ZStack` with original-rendered base PDF images and template-tinted overlay PDF images.
- Primary overlays use a controlled teal/blue treatment at stronger opacity; secondary overlays use the same hue family at lower opacity.

Muscle mapping and fallback:

- Direct pilot coverage: Chest, Shoulders, broad Back/Lats/Lower Back, and Glutes.
- Current runtime mapping uses `STRQHumanBodyMaleFrontBase`, `STRQHumanBodyMaleFrontChestOverlay`, `STRQHumanBodyMaleFrontShoulderOverlay`, `STRQHumanBodyMaleBackBase`, `STRQHumanBodyMaleBackBackOverlay`, `STRQHumanBodyFemaleBackBase`, and `STRQHumanBodyFemaleBackGluteOverlay`.
- Female front chest assets remain imported but are not selected in this exercise-info pilot because the male front canvas is the only available front canvas with both Chest and Shoulder overlays.
- Unsupported muscles fall back to a neutral body canvas and the exact primary/secondary muscle list already shown in the screen.

Verification run:

- `git status --short --branch`
- `git diff --name-only`
- `git diff -- ios/STRQ/Views docs/migration-progress-log.md`
- `rg -n "HumanBody|STRQHumanBody|Exercise|Muscle|primary|secondary|ZStack|renderingMode|foregroundStyle" ios/STRQ/Views`
- `rg -n "STRQHumanBodyMaleFrontBase|STRQHumanBodyMaleFrontChestOverlay|STRQHumanBodyMaleFrontShoulderOverlay|STRQHumanBodyMaleBackBase|STRQHumanBodyMaleBackBackOverlay|STRQHumanBodyFemaleFrontBase|STRQHumanBodyFemaleFrontChestOverlay|STRQHumanBodyFemaleBackBase|STRQHumanBodyFemaleBackGluteOverlay" ios/STRQ`
- `rg -n "Sandow" ios/STRQ/Views ios/STRQ/ContentView.swift`
- `git diff --name-only -- ios/STRQ/Assets.xcassets ios/STRQ/ViewModels ios/STRQ/Services ios/STRQ/Models ios/STRQ/Localizable.xcstrings ios/STRQWidget ios/STRQWatch ios/STRQ.xcodeproj`
- `git diff --check`

Intentionally not changed:

- No assets, project files, models, services, view models, persistence, analytics, localization, tests, fonts, Widget, Watch, Live Activity, onboarding, progress, coach, active workout, workout execution, or plan generation files.

Pending work:

- Rork QA should inspect Exercise Info with covered primary, covered primary plus covered secondary, and missing-overlay fallback exercises.
- macOS/CI build validation remains required; this pass ran on Windows.

## 2026-05-06 - Exercise Detail Anatomy Secondary Overlay Semantics

Scope:

- Refined only the Exercise Detail Human Body anatomy overlay selection so secondary support concepts stay in the text list without coloring the body map.
- Kept the existing Exercise Detail Anatomy V1 coverage assets, colors, legend, navigation, exercise data, and primary/secondary text rows unchanged.

Files changed:

- `ios/STRQ/Views/ExerciseDetailView.swift`
- `docs/migration-progress-log.md`

Code inspected:

- Confirmed Exercise Detail renders the primary and secondary muscle text directly from `exercise.primaryMuscle` and `exercise.secondaryMuscles`, independently of body overlay coverage.
- Confirmed the anatomy overlay mapping/filtering is local to `STRQHumanBodyExerciseTargetScene` in `ExerciseDetailView.swift`.

Implementation:

- Added secondary overlay eligibility filtering before layer merging.
- Filtered support-only secondary concepts including Core Stability/stability/stabilizer/bracing/grip/balance/support terms from visual overlays while preserving text rows.
- Prevented lower-body primary targets from picking up secondary arm/forearm overlays that are typically holding/support demands, such as Zercher Squat biceps.
- Stopped mapping Core Stability itself to the Abs overlay; direct core visuals now come from explicit Abs, Obliques, or Rotation targets.
- Kept existing compatible direct muscle overlays for chest/shoulder, back/lats, glutes, hamstrings, quads, biceps/forearms, and direct abs/oblique/rotation targets.

Intentionally not changed:

- No assets, models, services, view models, persistence, analytics, localization, workout execution, plan generation, onboarding, Coach, Progress, Profile, RevenueCat/store, HealthKit, notification scheduling, tests, Widget, Watch, Live Activity, fonts, or Xcode project files.
- No exercise data, primary/secondary text content, exercise navigation, favorites, search/filter, add/replace/start workout behavior, colors, legend, or asset names changed.
- No Sandow references introduced.

Pending work:

- Rork QA should visually inspect Zercher Squat plus Bench Press, Pull-Up/Row, RDL, Glute Kickback, Curl, Squat, and direct core examples.
- macOS or CI build validation remains required before shipping; this pass ran on Windows.

## 2026-05-06 - Human Body Overlay Exercise Detail V1 Coverage

Scope:

- Expanded the Exercise Detail Human Body Overlay from the first pilot into a controlled V1 coverage pass for common primary and secondary exercise targets.
- Imported only male front/back vector PDF overlays needed by the Exercise Detail V1 mapping, while keeping existing female pilot assets unused in Exercise Detail to avoid body-variant switching.
- Preserved the exact primary and secondary text list as the target source of truth and removed the debug-like partial-coverage helper copy.

Files changed:

- `ios/STRQ/Assets.xcassets`
- `ios/STRQ/Views/ExerciseDetailView.swift`
- `ios/STRQ/Views/Debug/STRQDesignSystemPreviewView.swift`
- `docs/figma-exports/human-body-overlay-v1-import/README.md`
- `docs/figma-exports/human-body-overlay-v1-import/v1-import-manifest.json`
- `docs/migration-progress-log.md`

Figma inspected:

- Used Figma read-only in Licensed Source Mode for Human Body source `9192:5535`.
- Missing V1 overlays were derived from existing licensed full-body SVG source and verified with Figma vector node metadata.

Implementation:

- Exercise Detail now uses a consistent default male anatomy variant.
- Primary muscles choose orientation: front for chest, shoulders, biceps, forearms, abs/core, upper leg/quads, and lower leg/tibialis; back for back/lats/lower back, traps, triceps, glutes, hamstrings, and calves.
- Secondary overlays render only when compatible with the primary muscle orientation and available in the V1 male asset set.
- Local mapping now covers Chest, Back/Lats/Lower Back, Shoulder, Bicep, Tricep, Forearm, Abs/Core/Obliques/Rotation, Glute, Upper Leg/Quads, Hamstring, Calf, Trap, and Lower Leg/Tibialis.

Intentionally not changed:

- No models, services, view models, persistence, analytics, localization, workout execution, plan generation, onboarding, Coach, Progress, Profile, RevenueCat/store, HealthKit, notification scheduling, tests, Widget, Watch, Live Activity, fonts, or Xcode project files.
- No Hand or Neck overlays were imported.
- No SVG files were imported into the production asset catalog.

Pending work:

- Rork QA should inspect Exercise Detail examples for chest/shoulder, back/lats, glutes, abs/core, upper leg/quads, hamstrings, biceps/triceps, calves/lower leg, and unsupported/non-compatible secondary text fallback.
- Rork QA should also inspect DEBUG Design System Lab Human Body Overlay V1 samples.
- macOS or CI build validation remains required before shipping; this pass ran on Windows.

## 2026-05-06 - Exercise Detail Anatomy Line Preservation

Scope:

- Refined only the Exercise Detail Human Body anatomy rendering so highlighted muscle overlays preserve more of the underlying body and muscle line definition.
- Kept the local `STRQHumanBodyExerciseTargetView` helper as the implementation boundary and avoided any anatomy asset, mapping, data, or production flow changes.

Files changed:

- `ios/STRQ/Views/ExerciseDetailView.swift`
- `docs/migration-progress-log.md`

Implementation:

- Kept the neutral base body as the first image layer.
- Reduced primary and secondary overlay alpha in the local target role helper.
- Reused the same base body asset as a subtle top line-art pass above colored overlays, using original rendering with a local `.darken` blend treatment so dark anatomical detail can read through large highlighted regions.
- Kept the line-art pass conditional on visible overlay layers so neutral fallback anatomy remains unchanged.

Opacity tuning:

- Primary overlay opacity changed from `0.94` to `0.84`.
- Secondary overlay opacity changed from `0.46` to `0.36`.
- The legend now reads from the same local role opacity values used by the rendered overlays.

Intentionally not changed:

- No muscle mapping, primary/secondary text lists, exercise data, orientation strategy, navigation, favorites, search/filter, workout add/replace/start, plan generation, workout execution, analytics, persistence, localization, or protected production flows were changed.
- No assets, models, services, view models, revenue/store files, HealthKit, notifications, tests, Widget, Watch, Live Activity, fonts, or Xcode project files were changed.
- No Sandow references were introduced.

Pending work:

- Rork QA should inspect large highlighted regions such as Back/Lats, Upper Leg/Quads, Abs, and Hamstrings to confirm they no longer read as flat solid areas while primary remains stronger than secondary.
- macOS or CI build validation remains required before shipping; this pass ran on Windows.

## 2026-05-06 - Exercise Detail Anatomy Large Overlay Tuning

Scope:

- Refined only the local Exercise Detail Human Body anatomy rendering for large highlighted regions after Rork QA found Back/Lats still slightly too flat.
- Preserved all anatomy mapping, filtering, text lists, assets, data, layout, and production flows.

Files changed:

- `ios/STRQ/Views/ExerciseDetailView.swift`
- `docs/migration-progress-log.md`

Implementation:

- Kept the neutral base body, colored overlay layers, and conditional top line-art pass.
- Added a local render-only `isLargeRegionOverlay` distinction for existing large anatomy mask assets: Abs, Upper Leg, Back, Glute, and Hamstring.
- Large-region overlays now use slightly lower local opacity than smaller overlays while preserving the existing primary-over-secondary hierarchy.
- Increased the local top line-art preservation pass from `0.38` to `0.42` using the existing `.darken` treatment.

Opacity tuning:

- Small primary overlays remain `0.84`; large primary overlays use `0.78`.
- Small secondary overlays remain `0.36`; large secondary overlays use `0.32`.

Intentionally not changed:

- No muscle mapping, secondary filtering rules, primary/secondary text lists, orientation strategy, exercise data, navigation, favorites, search/filter, workout add/replace/start behavior, plan generation, analytics, persistence, localization, or protected production flows were changed.
- No assets, models, services, view models, revenue/store files, HealthKit, notifications, tests, Widget, Watch, Live Activity, fonts, or Xcode project files were changed.
- No Sandow references were introduced.

Pending work:

- Rork QA should re-check Back/Lats specifically, plus Chest, Quads/Upper Leg, Glutes, Hamstrings, and Abs to confirm the large-region tuning improves definition without making target highlights too faint.
- macOS or CI build validation remains required before shipping; this pass ran on Windows.

## 2026-05-06 - Exercise Info Anatomy V1 Freeze Report

Scope:

- Created a docs-only freeze report accepting the Exercise Detail Human Body Overlay as a V1 feature candidate with caveats, covering Rork QA examples, support/stabilizer text-only behavior, deferred work, regression guardrails, and release-readiness.

Files changed:

- `docs/exercise-info-anatomy-v1-freeze-report.md`
- `docs/migration-progress-log.md`

Intentionally not changed:

- No Swift files, assets, models, services, view models, analytics, localization, project files, tests, fonts, Widget, Watch, Live Activity, workout behavior, plan behavior, or runtime behavior.

Pending work:

- macOS/CI build validation and continued Rork QA remain required before final release sign-off.

## 2026-05-06 - Progress Analytics Signature Direction Plan

Scope:

- Created a docs-only Progress / Analytics direction plan defining Progress as STRQ's premium proof surface, mapping current Progress inventory, licensed Figma chart/progress/report primitives, information architecture, visual language, guardrails, phased implementation, and exactly one immediate next prompt.

Files changed:

- `docs/progress-analytics-signature-direction-plan.md`
- `docs/migration-progress-log.md`

Figma inspected:

- Used [@Figma](plugin://figma@openai-curated) read-only in Licensed Source Mode for Chart `9129:26029`, Progress `9129:207997`, Bonus Dashboard `5643:11291`, Activity Tracker `11611:134946`, and Dark Home / Smart Fitness Metrics `11604:62728`.

Intentionally not changed:

- No Swift files, assets, models, services, view models, analytics, localization, project files, tests, fonts, Widget, Watch, Live Activity, or runtime behavior.

Pending work:

- Recommended next prompt is a docs-only current Progress risk/state inventory before any visual shell or chart implementation pass.

## 2026-05-06 - Progress Current State Risk Inventory

Scope:

- Created a docs-only current Progress risk and state inventory before any Progress redesign or Swift implementation.
- Statically mapped the Progress tab entry, `ProgressAnalyticsView`, `SessionHistoryView`, chart usage, empty states, data sources, routes, protected behavior, low-risk candidates, high-risk areas, and exactly one recommended next prompt.

Files changed:

- `docs/progress-current-state-risk-inventory.md`
- `docs/migration-progress-log.md`

Code inspected:

- `ios/STRQ/ContentView.swift`
- `ios/STRQ/Views/ProgressAnalyticsView.swift`
- `ios/STRQ/Views/SessionHistoryView.swift`
- `ios/STRQ/ViewModels/AppViewModel.swift`
- `ios/STRQ/Services/WorkoutController.swift`
- related model/service files referenced by Progress state and data calculations

Intentionally not changed:

- no Swift files, assets, project files, models, services, view models, analytics files, localization, tests, fonts, Watch, Widget, Live Activity, or production runtime behavior

Pending work:

- Recommended next prompt is a docs-only Progress Rork screenshot/state capture checklist before any shell-only Swift pass.

## 2026-05-06 - Progress Proof Surface Recomposition

Scope:

- Rebuilt `ProgressAnalyticsView` as a premium proof/report surface while staying view-layer-only.
- Reorganized the top of Progress around proof maturity, evidence signal, supporting proof metrics, an analytical section switcher, and more honest low-data presentation.
- Preserved Progress data sources, calculations, routes, analytics, persistence, models, services, view models, localization files, assets, project files, and app flows outside Progress.

Files changed:

- `ios/STRQ/Views/ProgressAnalyticsView.swift`
- `docs/migration-progress-log.md`

Figma inspected:

- Used [@Figma](plugin://figma@openai-curated) read-only in Licensed Source Mode.
- Inspected Chart `9129:26029`, Progress `9129:207997`, Bonus Dashboard `5643:11291`, Activity Tracker `11611:134946`, and Dark Home / Smart Fitness Metrics `11604:62728`.
- Adapted chart/report container anatomy, compact trend-label grammar, progress/ring maturity anatomy, metric proof-point density, activity early-state patterns, and analytical segmented-control structure.
- Did not copy source branding, source text, health-app assumptions, assets, or orange CTA styling.

Code inspected:

- `ios/STRQ/Views/ProgressAnalyticsView.swift`
- `ios/STRQ/ViewModels/AppViewModel.swift` read-only for existing maturity, strength-chart, body, recovery, workout-history, and muscle-balance gates.
- `ios/STRQ/Utilities/ForgeTheme.swift` and `ios/STRQ/Utilities/STRQPalette.swift` read-only for existing local token behavior.

Implementation:

- Replaced the generic hero with a proof summary showing progress maturity, trustworthy/current context, and existing key values.
- Reframed "What's improving" into an evidence signal with "Trust now" and "Still forming" language.
- Rebuilt the metric strip as compact supporting proof points instead of equal-weight dashboard tiles.
- Replaced the orange selected section treatment with a steel/navy analytical segmented selector.
- Reworded low-data Strength, Body, and Volume states around baseline forming, first signal, building pattern, and trustworthy evidence.
- Reordered the Volume section so Weekly Workouts remains visible while Muscle Balance waits for a trustworthy comparison baseline.
- Added a view-only Muscle Balance confidence gate so insufficient or zero comparison volume shows a baseline-forming state instead of presenting misleading `-100%` labels as a real negative conclusion.

Verification run:

- `git status --short --branch`
- `git diff --name-only`
- `git diff -- ios/STRQ/Views/ProgressAnalyticsView.swift docs/migration-progress-log.md`
- `rg -n "Progress|Proof|Strength|Body|Volume|selected|workouts logged|What's improving|Estimated 1RM|Recovery Trend|Muscle Balance|Weekly Workouts|Recent Workouts|Consistency|Chart|baseline|signal|foregroundStyle|orange|accentGradient" ios/STRQ/Views/ProgressAnalyticsView.swift`
- `rg -n "Sandow" ios/STRQ/Views ios/STRQ/ContentView.swift`
- `git diff --name-only -- ios/STRQ/ViewModels ios/STRQ/Services ios/STRQ/Models ios/STRQ/Assets.xcassets ios/STRQ/Localizable.xcstrings ios/STRQWidget ios/STRQWatch ios/STRQ.xcodeproj ios/STRQTests`
- `git diff --check`

Intentionally not changed:

- No chart math, workout/session history data, bodyweight/recovery calculations, muscle-volume generation, PR generation, time-range logic, navigation/routes, analytics, persistence, models, services, view models, controllers, HealthKit, localization catalogs, assets, project files, tests, fonts, Widget, Watch, Live Activity, or other screens were changed.
- No fake values were added.
- No runtime source-brand references were introduced.

Pending work:

- Rork QA should capture 0, 2, and 3 workout Progress states plus an established state with populated charts.
- macOS or CI build validation remains required before shipping; this pass ran on Windows.

Warnings:

- Muscle Balance confidence is handled view-only in this pass. The underlying incomplete/zero muscle-volume source behavior remains intentionally deferred because fixing it would require model/controller/data-generation changes outside the allowed scope.

## 2026-05-06 - Progress Chart & Section Content Recomposition

Scope:

- Reworked the lower `ProgressAnalyticsView` modules so charts, recent workout proof, consistency, recovery/body context, weekly rhythm, and balance states read as calm evidence modules instead of generic dashboard cards.
- Kept the prior Proof Summary/top-area direction intact except for local cohesion through shared evidence-module anatomy.
- Preserved calculations, data sources, selected section state, navigation/routes, analytics, persistence, model/service behavior, localization files, assets, project files, tests, and app flows outside Progress.

Files changed:

- `ios/STRQ/Views/ProgressAnalyticsView.swift`
- `docs/migration-progress-log.md`

Figma inspected:

- Used [@Figma](plugin://figma@openai-curated) read-only in Licensed Source Mode.
- Inspected Chart `9129:26029` and adapted chart base layout, line chart shell, bar chart shell, plot surface, trend label, and legend anatomy.
- Inspected Progress `9129:207997` and adapted progress/bar confidence structure for baseline-forming modules.
- Inspected Bonus Dashboard `5643:11291` descendants `11527:73138` and `11527:73069` for dark report-card anatomy, compact metric proof cards, chart headers, badges, and mini bar rhythm.
- Inspected Activity Tracker `11611:134946` descendants `11611:135087` and `11611:135104` for low-data panel structure and activity/consistency grid anatomy.
- Inspected Dark Home / Smart Fitness Metrics `11604:62728` descendants `11604:62757` and `11604:62839` for metric card density, context rows, and progress-bar report modules.
- Did not copy source branding, source text, raw dashboard layouts, health-app assumptions, assets, or orange/pro/violet styling.

Code inspected:

- `ios/STRQ/Views/ProgressAnalyticsView.swift` fully.
- `ios/STRQ/ViewModels/AppViewModel.swift` read-only for existing strength, body, recovery, workout-history, weekly-session, muscle-balance, and low-data gates.
- `ios/STRQ/Utilities/STRQPalette.swift` and `ios/STRQ/Utilities/ForgeTheme.swift` read-only for existing color and formatting behavior.

Implementation:

- Added local evidence/report shell helpers inside `ProgressAnalyticsView` for module containers, evidence headers, badges, chips, and plot shells.
- Rebuilt Estimated 1RM low-data and populated chart presentation around baseline-forming proof while keeping the same strength data and line chart calculations.
- Rebuilt Recent Workouts as dated training-evidence rows while preserving the completed-session source and `SessionHistoryView` route.
- Rebuilt 28-Day Consistency as a premium proof grid with neutral open days and no invented streak or negative framing.
- Rebuilt Body Baseline, Goal Pace, Body Weight, Recovery Trend, and Nutrition shells as context/report modules while preserving displayed values and calculations.
- Rebuilt Weekly Workouts, Muscle Balance, Muscle Balance baseline, and Movement Balance shells around rhythm proof and trustworthy-balance language while preserving the existing view-only confidence gate and all volume data generation.

Verification run:

- `git status --short --branch`
- `git diff --name-only`
- `git diff -- ios/STRQ/Views/ProgressAnalyticsView.swift docs/migration-progress-log.md`
- `rg -n "Estimated 1RM|Recent Workouts|28-Day Consistency|Recovery Trend|Body Baseline|Volume Signals|Weekly Workouts|Muscle Balance|Movement Balance|baseline|proof|signal|Chart|selected|SessionHistory|foregroundStyle|orange|accentGradient" ios/STRQ/Views/ProgressAnalyticsView.swift`
- `rg -n "Sandow" ios/STRQ/Views ios/STRQ/ContentView.swift`
- `git diff --name-only -- ios/STRQ/ViewModels ios/STRQ/Services ios/STRQ/Models ios/STRQ/Assets.xcassets ios/STRQ/Localizable.xcstrings ios/STRQWidget ios/STRQWatch ios/STRQ.xcodeproj ios/STRQTests`
- `git diff --check`

Intentionally not changed:

- No chart calculations, workout/session history data, workout count logic, bodyweight/recovery calculations, muscle-volume generation, PR generation, time-range logic, navigation/routes/actions, analytics, persistence, models, services, view models, controllers, HealthKit behavior, localization catalogs, assets, project files, tests, fonts, Widget, Watch, Live Activity, or other screens were changed.
- No fake values were added.
- No runtime source-brand references were introduced.

Pending work:

- Rork QA should verify low-data, partial-data, and fully populated Progress states, especially Estimated 1RM baseline, Recovery Trend, Weekly Workouts, and Muscle Balance trust states.
- macOS or CI build validation remains required before shipping; this pass ran on Windows.

Warnings:

- Any deeper improvement to muscle-volume source fidelity, recovery interpretation, or body-baseline trust rules remains deferred because it would require model/service/calculation changes outside the allowed scope.

## 2026-05-06 - Progress V2 DEBUG Prototype

Scope:

- Added a DEBUG-only Progress V2 prototype surface for owner/Rork review using local prototype data only.
- Preserved the production Progress tab, Progress calculations, workout history, models, services, persistence, analytics, localization, assets, project files, tests, Widget, Watch, and Live Activity.

Files changed:

- `ios/STRQ/Views/Debug/ProgressV2PrototypeView.swift`
- `ios/STRQ/Views/Debug/STRQDesignSystemPreviewView.swift`
- `docs/migration-progress-log.md`

Figma inspected:

- Used [@Figma](plugin://figma@openai-curated) in Licensed Source Mode.
- Inspected Chart `9129:26029`, Progress `9129:207997`, Activity Tracker `11611:134946`, Dark Home / Smart Fitness Metrics `11604:62728`, and Bonus Dashboard page `5643:11291` with targeted subnodes `11527:73138`, `11527:73069`, `11611:135104`, and `11611:135087`.
- Adapted chart-first report anatomy, line/area/bar chart grammar, progress ring maturity, metric density, calendar rhythm grid, low-data empty-state honesty, and evidence/feed structure.
- Did not copy source branding, source text, source assets, raw screen layout, orange CTA styling, Pro/violet styling, or production data wiring.

Implementation:

- Created baseline, forming, and established prototype states behind a local DEBUG selector.
- Added graph-first hero, varied proof area, rhythm grid, strength/volume trend, muscle distribution concept, and recent evidence timeline.
- Kept all demo/prototype data inside the new DEBUG file.
- Integrated the prototype into the DEBUG Design System Lab as `Progress V2 Prototype`.

Verification:

- Static verification only on Windows; no `xcodebuild` was run.
- macOS/CI build validation and Rork visual QA remain required.

## 2026-05-06 - Progress V3 Source-Locked Concept Lab

Scope:

- Added a DEBUG-only Progress V3 Concept Lab using local prototype/demo data only.
- Built three source-locked concept directions: Metric Insight Report, Progress Goal / Rhythm System, and Training Distribution / Muscle Proof.
- Preserved production Progress, production navigation, models, services, persistence, analytics, localization, assets, project files, tests, Widget, Watch, and Live Activity.

Files changed:

- `ios/STRQ/Views/Debug/ProgressV3ConceptLabView.swift`
- `ios/STRQ/Views/Debug/STRQDesignSystemPreviewView.swift`
- `docs/progress-v3-figma-source-map.md`
- `docs/migration-progress-log.md`

Figma inspected:

- Used [@Figma](plugin://figma@openai-curated) read-only in Licensed Source Mode.
- Inspected all mandatory user-selected nodes: `11604:63074`, `11604:63099`, `11604:63115`, `11604:63236`, `11604:63379`, `11604:63397`, `11604:63410`, `11604:63465`, `11604:63511`, `11604:63616`, `11604:63709`, `11604:63679`, `11604:63724`, `11604:64200`, `11604:64937`, and `11604:66184`.
- Also inspected helpful chart/progress/dashboard/activity primitives recorded in `docs/progress-v3-figma-source-map.md`.

Implementation:

- Added local concept and data-state switchers for Baseline, Forming, and Established states.
- Kept all demo data private inside the DEBUG prototype file.
- Integrated the lab into the existing DEBUG Design System Lab as `Progress V3 Concept Lab`.

Pending work:

- Rork QA should screenshot all three concepts across all three states.
- macOS/CI build validation remains required; this pass ran on Windows.

## 2026-05-07 - Progress V4 Hybrid Candidate

Scope:

- Added a DEBUG-only Progress V4 Hybrid Candidate using local prototype/demo data only.
- Combined Concept C muscle coverage and training distribution with Concept B weekly rhythm and a restrained Concept A strength trend detail.
- Kept production Progress, production navigation, models, services, persistence, analytics, localization, assets, project files, tests, Widget, Watch, and Live Activity unchanged.

Files changed:

- `ios/STRQ/Views/Debug/ProgressV4HybridCandidateView.swift`
- `ios/STRQ/Views/Debug/STRQDesignSystemPreviewView.swift`
- `docs/progress-v3-figma-source-map.md`
- `docs/migration-progress-log.md`

Figma inspected:

- Used [@Figma](plugin://figma@openai-curated) read-only in Licensed Source Mode.
- Re-inspected strongest V4 source nodes: `11604:64937`, `11604:63724`, `11604:63236`, and `11604:66184`.
- Used distribution/level, rhythm grid, goal cadence, chart-detail, and history/evidence pacing patterns without importing Figma assets.

Implementation:

- Added Baseline, Forming, and Established local states.
- Built a front/back muscle coverage hero, weekly rhythm grid, one strength trend chart, training mix distribution, and recent evidence timeline.
- Integrated the candidate into the DEBUG Design System Lab as `Progress V4 Hybrid Candidate`.

Pending work:

- Rork QA should screenshot all three V4 states.
- macOS/CI build validation remains required; this pass ran on Windows.

## 2026-05-07 - Progress V4 Hybrid Candidate Refinement

Scope:

- Refined only the DEBUG-only Progress V4 Hybrid Candidate toward a cleaner production-candidate direction.
- Preserved the production Progress tab, production navigation, models, services, persistence, analytics, localization, assets, project files, tests, Widget, Watch, and Live Activity.
- Kept all V4 data local to the DEBUG prototype and did not wire real data.

Files changed:

- `ios/STRQ/Views/Debug/ProgressV4HybridCandidateView.swift`
- `docs/progress-v3-figma-source-map.md`
- `docs/migration-progress-log.md`

Figma inspected:

- Used [@Figma](plugin://figma@openai-curated) read-only in Licensed Source Mode.
- Re-inspected `11604:63115`, `11604:63236`, `11604:63724`, `11604:64937`, `11604:66184`, `9129:26029`, and `9129:207997`.
- Adapted report hierarchy, chart skeleton grammar, progress/bar baseline states, rhythm grids, and evidence/history pacing without copying source text, source branding, or assets.

Implementation:

- Changed the in-surface header to product language and separated the Training Distribution title from its status chip to avoid truncation pressure.
- Replaced unexplained compact `P / U / L / C / H` training-mix labels with understandable Push, Pull, Legs, Core, and Posterior labels.
- Replaced low/high read semantics with Locked, Baseline forming, Early signal, Readable, and High confidence semantics.
- Added more intentional baseline visuals through faint body coverage guides, skeleton coverage bars, and locked trend language.
- Softened forming state color and copy so it reads as a constructive early signal rather than a warning state.
- Preserved established teal/green coverage, rhythm, and high-confidence trend hierarchy.
- Refined Recent Evidence from a plain list toward dated proof rows inside the timeline.

Intentionally not changed:

- No `ProgressAnalyticsView.swift`.
- No production Progress behavior, route, data source, model, service, analytics, persistence, localization, asset, token, project, test, Widget, Watch, or Live Activity change.
- No Sandow references were introduced.

Pending work:

- Rork QA should re-check Baseline, Forming, and Established V4 screenshots, especially Training Distribution title wrapping, the mix rail labels, baseline intentionality, forming warmth, and established readability.
- macOS or CI build validation remains required before any production planning; this pass ran on Windows.

## 2026-05-07 - Progress V4 Product Innovation Roadmap

Scope:

- Created a docs-only production roadmap for turning the DEBUG-only Progress V4 Hybrid Candidate into a phased STRQ Progress feature set, covering product innovation, Release V1 scope, 2027 differentiators, data contracts, monetization, production phases, risks, guardrails, and exactly one next prompt.

Files changed:

- `docs/progress-v4-product-innovation-production-roadmap.md`
- `docs/migration-progress-log.md`

Figma inspected:

- Used [@Figma](plugin://figma@openai-curated) read-only in Licensed Source Mode for compact metadata inspection of `11604:64937`, `11604:63724`, `11604:63236`, `11604:66184`, `9129:26029`, and `9129:207997`, alongside the existing V3/V4 source-map docs.

Intentionally not changed:

- No Swift files, assets, project files, models, services, view models, analytics files, localization, tests, fonts, Widget, Watch, Live Activity, or runtime behavior.

Pending work:

- Recommended next prompt is a docs-only real data contract audit for Progress V4 modules before any production skeleton or data wiring.

## 2026-05-07 - Progress V4 Real Data Contract Audit

Scope:

- Created `docs/progress-v4-real-data-contract-audit.md` to map Progress V4 modules to current STRQ data sources and confirm the production blocker around `ProgressEntry.muscleGroupVolume`.

Files changed:

- `docs/progress-v4-real-data-contract-audit.md`
- `docs/migration-progress-log.md`

Verification:

- Ran docs-only diff scope, iOS tree no-change check, required audit-term search, and `git diff --check`; no Swift/assets/project/localization/test/runtime changes.

Pending work:

- Recommended next step is C: fix/build the muscle coverage data contract first as a read-only derivation before any V4 production UI wiring.

## 2026-05-07 - Progress Muscle Coverage Data Contract V1

Scope:

- Implemented the first real Progress muscle coverage data contract by populating existing `ProgressEntry.muscleGroupVolume` during workout completion from completed workout sets and exercise muscle metadata.
- Added a centralized calculator for per-muscle coverage, broad push/pull/legs/core/posterior category distribution, secondary-muscle weighting, exposure fallback behavior, unresolved exercise reporting, and future confidence-state vocabulary.
- Preserved Progress V4 as DEBUG/prototype-only and did not wire any V4 production UI.

Files changed:

- `ios/STRQ/Services/ProgressMuscleCoverageCalculator.swift`
- `ios/STRQ/Services/WorkoutController.swift`
- `ios/STRQ/ViewModels/AppViewModel.swift`
- `ios/STRQTests/STRQTests.swift`
- `docs/progress-muscle-coverage-data-contract-v1.md`
- `docs/migration-progress-log.md`

Code inspected:

- `ProgressEntry`, `WorkoutSession`, `ExerciseLog`, and `SetLog` in `ios/STRQ/Models/WorkoutSession.swift`
- `Exercise`, `MovementPattern`, and exercise metadata fields in `ios/STRQ/Models/Exercise.swift`
- `MuscleGroup` in `ios/STRQ/Models/MuscleGroup.swift`
- workout completion in `ios/STRQ/Services/WorkoutController.swift`
- `ExerciseLibrary` resolution and imported exercise fallback
- `AppViewModel.muscleBalance` and `weeklyVolumeByMuscle`
- `ProgressAnalyticsView` Muscle Balance gate and movement-balance readers
- persistence through `PersistedAppState`, `ProgressEntry` decoding, and `SnapshotBuilder`
- existing Smart Volume and Weekly Review muscle-balance consumers

Implementation:

- Weighted completed sets use existing loaded volume (`weight * reps`) as the contribution value.
- Completed exercises with zero loaded volume fall back to completed set exposure points.
- Primary muscles receive `1.0` contribution and secondary muscles receive `0.35`.
- `ProgressEntry.muscleGroupVolume` stores stable per-muscle `MuscleGroup.rawValue` keys.
- Existing Progress display buckets aggregate the new exact per-muscle keys while retaining compatibility with older aggregate keys.
- Missing or unresolved exercise metadata is skipped safely and reported by the calculator result.

Intentionally not changed:

- No Progress V4 production integration.
- No `ProgressAnalyticsView.swift` edit.
- No Progress UI redesign, navigation, route, analytics, localization, asset, project, Widget, Watch, Live Activity, HealthKit, plan generation, workout execution, or exercise metadata changes.
- No demo/mock data and no historical workout backfill.

Pending work:

- macOS or CI build validation is required because this pass ran on Windows.
- Rork QA should verify Muscle Balance after real completed workouts, especially low-data and four-plus-workout states.
- Future V4 work should use the documented V1 contract to build read-only weekly and 4-week distribution adapters with module-level confidence gates.

## 2026-05-08 - Progress Muscle Coverage Contract V1 Validation

Scope:

- Validated the Progress muscle coverage V1 data path after `26dc264 feat: populate progress muscle coverage`.
- Performed Windows static validation only; no local Swift/Xcode build or simulator run was available.
- Confirmed workout completion now populates `ProgressEntry.muscleGroupVolume` from completed workout sets and `ExerciseLibrary` metadata without demo/prototype data or Progress V4 production wiring.

Files changed:

- `ios/STRQ/Views/ProgressAnalyticsView.swift`
- `docs/migration-progress-log.md`

Fix:

- Filtered existing Muscle Balance chart rows to entries with a real comparison baseline so newly populated data cannot display missing-baseline muscles as misleading `-100%` regressions.

Validation findings:

- Persisted `muscleGroupVolume` contains per-muscle `MuscleGroup.rawValue` keys only; broad push/pull/legs/core/posterior buckets remain calculator result data and are not written into `ProgressEntry`.
- Loaded exercises use `weight * reps`; zero-load exercises fall back to completed-set exposure points, so the field remains coverage/exposure rather than pure kg volume.
- Unresolved exercise IDs are skipped safely and reported by the calculator result.
- Existing workout completion ordering, total volume formula, analytics event payloads, HealthKit handoff, plan generation code, navigation, assets, localization, Widget, Watch, and project files were not changed in this validation pass.
- Progress V4 remains DEBUG-only.

Pending work:

- macOS or CI build/test validation remains required.
- Rork/simulator QA remains required for loaded, bodyweight, mixed, unresolved-metadata, low-data, three-workout, and established Muscle Balance states.

## 2026-05-08 - Progress Muscle Coverage iOS Test Workflow

Scope:

- Added a focused GitHub Actions workflow for Progress Muscle Coverage V1 test validation on macOS/Xcode CI.
- The workflow selects Xcode 16.4 when available, lists the Xcode project, lists available iOS simulators, prefers `iPhone 16`, and falls back to an available iPhone simulator.
- The focused test command is:

```sh
xcodebuild test \
  -project ios/STRQ.xcodeproj \
  -scheme STRQ \
  -configuration Debug \
  -sdk iphonesimulator \
  -destination "${destination}" \
  -only-testing:STRQTests/ProgressMuscleCoverageCalculatorTests \
  CODE_SIGNING_ALLOWED=NO
```

Files changed:

- `.github/workflows/ios-tests.yml`
- `docs/migration-progress-log.md`

Pre-CI inspection:

- `ios/STRQTests/STRQTests.swift` defines `ProgressMuscleCoverageCalculatorTests`.
- The shared `STRQ` scheme exists, but this Windows-side inspection found no `TestAction` in `ios/STRQ.xcodeproj/xcshareddata/xcschemes/STRQ.xcscheme`; macOS/Xcode CI must confirm whether this blocks `xcodebuild test`.

Intentionally not changed:

- No app runtime behavior, production Progress UI, Progress V4 production wiring, analytics, navigation, assets, localization, Widget, Watch, Live Activity, project file, or test source changes.

Pending work:

- Dispatch or inspect the `iOS Tests` workflow on GitHub Actions and capture the exact Progress Muscle Coverage test result or blocker.
- If CI reports the shared scheme is not configured for testing, the minimal follow-up is to add the existing `STRQTests` target to the shared `STRQ` scheme test action.

## 2026-05-08 - Progress Muscle Coverage Runtime QA Report

Scope:

- Documented Progress Muscle Coverage runtime QA status after green iOS Build and focused iOS Tests on `dcf9ac9`.
- Confirmed this Windows workspace cannot execute Rork/iOS simulator runtime scenarios because `xcodebuild`, `xcrun`, Swift, and `rork` are unavailable.
- Captured static findings for weighted, bodyweight, mixed, low-data, 4+ Muscle Balance, per-muscle data shape, broad bucket label risk, copy semantics, and V4 DEBUG-only containment.

Files changed:

- `docs/progress-muscle-coverage-runtime-qa-report.md`
- `docs/migration-progress-log.md`

Verification status:

- GitHub Actions iOS Build and iOS Tests passed on `dcf9ac94a984a2c97888d9919192cbbf9df05eae`.
- Real Rork/simulator QA remains blocked pending a macOS runtime environment with disposable simulator data.

## 2026-05-08 - Progress Muscle Coverage Runtime QA Current-Head Attempt

Scope:

- Re-attempted the requested real macOS/Rork simulator QA preflight from the current Codex workspace.
- Confirmed the working tree was clean before edits and `main` was at `bc2356cc8c0683aad94910b3047dbeab3a3e362a`.
- Confirmed `main` includes both `dcf9ac9 ci: enable STRQTests scheme action` and `bc2356c docs: validate progress muscle coverage runtime`.
- Confirmed local runtime QA remains blocked here because Windows PowerShell does not provide `xcodebuild`, `xcrun simctl`, Swift, a Rork CLI, or exposed XcodeBuildMCP simulator tools.
- Updated the runtime QA report so weighted, bodyweight, mixed, 1-workout, 3-workout, 4+ workout, Progress UI, Muscle Balance, Movement Balance, unresolved metadata, data-shape, and copy-risk sections state the exact blocker instead of implying simulator observations.

Files changed:

- `docs/progress-muscle-coverage-runtime-qa-report.md`
- `docs/migration-progress-log.md`

Verification status:

- iOS Build passed on current head `bc2356cc8c0683aad94910b3047dbeab3a3e362a`, run `25571693952`.
- Focused iOS Tests previously passed on `dcf9ac94a984a2c97888d9919192cbbf9df05eae`, run `25570824557`.
- Focused iOS Tests passed on current head `bc2356cc8c0683aad94910b3047dbeab3a3e362a`, run `25572288082`.

Intentionally not changed:

- No Swift files.
- No production Progress UI.
- No Progress V4 production integration.
- No DEBUG prototype files.
- No `ContentView.swift`, `CoachTabView.swift`, `ExerciseDetailView.swift`, `WeeklyCheckInView.swift`, assets, localization, project file, analytics, unrelated Services/Models/ViewModels, Widget, Watch, Live Activity, fonts, or destructive simulator data actions.

Pending work:

- Complete real Rork/simulator QA from a macOS runtime environment using disposable simulator data.
- Replace blocked scenario notes with actual runtime observations before classifying Progress Muscle Coverage V1 as pass or pass with caveats.

## 2026-05-08 - Progress V4 Production Integration Plan

Scope:

- Created a docs-only phased integration plan for moving the accepted DEBUG-only Progress V4 Hybrid Candidate into production safely without implementing it yet.
- Chose exactly one first production slice: Weekly Rhythm from real completed workout dates.
- Kept Muscle Coverage runtime QA as a separate release gate and documented why repeated Windows-only runtime QA attempts should not continue.

Files changed:

- `docs/progress-v4-production-integration-plan.md`
- `docs/migration-progress-log.md`

Intentionally not changed:

- No Swift files, assets, project files, models, services, view models, analytics files, localization, tests, fonts, Widget, Watch, Live Activity, or production runtime files.
- No Progress V4 productionization and no demo data wiring.

Pending work:

- Implement the Weekly Rhythm production slice in a separate scoped pass.
- Complete real macOS/Rork runtime QA for Muscle Coverage before Training Distribution or V4 replacement release confidence.

## 2026-05-08 - Progress Weekly Rhythm Production Slice

Scope:

- Replaced the production Progress 28-day consistency card with a real-data Weekly Rhythm module inside `ProgressAnalyticsView`.
- Kept the production Progress screen, Progress V4 DEBUG candidate, Muscle Coverage, Muscle Balance, Strength/Body/Volume chart calculations, Recent Workouts route, analytics, persistence, models, services, view models, assets, localization, project files, tests, Widget, Watch, and Live Activity behavior unchanged.
- Used completed workout/session dates from existing `workoutHistory` only, with `profile.daysPerWeek` as target context.

Files changed:

- `ios/STRQ/Views/ProgressAnalyticsView.swift`
- `docs/migration-progress-log.md`

Figma inspected:

- Used [@Figma](plugin://figma@openai-curated) read-only in Licensed Source Mode.
- Inspected Activity Tracker `11611:134946`, user-selected rhythm/goal/calendar nodes `11604:63724`, `11604:64200`, `11604:64937`, `11604:66184`, and chart/progress primitives `9129:26029`, `9129:207997`.
- Adapted compact calendar rows, target/progress context, neutral inactive day tracks, week-by-week cadence bars, and clear state chips without copying source text, branding, assets, raw layouts, orange CTA styling, Pro violet styling, or demo values.

Implementation:

- Added private view-local Weekly Rhythm snapshot structs and helpers inside `ProgressAnalyticsView.swift`.
- Shows a 28-day completed-workout grid, current week sessions versus target, last-28-day session days, active weeks, target-met weeks, and a compact four-week cadence row.
- Uses conservative labels: Baseline forming, Early rhythm, Readable rhythm, and Consistent week.
- Keeps low-data states honest and treats open days as neutral.

Verification status:

- Static Windows verification only; macOS/Xcode local build validation was not available in this workspace.
- macOS/CI build validation and Rork visual QA remain required.

Pending work:

- Rork QA should capture 0, 1, 3, and 4+ workout states on small and large iPhone sizes.
- Full Progress V4 production integration remains deferred; Muscle Coverage runtime QA remains a separate release gate.

## 2026-05-09 - Rork Preview Install Hardening

Scope:

- Hardened the native iOS app target for Rork preview installation after the cloud preview stayed on the Apple logo / Installing state.
- Kept the app on the iOS 26 direction and restored the modern tab shell / onboarding `MeshGradient` assumptions.
- Stopped the app target from embedding Widget and Watch products during the main STRQ app install, reducing preview signing/provisioning risk while leaving the Widget and Watch source targets in the project.
- Pruned the main app entitlements file to avoid requiring HealthKit, iCloud, Apple Sign-In, App Groups, or Apple Pay provisioning for the Rork preview app bundle.

Files changed:

- `ios/STRQ/ContentView.swift`
- `ios/STRQ/Views/OnboardingView.swift`
- `ios/STRQ/STRQ.entitlements`
- `ios/STRQ.xcodeproj/project.pbxproj`
- `docs/migration-progress-log.md`

Verification:

- Confirmed `Tab(value:)`, `.sidebarAdaptable`, and onboarding `MeshGradient` remain available for the iOS 26 baseline.
- Confirmed no iOS or watchOS deployment target below `26.0` remains in the app targets.
- Confirmed the main app entitlements file no longer contains `com.apple.developer.*` or App Groups entries.
- Ran `git diff --check`; only existing CRLF normalization warnings were reported.

Pending work:

- GitHub Actions on the current runner may need an Xcode/iOS 26 image before it can validate the iOS 26 deployment target.
- Rork preview should be refreshed from the new commit and retried.
- Watch, Widget, HealthKit, iCloud, and Apple Sign-In should be reintroduced only with matching provisioning once the base Rork app install is stable.

## 2026-05-09 - Progress Strength Volume Trend Slice

Scope:

- Refined the production Progress Strength Trend and Volume Trend / Weekly Workouts modules as the next safe Progress V4 production slice.
- Kept Progress V4 DEBUG-only and did not productionize Training Distribution, Muscle Coverage, or a full V4 surface.
- Preserved existing Strength/Body/Volume tab behavior, Weekly Rhythm, Muscle Balance, Muscle Coverage data behavior, Recent Workouts routing, analytics, persistence, models, services, view models, assets, localization files, project files, tests, Widget, Watch, and Live Activity behavior.

Files changed:

- `ios/STRQ/Views/ProgressAnalyticsView.swift`
- `docs/migration-progress-log.md`

Figma inspected:

- Used [@Figma](plugin://figma@openai-curated) read-only in Licensed Source Mode.
- Inspected chart primitives `9129:26029`, progress primitives `9129:207997`, metric insight/detail nodes `11604:63115`, `11604:63236`, `11604:63379`, `11604:63397`, and `11604:63410`.
- Adapted chart-first proof containers, conservative status chips, line/bar primitive grammar, muted progress tracks, compact metric rows, and detail/report hierarchy without copying source branding, assets, orange CTA identity, Pro violet styling, or health-specific copy.

Implementation:

- Upgraded the Strength module from a generic Estimated 1RM card into a Strength Trend proof module with Baseline forming, Early signal, and Readable trend states.
- Preserved the existing strength chart gate, `vm.strengthProgress` data source, and estimated 1RM chart marks while clarifying the visible labels as movement-anchor evidence rather than PR claims.
- Upgraded the Volume tab's Weekly Workouts card into a Volume Trend / weekly load rhythm module using the same completed-workout 8-week count source.
- Added local view-only helper snapshots and proof metrics inside `ProgressAnalyticsView.swift`.
- Improved low-data copy for Strength and Volume without using demo/mock data or new localization keys.

Verification status:

- Static Windows verification only; macOS/Xcode local build validation was not available in this workspace.
- macOS/CI build validation and Rork visual QA remain required.

Pending work:

- Rork QA should capture Strength Trend and Volume Trend states across low-data and readable-data users on small and large iPhone sizes.
- Full Progress V4 integration remains deferred; Muscle Coverage runtime QA remains a separate release gate before Training Distribution or V4 replacement confidence.

## 2026-05-09 - Progress Recent Evidence Slice

Scope:

- Upgraded the production Progress recent workout/history preview into a Recent Evidence timeline.
- Kept Progress V4 DEBUG-only and did not productionize Training Distribution, Muscle Coverage, Muscle Balance, or a full V4 surface.
- Preserved the existing SessionHistoryView route/action, selected Strength/Body/Volume tab behavior, Weekly Rhythm logic, Strength/Volume chart calculations, analytics, persistence, models, services, view models, assets, localization files, project files, tests, Widget, Watch, and Live Activity behavior.

Files changed:

- `ios/STRQ/Views/ProgressAnalyticsView.swift`
- `docs/migration-progress-log.md`

Figma inspected:

- Used [@Figma](plugin://figma@openai-curated) read-only in Licensed Source Mode.
- Inspected Activity Tracker / history source `11611:134946`, user-selected history/evidence/rhythm nodes `11604:63724`, `11604:64200`, `11604:64937`, `11604:66184`, chart primitives `9129:26029`, and progress primitives `9129:207997`.
- Drilled into history/evidence sublayers `11604:63838`, `11604:65087`, `11604:66340`, progress-track primitive `1264:9818`, and trend-label primitive `8390:5246`.
- Adapted compact history row anatomy, section-header plus history action, timeline/list pacing, conservative status chips, and progress/status primitive grammar without copying source branding, assets, orange CTA identity, Pro violet styling, health-specific copy, or demo data.

Implementation:

- Replaced the plain Recent Workouts preview with a Recent Evidence module that uses real completed workout history only.
- Shows a conservative 28-day evidence summary, active-week count, current-week count against the existing profile target, completed-session source count, and recent 3-5 completed sessions as a timeline.
- Derives only view-level labels from existing session fields: completed status, start/end date, workout name, duration, completed sets/reps/exercise count, total volume, and completed-date rhythm context.
- Uses conservative state language: Logged, Recent, Building pattern, Training evidence, and Baseline forming.
- Keeps `NavigationLink(value: ProgressRoute.history)` and `SessionHistoryView(vm: vm)` intact.

Verification status:

- Static Windows verification only; macOS/Xcode local build validation was not available in this workspace.
- macOS/CI build validation and Rork visual QA remain required.

Pending work:

- Rork visual QA should capture Recent Evidence empty, low-data, and multi-week states on small and large iPhone sizes.
- Full Progress V4 integration remains deferred; Muscle Coverage runtime QA remains a separate release gate before Training Distribution or V4 replacement confidence.

## 2026-05-09 - Progress V5 Experience Blueprint

Scope:

- Created a docs-only Progress V5 Experience Blueprint for a stronger flagship Progress direction.
- Defined Progress as a simple user-facing training story powered by complex confidence, rhythm, coverage, evidence, unlock, and future plan-impact logic.
- Kept current Progress production slices and V4 direction as useful ingredients, not the final experience.

Files changed:

- `docs/progress-v5-experience-blueprint.md`
- `docs/migration-progress-log.md`

Figma inspected:

- Used [@Figma](plugin://figma@openai-curated) read-only in Licensed Source Mode during planning.
- Mapped selected Progress / Metrics / Health / Goal / History frames `11604:63074`, `11604:63099`, `11604:63115`, `11604:63236`, `11604:63379`, `11604:63397`, `11604:63410`, `11604:63465`, `11604:63511`, `11604:63616`, `11604:63709`, `11604:63679`, `11604:63724`, `11604:64200`, `11604:64937`, `11604:66184`, chart primitives `9129:26029`, progress primitives `9129:207997`, Activity Tracker `11611:134946`, and Dark Home / Smart Fitness Metrics `11604:62728`.
- Chose `11604:63724`, `11604:64937`, `11604:66184`, `11611:134946`, and `11604:62728` as the strongest V5 layout anchors.

Intentionally not changed:

- No Swift files, assets, project files, models, services, view models, analytics files, localization files, Widget, Watch, Live Activity, tests, fonts, or production runtime behavior.

Pending work:

- Next recommended pass is a DEBUG-only Progress V5 Experience Prototype with first-time/beginner and established/athlete demo states.

## Template For Future Entries

### YYYY-MM-DD - Pass Name

Scope:

- 

Files changed:

- 

Figma inspected:

- 

Code inspected:

- 

Verification run:

- 

Intentionally not changed:

- 

Pending work:

- 

Warnings:

- 
