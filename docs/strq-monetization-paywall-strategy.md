# STRQ Monetization And Paywall Strategy

Date: 2026-05-13

Mode: Licensed Source Mode, planning only

Scope: docs-only strategy. No Swift files, RevenueCat integration, paywall logic, assets, localization, entitlement gates, or behavior changes are part of this slice.

## Executive Summary

STRQ should monetize the product's ongoing coaching value, not basic access to the app. The first plan, first workouts, core logging, basic history, and basic Progress must remain free enough for the user to understand why STRQ is useful. Pro should feel like an earned upgrade into a system that keeps learning from real training evidence.

Recommended V1 strategy: **E. Hybrid: free activation + Pro upgrade after user sees value.**

The recommended flow is:

1. Let onboarding, plan generation, plan reveal, pre-workout handoff, and the first workout run free.
2. Keep a passive STRQ Pro preview in Profile.
3. Introduce a calm soft Pro preview after the first completed workout or after the first meaningful progress milestone.
4. Gate only advanced Progress / Training Map depth, plan evolution, and coach-like insights behind Pro while leaving the basic product useful.
5. Defer production RevenueCat work until this model is approved.

This protects trust, keeps App Store review risk lower, and gives future RevenueCat integration a clear entitlement model.

## Source Inventory

Read or inspected planning sources:

- `docs/strq-product-design-north-star.md`
- `docs/progress-v5-experience-blueprint.md`
- `docs/progress-v4-production-integration-plan.md`
- `docs/migration-progress-log.md`
- `ios/STRQ/Views/OnboardingView.swift`
- `ios/STRQ/Views/PlanGenerationView.swift`
- `ios/STRQ/Views/PlanRevealView.swift`
- `ios/STRQ/Views/DashboardView.swift`
- `ios/STRQ/Views/ProgressAnalyticsView.swift`
- `ios/STRQ/Views/ProgressV5ProductionCandidateView.swift`
- `ios/STRQ/Views/ActiveWorkoutView.swift`
- `ios/STRQ/Views/STRQPaywallView.swift`
- `ios/STRQ/Views/ProfileView.swift`
- `ios/STRQ/ViewModels/StoreViewModel.swift`
- `ios/STRQ/STRQApp.swift`
- `docs/profile-subscription-section-risk-plan.md`

## Licensed Source Mode Figma Usage

Figma was inspected read-only in Licensed Source Mode. No source assets, source copy, source branding, or exact layouts should be copied into STRQ.

Nodes inspected:

- `11604:62728` - Dark Home / Smart Fitness Metrics
- `11611:134946` - Activity Tracker / onboarding / completion patterns
- `9129:207997` - Progress primitives
- `11603:111144` - Welcome / value intro patterns
- `11603:112700` - Comprehensive Fitness Assessment
- `11604:59713` - Profile setup / account completion
- `11604:63115` - Dark metric insight feed
- `11604:63236` - Dark metric detail
- `11604:63410` - Metric detail with action stack
- `11604:63724` - Goal / history detail set
- `11604:64200` - Weight / history detail set
- `11604:64937` - Hydration / history detail set
- `11604:66184` - Mood / history detail set

Directly useful planning patterns:

- Dense dark metric surfaces with compact proof modules.
- Completion and recommendation pacing that makes progress feel earned.
- Progress bars, rings, labels, and history primitives.
- Detail screens that move from high-level score to supporting evidence to action.

Adapted for STRQ:

- Use STRQ's own dark carbon Training Map and Progress language rather than generic health dashboard language.
- Treat Pro as deeper training evidence and adaptation, not as a lifestyle metric bundle.
- Use readiness/data-maturity states to explain when advanced insights become useful.
- Keep paywall hierarchy calm, compact, and proof-led.

Intentionally ignored:

- Source copy such as generic "healthy range" claims.
- Identity verification and account-completion language that does not fit STRQ.
- Exact layouts, spacing, screenshots, branding, imagery, and visual assets.
- Any health or body claims STRQ cannot support with transparent local data.

