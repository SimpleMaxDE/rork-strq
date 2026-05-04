# NotificationSettings Stage 1 QA Report

## 1. Executive summary

NotificationSettings Stage 1 is accepted as a visually much improved consolidation of the notification settings screen, not as a release-final notification surface.

The controlled visual micro-passes have moved the permission/status module and reminder sections away from the older grouped settings look and toward a calmer STRQ dark-card settings language. Static inspection confirms the protected notification permission, reminder binding, rescheduling, picker, and HealthKit-adjacent call paths are still represented in the current code.

This report is docs-only. It does not change Swift, scheduling, permissions, HealthKit, widgets, deep links, copy, localization, assets, project files, or tests.

## 2. Completed NotificationSettings migration areas

| Area | Stage 1 status |
|---|---|
| Permission Banner shell | Accepted for Stage 1. The shell now reads as a muted trust/status module instead of the old gradient/grouped surface. |
| Permission Banner enabled-state Settings button | Accepted for Stage 1 by static inspection. Authorized, provisional, ephemeral, and denied states expose a compact secondary Settings action, while notDetermined still exposes Enable. |
| Workout Reminders | Accepted for Stage 1. The section now uses a restrained steel/graphite treatment while preserving the toggle and Reminder Time row behavior. |
| Daily Check-In | Accepted for Stage 1. The section now uses a muted readiness teal accent while preserving the toggle and Check-In Time DatePicker behavior. |
| Weekly Review | Accepted for Stage 1. The section now uses a darker sapphire/navy review accent while preserving the toggle and Review Day Picker behavior. |
| Coach Nudges | Accepted for Stage 1. The section now uses a restrained Coach Blue / Steel Blue accent while preserving the Coach Recommendations toggle behavior. |
| Streak Protection | Accepted for Stage 1. The section now uses a darker copper/bronze treatment while preserving the Streak at Risk toggle behavior. |

## 3. Areas accepted with caveats

- Apple Health is not migrated and remains HealthKit-protected because availability, authorization, rollback, import, write, and sync behavior are sensitive.
- The actual OS notification permission flow still needs device or simulator validation across notDetermined, granted, provisional/ephemeral if reachable, and denied states.
- Scheduling behavior is statically preserved, but pending notification requests and cancellation/reschedule results still need QA.
- Global orange tint still exists elsewhere, including the app-level `ContentView` tint and older warm accent debt documented in the global tint audit.
- The copy/localization mismatch documented in the risk plan remains unresolved: `NotificationSettingsView.swift` uses `Get reminded when you have a workout scheduled`, while the localization catalog has the related `session scheduled` wording.
- macOS or CI `xcodebuild` validation is still required before shipping.

## 4. Known remaining debt

- Apple Health still uses the older local `sectionHeader`, native grouped background, `.pink` accent, and HealthKit toggle shell.
- Permission states still require real screenshots and interaction proof; static code cannot prove the native prompt, Settings handoff, or post-settings return state.
- Notification scheduling remains non-visual and must be verified through pending request inspection or device behavior.
- Global tint/accent migration is still outside this screen and should be handled with a separate approved plan.
- Copy/localization cleanup should be a later pass, not bundled into visual or scheduling work.
- Provisional and ephemeral notification states should be checked visually if the QA environment can produce them.
- The screen background and remaining native controls are acceptable for Stage 1, but not a final app-wide settings system.

## 5. Protected behavior status

Current static inspection confirms:

- `onAppear` refreshes notification authorization status through `NotificationScheduler.shared.refreshAuthorizationStatus()` and then copies `NotificationScheduler.shared.authorizationStatus` into local `authStatus`.
- The Enable button remains visible only for `.notDetermined`; it calls `NotificationScheduler.shared.requestAuthorizationIfNeeded()`, updates `authStatus`, and calls `vm.rescheduleSmartReminders()`.
- The Settings button opens `UIApplication.openSettingsURLString` in denied and authorized/provisional/ephemeral states.
- All reminder toggles still reschedule through the top-level `.onChange` hooks for `workoutRemindersEnabled`, `readinessCheckInEnabled`, `weeklyReviewEnabled`, `coachNudgesEnabled`, and `streakReminderEnabled`.
- Reminder time/day controls still reschedule through top-level `.onChange` hooks for `workoutReminderTime`, `readinessCheckInTime`, and `weeklyReviewDay`.
- `DatePicker` bindings remain preserved for Workout Reminder Time and Daily Check-In Time.
- The Weekly Review `Picker` binding remains preserved for `weeklyReviewDay`, with weekday tags still based on indexes `0..<7`.
- `NotificationScheduler` and `ReminderWidgetCoordinator` were not changed by this docs pass; the existing authorization, cancellation, scheduling, signature, and `strq.*` pending-request paths remain protected.
- The HealthKit section is unchanged and protected in this pass. It is still gated by `HealthKitService.shared.isAvailable`, still requests HealthKit authorization when enabled, still rolls `healthKitSyncEnabled` back to false on failure, and still calls `vm.syncHealthKitOnEnable()` on success.

## 6. Rork QA checklist completed/required

Completed by this docs-only pass:

- [x] Static inspection of requested NotificationSettings, scheduler, widget coordinator, HealthKit, ContentView, and migration docs.
- [x] Stage 1 acceptance/caveat split documented.

Required before treating NotificationSettings as release-ready:

- [ ] notDetermined permission state: Enable visible and unwrapped.
- [ ] authorized state: Settings visible and unwrapped.
- [ ] denied state: Settings visible and unwrapped.
- [ ] Workout toggle on/off plus time row visibility.
- [ ] Daily toggle on/off plus time row visibility.
- [ ] Weekly toggle on/off plus day row visibility.
- [ ] Coach toggle on/off.
- [ ] Streak toggle on/off.
- [ ] Apple Health visible if available, but not tested unless safe.
- [ ] Navigation from Profile and back.
- [ ] Small iPhone viewport.
- [ ] Large iPhone viewport.
- [ ] No orange or Pro violet introduced in reminder sections.

## 7. Visual consistency diagnosis

NotificationSettings is now much more coherent than the old grouped settings implementation. The migrated sections share dark card surfaces, compact row density, restrained borders, small icon wells, calmer typography, and native controls that still feel appropriate for settings.

The semantic accent system is now understandable:

- Workout = neutral steel.
- Daily = readiness teal.
- Weekly = sapphire/navy.
- Coach = coach blue.
- Streak = copper/bronze.
- Permission = trust steel.

It is colorful, but still controlled. Each reminder section has one muted semantic accent, and the dark card shell keeps the accents from turning into a rainbow settings page. The distinction is useful because the reminder types have different product meanings: training schedule, readiness habit, weekly review, coaching intelligence, and streak risk.

What still feels old is the Apple Health section, the inherited system/global tint outside this screen, and some remaining native grouped-settings DNA around the screen background and HealthKit row. Those are acceptable Stage 1 caveats, not reasons to keep polishing the completed reminder sections right now.

## 8. Release-readiness assessment for NotificationSettings

Classification: Stage 1 visually much improved, but not release-final.

NotificationSettings should not be called release-ready until permission/device QA, scheduling pending-request QA, Apple Health planning and implementation, global tint/accent migration, copy/localization review, and macOS or CI build validation are handled.

The current state is good enough to pause the visual reminder-section migration. The next work should be targeted QA and protected planning, not another broad NotificationSettings polish pass.

## 9. Recommended next NotificationSettings actions

- Plan Apple Health separately before touching the HealthKit section.
- Run permission-flow QA on device or simulator, including Enable, Settings, denied, and authorized states.
- Run scheduling QA by inspecting pending `strq.*` notification requests after toggle/time/day changes.
- Defer copy/localization cleanup to a dedicated pass.
- Consider shared pattern extraction later only if the same card/toggle shape repeats cleanly across more screens; do not extract now just to tidy this file.

## 10. Recommended next screen after NotificationSettings

Chosen next screen: E. CoachingPreferences final QA.

This is the only recommended next screen in this report.

Reason: CoachingPreferences is the closest Profile-adjacent destination already touched by earlier controlled passes. A final QA pass can close the settings/personalization loop before moving into larger behavior-heavy product surfaces. It should focus on state coverage, selected option behavior, disabled Physique behavior, navigation from Profile and back, small/large iPhone layout, no orange default selected treatment, and no preference persistence regression.
