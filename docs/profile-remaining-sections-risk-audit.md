# Profile Remaining Sections Risk Audit

## 1. Executive summary

This is a read-only Profile risk audit. It makes no Swift changes and does not implement the next UI pass.

The current accepted Profile migration state is:

- `controlsSection` is accepted and should not be reworked in this pass.
- `trainingSetup` static rows are accepted and should not be reworked in this pass.
- `bodyNutrition` static rows are accepted and should not be reworked in this pass.
- The remaining Profile areas include a mix of low-risk visual rows and high-risk protected logic.
- The next implementation should be one tiny Profile module only.
- This audit does not recommend subscription, account, danger, paywall, iCloud, reset, or restore as the next implementation target.

Recommended next implementation candidate: `coachingStyleRow` visual shell migration only. It is the smallest remaining visible Profile module with useful visual value and no direct revenue, account, reset, toggle-side-effect, sheet, or data mutation behavior.

## 2. Current accepted Profile migration state

Current accepted areas are frozen for now:

| Area | Status | Current implementation state | Rork QA status for this audit | Treat as frozen |
|---|---|---|---|---|
| `controlsSection` | Accepted | Uses `STRQSectionHeader`, tokenized list shell, `STRQIconContainer`, `STRQIconView`, `STRQColors`, and controls-specific row helpers. | Owner context says accepted after Rork QA-driven typography and optical-balance fixes. | Yes |
| `trainingSetup` static rows | Accepted | Uses `STRQSectionHeader`, `trainingSetupInfoRow`, `STRQColors.cardSurface`, `STRQRadii.md`, `STRQColors.borderMuted`, `STRQTypography`, and `STRQSpacing`. | Owner context says accepted. | Yes |
| `bodyNutrition` static info rows | Accepted | Uses `STRQSectionHeader`, `bodyNutritionInfoRow`, `STRQColors.cardSurface`, `STRQRadii.md`, `STRQColors.borderMuted`, `STRQTypography`, and `STRQSpacing`. | Owner context says accepted. | Yes |

Frozen means:

- Do not tune row typography, dividers, padding, title scale, or optical emphasis in the accepted sections during the next pass.
- Do not include accepted rows in a broad Profile cleanup.
- Do not re-open the Body & Nutrition static row split. The remaining Body & Nutrition work is only the toggle card and action buttons.
- Do not use a remaining-section pass as an excuse to touch `controlsSection` restore purchases, regenerate plan, notification route, or DEBUG Design System Lab behavior.

## 3. Remaining Profile section inventory

Line numbers reference the static inspection of `ios/STRQ/Views/ProfileView.swift` during this audit.

