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
        error = L10n.tr("Subscriptions are not available in this environment.")
        Analytics.shared.track(.purchase_failed, ["reason": "unconfigured"])
    }

    var productsUnavailable: Bool {
        fetchedOffering?.availablePackages.isEmpty ?? true
    }

    func restore() async {
        restoreMessage = L10n.tr("Subscriptions are not available in this environment.")
        Analytics.shared.track(.restore_failed, ["reason": "unconfigured"])
    }

    var subscriptionStatusText: String {
        isPro ? L10n.tr("Active") : L10n.tr("Free")
    }

    var subscriptionPlanName: String {
        isPro ? L10n.tr("Pro") : L10n.tr("Free")
    }

    var currentOffering: SubscriptionOffering? {
        // Slice B fetches products for readiness only. Keep the paywall preview-only.
        nil
    }

    var annualPackage: SubscriptionPackage? {
        // Live package cards wait for the separate purchase/restore integration slice.
        nil
    }

    var monthlyPackage: SubscriptionPackage? {
        // Live package cards wait for the separate purchase/restore integration slice.
        nil
    }
}
