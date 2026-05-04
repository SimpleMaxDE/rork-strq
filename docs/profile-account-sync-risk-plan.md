# Profile Account Sync Risk Plan

## 1. Executive summary

Account / Sync & Restore is visually outdated compared with the accepted Profile sections. It still uses older Forge/local styling while nearby Profile modules now use calmer STRQ section headers, dark carbon card surfaces, tokenized spacing, and restrained borders.

It is not a simple UI card. This section controls Sign in with Apple, account state, iCloud restore, iCloud upload, sign-out, restore confirmation, restore outcome messaging, and cloud status messaging.

This pass makes no Swift changes. It is a read-only planning and risk audit for `ProfileView.accountSection`.

Future implementation must preserve all account/iCloud behavior exactly, including request configuration, completion handling, restore/upload branching, forced restore behavior, sign-out behavior, status interpretation, alerts, and current copy/localization.

## 2. Current implementation inventory

Source inspected:

- `ios/STRQ/Views/ProfileView.swift`
- `ios/STRQ/ViewModels/AppViewModel.swift`
- `ios/STRQ/Services/AccountManager.swift`
- `ios/STRQ/Services/CloudSyncService.swift`
- `ios/STRQ/Services/ContinuityCoordinator.swift`
- `ios/STRQ/Services/SnapshotBuilder.swift`

Profile state and alerts connected to account/cloud behavior:

- `@State private var showSignOutAlert`
- `@State private var showCloudRestoreConfirm`
- `@State private var cloudRestoreMessage`
- `@State private var showCloudRestoreMessage`
- Sign-out alert title: `L10n.tr("Sign Out?")`
- Sign-out destructive action: `vm.account.signOut()`
- Restore confirmation alert title: `L10n.tr("Restore This Device?")`
- Restore destructive action: `vm.restoreFromCloud(force: true)`
- Restore outcome message alert title: `L10n.tr("iCloud Sync")`
- Restore outcome message is stored in `cloudRestoreMessage`

`private var accountSection`:

- Section header: `ForgeSectionHeader(title: L10n.tr("Sync & Restore"))`.
- Branches on `if let account = vm.account.account`.
- Signed-in branch shows the account/cloud summary, cloud status badge, Restore This Device action, and Sign Out action.
- Signed-out branch shows a short backup/sync explanation, native Sign in with Apple button, and local-first reassurance copy.

Signed-in branch:

- State source: `vm.account.account`.
- Account display: `account.displayName` passed to `signedInCloudSummary(name:)`.
- Icon: `Image(systemName: "icloud.fill")`.
- Icon treatment: white SF Symbol on `STRQBrand.steelGradient`.
- Summary text: `signedInCloudSummary(name: account.displayName)`.
- Status badge: `cloudStatusBadge`.
- Restore action trigger: button sets `showCloudRestoreConfirm = true`.
- Restore action row: `accountActionRow(icon: "arrow.clockwise.icloud.fill", label: L10n.tr("Restore This Device"), detail: L10n.tr("Replace local data with your latest iCloud snapshot"))`.
- Sign-out trigger: button sets `showSignOutAlert = true`.
- Sign-out row: `accountActionRow(icon: "rectangle.portrait.and.arrow.right", label: L10n.tr("Sign Out"), tint: .red)`.

Signed-out branch:

- Branch condition: no `vm.account.account`.
- Icon: `Image(systemName: "person.crop.circle.badge.checkmark")`.
- Icon treatment: white SF Symbol on `STRQBrand.steelGradient`.
- Description copy: `L10n.tr("Sign in with Apple to keep your training backed up in iCloud and ready to restore on another device.")`.
- Native Apple control: `SignInWithAppleButton(.signIn)`.
- Request configuration: `vm.account.configureRequest(request)`.
- Completion handling: `vm.account.handleCompletion(result)`.
- Post-completion gate: `if vm.account.isSignedIn`.
- Post-sign-in restore path: if `vm.cloudSync.hasRemoteSnapshot` and `vm.workoutHistory.isEmpty`, call `_ = vm.restoreFromCloud(force: false)`.
- Post-sign-in upload path: otherwise call `vm.uploadToCloud()`.
- Apple button style: `.signInWithAppleButtonStyle(.white)`.
- Apple button size: `.frame(height: 44)`.
- Apple button clip: `.clipShape(.rect(cornerRadius: 11))`.
- Local-first reassurance copy: `L10n.tr("Your training stays local on this device until you turn sync on.")`.

