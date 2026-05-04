# NotificationSettings Risk Plan

## 1. Executive summary

NotificationSettings is the next logical continuation after Profile Stage 1. It is visually close to Profile because it is a settings-style row/toggle surface entered from Profile's accepted Notifications & Tools section.

It is not a simple visual screen. Notifications involve system permission state, permission requests, scheduling, cancellation, reminder toggles, reminder times, deep-link routes, and fallback behavior through system Settings. The same screen also contains an Apple Health toggle, which is HealthKit-adjacent and protected.

This pass makes no Swift changes. It creates a read-only planning and risk report only.

Future implementation must preserve notification behavior exactly. Visual polish must not change permission requests, scheduling/canceling logic, notification identifiers, deep links, reminder times, enabled states, HealthKit authorization/sync behavior, copy/localization, alerts/sheets, or view-model/service/model behavior.

## 2. Current implementation inventory

Source inspected:

- `docs/profile-stage-1-qa-report.md`
- `docs/strq-premium-visual-direction-report.md`
- `docs/profile-remaining-sections-risk-audit.md`
- `docs/qa-validation-plan.md`
- `docs/migration-progress-log.md`
- `ios/STRQ/Views/NotificationSettingsView.swift`
- `ios/STRQ/Views/ProfileView.swift`
- `ios/STRQ/Models/NotificationSettings.swift`
- `ios/STRQ/Services/NotificationScheduler.swift`
- `ios/STRQ/Services/ReminderWidgetCoordinator.swift`
- `ios/STRQ/Models/NotificationDeepLinkRoute.swift`
- `ios/STRQ/Services/NotificationDeepLinkCenter.swift`
- `ios/STRQ/AppDelegate.swift`
- `ios/STRQ/ContentView.swift`
- `ios/STRQ/STRQApp.swift`
- `ios/STRQ/ViewModels/AppViewModel.swift`
- `ios/STRQ/Services/HealthKitService.swift`
- `ios/STRQ/Services/WorkoutController.swift`
- `ios/STRQ/Services/PersistenceStore.swift`

Main view:

- `struct NotificationSettingsView: View`
- `@Bindable var vm: AppViewModel`
- `@State private var appeared: Bool = false`
- `@State private var authStatus: UNAuthorizationStatus = .notDetermined`
- `private let weekdays = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]`

Profile navigation entry:

- `ProfileView.controlsSection` uses `STRQSectionHeader(L10n.tr("Notifications & Tools"))`.
- The Notifications row is a `NavigationLink` whose destination is `NotificationSettingsView(vm: vm)`.
- The visible row label is `controlsListRowContent(L10n.tr("Notifications"), icon: .bell, opticalEmphasis: .notifications)`.

Screen structure:

- `ScrollView` with a vertical stack.
- Sections render in this order: `permissionBanner`, `workoutReminders`, `readinessReminders`, `weeklyReviewReminders`, `coachNudges`, `streakReminders`, `healthKitSection`.
- Navigation title: `L10n.tr("Notifications")`.
- Background: `Color(.systemBackground)`.
- `navigationBarTitleDisplayMode(.large)`.
- On appear: animates `appeared`, refreshes `NotificationScheduler.shared.authorizationStatus`, then copies it into local `authStatus`.

View-model notification values used:

- `vm.notificationSettings.workoutRemindersEnabled`
- `vm.notificationSettings.readinessCheckInEnabled`
- `vm.notificationSettings.weeklyReviewEnabled`
- `vm.notificationSettings.coachNudgesEnabled`
- `vm.notificationSettings.streakReminderEnabled`
- `vm.notificationSettings.healthKitSyncEnabled`
- `vm.notificationSettings.workoutReminderTime`
- `vm.notificationSettings.readinessCheckInTime`
- `vm.notificationSettings.weeklyReviewDay`

`NotificationSettings` model defaults:

- `workoutRemindersEnabled = true`
- `readinessCheckInEnabled = true`
- `weeklyReviewEnabled = true`
- `coachNudgesEnabled = true`
- `streakReminderEnabled = true`
- `healthKitSyncEnabled = false`
- `workoutReminderTime = 17:00`
- `readinessCheckInTime = 08:00`
- `weeklyReviewDay = 1`
- Decoding is tolerant and falls back to these defaults for missing keys.

Rows and toggles:

- Workout Reminders section:
  - Header: `sectionHeader("Workout Reminders", icon: "dumbbell.fill", color: STRQBrand.steel)`.
  - Toggle row title: `Workout Planned Today`.
  - Toggle row subtitle: `Get reminded when you have a workout scheduled`.
  - Binding: `$vm.notificationSettings.workoutRemindersEnabled`.
  - Conditional time row appears only when enabled.
  - Time picker: `DatePicker("", selection: $vm.notificationSettings.workoutReminderTime, displayedComponents: .hourAndMinute)`.
- Daily Check-In section:
  - Header: `sectionHeader("Daily Check-In", icon: "heart.text.clipboard", color: .mint)`.
  - Toggle row title: `Daily Readiness Check-In`.
  - Toggle row subtitle: `Morning reminder to log how you're feeling`.
  - Binding: `$vm.notificationSettings.readinessCheckInEnabled`.
  - Conditional time row appears only when enabled.
  - Time picker: `DatePicker("", selection: $vm.notificationSettings.readinessCheckInTime, displayedComponents: .hourAndMinute)`.
