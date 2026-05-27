# Profile V4 Production Integration Plan

Date: 2026-05-27

Task type: Production integration plan / documentation.

Status: Final plan for review before commit. This document does not approve app source changes, staging, commit, or push by itself.

## 1. Context

Approved DEBUG prototype:

- `ios/STRQ/Views/Debug/ProfileV4SignatureExplorationView.swift`

Production source:

- `ios/STRQ/Views/ProfileView.swift`

Reference docs and release hygiene source:

- `docs/qa/profile-v3-concept-brief-2026-05-25.md`
- `docs/qa/profile-v2-redesign-plan-2026-05-25.md`
- Profile / Pro Release Hygiene P0 commit: `6fbc2b832d8e48fcaf9a32a2daa68f44b1e7382d`

Approved direction: Profile V4.1 Athlete Passport Compact.

V4.1 must lead with athlete identity, make `Build Muscle` the main read, use compact reliable training facts, organize Profile around three calm rows, keep STRQ Pro below setup, keep reset isolated and protected, stay English-first, and avoid settings dumps, Pro hero treatment, reset hero treatment, debug/internal labels, or production behavior changes.

## 2. Production Inventory

Current production Profile is still a stacked settings surface:

1. Profile header
   - Current subview: `profileHeader`.
   - Shows avatar initial, user name or `Athlete`, training-level chip, goal, and summary copy.
   - V4.1 gap: should become an athlete passport hero where goal is the main read and reliable setup facts are subordinate.

2. STRQ Pro / subscription card
   - Current subview: `subscriptionSection`.
   - Uses `store.isPro`, `store.subscriptionStatusText`, `store.subscriptionPlanName`, paywall sheet, manage-subscription sheet, and paywall analytics.
   - V4.1 gap: currently appears too high. It may move lower only as a presentation/order change.

3. Fitness Identity
   - Current subview: `fitnessIdentity`.
   - Shows primary goal plus recovery, sleep, nutrition, or streak chips.
   - V4.1 gap: first viewport should not read as a score/status card wall.

4. Coaching Style
   - Current subview: `coachingStyleRow`.
   - Routes to `CoachingPreferencesView`; summarizes tone, emphasis, and density.
   - V4.1 gap: should later align under `Coach & Inputs` without changing route behavior.

5. Body & Nutrition
   - Current subview: `bodyNutrition`.
   - Contains `trackingToggleCard`, height, weight, age, nutrition targets when enabled, `NutritionSettingsView`, and `SleepLogView`.
   - V4.1 gap: should become quiet input/status language later, not a first-viewport score block.

6. Training Setup
   - Current subview: `trainingSetup`.
   - Shows days/week, workout length, split preference, location, and focus-muscle chips.
   - V4.1 gap: should align to compact `Training Setup` rows: schedule, equipment/location, split, focus.

7. Notifications
   - Current area: inside `controlsSection`.
   - Routes to `NotificationSettingsView`; HealthKit toggle lives deeper there.
   - V4.1 gap: keep behavior; later relocate visually only if the route remains safe.

8. Restore Purchases
   - Current area: inside `controlsSection`.
   - Calls `store.restore()` when configured; otherwise shows a safe restore message.
   - V4.1 gap: belongs under account/product/data grouping later. Behavior is protected.

9. Rebuild/Regenerate Plan
   - Current area: inside `controlsSection`.
   - Opens `planRegenerationFlow`, tracks analytics, and requests Today tab after completion.
   - V4.1 gap: protected plan-control behavior; do not touch in P1.

10. Sync & Restore
    - Current subview: `accountSection`.
    - Handles Sign in with Apple, post-sign-in restore/upload branching, cloud restore, cloud status, and sign out.
    - V4.1 gap: should later become calm `Account & Data` grouping while preserving all behavior.

11. Data & Reset
    - Current subview: `dangerSection`.
    - Shows `Reset All Data` and calls `vm.resetAllData()` after confirmation.
    - V4.1 gap: keep isolated low and protected; no reset hero.

12. About / Support
    - Current subview: `footerSection`.
    - Shows Privacy, Terms, Support, and app version.
    - V4.1 gap: lower-scroll polish only.

13. Debug-only rows
    - Current rows: Internal Training Map preview and Design System Lab inside `#if DEBUG`.
    - V4.1 rule: remain DEBUG-only; never release-visible.

14. Hidden diagnostics
    - Current behavior: app-version long press opens media diagnostics inside `#if DEBUG`.
    - V4.1 rule: remain DEBUG-only; no release diagnostics route.

## 3. Data Readiness