`accountActionRow(...)`:

- Local helper used by signed-in Restore This Device and Sign Out rows.
- Parameters: `icon`, `label`, optional `detail`, and `tint`.
- Uses SF Symbols, local spacing, `.subheadline.weight(.medium)`, `.caption2`, `.secondary`, and a local chevron.
- Sign Out label is colored red by comparing `label == L10n.tr("Sign Out")`.

`signedInCloudSummary(...)`:

- Trims `account.displayName`.
- If name is present, builds `L10n.format("Signed in as %@", trimmedName)`.
- Otherwise uses `L10n.tr("Signed in with Apple")`.
- Appends `cloudStatusText` to the account line.

`cloudStatusText`:

- First gates on `vm.cloudSync.isAvailable`.
- `.syncing`: `L10n.tr("Saving recent changes")`.
- `.failed(let reason)` with `too large`: `L10n.tr("Some changes couldn't be saved to iCloud yet")`.
- `.failed`: `L10n.tr("Sync paused. Try again shortly")`.
- `.unavailable`: `L10n.tr("iCloud isn't available right now")`.
- `.success` or `.idle` with `vm.cloudSync.lastSyncText`: `L10n.format("Last synced %@", text)`.
- `.success` or `.idle` without last sync text: `L10n.tr("Changes sync automatically")`.

`cloudStatusBadge`:

- First gates on `vm.cloudSync.isAvailable`.
- Unavailable iCloud: label `OFF`, color `.gray`.
- `.syncing`: label `SYNC`, color `STRQBrand.steel`.
- `.failed`: label `CHECK`, color `STRQPalette.warning`.
- `.unavailable`: label `OFF`, color `.gray`.
- `.success` or `.idle`: label `ON`, color `STRQPalette.success`.
- Current labels are raw short strings in the helper. Do not change copy/localization in a shell-only pass.

Account/cloud service behavior found:

- `vm.account.account` and `vm.account.isSignedIn` come from `AccountManager.shared`.
- `AccountManager.configureRequest(_:)` requests `.fullName` and `.email`.
- `AccountManager.handleCompletion(_:)` stores a `STRQAccount`, persists it to `UserDefaults`, identifies analytics, tracks `.account_signed_in`, and records breadcrumbs.
- Failed Apple sign-in tracks `.account_sign_in_failed`, except user cancellation returns silently.
- `AccountManager.signOut()` clears account state, removes the account key, clears analytics identify state, tracks `.account_signed_out`, and records breadcrumbs.
- `vm.cloudSync.hasRemoteSnapshot`, `vm.cloudSync.isAvailable`, `vm.cloudSync.status`, and `vm.cloudSync.lastSyncText` come from `CloudSyncService.shared`.
- `CloudSyncService` stores snapshots in `NSUbiquitousKeyValueStore`.
- `CloudSyncService.isAvailable` checks `FileManager.default.ubiquityIdentityToken != nil`.
- `vm.restoreFromCloud(force:)` delegates to `ContinuityCoordinator.restore(force:)`.
- `vm.uploadToCloud()` delegates to `ContinuityCoordinator.uploadNow()`.
- Restore can return `.restored`, `.noSnapshot`, `.unavailable`, `.staleIgnored`, or `.decodeFailed`.
- Restore never clobbers an active workout; `ContinuityCoordinator` returns `.staleIgnored` when `vm.activeWorkout != nil`.
- Non-forced restore can skip when local data is materially richer than remote data.
- Forced restore bypasses the local-richer guard, but still respects availability, snapshot decode, missing snapshot, and active-workout protection.