- Weekly Review section:
  - Header: `sectionHeader("Weekly Review", icon: "doc.text.magnifyingglass", color: .blue)`.
  - Toggle row title: `Weekly Review Ready`.
  - Toggle row subtitle: `Get notified when your weekly check-in is available`.
  - Binding: `$vm.notificationSettings.weeklyReviewEnabled`.
  - Conditional day row appears only when enabled.
  - Day picker: `Picker("", selection: $vm.notificationSettings.weeklyReviewDay)` over indexes `0..<7`, with `LocalizedStringKey(weekdays[idx])`.
- Coach Nudges section:
  - Header: `sectionHeader("Coach Nudges", icon: "brain.head.profile.fill", color: .purple)`.
  - Toggle row title: `Coach Recommendations`.
  - Toggle row subtitle: `When your coach has important adjustments or insights`.
  - Binding: `$vm.notificationSettings.coachNudgesEnabled`.
- Streak Protection section:
  - Header: `sectionHeader("Streak Protection", icon: "flame.fill", color: STRQBrand.steel)`.
  - Toggle row title: `Streak at Risk`.
  - Toggle row subtitle: `Reminder when your streak might break tomorrow`.
  - Binding: `$vm.notificationSettings.streakReminderEnabled`.
- Apple Health section:
  - Gated by `HealthKitService.shared.isAvailable`.
  - Header: `sectionHeader("Apple Health", icon: "heart.fill", color: .pink)`.
  - Toggle title: `L10n.tr("Sync with Apple Health")`.
  - Toggle subtitle: `L10n.tr("Read body weight and sleep, write workouts and weigh-ins")`.
  - Custom binding getter: `vm.notificationSettings.healthKitSyncEnabled`.
  - Custom setter sets `vm.notificationSettings.healthKitSyncEnabled = newValue`.
  - If turned on, runs `HealthKitService.shared.requestAuthorization()`.
  - If HealthKit authorization fails, sets `vm.notificationSettings.healthKitSyncEnabled = false`.
  - If authorization succeeds, calls `await vm.syncHealthKitOnEnable()`.

Button actions:

- Permission Enable button:
  - Visible only when `authStatus == .notDetermined`.
  - Label: `L10n.tr("Enable")`.
  - Action: `NotificationScheduler.shared.requestAuthorizationIfNeeded()`, update `authStatus`, then call `vm.rescheduleSmartReminders()`.
- Permission Settings button:
  - Visible only when `authStatus == .denied`.
  - Label: `L10n.tr("Settings")`.
  - Action: open `UIApplication.openSettingsURLString` through `UIApplication.shared.open(url)`.

Permission request flows:

- On appear refreshes current notification authorization with `NotificationScheduler.shared.refreshAuthorizationStatus()`.
- Notification permission request uses `UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge])`.
- Authorized, provisional, and ephemeral are treated as schedule-eligible.
- Denied or unavailable/default statuses do not request again from the app; the view shows Settings for denied.
- HealthKit permission uses `HealthKitService.shared.requestAuthorization()` and requests body mass, sleep analysis, body mass write, and workout write where HealthKit is available.

Scheduling and rescheduling calls:

- `NotificationSettingsView` calls `vm.rescheduleSmartReminders()` on changes to:
  - `workoutRemindersEnabled`
  - `readinessCheckInEnabled`
  - `weeklyReviewEnabled`
  - `coachNudgesEnabled`
  - `streakReminderEnabled`
  - `workoutReminderTime`
  - `readinessCheckInTime`
  - `weeklyReviewDay`
- `vm.rescheduleSmartReminders()` delegates to `ReminderWidgetCoordinator.scheduleIfNeeded(force: true)`.
- `ReminderWidgetCoordinator.scheduleIfNeeded(force:)` returns early when onboarding is not completed.
- The coordinator builds `NotificationScheduler.ScheduleInput` from current workouts, readiness, weekly review, streak, lapse tier, missing body weight, missing sleep, and notification settings.
- It calls `Task { await NotificationScheduler.shared.reschedule(with: input) }`.
- `AppViewModel.init` calls `scheduleSmartRemindersIfNeeded(force: true)` after loading persisted state.
- `AppViewModel.persist()` calls `reminderWidgetCoordinator.scheduleIfNeeded()` and `refreshWidgetSnapshot()`.
- `STRQApp` calls `vm.rescheduleSmartReminders()` when the scene becomes active.

Scheduling behavior in `NotificationScheduler`:

- `reschedule(with:)` refreshes authorization first.
- If authorization is not authorized/provisional/ephemeral, it calls `cancelAll()` and returns.
- If authorized/provisional/ephemeral, it calls `cancelAll()` first, then schedules enabled reminders.
- `cancelAll()` gets all pending notification requests, filters identifiers with prefix `strq.`, and removes only those identifiers.
- Scheduled categories and identifiers:
  - `strq.workout.today`
  - `strq.workout.next`
  - `strq.readiness.today`
  - `strq.weekly_review.next`
  - `strq.streak.risk`
  - `strq.logging.weight`
  - `strq.logging.sleep`
  - `strq.coach.return`
