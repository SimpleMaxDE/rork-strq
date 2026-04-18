import Foundation
import ActivityKit

@MainActor
final class WorkoutLiveActivityManager {
    static let shared = WorkoutLiveActivityManager()

    private var currentActivity: Activity<WorkoutActivityAttributes>?

    private init() {
        reattachExisting()
    }

    private func reattachExisting() {
        currentActivity = Activity<WorkoutActivityAttributes>.activities.first
    }

    var isAvailable: Bool {
        ActivityAuthorizationInfo().areActivitiesEnabled
    }

    func start(state: WorkoutActivityAttributes.ContentState, workoutId: String) {
        guard isAvailable else { return }
        if let existing = currentActivity {
            Task { await existing.end(nil, dismissalPolicy: .immediate) }
            currentActivity = nil
        }
        let attributes = WorkoutActivityAttributes(workoutId: workoutId)
        let content = ActivityContent(state: state, staleDate: Date().addingTimeInterval(60 * 60 * 4))
        do {
            currentActivity = try Activity.request(attributes: attributes, content: content, pushType: nil)
        } catch {
            ErrorReporter.shared.reportMessage("LiveActivity start failed: \(error.localizedDescription)", level: .warning)
        }
    }

    func update(state: WorkoutActivityAttributes.ContentState) {
        guard let activity = currentActivity else { return }
        let content = ActivityContent(state: state, staleDate: Date().addingTimeInterval(60 * 60 * 4))
        Task { await activity.update(content) }
    }

    func end(finalState: WorkoutActivityAttributes.ContentState? = nil, immediate: Bool = true) {
        guard let activity = currentActivity else { return }
        currentActivity = nil
        let policy: ActivityUIDismissalPolicy = immediate ? .immediate : .default
        if let finalState {
            let content = ActivityContent(state: finalState, staleDate: nil)
            Task { await activity.end(content, dismissalPolicy: policy) }
        } else {
            Task { await activity.end(nil, dismissalPolicy: policy) }
        }
    }
}
