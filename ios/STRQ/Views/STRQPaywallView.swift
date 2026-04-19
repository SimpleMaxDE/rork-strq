import SwiftUI
import RevenueCat

struct STRQPaywallView: View {
    var store: StoreViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var selectedPackage: Package?

    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()

            if store.isPro {
                alreadySubscribedState
            } else if store.isLoading {
                loadingState
            } else if store.currentOffering != nil {
                paywallContent
            } else if !store.isConfigured {
                notConfiguredState
            } else {
                emptyState
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
        .alert("Error", isPresented: .init(
            get: { store.error != nil },
            set: { if !$0 { store.error = nil } }
        )) {
            Button("OK") { store.error = nil }
        } message: {
            Text(store.error ?? "")
        }
        .onChange(of: store.isPro) { _, isPro in
            if isPro { dismiss() }
        }
        .onAppear {
            if let annual = store.annualPackage {
                selectedPackage = annual
            } else if let monthly = store.monthlyPackage {
                selectedPackage = monthly
            }
        }
    }

    private var paywallContent: some View {
        ScrollView {
            VStack(spacing: 0) {
                heroSection
                    .padding(.top, 24)

                Spacer().frame(height: 28)

                pillarList

                Spacer().frame(height: 22)

                packageSelector

                Spacer().frame(height: 6)

                trialReassurance

                Spacer().frame(height: 18)

                purchaseButton

                Spacer().frame(height: 12)

                restoreButton

                Spacer().frame(height: 10)

                legalText

                Spacer().frame(height: 24)
            }
            .padding(.horizontal, 24)
        }
        .scrollIndicators(.hidden)
    }

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

                Text("Training that keeps adapting to you")
                    .font(.system(.title2, design: .rounded, weight: .bold))
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)

                Text("Deeper coaching, evolving plans, and your training safely synced across devices.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, 2)
            }
        }
    }

    private var pillarList: some View {
        VStack(spacing: 10) {
            pillarRow(
                icon: "brain.head.profile.fill",
                title: "Adaptive Coaching",
                detail: "Readiness-aware adjustments, weekly reviews, and deeper plan reasoning."
            )
            pillarRow(
                icon: "arrow.triangle.2.circlepath",
                title: "Plans That Evolve",
                detail: "Automatic progression, smart swaps, and training that responds to your signals."
            )
            pillarRow(
                icon: "scalemass.fill",
                title: "Physique Intelligence",
                detail: "Bodyweight trend, protein and calorie guidance tuned to your goal."
            )
            pillarRow(
                icon: "icloud.fill",
                title: "Ecosystem Access",
                detail: "iCloud sync, Apple Watch companion, widgets, and Live Activity."
            )
        }
    }

    private func pillarRow(icon: String, title: String, detail: String) -> some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 38, height: 38)
                .background(STRQBrand.steelGradient, in: .rect(cornerRadius: 10))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .strokeBorder(Color.white.opacity(0.08), lineWidth: 1)
                )

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.subheadline.weight(.bold))
                Text(detail)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
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
                    badge: trialBadge(annual) ?? savingsBadge(),
                    isSelected: selectedPackage?.identifier == annual.identifier
                )
            }
            if let monthly = store.monthlyPackage {
                packageCard(
                    package: monthly,
                    title: "Monthly",
                    subtitle: "\(monthly.storeProduct.localizedPriceString)/month",
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

    private func packageCard(package: Package, title: String, subtitle: String, badge: String?, isSelected: Bool) -> some View {
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

    private var alreadySubscribedState: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 20) {
                ZStack {
                    Circle()
                        .fill(.green.opacity(0.15))
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
                    .background(.green.opacity(0.8), in: Capsule())
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
            Text("Loading plans...")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    private var notConfiguredState: some View {
        VStack(spacing: 0) {
            Spacer()

            heroSection

            Spacer().frame(height: 24)

            pillarList
                .padding(.horizontal, 24)

            Spacer().frame(height: 28)

            VStack(spacing: 10) {
                Image(systemName: "info.circle")
                    .font(.title3)
                    .foregroundStyle(STRQBrand.steel)

                Text("Subscriptions are not available in this preview environment.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)

                Text("Install on your device via TestFlight to subscribe.")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 32)

            Spacer()

            restoreButton
                .padding(.bottom, 24)
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