| Remaining area | File section / helper | Current visual system used | User-facing purpose | Visible actions | State dependencies | Navigation / sheet / alert dependencies | Protected logic dependencies | Current Forge / STRQ / local helper usage | Fits near accepted style |
|---|---|---|---|---|---|---|---|---|---|
| `profileHeader` | `private var profileHeader`, around line 426 | Local `HStack`, `Circle`, system rounded fonts, steel gradient, local badge capsule | Shows athlete name, training level, goal, and profile summary | None | `vm.profile.name`, `vm.profile.trainingLevel`, `vm.profile.goal`, `vm.isEarlyStage` through `profileHeaderSummary` | None | Read-only profile state; brand-sensitive top-of-screen identity | Uses `STRQBrand.steelGradient`, `STRQBrand.steel`, local layout, no STRQ primitive | Yes visually, but it is broad and brand-sensitive |
| `subscriptionSection` | `private var subscriptionSection`, around line 323 | Local card/button layouts, system background, steel/accent gradients, success pill | Shows Pro status or Pro upsell entry | Manage Subscription, open Paywall | `store.isPro`, `store.subscriptionStatusText`, `store.subscriptionPlanName` | `STRQPaywallView`, `.manageSubscriptionsSheet`, `showPaywall`, `showManageSubscription` | RevenueCat/store-facing behavior and analytics | Uses `STRQBrand.steelGradient`, `STRQBrand.accentGradient`, `STRQPalette.success`, SF Symbols, `proPillarChip` | Visually yes, but behavior risk blocks implementation |
| `fitnessIdentity` | `private var fitnessIdentity`, around line 468 | Local card, divider, local `statusChip`, dark surface, steel gradient | Summarizes goal, recovery, sleep, nutrition adherence or streak | None | `vm.profile.goal`, `vm.isEarlyStage`, `vm.effectiveRecoveryScore`, `vm.averageSleepHours`, `vm.profile.nutritionTrackingEnabled`, `vm.weeklyNutritionAdherence`, `vm.streak` | None | Read-only, but product interpretation risk for recovery, sleep, nutrition, streak, and goal language | Uses `ForgeTheme.recoveryColor`, `ForgeTheme.sleepColor`, `STRQPalette.success`, `STRQBrand.steel`, SF Symbols, local `statusChip` | Yes, but needs semantic planning first |
| `coachingStyleRow` | `private var coachingStyleRow`, around line 691 | Local `NavigationLink` card, steel gradient icon, capsule label, local chips | Opens coaching preferences and previews tone/emphasis/density | Tap row opens `CoachingPreferencesView(vm: vm)` | `vm.profile.coachingPreferences.tone`, `.emphasis`, `.density` | NavigationLink only | Preserve route and displayed preference values; no direct mutation in the row | Uses `Image(systemName:)`, `STRQBrand.steelGradient`, `STRQBrand.steel`, local `styleChip` | Yes. Best immediate fit |
| `trackingToggleCard` | `private var trackingToggleCard`, around line 649 | Local `Toggle` card, system grouped background, success/info icon colors | Enables or disables Physique & Nutrition Coaching | Toggle on/off | `vm.profile.nutritionTrackingEnabled` | None directly, but binding has side effects | `vm.profile.nutritionTrackingEnabled = newValue`, `vm.refreshNutritionInsights()`, `vm.refreshCoachingInsights()`, `vm.refreshDailyState()` | Uses `Image(systemName:)`, `STRQPalette.success`, `STRQPalette.info`, `STRQBrand.cardBorder`, local Binding | Visually yes, but side effects require guardrails |
| Body & Nutrition action buttons | Inside `private var bodyNutrition`, around lines 615-644 | Local `Button` + `Label`, steel-tinted pill buttons | Opens nutrition target editing and sleep logging | `Edit Targets`, `Sleep Log` | `vm.profile.nutritionTrackingEnabled` controls whether Edit Targets appears | `showNutritionSettings`, `showSleepLog`, `NutritionSettingsView`, `SleepLogView` | Sheet entry points to persistence-affecting forms; row actions themselves only present sheets | Uses `Label(systemImage:)`, `STRQBrand.steel`, `.strqPressable`, local button styling | Yes, but action/sheet checks make it second-tier |
| `accountSection` | `private var accountSection`, around line 122 | `ForgeSectionHeader`, local cards, system backgrounds, Apple sign-in control, local action rows | iCloud sync, restore local device from cloud, sign out, sign in | Restore This Device, Sign Out, Sign in with Apple | `vm.account.account`, `vm.account.isSignedIn`, `vm.cloudSync.status`, `vm.cloudSync.isAvailable`, `vm.cloudSync.lastSyncText`, `vm.cloudSync.hasRemoteSnapshot`, `vm.workoutHistory.isEmpty` | Sign-out alert, cloud restore confirm alert, cloud restore message alert | Sign in with Apple, iCloud restore/upload, account sign-out | Uses `ForgeSectionHeader`, `Image(systemName:)`, `STRQBrand.steelGradient`, `STRQBrand.cardBorder`, `STRQPalette.warning/success`, `SignInWithAppleButton`, local `accountActionRow` | Visually yes, but protected |
| `dangerSection` | `private var dangerSection`, around line 827 | `ForgeSectionHeader`, local `controlRow`, system grouped background | Destructive data reset entry | Reset All Data | `showResetAlert` | Reset alert | `vm.resetAllData()` | Uses `ForgeSectionHeader`, `controlRow`, SF Symbol, red, `STRQBrand.cardBorder` | Not a safe visual target until reset guardrails are approved |
| `footerSection` | `private var footerSection`, around line 798 | Plain legal links and caption text | Privacy, Terms, Support, app version | Legal links; hidden long press on version | Bundle version/build | `showMediaDiagnostics` sheet | Hidden long press opens `MediaDiagnosticsView` | Uses `Link`, `Text`, `.onLongPressGesture`, no STRQ primitive | Low visual value; hidden behavior makes it poor next target |
| `trainingSetup` focus muscles / `ForgeChip` area | Inside `private var trainingSetup`, around lines 572-585 | Horizontal `ScrollView`, `Text("Focus:")`, `ForgeChip` | Shows selected focus muscles | None | `vm.profile.focusMuscles` | None | Read-only generated/profile display; preserve order and labels | Uses `ForgeChip`, local horizontal layout, accepted static rows nearby | Yes, but should be isolated from accepted static rows |

