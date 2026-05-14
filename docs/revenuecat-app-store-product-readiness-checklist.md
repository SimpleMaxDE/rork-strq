# RevenueCat And App Store Product Readiness Checklist

Date: 2026-05-14

Status: Official docs-only gate before RevenueCat D2 purchase UI enablement.

## Gate Summary

This checklist is the required readiness gate before enabling real purchase UI in `STRQPaywallView`.

D2 purchase UI must remain disabled until RevenueCat Dashboard setup, App Store Connect products, sandbox/TestFlight purchase behavior, restore behavior, compliance copy, and paywall screenshots are verified.

This document does not enable purchases, add gates, change product identifiers, or change runtime behavior.

## Official References

- RevenueCat products, entitlements, and offerings:
  - [Configuring Products](https://www.revenuecat.com/docs/projects/configuring-products)
  - [Entitlements](https://www.revenuecat.com/docs/getting-started/entitlements)
  - [Offerings](https://www.revenuecat.com/docs/offerings/overview)
- RevenueCat testing and launch:
  - [RevenueCat Test Store](https://www.revenuecat.com/docs/test-and-launch/sandbox/test-store)
  - [Sandbox Testing](https://www.revenuecat.com/docs/test-and-launch/sandbox)
  - [App Subscription Launch Checklist](https://www.revenuecat.com/docs/test-and-launch/launch-checklist)
  - [Connect Apps And Web Providers](https://www.revenuecat.com/docs/projects/connect-a-store)
- Apple subscriptions and review:
  - [Auto-renewable Subscriptions](https://developer.apple.com/app-store/subscriptions/)
  - [App Review Guidelines 3.1.2](https://developer.apple.com/app-store/review/guidelines/)
  - [Offer Auto-Renewable Subscriptions](https://developer.apple.com/help/app-store-connect/manage-subscriptions/offer-auto-renewable-subscriptions/)
  - [In-App Purchase Information](https://developer.apple.com/help/app-store-connect/reference/in-app-purchases-and-subscriptions/in-app-purchase-information)
  - [In-App Purchase Statuses](https://developer.apple.com/help/app-store-connect/reference/in-app-purchases-and-subscriptions/in-app-purchase-statuses)
  - [Submit An In-App Purchase](https://developer.apple.com/help/app-store-connect/manage-submissions-to-app-review/submit-an-in-app-purchase)
  - [Sandbox Testing Overview](https://developer.apple.com/help/app-store-connect/test-in-app-purchases/overview-of-testing-in-sandbox)
  - [Testing Subscriptions And IAPs In TestFlight](https://developer.apple.com/help/app-store-connect/test-a-beta-version/testing-subscriptions-and-in-app-purchases-in-testflight/)

## Current STRQ Code Readiness

The app already supports:

- RevenueCat SDK integration through the native iOS project.
- RevenueCat configuration at launch when a key is present.
- DEBUG key selection that prefers `EXPO_PUBLIC_REVENUECAT_TEST_API_KEY`, then falls back to `EXPO_PUBLIC_REVENUECAT_IOS_API_KEY`.
- Release key selection that requires `EXPO_PUBLIC_REVENUECAT_IOS_API_KEY`.
- CustomerInfo reads mapped to `StoreViewModel.isPro`.
- Offerings reads mapped into app-facing subscription packages and products.
- Purchase and restore service methods that map RevenueCat CustomerInfo back into STRQ subscription state.
- Calm failure handling for unconfigured, unavailable, failed, and cancelled purchase states.
- Live package preview in `STRQPaywallView` when valid package metadata is available.
- Restore access from the paywall preview.
- Store model tests for configured/unconfigured state, offerings, purchase success, purchase cancellation, purchase failure, restore active, restore no purchase, and restore failure.

Still intentionally disabled:

- The primary paywall CTA is disabled/internal and says purchases are not enabled in this build.
- No purchase sheet can be started from `STRQPaywallView`.
- No feature gates exist.
- No purchase placement exists outside the existing Profile Pro preview entry.
- No onboarding, plan reveal, first workout, core logging, basic Progress, or Training Map access is gated.

Expected identifier contract:

| Kind | Required identifier |
| --- | --- |
| Entitlement | `pro` |
| Offering | `default` |
| Monthly product | `com.strq.pro.monthly` |
| Yearly product | `com.strq.pro.yearly` |

Current app target bundle identifier observed in the Xcode project:

- `app.rork.40gfu7dywfru7n82xfoy4`

RevenueCat and App Store Connect must match the shipping bundle identifier for the build that will be submitted.

## RevenueCat Dashboard Checklist

Project and app:

- [ ] RevenueCat project exists for STRQ.
- [ ] iOS app is created in RevenueCat.
- [ ] RevenueCat iOS app Bundle ID exactly matches the shipping app target Bundle ID.
- [ ] iOS platform SDK key is available for release builds.
- [ ] Test Store API key is available for DEBUG/Test Store builds only.
- [ ] Release builds do not use the Test Store API key.
- [ ] App Store Connect/App Store provider is connected before real Apple sandbox testing.
- [ ] Required Apple App Store credentials are configured, including Bundle ID, app-specific shared secret if needed, and In-App Purchase key.
- [ ] App Store Connect API key is added or product import is otherwise verified.
- [ ] Platform server notifications are considered or configured before launch monitoring, if STRQ plans to rely on near-real-time subscription lifecycle updates.

Products:

- [ ] Test Store product exists for `com.strq.pro.monthly`.
- [ ] Test Store product exists for `com.strq.pro.yearly`.
- [ ] Apple App Store product is imported or manually added for `com.strq.pro.monthly`.
- [ ] Apple App Store product is imported or manually added for `com.strq.pro.yearly`.
- [ ] Each product has a positive price and subscription duration metadata.
- [ ] Each product returns localized price metadata through the SDK.

Entitlement:

- [ ] Entitlement `pro` exists.
- [ ] `com.strq.pro.monthly` is attached to entitlement `pro`.
- [ ] `com.strq.pro.yearly` is attached to entitlement `pro`.
- [ ] A purchase of either product activates `pro` in CustomerInfo.
- [ ] Expiration or revocation makes `pro` inactive in CustomerInfo.

Offering:

- [ ] Offering `default` exists.
- [ ] Offering `default` is the dashboard default/current offering unless an intentional targeting rule overrides it for a test user.
- [ ] Monthly package is attached to `default`.
- [ ] Yearly package is attached to `default`.
- [ ] Package identifiers are recognizable by duration, for example `$rc_monthly` and `$rc_annual`, or equivalent duration-specific identifiers.
- [ ] The SDK fetch returns both monthly and yearly packages.
- [ ] The yearly package appears before monthly in STRQ's paywall preview when both are available.

## App Store Connect Checklist

Account and agreements:

- [ ] Apple Developer Program account is active.
- [ ] Paid Applications Agreement is accepted.
- [ ] Tax forms are complete.
- [ ] Banking is configured and clear.
- [ ] App record exists for the shipping Bundle ID.
- [ ] App Store privacy disclosures include RevenueCat and any related data collection.

Subscription group:

- [ ] A single STRQ Pro subscription group exists.
- [ ] Monthly and yearly products are in the same group to avoid duplicate subscriptions for the same service.
- [ ] Subscription group display name is user-facing, clear, and localized where needed.
- [ ] Subscription levels/order are correct for equivalent Pro access across monthly and yearly plans.

Products:

- [ ] Auto-renewable subscription product `com.strq.pro.monthly` exists.
- [ ] Auto-renewable subscription product `com.strq.pro.yearly` exists.
- [ ] Product IDs exactly match STRQ code and RevenueCat.
- [ ] Monthly product duration is 1 month.
- [ ] Yearly product duration is 1 year.
- [ ] Pricing is set for required countries/regions.
- [ ] Availability is set for required countries/regions.
- [ ] Localized display name and description are complete for at least the launch language.
- [ ] App Review screenshot is uploaded for each subscription.
- [ ] Review notes explain where to find the paywall, how to test purchase/restore, and what Pro unlocks.
- [ ] Product status is no longer `Missing Metadata`.
- [ ] Product status is at least `Ready to Submit` before App Review.
- [ ] First subscription submission is included with a new app version if this is STRQ's first IAP/subscription submission.

App metadata and review:

- [ ] App description or metadata discloses auto-renewing subscription details.
- [ ] Terms of Use URL is valid.
- [ ] Privacy Policy URL is valid.
- [ ] Review notes include any required demo or test account details.
- [ ] Review notes state that free activation remains available without subscribing.
- [ ] Review notes state that Pro is for adaptive/deeper training evidence, not medical or body guarantees.

## Sandbox And TestFlight Test Plan

No-key behavior:

- [ ] With no RevenueCat keys, the app stays free and stable.
- [ ] Paywall remains preview-only.
- [ ] No live package cards are shown.
- [ ] Purchase CTA remains unavailable.
- [ ] Restore returns the calm unavailable message.

DEBUG Test Store behavior:

- [ ] DEBUG build uses the Test Store key only when `EXPO_PUBLIC_REVENUECAT_TEST_API_KEY` is present.
- [ ] Monthly package appears.
- [ ] Yearly package appears.
- [ ] Localized price and subscription period render from product metadata.
- [ ] Test Store purchase success updates CustomerInfo and activates `pro`.
- [ ] Test Store purchase cancellation shows no user-facing error.
- [ ] Test Store purchase failure preserves state and shows the calm error.
- [ ] Restore with active Test Store purchase activates `pro`.
- [ ] Restore without active purchase keeps the user free and shows no active subscriptions.

Real Apple sandbox and TestFlight behavior:

- [ ] Build uses `EXPO_PUBLIC_REVENUECAT_IOS_API_KEY`, not the Test Store key.
- [ ] Real Apple sandbox fetch returns `com.strq.pro.monthly`.
- [ ] Real Apple sandbox fetch returns `com.strq.pro.yearly`.
- [ ] Monthly package is visible in STRQ.
- [ ] Yearly package is visible in STRQ.
- [ ] Purchase success shows Apple's purchase sheet and activates `pro`.
- [ ] Purchase cancellation dismisses cleanly with no error.
- [ ] Purchase failure or interrupted purchase preserves state and shows calm recovery copy.
- [ ] Restore active subscription activates `pro`.
- [ ] Restore with no purchase keeps the user free and explains no active subscriptions were found.
- [ ] Already-Pro state shows the active subscription state instead of purchase options.
- [ ] App relaunch after purchase refreshes CustomerInfo and keeps `pro` active.
- [ ] Expired sandbox subscription eventually makes `pro` inactive.
- [ ] Offline or failed refresh preserves current state and does not accidentally remove active Pro during a transient failure.
- [ ] RevenueCat dashboard shows the sandbox customer, transaction, product ID, and active entitlement.

Free activation regression:

- [ ] Onboarding remains free.
- [ ] Plan generation remains free.
- [ ] Plan reveal remains free.
- [ ] First workout remains free.
- [ ] Core workout logging remains free.
- [ ] Basic Progress and Training Map remain free.
- [ ] Account, iCloud trust surfaces, Terms, Privacy, and Restore Purchases remain reachable.

## Paywall Compliance Checklist

Required subscription information before asking the user to subscribe:

- [ ] Subscription name is clear.
- [ ] Subscription duration is clear.
- [ ] What Pro provides is clear and specific.
- [ ] Full renewal price is shown clearly and prominently.
- [ ] Price is localized from App Store/RevenueCat metadata.
- [ ] Annual billed price is the primary annual price.
- [ ] Monthly equivalent for yearly is secondary only and appears only when mathematically valid.
- [ ] Savings badge appears only when yearly is cheaper than twelve monthly periods in the same currency.
- [ ] Trial or intro offer copy appears only when real product metadata includes the offer.
- [ ] If a trial exists, copy states trial duration and post-trial billing price.
- [ ] Apple ID charge language is present.
- [ ] Auto-renewal language is present.
- [ ] Cancel/manage subscription language is present.
- [ ] Restore Purchases is visible.
- [ ] Terms link is visible and valid.
- [ ] Privacy link is visible and valid.

Pro promise guardrails:

- [ ] No fake discount.
- [ ] No fake urgency.
- [ ] No countdowns or scarcity claims.
- [ ] No unavailable product claims.
- [ ] No claim that iCloud/account restore is Pro-only.
- [ ] No medical guarantee.
- [ ] No body transformation guarantee.
- [ ] No guarantee of strength, fat loss, injury prevention, recovery, diagnosis, or treatment.
- [ ] No claim that the first plan, first workout, core logging, or basic Progress requires Pro.

## D2 Go/No-Go Criteria

D2 may proceed only when all of the following are true:

- [ ] RevenueCat `default` offering validates in DEBUG Test Store.
- [ ] RevenueCat `default` offering validates with Apple sandbox products through the iOS SDK key.
- [ ] App shows correct monthly and yearly package cards.
- [ ] App displays localized price, duration, and legal copy correctly.
- [ ] `StoreViewModelTests` pass.
- [ ] STRQ Pro Preview/package snapshot tests pass.
- [ ] Real Apple sandbox purchase succeeds.
- [ ] Real Apple sandbox restore succeeds for an active subscription.
- [ ] Restore no-purchase state is verified.
- [ ] Already-Pro state is verified.
- [ ] App relaunch after purchase is verified.
- [ ] App Store Connect review screenshots and review notes are complete.
- [ ] Paywall footer/copy passes the compliance checklist above.
- [ ] No feature gates are added in D2.
- [ ] Free activation is verified after the D2 diff.

No-go if any of the following are true:

- [ ] Test Store key is used in a release/App Review build.
- [ ] Either product is missing from RevenueCat or App Store Connect.
- [ ] Either product is not attached to entitlement `pro`.
- [ ] Either product is not attached to offering `default`.
- [ ] Real Apple sandbox purchase has not passed.
- [ ] Real Apple sandbox restore has not passed.
- [ ] Paywall copy shows unsupported discounts, trials, guarantees, or urgency.
- [ ] Any free activation surface is accidentally gated.

## Recommended Next Action

Recommended next action after this docs gate is accepted:

**Do not enable D2 immediately.**

First, verify the external product setup in RevenueCat and App Store Connect, then run DEBUG Test Store and real Apple sandbox/TestFlight validation. Only after those checks pass should a separate D2 implementation slice replace the disabled/internal CTA with real purchase UI.

## Future D2 Implementation Boundary

Allowed in a later D2 implementation slice:

- Replace the disabled/internal CTA with a real purchase action.
- Keep using existing `StoreViewModel.purchase(package:)`.
- Keep using existing RevenueCat product metadata.
- Add UI tests or manual QA artifacts for the real purchase entry point.

Forbidden in D2 unless separately approved:

- Adding Pro feature gates.
- Blocking onboarding, plan generation, plan reveal, first workout, core logging, basic Progress, or basic Training Map.
- Changing product IDs.
- Changing entitlement ID.
- Changing offering ID.
- Switching release builds to the Test Store key.
- Adding unsupported medical/body transformation claims.