- `scheduleWorkoutReminder(input:)` uses `workoutReminderTime`, today's workout, rest-day state, next scheduled workout date/name, early-stage state, readiness bucket, and workout focus.
- `scheduleReadinessCheckIn(input:)` uses `readinessCheckInTime`, requires no check-in today, requires workout today, and skips rest days.
- `scheduleWeeklyReview(input:)` requires at least three completed workouts and maps `weeklyReviewDay` from `0...6` to calendar weekday `1...7`; time is fixed at 09:00.
- `scheduleStreakReminder(input:)` requires streak at least 3 and last active date; fires at 19:30 the day after last activity if still future.
- `scheduleLoggingNudges(input:)` runs under the Coach Nudges toggle, established users only; weight nudge uses missing body weight days, sleep nudge uses missing sleep days.
- `scheduleInactivityNudge(input:)` runs under the Coach Nudges toggle; uses `lapseTier` to choose comeback title/body and target timing.
- `add(id:content:trigger:)` uses `UNNotificationRequest`; add errors go to `ErrorReporter.shared.report(error)`.

Reminder state and persistence:

- Notification settings are part of `PersistedAppState.notificationSettings`.
- `PersistenceStore` decodes missing notification settings as `NotificationSettings()`.
- Reset all data sets `notificationSettings = NotificationSettings()`.
- HealthKit sync state is also stored in `notificationSettings`.

Notification deep links, categories, and routes:

- `NotificationDeepLinkRoute` cases:
  - `.resumeWorkout = "resume_workout"`
  - `.readinessCheckIn = "readiness_check_in"`
  - `.sleepLog = "sleep_log"`
- User info key: `deep_link_route`.
- Explicit user info routes are set for:
  - workout reminders: `.resumeWorkout`
  - readiness check-in: `.readinessCheckIn`
  - sleep log: `.sleepLog`
  - comeback coach nudge: `.resumeWorkout`
- Fallback request-identifier routing:
  - `strq.workout.*` and `strq.coach.*` route to `.resumeWorkout`.
  - `strq.readiness.*` routes to `.readinessCheckIn`.
  - `strq.logging.sleep` routes to `.sleepLog`.
- `AppDelegate` sets the notification center delegate in `willFinishLaunchingWithOptions`.
- Foreground notifications present with `[.banner, .sound, .badge]`.
- Notification responses enqueue the resolved route in `NotificationDeepLinkCenter.shared`.
- `ContentView` consumes pending routes on `.task` and on route changes.
- `.resumeWorkout` selects Today tab, expands an active workout if present, or calls `vm.prepareWorkoutHandoff(day:)` for today's or next workout.
- `.readinessCheckIn` presents `ReadinessCheckInView(vm: vm)` in a sheet and submits through `vm.submitReadiness(readiness)`.
- `.sleepLog` presents `SleepLogView(vm: vm)` in a `NavigationStack` sheet with large detent and drag indicator.

Alerts, sheets, and dialogs:

- `NotificationSettingsView` itself defines no alerts, sheets, or confirmation dialogs.
- Downstream notification deep-link handling in `ContentView` can present Readiness and Sleep Log sheets.
- Permission denied fallback opens the system Settings app, not a custom sheet.
- HealthKit permission uses the native HealthKit authorization prompt, not a custom sheet.

HealthKit-adjacent behavior:

- The Apple Health row is present only when `HealthKitService.shared.isAvailable`.
- Enabling the row requests HealthKit authorization.
- Failed authorization immediately rolls `healthKitSyncEnabled` back to false.
- Successful authorization calls `vm.syncHealthKitOnEnable()`.
- `syncHealthKitOnEnable()` reads latest body weight and recent sleep; it may insert entries, update `profile.weightKg`, refresh nutrition insights, and persist.
- `AppViewModel.logBodyWeight(...)` writes body weight to HealthKit when `notificationSettings.healthKitSyncEnabled` is true.
- `WorkoutController` saves workouts to HealthKit when `vm.notificationSettings.healthKitSyncEnabled` is true.

Current visual systems used:

- `Color(.systemBackground)`
- `Color(.secondarySystemGroupedBackground)`
- `STRQBrand.steelGradient`
- `STRQBrand.steel`
- SF Symbols via `Image(systemName:)`
- System semantic colors: `.mint`, `.blue`, `.purple`, `.pink`, `.white`, `.secondary`
- Local `.font(.headline)`, `.subheadline`, `.caption`, and weight modifiers
- Local padding, corner radii `10`, `14`, `16`, and clipped section shells
- Native SwiftUI `Toggle`, `DatePicker`, and `Picker`
- `.buttonStyle(.borderedProminent)` and `.buttonStyle(.bordered)`

Copy/localization strings in `NotificationSettingsView`:

- `Notifications`
- Weekdays: `Sunday`, `Monday`, `Tuesday`, `Wednesday`, `Thursday`, `Friday`, `Saturday`
- Permission banner/actions: `Enable`, `Settings`, `Stay on Track`, `Notifications Off`, `Enable Reminders`, `Smart reminders timed to your real schedule`, `Turn on in Settings to receive STRQ reminders`, `Let STRQ remind you at the right moments`
- Workout section: `Workout Reminders`, `Workout Planned Today`, `Get reminded when you have a workout scheduled`, `Reminder Time`
- Daily Check-In section: `Daily Check-In`, `Daily Readiness Check-In`, `Morning reminder to log how you're feeling`, `Check-In Time`
- Weekly Review section: `Weekly Review`, `Weekly Review Ready`, `Get notified when your weekly check-in is available`, `Review Day`
- Coach section: `Coach Nudges`, `Coach Recommendations`, `When your coach has important adjustments or insights`
- Streak section: `Streak Protection`, `Streak at Risk`, `Reminder when your streak might break tomorrow`
- Apple Health section: `Apple Health`, `Sync with Apple Health`, `Read body weight and sleep, write workouts and weigh-ins`

