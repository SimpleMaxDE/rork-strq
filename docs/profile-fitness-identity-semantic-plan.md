# Profile Fitness Identity Semantic Plan

## 1. Executive summary

`fitnessIdentity` is visually important because it is one of the first Profile cards. It should communicate the user's training identity and current coaching state, not merely decorate the Profile screen.

This area should not be treated as a simple card styling pass. Recovery, Sleep, Nutrition, and Streak have semantic meaning, and they need deliberate color and state rules before their visual language changes.

The recent `trackingToggleCard` green correction is the key warning for this area: token names are not enough. `successGreen` was visually lime-like, so this plan audits actual token definitions and current usage instead of trusting names.

This pass makes no Swift changes.

## 2. Current implementation inventory

`private var fitnessIdentity` in `ios/STRQ/Views/ProfileView.swift` is a local SwiftUI card, not a STRQ primitive composition.

Goal header:

- Icon source: `Image(systemName: vm.profile.goal.symbolName)`.
- Goal title: `Text(vm.profile.goal.displayName)`.
- Goal detail: `goalDescription`, only when `!vm.isEarlyStage`.
- Header icon color: white foreground on `STRQBrand.steelGradient`.
- Current goal display names and symbols come from `FitnessGoal.displayName` and `FitnessGoal.symbolName`.

`goalDescription` maps the selected goal to localized explanatory copy:

- `muscleGain`: "Hypertrophy-focused training for lean muscle growth"
- `strength`: "Maximizing strength on key compound lifts"
- `fatLoss`: "Training with metabolic demand for fat reduction"
- `generalFitness`: "Balanced training for overall health"
- `endurance`: "Building cardiovascular and muscular endurance"
- `flexibility`: "Improving range of motion and mobility"
- `athleticPerformance`: "Sport-specific training for peak performance"
- `rehabilitation`: "Safe, progressive training for recovery"

Metric chips:

- Recovery icon: `heart.fill`
- Recovery value: `"\(vm.effectiveRecoveryScore)%"`
- Recovery label: `L10n.tr("Recovery")`
- Recovery color: `ForgeTheme.recoveryColor(for: vm.effectiveRecoveryScore)`
- Sleep icon: `moon.zzz.fill`
- Sleep value: `String(format: "%.1fh", vm.averageSleepHours)`
- Sleep label: `L10n.tr("Sleep")`
- Sleep color: `ForgeTheme.sleepColor(for: vm.averageSleepHours)`
- Nutrition icon: `fork.knife`
- Nutrition value: `"\(Int(vm.weeklyNutritionAdherence * 100))%"`
- Nutrition label: `L10n.tr("Nutrition")`
- Nutrition color: `vm.weeklyNutritionAdherence >= 0.8 ? STRQPalette.success : STRQBrand.steel`
- Streak icon: `flame.fill`
- Streak value: `"\(vm.streak)"`
- Streak label: `L10n.tr("Streak")`
- Streak color: `STRQBrand.steel`

Conditional branch:

- If `vm.profile.nutritionTrackingEnabled` is true, the third chip shows Nutrition adherence.
- If `vm.profile.nutritionTrackingEnabled` is false, the third chip shows Streak.
- The branch is display-only here, but it reflects an important product mode switch.

Surfaces and borders:

- Outer card background: `Color(white: 0.105)` with corner radius `16`.
- Outer card border: `STRQBrand.cardBorder`, which is `Color.white.opacity(0.10)`.
- Inner divider: `Divider().opacity(0.4)`.
- Chip background: `Color.white.opacity(0.06)` with corner radius `10`.
- Chip border: `Color.white.opacity(0.06)` at `0.5`.
- The helper `private func statusChip(...)` controls all metric tile visuals.

Old visual systems used:

- `STRQBrand.steelGradient`
- `STRQBrand.steel`
- `STRQBrand.cardBorder`
- `STRQPalette.success`
- `ForgeTheme.recoveryColor(for:)`
- `ForgeTheme.sleepColor(for:)`
- direct SF Symbols
- local `statusChip`
- direct `Color(white:)` and `Color.white.opacity(...)`
- rounded system typography instead of `STRQTypography`

Minimum required identifiers confirmed:

- `vm.profile.goal.displayName`
- `vm.profile.goal.symbolName`
- `goalDescription`
- `vm.effectiveRecoveryScore`
- `vm.averageSleepHours`
- `vm.profile.nutritionTrackingEnabled`
- `vm.weeklyNutritionAdherence`
- `vm.streak`
- `ForgeTheme.recoveryColor(for:)`
- `ForgeTheme.sleepColor(for:)`
- `STRQPalette.success`
- `STRQBrand.steel`
- local `statusChip`

## 3. Current visual diagnosis

From static code inspection and owner screenshot context, `fitnessIdentity` reads older than the newly migrated Profile areas. The accepted Profile sections now use calmer STRQ card surfaces, tokenized rows, restrained borders, and clearer density. This card still uses a Forge-era local surface, white-opacity chip boxes, rounded system typography, and a steel-gradient icon well.

The metric chips may feel blocky and generic because all three chips share equal weight, full small boxes, and uppercase labels. The structure is readable, but it risks looking like a template dashboard rather than a premium coaching identity card.

The colors are semantically meaningful in code, but visually mixed. Recovery and Sleep can become green, amber, or red; Nutrition can become bright success green or neutral steel; Streak is steel. That can be useful, but in this compact card the accents may compete with the goal header instead of acting as small state signals.

The goal card and metrics need clearer hierarchy. The goal should read as training identity, while the metrics should read as current coaching state. Today they are separated by a divider, but the metric chip boxes dominate the lower half because each tile is framed and equally loud.

This should not become noisy gamification. Streak should not feel like a reward layer taking over the identity card, and Recovery/Sleep should not look like arcade status badges. At the same time, the card needs enough energy; an all-grey version would lose the coaching-state value that makes this card worth preserving.

## 4. Current semantic-state diagnosis

Recovery:

- Meaning: current training readiness/fatigue state, using `vm.effectiveRecoveryScore`.
- Current color likely meaningful: yes. It maps through score thresholds.
- Current intensity: potentially too loud when success/warning/danger colors are rendered as full icon tints in equal-weight chips.
- Recommended mode: semantic and conditional.
- Premium color requirement: use restrained deep or muted semantic accents, not bright gamified green/amber/red as full tile identity.
- At-a-glance user need: whether STRQ sees them as ready to push, needing moderation, or needing protection.

Sleep:

- Meaning: recent sleep average, shown as hours and used as a recovery input elsewhere.
- Current color likely meaningful: yes. It maps through sleep duration thresholds.
- Current intensity: acceptable in concept, but it can become too wellness-dashboard-like if bright green/amber/red carries the whole Sleep identity.
- Recommended mode: semantic and conditional, but calmer than Recovery.
- Premium color requirement: either muted blue/purple-neutral with a small semantic state marker, or deep semantic colors if product wants Sleep to share readiness thresholds.
- At-a-glance user need: whether recent sleep supports training readiness.

Nutrition:

- Meaning: weekly protein adherence when nutrition tracking is enabled.
- Current color likely meaningful: partly. High adherence turns success green; anything below 80% becomes neutral steel.
- Current intensity: too binary. It celebrates high adherence but does not distinguish medium from low, and the success green comes from legacy bright `STRQPalette.success`.
- Recommended mode: conditional only when nutrition tracking is enabled.
- Premium color requirement: green is acceptable for high adherence, but it should be deep emerald or muted green, not lime.
- At-a-glance user need: whether nutrition tracking is active and whether adherence is supporting body-composition coaching.

Streak:

- Meaning: consistency momentum when nutrition tracking is not enabled.
- Current color likely meaningful: yes as a restraint choice, because steel avoids making streak the loudest item.
- Current intensity: acceptable, possibly too weak if the whole card lacks energy.
- Recommended mode: neutral or lightly warm, not a loud reward color.
- Premium color requirement: neutral steel or a restrained warm signal could work, but avoid game-like flame dominance.
- At-a-glance user need: whether they have recent training/check-in consistency without making streak feel like the product's main goal.

## 5. Data and behavior dependencies

Data read directly by `fitnessIdentity`:

- `vm.profile.goal`
- `vm.profile.goal.displayName`
- `vm.profile.goal.symbolName`
- `vm.isEarlyStage`
- `goalDescription`
- `vm.effectiveRecoveryScore`
- `vm.averageSleepHours`
- `vm.profile.nutritionTrackingEnabled`
- `vm.weeklyNutritionAdherence`
- `vm.streak`

Data and calculations behind those values:

- `vm.effectiveRecoveryScore` returns the average of `recoveryScore` and today's readiness score when `todaysReadiness` exists; otherwise it returns `recoveryScore`.
- `recoveryScore` is derived from recent completed workout density, weekly load versus planned days, volume spike, recent sleep, today's readiness, pain/restriction, and training phase, then clamped.
- `vm.averageSleepHours` averages `sleepEntries.prefix(7)` and returns `0` when no sleep entries exist.
- `vm.weeklyNutritionAdherence` looks at `nutritionLogs.prefix(7)` and returns the fraction where protein is at least 80% of target.
- `vm.streak` is computed from today's completed workout or readiness check-in plus up to 60 prior days with completed workout or readiness activity.

Behavior:

- There are no direct actions in `fitnessIdentity`.
- There are no buttons, navigation links, sheets, alerts, bindings, analytics calls, async calls, persistence writes, or mutations in this card.
- The card is read-only display.

Must not change:

- recovery score calculation
- sleep average calculation
- nutrition adherence calculation
- streak logic
- goal display behavior
- `goalDescription` branching
- `vm.isEarlyStage` detail hiding
- `vm.profile.nutritionTrackingEnabled` Nutrition/Streak branch
- copy/localization
- profile state

## 6. Color/token usage audit

`ForgeTheme.recoveryColor(for:)`:

- Defined as `STRQPalette.recovery(for: score)`.
- `STRQPalette.recovery(for:)` returns success for scores `>= 80`, warning for `60..<80`, and danger below `60`.
- This is meaningful, but it inherits legacy palette brightness.

`ForgeTheme.sleepColor(for:)`:

- Defined as `STRQPalette.sleep(for: hours)`.
- `STRQPalette.sleep(for:)` returns success for `>= 7.5h`, warning for `>= 6.5h`, and danger below `6.5h`.
- This is meaningful, but it makes Sleep share the same traffic-light semantic colors as Recovery.

`STRQPalette.success`:

- Alias of `STRQPalette.signalGreen`.
- `signalGreen` is `Color(red: 0.290, green: 0.871, blue: 0.502)`.
- This is a bright, saturated green. It is not the same as the local premium deep green used in the accepted tracking toggle active state.

`STRQBrand.steel`:

- `Color(red: 0.655, green: 0.659, blue: 0.678)`.
- Visually neutral/steel grey.
- Used as the fallback for Nutrition below 80% adherence and for Streak.

`STRQBrand.steelGradient`:

- Gradient from rgb `0.655/0.659/0.678` to `0.439/0.443/0.467`.
- Used in the goal icon well.
- This is still part of the older Forge/brand layer, not the newer STRQ card/list token system.

`STRQBrand.cardBorder`:

- `Color.white.opacity(0.10)`.
- Used for the outer card border.
- Accepted Profile rows now more often use `STRQColors.borderMuted`.

`STRQColors.successGreen` and `STRQColors.success`:

- Both map to `STRQColors.lime500`.
- `lime500` is `#84CC16`.
- This confirms the product correction: do not recommend `successGreen` blindly for a premium green accent, because it is lime-like.

`STRQColors.warning` and `STRQColors.danger`:

- `warning` maps to `#F59E0B` amber.
- `danger` maps to `#F43F5E` rose/red.
- These are useful semantic families but still need restrained use in a compact premium card.

Existing deeper semantic colors:

- `STRQColors.successSoft` is `#3F6212`.
- `STRQColors.successDim` is `#1A2E05`.
- These are darker than lime, but their hue still belongs to the lime/olive family, not the tracking toggle's emerald family.

Deep green/local green learning from `trackingToggleCard`:

- The accepted active-state correction uses local colors:
- `activeGreen`: approximately `#047857`, a deep emerald.
- `activeGreenSoft`: approximately `#065F46`.
- `activeGreenDim`: approximately `#022C22`.
- This is the clearest current premium-green precedent in Profile.

