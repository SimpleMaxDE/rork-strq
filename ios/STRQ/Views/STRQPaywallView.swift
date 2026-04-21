import SwiftUI
import RevenueCat

struct STRQPaywallView: View {
    var store: StoreViewModel
    var source: String = "profile"
    @Environment(\.dismiss) private var dismiss
    @State private var selectedPackage: Package?

    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()

            if store.isPro {
                alreadySubscribedState
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
    }

    // MARK: - Hero

    private var heroSection: some View {
        VStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(STRQBrand.steelGradient)
                    .frame(width: 68, height: 68)
                    .overlay(
                        Circle()
                            .strokeBorder(Color.white.opacity(0.15), lineWidth: 1)
                    )
                Image(systemName: "bolt.fill")
                    .font(.system(size: 26, weight: .bold))
                    .foregroundStyle(.white)
            }

            VStack(spacing: 6) {
                Text("STRQ PRO")
                    .font(.system(size: 11, weight: .black))
                    .tracking(2.4)
                    .foregroundStyle(STRQBrand.steel)

                Text("Coaching that keeps learning you")
                    .font(.system(.title2, design: .rounded, weight: .bold))
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)

                Text("Adaptive plans, deeper progression reads, and every session safely carried across your devices.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, 2)
                    .padding(.horizontal, 4)
            }
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
                title: "Adaptive coaching",
                detail: "Readiness-aware adjustments and weekly reviews that tune your plan as you train.",
                bullets: [
                    "Smart swaps that preserve the training role",
                    "Weekly check-in that reasons about your week",
                    "Comeback guidance after missed sessions"
                ]
            ),
            Pillar(
                icon: "chart.line.uptrend.xyaxis",
                title: "Deeper progression",
                detail: "Long-term phase reads, progression memory, and a change log you can trust.",
                bullets: [
                    "Mesocycle outlook — block, phase, and next shift",
                    "Per-lift progression signals and plateau reads",
                    "Coaching memory: what changed, why, and when"
                ]
            ),
            Pillar(
                icon: "scalemass.fill",
                title: "Physique intelligence",
                detail: "Bodyweight trend and nutrition coaching tuned to your goal — fully opt-in.",
                bullets: [
                    "Regression-based bodyweight trend with 4-week projection",
                    "Protein and calorie targets that follow your goal",
                    "Nutrition × training bridge, not a calorie tracker"
                ]
            ),
            Pillar(
                icon: "icloud.fill",
                title: "Ecosystem & continuity",
                detail: "Your training carried safely across devices, with premium continuity features.",
                bullets: [
                    "iCloud sync across iPhone, iPad, and Mac",
                    "Smart reminders tuned to your week",
                    "Priority updates and early-access features"
                ]
            )
        ]
    }

    private var pillarList: some View {
        VStack(spacing: 10) {
            ForEach(pillars.indices, id: \.self) { i in
                pillarRow(pillars[i])
            }
        }
    }

    private func pillarRow(_ p: Pillar) -> some View {
        HStack(alignment: .top, spacing: 14) {
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
                Text(p.detail)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)

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
            Spacer(minLength: 0)
        }
        .padding(14)
        .background(Color(.secondarySystemGroupedBackground), in: .rect(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .strokeBorder(STRQBrand.cardBorder, lineWidth: 1)
        )
    }

    // MARK: - Compare (Free vs Pro)

    private var compareBlock: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                RoundedRectangle(cornerRadius: 2)
                    .fill(STRQBrand.steelGradient)
                    .frame(width: 3, height: 14)
                Text("WHAT YOU KEEP · WHAT PRO ADDS")
                    .font(.system(size: 10, weight: .black))
                    .tracking(1.2)
                    .foregroundStyle(STRQBrand.steel)
                Spacer()
            }

            VStack(spacing: 0) {
                compareRow(
                    label: "Plan generation",
                    free: "Strong default plans",
                    pro: "Adaptive weekly tuning"
                )
                Divider().opacity(0.25).padding(.horizontal, 14)
                compareRow(
                    label: "Exercise library",
                    free: "Full curated catalog",
                    pro: "Smart swaps & alternatives"
                )
                Divider().opacity(0.25).padding(.horizontal, 14)
                compareRow(
                    label: "Progression",
                    free: "Per-session logging",
                    pro: "Phase outlook & memory"
                )
                Divider().opacity(0.25).padding(.horizontal, 14)
                compareRow(
                    label: "Physique coaching",
                    free: "Training-only",
                    pro: "Trend · protein · bridge"
                )
                Divider().opacity(0.25).padding(.horizontal, 14)
                compareRow(
                    label: "Across devices",
                    free: "This device",
                    pro: "iCloud continuity"
                )
            }
            .background(Color(.secondarySystemGroupedBackground), in: .rect(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .strokeBorder(STRQBrand.cardBorder, lineWidth: 1)
            )
        }
    }

    private func compareRow(label: String, free: String, pro: String) -> some View {
        HStack(alignment: .center, spacing: 10) {
            Text(label)
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(.primary)
                .frame(width: 110, alignment: .leading)

            VStack(alignment: .leading, spacing: 2) {
                Text("FREE")
                    .font(.system(size: 8, weight: .black))
                    .tracking(0.8)
                    .foregroundStyle(.tertiary)
                Text(free)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 3) {
                    Image(systemName: "bolt.fill")
                        .font(.system(size: 7, weight: .black))
                    Text("PRO")
                        .font(.system(size: 8, weight: .black))
                        .tracking(0.8)
                }
                .foregroundStyle(.white)
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
                Image(systemName: "lock.open.fill")
                    .font(.system(size: 10, weight: .bold))
                Text("Try free, cancel anytime before it renews")
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
                    title: "Yearly",
                    subtitle: annualSubtitle(annual),
                    trailing: perMonthLine(for: annual),
                    badge: trialBadge(annual) ?? savingsBadge(),
                    isSelected: selectedPackage?.identifier == annual.identifier
                )
            }
            if let monthly = store.monthlyPackage {
                packageCard(
                    package: monthly,
                    title: "Monthly",
                    subtitle: "\(monthly.storeProduct.localizedPriceString)/month",
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
        let annualPrice = annual.storeProduct.price as NSDecimalNumber
        let monthlyPrice = monthly.storeProduct.price as NSDecimalNumber
        let monthlyAsYear = monthlyPrice.doubleValue * 12
        guard monthlyAsYear > 0 else { return nil }
        let saved = 1.0 - (annualPrice.doubleValue / monthlyAsYear)
        guard saved > 0.1 else { return nil }
        return "Save \(Int(saved * 100))%"
    }

    private func annualSubtitle(_ package: Package) -> String {
        let price = package.storeProduct.localizedPriceString
        return "\(price)/year"
    }

    private func perMonthLine(for package: Package) -> String? {
        let priceValue = (package.storeProduct.price as NSDecimalNumber).doubleValue
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
        return "\(formatted)/mo"
    }

    private func trialBadge(_ package: Package) -> String? {
        guard let intro = package.storeProduct.introductoryDiscount else { return nil }
        let period = intro.subscriptionPeriod
        if period.unit == .day {
            return "\(period.value)-day free trial"
        } else if period.unit == .week {
            return "\(period.value)-week free trial"
        }
        return "Free trial"
    }

    private func packageCard(package: Package, title: String, subtitle: String, trailing: String?, badge: String?, isSelected: Bool) -> some View {
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
        guard let pkg = selectedPackage else { return "Continue" }
        if pkg.storeProduct.introductoryDiscount != nil {
            return "Start Free Trial"
        }
        return "Subscribe"
    }

    private var trustRow: some View {
        HStack(spacing: 14) {
            trustItem(icon: "lock.shield.fill", label: "Secure")
            trustDivider
            trustItem(icon: "xmark.circle.fill", label: "Cancel anytime")
            trustDivider
            trustItem(icon: "apple.logo", label: "Via Apple")
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
            Text("Restore Purchases")
                .font(.caption.weight(.medium))
                .foregroundStyle(.secondary)
        }
    }

    private var legalText: some View {
        Text("Payment is charged to your Apple ID account. Subscription auto-renews unless cancelled at least 24 hours before the end of the current period.")
            .font(.system(size: 9))
            .foregroundStyle(.quaternary)
            .multilineTextAlignment(.center)
    }

    // MARK: - States

    private var alreadySubscribedState: some View {
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
                    Text("You have STRQ Pro")
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
                    Text("Done")
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
            Text("Loading plans…")
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

                comingSoonBanner

                Spacer().frame(height: 22)

                pillarList

                Spacer().frame(height: 22)

                compareBlock

                Spacer().frame(height: 22)

                disabledCTA

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
    }

    private var comingSoonBanner: some View {
        VStack(spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: "sparkles")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(STRQBrand.steel)
                Text("SUBSCRIPTIONS COMING SOON")
                    .font(.system(size: 10, weight: .black))
                    .tracking(1.4)
                    .foregroundStyle(STRQBrand.steel)
            }
            Text("Premium plans will become available once App Store setup is complete.")
                .font(.subheadline.weight(.semibold))
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
            Text("You can continue exploring STRQ in the meantime.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity)
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground), in: .rect(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .strokeBorder(STRQBrand.cardBorder, lineWidth: 1)
        )
    }

    private var disabledCTA: some View {
        VStack(spacing: 6) {
            Text("Unavailable")
                .font(.body.weight(.bold))
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(Color.white.opacity(0.05), in: .rect(cornerRadius: 14))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .strokeBorder(STRQBrand.cardBorder, lineWidth: 1)
                )
            Text("Check back once premium plans are live.")
                .font(.caption2)
                .foregroundStyle(.tertiary)
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
                Text("Subscription plans are currently unavailable.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)

                Button {
                    Task { await store.fetchOfferings() }
                } label: {
                    Text("Try Again")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.black)
                        .padding(.horizontal, 28)
                        .padding(.vertical, 12)
                        .background(STRQBrand.accentGradient, in: Capsule())
                }
            }
            .padding(.horizontal, 32)

            Spacer()

            restoreButton
                .padding(.bottom, 24)
        }
    }
}
