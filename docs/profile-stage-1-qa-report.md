# Profile Stage 1 QA Report

## 1. Executive summary

Profile Stage 1 is accepted as a visually much improved Profile consolidation, not as a release-final Profile.

The migrated Profile areas now read more consistently as calm, dark, carbon, and STRQ-owned. The screen has moved away from the older mixed Forge/local/orange styling in most visible rows and cards. Current static inspection also confirms the protected closures for reset, account, subscription, restore purchases, plan regeneration, and nutrition refresh behavior remain present in `ProfileView.swift`.

Stage 1 should pause here. The remaining work is not one more broad polish pass; it is targeted future planning and state-specific QA for global accent, signed-in account, Pro-active verification, paywall, semantic metric colors, and optional footer polish.

## 2. Completed Profile migration areas

| Area | Stage 1 status |
|---|---|
| `controlsSection` | Accepted. Notifications & Tools uses the migrated STRQ section/list shell while preserving notification navigation, restore purchases, regenerate plan, and DEBUG lab entry behavior. |
| `trainingSetup` | Accepted. Static rows use the migrated STRQ section/card/list treatment. Focus muscle chips remain outside the accepted static-row scope. |
| `bodyNutrition` static rows | Accepted. Height, Weight, Age, Calories, Protein, and Goal rows use the migrated STRQ card/list treatment. |
| `bodyNutrition` action buttons | Accepted. Edit Targets and Sleep Log action shells were migrated while preserving sheet triggers and conditional Edit Targets visibility. |
| `trackingToggleCard` | Accepted. Toggle card shell and active-state accent were refined while preserving the custom binding setter and refresh order. |
| `coachingStyleRow` | Accepted. Profile entry reads as a premium personalization row and still routes to `CoachingPreferencesView(vm: vm)`. |
| `CoachingPreferencesView` entry relation | Accepted for the Profile entry relationship. The row still presents the coaching preferences destination; deeper destination polish was handled separately and should not be reopened from this report. |
| `fitnessIdentity` current state | Accepted for Stage 1. Shell and metric tiles are calmer and clearer, while existing metric values, thresholds, icons, and semantic color sources remain unchanged. |
| non-Pro subscription card | Accepted. The Profile STRQ Pro upsell card uses a calmer Pro accent treatment while preserving paywall analytics and presentation. |
| Pro-active subscription card static implementation | Implemented and accepted by static/code review for Stage 1. Visual QA remains caveated unless a Pro state can be simulated or accessed. |
| signed-out `accountSection` | Accepted. Signed-out Sync & Restore shell uses a calmer STRQ card while preserving the native Sign in with Apple control and post-sign-in restore/upload logic. |
| `dangerSection` | Accepted. Danger Zone shell is calmer and semantically destructive while preserving the reset alert gate. |

## 3. Areas accepted with caveats

- Global tint still makes the Reset Alert `Cancel` button orange because the main `TabView` in `ContentView.swift` applies `.tint(STRQPalette.energyAccent)`.
- Signed-in `accountSection` has not been visually QA'd and still uses the older signed-in shell/action-row treatment.
- Pro-active subscription card has not been visually QA'd unless a Pro state is available.
- Semantic colors are not globally finalized; recovery, sleep, nutrition, streak, warning, success, and selected-state meanings need a broader pass.
- The paywall itself was not migrated in Stage 1.
- The signed-out account Apple button should remain native and should not be restyled into a STRQ CTA.
- Destructive reset must never be tested accidentally; only the alert appearance and Cancel behavior should be checked unless the owner explicitly approves disposable-data reset testing.

## 4. Known remaining debt

- App-level/global accent migration remains pending.
- Broader orange/warm-accent debt remains in system tint, tab selection, Dashboard/Today, paywall, onboarding, active workout, readiness, Coach, and older Forge surfaces.
- Signed-in account/iCloud state needs a separate state-mapped shell pass later.
- Pro-active subscription branch needs real or simulated Pro-state visual QA.
- Paywall needs planning only before any implementation because RevenueCat and purchase behavior are protected.
- Profile footer remains basic and low priority.
- Training Setup focus muscle chips still use an older chip style, but they are contained and lower priority than global accent and state QA.

## 5. Protected behavior status