## 4. Protected behavior map

Protected behavior found in or adjacent to remaining Profile areas:

| Area | Protected behavior and calls | Audit guidance |
|---|---|---|
| Profile body global | `Analytics.shared.track(.profile_viewed, ["pro": store.isPro ? "true" : "false"])`; if Pro, `Analytics.shared.track(.subscription_active_viewed)` | Do not change `onAppear`, event names, properties, or timing in a visual pass. |
| `subscriptionSection` | `Analytics.shared.track(.manage_subscription_opened)`; `showManageSubscription = true`; `.manageSubscriptionsSheet(isPresented: $showManageSubscription)`; `Analytics.shared.track(.paywall_viewed, ["source": "profile"])`; `showPaywall = true`; `.sheet(isPresented: $showPaywall) { STRQPaywallView(store: store) }`; `StoreViewModel` reads | Protected revenue/account surface. Planning only until owner approves a revenue pass. |
| Accepted `controlsSection` | `store.isConfigured`; `store.restoreMessage`; `Task { await store.restore() }`; `showRestoreMessage = true`; `Analytics.shared.track(.regenerate_plan_dialog_opened, ["surface": "profile"])`; `showPlanRegenerationDialog = true`; `NotificationSettingsView(vm: vm)`; DEBUG `STRQDesignSystemPreviewView()` | Accepted and frozen. Do not rework while touching remaining areas. |
| `accountSection` signed-in state | `showCloudRestoreConfirm = true`; restore confirm alert calls `vm.restoreFromCloud(force: true)` and maps cloud restore messages; `showSignOutAlert = true`; sign-out alert calls `vm.account.signOut()` | Protected iCloud/account/data behavior. Implementation not ready. |
| `accountSection` signed-out state | `SignInWithAppleButton(.signIn)`; `vm.account.configureRequest(request)`; `vm.account.handleCompletion(result)`; if signed in, either `_ = vm.restoreFromCloud(force: false)` or `vm.uploadToCloud()` | Protected account/iCloud behavior. Do not restyle in an implementation pass without owner approval and state-by-state QA. |
| `trackingToggleCard` | Binding setter calls `vm.profile.nutritionTrackingEnabled = newValue`, then `vm.refreshNutritionInsights()`, `vm.refreshCoachingInsights()`, `vm.refreshDailyState()` | Do not convert to `STRQToggleRow` until a prompt explicitly preserves the custom setter and refresh order. |
| Body & Nutrition action buttons | `showNutritionSettings = true`; `showSleepLog = true`; sheets present `NutritionSettingsView(vm: vm)` and `SleepLogView(vm: vm)` | Button shell can be planned later, but sheet presentation and conditions must remain exact. |
| `dangerSection` | Reset row sets `showResetAlert = true`; reset alert destructive button calls `vm.resetAllData()` | Protected destructive data behavior. No implementation without owner approval. |
| `footerSection` | App version text has `.onLongPressGesture(minimumDuration: 1.2) { showMediaDiagnostics = true }`; sheet presents `MediaDiagnosticsView()` | Hidden diagnostics route should not be disturbed by cosmetic footer changes. |
| `coachingStyleRow` | `NavigationLink { CoachingPreferencesView(vm: vm) }` | Preserve route exactly. No copy, preference mapping, or `CoachingPreferencesView` changes. |
| `fitnessIdentity` | Read-only recovery/sleep/nutrition/streak values from app state; colors from `ForgeTheme.recoveryColor(for:)`, `ForgeTheme.sleepColor(for:)`, `STRQPalette.success` | No direct calls, but semantic interpretation is product-sensitive. Plan before changing. |
| `profileHeader` | Read-only profile state and early-stage summary | No protected calls, but this is top-level identity and copy-sensitive. |
| `trainingSetup` focus chips | Read-only `vm.profile.focusMuscles` display | Preserve muscle order, display names, scroll behavior, and accepted static rows. |

## 5. Visual debt map

