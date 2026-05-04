# Profile Subscription Section Risk Plan

## 1. Executive summary

`subscriptionSection` is high-value and visually important because it is the STRQ Pro entry near the top of Profile. It is one of the first monetization surfaces a user sees after the profile header.

It is also revenue-sensitive and must not be treated as a simple card polish. The section controls the non-Pro paywall entry, the Pro manage-subscription entry, state display from `StoreViewModel`, and subscription analytics.

This pass makes no Swift changes. It is a read-only risk plan for the current Profile STRQ Pro entry.

The next implementation should be tiny. It should preserve all paywall, manage-subscription, store, entitlement, package, product, and analytics behavior exactly.

## 2. Current implementation inventory

`ios/STRQ/Views/ProfileView.swift` defines `private var subscriptionSection` as a local SwiftUI composition rather than a hardened STRQ primitive. The section appears near the top of the Profile stack after `profileHeader` and before `fitnessIdentity`.

Top-level state and presentation around the section:

- `@State private var showPaywall: Bool = false`
- `@State private var showManageSubscription: Bool = false`
- `.sheet(isPresented: $showPaywall) { STRQPaywallView(store: store) ... }`
- `.manageSubscriptionsSheet(isPresented: $showManageSubscription)`
- Profile `onAppear` tracks `.profile_viewed` with `["pro": store.isPro ? "true" : "false"]`.
- Profile `onAppear` also tracks `.subscription_active_viewed` when `store.isPro` is true.

Pro state branch:

- Condition: `if store.isPro`.
- Surface: `VStack(spacing: 0)` with `Color(.secondarySystemGroupedBackground)` and corner radius `14`.
- Border: `STRQBrand.cardBorder`, currently `Color.white.opacity(0.10)`.
- Icon: `Image(systemName: "bolt.fill")`.
- Icon treatment: white icon on `STRQBrand.steelGradient`.
- Title: `L10n.tr("STRQ Pro")`.
- Status copy: `Text(store.subscriptionStatusText)`.
- Plan badge: `Text(store.subscriptionPlanName)`.
- Plan badge color: white text on `STRQPalette.success.opacity(0.8)`.
- Divider: `Divider().opacity(0.3)`.
- Action row: `Button` labeled `L10n.tr("Manage Subscription")`.
- Action row icon: `Image(systemName: "creditcard.fill")`.
- Affordance: `Image(systemName: "chevron.right")`.
- Action behavior: tracks `Analytics.shared.track(.manage_subscription_opened)`, then sets `showManageSubscription = true`.

Non-Pro state branch:

- Condition: `else` when `store.isPro` is false.
- Surface/action: the whole card is a `Button`.
- Tap behavior: tracks `Analytics.shared.track(.paywall_viewed, ["source": "profile"])`, then sets `showPaywall = true`.
- Paywall presentation: the top-level `.sheet(isPresented: $showPaywall)` presents `STRQPaywallView(store: store)`.
- Icon: `Image(systemName: "bolt.fill")`.
- Icon treatment: black icon on `STRQBrand.accentGradient`.
- Title: `L10n.tr("STRQ Pro")`.
- Copy: `L10n.tr("Deeper coaching, plans that evolve, full ecosystem.")`.
- Affordance: `Image(systemName: "chevron.right")`.
- Surface: `Color(white: 0.105)` with corner radius `14`.
- Border: `Color.white.opacity(0.15)`.
- Button style: `.buttonStyle(.plain)`.

Local helper:

- `private func proPillarChip(icon: String, label: String) -> some View`.
- Used only by the non-Pro branch.
- Chip icons:
  - `brain.head.profile.fill` with `L10n.tr("Adaptive")`
  - `arrow.triangle.2.circlepath` with `L10n.tr("Evolving")`
  - `icloud.fill` with `L10n.tr("Sync")`
  - `applewatch` with `L10n.tr("Apple Watch")`
- Chip color: `STRQBrand.steel`.
- Chip surface: `STRQBrand.steel.opacity(0.12)` in a capsule.
- Chip border: `STRQBrand.steel.opacity(0.15)`.
- Chip density: four equal-width chips with very small text and icons.

Store values used directly by the Profile entry:

- `store.isPro`
- `store.subscriptionStatusText`
- `store.subscriptionPlanName`

Store/paywall values used downstream by `STRQPaywallView(store: store)`:

- `store.isPro`
- `store.isLoading`
- `store.currentOffering`
- `store.annualPackage`
- `store.monthlyPackage`
- `store.isPurchasing`
- `store.purchase(package:)`
- `store.restore()`
- `store.subscriptionStatusText`
- `store.subscriptionPlanName`

