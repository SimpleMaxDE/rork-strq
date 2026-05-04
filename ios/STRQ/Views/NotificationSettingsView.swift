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
        let permissionAccent = Color(red: 0.58, green: 0.63, blue: 0.70)
        let permissionAccentInk = Color(red: 0.80, green: 0.84, blue: 0.89)
        let permissionAccentDim = Color(red: 0.10, green: 0.11, blue: 0.13)
        let showsSettingsButton = authStatus == .denied ||
            authStatus == .authorized ||
            authStatus == .provisional ||
            authStatus == .ephemeral

        return HStack(alignment: .center, spacing: STRQSpacing.sm) {
            Image(systemName: authStatus == .authorized ? "bell.badge.fill" : "bell.slash.fill")
                .font(.system(size: 16, weight: .semibold))
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(authStatus == .authorized ? permissionAccentInk : permissionAccent.opacity(0.72))
                .frame(width: STRQSpacing.iconContainerMD, height: STRQSpacing.iconContainerMD)
                .background(
                    permissionAccentDim.opacity(0.72),
                    in: .rect(cornerRadius: STRQRadii.iconContainer)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: STRQRadii.iconContainer, style: .continuous)
                        .strokeBorder(permissionAccent.opacity(0.30), lineWidth: 1)
                )

            VStack(alignment: .leading, spacing: STRQSpacing.xs) {
                Text(bannerTitle)
                    .font(STRQTypography.labelMedium)
                    .foregroundStyle(STRQColors.primaryText)
                Text(bannerSubtitle)
                    .font(STRQTypography.paragraphSmall)
                    .foregroundStyle(STRQColors.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .layoutPriority(1)

            Spacer(minLength: 0)

            if authStatus == .notDetermined {
                Button(L10n.tr("Enable")) {
                    Task {
                        _ = await NotificationScheduler.shared.requestAuthorizationIfNeeded()
                        authStatus = NotificationScheduler.shared.authorizationStatus
                        vm.rescheduleSmartReminders()
                    }
                }
                .font(STRQTypography.buttonCompact)
                .buttonStyle(.bordered)
                .controlSize(.small)
                .tint(permissionAccent)
            } else if showsSettingsButton {
                Button(L10n.tr("Settings")) {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
                .font(STRQTypography.buttonCompact)
                .buttonStyle(.bordered)
                .controlSize(.small)
                .tint(permissionAccent)
            }
        }
        .padding(.horizontal, STRQSpacing.cardPaddingCompact)
        .padding(.vertical, STRQSpacing.sm)
        .background(STRQColors.cardSurface, in: .rect(cornerRadius: STRQRadii.md))
        .clipShape(.rect(cornerRadius: STRQRadii.md))
        .overlay(
            RoundedRectangle(cornerRadius: STRQRadii.md, style: .continuous)
                .strokeBorder(permissionAccent.opacity(0.20), lineWidth: 1)
        )
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
        let workoutAccent = Color(red: 0.50, green: 0.58, blue: 0.66)
        let workoutAccentInk = Color(red: 0.72, green: 0.78, blue: 0.84)
        let workoutAccentDim = Color(red: 0.08, green: 0.10, blue: 0.12)
        let isEnabled = vm.notificationSettings.workoutRemindersEnabled

        return VStack(alignment: .leading, spacing: STRQSpacing.sm) {
            Text("Workout Reminders")
                .font(STRQTypography.cardTitle)
                .foregroundStyle(STRQColors.primaryText)
                .lineLimit(1)
                .minimumScaleFactor(0.82)

            VStack(spacing: 0) {
                Toggle(isOn: $vm.notificationSettings.workoutRemindersEnabled) {
                    HStack(alignment: .center, spacing: STRQSpacing.sm) {
                        Image(systemName: "dumbbell.fill")
                            .font(.system(size: 15, weight: .semibold))
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(isEnabled ? workoutAccentInk : workoutAccent.opacity(0.62))
                            .frame(width: STRQSpacing.iconContainerMD, height: STRQSpacing.iconContainerMD)
                            .background(
                                workoutAccentDim.opacity(isEnabled ? 0.72 : 0.42),
                                in: .rect(cornerRadius: STRQRadii.iconContainer)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: STRQRadii.iconContainer, style: .continuous)
                                    .strokeBorder(workoutAccent.opacity(isEnabled ? 0.36 : 0.18), lineWidth: 1)
                            )

                        VStack(alignment: .leading, spacing: STRQSpacing.xs) {
                            Text("Workout Planned Today")
                                .font(STRQTypography.labelMedium)
                                .foregroundStyle(STRQColors.primaryText)
                            Text("Get reminded when you have a workout scheduled")
                                .font(STRQTypography.paragraphSmall)
                                .foregroundStyle(STRQColors.secondaryText)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        Spacer(minLength: 0)
                    }
                }
                .tint(isEnabled ? workoutAccent : STRQColors.secondaryAccent)
                .padding(.horizontal, STRQSpacing.cardPaddingCompact)
                .padding(.vertical, STRQSpacing.sm)

                if vm.notificationSettings.workoutRemindersEnabled {
                    Divider()
                        .overlay(STRQColors.borderMuted)
                        .padding(.leading, STRQSpacing.cardPaddingCompact + STRQSpacing.iconContainerMD + STRQSpacing.sm)

                    HStack {
                        Text(L10n.tr("Reminder Time"))
                            .font(STRQTypography.paragraphSmall)
                            .foregroundStyle(STRQColors.secondaryText)
                        Spacer()
                        DatePicker("", selection: $vm.notificationSettings.workoutReminderTime, displayedComponents: .hourAndMinute)
                            .labelsHidden()
                            .tint(workoutAccent)
                    }
                    .padding(.horizontal, STRQSpacing.cardPaddingCompact)
                    .padding(.vertical, STRQSpacing.sm)
                }
            }
            .background(STRQColors.cardSurface, in: .rect(cornerRadius: STRQRadii.md))
            .clipShape(.rect(cornerRadius: STRQRadii.md))
            .overlay(
                RoundedRectangle(cornerRadius: STRQRadii.md, style: .continuous)
                    .strokeBorder(
                        isEnabled ? workoutAccent.opacity(0.22) : STRQColors.borderMuted,
                        lineWidth: 1
                    )
            )
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 10)
        .animation(.easeOut(duration: 0.4).delay(0.05), value: appeared)
    }

    private var readinessReminders: some View {
        let readinessAccent = Color(red: 0.13, green: 0.55, blue: 0.52)
        let readinessAccentInk = Color(red: 0.45, green: 0.82, blue: 0.78)
        let readinessAccentDim = Color(red: 0.03, green: 0.13, blue: 0.13)
        let isEnabled = vm.notificationSettings.readinessCheckInEnabled

        return VStack(alignment: .leading, spacing: STRQSpacing.sm) {
            Text("Daily Check-In")
                .font(STRQTypography.cardTitle)
                .foregroundStyle(STRQColors.primaryText)
                .lineLimit(1)
                .minimumScaleFactor(0.82)

            VStack(spacing: 0) {
                Toggle(isOn: $vm.notificationSettings.readinessCheckInEnabled) {
                    HStack(alignment: .center, spacing: STRQSpacing.sm) {
                        Image(systemName: "heart.text.clipboard")
                            .font(.system(size: 15, weight: .semibold))
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(isEnabled ? readinessAccentInk : readinessAccent.opacity(0.62))
                            .frame(width: STRQSpacing.iconContainerMD, height: STRQSpacing.iconContainerMD)
                            .background(
                                readinessAccentDim.opacity(isEnabled ? 0.72 : 0.42),
                                in: .rect(cornerRadius: STRQRadii.iconContainer)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: STRQRadii.iconContainer, style: .continuous)
                                    .strokeBorder(readinessAccent.opacity(isEnabled ? 0.36 : 0.18), lineWidth: 1)
                            )

                        VStack(alignment: .leading, spacing: STRQSpacing.xs) {
                            Text("Daily Readiness Check-In")
                                .font(STRQTypography.labelMedium)
                                .foregroundStyle(STRQColors.primaryText)
                            Text("Morning reminder to log how you're feeling")
                                .font(STRQTypography.paragraphSmall)
                                .foregroundStyle(STRQColors.secondaryText)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        Spacer(minLength: 0)
                    }
                }
                .tint(isEnabled ? readinessAccent : STRQColors.secondaryAccent)
                .padding(.horizontal, STRQSpacing.cardPaddingCompact)
                .padding(.vertical, STRQSpacing.sm)

                if vm.notificationSettings.readinessCheckInEnabled {
                    Divider()
                        .overlay(STRQColors.borderMuted)
                        .padding(.leading, STRQSpacing.cardPaddingCompact + STRQSpacing.iconContainerMD + STRQSpacing.sm)

                    HStack {
                        Text(L10n.tr("Check-In Time"))
                            .font(STRQTypography.paragraphSmall)
                            .foregroundStyle(STRQColors.secondaryText)
                        Spacer()
                        DatePicker("", selection: $vm.notificationSettings.readinessCheckInTime, displayedComponents: .hourAndMinute)
                            .labelsHidden()
                            .tint(readinessAccent)
                    }
                    .padding(.horizontal, STRQSpacing.cardPaddingCompact)
                    .padding(.vertical, STRQSpacing.sm)
                }
            }
            .background(STRQColors.cardSurface, in: .rect(cornerRadius: STRQRadii.md))
            .clipShape(.rect(cornerRadius: STRQRadii.md))
            .overlay(
                RoundedRectangle(cornerRadius: STRQRadii.md, style: .continuous)
                    .strokeBorder(
                        isEnabled ? readinessAccent.opacity(0.22) : STRQColors.borderMuted,
                        lineWidth: 1
                    )
            )
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 10)
        .animation(.easeOut(duration: 0.4).delay(0.1), value: appeared)
    }

    private var weeklyReviewReminders: some View {
        let reviewAccent = Color(red: 0.16, green: 0.25, blue: 0.62)
        let reviewAccentInk = Color(red: 0.46, green: 0.56, blue: 0.92)
        let reviewAccentDim = Color(red: 0.03, green: 0.04, blue: 0.14)
        let isEnabled = vm.notificationSettings.weeklyReviewEnabled

        return VStack(alignment: .leading, spacing: STRQSpacing.sm) {
            Text("Weekly Review")
                .font(STRQTypography.cardTitle)
                .foregroundStyle(STRQColors.primaryText)
                .lineLimit(1)
                .minimumScaleFactor(0.82)

            VStack(spacing: 0) {
                Toggle(isOn: $vm.notificationSettings.weeklyReviewEnabled) {
                    HStack(alignment: .center, spacing: STRQSpacing.sm) {
                        Image(systemName: "doc.text.magnifyingglass")
                            .font(.system(size: 15, weight: .semibold))
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(isEnabled ? reviewAccentInk : reviewAccent.opacity(0.62))
                            .frame(width: STRQSpacing.iconContainerMD, height: STRQSpacing.iconContainerMD)
                            .background(
                                reviewAccentDim.opacity(isEnabled ? 0.72 : 0.42),
                                in: .rect(cornerRadius: STRQRadii.iconContainer)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: STRQRadii.iconContainer, style: .continuous)
                                    .strokeBorder(reviewAccent.opacity(isEnabled ? 0.36 : 0.18), lineWidth: 1)
                            )

                        VStack(alignment: .leading, spacing: STRQSpacing.xs) {
                            Text("Weekly Review Ready")
                                .font(STRQTypography.labelMedium)
                                .foregroundStyle(STRQColors.primaryText)
                            Text("Get notified when your weekly check-in is available")
                                .font(STRQTypography.paragraphSmall)
                                .foregroundStyle(STRQColors.secondaryText)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        Spacer(minLength: 0)
                    }
                }
                .tint(isEnabled ? reviewAccent : STRQColors.secondaryAccent)
                .padding(.horizontal, STRQSpacing.cardPaddingCompact)
                .padding(.vertical, STRQSpacing.sm)

                if vm.notificationSettings.weeklyReviewEnabled {
                    Divider()
                        .overlay(STRQColors.borderMuted)
                        .padding(.leading, STRQSpacing.cardPaddingCompact + STRQSpacing.iconContainerMD + STRQSpacing.sm)

                    HStack {
                        Text(L10n.tr("Review Day"))
                            .font(STRQTypography.paragraphSmall)
                            .foregroundStyle(STRQColors.secondaryText)
                        Spacer()
                        Picker("", selection: $vm.notificationSettings.weeklyReviewDay) {
                            ForEach(0..<7) { idx in
                                Text(LocalizedStringKey(weekdays[idx])).tag(idx)
                            }
                        }
                        .tint(reviewAccent)
                    }
                    .padding(.horizontal, STRQSpacing.cardPaddingCompact)
                    .padding(.vertical, STRQSpacing.sm)
                }
            }
            .background(STRQColors.cardSurface, in: .rect(cornerRadius: STRQRadii.md))
            .clipShape(.rect(cornerRadius: STRQRadii.md))
            .overlay(
                RoundedRectangle(cornerRadius: STRQRadii.md, style: .continuous)
                    .strokeBorder(
                        isEnabled ? reviewAccent.opacity(0.22) : STRQColors.borderMuted,
                        lineWidth: 1
                    )
            )
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