| Area | Current style debt | Remaining Forge / old system use | Conflict with accepted migrated style | Likely later primitive | Safer helper strategy |
|---|---|---|---|---|---|
| `profileHeader` | Local avatar, badge, typography, and summary hierarchy are not tokenized. | `STRQBrand.steelGradient`, `STRQBrand.steel`, system rounded fonts | Medium. It sits above accepted rows and sets the Profile tone. | `STRQAvatar`, `STRQBadge`, `STRQColors`, `STRQTypography`, maybe `STRQSurface` only if a header shell is approved | Custom private header helper is safer than forcing a generic card. |
| `subscriptionSection` | Pro card and upsell card use old gradients, local chips, and revenue CTA styling. | `STRQBrand.accentGradient`, `STRQBrand.steelGradient`, `STRQPalette.success`, local `proPillarChip` | High visual debt, but protected behavior dominates. | Planning only; later `STRQSurface`, `STRQBadge`, `STRQChip`, exact CTA primitive | Custom private revenue card with explicit owner approval. |
| `fitnessIdentity` | Local metric/status chips and semantic colors are not aligned with STRQ primitive policy. | `ForgeTheme.recoveryColor`, `ForgeTheme.sleepColor`, `STRQPalette.success`, `STRQBrand.steel` | Medium/high because it neighbors accepted row style and interprets coaching state. | `STRQCard`, `STRQMetricCard`, `STRQBadge`, `STRQIconContainer` after semantic map | Custom private summary card is safer than generic metric cards until semantics are approved. |
| `coachingStyleRow` | Local navigation card, icon well, `PERSONAL` badge, and chips remain old-style. | `STRQBrand.steelGradient`, `STRQBrand.steel`, SF Symbols, local `styleChip` | Medium. It is visually close to the accepted style but still old-system. | `STRQSurface` or `STRQCard`, `STRQChip`, `STRQColors`, `STRQTypography`, `STRQSpacing`, `STRQRadii` | A custom private `coachingStyleChip` using STRQ tokens is safer than overfitting generic chips if icons do not map cleanly. |
| `trackingToggleCard` | Local toggle card uses system grouped background and old success/info colors. | `STRQPalette.success`, `STRQPalette.info`, `STRQBrand.cardBorder` | Medium. It sits inside the partly migrated Body & Nutrition section. | `STRQToggleRow` or custom tokenized toggle card | Custom helper preserving the exact Binding setter is safer than direct primitive swap. |
| Body & Nutrition action buttons | Two local steel pill buttons still use old color tokens and SF Symbol labels. | `STRQBrand.steel`, `Label(systemImage:)`, local button styling | Medium. Static rows are migrated; buttons now look like leftovers. | `STRQButton.secondary` or custom tokenized action buttons | Custom private action button may be safer because `STRQButton` production CTA behavior is still target-specific. |
| `accountSection` | `ForgeSectionHeader`, old cards, SF Symbols, status badge, Apple sign-in styling. | `ForgeSectionHeader`, `STRQBrand`, `STRQPalette`, system backgrounds | High visual mismatch, but protected account/iCloud behavior blocks implementation. | Planning only; later `STRQSectionHeader`, `STRQSurface`, `STRQBadge`, `STRQListItem` | Dedicated account card helper with explicit account-state QA. |
| `dangerSection` | Old Forge header and local row, but destructive clarity is more important than visual parity. | `ForgeSectionHeader`, `controlRow`, `STRQBrand.cardBorder` | Medium visual mismatch. | Planning only; maybe `STRQSectionHeader` and native destructive row later | Keep current until owner approves reset-zone pass. |
| `footerSection` | Minimal token debt, low polish value. | Local legal links and caption text | Low. It does not compete with migrated modules. | Possibly `STRQTypography` only | Leave alone unless legal/footer pass is explicitly scoped. |
| Focus muscles / `ForgeChip` | `ForgeChip` remains directly beside accepted `trainingSetup` rows. | `ForgeChip` | Medium but contained. | `STRQChip` passive chips | Direct `STRQChip` can work later, but isolate from static rows. |

## 6. Risk rating by section

