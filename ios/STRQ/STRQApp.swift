import SwiftUI
import RevenueCat

@main
struct STRQApp: App {
    init() {
        let apiKey: String
        #if DEBUG
        apiKey = Config.EXPO_PUBLIC_REVENUECAT_TEST_API_KEY.isEmpty
            ? Config.EXPO_PUBLIC_REVENUECAT_IOS_API_KEY
            : Config.EXPO_PUBLIC_REVENUECAT_TEST_API_KEY
        #else
        apiKey = Config.EXPO_PUBLIC_REVENUECAT_IOS_API_KEY
        #endif

        guard !apiKey.isEmpty else {
            print("[STRQ] RevenueCat API key not configured — skipping initialization")
            return
        }

        #if DEBUG
        Purchases.logLevel = .debug
        #endif
        Purchases.configure(withAPIKey: apiKey)
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