| V4.1 visible item | Production source | Classification | Notes |
|---|---|---|---|
| User name / initials | `vm.profile.name`; fallback `Athlete`; initials from trimmed name | Reliable now | Current header already uses the name and first initial. |
| Primary goal | `vm.profile.goal.displayName` | Reliable now | `Build Muscle` exists for `.muscleGain`. |
| Training level | `vm.profile.trainingLevel.shortName` | Reliable now | Gives `Beginner`, `Intermediate`, or `Advanced`. |
| Days per week | `vm.profile.daysPerWeek` | Reliable now | Display as `4 days/week` style copy. |
| Location/equipment | `vm.profile.trainingLocation.displayName`; optional `availableEquipment` outside full gym | Reliable now for location; available but needs mapping for detailed equipment | P1 can use location only. |
| Split / plan shape | Prefer `vm.currentPlan?.splitType` mapped through `SplitDisplayName`; fallback to non-automatic `vm.profile.splitPreference.displayName` | Available but needs mapping | Do not display `Let AI Decide` as a plan shape. Use fallback copy if no reliable split exists. |
| Focus areas | `vm.profile.focusMuscles.prefix(3).map(\.localizedDisplayName)` | Reliable when set; display-only safe fallback if empty | If empty, avoid inventing focus. |
| Coach style | `vm.profile.coachingPreferences.tone.displayName` | Reliable now | Full tone/emphasis/density summary can remain in existing row. |
| Apple Health / HealthKit status | `HealthKitService.shared.isAvailable`, `HealthKitService.shared.authState`, `vm.notificationSettings.healthKitSyncEnabled` | Available but needs mapping | Stay out of P1 detail unless display-only and conservative. |
| Sleep source | `vm.sleepEntries`, HealthKit auth/toggle | Risky | Entries do not store source metadata. Should stay out of P1. |
| Bodyweight source | `vm.bodyWeightEntries`, `vm.profile.weightKg`, HealthKit auth/toggle | Risky | Entries do not store source metadata. Should stay out of P1. |
| Nutrition mode | `vm.profile.nutritionTrackingEnabled` | Reliable for display-only status | Do not alter toggle side effects. |
| Pro status | `store.isPro`, `store.subscriptionStatusText`, `store.subscriptionPlanName`, `store.isConfigured` | Reliable now | Revenue behavior protected. |
| Account / iCloud state | `vm.account.isSignedIn`, `vm.account.account`, `vm.cloudSync.isAvailable`, `vm.cloudSync.status`, `vm.cloudSync.lastSyncText` | Reliable for status; detailed sync UI belongs later | P1 may use short account status only if display-only. |

## 4. Protected Behavior

These behaviors must not change during Profile V4 production integration unless a later explicit plan approves it:

- Sign in with Apple request configuration and completion handling.
- iCloud sync, restore, upload, cloud-status display, and sign out.
- Restore Purchases.
- Paywall presentation, `StoreViewModel`, RevenueCat, StoreKit, entitlements, products/packages, restore, manage subscription, and subscription analytics.
- Rebuild Training Plan behavior, analytics, confirmation flow, active-workout protections, and Today-tab handoff.
- Reset All Data and `vm.resetAllData()`.
- Notifications routing and notification settings behavior.
- HealthKit permission flow and sync-on-enable behavior.
- Nutrition toggle side effects: update profile flag, refresh nutrition insights, refresh coaching insights, and refresh daily state.
- Hidden debug/diagnostics gating.
- DEBUG-only prototype and internal-preview gating.

## 5. Recommended Production Slicing

| Slice | Scope | Allowed future files | Forbidden future files/actions | Data sources | Screenshot requirements | Risk |
|---|---|---|---|---|---|---|
| P1 First viewport only | Athlete identity hero plus three calm rows: `Training Setup`, `Coach & Inputs`, `Account & Data`; move Pro lower only as ordering/presentation | `ios/STRQ/Views/ProfileView.swift`; private helper structs inside that file | No models, persistence, `AppViewModel`, `StoreViewModel`, RevenueCat, paywall, routes, reset, sign-in, iCloud, HealthKit, nutrition side effects, project files, debug files | `vm.profile`, read-only `vm.currentPlan?.splitType`, conservative `store.isPro`, conservative `vm.account.isSignedIn` | iPhone 17 Pro Max first viewport; iPhone 17e first viewport; include free/signed-out baseline | Low-medium |
| P2 Training Setup section alignment | Lower `Training Setup` section matches V4.1 rows and copy | `ProfileView.swift` only unless separately approved | No plan generator, onboarding, persistence, regeneration behavior, or route changes | days/week, minutes, location, split, focus, available equipment | Large and small lower-scroll Training Setup screenshots | Medium |
| P3 Coach & Inputs | Align coaching, HealthKit, sleep, bodyweight, nutrition as quiet statuses | `ProfileView.swift` only unless separately approved | No HealthKit service changes, no permission behavior changes, no nutrition toggle behavior changes, no new source metadata | coaching prefs, nutrition mode, HealthKit state, sleep/bodyweight presence | Large and small Coach & Inputs screenshots; HealthKit unavailable/off/on if reproducible | Medium-high |
| P4 Account & Data / Pro / sync | Rehouse STRQ Pro, account, iCloud, restore purchases, and sync into calmer grouping | `ProfileView.swift` only unless separately approved | No StoreViewModel, RevenueCat, StoreKit, entitlement, package/product, restore, manage-subscription, account, iCloud, analytics, or paywall changes | store status, account status, cloud sync status | Free/pro, signed-in/signed-out, cloud unavailable if reproducible | High |
| P5 Data & Privacy / reset safety | Move reset into protected low Data & Privacy placement after copy approval | `ProfileView.swift` only unless separately approved | No `vm.resetAllData()` behavior change, no persistence reset rewrite, no broadened destructive controls | existing reset route, privacy/legal links | Reset placement plus confirmation alert screenshots | High |
| P6 About / Support polish | Footer/legal/support polish and release-gating audit | `ProfileView.swift`; DEBUG-only files only if explicitly scoped | No release-visible diagnostics, internal previews, test fixture controls, or debug labels | `STRQLinks`, app version, DEBUG gates | Lower-scroll Debug and release-style screenshot/check | Low-medium |

