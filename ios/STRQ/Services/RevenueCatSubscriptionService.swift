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
        return Self.mapCustomerInfo(customerInfo)
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

    func purchase(package requestedPackage: SubscriptionPackage) async throws -> SubscriptionPurchaseResult {
        guard Self.isSDKConfigured else {
            throw SubscriptionServiceError.notConfigured
        }

        guard let package = try await revenueCatPackage(matching: requestedPackage) else {
            throw SubscriptionServiceError.packageUnavailable
        }

        do {
            let result = try await Purchases.shared.purchase(package: package)
            return SubscriptionPurchaseResult(
                snapshot: Self.mapCustomerInfo(result.customerInfo),
                userCancelled: result.userCancelled
            )
        } catch {
            if Self.isPurchaseCancellation(error) {
                throw SubscriptionServiceError.purchaseCancelled
            }
            throw SubscriptionServiceError.purchaseFailed
        }
    }

    func restorePurchases() async throws -> SubscriptionCustomerSnapshot {
        guard Self.isSDKConfigured else {
            throw SubscriptionServiceError.notConfigured
        }

        do {
            let customerInfo = try await Purchases.shared.restorePurchases()
            return Self.mapCustomerInfo(customerInfo)
        } catch {
            throw SubscriptionServiceError.restoreFailed
        }
    }

    private func revenueCatPackage(matching requestedPackage: SubscriptionPackage) async throws -> Package? {
        let offerings = try await Purchases.shared.offerings()
        let matchingOfferings = [
            offerings.offering(identifier: Self.defaultOfferingIdentifier),
            offerings.current
        ].compactMap { $0 }

        return matchingOfferings
            .flatMap(\.availablePackages)
            .first { package in
                package.identifier == requestedPackage.identifier
                    && package.storeProduct.productIdentifier == requestedPackage.storeProduct.productIdentifier
            }
    }

    private static func mapOffering(_ offering: Offering) -> SubscriptionOffering {
        SubscriptionOffering(availablePackages: offering.availablePackages.map(mapPackage))
    }

    private static func mapCustomerInfo(_ customerInfo: CustomerInfo) -> SubscriptionCustomerSnapshot {
        let isPro = customerInfo.entitlements[proEntitlementIdentifier]?.isActive == true
        return SubscriptionCustomerSnapshot(isPro: isPro)
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

    private static func isPurchaseCancellation(_ error: Error) -> Bool {
        let nsError = error as NSError
        return ErrorCode(rawValue: nsError.code) == .purchaseCancelledError
    }
}