Current visual systems used:

- `ForgeSectionHeader`
- SF Symbols through `Image(systemName:)`
- `STRQBrand.steelGradient`
- `Color(.secondarySystemGroupedBackground)`
- `STRQBrand.cardBorder`
- `STRQBrand.steel`
- `STRQPalette.warning`
- `STRQPalette.success`
- `.gray` and `.red` system colors
- local `.subheadline`, `.caption`, `.caption2`, `.system(size:weight:)`
- local dividers with `.opacity(0.3)`
- native `SignInWithAppleButton`

## 3. Protected behavior map

| UI element / state | Protected call/state | Current trigger | Risk if changed | Must preserve | Notes |
|---|---|---|---|---|---|
| Sign in with Apple request configuration | `vm.account.configureRequest(request)`; inside AccountManager requests `.fullName` and `.email` | Native `SignInWithAppleButton(.signIn)` request closure | User name/email capture may stop working or account records may become incomplete | Yes | Do not wrap or replace the native request path without exact parity. |
| Sign in completion handling | `vm.account.handleCompletion(result)` | Native Sign in with Apple completion closure | Account may not persist, analytics may not identify, failure/cancel handling may change | Yes | Handles credential type, persisted `STRQAccount`, analytics, and breadcrumbs. |
| Post-sign-in signed-in gate | `if vm.account.isSignedIn` | Immediately after `handleCompletion(result)` | Restore/upload could run after canceled or failed sign-in | Yes | Must remain after completion handling. |
| Post-sign-in restore branch | `vm.cloudSync.hasRemoteSnapshot`, `vm.workoutHistory.isEmpty`, `_ = vm.restoreFromCloud(force: false)` | Successful sign-in with remote snapshot and empty local history | New devices may fail to restore existing cloud data | Yes | Non-forced restore keeps local-richer protection. |
| Post-sign-in upload branch | `vm.uploadToCloud()` | Successful sign-in without remote snapshot or with local workout history | Local training may not be backed up, or remote could be overwritten at wrong time if branch changes | Yes | Upload only after sign-in and only in the existing else branch. |
| Restore This Device row | `showCloudRestoreConfirm = true` | Signed-in Restore This Device button tap | User could bypass warning before replacing local data | Yes | The row must continue to open the confirmation alert first. |
| Restore confirmation alert | `Button(..., role: .destructive)` then `vm.restoreFromCloud(force: true)` | User confirms Restore in alert | Local data replacement semantics, active-workout protection, or force behavior could change | Yes | The destructive role and force restore call are part of the safety model. |
| Forced restore behavior | `vm.restoreFromCloud(force: true)` -> `ContinuityCoordinator.restore(force:)` | Restore confirmation destructive action | Could either fail to restore when user explicitly requested it or clobber unsafe state | Yes | Force bypasses local-richer guard but still protects active workouts and unavailable/missing/decode states. |
| Restore outcome message mapping | `CloudRestoreOutcome` switch to exact `cloudRestoreMessage` copy | After forced restore returns | User may receive inaccurate data-state feedback | Yes | Preserve `.restored`, `.noSnapshot`, `.unavailable`, `.staleIgnored`, `.decodeFailed` mapping. |
| Restore outcome message alert | `showCloudRestoreMessage = true`; OK clears `cloudRestoreMessage = nil` | After forced restore message is set | User may never see result or stale message may persist | Yes | Keep alert title `iCloud Sync` and message flow. |
| Sign Out row | `showSignOutAlert = true` | Signed-in Sign Out button tap | User could sign out without confirmation | Yes | Sign-out should remain explicit but visually quiet. |
| Sign-out alert and action | `vm.account.signOut()` | User confirms Sign Out in alert | Account may not clear, analytics may not reset, or local data reassurance may change | Yes | Sign-out is destructive to account session, not local training data. |
| Cloud status summary | `signedInCloudSummary(name:)`, `cloudStatusText`, `vm.cloudSync.isAvailable/status/lastSyncText` | Signed-in branch render | Users may misunderstand sync health or last sync recency | Yes | Preserve interpretation and copy in first visual passes. |
| Cloud status badge | `cloudStatusBadge`; `OFF`, `SYNC`, `CHECK`, `ON` with current colors | Signed-in branch render | Badges could imply sync is healthy when unavailable/failed | Yes | Semantic refinement should be a separate later pass. |
| Cloud unavailable state | `!vm.cloudSync.isAvailable` or `.unavailable` | iCloud unavailable | UI could imply backup exists when it does not | Yes | Must remain visually distinct from healthy sync. |
| Cloud failed state | `.failed(String)` plus special `too large` copy | Upload/decode/local-richer failures in services | Warning may become hidden or too alarming | Yes | Preserve failed text and `CHECK` badge until approved. |
| Cloud syncing state | `.syncing` | Upload in progress | User may not know changes are being saved | Yes | Preserve `Saving recent changes` and `SYNC` meaning. |
| Cloud success/idle states | `.success(Date)`, `.idle`, `lastSyncText` | Successful or idle sync | User may lose reassurance or recency context | Yes | Preserve last-sync fallback and automatic-sync copy. |
| iCloud availability source | `FileManager.default.ubiquityIdentityToken != nil` through `vm.cloudSync.isAvailable` | Cloud service read | UI could invent availability independent of system iCloud state | Yes | No duplicated local availability state in Profile. |
| Snapshot storage and maturity guards | `NSUbiquitousKeyValueStore`, `SnapshotBuilder.maturityScore`, active-workout guard | Upload/restore service layer | Account UI could accidentally become data logic | Yes | Account visual work must not edit services/models. |

