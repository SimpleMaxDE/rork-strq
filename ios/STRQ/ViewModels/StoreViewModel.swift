import Foundation
import Observation

struct SubscriptionPeriod {
    enum Unit: Equatable {
        case day
        case week
        case month
        case year
    }

    let unit: Unit
    let value: Int
}

struct SubscriptionIntroductoryDiscount {
    let subscriptionPeriod: SubscriptionPeriod
}

struct SubscriptionProduct {
    let productIdentifier: String
    let localizedPriceString: String
    let price: NSDecimalNumber
    let priceFormatter: NumberFormatter?
    let currencyCode: String?
    let introductoryDiscount: SubscriptionIntroductoryDiscount?
}

struct SubscriptionPackage: Identifiable {
    let identifier: String
    let storeProduct: SubscriptionProduct

    var id: String {
        identifier
    }
}

struct SubscriptionOffering {
    let availablePackages: [SubscriptionPackage]

    var annual: SubscriptionPackage? {
        availablePackages.first { package in
            let id = package.identifier.lowercased()
            let productId = package.storeProduct.productIdentifier.lowercased()
            return id.contains("annual")
                || id.contains("year")
                || productId.contains("annual")
                || productId.contains("year")
        }
    }

    var monthly: SubscriptionPackage? {
        availablePackages.first { package in
            let id = package.identifier.lowercased()
            let productId = package.storeProduct.productIdentifier.lowercased()
            return id.contains("month") || productId.contains("month")
        }
    }
}

@Observable
@MainActor
class StoreViewModel {
    private let subscriptionService: any SubscriptionService
    private var fetchedOffering: SubscriptionOffering?

    var isPro: Bool = false
    var isLoading: Bool = false
    var isPurchasing: Bool = false
    var isRestoring: Bool = false
    var error: String?
    var isConfigured: Bool = false
    var restoreMessage: String?

    nonisolated static var hasRevenueCatKeys: Bool {
        let testKey = Config.EXPO_PUBLIC_REVENUECAT_TEST_API_KEY
        let prodKey = Config.EXPO_PUBLIC_REVENUECAT_IOS_API_KEY
        return !testKey.isEmpty || !prodKey.isEmpty
    }

    nonisolated static var isRevenueCatConfigured: Bool {
        RevenueCatSubscriptionService.isSDKConfigured
    }

    convenience init() {
        self.init(subscriptionService: RevenueCatSubscriptionService(), autoRefresh: true)
    }

    init(subscriptionService: any SubscriptionService, autoRefresh: Bool = true) {
        self.subscriptionService = subscriptionService
        isConfigured = subscriptionService.isConfigured
        if Self.hasRevenueCatKeys {
            ErrorReporter.shared.breadcrumb("RevenueCat keys present for subscription service", category: "subscription")
        }
        if autoRefresh {
            Task { [weak self] in
                await self?.refreshStatus()
                await self?.fetchOfferings()
            }
        }
    }

    func refreshStatus() async {
        isConfigured = subscriptionService.isConfigured
        guard isConfigured else {
            isPro = false
            error = nil
            return
        }

        do {
            let snapshot = try await subscriptionService.customerInfo()
            isConfigured = subscriptionService.isConfigured
            isPro = snapshot.isPro
            error = nil
        } catch let serviceError as SubscriptionServiceError where serviceError == .notConfigured {
            isConfigured = false
            isPro = false
            error = nil
        } catch {
            isConfigured = subscriptionService.isConfigured
            self.error = L10n.tr("Subscription status is temporarily unavailable.")
            ErrorReporter.shared.breadcrumb(
                "RevenueCat customer info refresh failed",
                category: "subscription",
                data: ["error": error.localizedDescription]
            )
        }
    }

    func fetchOfferings() async {
        isConfigured = subscriptionService.isConfigured
        guard isConfigured else {
            fetchedOffering = nil
            error = nil
            return
        }

        do {
            fetchedOffering = try await subscriptionService.offerings()
            error = nil
        } catch let serviceError as SubscriptionServiceError where serviceError == .notConfigured {
            isConfigured = false
            fetchedOffering = nil
            error = nil
        } catch {
            fetchedOffering = nil
            self.error = L10n.tr("Subscription products are temporarily unavailable.")
            ErrorReporter.shared.breadcrumb(
                "RevenueCat offerings fetch failed",
                category: "subscription",
                data: ["error": error.localizedDescription]
            )
        }
    }

