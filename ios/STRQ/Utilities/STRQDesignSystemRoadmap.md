# STRQ Design System Roadmap

Last prepared: 2026-04-29

## Scope

This roadmap began as a planning document and now also records the controlled
foundation ownership rename completed on 2026-04-29.

No new assets were imported. No runtime screens, Swift production views, localization, analytics, product IDs, exercise data, persistence, navigation, workout logic, progression logic, onboarding logic, active workout behavior, rest timer behavior, or paywall behavior were changed.

Source documents:

- `SandowImportManifest.md`
- `SandowAnatomyImportPlan.md`
- `STRQDesignSystemNamingPlan.md`
- `STRQDesignSystem.swift`
- `Assets.xcassets/STRQIcon*.imageset`

The purchased Figma/Sandow UI Kit is an internal source/reference. STRQ should own future runtime names, production assets, and reusable design-system APIs.

Allowed Sandow references:

- Import manifests
- Audit docs
- Roadmap docs
- Source/provenance notes
- Internal planning docs

Runtime-facing future names should be STRQ-owned, including:

- `STRQDesignSystem`
- `STRQColors`
- `STRQTypography`
- `STRQSpacing`
- `STRQRadii`
- `STRQEffects`
- `STRQIcon`
- `STRQIconView`
- `STRQCard`
- `STRQButton`
- `STRQChip`
- `STRQBadge`
- `STRQMetricCard`
- `STRQProgressBar`
- `STRQProgressRing`
- `STRQTabBar`
- `STRQScheduleRow`
- `STRQAnatomyMuscleView`
- `STRQMuscleFocusCard`

## Current State Summary

- Existing STRQ-owned app UI is active.
- The failed direct Home clone/takeover was rolled back.
- The imported foundation currently exists as isolated internal files/assets.
- Production screens should not use the imported foundation until a controlled migration pass.
- Runtime foundation code and icon assets now use STRQ-owned names. Sandow remains only in approved source/provenance documentation.
- Anatomy, muscle, body type, full-body vector, achievement, equipment, illustration, and organ anatomy asset groups were found and documented.
- No full UI import should happen blindly.
- No runtime production screens currently depend on the imported foundation, based on the prior manifest audit and validation searches in this pass.
- The 2026-04-29 foundation completion pass expanded isolated STRQ typography and reusable primitives without migrating production screens.
- The default foundation style remains black, white, carbon, graphite, muted gray, and semantic success/warning/danger colors. Warm/orange tokens remain source-kit aliases only.

## Foundation Completion Pass - 2026-04-29

Figma nodes inspected in bounded form:

- Typography `9119:6481`
- Colors `5359:9002`
- Gradients `5442:13546`
- Effects `9120:58753`
- Size & Spacing `9122:6944`
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

Typography completion:

- `STRQTypography` now includes complete display, heading, text, paragraph, and label roles matching the Figma categories.
- STRQ-owned aliases now include `appTitle`, `screenTitle`, `sectionTitle`, `cardTitle`, metric roles, button roles, chip roles, tab labels, captions, and micro text.
- Line-height constants and tracking constants were added for display, heading, text, paragraph, and label families.
- STRQ's default preset favors bold/heavy screen, card, metric, and action roles, medium/regular body text, medium captions, and modest uppercase label tracking.

Font strategy:

- Figma Typography node `9119:6481` uses Work Sans with Regular, Medium, SemiBold, and Bold styles.
- The 2026-04-29 activation pass found no Work Sans `.ttf`, `.otf`, `.woff`, or `.woff2` files anywhere in this checkout. The expected `ios/STRQ/Resources/Fonts/` path is not present in the visible workspace.
- Required bundled weights are `WorkSans-Regular`, `WorkSans-Medium`, `WorkSans-SemiBold`, and `WorkSans-Bold`; all are missing in this checkout. Optional `WorkSans-ExtraBold` and `WorkSans-Black` are also missing.
- No app `ios/STRQ/Info.plist` exists; the STRQ app target uses generated Info.plist build settings.
- The Xcode project uses `PBXFileSystemSynchronizedRootGroup` for the `STRQ` app target, so resources placed under `ios/STRQ` are included through filesystem sync; no explicit `project.pbxproj` resource entries were added for missing font files.
- No `UIAppFonts` registration was added. `STRQFontRegistrar` now registers bundled Work Sans files at startup with `CTFontManagerRegisterFontsForURL`, which avoids forcing a new generated-Info.plist override.
- No fonts were downloaded or added.
- Runtime typography now probes for registered Work Sans PostScript candidates first, including Regular, Medium, SemiBold, Bold, and optional ExtraBold/Black, then falls back to a stronger role-based system strategy with rounded emphasis for heading, label, and metric roles.
- Work Sans fidelity remains pending in this checkout until real font binaries are present in the app bundle.

Component primitives added or completed:

- Existing primitives remain: `STRQSurface`, `STRQCard`, `STRQButton`, `STRQChip`, `STRQBadge`, `STRQMetricCard`, `STRQProgressBar`, `STRQProgressRing`, `STRQListItem`, `STRQSectionHeader`, tab bar primitives, schedule rows/cards, and icon containers.
- Added isolated primitives: `STRQIconButton`, `STRQSearchField`, `STRQInputField`, `STRQToggleRow`, `STRQModalSurface`, `STRQBottomSheetSurface`, `STRQNavigationBar`, `STRQAvatar`, `STRQRatingStars`, and `STRQEmptyStateCard`.
- Figma evidence was explicit for icon buttons, chips/badges, progress, tabs, tab bar, list slots with avatar/toggle/rating, schedule empty/event states, general/app cards, and navigation.
- Dedicated modal, bottom-sheet, and input component sets were not found in the exact inspected nodes; STRQ now has simple token-based shells for future use, with deeper parity still pending.

Debug lab update:

- `STRQDesignSystemPreviewView` now shows typography families, Regular/Medium/SemiBold/Bold weight differences, optional ExtraBold/Black weights when registered, Work Sans active/fallback status, STRQ default roles, button variants, icon buttons, chips/badges, cards, metric cards, progress bars/rings, list items, schedule rows/cards, search/input/toggle/navigation/modal/bottom sheet/avatar/rating/empty-state primitives, and all icons through `STRQIcon.allCases`.

## Foundation Roadmap

### 1. Colors

Current status:

- `STRQDesignSystem.swift` contains an isolated color foundation.
- Current tokens cover primitive neutral scales, orange/brand scale, several accent/status colors, dark-mode surfaces, text colors, borders/dividers, and compatibility aliases.
- The implementation is partial relative to the purchased Figma file because exact Figma variable collections, modes, aliases, scopes, and accessibility variants have not been fully enumerated.

What is imported:

- Neutral scale: black, white, gray 50-950.
- Warm orange scale: orange 50-950.
- Accent primitives: blue, purple, lime, amber, rose.
- Dark surfaces, card/inset/control surfaces, selected surfaces.
- Text, border, divider, brand, success, warning, and danger semantics.

What still needs verification:

- Exact Figma variable collection names and semantic token hierarchy.
- Light mode, dark mode, and any contrast/accessibility modes.
- Whether Figma v3 semantic tokens map cleanly to STRQ's existing palette.
- Whether orange is the main STRQ action color or only an imported reference accent.
- Contrast behavior for text-on-brand, text-on-surface, disabled states, selected states, and chart colors.

STRQ ownership direction:

- Future runtime tokens should live under `STRQColors`.
- STRQ should own token names by role first, then primitive scale where useful.
- Recommended shape:
  - `STRQColors.background`
  - `STRQColors.surface`
  - `STRQColors.surfaceElevated`
  - `STRQColors.surfaceInset`
  - `STRQColors.textPrimary`
  - `STRQColors.textSecondary`
  - `STRQColors.textMuted`
  - `STRQColors.border`
  - `STRQColors.borderSelected`
  - `STRQColors.accent`
  - `STRQColors.success`
  - `STRQColors.warning`
  - `STRQColors.danger`
