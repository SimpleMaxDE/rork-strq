import SwiftUI

@main
struct STRQApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @Environment(\.scenePhase) private var scenePhase
    @State private var isFirstLaunch: Bool = !UserDefaults.standard.bool(forKey: "strq_has_launched_before")
    @State private var vm = AppViewModel()
    @State private var store: StoreViewModel

    init() {
        STRQFontRegistrar.registerBundledFonts()
        RevenueCatConfiguration.configureIfPossible()
        EnvironmentValidator.validateAndLog()
        _store = State(initialValue: Self.makeStore())
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

    private static func makeStore() -> StoreViewModel {
        #if DEBUG
        if let fixtureStore = STRQSubscriptionFixture.makeStoreIfRequested() {
            return fixtureStore
        }
        #endif
        return StoreViewModel()
    }
}
