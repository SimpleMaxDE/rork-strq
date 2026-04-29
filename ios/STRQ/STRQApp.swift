import SwiftUI
import RevenueCat

@main
struct STRQApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @Environment(\.scenePhase) private var scenePhase
    @State private var isFirstLaunch: Bool = !UserDefaults.standard.bool(forKey: "strq_has_launched_before")
    @State private var vm = AppViewModel()
    @State private var store = StoreViewModel()

    init() {
        STRQFontRegistrar.registerBundledFonts()

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
        EnvironmentValidator.validateAndLog()
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
                    WatchConnectivityService.shared.vm = vm
                    WatchConnectivityService.shared.activate()
                }
                .onReceive(NotificationCenter.default.publisher(for: .watchWorkoutAction)) { note in
                    guard let info = note.userInfo, let action = info["action"] as? String else { return }
                    vm.handleWatchAction(action, payload: info["payload"] as? [String: Any] ?? [:])
                }
        }
        .onChange(of: scenePhase) { _, phase in
            switch phase {
            case .active:
                Analytics.shared.track(.app_became_active)
                vm.rescheduleSmartReminders()
                vm.account.refreshCredentialState()
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