- Primitive scales may remain internal implementation details unless production code truly needs them.
- Do not replace existing app palette globally during the foundation pass.

### 2. Gradients

Current status:

- Current gradients include orange CTA, orange glow, dark card, inset card, subtle overlay, and progress/status gradients.
- Exact Figma gradient inventory is not complete.

Useful gradients:

- CTA/action gradient for high-emphasis primary actions.
- Progress fill gradients for workout, analytics, and score surfaces.
- Subtle overlay gradients for card depth when used sparingly.
- Dark card/inset gradients where they improve hierarchy without making the app feel like a marketing page.

Gradients to avoid:

- Large decorative gradients that dominate the product UI.
- Full-screen mesh/background gradients unless a specific STRQ screen intentionally needs them.
- One-off colorful variants that should be represented as tint/state in SwiftUI.
- Gradients imported only because they exist in Figma.

STRQ ownership direction:

- Future runtime gradients should live under `STRQGradients` or inside `STRQEffects` if they are effect-like.
- Prefer semantic names:
  - `STRQGradients.primaryAction`
  - `STRQGradients.progressAccent`
  - `STRQGradients.progressSuccess`
  - `STRQGradients.surfaceSubtle`
  - `STRQGradients.reward`
- Keep gradients constrained to components that need them.

### 3. Typography

Current status:

- Figma Typography node `9119:6481` was inspected directly.
- `STRQTypography` now covers the full observed display, heading, text, paragraph, and label scale.
- Work Sans font files are not present in this checkout, so runtime uses a safe, stronger system fallback while retaining Work Sans as the source-family note.
- `STRQFontRegistrar.registerBundledFonts()` is called once from `STRQApp.init()`. It looks for `WorkSans-Regular`, `WorkSans-Medium`, `WorkSans-SemiBold`, `WorkSans-Bold`, and optional `WorkSans-ExtraBold`/`WorkSans-Black` as `.ttf` or `.otf` resources in `Resources/Fonts`, `Fonts`, or the bundle root.
- STRQ-owned role aliases are complete enough for future component and module work without leaking source-kit naming into runtime Swift.
- The typography fidelity pass added explicit helpers: `STRQTypography.font(...)`, `headingFont(...)`, `textFont(...)`, `labelFont(...)`, and `metricFont(...)`.

Font family issue:

- The purchased UI kit uses Work Sans.
- The current visible checkout does not contain Work Sans font files.
- Exact Work Sans rendering requires app-bundled font files, target resource inclusion, runtime CoreText registration, and verified runtime PostScript/font names.
- The current app has no `ios/STRQ/Info.plist`; generated Info.plist settings are used, so runtime registration is preferred over adding `UIAppFonts`.

Fallback strategy:

- Short term: keep system-backed STRQ typography active in the isolated foundation.
- Use role helpers so display/heading/label/metric roles are intentionally stronger than plain defaults while Work Sans is missing.
- If licensed Work Sans font files are provided later, add only those font files under `ios/STRQ/Resources/Fonts/`. The STRQ filesystem-synchronized app target should include them without manual `project.pbxproj` entries, and `STRQFontRegistrar` will register them safely at process startup.
- Verify the PostScript/font names on-device or in simulator; `STRQTypography` already probes likely Work Sans names before falling back.
- Until then, exact Figma typography remains pending and the DEBUG design-system lab reports `Work Sans not bundled — using system fallback`.

STRQ ownership direction:

- Future runtime typography should live under `STRQTypography`.
- Recommended role names:
  - `displayLarge`
  - `displayMedium`
  - `displaySmall`
  - `heading2XL`
  - `headingXL`
  - `headingLarge`
  - `headingMedium`
  - `headingSmall`
  - `headingXS`
  - `text2XL` through `text2XS`
  - `paragraph2XL` through `paragraphXS`
  - `label2XL` through `labelXS`
  - `screenTitle`
  - `sectionTitle`
  - `cardTitle`
  - `metricLarge`
  - `metricMedium`
  - `metricSmall`
  - `body`
  - `bodySmall`
  - `caption`
  - `label`
  - `button`
  - `tabLabel`