## 6. P1 Implementation Boundary

P1 is the safest first production slice.

Allowed P1 changes:

- `ios/STRQ/Views/ProfileView.swift` only.
- Private helper structs, private helper computed properties, or small private formatting helpers inside `ProfileView.swift`.
- Replace only the first viewport composition with the V4.1 athlete passport direction.
- Use existing reliable production data only.
- Move `subscriptionSection` lower only as a presentation/order change.

P1 row behavior clarification:

- The three rows/doors, `Training Setup`, `Coach & Inputs`, and `Account & Data`, must not appear tappable unless they route to already-existing safe production destinations.
- If the rows are display-only in P1, they must not use strong chevrons, button styling, or tap affordances.
- No new routes or behaviors are approved in P1.

STRQ Pro movement clarification:

- Moving the subscription section lower is allowed only as a presentation/order change.
- Do not change paywall, `StoreViewModel`, RevenueCat, entitlement, restore, manage-subscription, products/packages, or analytics behavior.

Forbidden P1 changes:

- No behavior changes.
- No route changes.
- No reset changes.
- No sign-in changes.
- No purchase or restore changes.
- No iCloud changes.
- No HealthKit changes.
- No nutrition toggle side-effect changes.
- No debug gating changes.
- No model, persistence, analytics, `AppViewModel`, `StoreViewModel`, RevenueCat, StoreKit, or project-file changes.
- No full Profile rebuild.
- No `Localizable` changes unless a compile issue requires a minimal fallback key and that expansion is explicitly approved.

P1 recommended UI behavior:

- Hero main read: primary goal, for example `Build Muscle`.
- Secondary read: level, days/week, and training location.
- Supporting read: split and focus areas only when reliable.
- Three calm rows below the hero:
  - `Training Setup`
  - `Coach & Inputs`
  - `Account & Data`
- Keep existing lower sections available after the first viewport so production routes remain reachable.

## 7. Release Gating

These must remain DEBUG-only:

- Design System Lab.
- Internal previews.
- Diagnostics.
- `ProfileV4SignatureExplorationView`.
- `ProfileV3PrototypeView`.
- Any fixture-driven prototype or presentation mode.

Release builds must not show:

- Debug labels.
- Internal preview rows.
- Diagnostics routes.
- Build, package, preview, sandbox, fixture, or internal configuration copy.
- Fake subscription states.
- Test fixture controls.
- Internal state names.

The V4.1 prototype remains a DEBUG reference. Production Profile must not import or display the prototype directly.

## 8. Verification And Review Gates

Future implementation verification:

```sh
xcodebuild -project ios/STRQ.xcodeproj -scheme STRQ -configuration Debug -sdk iphonesimulator -destination 'generic/platform=iOS Simulator' CODE_SIGNING_ALLOWED=NO build
```

For UI implementation slices:

- Launch on a concrete simulator for screenshots.
- Preferred large simulator: `iPhone 17 Pro Max`, iOS 26.5 when available.
- Preferred small simulator: `iPhone 17e` when available.
- Save screenshots under `docs/qa/profile-v4-production-integration-2026-05-27/` or a later slice-specific folder.
- Screenshot review must check 10-second clarity, premium feel, clear next action, believable data, human/gym-native copy, no fake precision, no settings dump, no Pro hero, no reset hero, no debug/internal labels, and fit with accepted STRQ visual direction.

Build success is not product approval. User and ChatGPT remain the final product, design, and language judges.

## 9. Explicit Non-Approval

This document does not approve:

- App source edits.
- Production Profile implementation.
- Project file changes.
- Model, persistence, analytics, RevenueCat, StoreKit, StoreViewModel, AppViewModel, account, iCloud, HealthKit, reset, plan generation, regeneration, onboarding, Active Workout, Watch, Widget, or Live Activity changes.
- Release-visible debug tools.
- Staging.
- Commit.
- Push.