## Current Monetization Inventory

RevenueCat is **not production-integrated** today.

Observed state:

- `StoreViewModel` exists and owns subscription-like state.
- `StoreViewModel.isRevenueCatConfigured` is currently false because the SDK is omitted.
- If RevenueCat keys are present, `STRQApp` logs that keys exist but the SDK is omitted from the preview build.
- Purchase and restore paths currently fail gracefully as unconfigured.
- `STRQPaywallView` already exists as a visual/paywall shell with package selection, purchase, restore, legal/footer, and active-subscription states.
- `ProfileView.subscriptionSection` already has a passive Pro entry and active-subscription branch.
- Existing analytics include paywall view, package selection, purchase started/completed/failed, restore started/completed/failed, subscription active viewed, and manage subscription opened.

Existing entitlement/check state:

- `store.isPro` exists.
- `store.subscriptionStatusText` and `store.subscriptionPlanName` exist.
- There are no meaningful feature gates across the accepted product flow.
- Current Pro state affects Profile and paywall presentation, not the core training experience.

Areas currently assuming free access:

- Onboarding Shell.
- Plan Generation.
- Plan Reveal.
- Today/Home Command Center.
- Pre-Workout Handoff.
- Active Workout core.
- Basic workout logging and history.
- Progress / Training Map surfaces, including the internal V5 candidate.
- Exercise detail and anatomy education.
- Plan regeneration and editing paths.
- Profile, settings, notifications, restore purchases entry, iCloud sync, and account flows.
- Body/nutrition adjacent profile surfaces.
- Watch, widgets, and Live Activities if enabled later.

Important current mismatch:

- Existing paywall copy should not imply that iCloud continuity is Pro unless the product intentionally changes iCloud from a free trust feature to a paid feature. Today, account/iCloud restore is a trust and data-safety surface, not a monetization surface.

## Product Monetization Thesis

Users should pay for STRQ when it becomes more than a workout logger or static plan generator.

The strongest thesis:

> STRQ Pro is the adaptive training layer that keeps learning from your real workouts.

This means the paid value should focus on:

- Ongoing plan adjustments based on completed sessions, missed sessions, fatigue signals, equipment changes, and progress evidence.
- Advanced Training Map and Progress depth that explains what is changing, why it matters, and what to do next.
- Coach-like insights that connect plan, workout execution, readiness, and evidence.
- Longer workout history depth, replays, trend comparisons, and evidence timelines.
- Multi-plan and advanced split support for users with more complex training lives.
- Future Watch, widget, and Live Activity continuity if those surfaces become Pro-grade coaching surfaces.
- Premium exercise education only when it goes beyond basic safety and usability.

What should not be the main paid promise:

- "Better first plan generation." The first plan should be good enough to create trust.
- Basic safety guidance.
- Basic exercise anatomy.
- Core workout logging.
- The user's own training history in a basic usable form.

## Free Model

Free should prove value without making the app feel disposable.

Recommended Free access:

- Full onboarding.
- First generated plan.
- Plan reveal.
- Pre-workout handoff.
- First workout and ongoing core workout logging.
- Basic Today/Home command center.
- Basic workout history.
- Basic Progress / Training Map snapshot.
- Exercise library, basic exercise detail, basic anatomy, and safety cues.
- Basic plan editing/regeneration required to avoid trapping users in a bad or unsafe plan.
- Profile, settings, account/iCloud trust surfaces, restore purchase path, and privacy controls.

Free should answer:

- "Does STRQ understand what I am trying to do?"
- "Can I complete a workout with this?"
- "Can I trust the app with my training history?"
- "Is the Progress direction interesting enough to keep going?"

## Pro Model

Pro should unlock depth, continuity, and adaptation.

Recommended Pro access:

- Advanced Training Map insights.
- Deeper Progress detail, replay, and evidence timeline.
- Adaptive plan adjustments after real training data accumulates.
- Coach-like weekly review and next-step guidance.
- Advanced analytics such as volume trends, consistency analysis, muscle balance, recovery pattern interpretation, and progression confidence.
- Longer history depth and comparisons.
- Multi-plan support, advanced splits, and specialized plan modes.
- More granular exercise education, substitutions, and technique context beyond the free safety baseline.
- Future Watch, widgets, and Live Activities when they become active coaching/continuity surfaces.
- Future opt-in physique/nutrition intelligence if privacy, consent, and claims are handled conservatively.

Pro should not lock:

- Core safety.
- Basic usability.
- The user's ability to complete and log workouts.
- Basic access to their own data.
- Account restore, privacy, or support flows.

## Paywall Placement Evaluation

| Placement | Conversion Potential | Trust Risk | UX Risk | Implementation Complexity | Recommendation |
| --- | --- | --- | --- | --- | --- |
| After onboarding before plan reveal | High | Very high | High | Medium | Avoid for V1. This asks for payment before STRQ proves value and can feel like a trap. |
| After plan reveal before first workout | High | Medium to high | Medium | Medium | Only as a soft preview, never a hard gate. The user has seen the plan but has not felt the workout system yet. |
| After first workout | Medium to high | Low | Low to medium | Medium | Strong candidate. The user has completed a real action and can understand adaptive value. |
| Trying advanced Progress / Training Map | High | Low to medium | Low if basic Progress remains useful | Medium | Best feature paywall. It is contextual, honest, and tied to obvious Pro value. |
| Data-readiness milestone | High | Low | Low | Medium | Excellent. The app can say advanced insights are now meaningful because enough evidence exists. |
| Plan regeneration / adjustment | Medium to high | Medium | Medium | Medium to high | Good after the first free plan and basic safety edits. Do not block fixes that protect usability or safety. |
| Profile / Settings passive upgrade | Low to medium | Very low | Low | Low | Keep. This is a safe passive monetization surface. |

## Recommended V1 Paywall Strategy

Choose **E. Hybrid: free activation + Pro upgrade after user sees value.**

Why:

- It matches STRQ's product stance: prove value first, ask later.
- It avoids turning onboarding and plan reveal into a toll booth.
- It gives free users a meaningful product while making Pro understandable.
- It aligns the paid moment with the app's strongest future value: adaptive coaching and deeper training evidence.
- It reduces App Store review risk because the app remains useful without a subscription.
- It keeps future RevenueCat implementation focused on a small number of semantic entitlements.

Recommended V1 journey:

1. Onboarding: free.
2. Plan generation: free.
3. Plan reveal: free.
4. Pre-workout handoff: free.
5. First workout: free.
6. First post-workout review: show a soft Pro preview, not a blocking purchase.
7. Basic Progress: free.
8. Advanced Training Map / deep Progress: Pro.
9. Plan adaptation beyond basic fixes: Pro.
10. Profile: passive Pro entry always available.

The strongest first paywall should be contextual:

- "Unlock the deeper Training Map" when opening advanced Progress detail.
- "Let STRQ adapt next week" after the user has completed enough workouts.
- "See the evidence behind your next adjustment" after a data-readiness milestone.

## Paywall Design Direction

Visual style:

- Premium dark carbon, not loud neon commerce.
- Dense, clear, product-specific proof modules.
- Use Training Map / Progress visual language as the hero proof, not generic lifestyle imagery.
- Keep cards compact and calm.
- Do not use fake badges, fake scarcity, countdowns, or aggressive color urgency.

Copy tone:

- Confident, direct, and calm.
- Emphasize coaching continuity and evidence.
- Avoid "limited time", "only today", "last chance", and fake discounts.
- Avoid medical, diagnostic, guaranteed transformation, or body-shaming claims.

Benefit hierarchy:

1. Adaptive plan changes from real workouts.
2. Deeper Training Map and Progress evidence.
3. Weekly coach-like review and next steps.
4. Advanced history, replay, and comparisons.
5. Future continuity surfaces such as Watch/widgets if approved.

