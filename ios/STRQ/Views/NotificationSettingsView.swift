import SwiftUI
import UserNotifications

struct NotificationSettingsView: View {
    @Bindable var vm: AppViewModel
    @State private var appeared: Bool = false
    @State private var authStatus: UNAuthorizationStatus = .notDetermined

    private let weekdays = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                permissionBanner
                workoutReminders
                readinessReminders
                weeklyReviewReminders
                coachNudges
                streakReminders
                healthKitSection
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 32)
        }
        .background(Color(.systemBackground))
        .navigationTitle(L10n.tr("Notifications"))
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            withAnimation(.easeOut(duration: 0.4)) { appeared = true }
            Task {
                await NotificationScheduler.shared.refreshAuthorizationStatus()
                authStatus = NotificationScheduler.shared.authorizationStatus
            }
        }
        .onChange(of: vm.notificationSettings.workoutRemindersEnabled) { _, _ in vm.rescheduleSmartReminders() }
        .onChange(of: vm.notificationSettings.readinessCheckInEnabled) { _, _ in vm.rescheduleSmartReminders() }
        .onChange(of: vm.notificationSettings.weeklyReviewEnabled) { _, _ in vm.rescheduleSmartReminders() }
        .onChange(of: vm.notificationSettings.coachNudgesEnabled) { _, _ in vm.rescheduleSmartReminders() }
        .onChange(of: vm.notificationSettings.streakReminderEnabled) { _, _ in vm.rescheduleSmartReminders() }
        .onChange(of: vm.notificationSettings.workoutReminderTime) { _, _ in vm.rescheduleSmartReminders() }
        .onChange(of: vm.notificationSettings.readinessCheckInTime) { _, _ in vm.rescheduleSmartReminders() }
        .onChange(of: vm.notificationSettings.weeklyReviewDay) { _, _ in vm.rescheduleSmartReminders() }
    }

    private var permissionBanner: some View {
        HStack(spacing: 12) {
            Image(systemName: authStatus == .authorized ? "bell.badge.fill" : "bell.slash.fill")
                .font(.body.weight(.medium))
                .foregroundStyle(.white)
                .frame(width: 40, height: 40)
                .background(STRQBrand.steelGradient, in: .rect(cornerRadius: 10))

            VStack(alignment: .leading, spacing: 2) {
                Text(bannerTitle)
                    .font(.subheadline.weight(.semibold))
                Text(bannerSubtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            if authStatus == .notDetermined {
                Button(L10n.tr("Enable")) {
                    Task {
                        _ = await NotificationScheduler.shared.requestAuthorizationIfNeeded()
                        authStatus = NotificationScheduler.shared.authorizationStatus
                        vm.rescheduleSmartReminders()
                    }
                }
                .font(.subheadline.weight(.semibold))
                .buttonStyle(.borderedProminent)
                .tint(STRQBrand.steel)
            } else if authStatus == .denied {
                Button(L10n.tr("Settings")) {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
                .font(.subheadline.weight(.semibold))
                .buttonStyle(.bordered)
            }
        }
        .padding(14)
        .background(Color(.secondarySystemGroupedBackground), in: .rect(cornerRadius: 16))
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 10)
    }

    private var bannerTitle: LocalizedStringKey {
        switch authStatus {
        case .authorized, .provisional, .ephemeral: return "Stay on Track"
        case .denied: return "Notifications Off"
        default: return "Enable Reminders"
        }
    }

    private var bannerSubtitle: LocalizedStringKey {
        switch authStatus {
        case .authorized, .provisional, .ephemeral: return "Smart reminders timed to your real schedule"
        case .denied: return "Turn on in Settings to receive STRQ reminders"
        default: return "Let STRQ remind you at the right moments"
        }
    }

    private var workoutReminders: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("Workout Reminders", icon: "dumbbell.fill", color: STRQBrand.steel)

            VStack(spacing: 1) {
                toggleRow(
                    "Workout Planned Today",
            subtitle: "Get reminded when you have a workout scheduled",
                    isOn: $vm.notificationSettings.workoutRemindersEnabled
                )

                if vm.notificationSettings.workoutRemindersEnabled {
                    HStack {
                        Text(L10n.tr("Reminder Time"))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Spacer()
                        DatePicker("", selection: $vm.notificationSettings.workoutReminderTime, displayedComponents: .hourAndMinute)
                            .labelsHidden()
                            .tint(STRQBrand.steel)
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
                    .background(Color(.secondarySystemGroupedBackground))
                }
            }
            .clipShape(.rect(cornerRadius: 14))
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 10)
        .animation(.easeOut(duration: 0.4).delay(0.05), value: appeared)
    }

    private var readinessReminders: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("Daily Check-In", icon: "heart.text.clipboard", color: .mint)

            VStack(spacing: 1) {
                toggleRow(
                    "Daily Readiness Check-In",
                    subtitle: "Morning reminder to log how you're feeling",
                    isOn: $vm.notificationSettings.readinessCheckInEnabled
                )

                if vm.notificationSettings.readinessCheckInEnabled {
                    HStack {
                        Text(L10n.tr("Check-In Time"))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Spacer()
                        DatePicker("", selection: $vm.notificationSettings.readinessCheckInTime, displayedComponents: .hourAndMinute)
                            .labelsHidden()
                            .tint(STRQBrand.steel)
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
                    .background(Color(.secondarySystemGroupedBackground))
                }
            }
            .clipShape(.rect(cornerRadius: 14))
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 10)
        .animation(.easeOut(duration: 0.4).delay(0.1), value: appeared)
    }

    private var weeklyReviewReminders: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("Weekly Review", icon: "doc.text.magnifyingglass", color: .blue)

            VStack(spacing: 1) {
                toggleRow(
                    "Weekly Review Ready",
                    subtitle: "Get notified when your weekly check-in is available",
                    isOn: $vm.notificationSettings.weeklyReviewEnabled
                )

                if vm.notificationSettings.weeklyReviewEnabled {
                    HStack {
                        Text(L10n.tr("Review Day"))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Spacer()
                        Picker("", selection: $vm.notificationSettings.weeklyReviewDay) {
                            ForEach(0..<7) { idx in
                                Text(LocalizedStringKey(weekdays[idx])).tag(idx)
                            }
                        }
                        .tint(STRQBrand.steel)
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
                    .background(Color(.secondarySystemGroupedBackground))
                }
            }
            .clipShape(.rect(cornerRadius: 14))
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 10)
        .animation(.easeOut(duration: 0.4).delay(0.15), value: appeared)
    }

    private var coachNudges: some View {
        let coachAccent = Color(red: 0.20, green: 0.48, blue: 0.78)
        let coachAccentDim = Color(red: 0.04, green: 0.10, blue: 0.17)
        let isEnabled = vm.notificationSettings.coachNudgesEnabled

        return VStack(alignment: .leading, spacing: STRQSpacing.sm) {
            Text("Coach Nudges")
                .font(STRQTypography.cardTitle)
                .foregroundStyle(STRQColors.primaryText)
                .lineLimit(1)
                .minimumScaleFactor(0.82)

            Toggle(isOn: $vm.notificationSettings.coachNudgesEnabled) {
                HStack(alignment: .center, spacing: STRQSpacing.sm) {
                    Image(systemName: "brain.head.profile.fill")
                        .font(.system(size: 15, weight: .semibold))
                        .symbolRenderingMode(.hierarchical)
                        .foregroundStyle(isEnabled ? coachAccent : coachAccent.opacity(0.62))
                        .frame(width: STRQSpacing.iconContainerMD, height: STRQSpacing.iconContainerMD)
                        .background(
                            coachAccentDim.opacity(isEnabled ? 0.72 : 0.42),
                            in: .rect(cornerRadius: STRQRadii.iconContainer)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: STRQRadii.iconContainer, style: .continuous)
                                .strokeBorder(coachAccent.opacity(isEnabled ? 0.36 : 0.18), lineWidth: 1)
                        )

                    VStack(alignment: .leading, spacing: STRQSpacing.xs) {
                        Text("Coach Recommendations")
                            .font(STRQTypography.labelMedium)
                            .foregroundStyle(STRQColors.primaryText)
                        Text("When your coach has important adjustments or insights")
                            .font(STRQTypography.paragraphSmall)
                            .foregroundStyle(STRQColors.secondaryText)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    Spacer(minLength: 0)
                }
            }
            .tint(isEnabled ? coachAccent : STRQColors.secondaryAccent)
            .padding(.horizontal, STRQSpacing.cardPaddingCompact)
            .padding(.vertical, STRQSpacing.sm)
            .background(STRQColors.cardSurface, in: .rect(cornerRadius: STRQRadii.md))
            .clipShape(.rect(cornerRadius: STRQRadii.md))
            .overlay(
                RoundedRectangle(cornerRadius: STRQRadii.md, style: .continuous)
                    .strokeBorder(
                        isEnabled ? coachAccent.opacity(0.22) : STRQColors.borderMuted,
                        lineWidth: 1
                    )
            )
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 10)
        .animation(.easeOut(duration: 0.4).delay(0.2), value: appeared)
    }

    private var streakReminders: some View {
        let streakAccent = Color(red: 0.52, green: 0.30, blue: 0.18)
        let streakAccentInk = Color(red: 0.78, green: 0.52, blue: 0.34)
        let streakAccentDim = Color(red: 0.13, green: 0.07, blue: 0.04)
        let isEnabled = vm.notificationSettings.streakReminderEnabled

        return VStack(alignment: .leading, spacing: STRQSpacing.sm) {
            Text("Streak Protection")
                .font(STRQTypography.cardTitle)
                .foregroundStyle(STRQColors.primaryText)
                .lineLimit(1)
                .minimumScaleFactor(0.82)

            Toggle(isOn: $vm.notificationSettings.streakReminderEnabled) {
                HStack(alignment: .center, spacing: STRQSpacing.sm) {
                    Image(systemName: "flame.fill")
                        .font(.system(size: 15, weight: .semibold))
                        .symbolRenderingMode(.hierarchical)
                        .foregroundStyle(isEnabled ? streakAccentInk : streakAccent.opacity(0.62))
                        .frame(width: STRQSpacing.iconContainerMD, height: STRQSpacing.iconContainerMD)
                        .background(
                            streakAccentDim.opacity(isEnabled ? 0.72 : 0.42),
                            in: .rect(cornerRadius: STRQRadii.iconContainer)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: STRQRadii.iconContainer, style: .continuous)
                                .strokeBorder(streakAccent.opacity(isEnabled ? 0.36 : 0.18), lineWidth: 1)
                        )

                    VStack(alignment: .leading, spacing: STRQSpacing.xs) {
                        Text("Streak at Risk")
                            .font(STRQTypography.labelMedium)
                            .foregroundStyle(STRQColors.primaryText)
                        Text("Reminder when your streak might break tomorrow")
                            .font(STRQTypography.paragraphSmall)
                            .foregroundStyle(STRQColors.secondaryText)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    Spacer(minLength: 0)
                }
            }
            .tint(isEnabled ? streakAccent : STRQColors.secondaryAccent)
            .padding(.horizontal, STRQSpacing.cardPaddingCompact)
            .padding(.vertical, STRQSpacing.sm)
            .background(STRQColors.cardSurface, in: .rect(cornerRadius: STRQRadii.md))
            .clipShape(.rect(cornerRadius: STRQRadii.md))
            .overlay(
                RoundedRectangle(cornerRadius: STRQRadii.md, style: .continuous)
                    .strokeBorder(
                        isEnabled ? streakAccent.opacity(0.22) : STRQColors.borderMuted,
                        lineWidth: 1
                    )
            )
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 10)
        .animation(.easeOut(duration: 0.4).delay(0.25), value: appeared)
    }

    @ViewBuilder
    private var healthKitSection: some View {
        if HealthKitService.shared.isAvailable {
            VStack(alignment: .leading, spacing: 12) {
                sectionHeader("Apple Health", icon: "heart.fill", color: .pink)

                VStack(spacing: 1) {
                    Toggle(isOn: Binding(
                        get: { vm.notificationSettings.healthKitSyncEnabled },
                        set: { newValue in
                            vm.notificationSettings.healthKitSyncEnabled = newValue
                            if newValue {
                                Task {
                                    let ok = await HealthKitService.shared.requestAuthorization()
                                    if !ok {
                                        vm.notificationSettings.healthKitSyncEnabled = false
                                    } else {
                                        await vm.syncHealthKitOnEnable()
                                    }
                                }
                            }
                        }
                    )) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(L10n.tr("Sync with Apple Health"))
                                .font(.subheadline)
                            Text(L10n.tr("Read body weight and sleep, write workouts and weigh-ins"))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .tint(STRQBrand.steel)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
                    .background(Color(.secondarySystemGroupedBackground))
                }
                .clipShape(.rect(cornerRadius: 14))
            }
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 10)
            .animation(.easeOut(duration: 0.4).delay(0.3), value: appeared)
        }
    }

    private func sectionHeader(_ title: LocalizedStringKey, icon: String, color: Color) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.subheadline)
                .foregroundStyle(color)
            Text(title)
                .font(.headline)
        }
    }

    private func toggleRow(_ title: LocalizedStringKey, subtitle: LocalizedStringKey, isOn: Binding<Bool>) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Toggle(isOn: isOn) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.subheadline)
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .tint(STRQBrand.steel)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(Color(.secondarySystemGroupedBackground))
    }
}
