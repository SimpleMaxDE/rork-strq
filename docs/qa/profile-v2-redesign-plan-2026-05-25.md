# Profile V2 Redesign Plan

Date: 2026-05-25

Task type: Documentation only.

Status: Approved plan document. No app source changes. No production rebuild approved yet.

## 1. Product Definition

Profile V2 is the STRQ control center.

Its product job is:

> How is STRQ set up to train me, and what can I control?

Profile should answer that question calmly and quickly. It should feel like the place where a lifter checks training identity, coaching preferences, body and recovery inputs, plan controls, Pro status, data/privacy, and support.

Profile V2 must not feel like a subscription landing page. STRQ Pro belongs in Profile, but it must not become the first-viewport hero or dominate the screen before the user's own training setup is clear.

## 2. Ideal IA

The approved Profile V2 information architecture is:

1. Training Identity
2. Coach Preferences
3. Body & Recovery Inputs
4. Plan Control
5. STRQ Pro
6. Data & Privacy
7. About / Support

This IA is the product contract for future Profile work. It does not approve a production rebuild.

## 3. First Viewport Rules

The first viewport must answer the product job before it sells anything.

Required first-viewport hierarchy:

1. Screen title: `Profile`
2. Training Identity summary
3. Coach Preferences entry or compact preference summary
4. Quiet status row for core setup health, if space allows

First viewport must:

- Prioritize the user and their training setup over STRQ Pro.
- Show what STRQ knows about the athlete without fake precision.
- Keep copy short, direct, and gym-native.
- Avoid generic analytics dashboard language.
- Avoid score-first cards.
- Avoid medical claims or recovery diagnosis.
- Avoid bright sales-card energy.
- Leave STRQ Pro visible later in the scroll as a calm account/product module, not as the hero.

STRQ Pro may appear in the first scroll depth if density requires it, but it must not be the top hero or the dominant visual object.

## 4. Current Section Decisions

Current accepted Profile areas stay frozen unless a later prompt explicitly reopens them:

- `controlsSection`: accepted; do not rework during Profile V2 planning or prototyping unless scoped.
- `trainingSetup` static rows: accepted; do not tune typography, dividers, spacing, or optical emphasis in unrelated passes.
- `bodyNutrition` static info rows: accepted; do not reopen the row split in a broad cleanup.

Current protected or high-risk areas:

- `subscriptionSection`: revenue-sensitive. Keep as a calm STRQ Pro entry. Do not change paywall, store, entitlement, package/product, restore, manage-subscription, or analytics behavior without explicit approval.
- `accountSection`: account/iCloud sensitive. Preserve Sign in with Apple, restore/upload branching, forced restore, sign-out, cloud status, and alerts.
- `dangerSection`: reset-sensitive. Reset data should move conceptually into Data & Privacy, but no production move is approved yet.
- `footerSection`: contains hidden diagnostics behavior today. Diagnostics must be DEBUG-only in the future.
- `trackingToggleCard`: side-effect sensitive. Nutrition mode changes refresh nutrition insights, coaching insights, and daily state; any future visual pass must preserve this order.
- `fitnessIdentity`: semantically sensitive. Recovery, sleep, nutrition, and streak are coaching signals, not decorative metrics.
- `coachingStyleRow`: good candidate for a small future production slice if visual-only and route-preserving.

HealthKit, Sleep source, Bodyweight source, Nutrition mode, and iCloud sync state belong as quiet inputs/statuses, not score-first cards.

## 5. Release vs Debug Rules

Release builds:

- No debug tools.
- No internal previews.
- No diagnostics surfaces.
- No build/package/preview language in user-facing Pro states.
- No test fixture controls.
- No fake subscription states.
- No internal state names.

DEBUG builds:

- Debug tools may exist only behind DEBUG compilation gates.
- Internal previews may exist only in DEBUG.
- Diagnostics may exist only in DEBUG.
- Fixture-driven Profile V2 prototypes may exist only in DEBUG.
- DEBUG states must never leak into release navigation, copy, analytics, screenshots intended for App Store, or user-facing unavailable/error states.

Pro unavailable state rule:

- The unavailable state must never mention build, package, preview, offering, fixture, sandbox, or internal configuration.
- Acceptable direction: calm product copy such as `STRQ Pro is unavailable right now. Try again later.`
- Do not expose implementation reasons to users.

## 6. Data Sources And Permissions

Profile V2 should use existing trusted app data first. Do not invent new data models during the redesign.

Training Identity:

- Source: `vm.profile` and existing profile-derived fields.
- Examples: name, training level, primary goal, focus muscles, training location, equipment, schedule, current plan context.
- Rule: show identity and setup, not a scientific profile.

Coach Preferences:

- Source: `vm.profile.coachingPreferences`.
- Examples: tone, density, emphasis.
- Rule: show as controllable preferences, not personality analysis.

Body & Recovery Inputs:

- Sources: existing recovery, sleep, nutrition, bodyweight, readiness, and profile inputs.
- HealthKit state belongs here as a quiet permission/status row when relevant.
- Sleep source belongs here as a quiet input/status.
- Bodyweight source belongs here as a quiet input/status.
- Nutrition mode belongs here as a quiet setting/status.
- Rule: these inputs help STRQ adapt training; they are not a score wall.

Plan Control:

- Source: current plan, schedule, equipment, profile constraints, and existing plan regeneration/rebuild flows.
- Rule: plan controls must be framed as deliberate changes to training structure.

STRQ Pro:

- Source: `StoreViewModel` state such as `store.isPro`, `store.subscriptionStatusText`, and `store.subscriptionPlanName`.
- Rule: Pro is a calm product/account module. It must not imply iCloud, privacy, or basic data controls are paid.

