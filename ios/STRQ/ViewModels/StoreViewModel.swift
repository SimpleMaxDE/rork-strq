import Foundation
import Observation
import StoreKit
import RevenueCat

@Observable
@MainActor
class StoreViewModel {
    var offerings: Offerings?
    var isPro: Bool = false
    var isLoading: Bool = false
    var isPurchasing: Bool = false
    var error: String?
    var customerInfo: CustomerInfo?
    var isConfigured: Bool = false
    var restoreMessage: String?

    private var hasStartedListening = false

    static var isRevenueCatConfigured: Bool {
        let testKey = Config.EXPO_PUBLIC_REVENUECAT_TEST_API_KEY
        let prodKey = Config.EXPO_PUBLIC_REVENUECAT_IOS_API_KEY
        return !testKey.isEmpty || !prodKey.isEmpty
    }

    init() {
        isConfigured = Self.isRevenueCatConfigured
        guard isConfigured else { return }
        Task { await listenForUpdates() }
        Task { await fetchOfferings() }
    }

    private func listenForUpdates() async {
        guard isConfigured, !hasStartedListening else { return }
        hasStartedListening = true
        for await info in Purchases.shared.customerInfoStream {
            self.customerInfo = info
            self.isPro = info.entitlements["pro"]?.isActive == true
        }
    }

    func refreshStatus() async {
        guard isConfigured else { return }
        do {
            let info = try await Purchases.shared.customerInfo()
            customerInfo = info
            isPro = info.entitlements["pro"]?.isActive == true
        } catch {}
    }

    func fetchOfferings() async {
        guard isConfigured else { return }
        isLoading = true
        defer { isLoading = false }
        ErrorReporter.shared.breadcrumb("Fetching offerings", category: "subscription")
        do {
            offerings = try await Purchases.shared.offerings()
            let info = try await Purchases.shared.customerInfo()
            customerInfo = info
            isPro = info.entitlements["pro"]?.isActive == true
        } catch {
            self.error = error.localizedDescription
            ErrorReporter.shared.report(error, context: ["flow": "fetchOfferings"])
        }
    }

    func purchase(package: Package) async {
        guard isConfigured else { return }
        isPurchasing = true
        defer { isPurchasing = false }
        Analytics.shared.track(.purchase_started, [
            "package": package.identifier,
            "product": package.storeProduct.productIdentifier
        ])
        ErrorReporter.shared.breadcrumb("Purchase started \(package.identifier)", category: "subscription")
        do {
            let result = try await Purchases.shared.purchase(package: package)
            if !result.userCancelled {
                isPro = result.customerInfo.entitlements["pro"]?.isActive == true
                customerInfo = result.customerInfo
                Analytics.shared.track(.purchase_completed, [
                    "package": package.identifier,
                    "is_pro": isPro ? "true" : "false"
                ])
            } else {
                Analytics.shared.track(.purchase_failed, ["reason": "cancelled"])
            }
        } catch ErrorCode.purchaseCancelledError {
            Analytics.shared.track(.purchase_failed, ["reason": "cancelled"])
        } catch ErrorCode.paymentPendingError {
            Analytics.shared.track(.purchase_failed, ["reason": "pending"])
        } catch {
            self.error = error.localizedDescription
            Analytics.shared.track(.purchase_failed, ["reason": "error"])
            ErrorReporter.shared.report(error, context: ["flow": "purchase", "package": package.identifier])
        }
    }

    func restore() async {
        guard isConfigured else {
            restoreMessage = "Subscriptions are not available in this environment."
            Analytics.shared.track(.restore_failed, ["reason": "unconfigured"])
            return
        }
        isLoading = true
        restoreMessage = nil
        defer { isLoading = false }
        Analytics.shared.track(.restore_started)
        do {
            let info = try await Purchases.shared.restorePurchases()
            isPro = info.entitlements["pro"]?.isActive == true
            customerInfo = info
            restoreMessage = isPro ? "Purchases restored successfully." : "No active subscriptions found."
            Analytics.shared.track(.restore_completed, ["is_pro": isPro ? "true" : "false"])
        } catch {
            self.error = error.localizedDescription
            Analytics.shared.track(.restore_failed, ["reason": "error"])
            ErrorReporter.shared.report(error, context: ["flow": "restore"])
        }
    }

    var subscriptionStatusText: String {
        guard isConfigured else { return "Free" }
        guard isPro else { return "Free" }
        if let entitlement = customerInfo?.entitlements["pro"], entitlement.isActive {
            if entitlement.willRenew {
                return "Active · Renews automatically"
            } else {
                if let expDate = entitlement.expirationDate {
                    let formatter = DateFormatter()
                    formatter.dateStyle = .medium
                    return "Expires \(formatter.string(from: expDate))"
                }
                return "Active · Expires soon"
            }
        }
        return "Active"
    }

    var subscriptionPlanName: String {
        guard isPro, let entitlement = customerInfo?.entitlements["pro"], entitlement.isActive else {
            return "Free"
        }
        let id = entitlement.productIdentifier
        if id.contains("yearly") || id.contains("annual") {
            return "Yearly"
        } else if id.contains("monthly") {
            return "Monthly"
        }
        return "Pro"
    }

    var currentOffering: Offering? {
        offerings?.current
    }

    var annualPackage: Package? {
        currentOffering?.annual
    }

    var monthlyPackage: Package? {
        currentOffering?.monthly
    }
}
