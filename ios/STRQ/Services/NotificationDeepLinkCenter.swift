import Observation

@Observable
@MainActor
final class NotificationDeepLinkCenter {
    static let shared = NotificationDeepLinkCenter()

    var pendingRoute: NotificationDeepLinkRoute?

    private init() {}

    func enqueue(_ route: NotificationDeepLinkRoute) {
        pendingRoute = route
    }

    func consume() -> NotificationDeepLinkRoute? {
        let route = pendingRoute
        pendingRoute = nil
        return route
    }
}
