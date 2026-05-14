import Foundation

struct SubscriptionCustomerSnapshot: Equatable {
    let isPro: Bool
}

enum SubscriptionServiceError: Error, Equatable {
    case notConfigured
}

@MainActor
protocol SubscriptionService {
    var isConfigured: Bool { get }

    func customerInfo() async throws -> SubscriptionCustomerSnapshot
    func offerings() async throws -> SubscriptionOffering?
}