## 4. Current visual diagnosis

`accountSection` still uses `ForgeSectionHeader`, while accepted Profile sections such as Training Setup, Body & Nutrition, Notifications & Tools, Coaching Style, and Fitness Identity have moved toward `STRQSectionHeader` and STRQ tokenized card/list treatments.

The signed-in and signed-out cards use steel-gradient icon wells. These worked in the older Profile style, but now read louder and more legacy than the accepted dark carbon Profile modules.

Both branches use `Color(.secondarySystemGroupedBackground)` for the card shell. That system grouped surface feels older and lighter than the accepted `STRQColors.cardSurface` / carbon-card direction.

The border treatment uses `STRQBrand.cardBorder`, not the newer `STRQColors.borderMuted` language. Dividers use local opacity rather than the accepted divider token.

The Apple sign-in button is visually system-defined and should probably stay native. It is a trust and platform control, not a STRQ-branded CTA to reinvent.

Signed-in and signed-out states have different structure. The signed-out state is a backup invitation plus native sign-in control. The signed-in state is an active sync status module with restore and sign-out actions. They should not be forced into an identical layout if that weakens clarity.

The current action rows can feel like generic settings rows rather than a premium Sync & Restore module. Restore and Sign Out need clearer hierarchy under the sync status, but their behavior and alert triggers must remain exact.

The Sign Out row is danger-sensitive. It must stay clear and visibly different from neutral restore actions, but it should not become an oversized destructive CTA or compete with restore/sync confidence.

The cloud badge has useful compact state signaling, but the current green/yellow/steel/gray mapping is legacy. Green should remain only for semantic healthy status, warning should remain only for attention/error, and any badge refinement should happen after the shell is stable.

## 5. Product goal for Sync & Restore

Sync & Restore should communicate:

- trust
- safety
- continuity between devices
- local-first reassurance
- iCloud confidence
- recoverability
- calm account status
- clear restore and sign-out consequences

