import SwiftUI
import RevenueCat

@main
struct STRQApp: App {
    @Environment(\.scenePhase) private var scenePhase
    @State private var isFirstLaunch: Bool = !UserDefaults.standard.bool(forKey: "strq_has_launched_before")
    @State private var vm = AppViewModel()
    @State private var store = StoreViewModel()

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
            ErrorReporter.shared.breadcrumb("RevenueCat not configured", category: "subscription")
            return
        }

        #if DEBUG
        Purchases.logLevel = .debug
        #endif
        Purchases.configure(withAPIKey: apiKey)
        ErrorReporter.shared.breadcrumb("RevenueCat configured", category: "subscription")
    }

    var body: some Scene {
        WindowGroup {
            ContentView(vm: vm, store: store)
                .onAppear {
                    Analytics.shared.appOpened(isFirstLaunch: isFirstLaunch)
                    if isFirstLaunch {
                        UserDefaults.standard.set(true, forKey: "strq_has_launched_before")
                        isFirstLaunch = false
                    }
                }
        }
        .onChange(of: scenePhase) { _, phase in
            switch phase {
            case .active:
                Analytics.shared.track(.app_became_active)
                vm.rescheduleSmartReminders()
            case .background, .inactive:
                if vm.activeWorkout != nil {
                    vm.saveActiveWorkoutDraft()
                    ErrorReporter.shared.breadcrumb("Active workout draft saved on background", category: "training")
                }
            @unknown default:
                break
            }
        }
    }
}