| Section | Visual value if migrated | Behavior risk | Product risk | Revenue/account/data risk | Owner approval required | Rork QA complexity | Recommended timing | Reason |
|---|---|---|---|---|---|---|---|---|
| `coachingStyleRow` | Medium | low | low | none | no, if visual shell only | low | now | One helper, one navigation route, passive preference chips, no direct mutation. |
| Body & Nutrition action buttons | Medium | medium | medium | low | no, if only button shell and sheet triggers unchanged | medium | later | Useful cleanup after accepted static rows, but it opens nutrition/sleep sheets. |
| Focus muscles / `ForgeChip` area | Low/medium | low | low | none | no, if display-only | low | planning only | Display-only, but should avoid reworking accepted training rows. |
| `profileHeader` | High | low | medium/high | none | yes | medium | later | Top-level identity is brand-sensitive and broader than a row pass. |
| `fitnessIdentity` | High | low/medium | high | none | yes for implementation | medium/high | planning only | Recovery, sleep, nutrition, and streak semantics need a state map. |
| `trackingToggleCard` | Medium/high | high | medium/high | medium | yes for implementation | high | planning only | Toggle setter has refresh side effects that must remain exact and ordered. |
| `subscriptionSection` | High | high | high | high | yes | high | protected | RevenueCat, paywall, manage-subscription, and analytics behavior. |
| `accountSection` | High | high | high | high | yes | high | protected | iCloud, Sign in with Apple, restore, upload, sign-out, cloud messages. |
| `dangerSection` | Low/medium | high | high | high | yes | high | protected | Reset data is destructive and owner-gated. |
| `footerSection` | Low | medium | low | low | yes if hidden diagnostics changes | medium | later | Hidden long press opens diagnostics; low visual payoff. |

## 7. Candidate ranking for next micro-pass

### 1. `coachingStyleRow` visual shell migration

- Exact target file: `ios/STRQ/Views/ProfileView.swift`
- Exact target section/helper: `private var coachingStyleRow` and only private helpers needed for that row
- Objective: Bring the Coaching Style row shell, badge, and passive chips into the accepted Profile visual language while preserving the NavigationLink and displayed preferences.
- Allowed primitives: `STRQSurface` or `STRQCard`, `STRQChip` if labels/icons remain exact, `STRQColors`, `STRQTypography`, `STRQSpacing`, `STRQRadii`, `STRQIconView(.chevronRight)` for the chevron if desired.
- Forbidden areas: subscription, account, danger, footer, `trackingToggleCard`, Body & Nutrition buttons, accepted static rows, `controlsSection`, `CoachingPreferencesView`, view models, services, assets, localization.
- Behavior preservation list: Keep `NavigationLink { CoachingPreferencesView(vm: vm) }`; keep row order; keep `prefs.tone`, `prefs.emphasis`, `prefs.density`; keep existing labels/copy; keep tap area; no analytics changes.
- Owner approval required: No, if it is strictly visual and one helper only.
- Rork QA checklist: Profile root small and large iPhone; Coaching Style row visible; tap opens Coaching Preferences; back returns to Profile; chips do not clip; adjacent Profile sections unchanged.
- Why it should be next: It is the smallest useful remaining implementation target with the least protected behavior.

### 2. Body & Nutrition action buttons visual shell only

- Exact target file: `ios/STRQ/Views/ProfileView.swift`
- Exact target section/helper: Button cluster inside `private var bodyNutrition`, lines around 615-644
- Objective: Make `Edit Targets` and `Sleep Log` buttons visually match the accepted Body & Nutrition rows.
- Allowed primitives: `STRQButton.secondary` or a custom tokenized private action-button helper using `STRQColors`, `STRQTypography`, `STRQSpacing`, `STRQRadii`.
- Forbidden areas: `trackingToggleCard`, `NutritionSettingsView`, `SleepLogView`, accepted static info rows, nutrition persistence, sleep persistence, localization.
- Behavior preservation list: Keep `showNutritionSettings = true`; keep `showSleepLog = true`; keep conditional display of `Edit Targets` only when nutrition tracking is enabled; keep `.strqPressable` or equivalent tactile behavior.
- Owner approval required: No for shell-only; yes if sheet contents or save flows are touched.
- Rork QA checklist: Nutrition tracking on and off states; `Edit Targets` opens Nutrition Settings only when visible; `Sleep Log` opens Sleep Log; no clipping in the button cluster.
- Why it should not be first: It is still simple, but it touches sheet entry points and two Profile states.

### 3. Focus muscles / `ForgeChip` cleanup planning pass