RevenueCat-facing state and logic in `StoreViewModel`:

- `isConfigured` is derived from RevenueCat API-key configuration.
- `isPro` is updated from `customerInfo.entitlements["pro"]?.isActive == true`.
- `fetchOfferings()` loads RevenueCat offerings and customer info.
- `purchase(package:)` calls `Purchases.shared.purchase(package:)`.
- `restore()` calls `Purchases.shared.restorePurchases()`.
- `subscriptionStatusText` reads active entitlement renewal/expiration state.
- `subscriptionPlanName` maps the active entitlement product to package type when possible, then falls back to product-id string matching.

## 3. Revenue/protected behavior map

| Protected call/state | Where found | Current purpose | Must be preserved |
|---|---|---|---|
| `store.isPro` | `ProfileView` `onAppear` and `subscriptionSection` | Drives analytics property, active-subscription analytics, and Pro vs non-Pro branch. | Preserve branch condition and do not replace with copied local state. |
| `Analytics.shared.track(.profile_viewed, ["pro": ...])` | `ProfileView.onAppear` | Records Profile view with Pro state. | Preserve event name, property key/value shape, and timing. |
| `Analytics.shared.track(.subscription_active_viewed)` | `ProfileView.onAppear` | Records active subscriber viewing Profile. | Preserve event name and only fire when `store.isPro` is true. |
| `store.subscriptionStatusText` | Pro branch and paywall subscribed state | Displays Free/Active/Renewing/Expiring subscription status from entitlement state. | Preserve value source, formatting, localization, and placement in Pro state. |
| `store.subscriptionPlanName` | Pro branch and paywall subscribed state | Displays plan label from RevenueCat/StoreKit package or product fallback. | Preserve value source and display in Pro state. |
| `Analytics.shared.track(.manage_subscription_opened)` | Pro branch manage button | Records manage-subscription intent. | Preserve event name and fire before presenting manage subscriptions unless explicitly approved otherwise. |
| `showManageSubscription = true` | Pro branch manage button | Opens system manage-subscription sheet. | Preserve state mutation and tap trigger. |
| `.manageSubscriptionsSheet(isPresented: $showManageSubscription)` | End of `subscriptionSection` | Presents Apple's manage-subscription UI. | Preserve modifier, binding, and scope. |
| `Analytics.shared.track(.paywall_viewed, ["source": "profile"])` | Non-Pro branch button | Records Profile paywall entry. | Preserve event name, `source` property, value `profile`, and tap timing. |
| `showPaywall = true` | Non-Pro branch button | Opens the STRQ paywall sheet. | Preserve state mutation and tap trigger. |
| `.sheet(isPresented: $showPaywall)` | `ProfileView.body` modifiers | Hosts the Profile paywall presentation. | Preserve sheet binding and presentation behavior. |
| `STRQPaywallView(store: store)` | Paywall sheet | Passes the same store object into purchase, restore, loading, offering, and subscribed states. | Preserve initializer and store object. Do not insert a wrapper that changes lifecycle. |
| `store.isConfigured` | `StoreViewModel` and controls restore flow | Guards RevenueCat availability. | Do not alter or infer subscription availability in Profile visual work. |
| `store.isLoading` | `StoreViewModel`, `STRQPaywallView` | Shows loading state in paywall and protects product-unavailable state. | Do not add Profile entry loading behavior unless explicitly scoped. |
| `store.currentOffering`, `annualPackage`, `monthlyPackage` | `StoreViewModel`, `STRQPaywallView` | Determines package selection and paywall content. | Do not touch from Profile card redesign. |
| `store.purchase(package:)` | `STRQPaywallView` | Starts RevenueCat purchase and analytics. | Out of scope for Profile entry pass. |
| `store.restore()` | `STRQPaywallView` and Profile controls restore | Restores purchases and updates entitlement state. | Out of scope for Profile entry pass. |
| `customerInfo.entitlements["pro"]` | `StoreViewModel` | Source of Pro entitlement truth. | Do not duplicate, bypass, or reinterpret. |

## 4. Current visual diagnosis

The non-Pro card uses an orange bolt treatment through `STRQBrand.accentGradient`. Because the full card is tappable and the icon is a strong warm gradient, the entry reads like an older CTA banner rather than a calm premium account/subscription module.

The Pro state is quieter than the non-Pro state, but it still uses older `STRQBrand` and `STRQPalette` treatments. The active plan badge uses legacy success green, while the rest of the migrated Profile areas have moved toward a darker, calmer, more deliberate carbon style.