Possible headline direction:

- "Train with a plan that keeps learning."
- "Unlock STRQ Pro."
- "Turn your workouts into next steps."

Possible benefit copy direction:

- "See deeper evidence behind your Training Map."
- "Let STRQ adapt your plan as your week changes."
- "Review what moved, what stalled, and what to do next."

Screenshot/mockup usage:

- Use real STRQ Training Map and Progress screenshots once available.
- Do not use generic stock athletes as the primary proof.
- Do not export licensed source imagery into STRQ.
- Avoid placeholder Pro screenshots that imply unavailable functionality.

Price presentation placeholder:

- Pull price and period from StoreKit/RevenueCat products when live.
- Show monthly and yearly products clearly.
- Yearly can show a real calculated per-month equivalent when available.
- Any savings label must be mathematically true and derived from actual product prices.
- No fake crossed-out prices.

Required footer:

- Restore Purchases.
- Privacy Policy.
- Terms of Use.
- Apple ID billing/subscription management language.
- Trial details only if a real App Store introductory offer is configured.
- Plain cancellation language.

## RevenueCat Architecture Plan

Do not implement RevenueCat in this slice.

Recommended ownership:

- Keep app-facing subscription state in `StoreViewModel`.
- Add a future `SubscriptionService` protocol behind `StoreViewModel`.
- Add a future `RevenueCatSubscriptionService` implementation only when SDK integration is approved.
- Keep views dependent on semantic STRQ state, not RevenueCat APIs.

Suggested app-facing state:

- `isPro`
- `entitlementState`
- `availablePackages`
- `selectedPackage`
- `isPurchasing`
- `isRestoring`
- `error`
- `restoreMessage`
- `subscriptionStatusText`
- `subscriptionPlanName`

Suggested identifiers:

- RevenueCat entitlement: `pro`
- Offering: `default`
- Monthly product: `com.strq.pro.monthly`
- Yearly product: `com.strq.pro.yearly`

Debug/test mode:

- StoreKit config or local fixtures for previews and simulator QA.
- Ability to simulate Free, Pro, products unavailable, purchase failure, restore success, and restore failure.
- No live purchases in SwiftUI previews.
- Analytics should distinguish test/sandbox where possible.

Fallback behavior:

- If offerings fail to load, show a passive Pro preview with purchase disabled.
- Do not block core training features because product metadata is unavailable.
- Error copy should be calm and recoverable.

Offline behavior:

- Preserve last known entitlement locally with a conservative grace behavior.
- Core training, active workouts, and basic history must remain usable offline.
- Advanced Pro surfaces can show last-known Pro access or a non-destructive unavailable state depending on App Store and RevenueCat guidance at implementation time.

Restore:

- Restore must be available from the paywall and Profile.
- Restore must not be hidden behind sign-in or onboarding.
- Restore copy must distinguish "no active subscription" from network/configuration failure.

App Store review considerations:

- The free app must remain useful.
- Pricing, period, renewal, cancellation, privacy, and terms must be visible.
- Restore must work.
- Health and fitness claims must be conservative.
- Do not imply medical diagnosis, injury prevention guarantees, or guaranteed body outcomes.

## Risk And Ethics

Overpaywalling:

- Risk: users feel punished after investing in onboarding.
- Mitigation: first plan and first workout remain free; basic Progress remains useful.

Misleading claims:

- Risk: advanced analytics imply certainty the app does not have.
- Mitigation: use evidence, readiness, and confidence language. Avoid guarantees.

Subscription fatigue:

- Risk: another monthly fitness subscription feels generic.
- Mitigation: make Pro specific to adaptive training and Progress depth.

App Store compliance:

- Risk: missing restore, unclear pricing, or useless free app.
- Mitigation: clear footer, real restore, meaningful free flow, no deceptive urgency.

Refunds and support:

- Risk: users buy expecting unavailable features.
- Mitigation: only advertise shipped Pro benefits; mark future benefits as future only in docs, not paywall copy.

