# STRQ Global Tint / System Accent Audit

## 1. Executive summary

Rork QA showed the Reset Alert Cancel button in orange. The likely cause is the inherited SwiftUI tint environment from `ContentView`: the onboarded root `TabView` applies `.tint(STRQPalette.energyAccent)`, and `ProfileView` presents its Reset All Data alert inside that tinted hierarchy.

This is not caused by the accepted Danger Zone row shell. The row uses semantic red locally, while the system alert's non-destructive buttons inherit the app-level tint. The destructive `Reset` action keeps its destructive role and should remain red/system-destructive.

The global tint should not be changed blindly. It likely affects system alerts, confirmation dialogs, navigation affordances, sheet controls, links, buttons, toggles without local tint, and system UI hosted under the main `TabView`.

The recommended next path is D: plan a broader app accent migration before touching global tint. Do not implement a Swift change until the owner approves the target global accent, affected-state QA matrix, and rollback plan.

## 2. Current tint/accent inventory

High-level tint and system accent:

- `ios/STRQ/ContentView.swift:80`: `TabView(...).tint(STRQPalette.energyAccent)`. This is the only high-level inherited tint found.
- `ios/STRQ/STRQApp.swift`: no `.tint`, `.accentColor`, or global accent modifier found.
- `.accentColor(`: no Swift usage found.

Local `.tint` overrides found:

- `ios/STRQ/Views/ProfileView.swift:769`: nutrition tracking toggle uses `activeGreen` or `STRQColors.secondaryAccent`.
- `ios/STRQ/Views/NotificationSettingsView.swift`: multiple toggles use `STRQBrand.steel`.
- `ios/STRQ/Views/SleepLogView.swift`, `SessionEditorSheet.swift`, `ExerciseLibraryView.swift`, and `ActiveWorkoutView.swift`: selected local controls use `STRQBrand.steel`.
- `ios/STRQ/Views/STRQPaywallView.swift:523`: local paywall control uses `.tint(.black)`.
- `ios/STRQ/Views/MuscleFocusView.swift:163`: local control uses `.tint(.white.opacity(0.2))`.
- `ios/STRQ/Utilities/STRQDesignSystem.swift:2484`: `STRQToggleRow` uses `.tint(STRQColors.primaryAccent)`.

Orange/warm accent definitions and aliases:

- `ios/STRQ/Utilities/STRQPalette.swift`: `energyAccent`, `energyAccentSoft`, and `energyAccentGradient` are warm orange.
- `ios/STRQ/Utilities/ForgeTheme.swift`: `STRQBrand.accent` and `STRQBrand.accentGradient` are warm orange; `ForgeTheme.accent` maps to that accent.
- `ios/STRQ/Utilities/STRQDesignSystem.swift`: orange primitive scale, warm accent aliases, `orangeCTA`, `orangeGlow`, `progressOrange`, `STRQComponentStyle.Tone.orange`, and `STRQChip.Tone.orange` exist. The file comments explicitly describe warm/orange as legacy/source-kit compatible rather than the desired default STRQ brand.

High-usage orange/accent areas found by search:

- `STRQBrand.accentGradient`: most frequent in `OnboardingView`, `ActiveWorkoutView`, `STRQPaywallView`, `ReadinessCheckInView`, `CoachTabView`, and several sheets/cards.
- `STRQPalette.energyAccent` / `energyAccentGradient`: concentrated in `DashboardView`, `ForgeTheme`, and `ContentView`.
- Raw/model color names `"orange"` appear in services and models as semantic state names, then are mapped by views/helpers. These are data semantics and should not be mass-edited in a visual pass.

Alert/system button inventory:

- `ProfileView` has reset, sign-out, cloud restore, iCloud sync, and restore-purchases alerts.
- Other system dialogs include `ActiveWorkoutView`, `PlanRegenerationFlow`, and `WeeklyCheckInView`.
- No alert-specific tint override was found.

## 3. Why Reset Alert Cancel is orange

`ProfileView` is hosted inside the main onboarded `TabView` in `ContentView`. That `TabView` applies `.tint(STRQPalette.energyAccent)`.

SwiftUI alert buttons inherit the nearest tint environment for non-destructive actions. The Reset Alert's `Cancel` button has `role: .cancel`, not `role: .destructive`, so it uses the inherited tint. Because the inherited tint is `STRQPalette.energyAccent`, the Cancel button appears orange.

The destructive Reset button is different: it has `role: .destructive`, so the system applies destructive styling instead of the normal inherited accent. The alert copy and reset behavior in `ProfileView` are not the source of the orange Cancel button.

## 4. Current orange/accent debt

The premium visual direction report already states that orange is not the default CTA identity and should be treated as migration debt unless explicitly approved.

Current debt categories:

- Global/system accent debt: `ContentView` sets the main `TabView` tint to `STRQPalette.energyAccent`, which leaks orange into system controls and alerts.
- Custom tab bar debt: selected tab labels/icons and the center Train tab use `STRQPalette.energyAccent` and `energyAccentGradient`.
- CTA/gradient debt: Forge and older production components still use `STRQBrand.accentGradient` for primary CTAs, selected states, and action cards.
- Dashboard debt: Today/Dashboard uses `STRQPalette.energyAccent` in multiple display and progress treatments.
- Protected-flow debt: onboarding, active workout, paywall, readiness, coach, and several training sheets use orange gradients or orange-mapped state colors. These cannot be mass-changed safely.
- Data-semantic debt: services and models emit `"orange"` as a state color name in many places. This may represent warning, fatigue, plateau, nutrition, or coaching state semantics and should be reviewed separately from visual accent migration.