Localization note:

- Static search found `Get reminded when you have a workout scheduled` in `NotificationSettingsView.swift`, while `Localizable.xcstrings` contains `Get reminded when you have a session scheduled`. This report does not change copy or localization. Future visual implementation should not "fix" or normalize this unless a copy/localization pass is explicitly approved.

## 3. Protected behavior map

| UI element | Protected call/state | Current trigger | Risk if changed | Must preserve | Notes |
|---|---|---|---|---|---|
| Profile Notifications row | `NavigationLink { NotificationSettingsView(vm: vm) }` | Tap Notifications row in Profile controls section | Screen may lose shared `AppViewModel`, break state persistence, or route incorrectly | Yes | Entry is accepted Profile Stage 1 behavior. |
| Screen appear | `NotificationScheduler.shared.refreshAuthorizationStatus()` then `authStatus = NotificationScheduler.shared.authorizationStatus` | `NotificationSettingsView.onAppear` | Banner may show stale permission status or wrong action | Yes | Also animates `appeared`; animation is visual only but should not block status refresh. |
| Enable permission button | `NotificationScheduler.shared.requestAuthorizationIfNeeded()` | Tap `Enable` when `authStatus == .notDetermined` | Permission prompt may not appear, wrong options may be requested, or user intent may be ignored | Yes | Preserve request path and options `[.alert, .sound, .badge]`. |
| Permission reschedule after enable | `authStatus = ...`; `vm.rescheduleSmartReminders()` | After Enable task completes | Newly granted reminders may not be scheduled | Yes | Preserve status update before/with reschedule. |
| Denied permission fallback | `UIApplication.shared.open(UIApplication.openSettingsURLString)` | Tap `Settings` when `authStatus == .denied` | User may be trapped without a system path to re-enable notifications | Yes | Do not replace with custom permission UX unless approved. |
| Permission eligibility | authorized/provisional/ephemeral accepted | `NotificationScheduler.reschedule(with:)` | Provisional/ephemeral users could lose reminders or denied users could keep stale requests | Yes | Preserve current status categories. |
| Permission denied/unavailable cancellation | `await cancelAll()` when not schedule-eligible | `NotificationScheduler.reschedule(with:)` | Old pending STRQ notifications may remain after permission/state is invalid | Yes | Cancellation only removes pending identifiers with prefix `strq.`. |
| Workout reminder toggle | `$vm.notificationSettings.workoutRemindersEnabled` | User toggles Workout Planned Today | Workout reminders may schedule when disabled or disappear when enabled | Yes | On-change reschedules all smart reminders. |
| Workout reminder time | `$vm.notificationSettings.workoutReminderTime` | User changes DatePicker | Reminders may fire at old/wrong time | Yes | Preserve `DatePicker` binding and `.hourAndMinute`. |
| Readiness reminder toggle | `$vm.notificationSettings.readinessCheckInEnabled` | User toggles Daily Readiness Check-In | Readiness prompts may appear on wrong days or not appear when wanted | Yes | Scheduling also gates on workout today, not checked in, and non-rest day. |
| Readiness check-in time | `$vm.notificationSettings.readinessCheckInTime` | User changes DatePicker | Morning reminders may fire at old/wrong time | Yes | Preserve binding and `.hourAndMinute`. |
| Weekly review toggle | `$vm.notificationSettings.weeklyReviewEnabled` | User toggles Weekly Review Ready | Weekly check-in notification may appear incorrectly or disappear | Yes | Scheduler requires at least three completed workouts. |
| Weekly review day | `$vm.notificationSettings.weeklyReviewDay` | User changes day picker | Weekly review may schedule on wrong weekday | Yes | Preserve 0...6 picker tags and scheduler mapping `(day % 7) + 1`. |
| Coach nudges toggle | `$vm.notificationSettings.coachNudgesEnabled` | User toggles Coach Recommendations | Logging nudges and inactivity comeback nudges may change or stop | Yes | This one toggle controls both logging nudges and inactivity nudge scheduling. |
| Streak toggle | `$vm.notificationSettings.streakReminderEnabled` | User toggles Streak at Risk | Streak protection reminders may fire unexpectedly or not fire | Yes | Scheduler requires streak at least 3 and last active date. |
| Generic toggle helper | `toggleRow(..., isOn:)` passes existing binding to `Toggle` | Render of five notification toggles | Shared helper edits can accidentally affect every reminder toggle | Yes | Avoid broad helper changes in first implementation. |
| Scheduling rebuild | `vm.rescheduleSmartReminders()` | Five toggle changes plus workout/readiness time and weekly day changes | Stale, duplicated, or missing notifications | Yes | Delegates to coordinator with `force: true`. |
| Coordinator onboarding gate | `guard vm.hasCompletedOnboarding else { return }` | Any schedule attempt | Pre-onboarding users could receive reminders too early | Yes | Do not bypass coordinator. |
| Reminder signature cache | `lastScheduledSignature` | Persist/background schedule calls | Duplicates or missed refreshes if changed | Yes | Visual work should not touch coordinator. |
| Cancellation/removal behavior | pending requests filtered by `identifier.hasPrefix("strq.")` | Every reschedule and permission-ineligible schedule attempt | Non-STRQ notifications could be removed, or stale STRQ notifications could remain | Yes | Prefix scope is a safety boundary. |
| Notification identifiers | `strq.workout.today`, `strq.workout.next`, `strq.readiness.today`, `strq.weekly_review.next`, `strq.streak.risk`, `strq.logging.weight`, `strq.logging.sleep`, `strq.coach.return` | Scheduler add calls | Deep links, cancellation, or duplicate prevention may break | Yes | Do not rename identifiers in visual work. |
| Workout notification route | `NotificationDeepLinkRoute.resumeWorkout.userInfo` and fallback `strq.workout.*` / `strq.coach.*` | Workout reminders and comeback nudges | Tapping notification may not open Today/workout handoff | Yes | Preserve userInfo and fallback mapping. |
| Readiness notification route | `NotificationDeepLinkRoute.readinessCheckIn.userInfo` and fallback `strq.readiness.*` | Readiness notification | Tapping notification may not open readiness sheet | Yes | Preserve route and ContentView sheet handling. |
| Sleep logging route | `NotificationDeepLinkRoute.sleepLog.userInfo` and fallback exact `strq.logging.sleep` | Sleep log nudge | Tapping notification may not open Sleep Log sheet | Yes | Preserve exact identifier and route. |
| Foreground presentation | `completionHandler([.banner, .sound, .badge])` | Notification arrives while app foregrounded | Users may not see/hear foreground reminders | Yes | AppDelegate is out of scope. |
| HealthKit row availability | `if HealthKitService.shared.isAvailable` | Render Apple Health section | Unavailable devices may show unusable HealthKit control | Yes | Keep system availability gate. |
| HealthKit toggle setter | custom binding setter | User toggles Sync with Apple Health | HealthKit may enable without permission or fail without rollback | Yes | Preserve setter, async request, rollback, and sync call. |
| HealthKit authorization request | `HealthKitService.shared.requestAuthorization()` | HealthKit toggle turned on | Health data access may fail or request wrong types | Yes | Protected and owner-gated. |
| HealthKit failed fallback | `vm.notificationSettings.healthKitSyncEnabled = false` | HealthKit authorization returns false | UI may imply HealthKit sync is on when it is not authorized | Yes | Must preserve rollback. |
| HealthKit sync on enable | `await vm.syncHealthKitOnEnable()` | HealthKit authorization succeeds | Latest weight/sleep may not import, or persistence may change unexpectedly | Yes | Do not touch from notification visual pass. |
| HealthKit writes from app | `saveBodyWeight`, `saveWorkout` guarded by `healthKitSyncEnabled` | Body weight log or workout completion | Visual work could accidentally alter HealthKit side effects if model/service is touched | Yes | Do not edit view models/services. |
| Copy/localization | all existing strings and keys | Rendered screen and notification content | Copy drift, missing translations, or wrong trust messaging | Yes | Current copy mismatch is documented only; do not change in visual pass. |
| Alerts/sheets/dialogs | none in `NotificationSettingsView`; downstream ContentView sheets for deep links | Notification route handling | Adding custom permission sheets or changing route sheets can change product trust and behavior | Yes | No custom permission UX without approval. |