Audit conclusion:

- Do not recommend `successGreen` or `STRQColors.success` just because their names sound correct.
- If green is recommended for this card, specify deep emerald or muted green, not lime.
- Recovery and Sleep may keep semantic thresholds, but future implementation should shrink color to icons, micro-bars, or small state dots rather than filling or dominating metric tiles.
- Nutrition high adherence can use green, but it should not copy legacy bright `STRQPalette.success`.
- Streak should stay neutral or restrained warm unless the owner approves a stronger reward system.

## 7. Recommended product meaning for each metric

| Metric | User meaning | Current display | Recommended visual tone | Accent allowed yes/no | Suggested color family | Should it be conditional? | Implementation risk |
|---|---|---|---|---|---|---|---|
| Recovery | Current training readiness and fatigue protection signal. | `heart.fill`, percent, `ForgeTheme.recoveryColor(for:)` with success/warning/danger thresholds. | Semantic but restrained; should feel coach-like, not gamified. | Yes | Deep or muted green for high, amber for moderate, rose/red for low; consider neutral surface plus small accent only. | Yes | Medium/high because thresholds communicate training guidance. |
| Sleep | Recent sleep support for training readiness. | `moon.zzz.fill`, one-decimal hours, `ForgeTheme.sleepColor(for:)` with duration thresholds. | Calm and premium; avoid childish wellness colors. | Yes, but subtle | Calm blue/purple-neutral, or muted semantic green/amber/red if aligned with recovery. | Yes | Medium because sleep is both a metric and recovery input. |
| Nutrition | Weekly protein adherence when nutrition tracking is active. | `fork.knife`, percent, green only when `weeklyNutritionAdherence >= 0.8`, otherwise steel. | Active coaching signal only when enabled; avoid lime. | Yes | Deep emerald or muted green for high; neutral/steel for inactive or unknown; optional amber only if an explicit medium state is approved. | Yes | Medium because branch and adherence meaning must stay exact. |
| Streak | Consistency momentum from workout/readiness activity when nutrition tracking is off. | `flame.fill`, count, `STRQBrand.steel`. | Neutral or lightly warm; avoid reward-game dominance. | Limited | Steel/graphite with optional muted warm micro-accent, not bright orange. | Possibly, but not required now | Low/medium because visual overemphasis can change product feel. |

## 8. Visual redesign direction

The eventual card should use a premium dark/card surface that aligns with the accepted Profile rows while preserving the card's higher visual value. It should feel like a compact training identity module, not a generic stats grid.

Recommended direction:

- Use a quieter STRQ card surface and border treatment.
- Give the goal header clearer hierarchy: goal icon, goal title, and optional `goalDescription` should read as the primary identity.
- Refine metric tiles into lighter, more precise items, with less boxiness.
- Keep icons subtle and supportive.
- Use semantic accents as small signals, not full tile domination.
- Use typography consistent with accepted Profile rows.
- Preserve compact density so the Profile screen does not become taller for the same information.
- Avoid all-grey blandness; this card still needs coaching-state energy.
- Avoid too many competing colors in one row.
- Avoid turning Streak into a game layer.
- Do not introduce orange as a default reward, CTA, or selected-state identity.

A safe visual strategy is goal-first, metrics-second: one calm card shell, a stronger goal header, and three refined metric tiles where color is limited to icons, small markers, or thin accent strokes.

## 9. Risks and protected logic

Behavior risk:

- Low for `fitnessIdentity` itself because it has no direct actions or mutations.
- Medium if a future refactor accidentally changes the Nutrition/Streak branch, goal-description visibility, value formatting, or state reads.

Product meaning risk:

- High. Recovery, Sleep, Nutrition, and Streak are not decorative stats; they imply coaching interpretation.
- Changing colors can change what users think STRQ is telling them to do.

Data risk:

- Medium. The card reads derived values. Any future pass must not change calculations, collection ordering, thresholds, clamping, persistence, or data freshness.

Visual risk:

- Medium/high. The card sits early in Profile and can either lift the screen or make it feel like mixed-era UI.
- Too much semantic color can look noisy; too little can make the card bland and less useful.

