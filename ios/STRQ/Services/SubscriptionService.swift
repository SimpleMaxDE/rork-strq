import Foundation

struct SubscriptionCustomerSnapshot: Equatable {
    let isPro: Bool
}

struct SubscriptionPurchaseResult: Equatable {
    let snapshot: SubscriptionCustomerSnapshot
    let userCancelled: Bool
}

enum SubscriptionServiceError: Error, Equatable {
    case notConfigured
    case packageUnavailable
    case purchaseCancelled
    case purchaseFailed
    case restoreFailed
}

@MainActor
protocol SubscriptionService {
    var isConfigured: Bool { get }

    func customerInfo() async throws -> SubscriptionCustomerSnapshot
    func offerings() async throws -> SubscriptionOffering?
    func purchase(package: SubscriptionPackage) async throws -> SubscriptionPurchaseResult
    func restorePurchases() async throws -> SubscriptionCustomerSnapshot
}
