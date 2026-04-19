import SwiftUI

@main
struct STRQWatchApp: App {
    @State private var store = WatchWorkoutStore()

    var body: some Scene {
        WindowGroup {
            ContentView(store: store)
        }
    }
}