Owner approval requirement:

- Required before any semantic color threshold change.
- Required before changing copy or metric meaning.
- Required before changing the Nutrition/Streak branch.
- Recommended before any metric-tile redesign that changes accent intensity or state hierarchy.

Protected logic:

- recovery score calculation
- sleep average calculation
- nutrition adherence calculation
- streak logic
- profile goal behavior
- `goalDescription`
- `vm.isEarlyStage`
- `vm.profile.nutritionTrackingEnabled`
- localization/copy
- profile state

## 10. Candidate implementation phases

1. Plan completed
   - This document records current implementation, visual diagnosis, semantic diagnosis, data dependencies, token audit, risks, and the next prompt.

2. FitnessIdentity shell-only pass
   - Update only the outer card shell, spacing, typography alignment, and goal header treatment.
   - Preserve all metric colors, icons, values, thresholds, and branches.

3. Metric tile visual pass
   - Refine `statusChip` or a replacement private helper so metric tiles feel less blocky and more premium.
   - Preserve all values and existing semantic color sources unless phase 4 has approved changes.

4. Semantic color refinement pass
   - Apply approved semantic color rules for Recovery, Sleep, Nutrition, and Streak.
   - Do not use `successGreen` blindly; if green is used, choose a deep emerald or muted green family deliberately.

5. Rork polish pass
   - Use owner simulator screenshots across small and large iPhone viewports and relevant states.
   - Tune optical balance only after visual evidence, without broad Profile redesign.

Do not do all phases at once.

## 11. Exactly one recommended next implementation prompt

Selected recommendation: A. FitnessIdentity shell-only migration.

Why: the current card is visually older than the accepted Profile sections, but the metric colors carry product meaning. A shell-only pass can improve the card's premium fit while deliberately preserving all metric values, thresholds, semantic color sources, and the Nutrition/Streak branch. This gets visual progress without pretending the semantic color system is already approved.