- Exact target file: docs first; later `ios/STRQ/Views/ProfileView.swift`
- Exact target section/helper: `trainingSetup` focus muscle block, lines around 572-585
- Objective: Plan a display-only replacement of `ForgeChip` with passive STRQ chips without touching accepted static rows.
- Allowed primitives: Planning only now; later `STRQChip`, `STRQColors`, `STRQSpacing`.
- Forbidden areas: Accepted `trainingSetupInfoRow` shell, plan generation, onboarding, focus muscle data source, copy/localization.
- Behavior preservation list: Preserve `vm.profile.focusMuscles`, order, `muscle.displayName`, horizontal scroll, hidden state when empty.
- Owner approval required: No for planning; no for later display-only if exact.
- Rork QA checklist: Empty focus list, several focus muscles, long muscle names, horizontal scroll, accepted static rows unchanged.
- Why it should not be first: Visual value is smaller than `coachingStyleRow`, and it should be isolated carefully from an accepted section.

### 4. `trackingToggleCard` read-only/planning pass

- Exact target file: docs first; later `ios/STRQ/Views/ProfileView.swift`
- Exact target section/helper: `private var trackingToggleCard`
- Objective: Create guardrails for a future toggle visual migration without changing the binding or refresh calls.
- Allowed primitives: Planning only now; later `STRQToggleRow` only if the custom setter is preserved exactly, or a custom tokenized toggle card.
- Forbidden areas: Nutrition settings sheet, sleep sheet, nutrition persistence, coaching insights implementation, daily state implementation.
- Behavior preservation list: Preserve getter, setter, assignment, refresh call order, toggle labels, on/off text, toggle tint meaning, accessibility.
- Owner approval required: Yes before implementation.
- Rork QA checklist: Toggle on/off, Body & Nutrition static rows with and without targets, fitnessIdentity nutrition/streak branch, no stale insight display.
- Why it should not be first: The visual change is small but the side effects are important.

### 5. `fitnessIdentity` static card planning pass

- Exact target file: docs first; later `ios/STRQ/Views/ProfileView.swift`
- Exact target section/helper: `private var fitnessIdentity` and `statusChip`
- Objective: Plan a semantic card/metric treatment for goal, recovery, sleep, nutrition, and streak without changing data interpretation.
- Allowed primitives: Planning only now; later `STRQCard`, `STRQMetricCard`, `STRQBadge`, `STRQIconContainer` if state mapping is approved.
- Forbidden areas: Recovery score calculation, sleep average, nutrition adherence, streak logic, copy/localization changes.
- Behavior preservation list: Preserve values, conditional nutrition/streak branch, `goalDescription`, and semantic thresholds.
- Owner approval required: Yes before implementation.
- Rork QA checklist: Early stage, mature profile, nutrition on/off, low/medium/high recovery and sleep examples if owner can seed them.
- Why it should not be first: It has meaningful product interpretation risk.

### 6. `accountSection` planning only

- Exact target file: docs only
- Exact target section/helper: `private var accountSection`, `accountActionRow`, `cloudStatusBadge`, cloud summary helpers
- Objective: Map account/iCloud states for a future visual pass.
- Allowed primitives: Planning only; later `STRQSectionHeader`, `STRQSurface`, `STRQListItem`, `STRQBadge`.
- Forbidden areas: Sign in with Apple request/completion, `restoreFromCloud`, `uploadToCloud`, `signOut`, cloud alerts/messages.
- Behavior preservation list: Preserve every account action, alert, cloud status branch, and message.
- Owner approval required: Yes.
- Rork QA checklist: signed out, sign-in button visible, signed in, unavailable iCloud, failed sync, restore confirm, sign-out confirm.
- Why it should not be next: Account, iCloud, restore, and sign-out are protected data behavior.

### 7. `subscriptionSection` planning only

- Exact target file: docs only
- Exact target section/helper: `private var subscriptionSection`, `proPillarChip`
- Objective: Plan Pro status and upsell visuals without touching purchase/manage behavior.
- Allowed primitives: Planning only; later `STRQSurface`, `STRQBadge`, `STRQChip`, exact button primitive only after owner approval.
- Forbidden areas: `STRQPaywallView`, `StoreViewModel`, RevenueCat, manage subscription sheet, analytics events, copy/localization.
- Behavior preservation list: Preserve `store.isPro` branching, plan/status text, paywall presentation, manage subscription presentation, analytics calls.
- Owner approval required: Yes.
- Rork QA checklist: Pro state, non-Pro state, paywall opens, manage subscription sheet opens, restore purchases elsewhere still works.
- Why it should not be next: Revenue behavior is protected and high-risk.