## 4. Current visual diagnosis

`NotificationSettingsView` is structurally a good continuation from Profile Stage 1 because it is rows, toggles, small controls, and sections. The accepted Profile style can inform it.

The current visual implementation still feels older than the accepted Profile sections:

- It uses `Color(.systemBackground)` and `Color(.secondarySystemGroupedBackground)` rather than the accepted dark carbon card/list surfaces.
- Section headers are local `HStack` helpers with SF Symbols and `.headline`, not `STRQSectionHeader`.
- Rows are clipped local `VStack` groups with system grouped backgrounds, not STRQ list/card language.
- The permission banner uses `STRQBrand.steelGradient`, which reads closer to older local Profile treatments than the newer calm carbon style.
- Toggle rows use native `Toggle`, which is appropriate, but the surrounding row shell is generic iOS settings styling.
- The DatePicker and Picker rows are simple and native, which is behaviorally safe, but the shells still look like system grouped table cells.
- The section accent colors are mixed: `STRQBrand.steel`, `.mint`, `.blue`, `.purple`, `.pink`, `.white`, and `.secondary`.
- The purple Coach Nudges section is not Pro violet, but future work should still avoid turning notifications into a purple/product-tier surface.
- The Streak section uses `flame.fill` with steel instead of orange, which is good. Future work should keep avoiding orange default.
- Density is reasonable, but hierarchy is a bit fragmented because each small section becomes a mini card stack.
- The screen reads as functional Settings.app UI rather than a STRQ-owned trust/control surface.

Alignment with accepted Profile style:

- Good: simple rows, native controls, dark mode, compact settings hierarchy, no loud orange CTA.
- Not yet aligned: system grouped surfaces, local section headers, gradient icon well, inconsistent semantic accents, older corner/padding language, and lack of `STRQSectionHeader`/accepted Profile list shell.

Where it looks too old, too loud, too grey, or too settings-like:

- Too old: `secondarySystemGroupedBackground` row shells and local headers.
- Too loud: permission icon gradient and mixed section accent colors.
- Too grey: repeated grouped backgrounds do not create enough premium carbon hierarchy.
- Too settings-like: every section feels like a generic toggle group instead of STRQ explaining calm habit support.

## 5. Product goal for notifications

NotificationSettings should communicate:

- control
- trust
- habit support
- non-annoying reminders
- clarity about what STRQ will notify
- safety around permissions
- respect for the user's system settings
- a calm connection between training schedule, readiness, weekly review, coach nudges, streaks, and HealthKit-adjacent sync