    func purchase(package: SubscriptionPackage) async {
        guard !isPurchasing else { return }

        isConfigured = subscriptionService.isConfigured
        guard isConfigured else {
            error = L10n.tr("Subscriptions are not available in this environment.")
            Analytics.shared.track(.purchase_failed, purchaseAnalytics(package: package, reason: "unconfigured"))
            return
        }

        isPurchasing = true
        error = nil
        Analytics.shared.track(.purchase_started, purchaseAnalytics(package: package))
        defer { isPurchasing = false }

        do {
            let result = try await subscriptionService.purchase(package: package)
            isConfigured = subscriptionService.isConfigured
            guard !result.userCancelled else {
                error = nil
                return
            }

            isPro = result.snapshot.isPro
            error = nil
            Analytics.shared.track(
                .purchase_completed,
                purchaseAnalytics(package: package, pro: result.snapshot.isPro)
            )
        } catch let serviceError as SubscriptionServiceError where serviceError == .purchaseCancelled {
            isConfigured = subscriptionService.isConfigured
            error = nil
        } catch let serviceError as SubscriptionServiceError {
            isConfigured = subscriptionService.isConfigured
            applyPurchaseFailure(serviceError, package: package)
        } catch {
            isConfigured = subscriptionService.isConfigured
            applyPurchaseFailure(.purchaseFailed, package: package)
        }
    }

    var productsUnavailable: Bool {
        fetchedOffering?.availablePackages.isEmpty ?? true
    }

    func restore() async {
        guard !isRestoring else { return }

        isConfigured = subscriptionService.isConfigured
        guard isConfigured else {
            restoreMessage = L10n.tr("Subscriptions are not available in this environment.")
            error = nil
            Analytics.shared.track(.restore_failed, ["reason": "unconfigured"])
            return
        }

        isRestoring = true
        restoreMessage = nil
        error = nil
        Analytics.shared.track(.restore_started)
        defer { isRestoring = false }

        do {
            let snapshot = try await subscriptionService.restorePurchases()
            isConfigured = subscriptionService.isConfigured
            isPro = snapshot.isPro
            error = nil
            restoreMessage = snapshot.isPro
                ? L10n.tr("Purchases restored successfully.")
                : L10n.tr("No active subscriptions found.")
            Analytics.shared.track(.restore_completed, ["pro": snapshot.isPro ? "true" : "false"])
        } catch let serviceError as SubscriptionServiceError {
            isConfigured = subscriptionService.isConfigured
            applyRestoreFailure(serviceError)
        } catch {
            isConfigured = subscriptionService.isConfigured
            applyRestoreFailure(.restoreFailed)
        }
    }

    var subscriptionStatusText: String {
        isPro ? L10n.tr("Active") : L10n.tr("Free")
    }

    var subscriptionPlanName: String {
        isPro ? L10n.tr("Pro") : L10n.tr("Free")
    }

    var currentOffering: SubscriptionOffering? {
        // Products stay internal until the separate live purchase UI slice.
        nil
    }

    var annualPackage: SubscriptionPackage? {
        // Live package cards wait for the separate live purchase UI slice.
        nil
    }

    var monthlyPackage: SubscriptionPackage? {
        // Live package cards wait for the separate live purchase UI slice.
        nil
    }

    private func purchaseAnalytics(
        package: SubscriptionPackage,
        reason: String? = nil,
        pro: Bool? = nil
    ) -> [String: String] {
        var properties = [
            "package": package.identifier,
            "product_id": package.storeProduct.productIdentifier
        ]
        if let reason {
            properties["reason"] = reason
        }
        if let pro {
            properties["pro"] = pro ? "true" : "false"
        }
        return properties
    }

    private func applyPurchaseFailure(_ serviceError: SubscriptionServiceError, package: SubscriptionPackage) {
        let reason: String
        switch serviceError {
        case .notConfigured:
            isConfigured = false
            error = L10n.tr("Subscriptions are not available in this environment.")
            reason = "unconfigured"
        case .packageUnavailable:
            error = L10n.tr("Subscription products are temporarily unavailable.")
            reason = "package_unavailable"
        case .purchaseCancelled:
            error = nil
            return
        case .purchaseFailed, .restoreFailed:
            error = L10n.tr("Subscription status is temporarily unavailable.")
            reason = "purchase_failed"
        }

        Analytics.shared.track(.purchase_failed, purchaseAnalytics(package: package, reason: reason))
        ErrorReporter.shared.breadcrumb(
            "RevenueCat purchase failed",
            category: "subscription",
            data: ["reason": reason, "product_id": package.storeProduct.productIdentifier]
        )
    }

    private func applyRestoreFailure(_ serviceError: SubscriptionServiceError) {
        let reason: String
        switch serviceError {
        case .notConfigured:
            isConfigured = false
            restoreMessage = L10n.tr("Subscriptions are not available in this environment.")
            error = nil
            reason = "unconfigured"
        case .restoreFailed:
            restoreMessage = nil
            error = L10n.tr("Subscription status is temporarily unavailable.")
            reason = "restore_failed"
        case .packageUnavailable, .purchaseCancelled, .purchaseFailed:
            restoreMessage = nil
            error = L10n.tr("Subscription status is temporarily unavailable.")
            reason = "unexpected_restore_error"
        }

        Analytics.shared.track(.restore_failed, ["reason": reason])
        ErrorReporter.shared.breadcrumb(
            "RevenueCat restore failed",
            category: "subscription",
            data: ["reason": reason]
        )
    }
}