Beta/test users:

- Risk: internal testers get blocked or charged accidentally.
- Mitigation: debug flags, sandbox testing, and explicit internal-only states.

Data trust:

- Risk: users feel their own data is held hostage.
- Mitigation: basic history stays free; export/privacy direction remains honest.

Minors and health claims:

- Risk: fitness/body features can become sensitive.
- Mitigation: avoid medical language, body-shaming, unsafe recommendations, and unsupported nutrition claims.

Privacy:

- Risk: Pro insights require sensitive personal data.
- Mitigation: keep sensitive modules opt-in, explain local/cloud behavior, and avoid monetizing privacy controls.

## Release-Safe First Implementation Slice

Choose exactly one: **A. Docs-only monetization strategy.**

Why:

- The app already has a paywall shell and subscription state, but the monetization model needs approval before code changes.
- The highest current risk is not technical integration; it is choosing the wrong paid boundary.
- Docs-only creates a stable product contract for future RevenueCat, paywall design, analytics, and QA work.
- It satisfies the immediate planning need without touching protected app flows.

Explicitly out of scope:

- Swift edits.
- RevenueCat SDK work.
- Entitlement gates.
- Paywall placement changes.
- Assets.
- Localization.
- Screenshots.
- Xcode builds.

## Exactly One Implementation Prompt

Use this prompt for the chosen docs-only slice.

```text
Use Licensed Source Mode.

Goal:
Create a docs-only STRQ monetization and paywall strategy. Do not implement RevenueCat, do not change Swift, and do not alter app behavior.

Allowed files:
- docs/strq-monetization-paywall-strategy.md
- docs/migration-progress-log.md

Forbidden files:
- ios/STRQ/**/*.swift
- ios/STRQ.xcodeproj/**
- ios/STRQ/Assets.xcassets/**
- ios/STRQ/Localizable.xcstrings
- ios/STRQWidget/**
- ios/STRQWatch/**
- tests, assets, fonts, config, entitlements, StoreKit, RevenueCat, analytics, persistence, onboarding, workout, Progress, Profile, Paywall code

Figma requirement:
Use @figma read-only in Licensed Source Mode. Inspect/adapt:
11604:62728, 11611:134946, 9129:207997, 11603:112700, 11604:59713, 11604:63115, 11604:63236, 11604:63410, 11604:63724, 11604:64200, 11604:64937, 11604:66184.
Report what was used directly, adapted, and ignored. Do not export assets or copy source branding/copy.

Behavior guards:
No code changes. No RevenueCat SDK work. No entitlement gates. No paywall placement changes. No screenshots required for this docs-only slice.

Verification:
git status --short --branch
git diff --name-only
git diff -- docs/strq-monetization-paywall-strategy.md docs/migration-progress-log.md
git diff --name-only -- ios ios/STRQWidget ios/STRQWatch
rg -n "RevenueCat|Paywall|Free|Pro|entitlement|restore|subscription|Training Map|Licensed Source Mode" docs/strq-monetization-paywall-strategy.md
git diff --check

Build command:
Docs-only: do not run xcodebuild. If any Swift/project file changes, stop. If scope is later expanded, use:
xcodebuild -project ios/STRQ.xcodeproj -scheme STRQ -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build

Push command after approval:
git add docs/strq-monetization-paywall-strategy.md docs/migration-progress-log.md
git commit -m "docs: plan STRQ monetization strategy"
git push
```

## Open Decisions Before RevenueCat

- Confirm whether iCloud continuity stays free. Recommendation: keep it free as a trust feature.
- Confirm exact Pro feature names before public paywall copy.
- Confirm monthly/yearly price points and any real introductory offer.
- Confirm first contextual paywall: advanced Training Map, first post-workout review, or data-readiness milestone.
- Confirm whether beta users, testers, or early adopters get complimentary access.
- Confirm analytics events for paywall impression source, soft preview dismissal, advanced feature tap, purchase result, restore result, and entitlement refresh.