The Pro entry may now look older than nearby accepted sections: `fitnessIdentity`, `coachingStyleRow`, `trackingToggleCard`, Body & Nutrition rows/buttons, Training Setup rows, and `controlsSection` have been moved toward a more restrained visual language.

The pillar chips in the non-Pro branch communicate useful value themes, but four equal-width chips in a tight row can feel dense and generic. The chips also compete with the headline/copy instead of creating a clear value hierarchy.

The Pro card should sell value without feeling cheap or loud. It should not look like a generic subscription nag, a bright ad banner, or a leftover orange kit card.

Pro active and non-Pro upsell need separate treatment. A subscribed user needs confirmation, trust, plan/status clarity, and a quiet manage-subscription entry. A non-subscribed user needs a premium upgrade path and value cue without aggressive pressure.

## 5. Product goal for STRQ Pro entry

The Profile STRQ Pro entry should communicate:

- A premium upgrade path for users who are not subscribed.
- Trust and account/subscription confidence for users who are subscribed.
- Clear value: adaptive coaching, evolving plans, device continuity, and ecosystem depth.
- Confidence that Pro is part of the STRQ training-coach system, not an unrelated ad.
- A calm, premium affordance to learn more or manage the subscription.

It should not communicate:

- An aggressive ad banner.
- A generic subscription nag.
- A cheap orange sale card.
- A one-size-fits-all CTA for both active subscribers and non-Pro users.
- A change in product entitlement, package, purchase, restore, or manage-subscription behavior.

## 6. What must not change

- No RevenueCat or store logic.
- No paywall purchase flow.
- No manage subscription flow.
- No analytics events or timing.
- No copy/localization in this pass.
- No entitlement logic.
- No product/package state.
- No `STRQPaywallView` changes.
- No `StoreViewModel` changes.
- No `STRQDesignSystem`, `STRQPalette`, or `ForgeTheme` token changes.
- No asset, icon asset, font, or localization catalog changes.
- No broad Profile cleanup.
- No accepted/frozen Profile sections.

## 7. Visual redesign direction

Recommended direction:

- Use a dark premium surface that aligns with the accepted Profile carbon-card language.
- Keep accent restrained and supportive; orange should not be dominant.
- Preserve a clear Pro badge/status cue.
- Reduce chip clutter and avoid four equal-weight tiny value pills as the main value proof.
- Create a stronger value hierarchy: Pro identity first, concise benefit second, small value proof third.
- Preserve the chevron/tap affordance.
- Keep Pro active and non-Pro states visually distinct.
- Avoid a button-like CTA unless explicitly approved.
- Use a calm premium account/subscription tone for active Pro users.
- Use a premium discovery/upgrade tone for non-Pro users.

Recommended non-Pro shape:

- One compact dark card.
- Restrained Pro mark or badge.
- Title and existing copy kept exactly.
- The whole card can remain tappable, but it should not look like a loud orange CTA button.
- Value proof can be simplified into fewer quieter signals, or recast as a compact value summary while preserving copy/localization constraints.

Recommended Pro active shape:

- Confirmation-oriented card.
- Clear `STRQ Pro` identity.
- Status and plan badge remain visible.
- Manage Subscription remains a secondary row/affordance, not a primary upsell CTA.
- Success/active accent should be subdued and trustworthy, not lime or celebratory.

## 8. State coverage requirements

Any future implementation must cover:

- Non-Pro state.
- Pro active state.
- Loading/unavailable if present.
- Subscription plan name display.
- Manage subscription tap.
- Paywall tap.
- Small iPhone viewport.
- Large iPhone viewport.

Current Profile entry state notes:

- `subscriptionSection` itself only branches on `store.isPro`.
- Loading/unavailable states are currently handled in `STRQPaywallView` through `store.isLoading`, `store.currentOffering`, and fallback states, not as separate Profile card states.
- A future Profile card shell pass should not invent a new loading or unavailable Profile branch unless owner-approved.
- `store.subscriptionStatusText` can return `Free`, `Active`, auto-renewing copy, expiring copy, or active fallback depending on configuration and entitlement state.
- `store.subscriptionPlanName` can return `Free`, `Yearly`, `Monthly`, `Weekly`, `Lifetime`, or `Pro`.

## 9. Risk rating

