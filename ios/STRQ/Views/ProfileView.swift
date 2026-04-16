import SwiftUI
import StoreKit

struct ProfileView: View {
    @Bindable var vm: AppViewModel
    var store: StoreViewModel
    @State private var showResetAlert: Bool = false
    @State private var showNutritionSettings: Bool = false
    @State private var showSleepLog: Bool = false
    @State private var showPaywall: Bool = false
    @State private var showManageSubscription: Bool = false
    @State private var showRestoreMessage: Bool = false

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                profileHeader
                subscriptionSection
                fitnessIdentity
                trainingSetup
                bodyNutrition
                controlsSection
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 32)
        }
        .background(Color(.systemBackground))
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            Analytics.shared.track(.profile_viewed, ["pro": store.isPro ? "true" : "false"])
            if store.isPro {
                Analytics.shared.track(.subscription_active_viewed)
            }
        }
        .alert("Reset All Data?", isPresented: $showResetAlert) {
            Button("Reset", role: .destructive) {
                vm.resetAllData()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will clear all your data and restart onboarding.")
        }
        .sheet(isPresented: $showNutritionSettings) {
            NavigationStack {
                NutritionSettingsView(vm: vm)
            }
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showSleepLog) {
            NavigationStack {
                SleepLogView(vm: vm)
            }
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showPaywall) {
            STRQPaywallView(store: store)
                .presentationDragIndicator(.visible)
        }
        .alert("Restore Purchases", isPresented: $showRestoreMessage) {
            Button("OK") {
                store.restoreMessage = nil
                store.error = nil
            }
        } message: {
            Text(store.restoreMessage ?? store.error ?? "No active subscriptions found.")
        }
    }

    // MARK: - Subscription

    private var subscriptionSection: some View {
        VStack(spacing: 10) {
            if store.isPro {
                VStack(spacing: 0) {
                    HStack(spacing: 12) {
                        Image(systemName: "bolt.fill")
                            .font(.subheadline)
                            .foregroundStyle(.white)
                            .frame(width: 34, height: 34)
                            .background(STRQBrand.steelGradient, in: .rect(cornerRadius: 9))
                        VStack(alignment: .leading, spacing: 2) {
                            Text("STRQ Pro")
                                .font(.subheadline.weight(.bold))
                            Text(store.subscriptionStatusText)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Text(store.subscriptionPlanName)
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(.green.opacity(0.8), in: Capsule())
                    }
                    .padding(14)

                    Divider().opacity(0.3).padding(.horizontal, 14)

                    Button {
                    Analytics.shared.track(.manage_subscription_opened)
                    showManageSubscription = true
                } label: {
                        HStack(spacing: 10) {
                            Image(systemName: "creditcard.fill")
                                .font(.caption)
                                .foregroundStyle(STRQBrand.steel)
                                .frame(width: 24)
                            Text("Manage Subscription")
                                .font(.subheadline.weight(.medium))
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption2.weight(.semibold))
                                .foregroundStyle(.tertiary)
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 11)
                    }
                }
                .background(Color(.secondarySystemGroupedBackground), in: .rect(cornerRadius: 14))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .strokeBorder(STRQBrand.cardBorder, lineWidth: 1)
                )
            } else {
                Button {
                    Analytics.shared.track(.paywall_viewed, ["source": "profile"])
                    showPaywall = true
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: "bolt.fill")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.black)
                            .frame(width: 34, height: 34)
                            .background(STRQBrand.accentGradient, in: .rect(cornerRadius: 9))
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Upgrade to STRQ Pro")
                                .font(.subheadline.weight(.bold))
                            Text("Unlock the full training system")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption2.weight(.semibold))
                            .foregroundStyle(.tertiary)
                    }
                    .padding(14)
                    .background(Color(.secondarySystemGroupedBackground), in: .rect(cornerRadius: 14))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .strokeBorder(Color.white.opacity(0.15), lineWidth: 1)
                    )
                }
            }
        }
        .manageSubscriptionsSheet(isPresented: $showManageSubscription)
    }

    // MARK: - Header

    private var profileHeader: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(STRQBrand.steelGradient)
                    .frame(width: 56, height: 56)
                    .overlay(
                        Circle()
                            .strokeBorder(Color.white.opacity(0.12), lineWidth: 1)
                    )
                Text(String(vm.profile.name.prefix(1)).uppercased())
                    .font(.system(.title3, design: .rounded, weight: .bold))
                    .foregroundStyle(.white)
            }

            VStack(alignment: .leading, spacing: 5) {
                Text(vm.profile.name.isEmpty ? "Athlete" : vm.profile.name)
                    .font(.system(.title3, design: .rounded, weight: .bold))
                HStack(spacing: 6) {
                    Text(vm.profile.trainingLevel.shortName)
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(STRQBrand.steel)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(STRQBrand.steel.opacity(0.15), in: Capsule())
                    Text(vm.profile.goal.displayName)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            Spacer()
        }
        .padding(.top, 4)
    }

    // MARK: - Fitness Identity

    private var fitnessIdentity: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 12) {
                Image(systemName: vm.profile.goal.symbolName)
                    .font(.title3)
                    .foregroundStyle(.white)
                    .frame(width: 42, height: 42)
                    .background(STRQBrand.steelGradient, in: .rect(cornerRadius: 11))

                VStack(alignment: .leading, spacing: 2) {
                    Text(vm.profile.goal.displayName)
                        .font(.subheadline.weight(.semibold))
                    Text(goalDescription)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
                Spacer()
            }

            Divider().opacity(0.4)

            HStack(spacing: 8) {
                statusChip(
                    icon: "heart.fill",
                    value: "\(vm.effectiveRecoveryScore)%",
                    label: "Recovery",
                    color: ForgeTheme.recoveryColor(for: vm.effectiveRecoveryScore)
                )
                statusChip(
                    icon: "moon.zzz.fill",
                    value: String(format: "%.1fh", vm.averageSleepHours),
                    label: "Sleep",
                    color: ForgeTheme.sleepColor(for: vm.averageSleepHours)
                )
                statusChip(
                    icon: "fork.knife",
                    value: "\(Int(vm.weeklyNutritionAdherence * 100))%",
                    label: "Nutrition",
                    color: vm.weeklyNutritionAdherence >= 0.8 ? .green : STRQBrand.steel
                )
            }
        }
        .padding(14)
        .background(Color(.secondarySystemGroupedBackground), in: .rect(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(STRQBrand.cardBorder, lineWidth: 1)
        )
    }

    private func statusChip(icon: String, value: String, label: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 12))
                .foregroundStyle(color)
            Text(value)
                .font(.system(.caption, design: .rounded, weight: .bold).monospacedDigit())
            Text(label)
                .font(.system(size: 9, weight: .semibold))
                .foregroundStyle(.secondary)
                .textCase(.uppercase)
                .tracking(0.3)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(Color.white.opacity(0.04), in: .rect(cornerRadius: 10))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .strokeBorder(Color.white.opacity(0.06), lineWidth: 0.5)
        )
    }

    // MARK: - Training Setup

    private var trainingSetup: some View {
        VStack(alignment: .leading, spacing: 10) {
            ForgeSectionHeader(title: "Training")

            VStack(spacing: 1) {
                profileRow("Days/Week", value: "\(vm.profile.daysPerWeek)")
                profileRow("Session", value: "\(vm.profile.minutesPerSession) min")
                profileRow("Split", value: vm.profile.splitPreference.displayName)
                profileRow("Location", value: vm.profile.trainingLocation.displayName)
            }
            .clipShape(.rect(cornerRadius: 12))

            if !vm.profile.focusMuscles.isEmpty {
                ScrollView(.horizontal) {
                    HStack(spacing: 6) {
                        Text("Focus:")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(.tertiary)
                        ForEach(vm.profile.focusMuscles) { muscle in
                            ForgeChip(text: muscle.displayName)
                        }
                    }
                }
                .contentMargins(.horizontal, 0)
                .scrollIndicators(.hidden)
            }
        }
    }

    // MARK: - Body & Nutrition

    private var bodyNutrition: some View {
        VStack(alignment: .leading, spacing: 10) {
            ForgeSectionHeader(title: "Body & Nutrition")

            VStack(spacing: 1) {
                profileRow("Height", value: "\(Int(vm.profile.heightCm)) cm")
                profileRow("Weight", value: String(format: "%.1f kg", vm.profile.weightKg))
                profileRow("Age", value: "\(vm.profile.age)")
                profileRow("Calories", value: "\(vm.nutritionTarget.calories) kcal")
                profileRow("Protein", value: "\(vm.nutritionTarget.proteinGrams)g")
                profileRow("Goal", value: vm.nutritionTarget.nutritionGoal.displayName)
            }
            .clipShape(.rect(cornerRadius: 12))

            HStack(spacing: 10) {
                Button { showNutritionSettings = true } label: {
                    Label("Edit Targets", systemImage: "slider.horizontal.3")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(STRQBrand.steel)
                        .frame(maxWidth: .infinity)
                        .frame(height: 42)
                        .background(STRQBrand.steel.opacity(0.1), in: .rect(cornerRadius: 11))
                        .overlay(
                            RoundedRectangle(cornerRadius: 11)
                                .strokeBorder(STRQBrand.steel.opacity(0.1), lineWidth: 1)
                        )
                }

                Button { showSleepLog = true } label: {
                    Label("Sleep Log", systemImage: "moon.zzz.fill")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(STRQBrand.steel)
                        .frame(maxWidth: .infinity)
                        .frame(height: 42)
                        .background(STRQBrand.steel.opacity(0.1), in: .rect(cornerRadius: 11))
                        .overlay(
                            RoundedRectangle(cornerRadius: 11)
                                .strokeBorder(STRQBrand.steel.opacity(0.1), lineWidth: 1)
                        )
                }
            }
        }
    }

    // MARK: - Controls

    private var controlsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            VStack(spacing: 1) {
                controlRow("Regenerate Plan", icon: "arrow.triangle.2.circlepath", color: STRQBrand.steel) {
                    vm.generatePlan()
                }
                NavigationLink {
                    NotificationSettingsView(vm: vm)
                } label: {
                    controlRowContent("Notifications", icon: "bell.fill", color: STRQBrand.steel)
                        .background(Color(.secondarySystemGroupedBackground))
                }
                controlRow("Restore Purchases", icon: "arrow.clockwise", color: STRQBrand.steel) {
                    guard store.isConfigured else {
                        store.restoreMessage = "Subscriptions are not available in this environment."
                        showRestoreMessage = true
                        return
                    }
                    Task {
                        await store.restore()
                        showRestoreMessage = true
                    }
                }
                controlRow("Reset All Data", icon: "trash.fill", color: .red) {
                    showResetAlert = true
                }
            }
            .clipShape(.rect(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(STRQBrand.cardBorder, lineWidth: 1)
            )

            Text("STRQ v1.0")
                .font(.caption)
                .foregroundStyle(.quaternary)
                .frame(maxWidth: .infinity)
                .padding(.top, 6)
        }
    }

    // MARK: - Components

    private func profileRow(_ label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .font(.subheadline.weight(.medium))
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 11)
        .background(Color(.secondarySystemGroupedBackground))
    }

    private func controlRow(_ label: String, icon: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            controlRowContent(label, icon: icon, color: color)
                .background(Color(.secondarySystemGroupedBackground))
        }
    }

    private func controlRowContent(_ label: String, icon: String, color: Color) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.subheadline)
                .foregroundStyle(color)
                .frame(width: 30, height: 30)
                .background(color.opacity(0.12), in: .rect(cornerRadius: 8))
            Text(label)
                .font(.subheadline)
                .foregroundStyle(label.contains("Reset") ? .red : .primary)
            Spacer()
            Image(systemName: "chevron.right")
                .font(.caption2.weight(.semibold))
                .foregroundStyle(.tertiary)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
    }

    private var goalDescription: String {
        switch vm.profile.goal {
        case .muscleGain: "Hypertrophy-focused training for lean muscle growth"
        case .strength: "Maximizing strength on key compound lifts"
        case .fatLoss: "Training with metabolic demand for fat reduction"
        case .generalFitness: "Balanced training for overall health"
        case .endurance: "Building cardiovascular and muscular endurance"
        case .flexibility: "Improving range of motion and mobility"
        case .athleticPerformance: "Sport-specific training for peak performance"
        case .rehabilitation: "Safe, progressive training for recovery"
        }
    }
}
