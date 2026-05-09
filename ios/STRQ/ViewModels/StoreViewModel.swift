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
            return id.contains("annual") || id.contains("year")
        }
    }

    var monthly: SubscriptionPackage? {
        availablePackages.first { package in
            package.identifier.lowercased().contains("month")
        }
    }
}

@Observable
@MainActor
class StoreViewModel {
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
        false
    }

    init() {
        isConfigured = Self.isRevenueCatConfigured
        if Self.hasRevenueCatKeys {
            ErrorReporter.shared.breadcrumb("RevenueCat keys present but SDK omitted from preview build", category: "subscription")
        }
    }

    func refreshStatus() async {
    }

    func fetchOfferings() async {
    }

    func purchase(package: SubscriptionPackage) async {
        error = L10n.tr("Subscriptions are not available in this environment.")
        Analytics.shared.track(.purchase_failed, ["reason": "unconfigured"])
    }

    var productsUnavailable: Bool {
        true
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
        nil
    }

    var annualPackage: SubscriptionPackage? {
        nil
    }

    var monthlyPackage: SubscriptionPackage? {
        nil
    }
}