It should not become:

- a noisy account center
- a Pro/subscription-looking promotion
- a bright CTA module
- a generic settings dump
- a design pass that masks data risk

The signed-out state should feel like a trustworthy backup module: sign in to make training portable, while local training remains safe on this device.

The signed-in state should feel like an active sync status module: account identity, iCloud health, restore option, and sign-out path are visible without turning account actions into sales CTAs.

## 6. What must not change

Future visual work must not change:

- Sign in with Apple behavior.
- `SignInWithAppleButton(.signIn)`.
- `vm.account.configureRequest(request)`.
- AccountManager requested scopes `.fullName` and `.email`.
- `vm.account.handleCompletion(result)`.
- Completion failure and cancellation behavior.
- `vm.account.isSignedIn` gate after completion.
- Post-sign-in restore/upload flow.
- `vm.cloudSync.hasRemoteSnapshot` check.
- `vm.workoutHistory.isEmpty` check.
- `_ = vm.restoreFromCloud(force: false)` branch.
- `vm.uploadToCloud()` branch.
- Restore This Device trigger through `showCloudRestoreConfirm`.
- Force restore confirmation alert.
- `vm.restoreFromCloud(force: true)`.
- Restore result messaging and `CloudRestoreOutcome` mapping.
- `showCloudRestoreMessage` flow and OK behavior.
- Sign-out trigger through `showSignOutAlert`.
- `vm.account.signOut()`.
- Cloud status interpretation.
- `vm.cloudSync.isAvailable`.
- `vm.cloudSync.status`.
- `vm.cloudSync.lastSyncText`.
- Copy/localization strings.
- Alert titles, roles, buttons, messages, and order.
- Sheet behavior elsewhere in `ProfileView`.
- Account/cloud models, services, coordinators, persistence, and data.
- Analytics produced by AccountManager and CloudSync/Continuity services.
- `NSUbiquitousKeyValueStore` snapshot keys and remote data handling.
- Active-workout protection during restore.
- Any accepted/frozen Profile sections.

## 7. Visual redesign direction

Recommended direction for later implementation:

- Replace `ForgeSectionHeader` with `STRQSectionHeader` later, matching accepted Profile section headers.
- Use a dark carbon card shell aligned with accepted Profile modules.
- Use a calm trust-oriented icon well instead of the current steel-gradient well.
- Preserve the native Sign in with Apple button.
- Treat signed-out state as a trustworthy backup module.
- Treat signed-in state as an active sync status module.
- Make restore and sign-out action rows quieter and clearer.
- Keep Restore This Device as a secondary recovery action, not a primary CTA.
- Keep Sign Out visually clear but not overly aggressive.
- Use STRQ tokens for typography, spacing, radii, card surface, border, and dividers.
- Keep SF Symbols temporarily unless an exact `STRQIcon` mapping is approved.
- Do not use Pro violet/indigo unless the surface is subscription-specific.
- Do not use green unless it is semantic status.
- Do not use orange.
- Avoid making destructive/sign-out look like a CTA.
- Avoid changing copy or inventing new account-center hierarchy in the first pass.

The first visual pass should prefer shell alignment over semantic badge redesign. Status badge semantics should be refined only after the branch shell is stable and owner-approved.

## 8. State coverage requirements

Any future Swift implementation must cover:

- Signed out.
- Signed in.
- iCloud available idle.
- iCloud success with `lastSyncText`.
- iCloud success/idle without `lastSyncText`.
- Syncing.
- Failed with a `too large` reason.
- Failed with a generic reason.
- Unavailable through `vm.cloudSync.isAvailable == false`.
- Unavailable through `.unavailable`.
- Remote snapshot exists plus empty local workout history after sign-in.
- Remote snapshot missing after sign-in.
- Local workout history present after sign-in.
- Restore confirmation alert.
- Restore outcome messages for `.restored`, `.noSnapshot`, `.unavailable`, `.staleIgnored`, and `.decodeFailed`.
- Sign-out alert.
- Small iPhone viewport.
- Large iPhone viewport.