It should not communicate:

- a noisy settings dump
- a notification growth hack
- a permission trick
- a generic iOS settings clone
- a bright CTA surface
- a Pro or upsell surface
- a screen where every reminder has the same visual urgency

The product story should be: STRQ helps keep the training habit intact without nagging, and the user remains in control.

## 6. What must not change

Future visual work must not change:

- Notification permission request flow.
- `NotificationScheduler.shared.refreshAuthorizationStatus()`.
- `NotificationScheduler.shared.requestAuthorizationIfNeeded()`.
- `UNUserNotificationCenter.requestAuthorization(options: [.alert, .sound, .badge])`.
- Notification authorization status handling for authorized, provisional, ephemeral, denied, and not determined.
- Settings.app fallback through `UIApplication.openSettingsURLString`.
- Reminder enabled states.
- Reminder times.
- Weekly review day values and tags.
- `vm.rescheduleSmartReminders()`.
- `ReminderWidgetCoordinator.scheduleIfNeeded(force:)`.
- The onboarding gate before scheduling.
- The schedule signature behavior.
- `NotificationScheduler.reschedule(with:)`.
- `NotificationScheduler.cancelAll()`.
- Pending notification filtering by `strq.` prefix.
- Notification identifiers.
- Notification routes/deep links.
- Notification userInfo key `deep_link_route`.
- ContentView deep-link route handling.
- AppDelegate foreground presentation and response handling.
- Notification titles/body keys and localization behavior.
- HealthKit row availability gate.
- HealthKit authorization request.
- HealthKit failed-authorization rollback.
- `vm.syncHealthKitOnEnable()`.
- Body weight/sleep import behavior.
- HealthKit workout/body-weight write guards.
- Copy/localization unless later approved.
- View-model, service, and model behavior.
- Alerts/sheets/dialogs, including the absence of custom permission sheets in this screen.
- Assets, fonts, app tint, project files, Watch, Widget, Live Activity, tests, RevenueCat/store files, and accepted Profile Stage 1 areas.

## 7. Visual redesign direction

Recommended direction for later implementation:

- Use `STRQSectionHeader` for section titles, aligned with accepted Profile.
- Move toward calm dark/carbon row groups using existing STRQ card/list/toggle language.
- Keep native/system controls where appropriate, especially `Toggle`, `DatePicker`, `Picker`, system notification permission prompt, Settings.app fallback, and HealthKit prompt.
- Use a clear permission/status row that tells the user current state without trying to spoof system permission UI.
- Use semantic accents only when meaningful:
  - notification permission/status
  - readiness
  - weekly review
  - HealthKit
  - destructive/unavailable states if represented later
- Do not use Pro violet.
- Do not use orange as a default.
- Do not create a custom permission UX unless explicitly approved.
- Keep row density compact and scannable.
- Avoid nested cards and avoid making every section a loud mini-card.
- Prefer shell/list alignment before changing icons, copy, or semantic color meaning.
- Keep DatePicker/Picker rows visually calm and native.
- Treat HealthKit as a protected system integration row, not a notification row.

Recommended first visual posture:

- Do a tiny row/shell pass first.
- Keep `toggleRow(...)` unchanged unless the pass explicitly intends to affect all toggle rows.
- Avoid permission banner and HealthKit toggle until their states are mapped in Rork.
- Avoid changing all sections at once.

## 8. State coverage requirements

Any future Swift implementation must cover:

- Notification permission not determined.
- Notification permission granted.
- Notification permission provisional/ephemeral if state can be simulated.
- Notification permission denied.
- Permission Settings fallback visible and tappable.
- Reminders enabled.
- Reminders disabled.
- Workout reminder time changed.
- Readiness check-in time changed.
- Weekly review day changed.
- Scheduled successfully, as represented by pending requests or no visible error.
- Scheduling failed if represented by `ErrorReporter` or any future UI state.
- Permission unavailable/denied causing STRQ pending requests to cancel.
- Coach nudges enabled and disabled.
- Streak reminder enabled and disabled.
- HealthKit unavailable.
- HealthKit available but off.
- HealthKit authorization granted.
- HealthKit authorization denied/failed with toggle rollback.
- Small iPhone viewport.
- Large iPhone viewport.
- Navigation from Profile to Notifications and back.
- Notification deep-link routes to Today/workout handoff, readiness check-in sheet, and sleep log sheet if a future pass touches route-adjacent UI.

State coverage notes:

- Rork visual QA can verify most UI states, but actual notification scheduling/permission QA may need owner-approved device/simulator state setup.
- Denied notification permission is a system state and may require resetting simulator permissions.
- HealthKit states may require a device/simulator capability decision.
- Scheduling success is mostly non-visual today; do not invent a visual success state in the first pass.
- Do not test destructive reset or unrelated Profile behavior while testing notifications.

## 9. Risk rating

| Risk area | Rating | Reason | Mitigation |
|---|---|---|---|
| Behavior risk | High | Toggle/time/day changes trigger smart reminder rescheduling, which cancels and rebuilds pending `strq.*` requests. | Start with one narrow non-permission row shell; preserve bindings and on-change handlers exactly. |
| Permission/system risk | High | The screen requests notification permission, opens system Settings, and includes HealthKit authorization. | Do not touch permission banner or HealthKit row in the first implementation pass. Keep native system prompts. |
| Product trust risk | High | Notifications can feel intrusive if visual hierarchy implies nagging or hides permission/control meaning. | Use calm trust-oriented copy presentation and clear status messaging without copy changes. |
| Visual risk | Medium | The screen is visibly older and settings-like, but the layout is simple and close to accepted Profile row language. | Migrate small shells in phases with Rork screenshots. |
| Owner approval need | High | Notification scheduling, permission requests, deep links, HealthKit, and reminder behavior are protected. | Owner should approve exact phase and state checklist before Swift implementation. |

