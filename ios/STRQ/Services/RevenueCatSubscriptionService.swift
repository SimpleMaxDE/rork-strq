import Foundation
import RevenueCat

struct RevenueCatSubscriptionService: SubscriptionService {
    static let proEntitlementIdentifier = "pro"
    static let defaultOfferingIdentifier = "default"
    static let monthlyProductIdentifier = "com.strq.pro.monthly"
    static let yearlyProductIdentifier = "com.strq.pro.yearly"

    nonisolated static var isSDKConfigured: Bool {
        Purchases.isConfigured
    }

    var isConfigured: Bool {
        Self.isSDKConfigured
    }

    func customerInfo() async throws -> SubscriptionCustomerSnapshot {
        guard Self.isSDKConfigured else {
            throw SubscriptionServiceError.notConfigured
        }

        let customerInfo = try await Purchases.shared.customerInfo()
        let isPro = customerInfo.entitlements[Self.proEntitlementIdentifier]?.isActive == true
        return SubscriptionCustomerSnapshot(isPro: isPro)
    }

    func offerings() async throws -> SubscriptionOffering? {
        guard Self.isSDKConfigured else {
            throw SubscriptionServiceError.notConfigured
        }

        let offerings = try await Purchases.shared.offerings()
        guard let offering = offerings.offering(identifier: Self.defaultOfferingIdentifier) ?? offerings.current else {
            return nil
        }
        return Self.mapOffering(offering)
    }

    private static func mapOffering(_ offering: Offering) -> SubscriptionOffering {
        SubscriptionOffering(availablePackages: offering.availablePackages.map(mapPackage))
    }

    private static func mapPackage(_ package: Package) -> SubscriptionPackage {
        SubscriptionPackage(
            identifier: package.identifier,
            storeProduct: mapProduct(package.storeProduct)
        )
    }

    private static func mapProduct(_ product: StoreProduct) -> SubscriptionProduct {
        SubscriptionProduct(
            productIdentifier: product.productIdentifier,
            localizedPriceString: product.localizedPriceString,
            price: product.priceDecimalNumber,
            priceFormatter: product.priceFormatter,
            currencyCode: product.currencyCode,
            introductoryDiscount: mapIntroductoryDiscount(product.introductoryDiscount)
        )
    }

    private static func mapIntroductoryDiscount(_ discount: StoreProductDiscount?) -> SubscriptionIntroductoryDiscount? {
        guard let discount,
              let unit = mapUnit(discount.subscriptionPeriod.unit) else {
            return nil
        }

        return SubscriptionIntroductoryDiscount(
            subscriptionPeriod: SubscriptionPeriod(unit: unit, value: discount.subscriptionPeriod.value)
        )
    }

    private static func mapUnit(_ unit: RevenueCat.SubscriptionPeriod.Unit) -> SubscriptionPeriod.Unit? {
        switch unit {
        case .day:
            return .day
        case .week:
            return .week
        case .month:
            return .month
        case .year:
            return .year
        @unknown default:
            return nil
        }
    }
}