### 8. `dangerSection` planning only

- Exact target file: docs only
- Exact target section/helper: `private var dangerSection`, `controlRow`, reset alert
- Objective: Define future destructive-row visual rules without touching reset behavior.
- Allowed primitives: Planning only; later `STRQSectionHeader` and a destructive row treatment only after approval.
- Forbidden areas: `vm.resetAllData()`, reset alert copy/buttons, onboarding reset behavior, persistence.
- Behavior preservation list: Preserve `showResetAlert = true`, destructive alert role, cancel role, and `vm.resetAllData()` call.
- Owner approval required: Yes.
- Rork QA checklist: Danger Zone visible, alert copy, Cancel, destructive button role, no accidental reset during QA unless owner explicitly tests it.
- Why it should not be next: Destructive data reset is protected and has low visual payoff.

## 8. Areas not ready for implementation

Do not implement these next:

- `subscriptionSection`, because it includes paywall presentation, RevenueCat/store state, manage subscription behavior, and analytics.
- `accountSection`, because it includes Sign in with Apple, iCloud restore, upload, sign-out, cloud status, and cloud restore alerts/messages.
- `dangerSection`, because it leads to `vm.resetAllData()`.
- `trackingToggleCard`, unless a separate prompt explicitly preserves the custom Binding setter and refresh call order.
- `footerSection`, because the hidden long press opens `MediaDiagnosticsView` and the visual payoff is low.
- `profileHeader`, because it is broad, brand-sensitive, and should follow a clear header/avatar decision.
- `fitnessIdentity`, because recovery, sleep, nutrition, and streak interpretation need semantic guardrails before a visual implementation.
- Any section requiring copy changes or `Localizable.xcstrings` edits.
- Any section that would touch `STRQPaywallView`, `StoreViewModel`, iCloud/account code, reset data, onboarding, active workout, persistence, HealthKit, Watch, Widget, Live Activity, plan generation, progression, analytics, or localization catalogs.

## 9. Recommended next implementation prompt

Recommend exactly one next implementation prompt: A. `coachingStyleRow` visual shell migration.

