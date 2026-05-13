import SwiftUI

struct STRQPaywallView: View {
    var store: StoreViewModel
    var source: String = "profile"
    @Environment(\.dismiss) private var dismiss
    @State private var selectedPackage: SubscriptionPackage?
    @State private var expandedPillars: Set<Int> = []

    private var previewBackground: LinearGradient {
        LinearGradient(
            colors: [
                Color(red: 0.030, green: 0.034, blue: 0.040),
                Color(red: 0.055, green: 0.060, blue: 0.072),
                Color(red: 0.026, green: 0.029, blue: 0.034)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private var previewSurface: Color {
        Color(red: 0.075, green: 0.082, blue: 0.096)
    }

    private var previewSurfaceRaised: Color {
        Color(red: 0.100, green: 0.108, blue: 0.126)
    }

    private var previewBorder: Color {
        Color.white.opacity(0.105)
    }

    private var proAccent: Color {
        Color(red: 0.46, green: 0.42, blue: 0.95)
    }

    private var proAccentInk: Color {
        Color(red: 0.78, green: 0.75, blue: 1.00)
    }

    private var proofTint: Color {
        Color(red: 0.40, green: 0.78, blue: 0.72)
    }

    var body: some View {
        ZStack {
            previewBackground.ignoresSafeArea()

            if store.isPro {
                activeProState
            } else if store.isLoading {
                loadingState
            } else if store.currentOffering != nil, !(store.currentOffering?.availablePackages.isEmpty ?? true) {
                paywallContent
            } else {
                comingSoonState
            }
        }
        .overlay(alignment: .topTrailing) {
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.secondary)
                    .frame(width: 32, height: 32)
                    .background(.ultraThinMaterial, in: Circle())
            }
            .accessibilityIdentifier("strq.pro-preview.close")
            .padding(16)
        }
        .onAppear { store.error = nil }
        .onChange(of: store.isPro) { _, isPro in
            if isPro { dismiss() }
        }
        .onChange(of: selectedPackage?.identifier) { _, newId in
            guard let newId else { return }
            Analytics.shared.track(.package_selected, ["package": newId, "source": source])
        }
        .onAppear {
            if let annual = store.annualPackage {
                selectedPackage = annual
            } else if let monthly = store.monthlyPackage {
                selectedPackage = monthly
            }
        }
    }

    // MARK: - Main content

    private var paywallContent: some View {
        ScrollView {
            VStack(spacing: 0) {
                heroSection
                    .padding(.top, 28)

                Spacer().frame(height: 26)

                pillarList

                Spacer().frame(height: 22)

                compareBlock

                Spacer().frame(height: 22)

                packageSelector

                Spacer().frame(height: 6)

                trialReassurance

                Spacer().frame(height: 16)

                purchaseButton

                Spacer().frame(height: 10)

                trustRow

                Spacer().frame(height: 12)

                restoreButton

                Spacer().frame(height: 10)

                legalText

                Spacer().frame(height: 28)
            }
            .padding(.horizontal, 24)
        }
        .scrollIndicators(.hidden)
        .accessibilityIdentifier("strq.pro-preview.scroll")
    }

    // MARK: - Hero

    private var heroSection: some View {
        VStack(spacing: 18) {
            VStack(spacing: 7) {
                Text(L10n.tr("STRQ PRO PREVIEW"))
                    .font(.system(size: 10, weight: .black))
                    .tracking(1.8)
                    .foregroundStyle(proAccentInk)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(proAccent.opacity(0.16), in: Capsule())
                    .overlay(
                        Capsule()
                            .strokeBorder(proAccent.opacity(0.34), lineWidth: 1)
                    )

                Text(L10n.tr("Train with a plan that keeps learning."))
                    .font(.system(.title2, design: .rounded, weight: .bold))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)

                Text(L10n.tr("Pro is the deeper layer after STRQ has real workouts to learn from: Training Map evidence, plan evolution, weekly review, and advanced history."))
                    .font(.subheadline)
                    .foregroundStyle(Color.white.opacity(0.68))
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, 2)
                    .padding(.horizontal, 4)
            }

            trainingMapPreview
        }
    }

    private var trainingMapPreview: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .center, spacing: 10) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(L10n.tr("TRAINING MAP"))
                        .font(.system(size: 10, weight: .black))
                        .tracking(1.2)
                        .foregroundStyle(Color.white.opacity(0.48))
                    Text(L10n.tr("Evidence forming"))
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(.white)
                }
                Spacer()
                Text(L10n.tr("Preview"))
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(proAccentInk)
                    .padding(.horizontal, 9)
                    .padding(.vertical, 4)
                    .background(proAccent.opacity(0.14), in: Capsule())
                    .overlay(Capsule().strokeBorder(proAccent.opacity(0.28), lineWidth: 1))
            }

            HStack(spacing: 8) {
                trainingMapNode(title: L10n.tr("Push"), value: 0.74, tint: proofTint)
                trainingMapNode(title: L10n.tr("Pull"), value: 0.58, tint: proAccentInk)
                trainingMapNode(title: L10n.tr("Legs"), value: 0.36, tint: Color(red: 0.88, green: 0.70, blue: 0.38))
            }

            VStack(spacing: 8) {
                evidenceLine(icon: "checkmark.circle.fill", title: L10n.tr("First plan stays free"), detail: L10n.tr("Onboarding, plan reveal, first workout, and core logging remain useful."))
                evidenceLine(icon: "chart.line.uptrend.xyaxis", title: L10n.tr("Pro adds depth later"), detail: L10n.tr("Deeper evidence appears once your training record can support it."))
            }
        }
        .padding(16)
        .background(
            LinearGradient(
                colors: [
                    previewSurfaceRaised,
                    previewSurface
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            in: .rect(cornerRadius: 22)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .strokeBorder(previewBorder, lineWidth: 1)
        )
        .overlay(alignment: .topLeading) {
            Capsule()
                .fill(proAccentInk.opacity(0.72))
                .frame(width: 48, height: 2)
                .padding(.leading, 18)
        }
    }

    private func trainingMapNode(title: String, value: Double, tint: Color) -> some View {
        let clampedValue = min(max(value, 0), 1)

        return VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption.weight(.bold))
                .foregroundStyle(.white)
            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.white.opacity(0.08))
                    Capsule()
                        .fill(tint.opacity(0.74))
                        .frame(width: max(CGFloat(8), proxy.size.width * CGFloat(clampedValue)))
                }
            }
            .frame(height: 5)
            Text(L10n.tr(value > 0.65 ? "Covered" : value > 0.45 ? "Forming" : "Light"))
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(Color.white.opacity(0.58))
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.black.opacity(0.16), in: .rect(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .strokeBorder(Color.white.opacity(0.06), lineWidth: 1)
        )
    }

    private func evidenceLine(icon: String, title: String, detail: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(proofTint)
                .frame(width: 20, height: 20)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.white.opacity(0.90))
                Text(detail)
                    .font(.caption2)
                    .foregroundStyle(Color.white.opacity(0.56))
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
        }
    }

    // MARK: - Pillars

    private struct Pillar {
        let icon: String
        let title: String
        let detail: String
        let bullets: [String]
    }

    private var pillars: [Pillar] {
        [
            Pillar(
                icon: "brain.head.profile.fill",
                title: L10n.tr("Adaptive plan evolution"),
                detail: L10n.tr("Your plan can respond to completed sessions, missed days, fatigue signals, and real progress evidence."),
                bullets: [
                    L10n.tr("Adjustments based on what you actually logged"),
                    L10n.tr("Comeback guidance after disrupted weeks"),
                    L10n.tr("Clear reasons before meaningful changes")
                ]
            ),
            Pillar(
                icon: "chart.line.uptrend.xyaxis",
                title: L10n.tr("Deeper Training Map"),
                detail: L10n.tr("See what is covered, what is forming, what is light, and which workouts made the signal stronger."),
                bullets: [
                    L10n.tr("Evidence behind each training area"),
                    L10n.tr("Confidence labels before strong claims"),
                    L10n.tr("Next unlocks tied to real sessions")
                ]
            ),
            Pillar(
                icon: "calendar.badge.clock",
                title: L10n.tr("Weekly coach review"),
                detail: L10n.tr("A calmer review of what moved, what stalled, and what STRQ recommends for the next week."),
                bullets: [
                    L10n.tr("Training rhythm and consistency read"),
                    L10n.tr("Progress signals that are ready to trust"),
                    L10n.tr("One next step, not a wall of metrics")
                ]
            ),
            Pillar(
                icon: "clock.arrow.circlepath",
                title: L10n.tr("Advanced evidence history"),
                detail: L10n.tr("Longer history, trend context, and evidence timelines for users who want to inspect the why."),
                bullets: [
                    L10n.tr("Session-to-session evidence trail"),
                    L10n.tr("Readable trends when data is mature"),
                    L10n.tr("Comparisons that stay tied to logged workouts")
                ]
            )
        ]
    }

    private var pillarList: some View {
        VStack(spacing: 10) {
            ForEach(pillars.indices, id: \.self) { i in
                pillarRow(pillars[i], index: i)
            }
        }
    }

    private func pillarRow(_ p: Pillar, index: Int) -> some View {
        let isExpanded = expandedPillars.contains(index)

        return HStack(alignment: .top, spacing: 14) {
            Image(systemName: p.icon)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 38, height: 38)
                .background(STRQBrand.steelGradient, in: .rect(cornerRadius: 10))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .strokeBorder(Color.white.opacity(0.08), lineWidth: 1)
                )

            VStack(alignment: .leading, spacing: 6) {
                Text(p.title)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(.white)
                Text(p.detail)
                    .font(.caption)
                    .foregroundStyle(Color.white.opacity(0.62))
                    .fixedSize(horizontal: false, vertical: true)

                Button {
                    withAnimation(.snappy(duration: 0.22)) {
                        if isExpanded {
                            expandedPillars.remove(index)
                        } else {
                            expandedPillars.insert(index)
                        }
                    }
                } label: {
                    HStack(spacing: 5) {
                        Text(L10n.tr("common.details", fallback: "Details"))
                            .font(.caption.weight(.semibold))
                        Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                            .font(.caption2.weight(.bold))
                    }
                    .foregroundStyle(STRQBrand.steel)
                }
                .buttonStyle(.plain)

                if isExpanded {
                    VStack(alignment: .leading, spacing: 4) {
                        ForEach(p.bullets, id: \.self) { line in
                            HStack(alignment: .top, spacing: 6) {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 9, weight: .bold))
                                    .foregroundStyle(STRQPalette.success)
                                    .frame(width: 10, alignment: .leading)
                                    .padding(.top, 2)
                                Text(line)
                                    .font(.system(size: 11.5, weight: .medium))
                                    .foregroundStyle(.white.opacity(0.78))
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                    }
                    .padding(.top, 2)
                }
            }
            Spacer(minLength: 0)
        }
        .padding(14)
        .background(previewSurface, in: .rect(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .strokeBorder(previewBorder, lineWidth: 1)
        )
    }

    // MARK: - Compare (Free vs Pro)

    private var compareBlock: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                RoundedRectangle(cornerRadius: 2)
                    .fill(STRQBrand.steelGradient)
                    .frame(width: 3, height: 14)
                Text(L10n.tr("WHAT YOU KEEP · WHAT PRO ADDS"))
                    .font(.system(size: 10, weight: .black))
                    .tracking(1.2)
                    .foregroundStyle(STRQBrand.steel)
                Spacer()
            }

            VStack(spacing: 0) {
                compareRow(
                    label: L10n.tr("Activation"),
                    free: L10n.tr("Onboarding + first plan"),
                    pro: L10n.tr("Learns over time")
                )
                Divider().opacity(0.25).padding(.horizontal, 14)
                compareRow(
                    label: L10n.tr("First workout"),
                    free: L10n.tr("Core logging included"),
                    pro: L10n.tr("Deeper review")
                )
                Divider().opacity(0.25).padding(.horizontal, 14)
                compareRow(
                    label: L10n.tr("Progress"),
                    free: L10n.tr("Basic Training Map"),
                    pro: L10n.tr("Evidence depth")
                )
                Divider().opacity(0.25).padding(.horizontal, 14)
                compareRow(
                    label: L10n.tr("Plan changes"),
                    free: L10n.tr("Safe fixes remain"),
                    pro: L10n.tr("Adaptive tuning")
                )
                Divider().opacity(0.25).padding(.horizontal, 14)
                compareRow(
                    label: L10n.tr("History"),
                    free: L10n.tr("Recent sessions"),
                    pro: L10n.tr("Longer evidence")
                )
            }
            .background(previewSurface, in: .rect(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .strokeBorder(previewBorder, lineWidth: 1)
            )
        }
    }

    private func compareRow(label: String, free: String, pro: String) -> some View {
        HStack(alignment: .center, spacing: 10) {
            Text(label)
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: 110, alignment: .leading)

            VStack(alignment: .leading, spacing: 2) {
                Text(L10n.tr("FREE"))
                    .font(.system(size: 8, weight: .black))
                    .tracking(0.8)
                    .foregroundStyle(Color.white.opacity(0.40))
                Text(free)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(Color.white.opacity(0.62))
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 3) {
                    Image(systemName: "bolt.fill")
                        .font(.system(size: 7, weight: .black))
                    Text(L10n.tr("PRO"))
                        .font(.system(size: 8, weight: .black))
                        .tracking(0.8)
                }
                .foregroundStyle(proAccentInk)
                Text(pro)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(.white)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 11)
    }

    // MARK: - Packages

    @ViewBuilder
    private var trialReassurance: some View {
        if let pkg = selectedPackage, pkg.storeProduct.introductoryDiscount != nil {
            HStack(spacing: 6) {
                Image(systemName: "apple.logo")
                    .font(.system(size: 10, weight: .bold))
                Text(L10n.tr("Apple shows offer details before purchase"))
                    .font(.caption2.weight(.semibold))
            }
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity)
            .padding(.top, 10)
        }
    }

    private var packageSelector: some View {
        VStack(spacing: 10) {
            if let annual = store.annualPackage {
                packageCard(
                    package: annual,
                    title: L10n.tr("Yearly"),
                    subtitle: annualSubtitle(annual),
                    trailing: perMonthLine(for: annual),
                    badge: trialBadge(annual) ?? savingsBadge(),
                    isSelected: selectedPackage?.identifier == annual.identifier
                )
            }
            if let monthly = store.monthlyPackage {
                packageCard(
                    package: monthly,
                    title: L10n.tr("Monthly"),
                    subtitle: L10n.format("%@/month", monthly.storeProduct.localizedPriceString),
                    trailing: nil,
                    badge: nil,
                    isSelected: selectedPackage?.identifier == monthly.identifier
                )
            }
        }
    }

    private func savingsBadge() -> String? {
        guard let annual = store.annualPackage,
              let monthly = store.monthlyPackage else { return nil }
        let annualPrice = annual.storeProduct.price
        let monthlyPrice = monthly.storeProduct.price
        let monthlyAsYear = monthlyPrice.doubleValue * 12
        guard monthlyAsYear > 0 else { return nil }
        let saved = 1.0 - (annualPrice.doubleValue / monthlyAsYear)
        guard saved > 0.1 else { return nil }
        return L10n.format("Save %d%%", Int(saved * 100))
    }

    private func annualSubtitle(_ package: SubscriptionPackage) -> String {
        let price = package.storeProduct.localizedPriceString
        return L10n.format("%@/year", price)
    }

    private func perMonthLine(for package: SubscriptionPackage) -> String? {
        let priceValue = package.storeProduct.price.doubleValue
        guard priceValue > 0 else { return nil }
        let monthly = priceValue / 12.0
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = package.storeProduct.priceFormatter?.locale ?? .current
        if let code = package.storeProduct.currencyCode {
            formatter.currencyCode = code
        }
        formatter.maximumFractionDigits = monthly < 10 ? 2 : 0
        guard let formatted = formatter.string(from: NSNumber(value: monthly)) else { return nil }
        return L10n.format("%@/mo", formatted)
    }

    private func trialBadge(_ package: SubscriptionPackage) -> String? {
        guard let intro = package.storeProduct.introductoryDiscount else { return nil }
        let period = intro.subscriptionPeriod
        if period.unit == .day {
            return L10n.format("%d-day free trial", period.value)
        } else if period.unit == .week {
            return L10n.format("%d-week free trial", period.value)
        }
        return L10n.tr("Free trial")
    }

    private func packageCard(package: SubscriptionPackage, title: String, subtitle: String, trailing: String?, badge: String?, isSelected: Bool) -> some View {
        Button {
            withAnimation(.snappy(duration: 0.2)) {
                selectedPackage = package
            }
        } label: {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .strokeBorder(isSelected ? Color.white : Color.white.opacity(0.2), lineWidth: 2)
                        .frame(width: 22, height: 22)
                    if isSelected {
                        Circle()
                            .fill(.white)
                            .frame(width: 12, height: 12)
                    }
                }

                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 8) {
                        Text(title)
                            .font(.subheadline.weight(.bold))
                        if let badge {
                            Text(badge)
                                .font(.system(size: 10, weight: .bold))
                                .foregroundStyle(.black)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(STRQBrand.accentGradient, in: Capsule())
                        }
                    }
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                if let trailing {
                    Text(trailing)
                        .font(.system(size: 12, weight: .bold).monospacedDigit())
                        .foregroundStyle(isSelected ? .white : .secondary)
                }
            }
            .padding(16)
            .background(
                isSelected
                    ? Color.white.opacity(0.08)
                    : Color(.secondarySystemGroupedBackground),
                in: .rect(cornerRadius: 14)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .strokeBorder(
                        isSelected ? Color.white.opacity(0.3) : STRQBrand.cardBorder,
                        lineWidth: isSelected ? 1.5 : 1
                    )
            )
        }
    }

    // MARK: - Purchase button

    private var purchaseButton: some View {
        Button {
            guard let pkg = selectedPackage else { return }
            Task { await store.purchase(package: pkg) }
        } label: {
            Group {
                if store.isPurchasing {
                    ProgressView()
                        .tint(.black)
                } else {
                    Text(purchaseButtonTitle)
                        .font(.body.weight(.bold))
                }
            }
            .foregroundStyle(.black)
            .frame(maxWidth: .infinity)
            .frame(height: 54)
            .background(STRQBrand.accentGradient, in: .rect(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.white.opacity(0.1))
                    .frame(height: 27)
                    .frame(maxWidth: .infinity)
                    .clipShape(.rect(cornerRadius: 14))
                    .allowsHitTesting(false)
                , alignment: .top
            )
            .shadow(color: .white.opacity(0.08), radius: 12, y: 2)
        }
        .disabled(selectedPackage == nil || store.isPurchasing)
    }

    private var purchaseButtonTitle: String {
        guard let pkg = selectedPackage else { return L10n.tr("Continue") }
        if pkg.storeProduct.introductoryDiscount != nil {
            return L10n.tr("Continue with STRQ Pro")
        }
        return L10n.tr("Continue with STRQ Pro")
    }

    private var trustRow: some View {
        HStack(spacing: 14) {
            trustItem(icon: "lock.shield.fill", label: L10n.tr("Secure"))
            trustDivider
            trustItem(icon: "xmark.circle.fill", label: L10n.tr("Cancel anytime"))
            trustDivider
            trustItem(icon: "apple.logo", label: L10n.tr("Via Apple"))
        }
        .frame(maxWidth: .infinity)
    }

    private func trustItem(icon: String, label: String) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 9, weight: .semibold))
            Text(label)
                .font(.system(size: 10, weight: .semibold))
        }
        .foregroundStyle(.tertiary)
    }

    private var trustDivider: some View {
        Circle()
            .fill(Color.white.opacity(0.18))
            .frame(width: 3, height: 3)
    }

    private var restoreButton: some View {
        Button {
            Task { await store.restore() }
        } label: {
            Text(L10n.tr("Restore Purchases"))
                .font(.caption.weight(.medium))
                .foregroundStyle(.secondary)
        }
        .accessibilityIdentifier("strq.pro-preview.restore")
    }

    private var legalText: some View {
        Text(L10n.tr("Apple shows pricing, renewal, and cancellation details before any purchase is confirmed."))
            .font(.system(size: 9))
            .foregroundStyle(.quaternary)
            .multilineTextAlignment(.center)
    }

    // MARK: - States

    private var activeProState: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 20) {
                ZStack {
                    Circle()
                        .fill(STRQPalette.success.opacity(0.15))
                        .frame(width: 88, height: 88)
                    Circle()
                        .fill(STRQBrand.steelGradient)
                        .frame(width: 72, height: 72)
                        .overlay(
                            Circle()
                                .strokeBorder(Color.white.opacity(0.15), lineWidth: 1)
                        )
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundStyle(.white)
                }

                VStack(spacing: 8) {
                    Text(L10n.tr("You have STRQ Pro"))
                        .font(.system(.title2, design: .rounded, weight: .bold))
                        .tracking(0.3)

                    Text(store.subscriptionStatusText)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Text(store.subscriptionPlanName)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 5)
                    .background(STRQPalette.success.opacity(0.8), in: Capsule())
            }

            Spacer()

            VStack(spacing: 12) {
                Button {
                    dismiss()
                } label: {
                    Text(L10n.tr("Done"))
                        .font(.body.weight(.bold))
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(STRQBrand.accentGradient, in: .rect(cornerRadius: 14))
                }

                restoreButton
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
    }

    private var loadingState: some View {
        VStack(spacing: 16) {
            ProgressView()
            Text(L10n.tr("Loading plans…"))
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    private var comingSoonState: some View {
        ScrollView {
            VStack(spacing: 0) {
                heroSection
                    .padding(.top, 28)

                Spacer().frame(height: 22)

                previewBanner

                Spacer().frame(height: 22)

                freeAccessBlock

                Spacer().frame(height: 22)

                pillarList

                Spacer().frame(height: 22)

                compareBlock

                Spacer().frame(height: 22)

                disabledCTA

                Spacer().frame(height: 10)

                previewTrustRow

                Spacer().frame(height: 12)

                restoreButton

                Spacer().frame(height: 10)

                previewFooterText

                Spacer().frame(height: 28)
            }
            .padding(.horizontal, 24)
        }
        .scrollIndicators(.hidden)
    }

    private var previewBanner: some View {
        VStack(spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: "eye.fill")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(proAccentInk)
                Text(L10n.tr("PREVIEW ONLY"))
                    .font(.system(size: 10, weight: .black))
                    .tracking(1.4)
                    .foregroundStyle(proAccentInk)
            }
            Text(L10n.tr("No purchase is available in this build."))
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
            Text(L10n.tr("This screen previews the kind of depth STRQ Pro may add after a user has seen value."))
                .font(.caption)
                .foregroundStyle(Color.white.opacity(0.62))
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity)
        .padding(16)
        .background(previewSurface, in: .rect(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .strokeBorder(previewBorder, lineWidth: 1)
        )
    }

    private var freeAccessBlock: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                RoundedRectangle(cornerRadius: 2)
                    .fill(proofTint)
                    .frame(width: 3, height: 14)
                Text(L10n.tr("FREE ACCESS STAYS USEFUL"))
                    .font(.system(size: 10, weight: .black))
                    .tracking(1.1)
                    .foregroundStyle(Color.white.opacity(0.62))
                Spacer()
            }

            VStack(spacing: 8) {
                freeAccessItem(icon: "person.crop.circle.badge.checkmark", title: L10n.tr("Free activation"), detail: L10n.tr("Onboarding and setup remain open."))
                freeAccessItem(icon: "map.fill", title: L10n.tr("First plan free"), detail: L10n.tr("Plan reveal is not blocked."))
                freeAccessItem(icon: "figure.strengthtraining.traditional", title: L10n.tr("First workout free"), detail: L10n.tr("Core workout logging remains usable."))
                freeAccessItem(icon: "chart.bar.fill", title: L10n.tr("Basic Progress free"), detail: L10n.tr("The Training Map starts useful before Pro depth."))
            }
        }
        .padding(16)
        .background(previewSurface, in: .rect(cornerRadius: 18))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .strokeBorder(previewBorder, lineWidth: 1)
        )
    }

    private func freeAccessItem(icon: String, title: String, detail: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(proofTint)
                .frame(width: 24, height: 24)
                .background(proofTint.opacity(0.12), in: .rect(cornerRadius: 8))
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.white.opacity(0.90))
                Text(detail)
                    .font(.caption2)
                    .foregroundStyle(Color.white.opacity(0.58))
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
        }
    }

    private var disabledCTA: some View {
        VStack(spacing: 6) {
            HStack(spacing: 8) {
                Image(systemName: "eye.fill")
                    .font(.system(size: 12, weight: .bold))
                Text(L10n.tr("Preview only"))
                    .font(.body.weight(.bold))
            }
            .foregroundStyle(Color.white.opacity(0.72))
            .frame(maxWidth: .infinity)
            .frame(height: 54)
            .background(Color.white.opacity(0.055), in: .rect(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .strokeBorder(previewBorder, lineWidth: 1)
            )
            Text(L10n.tr("Purchases stay disabled until a separate purchase implementation is approved."))
                .font(.caption2)
                .foregroundStyle(Color.white.opacity(0.46))
                .multilineTextAlignment(.center)
        }
    }

    private var previewTrustRow: some View {
        HStack(spacing: 10) {
            previewTrustItem(icon: "checkmark.seal.fill", label: L10n.tr("No purchase today"))
            trustDivider
            previewTrustItem(icon: "figure.strengthtraining.traditional", label: L10n.tr("Training stays open"))
        }
        .frame(maxWidth: .infinity)
    }

    private func previewTrustItem(icon: String, label: String) -> some View {
        HStack(spacing: 5) {
            Image(systemName: icon)
                .font(.system(size: 9, weight: .semibold))
            Text(label)
                .font(.system(size: 10, weight: .semibold))
        }
        .foregroundStyle(Color.white.opacity(0.46))
    }

    private var previewFooterText: some View {
        Text(L10n.tr("Restore remains available from Profile and this preview. Pricing and Apple billing details are not shown because purchases are not active in this build."))
            .font(.system(size: 9))
            .foregroundStyle(Color.white.opacity(0.34))
            .multilineTextAlignment(.center)
    }

    private var emptyState: some View {
        VStack(spacing: 0) {
            Spacer()

            heroSection

            Spacer().frame(height: 24)

            pillarList
                .padding(.horizontal, 24)

            Spacer().frame(height: 28)

            VStack(spacing: 14) {
                Text(L10n.tr("STRQ Pro Preview is not connected to products in this build."))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)

                Button {
                    Task { await store.fetchOfferings() }
                } label: {
                    Text(L10n.tr("Refresh Preview"))
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 28)
                        .padding(.vertical, 12)
                        .background(proAccent.opacity(0.24), in: Capsule())
                        .overlay(Capsule().strokeBorder(proAccent.opacity(0.36), lineWidth: 1))
                }
            }
            .padding(.horizontal, 32)

            Spacer()

            restoreButton
                .padding(.bottom, 24)
        }
    }
}
