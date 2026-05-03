import SwiftUI
import StoreKit
import AuthenticationServices

struct ProfileView: View {
    @Bindable var vm: AppViewModel
    var store: StoreViewModel
    @State private var showResetAlert: Bool = false
    @State private var showNutritionSettings: Bool = false
    @State private var showSleepLog: Bool = false
    @State private var showPaywall: Bool = false
    @State private var showManageSubscription: Bool = false
    @State private var showRestoreMessage: Bool = false
    @State private var showSignOutAlert: Bool = false
    @State private var showCloudRestoreConfirm: Bool = false
    @State private var cloudRestoreMessage: String?
    @State private var showCloudRestoreMessage: Bool = false
    @State private var showMediaDiagnostics: Bool = false
    @State private var showPlanRegenerationDialog: Bool = false

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                profileHeader
                subscriptionSection
                fitnessIdentity
                coachingStyleRow
                bodyNutrition
                trainingSetup
                controlsSection
                accountSection
                dangerSection
                footerSection
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 32)
        }
        .background(Color(.systemBackground))
        .navigationTitle(L10n.tr("Profile"))
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            Analytics.shared.track(.profile_viewed, ["pro": store.isPro ? "true" : "false"])
            if store.isPro {
                Analytics.shared.track(.subscription_active_viewed)
            }
        }
        .alert(L10n.tr("Reset All Data?"), isPresented: $showResetAlert) {
            Button(L10n.tr("Reset"), role: .destructive) {
                vm.resetAllData()
            }
            Button(L10n.tr("Cancel"), role: .cancel) {}
        } message: {
            Text(L10n.tr("This will clear all your data and restart onboarding."))
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
        .sheet(isPresented: $showMediaDiagnostics) {
            NavigationStack { MediaDiagnosticsView() }
        }
        .planRegenerationFlow(vm: vm, isPresented: $showPlanRegenerationDialog) {
            vm.requestTodayTab()
        }
        .sheet(isPresented: $showPaywall) {
            STRQPaywallView(store: store)
                .presentationDragIndicator(.visible)
        }
        .alert(L10n.tr("Sign Out?"), isPresented: $showSignOutAlert) {
            Button(L10n.tr("Sign Out"), role: .destructive) {
                vm.account.signOut()
            }
            Button(L10n.tr("Cancel"), role: .cancel) {}
        } message: {
            Text(L10n.tr("Your training stays on this device. You can sign in again later to sync or restore from iCloud."))
        }
        .alert(L10n.tr("Restore This Device?"), isPresented: $showCloudRestoreConfirm) {
            Button(L10n.tr("Restore"), role: .destructive) {
                let outcome = vm.restoreFromCloud(force: true)
                cloudRestoreMessage = {
                    switch outcome {
                    case .restored: return L10n.tr("This device has been updated from your latest iCloud snapshot.")
                    case .noSnapshot: return L10n.tr("No iCloud snapshot is available yet. Once you train while signed in, changes will sync automatically.")
                    case .unavailable: return L10n.tr("iCloud isn't available right now. Check that iCloud is enabled, then try again.")
                    case .staleIgnored: return L10n.tr("This device is already using your latest iCloud data.")
                    case .decodeFailed: return L10n.tr("We couldn't read your iCloud data right now. Try again in a moment.")
                    }
                }()
                showCloudRestoreMessage = true
            }
            Button(L10n.tr("Cancel"), role: .cancel) {}
        } message: {
            Text(L10n.tr("Use your most recent iCloud snapshot on this device. Current local data will be replaced."))
        }
        .alert(L10n.tr("iCloud Sync"), isPresented: $showCloudRestoreMessage) {
            Button(L10n.tr("OK")) { cloudRestoreMessage = nil }
        } message: {
            Text(cloudRestoreMessage ?? "")
        }
        .alert(L10n.tr("Restore Purchases"), isPresented: $showRestoreMessage) {
            Button(L10n.tr("OK")) {
                store.restoreMessage = nil
                store.error = nil
            }
        } message: {
            Text(store.restoreMessage ?? store.error ?? L10n.tr("No active subscriptions found."))
        }
    }

    // MARK: - Account

    private var accountSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            ForgeSectionHeader(title: L10n.tr("Sync & Restore"))

            if let account = vm.account.account {
                VStack(spacing: 0) {
                    HStack(spacing: 12) {
                        Image(systemName: "icloud.fill")
                            .font(.subheadline)
                            .foregroundStyle(.white)
                            .frame(width: 34, height: 34)
                            .background(STRQBrand.steelGradient, in: .rect(cornerRadius: 9))
                        VStack(alignment: .leading, spacing: 2) {
                            Text(L10n.tr("iCloud Sync"))
                                .font(.subheadline.weight(.bold))
                            Text(signedInCloudSummary(name: account.displayName))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        Spacer()
                        cloudStatusBadge
                    }
                    .padding(14)

                    Divider().opacity(0.3).padding(.horizontal, 14)

                    Button {
                        showCloudRestoreConfirm = true
                    } label: {
                        accountActionRow(
                            icon: "arrow.clockwise.icloud.fill",
                            label: L10n.tr("Restore This Device"),
                            detail: L10n.tr("Replace local data with your latest iCloud snapshot")
                        )
                    }

                    Divider().opacity(0.3).padding(.horizontal, 14)

                    Button {
                        showSignOutAlert = true
                    } label: {
                        accountActionRow(icon: "rectangle.portrait.and.arrow.right", label: L10n.tr("Sign Out"), tint: .red)
                    }
                }
                .background(Color(.secondarySystemGroupedBackground), in: .rect(cornerRadius: 14))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .strokeBorder(STRQBrand.cardBorder, lineWidth: 1)
                )
            } else {
                VStack(alignment: .leading, spacing: 10) {
                    HStack(spacing: 12) {
                        Image(systemName: "person.crop.circle.badge.checkmark")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.white)
                            .frame(width: 34, height: 34)
                            .background(STRQBrand.steelGradient, in: .rect(cornerRadius: 9))
                        VStack(alignment: .leading, spacing: 2) {
                            Text(L10n.tr("iCloud Sync"))
                                .font(.subheadline.weight(.bold))
                            Text(L10n.tr("Sign in with Apple to keep your training backed up in iCloud and ready to restore on another device."))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        Spacer(minLength: 0)
                    }

                    SignInWithAppleButton(.signIn) { request in
                        vm.account.configureRequest(request)
                    } onCompletion: { result in
                        vm.account.handleCompletion(result)
                        if vm.account.isSignedIn {
                            if vm.cloudSync.hasRemoteSnapshot, vm.workoutHistory.isEmpty {
                                _ = vm.restoreFromCloud(force: false)
                            } else {
                                vm.uploadToCloud()
                            }
                        }
                    }
                    .signInWithAppleButtonStyle(.white)
                    .frame(height: 44)
                    .clipShape(.rect(cornerRadius: 11))

                    Text(L10n.tr("Your training stays local on this device until you turn sync on."))
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
                .padding(14)
                .background(Color(.secondarySystemGroupedBackground), in: .rect(cornerRadius: 14))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .strokeBorder(STRQBrand.cardBorder, lineWidth: 1)
                )
            }
        }
    }

    private func proPillarChip(icon: String, label: String) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 9, weight: .semibold))
            Text(label)
                .font(.system(size: 10, weight: .semibold))
                .lineLimit(1)
                .minimumScaleFactor(0.72)
        }
        .foregroundStyle(STRQBrand.steel)
        .padding(.horizontal, 8)
        .padding(.vertical, 5)
        .frame(maxWidth: .infinity)
        .background(STRQBrand.steel.opacity(0.12), in: Capsule())
        .overlay(
            Capsule()
                .strokeBorder(STRQBrand.steel.opacity(0.15), lineWidth: 0.5)
        )
    }

    private func accountActionRow(icon: String, label: String, detail: String? = nil, tint: Color = STRQBrand.steel) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(tint)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(label == L10n.tr("Sign Out") ? .red : .primary)

                if let detail {
                    Text(detail)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            Spacer()
            Image(systemName: "chevron.right")
                .font(.caption2.weight(.semibold))
                .foregroundStyle(.tertiary)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 11)
    }

    private func signedInCloudSummary(name: String?) -> String {
        let trimmedName: String? = name?.trimmingCharacters(in: .whitespacesAndNewlines)
        let accountLine: String
        if let trimmedName, !trimmedName.isEmpty {
            accountLine = L10n.format("Signed in as %@", trimmedName)
        } else {
            accountLine = L10n.tr("Signed in with Apple")
        }
        return "\(accountLine) · \(cloudStatusText)"
    }

    private var cloudStatusText: String {
        guard vm.cloudSync.isAvailable else {
            return L10n.tr("iCloud isn't available right now")
        }
        switch vm.cloudSync.status {
        case .syncing:
            return L10n.tr("Saving recent changes")
        case .failed(let reason):
            if reason.localizedCaseInsensitiveContains("too large") {
                return L10n.tr("Some changes couldn't be saved to iCloud yet")
            }
            return L10n.tr("Sync paused. Try again shortly")
        case .unavailable:
            return L10n.tr("iCloud isn't available right now")
        case .success, .idle:
            if let text = vm.cloudSync.lastSyncText {
                return L10n.format("Last synced %@", text)
            }
            return L10n.tr("Changes sync automatically")
        }
    }

    private var cloudStatusBadge: some View {
        let (label, color): (String, Color) = {
            guard vm.cloudSync.isAvailable else { return ("OFF", .gray) }
            switch vm.cloudSync.status {
            case .syncing: return ("SYNC", STRQBrand.steel)
            case .failed: return ("CHECK", STRQPalette.warning)
            case .unavailable: return ("OFF", .gray)
            case .success, .idle: return ("ON", STRQPalette.success)
            }
        }()
        return Text(label)
            .font(.system(size: 10, weight: .bold))
            .foregroundStyle(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(color.opacity(0.8), in: Capsule())
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
                            Text(L10n.tr("STRQ Pro"))
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
                            .background(STRQPalette.success.opacity(0.8), in: Capsule())
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
                            Text(L10n.tr("Manage Subscription"))
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
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 12) {
                            Image(systemName: "bolt.fill")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(.black)
                                .frame(width: 34, height: 34)
                                .background(STRQBrand.accentGradient, in: .rect(cornerRadius: 9))
                            VStack(alignment: .leading, spacing: 2) {
                                Text(L10n.tr("STRQ Pro"))
                                    .font(.subheadline.weight(.bold))
                                Text(L10n.tr("Deeper coaching, plans that evolve, full ecosystem."))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(2)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            Spacer(minLength: 0)
                            Image(systemName: "chevron.right")
                                .font(.caption2.weight(.semibold))
                                .foregroundStyle(.tertiary)
                        }

                        HStack(spacing: 5) {
                            proPillarChip(icon: "brain.head.profile.fill", label: L10n.tr("Adaptive"))
                            proPillarChip(icon: "arrow.triangle.2.circlepath", label: L10n.tr("Evolving"))
                            proPillarChip(icon: "icloud.fill", label: L10n.tr("Sync"))
                            proPillarChip(icon: "applewatch", label: L10n.tr("Apple Watch"))
                        }
                    }
                    .padding(14)
                    .background(Color(white: 0.105), in: .rect(cornerRadius: 14))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .strokeBorder(Color.white.opacity(0.15), lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
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

            VStack(alignment: .leading, spacing: 6) {
                Text(vm.profile.name.isEmpty ? L10n.tr("Athlete") : vm.profile.name)
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
                Text(profileHeaderSummary)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
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
                    if !vm.isEarlyStage {
                        Text(goalDescription)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                    }
                }
                Spacer()
            }

            Divider().opacity(0.4)

            HStack(spacing: 8) {
                statusChip(
                    icon: "heart.fill",
                    value: "\(vm.effectiveRecoveryScore)%",
                    label: L10n.tr("Recovery"),
                    color: ForgeTheme.recoveryColor(for: vm.effectiveRecoveryScore)
                )
                statusChip(
                    icon: "moon.zzz.fill",
                    value: String(format: "%.1fh", vm.averageSleepHours),
                    label: L10n.tr("Sleep"),
                    color: ForgeTheme.sleepColor(for: vm.averageSleepHours)
                )
                if vm.profile.nutritionTrackingEnabled {
                    statusChip(
                        icon: "fork.knife",
                        value: "\(Int(vm.weeklyNutritionAdherence * 100))%",
                        label: L10n.tr("Nutrition"),
                        color: vm.weeklyNutritionAdherence >= 0.8 ? STRQPalette.success : STRQBrand.steel
                    )
                } else {
                    statusChip(
                        icon: "flame.fill",
                        value: "\(vm.streak)",
                        label: L10n.tr("Streak"),
                        color: STRQBrand.steel
                    )
                }
            }
        }
        .padding(14)
        .background(Color(white: 0.105), in: .rect(cornerRadius: 16))
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
        .background(Color.white.opacity(0.06), in: .rect(cornerRadius: 10))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .strokeBorder(Color.white.opacity(0.06), lineWidth: 0.5)
        )
    }

    // MARK: - Training Setup

    private var trainingSetup: some View {
        VStack(alignment: .leading, spacing: 10) {
            ForgeSectionHeader(title: L10n.tr("Training Setup"))

            VStack(spacing: 1) {
                profileRow(L10n.tr("Days / Week"), value: "\(vm.profile.daysPerWeek)")
                profileRow(L10n.tr("Workout Length"), value: L10n.format("%d min", vm.profile.minutesPerSession))
                profileRow(L10n.tr("Split"), value: vm.profile.splitPreference.displayName)
                profileRow(L10n.tr("Location"), value: vm.profile.trainingLocation.displayName)
            }
            .clipShape(.rect(cornerRadius: 12))

            if !vm.profile.focusMuscles.isEmpty {
                ScrollView(.horizontal) {
                    HStack(spacing: 6) {
                        Text(L10n.tr("Focus:"))
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
            ForgeSectionHeader(title: L10n.tr("Body & Nutrition"))

            trackingToggleCard

            VStack(spacing: 1) {
                profileRow(L10n.tr("Height"), value: L10n.format("%d cm", Int(vm.profile.heightCm)))
                profileRow(L10n.tr("Weight"), value: L10n.format("%.1f kg", vm.profile.weightKg))
                profileRow(L10n.tr("Age"), value: "\(vm.profile.age)")
                if vm.profile.nutritionTrackingEnabled {
                    profileRow(L10n.tr("Calories"), value: L10n.format("%d kcal", vm.nutritionTarget.calories))
                    profileRow(L10n.tr("Protein"), value: L10n.format("%dg", vm.nutritionTarget.proteinGrams))
                    profileRow(L10n.tr("Goal"), value: vm.nutritionTarget.nutritionGoal.displayName)
                }
            }
            .clipShape(.rect(cornerRadius: 12))

            HStack(spacing: 10) {
                if vm.profile.nutritionTrackingEnabled {
                    Button { showNutritionSettings = true } label: {
                        Label(L10n.tr("Edit Targets"), systemImage: "slider.horizontal.3")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(STRQBrand.steel)
                            .frame(maxWidth: .infinity)
                            .frame(height: 44)
                            .background(STRQBrand.steel.opacity(0.1), in: .rect(cornerRadius: 11))
                            .overlay(
                                RoundedRectangle(cornerRadius: 11)
                                    .strokeBorder(STRQBrand.steel.opacity(0.1), lineWidth: 1)
                            )
                    }
                    .buttonStyle(.strqPressable)
                }

                Button { showSleepLog = true } label: {
                    Label(L10n.tr("Sleep Log"), systemImage: "moon.zzz.fill")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(STRQBrand.steel)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(STRQBrand.steel.opacity(0.1), in: .rect(cornerRadius: 11))
                        .overlay(
                            RoundedRectangle(cornerRadius: 11)
                                .strokeBorder(STRQBrand.steel.opacity(0.1), lineWidth: 1)
                        )
                }
                .buttonStyle(.strqPressable)
            }
        }
    }

    private var trackingToggleCard: some View {
        let on = vm.profile.nutritionTrackingEnabled
        return VStack(alignment: .leading, spacing: 8) {
            Toggle(isOn: Binding(
                get: { vm.profile.nutritionTrackingEnabled },
                set: { newValue in
                    vm.profile.nutritionTrackingEnabled = newValue
                    vm.refreshNutritionInsights()
                    vm.refreshCoachingInsights()
                    vm.refreshDailyState()
                }
            )) {
                HStack(spacing: 10) {
                    Image(systemName: on ? "checkmark.seal.fill" : "leaf.fill")
                        .font(.subheadline)
                        .foregroundStyle(on ? STRQPalette.success : STRQPalette.info)
                        .frame(width: 30, height: 30)
                        .background((on ? STRQPalette.success : STRQPalette.info).opacity(0.12), in: .rect(cornerRadius: 8))
                    VStack(alignment: .leading, spacing: 2) {
                        Text(L10n.tr("Physique & Nutrition Coaching"))
                            .font(.subheadline.weight(.semibold))
                        Text(on
                            ? L10n.tr("STRQ uses weigh-ins and nutrition logs to read body-composition progress.")
                            : L10n.tr("Optional. Training and recovery coaching stay fully active without food or bodyweight logs."))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
            .tint(STRQPalette.success)
            .padding(14)
            .background(Color(.secondarySystemGroupedBackground), in: .rect(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(STRQBrand.cardBorder, lineWidth: 1)
            )
        }
    }

    // MARK: - Controls

    private var coachingStyleRow: some View {
        let prefs = vm.profile.coachingPreferences
        return NavigationLink {
            CoachingPreferencesView(vm: vm)
        } label: {
            HStack(alignment: .center, spacing: 12) {
                Image(systemName: "person.bust.fill")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.white)
                    .frame(width: 36, height: 36)
                    .background(STRQBrand.steelGradient, in: .rect(cornerRadius: 10))

                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 6) {
                        Text(L10n.tr("Coaching Style"))
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.primary)
                        Text(L10n.tr("PERSONAL"))
                            .font(.system(size: 9, weight: .black))
                            .tracking(0.8)
                            .foregroundStyle(STRQBrand.steel)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(STRQBrand.steel.opacity(0.12), in: Capsule())
                    }
                    HStack(spacing: 5) {
                        styleChip(icon: prefs.tone.symbolName, label: prefs.tone.displayName)
                        styleChip(icon: prefs.emphasis.symbolName, label: prefs.emphasis.displayName)
                        styleChip(icon: prefs.density.symbolName, label: prefs.density.displayName)
                    }
                }
                Spacer(minLength: 0)
                Image(systemName: "chevron.right")
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(.tertiary)
            }
            .padding(14)
            .background(Color(.secondarySystemGroupedBackground), in: .rect(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .strokeBorder(STRQBrand.cardBorder, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    private func styleChip(icon: String, label: String) -> some View {
        HStack(spacing: 3) {
            Image(systemName: icon)
                .font(.system(size: 8, weight: .bold))
            Text(label)
                .font(.system(size: 9, weight: .bold))
        }
        .foregroundStyle(STRQBrand.steel)
        .padding(.horizontal, 6)
        .padding(.vertical, 3)
        .background(STRQBrand.steel.opacity(0.10), in: Capsule())
    }

    private var controlsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            STRQSectionHeader(L10n.tr("Notifications & Tools"))
                .textCase(.uppercase)

            VStack(spacing: 0) {
                NavigationLink {
                    NotificationSettingsView(vm: vm)
                } label: {
                    controlsListRowContent(L10n.tr("Notifications"), icon: .bell, opticalEmphasis: .notifications)
                }
                controlsListButtonRow(L10n.tr("Restore Purchases"), icon: .repeatAction) {
                    guard store.isConfigured else {
                        store.restoreMessage = L10n.tr("Subscriptions are not available in this environment.")
                        showRestoreMessage = true
                        return
                    }
                    Task {
                        await store.restore()
                        showRestoreMessage = true
                    }
                }
                controlsListButtonRow(
                    L10n.tr("profile.regeneratePlan", fallback: "Regenerate Plan"),
                    icon: .repeatAction,
                    showsDivider: controlsSectionShowsDesignSystemLab
                ) {
                    Analytics.shared.track(.regenerate_plan_dialog_opened, ["surface": "profile"])
                    showPlanRegenerationDialog = true
                }
                #if DEBUG
                NavigationLink {
                    STRQDesignSystemPreviewView()
                } label: {
                    controlsListSymbolRowContent("Design System Lab", systemIcon: "paintpalette.fill", showsDivider: false)
                }
                #endif
            }
            .buttonStyle(.plain)
            .background(STRQColors.cardSurface, in: .rect(cornerRadius: 12))
            .clipShape(.rect(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(STRQColors.borderMuted, lineWidth: 1)
            )
        }
    }

    private var footerSection: some View {
        VStack(spacing: 10) {
            legalLinks

            Text(appVersionString)
                .font(.caption2)
                .foregroundStyle(.quaternary)
                .frame(maxWidth: .infinity)
                .contentShape(Rectangle())
                .onLongPressGesture(minimumDuration: 1.2) {
                    showMediaDiagnostics = true
                }
        }
        .padding(.top, 2)
    }

    private var legalLinks: some View {
        HStack(spacing: 18) {
            Link(L10n.tr("Privacy"), destination: STRQLinks.privacy)
            Text("·").foregroundStyle(.quaternary)
            Link(L10n.tr("Terms"), destination: STRQLinks.terms)
            Text("·").foregroundStyle(.quaternary)
            Link(L10n.tr("Support"), destination: STRQLinks.support)
        }
        .font(.caption.weight(.medium))
        .foregroundStyle(.secondary)
        .frame(maxWidth: .infinity)
    }

    private var dangerSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            ForgeSectionHeader(title: L10n.tr("Danger Zone"))

            VStack(spacing: 1) {
                controlRow(L10n.tr("Reset All Data"), icon: "trash.fill", color: .red) {
                    showResetAlert = true
                }
            }
            .clipShape(.rect(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(STRQBrand.cardBorder, lineWidth: 1)
            )
        }
    }

    private var profileHeaderSummary: String {
        if vm.isEarlyStage {
            return L10n.tr("Setup locked. STRQ is learning your training rhythm.")
        }
        return L10n.tr("Coaching profile, recovery, and sync in one place.")
    }

    private var appVersionString: String {
        let info = Bundle.main.infoDictionary
        let version = info?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = info?["CFBundleVersion"] as? String ?? "1"
        return "STRQ v\(version) (\(build))"
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

    private var controlsSectionShowsDesignSystemLab: Bool {
        #if DEBUG
        true
        #else
        false
        #endif
    }

    // Controls-only optical balance for the short Notifications label; not a global typography rule.
    private enum ControlsRowOpticalEmphasis {
        case standard
        case notifications

        var titleFont: Font {
            switch self {
            case .standard:
                return STRQTypography.labelLarge
            case .notifications:
                return STRQTypography.labelFont(size: 16, weight: .heavy)
            }
        }
    }

    private func controlsListButtonRow(
        _ label: String,
        icon: STRQIcon,
        showsDivider: Bool = true,
        opticalEmphasis: ControlsRowOpticalEmphasis = .standard,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            controlsListRowContent(label, icon: icon, showsDivider: showsDivider, opticalEmphasis: opticalEmphasis)
        }
    }

    private func controlsListRowContent(
        _ label: String,
        icon: STRQIcon,
        showsDivider: Bool = true,
        opticalEmphasis: ControlsRowOpticalEmphasis = .standard
    ) -> some View {
        controlsListRowContent(label, showsDivider: showsDivider, opticalEmphasis: opticalEmphasis) {
            STRQIconContainer(icon: icon, size: .md, tint: STRQColors.iconSecondary)
        }
    }

    private func controlsListSymbolRowContent(
        _ label: String,
        systemIcon: String,
        showsDivider: Bool = true,
        opticalEmphasis: ControlsRowOpticalEmphasis = .standard
    ) -> some View {
        controlsListRowContent(label, showsDivider: showsDivider, opticalEmphasis: opticalEmphasis) {
            controlsListSystemIcon(systemIcon)
        }
    }

    private func controlsListRowContent<LeadingIcon: View>(
        _ label: String,
        showsDivider: Bool = true,
        opticalEmphasis: ControlsRowOpticalEmphasis = .standard,
        @ViewBuilder leadingIcon: () -> LeadingIcon
    ) -> some View {
        VStack(spacing: 0) {
            HStack(spacing: STRQSpacing.sm) {
                leadingIcon()

                controlsListRowTitle(label, opticalEmphasis: opticalEmphasis)

                Spacer(minLength: STRQSpacing.sm)

                STRQIconView(.chevronRight, size: STRQSpacing.iconSM, tint: STRQColors.mutedText)
            }
            .padding(.vertical, STRQSpacing.sm)
            .padding(.horizontal, STRQSpacing.listItemPadding)

            if showsDivider {
                Rectangle()
                    .fill(STRQColors.divider)
                    .frame(height: 1)
                    .padding(.leading, 68)
            }
        }
        .background(STRQColors.cardSurface)
        .accessibilityLabel(label)
    }

    private func controlsListRowTitle(_ label: String, opticalEmphasis: ControlsRowOpticalEmphasis = .standard) -> some View {
        Text(label)
            .font(opticalEmphasis.titleFont)
            .foregroundStyle(STRQColors.primaryText)
            .lineLimit(1)
            .minimumScaleFactor(0.82)
    }

    private func controlsListSystemIcon(_ systemIcon: String) -> some View {
        Image(systemName: systemIcon)
            .font(.system(size: STRQSpacing.iconSM, weight: .semibold))
            .foregroundStyle(STRQColors.iconSecondary)
            .frame(width: STRQSpacing.iconContainerMD, height: STRQSpacing.iconContainerMD)
            .background(STRQColors.controlSurface, in: .rect(cornerRadius: STRQRadii.iconContainer))
            .overlay(
                RoundedRectangle(cornerRadius: STRQRadii.iconContainer, style: .continuous)
                    .strokeBorder(STRQColors.borderMuted, lineWidth: 1)
            )
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
                .foregroundStyle(label.contains(L10n.tr("Reset")) ? .red : .primary)
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
        case .muscleGain: L10n.tr("Hypertrophy-focused training for lean muscle growth")
        case .strength: L10n.tr("Maximizing strength on key compound lifts")
        case .fatLoss: L10n.tr("Training with metabolic demand for fat reduction")
        case .generalFitness: L10n.tr("Balanced training for overall health")
        case .endurance: L10n.tr("Building cardiovascular and muscular endurance")
        case .flexibility: L10n.tr("Improving range of motion and mobility")
        case .athleticPerformance: L10n.tr("Sport-specific training for peak performance")
        case .rehabilitation: L10n.tr("Safe, progressive training for recovery")
        }
    }
}