Data & Privacy:

- Sources: account state, iCloud sync status, HealthKit permission state, privacy/legal routes, reset controls.
- iCloud sync state belongs here as a quiet trust/status module.
- Rule: privacy, backup, restore, and reset are trust surfaces, not monetization surfaces.

About / Support:

- Sources: app version, terms, privacy policy, support contact.
- Rule: app version and internal diagnostics must not create release-visible debug affordances.

## 7. Plan Control Safety

Plan Control is allowed conceptually in Profile V2, but it is protected. It can change the structure STRQ uses to train the user.

Future Plan Control must:

- Separate harmless edits from structure-changing actions.
- Preserve existing training-plan generation, regeneration, and progression logic unless a production integration plan explicitly approves changes.
- Avoid broad "rebuild everything" actions without clear consequence copy.
- Avoid putting destructive plan actions beside neutral settings.
- Avoid presenting plan rebuild as a casual refresh.

Rebuild Training Plan rule:

- Must include consequence copy before replacing the current training structure.
- Must require explicit confirmation before replacement.
- Must explain that the current plan structure may change, including days, exercises, progression, and near-term training flow.
- Must preserve active-workout protection and existing data-safety guards.
- Must not run automatically from a Profile visual change.

Recommended confirmation direction:

> This replaces your current training structure with a new plan based on your latest setup. Your logged workout history stays, but upcoming days, exercises, and progression can change.

The final copy requires user/ChatGPT review before production.

## 8. Reset Safety

Reset data must live inside Data & Privacy, not as a root-level danger card.

Future reset behavior must:

- Require clear confirmation.
- Use destructive styling only where it clarifies risk.
- Explain exactly what will be removed before confirmation.
- Avoid accidental proximity to routine controls.
- Preserve existing `vm.resetAllData()` behavior unless a separate data-safety plan approves changes.
- Avoid broad reset entry points in the first viewport.

Reset must not be used as a visual balance element. It is a protected data-control surface.

## 9. DEBUG Prototype Plan

Before any production Profile V2 rebuild, create a DEBUG-only prototype.

Prototype goals:

- Validate the IA and first viewport hierarchy.
- Explore Profile as control center without touching production Profile behavior.
- Test quiet status/input rows for HealthKit, Sleep source, Bodyweight source, Nutrition mode, and iCloud sync.
- Test STRQ Pro placement below the primary setup controls.
- Test Plan Control and Data & Privacy grouping without wiring destructive behavior.

Prototype rules:

- DEBUG-only compilation gate.
- Fixture data only unless explicitly approved.
- No production persistence writes.
- No production reset.
- No production plan rebuild.
- No live purchase or restore.
- No internal previews in release.
- No diagnostics in release.

Screenshot plan for prototype review:

- iPhone 17 Pro Max first viewport.
- iPhone 17 Pro Max lower scroll.
- iPhone 17e first viewport.
- iPhone 17e lower scroll.
- At least one state with Pro unavailable.
- At least one state with iCloud unavailable or signed out.
- At least one state with HealthKit unavailable or not connected.

Screenshots are evidence only. User and ChatGPT remain final product, design, and language judges.

## 10. Production Slicing Plan

No production rebuild is approved yet.

Future production work should be sliced only after the DEBUG prototype is reviewed and approved.

Recommended slicing:

1. P0 Documentation and prototype approval
   - Keep this plan as the product contract.
   - Build and review DEBUG prototype screenshots.
   - Decide exact first production slice.

2. P1 First viewport only
   - Implement Training Identity and Coach Preferences first-viewport structure.
   - Keep STRQ Pro out of hero position.
   - Use only trusted existing data.
   - Preserve existing routes and actions.
   - No plan rebuild, reset, iCloud restore, subscription logic, HealthKit permission logic, or persistence changes.

3. P2 Body & Recovery Inputs
   - Add quiet rows/statuses for HealthKit, Sleep source, Bodyweight source, and Nutrition mode.
   - Preserve existing permission and input flows.
   - No score-first cards.

4. P3 Plan Control
   - Add plan-control grouping only with approved consequence copy and confirmation behavior.
   - Keep rebuild/regeneration behavior protected.
   - Verify active workout, current plan, and history safety.

5. P4 STRQ Pro
   - Place Pro as a calm account/product module.
   - Preserve `StoreViewModel`, paywall, restore, manage-subscription, entitlement, package/product, and analytics behavior.
   - Ensure unavailable copy is release-safe and does not mention build/package/preview.

6. P5 Data & Privacy
   - Move/reset data concept into Data & Privacy only after reset confirmation copy and behavior are approved.
   - Treat iCloud sync as a trust/status surface.
   - Keep account restore and sign-out behavior protected.

7. P6 About / Support
   - Keep legal/support routes simple.
   - Remove or gate release-visible diagnostics affordances.
   - Ensure internal previews never ship in release.

Each slice needs its own allowed files, forbidden files, build command, screenshot plan, and review gate.

## 11. Explicit Non-Approval

This document approves the Profile V2 plan as documentation.

It does not approve:

- Production Profile rebuild.
- Edits to `ios/STRQ/Views/ProfileView.swift`.
- RevenueCat, StoreKit, paywall, package, product, entitlement, restore, or manage-subscription changes.
- HealthKit, iCloud, account, persistence, analytics, reset, plan generation, regeneration, progression, onboarding, active workout, Watch, Widget, or Live Activity changes.
- Release-visible debug tools, internal previews, or diagnostics.

No production rebuild is approved yet.