```text
Work in repo: C:\Users\maxwa\Documents\GitHub\rork-strq

Goal:
Migrate only the Profile `coachingStyleRow` visual shell in `ios/STRQ/Views/ProfileView.swift`. This is a tiny Profile module pass. Preserve behavior exactly.

Exact target file:
- `ios/STRQ/Views/ProfileView.swift`

Exact target section/helper:
- `private var coachingStyleRow`
- Existing or new private helper(s) used only by `coachingStyleRow`, if needed

Allowed edits:
- `ios/STRQ/Views/ProfileView.swift`, scoped only to `coachingStyleRow` and row-private helpers
- `docs/migration-progress-log.md`, one concise entry after verification

Forbidden edits:
- Do not edit subscription, account, danger, footer, `profileHeader`, `fitnessIdentity`, `trackingToggleCard`, Body & Nutrition static rows, Body & Nutrition action buttons, Training Setup static rows, focus muscle chips, or `controlsSection`.
- Do not edit `CoachingPreferencesView`, `STRQDesignSystem.swift`, `STRQDesignSystemPreviewView.swift`, `ContentView.swift`, `STRQApp.swift`, assets, fonts, `Localizable.xcstrings`, RevenueCat/store files, ViewModels, Services, Models, Watch, Widget, Live Activity, project files, tests, or protected logic.
- Do not change copy, localization keys, analytics, navigation, sheets, alerts, persistence, plan generation, progression, onboarding, active workout, HealthKit, iCloud/account, reset, or paywall behavior.
- Do not introduce orange as a default CTA or selected-state identity.

Behavior preservation list:
- Keep `NavigationLink { CoachingPreferencesView(vm: vm) }` exactly.
- Keep the row in the same place in the Profile stack.
- Keep displayed title `L10n.tr("Coaching Style")`.
- Keep displayed badge text `L10n.tr("PERSONAL")`.
- Keep `prefs.tone.displayName`, `prefs.emphasis.displayName`, and `prefs.density.displayName`.
- Keep `prefs.tone.symbolName`, `prefs.emphasis.symbolName`, and `prefs.density.symbolName` unless the prompt names an exact icon mapping.
- Keep the row tap target and chevron behavior.
- Do not modify `vm.profile.coachingPreferences` or `CoachingPreferencesView`.

Allowed STRQ primitives:
- `STRQSurface` or `STRQCard` for the row shell if it improves consistency without nesting cards.
- `STRQChip` only for passive preference chips if labels and icons remain exact.
- `STRQColors`, `STRQTypography`, `STRQSpacing`, `STRQRadii`.
- `STRQIconView(.chevronRight)` may replace the local chevron if behavior and layout are unchanged.
- Existing `Image(systemName:)` may remain for unmapped coaching/preference symbols. Do not guess new `STRQIcon` mappings.

Acceptance criteria:
- Only the scoped `coachingStyleRow` visual shell changes in Swift.
- The row still opens `CoachingPreferencesView(vm: vm)`.
- Preference values and icons are unchanged.
- No subscription/account/danger/paywall/iCloud/reset/toggle/sheet behavior is touched.
- Accepted `controlsSection`, Training Setup static rows, and Body & Nutrition static rows remain unchanged.
- The row visually fits the accepted calm dark/carbon Profile style.
- No orange default CTA treatment is introduced.
- One concise migration-log entry is appended.

Verification commands:
- `git status --short --branch`
- `git diff --name-only`
- `git diff -- ios/STRQ/Views/ProfileView.swift docs/migration-progress-log.md`
- `git diff --name-only -- ios/STRQ/Utilities ios/STRQ/Views/Debug ios/STRQ/ContentView.swift ios/STRQ/STRQApp.swift ios/STRQ/ViewModels ios/STRQ/Services ios/STRQ/Models ios/STRQWidget ios/STRQWatch ios/STRQ/Assets.xcassets ios/STRQ/Localizable.xcstrings`
- `rg -n "private var coachingStyleRow|CoachingPreferencesView|PERSONAL|styleChip|STRQChip|STRQSurface|STRQCard" ios/STRQ/Views/ProfileView.swift`
- `rg -n "showPaywall|STRQPaywallView|showManageSubscription|manageSubscriptionsSheet|SignInWithAppleButton|restoreFromCloud|uploadToCloud|resetAllData|nutritionTrackingEnabled|refreshNutritionInsights|refreshCoachingInsights|refreshDailyState" ios/STRQ/Views/ProfileView.swift`

Report-back format:
1. Files changed
2. Protected files unchanged
3. Exact Profile helper changed
4. Visual summary
5. Behavior preserved
6. Verification command results
7. Rork QA needed/completed
8. Risks or owner approval gates

Rork QA checklist:
- Open Profile on a small iPhone viewport.
- Open Profile on a large iPhone viewport.
- Confirm the Coaching Style row looks aligned with the accepted Profile style.
- Confirm the row title, PERSONAL badge, and three preference chips are readable with no clipping.
- Tap Coaching Style and confirm `CoachingPreferencesView` opens.
- Navigate back and confirm Profile state is unchanged.
- Confirm subscription, account, danger, Body & Nutrition, Training Setup, and Notifications & Tools still look and behave unchanged.
```

## 10. Rork QA expectations for the recommended next pass

Rork simulator QA is not required for this docs-only audit. It is required after the future `coachingStyleRow` implementation pass.

For that future pass, owner QA should check:

- Profile initial load in the Rork simulator.
- Small iPhone viewport and large iPhone viewport.
- Coaching Style row visual alignment with accepted Profile sections.
- No clipped title, badge, preference chip, SF Symbol, or chevron.
- Tap row opens Coaching Preferences.
- Back navigation returns to Profile.
- No unexpected changes to Profile header, subscription, Body & Nutrition, Training Setup, Notifications & Tools, Sync & Restore, Danger Zone, or footer.
- No orange-default CTA treatment appears.
- The app does not crash or visually jump when returning from Coaching Preferences.

## 11. Lessons from previous Profile passes

- `controlsSection` taught us to separate technical mismatch from optical balance.
- `trainingSetup` worked well because shared helper reuse was checked before implementation.
- `bodyNutrition` worked well because static rows were separated from toggle/actions.
- Future Profile passes must keep scope tiny and preserve behavior exactly.
- Accepted Profile areas should stay frozen while the next remaining module is migrated.
- Protected behavior should be mapped before visual work, even when a section looks visually simple.
