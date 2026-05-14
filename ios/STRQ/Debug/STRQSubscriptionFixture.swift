#if DEBUG
import Foundation

@MainActor
enum STRQSubscriptionFixture {
    static let purchaseMarkerPath = "/tmp/strq_d1_purchase_called"

    static func makeStoreIfRequested() -> StoreViewModel? {
        let args = ProcessInfo.processInfo.arguments
        guard let flagIndex = args.firstIndex(of: "-STRQSubscriptionFixture"),
              args.indices.contains(flagIndex + 1),
              args[flagIndex + 1] == "packagePreview" else {
            return nil
        }

        try? FileManager.default.removeItem(atPath: purchaseMarkerPath)
        return StoreViewModel(subscriptionService: PackagePreviewSubscriptionService(), autoRefresh: true)
    }
}

@MainActor
private final class PackagePreviewSubscriptionService: SubscriptionService {
    var isConfigured: Bool { true }

    func customerInfo() async throws -> SubscriptionCustomerSnapshot {
        SubscriptionCustomerSnapshot(isPro: false)
    }

    func offerings() async throws -> SubscriptionOffering? {
        SubscriptionOffering(
            availablePackages: [
                Self.package(
                    identifier: "$rc_annual",
                    productIdentifier: "com.strq.pro.yearly",
                    price: 59.99,
                    localizedPrice: "$59.99",
                    period: SubscriptionPeriod(unit: .year, value: 1),
                    intro: nil
                ),
                Self.package(
                    identifier: "$rc_monthly",
                    productIdentifier: "com.strq.pro.monthly",
                    price: 8.99,
                    localizedPrice: "$8.99",
                    period: SubscriptionPeriod(unit: .month, value: 1),
                    intro: SubscriptionIntroductoryDiscount(
                        localizedPriceString: "$0.00",
                        paymentMode: .freeTrial,
                        subscriptionPeriod: SubscriptionPeriod(unit: .day, value: 7)
                    )
                )
            ]
        )
    }

    func purchase(package: SubscriptionPackage) async throws -> SubscriptionPurchaseResult {
        FileManager.default.createFile(
            atPath: STRQSubscriptionFixture.purchaseMarkerPath,
            contents: Data(package.identifier.utf8)
        )
        return SubscriptionPurchaseResult(
            snapshot: SubscriptionCustomerSnapshot(isPro: false),
            userCancelled: false
        )
    }

    func restorePurchases() async throws -> SubscriptionCustomerSnapshot {
        SubscriptionCustomerSnapshot(isPro: false)
    }

    private static func package(
        identifier: String,
        productIdentifier: String,
        price: Double,
        localizedPrice: String,
        period: SubscriptionPeriod,
        intro: SubscriptionIntroductoryDiscount?
    ) -> SubscriptionPackage {
        SubscriptionPackage(
            identifier: identifier,
            storeProduct: SubscriptionProduct(
                productIdentifier: productIdentifier,
                localizedPriceString: localizedPrice,
                price: NSDecimalNumber(value: price),
                priceFormatter: usdFormatter,
                currencyCode: "USD",
                subscriptionPeriod: period,
                introductoryDiscount: intro
            )
        )
    }

    private static var usdFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "en_US")
        formatter.currencyCode = "USD"
        return formatter
    }
}
#endif
