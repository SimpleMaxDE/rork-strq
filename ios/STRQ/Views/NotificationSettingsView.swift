import SwiftUI

struct NotificationSettingsView: View {
    @Bindable var vm: AppViewModel
    @State private var appeared: Bool = false

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
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 32)
        }
        .background(Color(.systemBackground))
        .navigationTitle("Notifications")
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            withAnimation(.easeOut(duration: 0.4)) { appeared = true }
        }
    }

    private var permissionBanner: some View {
        HStack(spacing: 12) {
            Image(systemName: "bell.badge.fill")
                .font(.body.weight(.medium))
                .foregroundStyle(.white)
                .frame(width: 40, height: 40)
                .background(STRQBrand.steelGradient, in: .rect(cornerRadius: 10))

            VStack(alignment: .leading, spacing: 2) {
                Text("Stay on Track")
                    .font(.subheadline.weight(.semibold))
                Text("Smart reminders to keep your training consistent")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(14)
        .background(Color(.secondarySystemGroupedBackground), in: .rect(cornerRadius: 16))
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 10)
    }

    private var workoutReminders: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("Workout Reminders", icon: "dumbbell.fill", color: STRQBrand.steel)

            VStack(spacing: 1) {
                toggleRow(
                    "Workout Planned Today",
                    subtitle: "Get reminded when you have a session scheduled",
                    isOn: $vm.notificationSettings.workoutRemindersEnabled
                )

                if vm.notificationSettings.workoutRemindersEnabled {
                    HStack {
                        Text("Reminder Time")
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
                        Text("Check-In Time")
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
                        Text("Review Day")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Spacer()
                        Picker("", selection: $vm.notificationSettings.weeklyReviewDay) {
                            ForEach(0..<7) { idx in
                                Text(weekdays[idx]).tag(idx)
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
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("Coach Nudges", icon: "brain.head.profile.fill", color: .purple)

            VStack(spacing: 1) {
                toggleRow(
                    "Coach Recommendations",
                    subtitle: "When your coach has important adjustments or insights",
                    isOn: $vm.notificationSettings.coachNudgesEnabled
                )
            }
            .clipShape(.rect(cornerRadius: 14))
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 10)
        .animation(.easeOut(duration: 0.4).delay(0.2), value: appeared)
    }

    private var streakReminders: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("Streak Protection", icon: "flame.fill", color: STRQBrand.steel)

            VStack(spacing: 1) {
                toggleRow(
                    "Streak at Risk",
                    subtitle: "Reminder when your streak might break tomorrow",
                    isOn: $vm.notificationSettings.streakReminderEnabled
                )
            }
            .clipShape(.rect(cornerRadius: 14))
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 10)
        .animation(.easeOut(duration: 0.4).delay(0.25), value: appeared)
    }

    private func sectionHeader(_ title: String, icon: String, color: Color) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.subheadline)
                .foregroundStyle(color)
            Text(title)
                .font(.headline)
        }
    }

    private func toggleRow(_ title: String, subtitle: String, isOn: Binding<Bool>) -> some View {
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