## 5. Risk map for changing global tint

| Area | Likely effect if `ContentView` global tint changes | Risk |
|---|---|---|
| TabView / tab bar | Native `TabView` tint would change. The custom `STRQTabBar` selected state would not fully change unless its explicit `energyAccent` usages are also migrated. Mixed accent risk is high. | High |
| System alerts | Non-destructive buttons such as Cancel and OK would shift away from orange. Destructive roles should remain destructive. This is the desired effect for Reset Alert, but it affects all alerts under the main TabView. | Medium/high |
| Sheets | Sheet-hosted controls, links, toggles, pickers, and done/cancel affordances without local tint could change. Several sheets are training, nutrition, recovery, or subscription adjacent. | High |
| NavigationStack links | Default link/button tint and navigation affordances under each tab can change unless locally styled. Profile rows often use custom foregrounds, but not every screen is migrated. | Medium/high |
| Buttons | Plain/custom buttons with explicit foreground/background may be stable; system-styled buttons without local colors may change. | Medium |
| Toggles | Many important toggles already override tint locally, but any unscoped toggle under the TabView may inherit the new tint. | Medium |
| Sign in with Apple | Native `SignInWithAppleButton` style is explicit and should not visually follow the app tint. The surrounding account screen could still inherit a changed accent for links or alerts. | Low/medium |
| Profile sections | Accepted Profile row shells mostly use explicit STRQ colors. Profile alerts and any unstyled system controls would change. | Medium |
| Onboarding | Not under the onboarded `TabView` branch, so the specific `TabView.tint` does not affect onboarding. Onboarding still has explicit orange gradient debt. | Medium |
| Paywall | Presented from Profile under the tinted hierarchy; local controls may override some tint, but system sheet controls or buttons could be affected. Revenue-sensitive. | High |
| Active workout | Active workout is outside the TabView branch when active, so the `TabView.tint` may not apply there. It still has extensive explicit orange gradient debt and protected behavior. | High |

## 6. Local override options

Option A: leave global tint as-is for now and document debt.

- Safest code-wise, but the Reset Alert Cancel button remains orange.
- Acceptable only if owner agrees the orange system accent debt can ship temporarily.

Option B: change global tint to neutral/white/graphite.

- Likely fixes Reset Alert Cancel and other system accent leakage.
- Not safe as a blind micro-pass because it touches the whole onboarded app environment and can produce mixed tab/paywall/sheet/navigation states.

Option C: locally override tint only for Profile Reset Alert / Danger Zone.

- A `dangerSection` tint override is unlikely to fix the system alert because the alert is attached at the top-level `ProfileView`, not inside the row.
- A `ProfileView`-level tint override could make Profile alerts neutral, but may also affect Profile navigation links, sheet affordances, and all Profile alerts.
- A native SwiftUI alert does not provide a clean per-button tint API for only the Cancel button. A custom alert would be a heavier behavioral and accessibility risk and is not necessary yet.

Option D: plan a broader app accent migration before touching global tint.

- Safest next step. It acknowledges the Reset Alert issue while avoiding an unreviewed global visual change.
- The plan should define the target global tint, what happens to the custom tab bar selected state, which screens are protected, which local overrides remain, and which Rork screenshots are required before code changes.

## 7. Recommended next path

The recommended next path is D: plan a broader app accent migration before touching global tint.

Do not implement a Swift change now. The owner should first approve an accent policy decision and a QA matrix that covers system alerts, the custom tab bar, Profile, Paywall, Dashboard, notification/settings toggles, sheets, navigation links, and protected flows.

This recommendation avoids a blind global accent change. It also avoids introducing a custom alert for one visual symptom when the root issue is inherited app tint plus broader orange migration debt.

## 8. Suggested implementation prompt if appropriate

No Swift implementation prompt is appropriate yet.

Suggested next prompt should be docs-only:

```text
Goal:
Create a docs-only STRQ global accent migration plan. Do not edit Swift.

Scope:
- Inventory every user-visible effect of changing `ContentView`'s `.tint(STRQPalette.energyAccent)`.
- Define the approved target global tint candidate.
- Define whether the custom `STRQTabBar` selected state changes in the same pass or a separate pass.
- Define protected screens/flows and required Rork screenshots.
- Produce one owner-reviewable implementation prompt only after risk is mapped.

Forbidden:
- No Swift changes.
- No custom alerts.
- No mass orange replacement.
- No protected flow changes.
```

## 9. Rork QA checklist

Before any future global tint Swift change, Rork QA should capture:

- Profile Reset Alert: Cancel is neutral/approved accent, Reset remains destructive, copy unchanged.
- Profile Sign Out alert and Restore This Device alert: Cancel/OK styling is acceptable, destructive buttons remain destructive.
- Main tab bar: native TabView behavior and custom `STRQTabBar` selected states are visually coherent.
- Dashboard: no broken selected/day/progress accent hierarchy.
- Coach, Train, Progress, and Profile roots: no unexpected default button/link color regressions.
- Paywall opened from Profile: purchase/restore/manage affordances remain clear and revenue-safe.
- Sheets opened from Profile: nutrition settings, sleep log, restore purchases message, and plan regeneration dialog remain readable.
- Notification settings: toggles remain steel/approved accent and permission flow remains clear.
- Sign in with Apple: native button remains platform-correct.
- Active workout entry/exit: no protected workout UI regression if a future pass reaches that branch.
- Small and large iPhone viewports.
- No orange default system accent remains unless explicitly approved for a scoped state.
