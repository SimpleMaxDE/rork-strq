import Foundation
import RevenueCat

@MainActor
enum RevenueCatConfiguration {
    private static var hasRun = false

    static func configureIfPossible() {
        guard !hasRun else { return }
        hasRun = true

        guard let key = selectedSDKKey else {
            #if DEBUG
            print("[STRQ] RevenueCat SDK key not configured - SDK configuration skipped")
            #endif
            ErrorReporter.shared.breadcrumb("RevenueCat SDK configuration skipped: missing SDK key", category: "subscription")
            return
        }

        #if DEBUG
        Purchases.logLevel = .debug
        #endif

        Purchases.configure(withAPIKey: key.value)
        ErrorReporter.shared.breadcrumb(
            "RevenueCat SDK configured",
            category: "subscription",
            data: ["source": key.source]
        )
    }

    private static var selectedSDKKey: (value: String, source: String)? {
        #if DEBUG
        if let testKey = normalizedKey(Config.EXPO_PUBLIC_REVENUECAT_TEST_API_KEY) {
            return (testKey, "test")
        }
        if let iosKey = normalizedKey(Config.EXPO_PUBLIC_REVENUECAT_IOS_API_KEY) {
            return (iosKey, "ios")
        }
        return nil
        #else
        guard let iosKey = normalizedKey(Config.EXPO_PUBLIC_REVENUECAT_IOS_API_KEY) else {
            return nil
        }
        return (iosKey, "ios")
        #endif
    }

    private static func normalizedKey(_ key: String) -> String? {
        let trimmed = key.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
}