- Production screens should use role-based names, not vendor style names.

### 4. Spacing / Sizing / Grid

Current status:

- Current spacing includes 2-128 point increments, semantic gaps, card padding, list padding, chip padding, component heights, icon sizes, tab bar height, and nav bar height.
- Exact Figma grid, size, spacing, and responsive frame tokens are not fully verified.

Areas to verify:

- Mobile horizontal margins.
- Section and module gaps.
- Card padding and compact card padding.
- List row horizontal/vertical padding.
- Component gaps inside cards.
- Icon sizes and icon container sizes.
- Tab bar height, safe-area treatment, and center-action sizing.
- Navigation/app bar height.
- Input/search heights if imported later.
- Bottom sheet/modal padding and detent spacing if found later.

STRQ ownership direction:

- Future runtime spacing should live under `STRQSpacing`.
- Recommended names:
  - `screenMargin`
  - `sectionGap`
  - `moduleGap`
  - `cardGap`
  - `cardPadding`
  - `cardPaddingCompact`
  - `rowPadding`
  - `chipPaddingX`
  - `chipPaddingY`
  - `iconSmall`
  - `iconMedium`
  - `iconLarge`
  - `tabBarHeight`
  - `navBarHeight`
- Keep primitive increments available internally, but encourage semantic spacing in production components.

### 5. Radii / Effects

Current status:

- Current radii cover 0, 2, 4, 8, 12, 16, 20, 24, 32, and full pill values.
- Current effect tokens cover hairline/selected/focus widths, card/divider borders, shadows, orange glow, background blur values, and dark glass background/stroke.
- Exact Figma effect styles remain partial.

Areas to verify:

- Card radius standards by component type.
- Button, chip, badge, icon container, tab item, tab bar, and modal radii.
- Shadow depth levels and whether they should remain in STRQ production UI.
- Glow and blur rules, especially selected states and tab bar glass effects.
- Error, focus, pressed, disabled, selected, and active state effects.

STRQ ownership direction:

- Runtime radii should live under `STRQRadii`.
- Runtime effects should live under `STRQEffects`.
- Use effects sparingly:
  - Borders and selected strokes should be preferred for utilitarian STRQ surfaces.
  - Glows should be reserved for clear reward/action moments.
  - Background blur should be limited to overlays, sheets, and navigation surfaces that need depth.
  - Selected state should be represented by tokenized fill, stroke, icon tint, and text color, not imported duplicate image states.

### 6. Component Primitives

Current status:

- The isolated foundation currently covers surfaces, cards, buttons, icon buttons, chips, badges, metric cards, progress bars/rings, progress rows, list items, section headers/actions, search/input fields, toggle rows, modal/sheet surfaces, navigation bars, avatars, rating stars, empty states, tab bar primitives, and schedule rows/cards.
- These are not production screen dependencies yet.
- Several app-relevant primitive groups remain partial, especially charts, sliders, workout/exercise cards, achievement cards, and deeper modal/input parity.

Foundation primitive roadmap:

| Primitive Area | Current Coverage | What To Add / Verify | Future STRQ Name |
|---|---|---|---|
| Surfaces | Partial | Base/elevated/inset/selected/background behavior, light/dark mapping | `STRQSurface` |
| Cards | Partial | General card shell, selected card, media card, action card, compact card | `STRQCard` |
| Buttons | Partial | Primary, secondary, ghost, destructive, icon button, loading, disabled, compact | `STRQButton`, `STRQIconButton` |
| Chips | Partial | Neutral, selected, removable, icon-leading, filter state | `STRQChip` |
| Badges | Partial | Count, status, achievement, premium, warning/error | `STRQBadge` |
| Metric Cards | Partial | KPI, trend, score, compact dashboard, comparison state | `STRQMetricCard` |
| Progress Bars | Partial | Compact, labeled, segmented, status/tone variants | `STRQProgressBar` |
| Progress Rings | Partial | Score, activity, compact, label/value center content | `STRQProgressRing` |
| List Rows | Partial | Icon, avatar, chevron, toggle, destructive, settings rows | `STRQListItem` |
| Schedule Rows | Partial | Calendar/session variants, selected state, rest day, completed state | `STRQScheduleRow` |
| Tab Bar | Partial | Safe area, selected state, center action, badges | `STRQTabBar` |
| Inputs/Search | Partial | Text input, search field, filters, validation states | `STRQInputField`, `STRQSearchField` |
| Bottom Sheets/Modals | Partial | Sheet container, drag handle, modal header/actions | `STRQBottomSheetSurface`, `STRQModalSurface` |
| Toggles/Sliders | Partial | Settings controls, numeric preference controls | `STRQToggleRow`, `STRQSliderRow` |
| Charts | Missing | Trend, bar, ring, score, weekly volume, muscle coverage | `STRQChartCard` |

## Icon Roadmap

Current status:

- Current imported icon image sets are named `STRQIcon*`.
- Current icon assets are isolated in `Assets.xcassets`.
- Current foundation exposes `STRQIcon` and `STRQIconView`.

Ownership strategy:

- Future app-facing icon assets should continue to use `STRQIcon*`.
- Runtime icon registry is `STRQIcon`.
- Runtime icon renderer is `STRQIconView`.
- Keep source/provenance notes in docs, not production-facing names.

Import strategy:

- Do not import every color/style variant.
- Prefer one template/vector icon per base icon and tint in SwiftUI.
- Import only icons needed for real STRQ screens/modules.
- Keep social/payment/brand icons optional unless a STRQ screen actually needs them.
- Avoid duplicate assets for selected, disabled, hover, pressed, or color states.
- Preserve vector representation and template rendering intent.
- Keep multicolor icons only when the icon meaning requires multicolor artwork.

Recommended icon import order:

1. App navigation icons.
2. Core UI action icons.
3. Fitness/workout icons.
4. Health/recovery/sleep icons.
5. Analytics/progress icons.
6. Reward/achievement icons.
7. Optional social/payment/brand icons only if needed.

Suggested first missing icon concepts:

- Navigation/action: back, close, menu, more, edit, trash, share, filter, sort, info, alert, lock, settings.
- Training: dumbbell, exercise, sets, reps, timer, rest, swap, history, intensity, volume.
- Analytics/progress: chart, line chart, activity, trend up, trend down, score, gauge.
- Coach/chat: chat, send, sparkle/AI, microphone, attachment, insight.
- Health/body: body, muscle, heart, recovery, nutrition, water, weight, watch/device.
- Rewards: trophy variants, medal, badge, streak, crown/premium where product scope needs it.

## App Component Roadmap

Future components should be STRQ-owned. The UI kit should provide visual reference and reusable patterns, while STRQ keeps product logic, copy, data, and brand direction.

