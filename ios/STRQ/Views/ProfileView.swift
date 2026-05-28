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
    #if DEBUG
    @State private var showMediaDiagnostics: Bool = false
    #endif
    @State private var showPlanRegenerationDialog: Bool = false

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                profileFirstViewport
                trainingSetup
                coachInputsSection
                accountDataSection
                controlsSection
                privacySupportSection
                lowerFooterSection
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
        #if DEBUG
            .sheet(isPresented: $showMediaDiagnostics) {
                NavigationStack { MediaDiagnosticsView() }
            }
        #endif
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

    // MARK: - Account & Data

    private var accountDataSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            STRQSectionHeader(L10n.tr("Account & Data"))

            VStack(spacing: 0) {
                proAccountRows
                accountDataDivider
                restorePurchasesRow
                accountDataDivider
                accountCloudRows
            }
            .background(STRQColors.cardSurface, in: .rect(cornerRadius: STRQRadii.md))
            .clipShape(.rect(cornerRadius: STRQRadii.md))
            .overlay(
                RoundedRectangle(cornerRadius: STRQRadii.md, style: .continuous)
                    .strokeBorder(STRQColors.borderMuted, lineWidth: 1)
            )
            .accessibilityIdentifier("strq.profile.account")
        }
        .manageSubscriptionsSheet(isPresented: $showManageSubscription)
        .accessibilityIdentifier("strq.profile.subscription")
    }

    @ViewBuilder
    private var proAccountRows: some View {
        if store.isPro {
            accountDataStatusRow(
                icon: "sparkles",
                title: L10n.tr("STRQ Pro"),
                detail: store.subscriptionStatusText,
                tint: STRQBrand.steel
            ) {
                accountDataStatusPill(store.subscriptionPlanName, tint: STRQBrand.steel)
            }

            accountDataDivider

            Button {
                Analytics.shared.track(.manage_subscription_opened)
                showManageSubscription = true
            } label: {
                accountDataActionRow(
                    icon: "creditcard.fill",
                    title: L10n.tr("Manage Subscription"),
                    tint: STRQColors.iconSecondary
                )
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("strq.profile.manage-subscription")
        } else {
            Button {
                Analytics.shared.track(.paywall_viewed, ["source": "profile"])
                showPaywall = true
            } label: {
                accountDataActionRow(
                    icon: "sparkles",
                    title: L10n.tr("STRQ Pro"),
                    detail: L10n.tr("Free plan. Upgrade when ready."),
                    tint: STRQBrand.steel
                )
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("strq.profile.pro-preview-card")
        }
    }

    private var restorePurchasesRow: some View {
        Button {
            guard store.isConfigured else {
                store.restoreMessage = L10n.tr("Subscriptions are not available in this environment.")
                showRestoreMessage = true
                return
            }
            Task {
                await store.restore()
                showRestoreMessage = true
            }
        } label: {
            accountDataActionRow(
                icon: "arrow.clockwise",
                title: L10n.tr("Restore Purchases"),
                detail: L10n.tr("Check App Store purchases"),
                tint: STRQColors.iconSecondary
            )
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("strq.profile.restore-purchases")
    }

    @ViewBuilder
    private var accountCloudRows: some View {
        if let account = vm.account.account {
            accountDataStatusRow(
                icon: "icloud.fill",
                title: L10n.tr("iCloud Sync"),
                detail: signedInCloudSummary(name: account.displayName),
                tint: STRQBrand.steel
            ) {
                cloudStatusBadge
            }

            accountDataDivider

            Button {
                showCloudRestoreConfirm = true
            } label: {
                accountDataActionRow(
                    icon: "arrow.clockwise.icloud.fill",
                    title: L10n.tr("Restore This Device"),
                    detail: L10n.tr("Replace local data with your latest iCloud snapshot"),
                    tint: STRQColors.iconSecondary
                )
            }
            .buttonStyle(.plain)

            accountDataDivider

            Button {
                showSignOutAlert = true
            } label: {
                accountDataActionRow(
                    icon: "rectangle.portrait.and.arrow.right",
                    title: L10n.tr("Sign Out"),
                    tint: .red,
                    titleColor: .red
                )
            }
            .buttonStyle(.plain)
        } else {
            accountDataStatusRow(
                icon: "icloud",
                title: L10n.tr("iCloud Sync"),
                detail: L10n.tr("Sign in with Apple to keep your training backed up in iCloud and ready to restore on another device."),
                tint: STRQColors.iconSecondary
            ) {
                accountDataStatusPill(L10n.tr("OFF"), tint: STRQColors.mutedText)
            }

            accountDataDivider

            VStack(alignment: .leading, spacing: STRQSpacing.sm) {
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
                    .font(STRQTypography.captionRegular)
                    .foregroundStyle(STRQColors.mutedText)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, STRQSpacing.xs)
                    .padding(.vertical, STRQSpacing.xs)
                    .background(STRQColors.insetSurface.opacity(0.52), in: .rect(cornerRadius: STRQRadii.sm))
                    .overlay(
                        RoundedRectangle(cornerRadius: STRQRadii.sm, style: .continuous)
                            .strokeBorder(STRQColors.borderMuted.opacity(0.58), lineWidth: 1)
                    )
            }
            .padding(STRQSpacing.cardPaddingCompact)
        }
    }

    private func accountDataStatusRow<Accessory: View>(
        icon: String,
        title: String,
        detail: String,
        tint: Color,
        @ViewBuilder accessory: () -> Accessory
    ) -> some View {
        HStack(spacing: STRQSpacing.sm) {
            accountDataIcon(icon, tint: tint)

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(STRQTypography.labelLarge)
                    .foregroundStyle(STRQColors.primaryText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.78)

                Text(detail)
                    .font(STRQTypography.caption)
                    .foregroundStyle(STRQColors.secondaryText)
                    .lineLimit(2)
                    .minimumScaleFactor(0.78)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: STRQSpacing.sm)

            accessory()
        }
        .padding(.horizontal, STRQSpacing.listItemPadding)
        .padding(.vertical, STRQSpacing.sm)
        .accessibilityElement(children: .combine)
    }

    private func accountDataActionRow(
        icon: String,
        title: String,
        detail: String? = nil,
        tint: Color,
        titleColor: Color = STRQColors.primaryText
    ) -> some View {
        HStack(spacing: STRQSpacing.sm) {
            accountDataIcon(icon, tint: tint)

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(STRQTypography.labelLarge)
                    .foregroundStyle(titleColor)
                    .lineLimit(1)
                    .minimumScaleFactor(0.78)

                if let detail {
                    Text(detail)
                        .font(STRQTypography.caption)
                        .foregroundStyle(STRQColors.secondaryText)
                        .lineLimit(2)
                        .minimumScaleFactor(0.78)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            Spacer(minLength: STRQSpacing.sm)

            STRQIconView(.chevronRight, size: STRQSpacing.iconXS, tint: tint.opacity(0.72))
        }
        .padding(.horizontal, STRQSpacing.listItemPadding)
        .padding(.vertical, STRQSpacing.sm)
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
    }

    private func accountDataIcon(_ systemIcon: String, tint: Color) -> some View {
        Image(systemName: systemIcon)
            .font(.system(size: 15, weight: .semibold))
            .symbolRenderingMode(.hierarchical)
            .foregroundStyle(tint)
            .frame(width: STRQSpacing.iconContainerMD, height: STRQSpacing.iconContainerMD)
            .background(STRQColors.controlSurface, in: .rect(cornerRadius: STRQRadii.iconContainer))
            .overlay(
                RoundedRectangle(cornerRadius: STRQRadii.iconContainer, style: .continuous)
                    .strokeBorder(STRQColors.borderMuted, lineWidth: 1)
            )
    }

    private func accountDataStatusPill(_ label: String, tint: Color) -> some View {
        Text(label)
            .font(.system(size: 10, weight: .bold))
            .foregroundStyle(tint)
            .lineLimit(1)
            .minimumScaleFactor(0.7)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(tint.opacity(0.10), in: Capsule())
            .overlay(
                Capsule()
                    .strokeBorder(tint.opacity(0.24), lineWidth: 1)
            )
    }

    private var accountDataDivider: some View {
        Rectangle()
            .fill(STRQColors.divider)
            .frame(height: 1)
            .padding(.leading, 68)
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
            guard vm.cloudSync.isAvailable else { return (L10n.tr("OFF"), .gray) }
            switch vm.cloudSync.status {
            case .syncing: return (L10n.tr("SYNC"), STRQBrand.steel)
            case .failed: return (L10n.tr("CHECK"), STRQPalette.warning)
            case .unavailable: return (L10n.tr("OFF"), .gray)
            case .success, .idle: return (L10n.tr("ON"), STRQPalette.success)
            }
        }()
        return Text(label)
            .font(.system(size: 10, weight: .bold))
            .foregroundStyle(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(color.opacity(0.8), in: Capsule())
    }

    // MARK: - Header

    private var profileFirstViewport: some View {
        VStack(alignment: .leading, spacing: 10) {
            athletePassportHero
            profileOverviewRows
        }
        .padding(.top, 4)
        .accessibilityIdentifier("strq.profile.v4.first-viewport")
    }

    private var athletePassportHero: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top, spacing: 12) {
                profileInitialsBadge

                VStack(alignment: .leading, spacing: 5) {
                    Text(profileDisplayName)
                        .font(STRQTypography.caption)
                        .foregroundStyle(STRQColors.secondaryText)
                        .lineLimit(1)
                        .minimumScaleFactor(0.76)

                    Text(vm.profile.goal.displayName)
                        .font(.system(size: 31, weight: .black, design: .rounded))
                        .foregroundStyle(STRQColors.primaryText)
                        .lineLimit(1)
                        .minimumScaleFactor(0.70)

                    Text(profilePassportSecondaryRead)
                        .font(STRQTypography.labelLarge)
                        .foregroundStyle(STRQColors.primaryText)
                        .lineLimit(1)
                        .minimumScaleFactor(0.70)
                }

                Spacer(minLength: 0)
            }

            if let supportingRead = profilePassportSupportingRead {
                profileInlineFactRow(supportingRead)
            }
        }
        .padding(16)
        .background(
            LinearGradient(
                colors: [
                    Color(red: 0.118, green: 0.116, blue: 0.102),
                    Color(red: 0.070, green: 0.073, blue: 0.071)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            in: .rect(cornerRadius: 22, style: .continuous)
        )
        .overlay(alignment: .topLeading) {
            Capsule()
                .fill(STRQBrand.steel.opacity(0.62))
                .frame(width: 86, height: 2)
                .padding(.leading, 27)
        }
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .strokeBorder(Color.white.opacity(0.145), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.18), radius: 18, y: 10)
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("strq.profile.v4.passport")
    }

    private var profileInitialsBadge: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [
                            STRQColors.white.opacity(0.16),
                            STRQColors.white.opacity(0.05)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            Circle()
                .strokeBorder(Color.white.opacity(0.145), lineWidth: 1)

            Text(profileInitials)
                .font(.system(size: 15, weight: .black, design: .rounded))
                .foregroundStyle(STRQColors.primaryText)
                .lineLimit(1)
                .minimumScaleFactor(0.72)
        }
        .frame(width: 48, height: 48)
        .accessibilityHidden(true)
    }

    private func profileInlineFactRow(_ text: String) -> some View {
        HStack(spacing: 8) {
            Circle()
                .fill(STRQBrand.steel.opacity(0.74))
                .frame(width: 6, height: 6)

            Text(text)
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundStyle(STRQColors.primaryText)
                .lineLimit(1)
                .minimumScaleFactor(0.70)
        }
        .padding(.horizontal, 10)
        .frame(height: 30)
        .background(STRQColors.white.opacity(0.060), in: Capsule())
        .overlay(Capsule().strokeBorder(STRQColors.white.opacity(0.10), lineWidth: 1))
    }

    private var profileOverviewRows: some View {
        VStack(spacing: 0) {
            ForEach(Array(profileOverviewRowData.enumerated()), id: \.element.id) { index, row in
                profileOverviewRow(row)

                if index < profileOverviewRowData.count - 1 {
                    Rectangle()
                        .fill(STRQColors.white.opacity(0.075))
                        .frame(height: 1 / UIScreen.main.scale)
                        .padding(.leading, 54)
                }
            }
        }
        .padding(.vertical, 5)
        .background(STRQColors.cardSurface, in: .rect(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .strokeBorder(STRQColors.borderMuted, lineWidth: 1)
        )
        .accessibilityIdentifier("strq.profile.v4.rows")
    }

    private func profileOverviewRow(_ row: ProfileOverviewRowData) -> some View {
        HStack(spacing: 12) {
            Image(systemName: row.icon)
                .font(.system(size: 15, weight: .bold))
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(STRQColors.primaryText)
                .frame(width: 34, height: 34)
                .background(STRQColors.white.opacity(0.07), in: Circle())

            VStack(alignment: .leading, spacing: 3) {
                Text(row.title)
                    .font(STRQTypography.labelLarge)
                    .foregroundStyle(STRQColors.primaryText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.74)

                Text(row.detail)
                    .font(STRQTypography.caption)
                    .foregroundStyle(STRQColors.secondaryText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.68)
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 12)
        .frame(minHeight: 58)
        .accessibilityElement(children: .combine)
    }

    private var profileOverviewRowData: [ProfileOverviewRowData] {
        [
            ProfileOverviewRowData(
                id: "training",
                icon: "figure.strengthtraining.traditional",
                title: L10n.tr("profile.v4.trainingSetup", fallback: "Training Setup"),
                detail: trainingSetupOverviewDetail
            ),
            ProfileOverviewRowData(
                id: "coach",
                icon: "slider.horizontal.3",
                title: L10n.tr("profile.v4.coachInputs", fallback: "Coach & Inputs"),
                detail: coachInputsOverviewDetail
            ),
            ProfileOverviewRowData(
                id: "account",
                icon: "person.crop.circle",
                title: L10n.tr("profile.v4.accountData", fallback: "Account & Data"),
                detail: accountDataOverviewDetail
            )
        ]
    }

    private var profileDisplayName: String {
        let trimmed = vm.profile.name.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? L10n.tr("profile.v4.athleteFallback", fallback: "Athlete") : trimmed
    }

    private var profileInitials: String {
        let trimmed = vm.profile.name.trimmingCharacters(in: .whitespacesAndNewlines)
        let source = trimmed.isEmpty ? L10n.tr("profile.v4.athleteFallback", fallback: "Athlete") : trimmed
        let parts = source.split { character in
            character.isWhitespace || character == "-" || character == "_"
        }
        let initials = parts.prefix(2).compactMap(\.first).map { String($0) }.joined()
        if !initials.isEmpty {
            return initials.uppercased()
        }
        return String(source.prefix(2)).uppercased()
    }

    private var profilePassportSecondaryRead: String {
        [
            vm.profile.trainingLevel.shortName,
            profileDaysPerWeekText,
            vm.profile.trainingLocation.displayName
        ].joined(separator: " · ")
    }

    private var profilePassportSupportingRead: String? {
        var reads: [String] = []
        if let split = profileSplitRead {
            reads.append(split)
        }
        if let focus = profileFocusRead {
            reads.append(focus)
        }
        return reads.isEmpty ? nil : reads.joined(separator: " · ")
    }

    private var trainingSetupOverviewDetail: String {
        var reads = [
            profileDaysPerWeekText,
            vm.profile.trainingLocation.displayName
        ]
        if let split = profileSplitRead {
            reads.append(split)
        }
        return reads.joined(separator: " · ")
    }

    private var coachInputsOverviewDetail: String {
        let coachTone = L10n.format(
            "profile.v4.coachTone",
            fallback: "%@ coach",
            vm.profile.coachingPreferences.tone.displayName
        )
        let nutrition = vm.profile.nutritionTrackingEnabled
            ? L10n.tr("profile.v4.nutritionOn", fallback: "Nutrition on")
            : L10n.tr("profile.v4.nutritionOff", fallback: "Nutrition off")
        return [coachTone, nutrition].joined(separator: " · ")
    }

    private var accountDataOverviewDetail: String {
        let proState = store.isPro
            ? L10n.tr("profile.v4.pro", fallback: "Pro")
            : L10n.tr("profile.v4.free", fallback: "Free")
        let accountState = vm.account.isSignedIn
            ? L10n.tr("profile.v4.signedIn", fallback: "Signed in")
            : L10n.tr("profile.v4.notSignedIn", fallback: "Not signed in")
        return [proState, accountState].joined(separator: " · ")
    }

    private var profileDaysPerWeekText: String {
        if vm.profile.daysPerWeek == 1 {
            return L10n.tr("profile.v4.oneDayPerWeek", fallback: "1 day/week")
        }
        return L10n.format("profile.v4.daysPerWeek", fallback: "%d days/week", vm.profile.daysPerWeek)
    }

    private var profileSplitRead: String? {
        if let planSplit = vm.currentPlan?.splitType.trimmingCharacters(in: .whitespacesAndNewlines),
           !planSplit.isEmpty {
            let displayName = normalizeSplitDisplayName(SplitDisplayName.localizedDisplayName(for: planSplit))
            if isReadableSplit(displayName) {
                return displayName
            }
        }

        guard vm.profile.splitPreference != .automatic else {
            return nil
        }
        let displayName = normalizeSplitDisplayName(vm.profile.splitPreference.displayName)
        return isReadableSplit(displayName) ? displayName : nil
    }

    private var trainingSetupSplitValue: String {
        let displayName = normalizeSplitDisplayName(vm.profile.splitPreference.displayName)
        if vm.profile.splitPreference == .automatic || isAutomaticSplitDisplayName(displayName) {
            return L10n.tr("profile.trainingSetup.autoSplit", fallback: "Auto split")
        }
        return displayName
    }

    private var profileFocusRead: String? {
        let names = vm.profile.focusMuscles
            .prefix(3)
            .map(\.localizedDisplayName)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        return names.isEmpty ? nil : names.joined(separator: ", ")
    }

    private func normalizeSplitDisplayName(_ value: String) -> String {
        value
            .replacingOccurrences(of: "/", with: " / ")
            .split(separator: " ")
            .joined(separator: " ")
    }

    private func isReadableSplit(_ value: String) -> Bool {
        let normalized = value.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        return !normalized.isEmpty
            && normalized != "automatic"
            && !normalized.contains("let ai decide")
    }

    private func isAutomaticSplitDisplayName(_ value: String) -> Bool {
        let normalized = value.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        return normalized == "automatic"
            || normalized.contains("let ai decide")
            || normalized.contains("ai decide")
    }

    private struct ProfileOverviewRowData {
        let id: String
        let icon: String
        let title: String
        let detail: String
    }

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
        .accessibilityIdentifier("strq.profile.header")
    }

    // MARK: - Coach & Inputs

    private var coachInputsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            STRQSectionHeader(L10n.tr("profile.coachInputs.section", fallback: "Coach & Inputs"))

            VStack(alignment: .leading, spacing: 0) {
                coachInputsSummaryBlock

                coachInputsDivider

                coachInputSignals

                coachInputsDivider

                NavigationLink {
                    CoachingPreferencesView(vm: vm)
                } label: {
                    coachInputRouteRow(
                        systemIcon: "person.bust.fill",
                        title: L10n.tr("Coaching Style"),
                        value: coachStyleValue,
                        detail: coachStyleDetail,
                        tint: STRQColors.iconSecondary
                    )
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("strq.profile.coaching-style")

                coachInputsDivider

                Button {
                    showSleepLog = true
                } label: {
                    coachInputRouteRow(
                        systemIcon: "moon.zzz.fill",
                        title: L10n.tr("Sleep Log"),
                        value: profileSleepStateLabel,
                        detail: L10n.tr("profile.coachInputs.sleepLogDetail", fallback: "Manual sleep input when you want it."),
                        tint: ForgeTheme.sleepColor(for: vm.averageSleepHours)
                    )
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("strq.profile.sleep-log")

                coachInputsDivider

                VStack(spacing: 0) {
                    bodyProfileInputRow

                    coachInputsDivider

                    nutritionTrackingInputRow

                    if vm.profile.nutritionTrackingEnabled {
                        coachInputsDivider

                        Button {
                            showNutritionSettings = true
                        } label: {
                            coachInputRouteRow(
                                systemIcon: "slider.horizontal.3",
                                title: L10n.tr("Edit Targets"),
                                value: nutritionTargetsSummary,
                                detail: L10n.tr("profile.coachInputs.targetsDetail", fallback: "Calories and protein live here."),
                                tint: STRQBrand.steel
                            )
                        }
                        .buttonStyle(.plain)
                        .accessibilityIdentifier("strq.profile.nutrition-settings")
                    }
                }
                .accessibilityIdentifier("strq.profile.body-nutrition")
            }
            .background(STRQColors.cardSurface, in: .rect(cornerRadius: 18, style: .continuous))
            .clipShape(.rect(cornerRadius: 18, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .strokeBorder(STRQColors.borderMuted, lineWidth: 1)
            )
        }
        .accessibilityIdentifier("strq.profile.coach-inputs")
    }

    private var coachInputsSummaryBlock: some View {
        HStack(alignment: .center, spacing: STRQSpacing.sm) {
            coachInputIcon("slider.horizontal.3", tint: STRQColors.primaryText)

            VStack(alignment: .leading, spacing: STRQSpacing.px50) {
                Text(L10n.tr("profile.coachInputs.contextTitle", fallback: "Context for the next lift"))
                    .font(STRQTypography.labelLarge)
                    .foregroundStyle(STRQColors.primaryText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.76)

                Text(coachInputsSummaryLine)
                    .font(STRQTypography.captionRegular)
                    .foregroundStyle(STRQColors.secondaryText)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, STRQSpacing.cardPaddingCompact)
        .padding(.vertical, STRQSpacing.sm)
    }

    private var coachInputSignals: some View {
        HStack(spacing: STRQSpacing.xs) {
            coachInputSignalChip(
                icon: "heart.fill",
                title: L10n.tr("Recovery"),
                value: profileRecoveryStateLabel,
                color: ForgeTheme.recoveryColor(for: vm.effectiveRecoveryScore)
            )
            coachInputSignalChip(
                icon: "moon.zzz.fill",
                title: L10n.tr("Sleep"),
                value: profileSleepStateLabel,
                color: ForgeTheme.sleepColor(for: vm.averageSleepHours)
            )
            coachInputSignalChip(
                icon: "fork.knife",
                title: L10n.tr("Nutrition"),
                value: profileNutritionStateLabel,
                color: profileNutritionStateColor
            )
        }
        .padding(.horizontal, STRQSpacing.cardPaddingCompact)
        .padding(.vertical, STRQSpacing.sm)
    }

    private func coachInputSignalChip(icon: String, title: String, value: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: STRQSpacing.xs) {
            HStack(spacing: STRQSpacing.px150) {
                Image(systemName: icon)
                    .font(.system(size: 11, weight: .semibold))
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(color)

                Text(title)
                    .font(STRQTypography.micro)
                    .foregroundStyle(STRQColors.mutedText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)
            }

            Text(value)
                .font(STRQTypography.labelMedium)
                .foregroundStyle(STRQColors.primaryText)
                .lineLimit(1)
                .minimumScaleFactor(0.72)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(minHeight: 58)
        .padding(.horizontal, STRQSpacing.xs)
        .padding(.vertical, STRQSpacing.xs)
        .background(STRQColors.insetSurface.opacity(0.52), in: .rect(cornerRadius: STRQRadii.md))
        .overlay(
            RoundedRectangle(cornerRadius: STRQRadii.md, style: .continuous)
                .strokeBorder(STRQColors.borderMuted.opacity(0.58), lineWidth: 1)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel([title, value].joined(separator: ", "))
    }

    private var bodyProfileInputRow: some View {
        coachInputRowContent(
            systemIcon: "scalemass.fill",
            title: L10n.tr("profile.coachInputs.bodyProfile", fallback: "Body Profile"),
            value: bodyProfileSummary,
            detail: L10n.tr("profile.coachInputs.bodyProfileDetail", fallback: "Height, weight, and age for plan context."),
            tint: STRQColors.iconSecondary,
            showsChevron: false
        )
    }

    private var nutritionTrackingInputRow: some View {
        let on = vm.profile.nutritionTrackingEnabled
        let tint = on ? STRQPalette.success : STRQColors.iconSecondary
        return Toggle(isOn: Binding(
            get: { vm.profile.nutritionTrackingEnabled },
            set: { newValue in
                vm.profile.nutritionTrackingEnabled = newValue
                vm.refreshNutritionInsights()
                vm.refreshCoachingInsights()
                vm.refreshDailyState()
            }
        )) {
            HStack(alignment: .center, spacing: STRQSpacing.sm) {
                coachInputIcon(on ? "checkmark.seal.fill" : "fork.knife", tint: tint)

                VStack(alignment: .leading, spacing: STRQSpacing.xs) {
                    HStack(spacing: STRQSpacing.xs) {
                        Text(L10n.tr("profile.coachInputs.nutritionCoaching", fallback: "Nutrition Coaching"))
                            .font(STRQTypography.labelMedium)
                            .foregroundStyle(STRQColors.primaryText)
                            .lineLimit(1)
                            .minimumScaleFactor(0.78)

                        coachInputStatePill(on ? L10n.tr("On") : L10n.tr("Off"), color: tint)
                    }

                    Text(on
                        ? L10n.tr("profile.coachInputs.nutritionOnDetail", fallback: "Targets are available. Food logs stay optional.")
                        : L10n.tr("profile.coachInputs.nutritionOffDetail", fallback: "Optional. Training coaching stays active."))
                        .font(STRQTypography.paragraphSmall)
                        .foregroundStyle(STRQColors.secondaryText)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .tint(on ? STRQPalette.success : STRQColors.secondaryAccent)
        .padding(.horizontal, STRQSpacing.cardPaddingCompact)
        .padding(.vertical, STRQSpacing.sm)
        .background(STRQColors.cardSurface)
    }

    private func coachInputRouteRow(
        systemIcon: String,
        title: String,
        value: String,
        detail: String,
        tint: Color
    ) -> some View {
        coachInputRowContent(
            systemIcon: systemIcon,
            title: title,
            value: value,
            detail: detail,
            tint: tint,
            showsChevron: true
        )
    }

    private func coachInputRowContent(
        systemIcon: String,
        title: String,
        value: String,
        detail: String,
        tint: Color,
        showsChevron: Bool
    ) -> some View {
        HStack(alignment: .center, spacing: STRQSpacing.sm) {
            coachInputIcon(systemIcon, tint: tint)

            VStack(alignment: .leading, spacing: STRQSpacing.xs) {
                Text(title)
                    .font(STRQTypography.labelMedium)
                    .foregroundStyle(STRQColors.primaryText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.78)

                Text(detail)
                    .font(STRQTypography.paragraphSmall)
                    .foregroundStyle(STRQColors.secondaryText)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: STRQSpacing.xs)

            Text(value)
                .font(STRQTypography.labelSmall)
                .foregroundStyle(STRQColors.secondaryText)
                .lineLimit(1)
                .minimumScaleFactor(0.70)
                .multilineTextAlignment(.trailing)

            if showsChevron {
                STRQIconView(.chevronRight, size: STRQSpacing.iconXS, tint: STRQColors.iconMuted)
            }
        }
        .padding(.horizontal, STRQSpacing.cardPaddingCompact)
        .padding(.vertical, STRQSpacing.sm)
        .background(STRQColors.cardSurface)
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
        .accessibilityLabel([title, value, detail].joined(separator: ", "))
    }

    private func coachInputIcon(_ systemIcon: String, tint: Color) -> some View {
        Image(systemName: systemIcon)
            .font(.system(size: 15, weight: .semibold))
            .symbolRenderingMode(.hierarchical)
            .foregroundStyle(tint)
            .frame(width: STRQSpacing.iconContainerMD, height: STRQSpacing.iconContainerMD)
            .background(STRQColors.controlSurface, in: .rect(cornerRadius: STRQRadii.iconContainer))
            .overlay(
                RoundedRectangle(cornerRadius: STRQRadii.iconContainer, style: .continuous)
                    .strokeBorder(STRQColors.borderMuted, lineWidth: 1)
            )
    }

    private func coachInputStatePill(_ value: String, color: Color) -> some View {
        Text(value)
            .font(STRQTypography.labelXS)
            .tracking(STRQTypography.labelXSTracking)
            .foregroundStyle(color)
            .lineLimit(1)
            .minimumScaleFactor(0.78)
            .padding(.horizontal, STRQSpacing.px150)
            .padding(.vertical, STRQSpacing.px50)
            .background(color.opacity(0.10), in: Capsule())
            .overlay(
                Capsule()
                    .strokeBorder(color.opacity(0.22), lineWidth: 1)
            )
    }

    private var coachInputsDivider: some View {
        Rectangle()
            .fill(STRQColors.divider)
            .frame(height: 1)
            .padding(.leading, 68)
    }

    // MARK: - Training Setup

    private var trainingSetup: some View {
        VStack(alignment: .leading, spacing: 10) {
            STRQSectionHeader(L10n.tr("Training Setup"))

            VStack(spacing: 0) {
                trainingSetupInfoRow(L10n.tr("Days / Week"), value: "\(vm.profile.daysPerWeek)")
                trainingSetupInfoRow(L10n.tr("Workout Length"), value: L10n.format("%d min", vm.profile.minutesPerSession))
                trainingSetupInfoRow(L10n.tr("profile.trainingSetup.split", fallback: "Split"), value: trainingSetupSplitValue)
                trainingSetupInfoRow(L10n.tr("Location"), value: vm.profile.trainingLocation.displayName, showsDivider: false)
            }
            .background(STRQColors.cardSurface, in: .rect(cornerRadius: STRQRadii.md))
            .clipShape(.rect(cornerRadius: STRQRadii.md))
            .overlay(
                RoundedRectangle(cornerRadius: STRQRadii.md, style: .continuous)
                    .strokeBorder(STRQColors.borderMuted, lineWidth: 1)
            )

            if !vm.profile.focusMuscles.isEmpty {
                ScrollView(.horizontal) {
                    HStack(spacing: 6) {
                        Text(L10n.tr("Focus:"))
                            .font(.caption.weight(.bold))
                            .foregroundStyle(.tertiary)
                        ForEach(vm.profile.focusMuscles) { muscle in
                            ForgeChip(text: muscle.localizedDisplayName)
                        }
                    }
                }
                .contentMargins(.horizontal, 0)
                .scrollIndicators(.hidden)
            }
        }
        .accessibilityIdentifier("strq.profile.training-setup")
    }

    // MARK: - Controls

    private var controlsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            STRQSectionHeader(L10n.tr("Notifications & Tools"))

            VStack(spacing: 0) {
                NavigationLink {
                    NotificationSettingsView(vm: vm)
                } label: {
                    controlsListRowContent(
                        L10n.tr("Notifications"),
                        detail: L10n.tr("profile.tools.notificationsDetail", fallback: "Training reminders and check-ins."),
                        icon: .bell,
                        opticalEmphasis: .notifications
                    )
                }
                .accessibilityIdentifier("strq.profile.notifications")
                controlsListButtonRow(
                    L10n.tr("profile.rebuildTrainingPlan", fallback: "Rebuild Training Plan"),
                    detail: L10n.tr("profile.tools.rebuildTrainingPlanDetail", fallback: "Use when your schedule or setup changes."),
                    icon: .repeatAction,
                    showsDivider: controlsSectionShowsDesignSystemLab
                ) {
                    Analytics.shared.track(.regenerate_plan_dialog_opened, ["surface": "profile"])
                    showPlanRegenerationDialog = true
                }
                .accessibilityIdentifier("strq.profile.regenerate-plan")
                #if DEBUG
                NavigationLink {
                    ProgressV5ProductionCandidateView(vm: vm)
                        .navigationTitle(L10n.tr("Training Map"))
                        .navigationBarTitleDisplayMode(.inline)
                } label: {
                    controlsListSymbolRowContent(
                        L10n.tr("profile.internalTrainingMapPreview", fallback: "Internal Preview: Training Map"),
                        systemIcon: "eye.fill",
                        showsDivider: true
                    )
                }
                .accessibilityIdentifier("strq.profile.training-map-preview")
                NavigationLink {
                    STRQDesignSystemPreviewView()
                } label: {
                    controlsListSymbolRowContent(L10n.tr("profile.designSystemLab", fallback: "Design System Lab"), systemIcon: "paintpalette.fill", showsDivider: false)
                }
                .accessibilityIdentifier("strq.profile.design-system-lab")
                #endif
            }
            .buttonStyle(.plain)
            .background(STRQColors.cardSurface, in: .rect(cornerRadius: STRQRadii.md))
            .clipShape(.rect(cornerRadius: STRQRadii.md))
            .overlay(
                RoundedRectangle(cornerRadius: STRQRadii.md, style: .continuous)
                    .strokeBorder(STRQColors.borderMuted, lineWidth: 1)
            )
        }
        .accessibilityIdentifier("strq.profile.controls")
    }

    private var privacySupportSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            STRQSectionHeader(L10n.tr("profile.privacySupport", fallback: "Privacy & Support"))

            VStack(spacing: 0) {
                privacySupportLinkRow(
                    systemIcon: "lock.shield.fill",
                    title: L10n.tr("Privacy Policy"),
                    detail: L10n.tr("profile.privacySupport.privacyDetail", fallback: "How STRQ handles your data."),
                    value: L10n.tr("Read"),
                    destination: STRQLinks.privacy
                )

                privacySupportLinkRow(
                    systemIcon: "doc.text.fill",
                    title: L10n.tr("Terms"),
                    detail: L10n.tr("profile.privacySupport.termsDetail", fallback: "Usage terms and product rules."),
                    value: L10n.tr("Read"),
                    destination: STRQLinks.terms
                )

                privacySupportLinkRow(
                    systemIcon: "envelope.fill",
                    title: L10n.tr("profile.footer.support", fallback: "Support"),
                    detail: L10n.tr("profile.privacySupport.supportDetail", fallback: "Get help with STRQ."),
                    value: L10n.tr("Contact"),
                    destination: STRQLinks.support,
                    showsDivider: false
                )
            }
            .buttonStyle(.plain)
            .background(STRQColors.cardSurface, in: .rect(cornerRadius: STRQRadii.md))
            .clipShape(.rect(cornerRadius: STRQRadii.md))
            .overlay(
                RoundedRectangle(cornerRadius: STRQRadii.md, style: .continuous)
                    .strokeBorder(STRQColors.borderMuted, lineWidth: 1)
            )
        }
        .accessibilityIdentifier("strq.profile.privacy-support")
    }

    private var lowerFooterSection: some View {
        VStack(spacing: 10) {
            advancedDataSection
            appVersionFooter
        }
    }

    private var appVersionFooter: some View {
        #if DEBUG
        return Text(appVersionString)
            .font(.caption2)
            .foregroundStyle(.quaternary)
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
            .onLongPressGesture(minimumDuration: 1.2) {
                showMediaDiagnostics = true
            }
        #else
        return Text(appVersionString)
            .font(.caption2)
            .foregroundStyle(.quaternary)
            .frame(maxWidth: .infinity)
        #endif
    }

    private var advancedDataSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            STRQSectionHeader(L10n.tr("profile.advancedData", fallback: "Advanced Data"))

            VStack(spacing: 0) {
                Button {
                    showResetAlert = true
                } label: {
                    advancedDataResetRow
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("strq.profile.reset-all-data")
            }
            .buttonStyle(.plain)
            .background(STRQColors.cardSurface, in: .rect(cornerRadius: STRQRadii.md))
            .clipShape(.rect(cornerRadius: STRQRadii.md))
            .overlay(
                RoundedRectangle(cornerRadius: STRQRadii.md, style: .continuous)
                    .strokeBorder(STRQColors.borderMuted, lineWidth: 1)
            )
        }
        .accessibilityIdentifier("strq.profile.advanced-data")
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

    private func privacySupportLinkRow(
        systemIcon: String,
        title: String,
        detail: String,
        value: String,
        destination: URL,
        showsDivider: Bool = true
    ) -> some View {
        Link(destination: destination) {
            privacySupportRowContent(
                systemIcon: systemIcon,
                title: title,
                detail: detail,
                value: value,
                showsDivider: showsDivider
            )
        }
        .accessibilityLabel([title, value, detail].joined(separator: ", "))
    }

    private func privacySupportRowContent(
        systemIcon: String,
        title: String,
        detail: String,
        value: String,
        showsDivider: Bool
    ) -> some View {
        VStack(spacing: 0) {
            HStack(alignment: .center, spacing: STRQSpacing.sm) {
                privacySupportIcon(systemIcon)

                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(STRQTypography.labelLarge)
                        .foregroundStyle(STRQColors.primaryText)
                        .lineLimit(1)
                        .minimumScaleFactor(0.78)

                    Text(detail)
                        .font(STRQTypography.caption)
                        .foregroundStyle(STRQColors.secondaryText)
                        .lineLimit(2)
                        .minimumScaleFactor(0.78)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: STRQSpacing.sm)

                Text(value)
                    .font(STRQTypography.labelSmall)
                    .foregroundStyle(STRQColors.secondaryText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.74)

                STRQIconView(.chevronRight, size: STRQSpacing.iconXS, tint: STRQColors.iconMuted)
            }
            .padding(.horizontal, STRQSpacing.listItemPadding)
            .padding(.vertical, STRQSpacing.sm)
            .contentShape(Rectangle())

            if showsDivider {
                Rectangle()
                    .fill(STRQColors.divider)
                    .frame(height: 1)
                    .padding(.leading, 68)
            }
        }
        .background(STRQColors.cardSurface)
    }

    private func privacySupportIcon(_ systemIcon: String) -> some View {
        Image(systemName: systemIcon)
            .font(.system(size: 15, weight: .semibold))
            .symbolRenderingMode(.hierarchical)
            .foregroundStyle(STRQColors.iconSecondary)
            .frame(width: STRQSpacing.iconContainerMD, height: STRQSpacing.iconContainerMD)
            .background(STRQColors.controlSurface, in: .rect(cornerRadius: STRQRadii.iconContainer))
            .overlay(
                RoundedRectangle(cornerRadius: STRQRadii.iconContainer, style: .continuous)
                    .strokeBorder(STRQColors.borderMuted, lineWidth: 1)
            )
    }

    private var advancedDataResetRow: some View {
        let tint = STRQPalette.danger
        return HStack(alignment: .center, spacing: STRQSpacing.sm) {
            Image(systemName: "arrow.counterclockwise")
                .font(.system(size: 15, weight: .semibold))
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(tint)
                .frame(width: STRQSpacing.iconContainerMD, height: STRQSpacing.iconContainerMD)
                .background(tint.opacity(0.08), in: .rect(cornerRadius: STRQRadii.iconContainer))
                .overlay(
                    RoundedRectangle(cornerRadius: STRQRadii.iconContainer, style: .continuous)
                        .strokeBorder(tint.opacity(0.18), lineWidth: 1)
                )

            VStack(alignment: .leading, spacing: 3) {
                Text(L10n.tr("profile.advancedData.resetData", fallback: "Reset data"))
                    .font(STRQTypography.labelLarge)
                    .foregroundStyle(STRQColors.primaryText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.78)

                Text(L10n.tr("profile.advancedData.resetDetail", fallback: "Clears data and restarts onboarding."))
                    .font(STRQTypography.caption)
                    .foregroundStyle(STRQColors.secondaryText)
                    .lineLimit(2)
                    .minimumScaleFactor(0.78)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: STRQSpacing.sm)

            advancedDataProtectedPill

            STRQIconView(.chevronRight, size: STRQSpacing.iconXS, tint: tint.opacity(0.58))
        }
        .padding(.horizontal, STRQSpacing.listItemPadding)
        .padding(.vertical, STRQSpacing.sm)
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
        .accessibilityLabel(L10n.tr("profile.advancedData.resetData", fallback: "Reset data"))
    }

    private var advancedDataProtectedPill: some View {
        Text(L10n.tr("profile.advancedData.protected", fallback: "Protected"))
            .font(.system(size: 10, weight: .bold))
            .foregroundStyle(STRQPalette.danger)
            .lineLimit(1)
            .minimumScaleFactor(0.74)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(STRQPalette.danger.opacity(0.10), in: Capsule())
            .overlay(
                Capsule()
                    .strokeBorder(STRQPalette.danger.opacity(0.22), lineWidth: 1)
            )
    }

    // MARK: - Components

    private func trainingSetupInfoRow(_ title: String, value: String, showsDivider: Bool = true) -> some View {
        VStack(spacing: 0) {
            HStack(alignment: .firstTextBaseline, spacing: STRQSpacing.sm) {
                Text(title)
                    .font(STRQTypography.paragraphSmall)
                    .foregroundStyle(STRQColors.secondaryText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.82)

                Spacer(minLength: STRQSpacing.sm)

                Text(value)
                    .font(STRQTypography.labelMedium)
                    .foregroundStyle(STRQColors.primaryText)
                    .multilineTextAlignment(.trailing)
                    .lineLimit(1)
                    .minimumScaleFactor(0.78)
            }
            .padding(.horizontal, STRQSpacing.listItemPadding)
            .padding(.vertical, STRQSpacing.sm)

            if showsDivider {
                Rectangle()
                    .fill(STRQColors.divider)
                    .frame(height: 1)
                    .padding(.horizontal, STRQSpacing.listItemPadding)
            }
        }
        .background(STRQColors.cardSurface)
        .accessibilityLabel([title, value].joined(separator: ", "))
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
        detail: String? = nil,
        icon: STRQIcon,
        showsDivider: Bool = true,
        opticalEmphasis: ControlsRowOpticalEmphasis = .standard,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            controlsListRowContent(label, detail: detail, icon: icon, showsDivider: showsDivider, opticalEmphasis: opticalEmphasis)
        }
    }

    private func controlsListRowContent(
        _ label: String,
        detail: String? = nil,
        icon: STRQIcon,
        showsDivider: Bool = true,
        opticalEmphasis: ControlsRowOpticalEmphasis = .standard
    ) -> some View {
        controlsListRowContent(label, detail: detail, showsDivider: showsDivider, opticalEmphasis: opticalEmphasis) {
            STRQIconContainer(icon: icon, size: .md, tint: STRQColors.iconSecondary)
        }
    }

    private func controlsListSymbolRowContent(
        _ label: String,
        detail: String? = nil,
        systemIcon: String,
        showsDivider: Bool = true,
        opticalEmphasis: ControlsRowOpticalEmphasis = .standard
    ) -> some View {
        controlsListRowContent(label, detail: detail, showsDivider: showsDivider, opticalEmphasis: opticalEmphasis) {
            controlsListSystemIcon(systemIcon)
        }
    }

    private func controlsListRowContent<LeadingIcon: View>(
        _ label: String,
        detail: String? = nil,
        showsDivider: Bool = true,
        opticalEmphasis: ControlsRowOpticalEmphasis = .standard,
        @ViewBuilder leadingIcon: () -> LeadingIcon
    ) -> some View {
        VStack(spacing: 0) {
            HStack(spacing: STRQSpacing.sm) {
                leadingIcon()

                VStack(alignment: .leading, spacing: 3) {
                    controlsListRowTitle(label, opticalEmphasis: opticalEmphasis)

                    if let detail {
                        Text(detail)
                            .font(STRQTypography.caption)
                            .foregroundStyle(STRQColors.secondaryText)
                            .lineLimit(2)
                            .minimumScaleFactor(0.78)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }

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
        }
    }

    private func controlRowContent(_ label: String, icon: String, color: Color) -> some View {
        HStack(spacing: STRQSpacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 15, weight: .semibold))
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(color)
                .frame(width: STRQSpacing.iconContainerMD, height: STRQSpacing.iconContainerMD)
                .background(color.opacity(0.10), in: .rect(cornerRadius: STRQRadii.iconContainer))
                .overlay(
                    RoundedRectangle(cornerRadius: STRQRadii.iconContainer, style: .continuous)
                        .strokeBorder(color.opacity(0.22), lineWidth: 1)
                )
            Text(label)
                .font(STRQTypography.labelMedium)
                .foregroundStyle(color)
                .lineLimit(1)
                .minimumScaleFactor(0.82)
            Spacer(minLength: STRQSpacing.sm)
            STRQIconView(.chevronRight, size: STRQSpacing.iconXS, tint: color.opacity(0.58))
        }
        .padding(.horizontal, STRQSpacing.cardPaddingCompact)
        .padding(.vertical, STRQSpacing.sm)
        .background(STRQColors.cardSurface)
        .accessibilityLabel(label)
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

    private var coachStyleValue: String {
        vm.profile.coachingPreferences.tone.displayName
    }

    private var coachStyleDetail: String {
        let prefs = vm.profile.coachingPreferences
        return [
            prefs.emphasis.displayName,
            prefs.density.displayName
        ].joined(separator: " · ")
    }

    private var coachInputsSummaryLine: String {
        [
            L10n.format("profile.coachInputs.recoverySummary", fallback: "%@ recovery", profileRecoveryStateLabel),
            profileSleepSummaryFragment,
            vm.profile.nutritionTrackingEnabled
                ? L10n.tr("profile.coachInputs.nutritionOn", fallback: "Nutrition on")
                : L10n.tr("profile.coachInputs.nutritionOptional", fallback: "Nutrition optional")
        ].joined(separator: " · ")
    }

    private var profileSleepSummaryFragment: String {
        guard vm.averageSleepHours.isFinite, vm.averageSleepHours > 0 else {
            return L10n.tr("profile.coachInputs.sleepNotSet", fallback: "Sleep not set")
        }
        return L10n.format("profile.coachInputs.sleepSummary", fallback: "%@ sleep", profileSleepStateLabel)
    }

    private var bodyProfileSummary: String {
        L10n.format(
            "profile.coachInputs.bodySummary",
            fallback: "%d cm · %.1f kg · %d",
            Int(vm.profile.heightCm),
            vm.profile.weightKg,
            vm.profile.age
        )
    }

    private var nutritionTargetsSummary: String {
        vm.nutritionTarget.nutritionGoal.displayName
    }

    private var profileRecoveryStateLabel: String {
        switch vm.effectiveRecoveryScore {
        case 85...:
            return L10n.tr("profile.bodyRecovery.state.ready", fallback: "Ready")
        case 70..<85:
            return L10n.tr("profile.bodyRecovery.state.steady", fallback: "Steady")
        case 55..<70:
            return L10n.tr("profile.bodyRecovery.state.light", fallback: "Light")
        case 40..<55:
            return L10n.tr("profile.bodyRecovery.state.low", fallback: "Low")
        default:
            return L10n.tr("profile.bodyRecovery.state.rest", fallback: "Rest")
        }
    }

    private var profileSleepStateLabel: String {
        guard vm.averageSleepHours.isFinite, vm.averageSleepHours > 0 else {
            return L10n.tr("profile.coachInputs.sleep.notSet", fallback: "Not set")
        }

        switch vm.averageSleepHours {
        case 7...:
            return L10n.tr("profile.coachInputs.sleep.solid", fallback: "Solid")
        case 6..<7:
            return L10n.tr("profile.coachInputs.sleep.light", fallback: "Light")
        default:
            return L10n.tr("profile.coachInputs.sleep.short", fallback: "Short")
        }
    }

    private var profileNutritionStateLabel: String {
        guard vm.profile.nutritionTrackingEnabled else {
            return L10n.tr("profile.bodyRecovery.nutrition.off", fallback: "Optional")
        }

        return profileHasUsableNutritionLog
            ? L10n.tr("profile.bodyRecovery.nutrition.logged", fallback: "Logged")
            : L10n.tr("profile.bodyRecovery.nutrition.noLogs", fallback: "No logs")
    }

    private var profileNutritionStateColor: Color {
        guard vm.profile.nutritionTrackingEnabled else {
            return STRQColors.iconSecondary
        }
        return profileHasUsableNutritionLog ? STRQPalette.success : STRQBrand.steel
    }

    private var profileHasUsableNutritionLog: Bool {
        vm.nutritionLogs.contains { log in
            log.calories > 0 || log.proteinGrams > 0 || log.carbsGrams > 0 || log.fatGrams > 0 || log.waterLiters > 0
        }
    }
}