Current static inspection confirms these protected behaviors are still represented in `ProfileView.swift`:

- Reset remains protected by the `Reset All Data?` alert. The row sets `showResetAlert = true`; only the destructive alert action calls `vm.resetAllData()`.
- Sign in with Apple logic remains protected. The native `SignInWithAppleButton(.signIn)` still calls `vm.account.configureRequest(request)`, then `vm.account.handleCompletion(result)`, then conditionally restores from iCloud or uploads after successful sign-in.
- Paywall and manage-subscription logic remain protected. The non-Pro card still tracks `paywall_viewed` with source `profile` before setting `showPaywall = true`, and the sheet still presents `STRQPaywallView(store: store)`. The Pro branch still tracks `manage_subscription_opened` before setting `showManageSubscription = true`, with `.manageSubscriptionsSheet` intact.
- Restore purchases and regenerate plan remain protected. Restore Purchases still guards `store.isConfigured`, calls `await store.restore()`, and presents the restore message alert. Regenerate Plan still tracks the profile surface event and opens the plan regeneration flow.
- Nutrition toggle refresh order remains protected: set `vm.profile.nutritionTrackingEnabled`, then `vm.refreshNutritionInsights()`, then `vm.refreshCoachingInsights()`, then `vm.refreshDailyState()`.
- Stage 1 expects no RevenueCat, store, model, service, persistence, Watch, Widget, Live Activity, asset, localization, project, or test edits.

## 6. Rork QA checklist completed/required

This docs-only pass does not complete simulator QA. Owner Rork QA is still required before treating Profile as release-ready.

- [ ] Profile full scroll on a small iPhone viewport.
- [ ] Profile full scroll on a large iPhone viewport.
- [ ] Nutrition tracking on/off states.
- [ ] Coaching Style navigation opens and returns safely.
- [ ] Paywall tap from the non-Pro subscription card opens the paywall.
- [ ] Reset alert appears and Cancel works; do not press Reset unless using approved disposable data.
- [ ] Sign in with Apple is visible; do not sign in unless the test state is safe.
- [ ] Restore Purchases flow if safe.
- [ ] Regenerate Plan dialog if safe.
- [ ] Signed-in account state later.
- [ ] Pro state later.

## 7. Visual consistency diagnosis

Profile now feels meaningfully more coherent. The accepted modules share darker carbon surfaces, quieter borders, tighter typography, calmer icon wells, and more deliberate semantic accents. The subscription cards are no longer broad orange CTA banners. Body & Nutrition, Training Setup, Coaching Style, Fitness Identity, controls, signed-out sync, and danger now feel like parts of one Profile system instead of unrelated local helpers.

What still feels old: inherited orange system tint, the signed-in account branch, the basic footer, the paywall destination, some older semantic color mappings, and the small remaining focus-chip treatment.

Profile Stage 1 is good enough to leave for now. The screen should not be over-polished by chasing the footer, replacing the native Apple button, custom-building alerts, or mass-changing semantic colors. The better move is to freeze the accepted areas and handle the remaining debt as small, named future passes.

## 8. Release-readiness assessment for Profile

Classification: Stage 1 visually much improved, but not full release-ready.

Profile should not be called release-final until global accent/system tint, paywall planning, signed-in account states, Pro-active state QA, broader semantic colors, and full small/large Rork QA are handled. The current state is strong enough to move on from Profile Stage 1 without pretending the whole Profile surface is done.

## 9. Recommended next Profile actions

- Plan global tint/accent migration later before changing `ContentView` tint.
- Create a signed-in account shell pass later with iCloud/account state mapping.
- Run Pro-active visual QA when a Pro state can be simulated or accessed.
- Plan a semantic metric color pass later for recovery, sleep, nutrition, streak, warning, success, and selected states.
- Treat footer polish as optional later work.

## 10. Recommended next screen after Profile

Chosen next screen: D. NotificationSettings planning.

This is the only recommended next screen in this report.

Reason: NotificationSettings is the closest safe continuation from the Profile work because it is also a settings-style row/toggle surface, so the accepted Profile visual language can inform the plan without jumping straight into core training, analytics, or revenue surfaces. It should be planning-only first because notification scheduling, permissions, reminder routes, and HealthKit-adjacent behavior are protected.