State coverage notes:

- Signed-out visual QA can be done without a cloud snapshot, but behavior QA must verify the native Apple request/completion path remains reachable.
- Signed-in visual QA needs account state simulation or a real signed-in state.
- Restore QA should be run with explicit owner permission because forced restore can replace local data.
- The active-workout restore guard is service-level behavior and must not be tested by accidental destructive restore during visual QA.
- Cloud failed/unavailable/syncing states may require service simulation, seeded state, or owner-provided screenshots before visual approval.

## 9. Risk rating

| Risk area | Rating | Reason | Mitigation |
|---|---|---|---|
| Behavior risk | High | The section includes sign-in request/completion, restore, upload, alerts, and sign-out triggers. | Shell-only phases, exact closure preservation, targeted diffs, no service/model edits. |
| Account/data risk | High | Restore can replace local data, upload can push local snapshots, and sign-out changes account identity. | Owner approval, state-by-state QA, no copy/alert changes, no restore/upload branch changes. |
| Product trust risk | High | Users rely on this surface to understand whether training is backed up, recoverable, and local-safe. | Calm trust-oriented design, preserve local-first reassurance, accurate badge/status semantics. |
| Visual risk | Medium/high | The section is visibly older and sits below accepted Profile modules, but over-polishing could hide dangerous actions. | First align the shell, then action rows, then status badge semantics. |
| Owner approval need | High | Account/iCloud restore behavior is protected and data-sensitive. | Owner should approve exact phase, screenshots/states, and QA boundaries before Swift implementation. |

Overall recommendation: do not implement the whole account section at once.

## 10. Recommended implementation phases

1. Plan completed
   - This document records implementation inventory, protected behavior, visual diagnosis, state coverage, risk, and one next prompt.

2. Signed-out shell-only visual pass, preserving native Apple button
   - Update only the signed-out card shell and surrounding header/card tokens.
   - Preserve `SignInWithAppleButton(.signIn)`, request configuration, completion handling, and post-sign-in restore/upload branch exactly.
   - Do not touch signed-in restore/sign-out rows.

3. Signed-in shell-only visual pass, preserving restore/sign-out behavior
   - Update only the signed-in card shell and status summary presentation.
   - Preserve Restore This Device and Sign Out triggers exactly.
   - Do not change cloud status badge semantics yet.

4. Action-row visual alignment
   - Align `accountActionRow(...)` with accepted STRQ list/action row styling.
   - Preserve icons, labels, details, tint, chevron, button triggers, and alert flow.

5. Cloud status badge semantic refinement
   - Revisit `cloudStatusBadge` only after shell/action rows are approved.
   - Preserve cloud status interpretation and copy unless a later prompt explicitly scopes copy/localization.

6. Final Rork QA across states
   - Verify signed-out, signed-in, status, restore, sign-out, and viewport states.
   - Use seeded/simulated account/cloud states where possible.
   - Do not run destructive restore tests without owner approval and known disposable data.

Do not do all phases at once. The visible code is compact, but account/iCloud restore is protected data behavior.

## 11. Exactly one recommended next implementation prompt

Selected option: A. signed-out accountSection shell-only pass.

Why: the signed-out branch can improve the visible Sync & Restore trust module while leaving the signed-in restore/sign-out action stack untouched. It also preserves the native Apple control, which should remain system-defined for trust and platform compliance. This is still account-sensitive, so owner approval and Rork QA are required before using the prompt.