Overall recommendation: do not implement the whole NotificationSettings screen at once.

## 10. Recommended implementation phases

1. Plan completed
   - This document records current implementation, protected behavior, visual diagnosis, product goal, state coverage, risk, and one next prompt.

2. Static shell/section planning
   - Confirm which section/header/list primitive will be used.
   - Decide whether `STRQSectionHeader` can replace local headers without changing copy or behavior.
   - Do not touch Swift unless explicitly approved.

3. One low-risk row/toggle shell pass
   - Target one non-permission, non-time-picker, non-HealthKit toggle section first.
   - Preserve direct binding, on-change reschedule behavior, labels, icons, and order.
   - Recommended candidate: `coachNudges`, because it has one toggle and no DatePicker, Picker, permission, Settings app action, or HealthKit authorization.

4. Permission/status row pass
   - After state screenshots are available, refine the permission banner/status row.
   - Preserve `refreshAuthorizationStatus`, `requestAuthorizationIfNeeded`, denied Settings fallback, and status copy.
   - Do not custom-build a permission prompt.

5. Scheduling/time-picker visual pass
   - Refine Workout, Readiness, and Weekly Review rows containing DatePicker/Picker controls.
   - Preserve bindings, conditional visibility, day tags, and reschedule handlers.
   - Verify enabled/disabled and time/day changed states.

6. Final Rork QA
   - Verify small/large iPhone, permission states, reminder enabled/disabled states, time/day changes, HealthKit state, Profile navigation, and back navigation.
   - Validate no protected files changed and no notification behavior was modified.

Do not do all phases at once. The screen is compact, but notification and HealthKit behavior makes broad implementation unsafe.

## 11. Exactly one recommended next implementation prompt

Selected option: B. One low-risk non-permission toggle row visual pass.

Why: `coachNudges` is the smallest useful visual target in `NotificationSettingsView`. It has one toggle and no permission button, no Settings app fallback, no DatePicker, no Picker, and no HealthKit authorization. It still affects scheduling through `vm.rescheduleSmartReminders()`, so the prompt must preserve the binding and all on-change behavior exactly. Starting here gives the team one low-risk row/toggle proof before touching permission/status, time pickers, HealthKit, or the whole screen shell.