| Risk area | Rating | Reason | Mitigation |
|---|---|---|---|
| Behavior risk | High | The section owns paywall and manage-subscription entry points plus analytics. | Shell-only edits, exact action preservation, targeted diffs. |
| Revenue risk | High | Non-Pro tap opens the paywall; Pro tap opens subscription management; downstream paywall controls purchase/restore. | No `STRQPaywallView`, `StoreViewModel`, RevenueCat, package, product, or entitlement edits. |
| Product risk | High | The card shapes how users perceive Pro value and subscription trust. | Separate non-Pro upsell from Pro active status; keep copy unchanged. |
| Visual risk | Medium/high | It is near the top of Profile and currently conflicts with accepted migrated sections. | Use restrained dark premium surface and minimal accent. |
| Owner approval need | High | Monetization surfaces affect revenue, trust, and app-store subscription expectations. | Owner should approve the exact state and screenshot checklist before implementation. |

## 10. Recommended implementation phases

1. Plan completed
   - This document records current implementation, protected behavior, visual diagnosis, state coverage, risks, and the next prompt.

2. Non-Pro Profile card shell-only pass
   - Update only the non-Pro branch visual shell in `private var subscriptionSection`.
   - Preserve paywall tap analytics and `showPaywall` behavior exactly.
   - Do not touch the Pro branch.

3. Pro active card shell-only pass
   - Update only the Pro branch visual shell and manage-subscription row presentation.
   - Preserve status/plan display, manage analytics, and `showManageSubscription` behavior exactly.

4. Pillar chip/value summary cleanup
   - Revisit `proPillarChip(...)` only after the non-Pro shell direction is approved.
   - Preserve existing labels and icons unless a copy/icon/localization prompt explicitly scopes changes.

5. Final Rork QA
   - Verify non-Pro and Pro active states on small and large iPhone viewports.
   - Verify paywall and manage-subscription entry points.
   - Verify adjacent accepted Profile sections remain visually unchanged.

Do not do all phases at once. The two branches are small in code, but their revenue and product meaning are high-risk.

## 11. Exactly one recommended next implementation prompt

Selected option: A. non-Pro subscription card shell-only pass.

Why: the non-Pro branch is the most visually outdated and most likely to read as an older orange CTA banner. It is also self-contained enough for a tiny shell-only pass if the paywall analytics and `showPaywall` trigger are preserved exactly. Starting with the non-Pro shell avoids mixing active-subscriber status design, manage-subscription design, and value-chip cleanup into one revenue-sensitive diff.

