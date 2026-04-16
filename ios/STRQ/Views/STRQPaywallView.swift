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
        VStack(spacing: 0) {
            Spacer()

            heroSection

            Spacer().frame(height: 32)

            featureList

            Spacer().frame(height: 28)

            packageSelector

            Spacer().frame(height: 20)

            purchaseButton

            Spacer().frame(height: 14)

            restoreButton

            Spacer().frame(height: 8)

            legalText

            Spacer().frame(height: 16)
        }
        .padding(.horizontal, 24)
    }

    private var heroSection: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(STRQBrand.steelGradient)
                    .frame(width: 72, height: 72)
                    .overlay(
                        Circle()
                            .strokeBorder(Color.white.opacity(0.15), lineWidth: 1)
                    )
                Image(systemName: "bolt.fill")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(.white)
            }

            VStack(spacing: 8) {
                Text("STRQ Pro")
                    .font(.system(.title, design: .rounded, weight: .bold))
                    .tracking(0.5)

                Text("Unlock the full training system")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var featureList: some View {
        VStack(alignment: .leading, spacing: 14) {
            featureRow(icon: "brain.head.profile.fill", text: "Advanced coach insights")
            featureRow(icon: "chart.line.uptrend.xyaxis", text: "Weekly performance reviews")
            featureRow(icon: "arrow.triangle.2.circlepath", text: "Adaptive plan adjustments")
            featureRow(icon: "moon.zzz.fill", text: "Recovery & sleep intelligence")
            featureRow(icon: "scalemass.fill", text: "Nutrition coaching")
        }
        .padding(18)
        .background(Color(.secondarySystemGroupedBackground), in: .rect(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(STRQBrand.cardBorder, lineWidth: 1)
        )
    }

    private func featureRow(icon: String, text: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundStyle(STRQBrand.steel)
                .frame(width: 28, height: 28)
                .background(STRQBrand.steel.opacity(0.12), in: .rect(cornerRadius: 7))
            Text(text)
                .font(.subheadline.weight(.medium))
            Spacer()
        }
    }

    private var packageSelector: some View {
        VStack(spacing: 10) {
            if let annual = store.annualPackage {
                packageCard(
                    package: annual,
                    title: "Yearly",
                    subtitle: annualSubtitle(annual),
                    badge: trialBadge(annual),
                    isSelected: selectedPackage?.identifier == annual.identifier
                )
            }
            if let monthly = store.monthlyPackage {
                packageCard(
                    package: monthly,
                    title: "Monthly",
                    subtitle: monthly.storeProduct.localizedPriceString,
                    badge: nil,
                    isSelected: selectedPackage?.identifier == monthly.identifier
                )
            }
        }
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

            featureList
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

            featureList
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