| Component Group | Current Coverage | STRQ Relevance | Future STRQ Component Name | Recommended Migration Timing |
|---|---|---:|---|---|
| Navigation / App Bar | Missing | High | `STRQNavigationBar` | After tokens/icons are stable; before screen migrations |
| Tab Bar | Partial | High | `STRQTabBar` | Early component migration, isolated preview first |
| Schedule Rows/Cards | Partial | High | `STRQScheduleRow`, `STRQScheduleCard` | Early small module after foundation rename plan |
| List Items | Partial | High | `STRQListItem`, `STRQSettingsRow` | Early, useful across profile/settings/paywall |
| Metric Cards | Partial | High | `STRQMetricCard` | First or second small component migration |
| Activity Cards | Needs audit | High | `STRQActivityCard` | After metrics/progress primitives |
| Workout Cards | Missing | High | `STRQWorkoutCard` | After card/button/icon system |
| Exercise Cards | Missing | High | `STRQExerciseCard` | After workout card and muscle asset strategy |
| Progress / Analytics Cards | Partial | High | `STRQProgressCard`, `STRQAnalyticsCard` | After metric/progress primitives |
| Achievement Cards | Missing | Medium/High | `STRQAchievementCard` | After badge asset audit/import |
| Leaderboard Rows | Missing | Medium | `STRQLeaderboardRow` | Later, only if social/ranking feature remains |
| Paywall Plan Cards | Missing | High | `STRQPaywallPlanCard` | After button/card/list primitives; keep paywall logic untouched |
| Profile / Settings Rows | Partial | High | `STRQProfileHeader`, `STRQSettingsRow` | After list row primitives |
| Coach / Message Cards | Missing | Medium/High | `STRQCoachMessageCard`, `STRQInsightCard` | After coach feature direction is clear |
| Article / News Cards | Needs audit | Low | `STRQArticleCard` | Later only if content feed exists |
| Feedback / Rating Cards | Missing | Low/Medium | `STRQFeedbackCard`, `STRQRatingPrompt` | Later, post-session/product feedback only |
| Onboarding Selection Cards | Needs audit | High | `STRQSelectionCard` | Before onboarding visual migration |
| Bottom Sheets / Modals | Needs audit | High | `STRQBottomSheet`, `STRQModal` | Before any modal-heavy migration |
| Search / Input Components | Missing / needs audit | High | `STRQSearchField`, `STRQTextField` | Before exercise library/settings migration |

Migration principle:

- Build and verify a component in isolation first.
- Apply to one small STRQ module second.
- Expand only after the component holds up visually and behaviorally.

## STRQ-Critical Asset Roadmap

### 1. Anatomy Muscle

- Node: `8673:69673`
- 60 variants.
- 2 genders x 15 areas x selected/unselected.
- Mini area silhouettes, not a full body map.
- High STRQ relevance for exercise detail, muscle focus, onboarding body focus, progress/muscle coverage, and workout completion insights.
- Do not import all variants blindly.
- Recommended strategy from anatomy plan: base line art plus masks/overlays where possible.
- Future component names should be STRQ-owned:
  - `STRQAnatomyMuscleView`
  - `STRQMuscleFocusCard`
  - `STRQBodyAreaSelector`
  - `STRQAnatomyLegend`

Recommended import strategy:

- First verify export quality on a tiny sample: one male area and one female area, selected and unselected, without adding to production.
- Prefer extracting masks/overlays and styling selected/unselected/focus/reduced states in SwiftUI.
- If masks are not viable, use one composite per gender/body area and still avoid selected-state duplicates where possible.
- Skip the Hand area unless STRQ adds grip/hand rehab scope.

### 2. Full Body / Anatomy Vector Groups

- Node: `9192:5535`
- Better candidate for full-body line art.
- Pending export/component strategy.
- Likely useful for full-body overview, exercise detail, analytics, and onboarding.

Recommended next step:

- Inspect the four generic groups and label them as male front, male back, female front, and female back if that is what export QA confirms.
- Verify stable canvases and viewBox alignment before importing.
- Use as base line art for `STRQAnatomyMuscleView` if alignment with masks is feasible.

### 3. Body Type

- Node: `9025:207456`
- Medium priority.
- Useful for onboarding, profile, and body goals.

Recommended next step:

- Decide whether STRQ wants body type as product input.
- If yes, import only the states needed by the onboarding/profile flow.
- Prefer STRQ-owned naming and SwiftUI selected state styling.

### 4. Organ Anatomy

- Node: `9139:70026`
- Base component set: `8860:134805`
- Optional/later.
- Only import if STRQ adds health/recovery education screens.

Recommended next step:

- Keep out of the app until product scope requires organ-specific education.
- Do not import medical/organ illustrations as generic decoration.

### 5. Achievement Badges

- Nodes: `9064:106798` and `9063:203904`
- High value for reward moments and progress motivation.
- Likely earlier import than organ anatomy.

Recommended next step:

- Audit badge variants and export feasibility.
- Prioritize badges used for real milestones: first workout, streak, volume, consistency, PR, recovery, completion.
- Pair badge assets with `STRQAchievementCard` and workout completion reward moments.

### 6. Fitness Equipment Images

- Node: `11536:90366`
- Medium priority.
- Needs licensing/export-quality review before import.

Recommended next step:

- Inspect whether images are demo placeholders, licensed raster assets, or reusable kit assets.
- Import only if STRQ needs equipment filters, gym setup, exercise library visuals, or onboarding equipment selection.

### 7. Base Illustrations

- Node: `8912:62197`
- Useful for onboarding, empty states, and rewards if style fits STRQ.

Recommended next step:

- Audit style fit against current STRQ brand direction.
- Import only illustrations tied to a real screen/module.

### 8. Avatar Illustrations

- Useful only if STRQ profile, coach, onboarding, or community features need them.
- Keep optional until a concrete screen requires avatar artwork.

### 9. Confetti / Reward

- Useful for workout completion, milestone moments, streaks, and achievement unlocks.
- Import only after reward moments are designed and copy/product behavior is settled.

## What Not To Import By Default

Do not import by default:

- Coach/person photos.
- Demo user photos.
- Huge marketing mockups.
- Unrelated background images.
- Full 140MB ZIP.
- Full Figma source file.
- Press logos.
- Random company logos.
- Social logos unless needed.
- Payment logos unless the paywall needs them.
- Maps unless a real STRQ feature needs maps.
- Medication/pill assets unless STRQ product scope changes.
- Redundant icon color variants if tinting works.
- Selected/disabled/pressed asset duplicates where SwiftUI state styling is sufficient.
- Any asset that does not map to a near-term STRQ screen, component, or product moment.

## Timeout-Safe Figma Workflow

Large Figma scans can timeout. Future Figma work should be narrow and exact.

Rules:

- Never ask Codex to scan the full Figma file in one pass.
- Inspect one node/component group per pass.
- Use exact node IDs to avoid 120-second timeout.
- Update `SandowImportManifest.md` after every audit/import.
- Update this roadmap when priority changes.
- Import assets only after strategy is confirmed.
- Do not touch runtime screens during audit/import passes.
- After import, run a small isolated preview or component test first.
- Only then apply to a production screen/module.

Recommended audit/import loop:

1. Pick one roadmap item.
2. Inspect the exact Figma node.
3. Record node findings, variants, export risk, and STRQ relevance.
4. Choose STRQ-owned naming before import.
5. Import only the minimum useful assets/components.
6. Update manifest and roadmap.
7. Verify in an isolated preview.
8. Schedule production migration separately.

## Future Screen Migration Workflow

Future STRQ screen work should happen one contained module at a time.

1. User provides a Figma link or chooses a roadmap item.
2. Inspect exact node only.
3. Check if the STRQ foundation already supports it.
4. Add missing STRQ-named component/asset if needed.
5. Update manifest/roadmap.
6. Apply to one small STRQ module only.
7. Validate visually.
8. Continue to the next module only after the first module is stable.

Important:

- Do not copy full screens blindly unless explicitly requested.
- Use UI kit patterns as building blocks.
- STRQ keeps product logic, data, training intelligence, copy, and brand direction.
- Never combine visual migration with changes to workout logic, progression, persistence, analytics, product IDs, localization, navigation, onboarding, active workout, rest timer, paywall behavior, or exercise data.
- Use `L10n.tr` for user-facing copy and avoid raw localization keys.

## Priority Plan

### Priority 1: Foundation Completion And Ownership

- Verify current `STRQDesignSystem.swift` coverage against exact Figma token/style inventories.
- STRQ naming migration is complete for the isolated foundation and current icon assets.
- Complete core tokens/components.
- Do not change production screens.
- Do not import more assets in this priority unless a token/component preview requires a tiny internal fixture.

### Priority 2: Core Icon System

