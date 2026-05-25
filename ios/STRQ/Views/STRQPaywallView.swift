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
            } else if showsLivePackagePreview {
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
        .onChange(of: packageSelectionSignature) { _, _ in
            selectDefaultPackageIfNeeded()
        }
        .onChange(of: selectedPackage?.identifier) { _, newId in
            guard let newId else { return }
            Analytics.shared.track(.package_selected, ["package": newId, "source": source])
        }
        .onAppear {
            selectDefaultPackageIfNeeded()
        }
    }

    private var showsLivePackagePreview: Bool {
        store.isConfigured && !livePackages.isEmpty
    }

    private var livePackages: [SubscriptionPackage] {
        [store.annualPackage, store.monthlyPackage].compactMap { $0 }
    }

    private var packageSelectionSignature: String {
        livePackages.map { "\($0.identifier):\($0.storeProduct.productIdentifier)" }.joined(separator: "|")
    }

    private func selectDefaultPackageIfNeeded() {
        guard !livePackages.isEmpty else {
            selectedPackage = nil
            return
        }
        if let selectedPackage,
           livePackages.contains(where: { $0.identifier == selectedPackage.identifier }) {
            return
        }
        selectedPackage = store.annualPackage ?? store.monthlyPackage ?? livePackages.first
    }

    // MARK: - Main content

    private var paywallContent: some View {
        ScrollView {
            VStack(spacing: 0) {
                heroSection
                    .padding(.top, 28)

                Spacer().frame(height: 26)

                freeAccessBlock

                Spacer().frame(height: 22)

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
                Text(proHeroEyebrow)
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
                Text(trainingMapBadgeTitle)
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

    private var proHeroEyebrow: String {
        #if DEBUG
        return L10n.tr("STRQ PRO PREVIEW")
        #else
        return L10n.tr("proPreview.eyebrow.release", fallback: "STRQ PRO")
        #endif
    }

    private var trainingMapBadgeTitle: String {
        #if DEBUG
        return L10n.tr("proPreview.trainingMapBadge.debug", fallback: "Debug preview")
        #else
        return L10n.tr("Pro")
        #endif
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
                    label: L10n.tr("proPreview.compare.history", fallback: "History"),
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
                Text(L10n.tr("Offer details come from Apple product metadata"))
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
                    priceLine: priceLine(for: annual),
                    detailLine: billingLine(for: annual),
                    secondaryLine: perMonthLine(for: annual),
                    badge: trialBadge(annual) ?? savingsBadge(),
                    isSelected: selectedPackage?.identifier == annual.identifier
                )
            }
            if let monthly = store.monthlyPackage {
                packageCard(
                    package: monthly,
                    title: L10n.tr("Monthly"),
                    priceLine: priceLine(for: monthly),
                    detailLine: billingLine(for: monthly),
                    secondaryLine: nil,
                    badge: trialBadge(monthly),
                    isSelected: selectedPackage?.identifier == monthly.identifier
                )
            }
        }
    }

    private func savingsBadge() -> String? {
        guard let annual = store.annualPackage,
              let monthly = store.monthlyPackage else { return nil }
        guard annual.storeProduct.currencyCode == monthly.storeProduct.currencyCode else { return nil }
        let annualPrice = annual.storeProduct.price
        let monthlyPrice = monthly.storeProduct.price
        let monthlyAsYear = monthlyPrice.doubleValue * 12
        guard monthlyAsYear > 0 else { return nil }
        let saved = 1.0 - (annualPrice.doubleValue / monthlyAsYear)
        guard saved > 0.1 else { return nil }
        return L10n.format("Save %d%%", Int(saved * 100))
    }

    private func priceLine(for package: SubscriptionPackage) -> String {
        guard let period = package.storeProduct.subscriptionPeriod else {
            return package.storeProduct.localizedPriceString
        }
        return "\(package.storeProduct.localizedPriceString)/\(periodPriceUnit(period))"
    }

    private func billingLine(for package: SubscriptionPackage) -> String {
        guard let period = package.storeProduct.subscriptionPeriod else {
            return L10n.tr("Billing period unavailable")
        }
        return L10n.format("Billed %@", billingPeriodName(period))
    }

    private func perMonthLine(for package: SubscriptionPackage) -> String? {
        guard package.storeProduct.subscriptionPeriod?.unit == .year else { return nil }
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
        switch intro.paymentMode {
        case .freeTrial:
            return L10n.format("%@ free trial", introPeriodName(period))
        case .payAsYouGo, .payUpFront:
            return L10n.format("%@ intro", intro.localizedPriceString)
        }
    }

    private func periodPriceUnit(_ period: SubscriptionPeriod) -> String {
        if period.value == 1 {
            return singularPeriodUnit(period.unit)
        }
        return "\(period.value) \(pluralPeriodUnit(period.unit))"
    }

    private func billingPeriodName(_ period: SubscriptionPeriod) -> String {
        if period.value == 1 {
            switch period.unit {
            case .day:
                return L10n.tr("daily")
            case .week:
                return L10n.tr("weekly")
            case .month:
                return L10n.tr("monthly")
            case .year:
                return L10n.tr("yearly")
            }
        }
        return L10n.format("every %@ %@", "\(period.value)", pluralPeriodUnit(period.unit))
    }

    private func introPeriodName(_ period: SubscriptionPeriod) -> String {
        if period.value == 1 {
            return L10n.format("1 %@", singularPeriodUnit(period.unit))
        }
        return L10n.format("%d %@", period.value, pluralPeriodUnit(period.unit))
    }

    private func singularPeriodUnit(_ unit: SubscriptionPeriod.Unit) -> String {
        switch unit {
        case .day:
            return L10n.tr("day")
        case .week:
            return L10n.tr("week")
        case .month:
            return L10n.tr("month")
        case .year:
            return L10n.tr("year")
        }
    }

    private func pluralPeriodUnit(_ unit: SubscriptionPeriod.Unit) -> String {
        switch unit {
        case .day:
            return L10n.tr("days")
        case .week:
            return L10n.tr("weeks")
        case .month:
            return L10n.tr("months")
        case .year:
            return L10n.tr("years")
        }
    }

    private func packageCard(package: SubscriptionPackage, title: String, priceLine: String, detailLine: String, secondaryLine: String?, badge: String?, isSelected: Bool) -> some View {
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
                            .foregroundStyle(.white)
                        if let badge {
                            Text(badge)
                                .font(.system(size: 10, weight: .bold))
                                .foregroundStyle(.black)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(STRQBrand.accentGradient, in: Capsule())
                        }
                    }
                    Text(priceLine)
                        .font(.system(size: 17, weight: .black).monospacedDigit())
                        .foregroundStyle(.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.78)
                    Text(detailLine)
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(Color.white.opacity(0.58))
                }

                Spacer()

                if let secondaryLine {
                    Text(secondaryLine)
                        .font(.system(size: 12, weight: .bold).monospacedDigit())
                        .foregroundStyle(isSelected ? .white : .secondary)
                        .accessibilityIdentifier("strq.pro-preview.package.secondary-price")
                }
            }
            .padding(16)
            .background(
                isSelected
                    ? Color.white.opacity(0.08)
                    : Color.white.opacity(0.045),
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
        .accessibilityIdentifier("strq.pro-preview.package.\(title.lowercased())")
    }

    // MARK: - Purchase button

    private var purchaseButton: some View {
        Button {} label: {
            VStack(spacing: 3) {
                Text(purchaseButtonTitle)
                    .font(.body.weight(.bold))
                Text(purchaseButtonSubtitle)
                    .font(.caption2.weight(.semibold))
            }
            .foregroundStyle(Color.white.opacity(0.72))
            .frame(maxWidth: .infinity)
            .frame(height: 54)
            .background(Color.white.opacity(0.055), in: .rect(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .strokeBorder(previewBorder, lineWidth: 1)
            )
        }
        .disabled(true)
        .accessibilityIdentifier("strq.pro-preview.purchase-disabled")
    }

    private var purchaseButtonTitle: String {
        #if DEBUG
        return L10n.tr("proPreview.purchaseDisabled.debug", fallback: "Debug build: purchases disabled")
        #else
        return L10n.tr("proPreview.purchaseUnavailable.title", fallback: "STRQ Pro is not available right now.")
        #endif
    }

    private var purchaseButtonSubtitle: String {
        #if DEBUG
        return L10n.tr("proPreview.purchaseDisabled.subtitle.debug", fallback: "Debug package preview")
        #else
        return L10n.tr("proPreview.purchaseUnavailable.subtitle", fallback: "Please try again later.")
        #endif
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
            if store.isRestoring {
                ProgressView()
                    .controlSize(.small)
            } else {
                Text(L10n.tr("Restore Purchases"))
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.secondary)
            }
        }
        .disabled(store.isRestoring)
        .accessibilityIdentifier("strq.pro-preview.restore")
    }

    private var legalText: some View {
        VStack(spacing: 8) {
            if let message = store.restoreMessage ?? store.error {
                Text(message)
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(Color.white.opacity(0.58))
                    .multilineTextAlignment(.center)
            }

            Text(L10n.tr("Subscriptions renew automatically unless canceled at least 24 hours before the end of the current period. Payment is charged to your Apple ID at confirmation. Manage or cancel in App Store settings."))
                .font(.system(size: 9))
                .foregroundStyle(.quaternary)
                .multilineTextAlignment(.center)

            HStack(spacing: 16) {
                Link(L10n.tr("Terms"), destination: STRQLinks.terms)
                Text("·").foregroundStyle(.quaternary)
                Link(L10n.tr("Privacy"), destination: STRQLinks.privacy)
            }
            .font(.caption2.weight(.semibold))
            .foregroundStyle(.secondary)
        }
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

                #if DEBUG
                debugPreviewBanner
                #else
                unavailableBanner
                #endif

                Spacer().frame(height: 22)

                freeAccessBlock

                Spacer().frame(height: 22)

                pillarList

                Spacer().frame(height: 22)

                compareBlock

                Spacer().frame(height: 22)

                #if DEBUG
                disabledDebugCTA
                #else
                unavailableCTA
                #endif

                Spacer().frame(height: 10)

                #if DEBUG
                previewTrustRow
                #endif

                Spacer().frame(height: 12)

                restoreButton

                Spacer().frame(height: 10)

                #if DEBUG
                debugPreviewFooterText
                #else
                unavailableFooterText
                #endif

                Spacer().frame(height: 28)
            }
            .padding(.horizontal, 24)
        }
        .scrollIndicators(.hidden)
    }

    private var debugPreviewBanner: some View {
        VStack(spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: "eye.fill")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(proAccentInk)
                Text(L10n.tr("proPreview.debugBanner.eyebrow", fallback: "DEBUG PREVIEW"))
                    .font(.system(size: 10, weight: .black))
                    .tracking(1.4)
                    .foregroundStyle(proAccentInk)
            }
            Text(L10n.tr("proPreview.debugBanner.title", fallback: "Debug build: purchase flow is disabled."))
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

    private var unavailableBanner: some View {
        VStack(spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: "clock.fill")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(proAccentInk)
                Text(L10n.tr("proPreview.unavailable.eyebrow", fallback: "STRQ PRO"))
                    .font(.system(size: 10, weight: .black))
                    .tracking(1.4)
                    .foregroundStyle(proAccentInk)
            }
            Text(L10n.tr("proPreview.purchaseUnavailable.title", fallback: "STRQ Pro is not available right now."))
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
            Text(L10n.tr("proPreview.purchaseUnavailable.subtitle", fallback: "Please try again later."))
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

    private var disabledDebugCTA: some View {
        VStack(spacing: 6) {
            HStack(spacing: 8) {
                Image(systemName: "eye.fill")
                    .font(.system(size: 12, weight: .bold))
                Text(L10n.tr("proPreview.disabledCTA.debug", fallback: "Debug preview"))
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
            Text(L10n.tr("proPreview.disabledCTA.detail.debug", fallback: "Purchases stay disabled in this debug slice."))
                .font(.caption2)
                .foregroundStyle(Color.white.opacity(0.46))
                .multilineTextAlignment(.center)
        }
    }

    private var unavailableCTA: some View {
        VStack(spacing: 6) {
            HStack(spacing: 8) {
                Image(systemName: "clock.fill")
                    .font(.system(size: 12, weight: .bold))
                Text(L10n.tr("proPreview.unavailableCTA", fallback: "Try again later"))
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
            Text(L10n.tr("proPreview.purchaseUnavailable.subtitle", fallback: "Please try again later."))
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

    private var debugPreviewFooterText: some View {
        VStack(spacing: 8) {
            Text(L10n.tr("proPreview.footer.debug", fallback: "Restore remains available from Profile. Pricing and Apple billing details may be hidden while debug purchases are inactive."))
                .font(.system(size: 9))
                .foregroundStyle(Color.white.opacity(0.34))
                .multilineTextAlignment(.center)

            HStack(spacing: 16) {
                Link(L10n.tr("Terms"), destination: STRQLinks.terms)
                Text("·").foregroundStyle(.quaternary)
                Link(L10n.tr("Privacy"), destination: STRQLinks.privacy)
            }
            .font(.caption2.weight(.semibold))
            .foregroundStyle(.secondary)
        }
    }

    private var unavailableFooterText: some View {
        VStack(spacing: 8) {
            Text(L10n.tr("proPreview.unavailableFooter", fallback: "Restore remains available from Profile."))
                .font(.system(size: 9))
                .foregroundStyle(Color.white.opacity(0.34))
                .multilineTextAlignment(.center)

            HStack(spacing: 16) {
                Link(L10n.tr("Terms"), destination: STRQLinks.terms)
                Text("·").foregroundStyle(.quaternary)
                Link(L10n.tr("Privacy"), destination: STRQLinks.privacy)
            }
            .font(.caption2.weight(.semibold))
            .foregroundStyle(.secondary)
        }
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
                Text(L10n.tr("proPreview.purchaseUnavailable.title", fallback: "STRQ Pro is not available right now."))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)

                Button {
                    Task { await store.fetchOfferings() }
                } label: {
                    Text(L10n.tr("proPreview.refresh", fallback: "Try Again"))
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