```text
Work in repo: C:\Users\maxwa\Documents\GitHub\rork-strq

Goal:
Migrate only the non-Pro Profile STRQ Pro subscription card shell. This is a tiny visual pass for the non-Pro branch of `subscriptionSection`; preserve all paywall, store, analytics, and revenue behavior exactly.

Exact target file:
- `ios/STRQ/Views/ProfileView.swift`

Exact target section/helper:
- `private var subscriptionSection`
- Only the `else` / non-Pro branch inside `subscriptionSection`
- `private func proPillarChip(icon:label:)` only if needed to support the non-Pro shell without changing labels/icons

Allowed edits:
- `ios/STRQ/Views/ProfileView.swift`, scoped only to the non-Pro branch of `subscriptionSection` and its local non-Pro-only helper usage
- `docs/migration-progress-log.md`, one concise entry after verification

Forbidden edits:
- Do not edit the Pro active branch except for whitespace forced by formatting.
- Do not edit `STRQPaywallView.swift`.
- Do not edit `StoreViewModel` files.
- Do not edit RevenueCat/store files.
- Do not edit `STRQDesignSystem.swift`, `STRQPalette.swift`, `ForgeTheme.swift`, `ContentView.swift`, `STRQApp.swift`, assets, fonts, `Localizable.xcstrings`, ViewModels, Services, Models, Watch, Widget, Live Activity, project files, tests, or asset catalogs.
- Do not edit Profile `profileHeader`, `fitnessIdentity`, `coachingStyleRow`, `bodyNutrition`, `trackingToggleCard`, `trainingSetup`, `controlsSection`, `accountSection`, `dangerSection`, or `footerSection`.
- Do not change copy, localization keys, analytics events, navigation, sheets, alerts, entitlement logic, package/product logic, purchase, restore, manage subscription, onboarding, active workout, plan generation, progression, persistence, HealthKit, iCloud/account, reset, or notifications.

Behavior preservation list:
- Keep `store.isPro` as the branch condition.
- Keep the non-Pro card tap as a `Button` that opens the paywall.
- Keep `Analytics.shared.track(.paywall_viewed, ["source": "profile"])` exactly.
- Keep the analytics call inside the non-Pro tap action before `showPaywall = true`.
- Keep `showPaywall = true` exactly.
- Keep `.sheet(isPresented: $showPaywall) { STRQPaywallView(store: store) ... }` unchanged.
- Keep `STRQPaywallView(store: store)` unchanged.
- Keep `.manageSubscriptionsSheet(isPresented: $showManageSubscription)` unchanged.
- Keep the Pro branch manage-subscription behavior unchanged.
- Keep `L10n.tr("STRQ Pro")`.
- Keep `L10n.tr("Deeper coaching, plans that evolve, full ecosystem.")`.
- Keep the existing non-Pro value labels: `Adaptive`, `Evolving`, `Sync`, `Apple Watch`.
- Keep existing SF Symbols unless an exact future prompt names replacements.

Visual objective:
- Make the non-Pro STRQ Pro entry feel like a premium upgrade path inside the accepted calm dark/carbon Profile style.
- Remove orange dominance from the card treatment.
- Preserve a clear Pro identity, benefit hierarchy, and chevron/tap affordance.
- Reduce cheap CTA-banner energy.
- Avoid making the entry look like a generic ad or button-like sales banner.
- Leave active Pro status design for a separate pass.

Verification commands:
- `git status --short --branch`
- `git diff --name-only`
- `git diff -- ios/STRQ/Views/ProfileView.swift docs/migration-progress-log.md`
- `git diff --name-only -- ios/STRQ/Views/STRQPaywallView.swift ios/STRQ/ViewModels ios/STRQ/Services ios/STRQ/Models ios/STRQ/Utilities/STRQDesignSystem.swift ios/STRQ/Utilities/STRQPalette.swift ios/STRQ/Utilities/ForgeTheme.swift ios/STRQ/ContentView.swift ios/STRQ/STRQApp.swift ios/STRQWidget ios/STRQWatch ios/STRQ/Assets.xcassets ios/STRQ/Localizable.xcstrings ios/STRQ.xcodeproj`
- `rg -n "private var subscriptionSection|proPillarChip|store\\.isPro|showPaywall|STRQPaywallView|paywall_viewed|showManageSubscription|manageSubscriptionsSheet|manage_subscription_opened|subscriptionStatusText|subscriptionPlanName" ios/STRQ/Views/ProfileView.swift`
- `rg -n "STRQBrand\\.accentGradient|bolt\\.fill|Adaptive|Evolving|Apple Watch|Deeper coaching" ios/STRQ/Views/ProfileView.swift`
- `rg -n "RevenueCat|Purchases|entitlement|subscription|product|package" ios/STRQ/ViewModels ios/STRQ/Views/STRQPaywallView.swift ios/STRQ/STRQApp.swift`
- `rg -n "Sandow" ios/STRQ/Views ios/STRQ/ContentView.swift`

Rork QA checklist:
- Open Profile in a non-Pro state on a small iPhone viewport.
- Open Profile in a non-Pro state on a large iPhone viewport.
- Confirm the STRQ Pro entry reads as premium and calm, not a loud orange CTA.
- Confirm title, copy, value labels, icon, and chevron are readable with no clipping.
- Tap the non-Pro STRQ Pro card and confirm `STRQPaywallView(store: store)` opens.
- Dismiss the paywall and confirm Profile state is unchanged.
- Confirm active Pro branch remains visually and behaviorally unchanged if a Pro test account/state is available.
- Confirm manage-subscription behavior is unchanged in Pro state if available.
- Confirm accepted Profile sections remain unchanged.

Report-back format:
1. Files changed
2. Protected files unchanged
3. Exact Profile branch/helper changed
4. Visual summary
5. Behavior preserved
6. Verification command results
7. Rork QA needed/completed
8. Risks or owner approval gates
```

## 12. Rork QA checklist

Rork QA is not required for this docs-only pass because no Swift files changed.

Rork QA is required after any future subscriptionSection Swift implementation. Owner should check:

- Profile opens successfully.
- Non-Pro state on a small iPhone viewport.
- Non-Pro state on a large iPhone viewport.
- Pro active state on a small iPhone viewport.
- Pro active state on a large iPhone viewport.
- `STRQ Pro` title is readable.
- Existing non-Pro copy is readable and not clipped.
- Existing Pro status text and plan name are readable and not clipped.
- Non-Pro tap opens the paywall.
- Paywall dismiss returns to Profile.
- Pro manage-subscription tap opens the manage-subscription sheet.
- Analytics timing is not changed by the implementation diff.
- No purchase, restore, entitlement, package, product, or RevenueCat behavior is changed.
- Orange is not dominant unless explicitly approved.
- Active Pro state and non-Pro upsell state are visually distinct.
- Accepted Profile sections remain visually unchanged.
- No clipped text, overlapping chips, broken chevron, or layout jump on small/large iPhone.