```text
Work in repo:
C:\Users\maxwa\Documents\GitHub\rork-strq

Goal:
Migrate only the signed-out `ProfileView.accountSection` visual shell for Sync & Restore. This is a shell-only visual pass. Preserve Sign in with Apple, account, iCloud, restore, upload, status, alert, copy, and data behavior exactly.

Exact target file:
- `ios/STRQ/Views/ProfileView.swift`

Exact target section/helper:
- `private var accountSection`
- Only the signed-out `else` branch inside `accountSection`
- No edits to `accountActionRow(...)`, `signedInCloudSummary(...)`, `cloudStatusText`, or `cloudStatusBadge`

Allowed edits:
- `ios/STRQ/Views/ProfileView.swift`, scoped only to the signed-out branch visual shell of `accountSection`
- `docs/migration-progress-log.md`, one concise entry after verification

Forbidden edits:
- Do not edit the signed-in branch of `accountSection`.
- Do not edit `accountActionRow(...)`.
- Do not edit `signedInCloudSummary(...)`.
- Do not edit `cloudStatusText`.
- Do not edit `cloudStatusBadge`.
- Do not edit any Sign in with Apple request or completion closure behavior.
- Do not edit AccountManager, CloudSyncService, ContinuityCoordinator, SnapshotBuilder, AppViewModel, models, services, persistence, analytics, iCloud entitlements, project files, assets, fonts, localization catalogs, tests, Watch, Widget, Live Activity, `ContentView.swift`, `STRQApp.swift`, `STRQDesignSystem.swift`, `STRQPalette.swift`, or `ForgeTheme.swift`.
- Do not edit subscription, Profile header, fitnessIdentity, coachingStyleRow, Body & Nutrition, Training Setup, controlsSection, dangerSection, footer, paywall, RevenueCat/store files, reset behavior, notification behavior, onboarding, active workout, plan generation, progression, HealthKit, or persistence logic.
- Do not change copy or localization keys.
- Do not introduce orange.
- Do not use Pro violet/indigo in this account/iCloud surface.
- Do not make Sign Out, Restore, or Sign in look like a generic STRQ CTA.

Behavior preservation list:
- Keep `ForgeSectionHeader(title: L10n.tr("Sync & Restore"))` unless this exact pass changes only the account section header to `STRQSectionHeader(L10n.tr("Sync & Restore")).textCase(.uppercase)` with no copy change.
- Keep the branch condition `if let account = vm.account.account`.
- Keep the signed-in branch unchanged.
- Keep `SignInWithAppleButton(.signIn)` as the native Apple control.
- Keep `vm.account.configureRequest(request)` exactly in the request closure.
- Keep `vm.account.handleCompletion(result)` exactly in the completion closure.
- Keep `if vm.account.isSignedIn` exactly after completion handling.
- Keep `if vm.cloudSync.hasRemoteSnapshot, vm.workoutHistory.isEmpty`.
- Keep `_ = vm.restoreFromCloud(force: false)`.
- Keep `vm.uploadToCloud()`.
- Keep `.signInWithAppleButtonStyle(.white)`.
- Keep the Apple button height and tappability.
- Keep all signed-out copy exactly:
  - `L10n.tr("iCloud Sync")`
  - `L10n.tr("Sign in with Apple to keep your training backed up in iCloud and ready to restore on another device.")`
  - `L10n.tr("Your training stays local on this device until you turn sync on.")`
- Keep all top-level sign-out, restore confirmation, and restore message alerts unchanged.
- Keep all cloud status helpers unchanged.

Visual objective:
- Make the signed-out Sync & Restore card feel like a calm, premium, trustworthy backup module inside the accepted dark/carbon Profile style.
- Preserve the native Sign in with Apple button as the main platform control.
- Replace the older system grouped card feel with a restrained STRQ card shell if possible.
- Use a calm trust-oriented icon well, not a loud gradient.
- Communicate local-first safety and iCloud continuity without looking like a subscription upsell or account center.

Verification commands:
- `git status --short --branch`
- `git diff --name-only`
- `git diff -- ios/STRQ/Views/ProfileView.swift docs/migration-progress-log.md`
- `git diff --name-only -- ios/STRQ/ViewModels ios/STRQ/Services ios/STRQ/Models ios/STRQ/ContentView.swift ios/STRQ/STRQApp.swift ios/STRQ/Utilities/STRQDesignSystem.swift ios/STRQ/Utilities/STRQPalette.swift ios/STRQ/Utilities/ForgeTheme.swift ios/STRQ/Assets.xcassets ios/STRQ/Localizable.xcstrings ios/STRQWidget ios/STRQWatch ios/STRQ.xcodeproj`
- `rg -n "private var accountSection|SignInWithAppleButton|configureRequest|handleCompletion|isSignedIn|hasRemoteSnapshot|restoreFromCloud|uploadToCloud|showCloudRestoreConfirm|showCloudRestoreMessage|showSignOutAlert|cloudRestoreMessage|accountActionRow|signedInCloudSummary|cloudStatusText|cloudStatusBadge" ios/STRQ/Views/ProfileView.swift`
- `rg -n "AccountManager|CloudSyncService|ContinuityCoordinator|SnapshotBuilder|NSUbiquitousKeyValueStore|ubiquityIdentityToken|CloudRestoreOutcome" ios/STRQ`
- `rg -n "STRQBrand\\.accentGradient|Color\\.orange|orange" ios/STRQ/Views/ProfileView.swift`
- `rg -n "Sandow" ios/STRQ/Views ios/STRQ/ContentView.swift`

Rork QA checklist:
- Open Profile in a signed-out state on a small iPhone viewport.
- Open Profile in a signed-out state on a large iPhone viewport.
- Confirm Sync & Restore uses the accepted calm dark/carbon Profile direction.
- Confirm the native Sign in with Apple button is visible, correctly sized, and not visually restyled into a generic CTA.
- Confirm title, explanatory copy, and local-first reassurance copy are readable with no clipping.
- Tap Sign in with Apple only if using a disposable/approved test state.
- If sign-in is tested, confirm the Apple request/completion path still runs and the post-sign-in restore/upload branch is not changed by the diff.
- Confirm the signed-in branch, Restore This Device, Sign Out, cloud status badge, and all alerts are unchanged if a signed-in state can be reached.
- Confirm subscription, fitnessIdentity, coachingStyleRow, Body & Nutrition, Training Setup, controlsSection, dangerSection, and footer remain unchanged.

Report-back format:
1. Files changed
2. Protected files unchanged
3. Exact branch/helper changed
4. Behavior preserved
5. Visual summary
6. Verification command results
7. Rork QA needed/completed
8. Risks or owner approval gates
```