- Decide import coverage.
- Keep naming and mapping on `STRQIcon*`.
- Maintain `STRQIcon` enum/view.
- Keep template/tint strategy.
- Import only icons needed by near-term STRQ modules.

### Priority 3: High-Value STRQ Assets

- Anatomy Muscle strategy.
- Full-body vector groups.
- Achievement badges.
- Body Type.
- Equipment visuals.
- Base illustrations.

### Priority 4: Small Component Migrations

- Metric card group.
- Schedule row.
- Achievement badge card.
- Progress row.
- Paywall plan card.

### Priority 5: Screen-Level Migrations

- Progress/Analytics.
- Exercise Detail muscle focus.
- Workout Completion rewards.
- Paywall.
- Onboarding.
- Profile/Settings.
- Dashboard modules only after smaller components are proven.

### Priority 6: Optional/Later

- Organ anatomy.
- Maps.
- Payment/social/press logos.
- Unrelated media.

## Open Decisions For User

- Should STRQ use orange/warm accent as the main action color or keep a custom STRQ accent?
- Should anatomy be male/female selectable or neutral/default only?
- Should Body Type be part of onboarding?
- Should achievement badges become a real product feature or just visual rewards?
- Which screen should receive the first small component migration?
- Should existing Sandow-named files/assets be renamed now or only after more imports?

## Validation Searches

Searches to run for this roadmap pass:

- `SandowImportRoadmap`
- `STRQDesignSystemRoadmap`
- `SandowDesignSystem`
- `STRQDesignSystemNamingPlan`
- `SandowAnatomyImportPlan`
- `DashboardView Sandow`
- `ContentView Sandow`
- `ios/STRQ/Views Sandow`
- `exercise.singular`
- `set.plural`
- `Start Session`
- `Per Session`

Expected results:

- New roadmap exists at `ios/STRQ/Utilities/STRQDesignSystemRoadmap.md`.
- Runtime screens remain unchanged.
- Sandow references remain docs/foundation/assets only.
- No raw localization keys are introduced.
- No production screen migration happened.

Results from this pass:

| Search | Result |
|---|---|
| `SandowImportRoadmap` | Existing mention only in `STRQDesignSystemNamingPlan.md` noting that file does not exist, plus this roadmap's validation checklist. |
| `STRQDesignSystemRoadmap` | Found in this new roadmap only. |
| `SandowDesignSystem` | Historical/provenance references remain in docs only. The runtime file is now `STRQDesignSystem.swift`. |
| `STRQDesignSystemNamingPlan` | Found in the naming plan and this roadmap. |
| `SandowAnatomyImportPlan` | Found in import/naming/roadmap docs. |
| `DashboardView` + `Sandow` | No matches. |
| `ContentView` + `Sandow` | No matches. |
| `ios/STRQ/Views` + `Sandow` | No matches. |
| `exercise.singular` | Matches only import/roadmap docs. No runtime raw key usage found. |
| `set.plural` | Matches only import/roadmap docs. No runtime raw key usage found. |
| `Start Session` | Matches only import/roadmap docs. No runtime production screen hit from this pass. |
| `Per Session` | Matches import/roadmap docs only in the final foundation validation search. No production screen migration evidence. |

Validation note: `rg` succeeded in this pass and reported ripgrep 15.1.0.

## Naming / Ownership Rule

The purchased Figma/Sandow UI Kit remains the source reference. STRQ owns the app.

Future production-facing names should use STRQ prefixes and STRQ product language. Sandow names should stay in provenance, import, audit, and roadmap documentation only.

## Deliverable Summary For This Pass

Files changed:

- `ios/STRQ/Utilities/STRQDesignSystem.swift`
- `ios/STRQ/Views/Debug/STRQDesignSystemPreviewView.swift`
- `ios/STRQ/Utilities/STRQDesignSystemRoadmap.md`
- `ios/STRQ/Utilities/SandowImportManifest.md`

This roadmap now reflects the completed runtime ownership rename and the larger isolated foundation completion pass. See the naming plan for the full file, type, and asset mapping.