```text
Work in repo:
C:\Users\maxwa\Documents\GitHub\rork-strq

Goal:
Migrate only the `coachNudges` section visual shell in `ios/STRQ/Views/NotificationSettingsView.swift`. This is a tiny non-permission toggle-row visual pass. Preserve notification scheduling, permission, HealthKit, route, copy, localization, and view-model behavior exactly.

Exact target file:
- `ios/STRQ/Views/NotificationSettingsView.swift`

Exact target section/helper:
- `private var coachNudges`
- Optional new private helper used only by `coachNudges`, if needed
- Do not edit the shared `toggleRow(...)` helper unless the final diff proves no other section output changes; prefer a coach-nudges-only helper for this first pass

Allowed edits:
- `ios/STRQ/Views/NotificationSettingsView.swift`, scoped only to `private var coachNudges` and any coach-nudges-only private visual helper
- `docs/migration-progress-log.md`, one concise entry after verification

Forbidden edits:
- Do not edit `permissionBanner`, `bannerTitle`, `bannerSubtitle`, `workoutReminders`, `readinessReminders`, `weeklyReviewReminders`, `streakReminders`, `healthKitSection`, `sectionHeader(...)`, or the shared `toggleRow(...)` helper unless explicitly needed and proven scoped.
- Do not edit `ProfileView.swift`, `ContentView.swift`, `STRQApp.swift`, `AppDelegate.swift`, notification services/managers, `NotificationScheduler.swift`, `ReminderWidgetCoordinator.swift`, `NotificationDeepLinkCenter.swift`, `NotificationDeepLinkRoute.swift`, `AppViewModel.swift`, `NotificationSettings.swift`, `HealthKitService.swift`, `WorkoutController.swift`, ViewModels, Services, Models, STRQ design-system utilities, `STRQPalette.swift`, `ForgeTheme.swift`, assets, fonts, `Localizable.xcstrings`, RevenueCat/store files, Watch, Widget, Live Activity, project files, tests, or asset catalogs.
- Do not change copy, localization keys, icons, notification identifiers, deep links, route handling, permission prompts, system Settings fallback, HealthKit authorization, scheduling/rescheduling logic, cancellation behavior, persistence, analytics, onboarding gates, or widget behavior.
- Do not introduce Pro violet.
- Do not introduce orange as a default accent.
- Do not create custom permission UI.
- Do not do a whole-screen NotificationSettings redesign.

Behavior preservation list:
- Keep `coachNudges` in the same order between `weeklyReviewReminders` and `streakReminders`.
- Keep section title `Coach Nudges`.
- Keep section icon `brain.head.profile.fill`.
- Keep current section accent meaning unless visual shell only changes the container.
- Keep row title `Coach Recommendations`.
- Keep row subtitle `When your coach has important adjustments or insights`.
- Keep the toggle bound to `$vm.notificationSettings.coachNudgesEnabled`.
- Keep `.onChange(of: vm.notificationSettings.coachNudgesEnabled) { _, _ in vm.rescheduleSmartReminders() }` unchanged.
- Keep `vm.rescheduleSmartReminders()` behavior untouched.
- Keep `NotificationScheduler.reschedule(with:)`, `cancelAll()`, and all `strq.*` identifiers untouched.
- Keep Coach Nudges scheduling semantics: when enabled, it schedules logging nudges and inactivity comeback nudges through the existing scheduler.
- Keep notification deep-link routes untouched.
- Keep HealthKit toggle and permission behavior untouched.
- Keep notification permission banner and Settings fallback untouched.

Visual objective:
- Make only the Coach Nudges section feel closer to the accepted calm dark/carbon Profile row style.
- Use a restrained STRQ row/card shell and typography if available locally in the file imports.
- Keep native `Toggle` behavior and a compact settings-row density.
- Improve premium alignment without making the row look like a CTA, Pro upsell, alert, or permission prompt.
- Avoid loud purple, orange, gradients, or extra explanatory copy.

Verification commands:
- `git status --short --branch`
- `git diff --name-only`
- `git diff -- ios/STRQ/Views/NotificationSettingsView.swift docs/migration-progress-log.md`
- `git diff --name-only -- ios/STRQ/Views/ProfileView.swift ios/STRQ/ContentView.swift ios/STRQ/STRQApp.swift ios/STRQ/AppDelegate.swift ios/STRQ/ViewModels ios/STRQ/Services ios/STRQ/Models ios/STRQ/Utilities/STRQDesignSystem.swift ios/STRQ/Utilities/STRQPalette.swift ios/STRQ/Utilities/ForgeTheme.swift ios/STRQ/Assets.xcassets ios/STRQ/Localizable.xcstrings ios/STRQWidget ios/STRQWatch ios/STRQ.xcodeproj`
- `rg -n "private var coachNudges|Coach Nudges|Coach Recommendations|coachNudgesEnabled|rescheduleSmartReminders|scheduleLoggingNudges|scheduleInactivityNudge" ios/STRQ/Views/NotificationSettingsView.swift ios/STRQ/Services/NotificationScheduler.swift`
- `rg -n "requestAuthorizationIfNeeded|UIApplication.openSettingsURLString|workoutReminderTime|readinessCheckInTime|weeklyReviewDay|healthKitSyncEnabled|HealthKitService|NotificationDeepLinkRoute|strq\\." ios/STRQ/Views/NotificationSettingsView.swift ios/STRQ/Services ios/STRQ/Models ios/STRQ/ContentView.swift ios/STRQ/AppDelegate.swift`
- `rg -n "Sandow" ios/STRQ/Views ios/STRQ/ContentView.swift`

Rork QA checklist:
- Open Profile on a small iPhone viewport.
- Tap Notifications and confirm `NotificationSettingsView(vm: vm)` opens.
- Confirm Coach Nudges appears between Weekly Review and Streak Protection.
- Confirm the Coach Nudges section visually matches the calm dark/carbon direction without looking like a CTA or permission banner.
- Confirm the title and subtitle are readable with no clipping.
- Toggle Coach Recommendations off and on.
- Confirm the screen does not crash or visually jump.
- Confirm navigation back to Profile works.
- Confirm permission banner, Workout Reminders, Daily Check-In, Weekly Review, Streak Protection, and Apple Health sections are unchanged.
- Confirm notification permission request and Settings fallback are untouched.
- Confirm HealthKit toggle behavior is untouched.
- Repeat on a large iPhone viewport.

Report-back format:
1. Files changed
2. Protected files unchanged
3. Exact NotificationSettings section/helper changed
4. Behavior preserved
5. Visual summary
6. Verification command results
7. Rork QA needed/completed
8. Risks or owner approval gates
```

## 12. Rork QA checklist

Rork QA is not required for this docs-only pass because no Swift files changed.

Rork QA is required after any future `NotificationSettingsView` Swift implementation. Owner should verify:

- Profile opens successfully.
- Notifications row opens `NotificationSettingsView(vm: vm)`.
- Back navigation returns to Profile.
- Small iPhone viewport.
- Large iPhone viewport.
- Permission not determined state.
- Permission granted state.
- Permission denied state with Settings fallback.
- Enable permission button behavior if using an approved simulator/device state.
- Workout reminders enabled.
- Workout reminders disabled.
- Workout reminder time changed.
- Daily Readiness Check-In enabled.
- Daily Readiness Check-In disabled.
- Readiness check-in time changed.
- Weekly Review enabled.
- Weekly Review disabled.
- Weekly review day changed.
- Coach Nudges enabled.
- Coach Nudges disabled.
- Streak Protection enabled.
- Streak Protection disabled.
- HealthKit unavailable state.
- HealthKit available/off state.
- HealthKit authorization granted state if approved.
- HealthKit authorization denied/failed rollback if approved.
- No copied or changed notification strings unless a copy pass is approved.
- No clipped text, overlapping controls, broken toggle alignment, or layout jumps.
- No custom permission UX appears.
- No Pro violet or orange default treatment appears.
- Notification identifiers, routes, and scheduling behavior are untouched in the diff.
- Rork QA should not claim scheduling success unless pending requests or device behavior are explicitly verified.