```text
Work in repo: C:\Users\maxwa\Documents\GitHub\rork-strq

Goal:
Migrate only the Profile `fitnessIdentity` shell in `ios/STRQ/Views/ProfileView.swift`. This is a shell-only visual pass. Preserve all metric values, icons, semantic color sources, thresholds, branches, and behavior exactly.

Exact target file:
- `ios/STRQ/Views/ProfileView.swift`

Exact target section/helper:
- `private var fitnessIdentity`
- `private func statusChip(...)` only if needed for shell spacing or typography alignment

Allowed edits:
- `ios/STRQ/Views/ProfileView.swift`, scoped only to `fitnessIdentity` and `statusChip`
- `docs/migration-progress-log.md`, one concise entry after verification

Forbidden edits:
- Do not edit `STRQDesignSystem.swift`, `STRQPalette.swift`, `ForgeTheme.swift`, `ContentView.swift`, `STRQApp.swift`, assets, fonts, `Localizable.xcstrings`, RevenueCat/store files, ViewModels, Services, Models, Watch, Widget, Live Activity, project files, tests, or protected logic.
- Do not edit Profile `controlsSection`, Training Setup static rows, Body & Nutrition static rows, Body & Nutrition action buttons, `trackingToggleCard`, `coachingStyleRow`, subscription, account, danger, footer, sheets, alerts, paywall, iCloud/account, reset, analytics, onboarding, active workout, plan generation, progression, or persistence.
- Do not change copy or localization.
- Do not add new assets or replace icons.
- Do not change semantic color thresholds or token definitions.
- Do not introduce orange as a default accent, CTA, selected state, reward state, or streak treatment.

Behavior preservation list:
- Keep `vm.profile.goal.displayName`.
- Keep `vm.profile.goal.symbolName`.
- Keep `goalDescription` and its `!vm.isEarlyStage` visibility.
- Keep `vm.effectiveRecoveryScore` and the displayed percent format.
- Keep `vm.averageSleepHours` and the displayed `%.1fh` format.
- Keep `vm.profile.nutritionTrackingEnabled`.
- Keep `vm.weeklyNutritionAdherence` and the displayed integer percent format.
- Keep `vm.streak`.
- Keep `ForgeTheme.recoveryColor(for: vm.effectiveRecoveryScore)`.
- Keep `ForgeTheme.sleepColor(for: vm.averageSleepHours)`.
- Keep Nutrition color expression `vm.weeklyNutritionAdherence >= 0.8 ? STRQPalette.success : STRQBrand.steel`.
- Keep Streak color `STRQBrand.steel`.
- Keep the Nutrition/Streak conditional branch exactly.
- Keep all SF Symbols unless a future approved prompt provides exact mappings.
- Do not add actions, navigation, sheets, analytics, persistence, or mutations.

Visual objective:
- Make `fitnessIdentity` feel aligned with the accepted calm dark/carbon Profile style while preserving its compact identity-plus-state role.
- Improve the card shell, goal hierarchy, typography consistency, border/surface restraint, and metric tile refinement.
- Keep semantic colors as small current-state signals and do not make the card noisy or game-like.
- Avoid all-grey blandness.

Verification commands:
- `git status --short --branch`
- `git diff --name-only`
- `git diff -- ios/STRQ/Views/ProfileView.swift docs/migration-progress-log.md`
- `git diff --name-only -- ios/STRQ/Utilities ios/STRQ/ContentView.swift ios/STRQ/STRQApp.swift ios/STRQ/ViewModels ios/STRQ/Services ios/STRQ/Models ios/STRQWidget ios/STRQWatch ios/STRQ/Assets.xcassets ios/STRQ/Localizable.xcstrings ios/STRQ.xcodeproj ios/STRQTests`
- `rg -n "private var fitnessIdentity|private func statusChip|goalDescription|effectiveRecoveryScore|averageSleepHours|nutritionTrackingEnabled|weeklyNutritionAdherence|streak|ForgeTheme\\.recoveryColor|ForgeTheme\\.sleepColor|STRQPalette\\.success|STRQBrand\\.steel" ios/STRQ/Views/ProfileView.swift`
- `rg -n "recoveryColor|sleepColor|signalGreen|success|warning|danger|recovery|sleep" ios/STRQ/Utilities/ForgeTheme.swift ios/STRQ/Utilities/STRQPalette.swift ios/STRQ/Utilities/STRQDesignSystem.swift`
- `rg -n "Sandow" ios/STRQ/Views ios/STRQ/ContentView.swift`

Rork QA checklist:
- Open Profile on a small iPhone viewport.
- Open Profile on a large iPhone viewport.
- Confirm `fitnessIdentity` sits visually with the accepted Profile sections.
- Confirm the goal icon, title, and optional goal description are readable and not clipped.
- Confirm Recovery, Sleep, and Nutrition metric states remain recognizable.
- Confirm nutrition tracking enabled shows Nutrition.
- Confirm nutrition tracking disabled shows Streak.
- Confirm the card does not feel all-grey, overly colorful, or game-like.
- Confirm accepted Profile sections remain unchanged.
- Confirm no crash or visual jump on Profile load.

Report-back format:
1. Files changed
2. Protected files unchanged
3. Exact Profile helper changed
4. Visual summary
5. Behavior preserved
6. Semantic colors preserved
7. Verification command results
8. Rork QA needed/completed
9. Risks or owner approval gates
```

## 12. Rork QA checklist

Rork QA is not required for this docs-only pass because no Swift files changed.

Rork QA is required after any future `fitnessIdentity` implementation pass. Owner should check:

- Profile opens successfully.
- Small iPhone viewport.
- Large iPhone viewport.
- Early-stage profile, where `goalDescription` is hidden.
- Established profile, where `goalDescription` is visible.
- Nutrition tracking enabled, showing Nutrition.
- Nutrition tracking disabled, showing Streak.
- Recovery high/moderate/low examples if states can be seeded.
- Sleep high/moderate/low examples if states can be seeded.
- Nutrition high and low adherence examples if states can be seeded.
- No clipped title, description, metric value, metric label, or icon.
- No noisy color competition between Recovery, Sleep, Nutrition, and Streak.
- No accidental orange default treatment.
- Accepted `controlsSection`, Training Setup rows, Body & Nutrition rows/buttons, `trackingToggleCard`, and `coachingStyleRow` remain visually unchanged unless a future prompt explicitly scopes them.
