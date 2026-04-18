import Foundation
#if canImport(WidgetKit)
import WidgetKit
#endif

nonisolated enum WidgetBridge {
    static let appGroup = "group.app.rork.40gfu7dywfru7n82xfoy4"
    static let snapshotKey = "strq_widget_snapshot_v1"

    nonisolated struct Snapshot: Codable, Sendable {
        var todayWorkoutName: String?
        var todayFocus: String?
        var isRestDay: Bool
        var hasCheckedIn: Bool
        var readinessScore: Int
        var readinessLabel: String
        var nextActionTitle: String
        var streak: Int
        var weeklyCompleted: Int
        var weeklyTarget: Int
        var updatedAt: Date

        static let placeholder = Snapshot(
            todayWorkoutName: "Upper Strength",
            todayFocus: "Chest & Back",
            isRestDay: false,
            hasCheckedIn: false,
            readinessScore: 78,
            readinessLabel: "Well Prepared",
            nextActionTitle: "Ready to train",
            streak: 4,
            weeklyCompleted: 2,
            weeklyTarget: 4,
            updatedAt: Date()
        )
    }

    static func write(_ snapshot: Snapshot) {
        guard let defaults = UserDefaults(suiteName: appGroup) else { return }
        if let data = try? JSONEncoder().encode(snapshot) {
            defaults.set(data, forKey: snapshotKey)
        }
        #if canImport(WidgetKit)
        WidgetCenter.shared.reloadAllTimelines()
        #endif
    }

    static func read() -> Snapshot? {
        guard let defaults = UserDefaults(suiteName: appGroup),
              let data = defaults.data(forKey: snapshotKey),
              let decoded = try? JSONDecoder().decode(Snapshot.self, from: data) else {
            return nil
        }
        return decoded
    }
}