## 12. Rork QA checklist

Rork QA is not required for this docs-only pass because no Swift files changed.

Rork QA is required after any future `accountSection` Swift implementation. Owner should verify:

- Profile opens successfully.
- Signed-out Sync & Restore state on a small iPhone viewport.
- Signed-out Sync & Restore state on a large iPhone viewport.
- Native Sign in with Apple button is visible, correctly sized, and tappable.
- Signed-in Sync & Restore state on a small iPhone viewport.
- Signed-in Sync & Restore state on a large iPhone viewport.
- iCloud available idle/success state.
- Syncing state.
- Failed state.
- Unavailable state.
- Last synced text state.
- No last sync text fallback state.
- Remote snapshot exists plus empty workout history post-sign-in path.
- Restore confirmation alert appears before forced restore.
- Restore outcome message appears after restore attempt.
- All restore outcome message variants are reviewed if state simulation is available.
- Sign-out alert appears before sign-out.
- Sign-out copy makes clear training stays on device.
- Sign Out remains clear but not oversized or CTA-like.
- Restore This Device remains clear as a recovery action, not a casual row.
- Accepted Profile sections remain visually unchanged.
- No copy/localization changes are visible.
- No clipped text, overlapping badge, broken chevron, or layout jump on small/large iPhone.
- No destructive restore testing is performed on valuable local data without owner approval.
