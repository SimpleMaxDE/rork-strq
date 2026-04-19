import Foundation
#if canImport(WatchConnectivity)
import WatchConnectivity
#endif

extension Notification.Name {
    static let watchWorkoutAction = Notification.Name("STRQ.watchWorkoutAction")
}

@MainActor
final class WatchConnectivityService: NSObject {
    static let shared = WatchConnectivityService()

    weak var vm: AppViewModel?

    private override init() {
        super.init()
    }

    func activate() {
        #if canImport(WatchConnectivity)
        guard WCSession.isSupported() else { return }
        let session = WCSession.default
        session.delegate = self
        if session.activationState != .activated {
            session.activate()
        }
        #endif
    }

    func pushActiveWorkoutState() {
        #if canImport(WatchConnectivity)
        guard WCSession.isSupported() else { return }
        let session = WCSession.default
        guard session.activationState == .activated, session.isWatchAppInstalled else { return }
        let context = buildContext()
        do {
            try session.updateApplicationContext(context)
        } catch {
            ErrorReporter.shared.reportMessage("WatchConnectivity updateContext failed: \(error.localizedDescription)", level: .warning)
        }
        #endif
    }

    func pushCleared() {
        #if canImport(WatchConnectivity)
        guard WCSession.isSupported() else { return }
        let session = WCSession.default
        guard session.activationState == .activated, session.isWatchAppInstalled else { return }
        try? session.updateApplicationContext(["isActive": false, "stamp": Date().timeIntervalSince1970])
        #endif
    }

    private func buildContext() -> [String: Any] {
        guard let vm, let workout = vm.activeWorkout else {
            return ["isActive": false, "stamp": Date().timeIntervalSince1970]
        }
        let logs = workout.session.exerciseLogs
        guard !logs.isEmpty else { return ["isActive": false, "stamp": Date().timeIntervalSince1970] }
        let idx = min(workout.currentExerciseIndex, logs.count - 1)
        let log = logs[idx]
        let exerciseName = vm.library.exercise(byId: log.exerciseId)?.name ?? log.exerciseId
        let completedInCurrent = log.sets.filter(\.isCompleted).count
        let setNumber = min(log.sets.count, completedInCurrent + 1)
        let activeSet = log.sets.first(where: { !$0.isCompleted }) ?? log.sets.last
        let weight = activeSet?.weight ?? 0
        let reps = activeSet?.reps ?? 0
        let nextIdx = idx + 1
        let nextName: String? = nextIdx < logs.count
            ? (vm.library.exercise(byId: logs[nextIdx].exerciseId)?.name ?? logs[nextIdx].exerciseId)
            : nil
        let allDone = logs.allSatisfy(\.isCompleted)

        var dict: [String: Any] = [
            "isActive": true,
            "dayName": workout.session.dayName,
            "exerciseName": exerciseName,
            "exerciseIndex": idx,
            "totalExercises": logs.count,
            "setNumber": setNumber,
            "totalSets": log.sets.count,
            "weight": weight,
            "reps": reps,
            "startedAt": workout.session.startTime.timeIntervalSince1970,
            "isCompleted": allDone,
            "stamp": Date().timeIntervalSince1970
        ]
        if let nextName { dict["nextExerciseName"] = nextName }
        return dict
    }

    @MainActor
    fileprivate func handleIncomingAction(_ message: [String: Any]) {
        guard let action = message["action"] as? String else { return }
        NotificationCenter.default.post(name: .watchWorkoutAction, object: nil, userInfo: ["action": action, "payload": message])
    }
}

#if canImport(WatchConnectivity)
extension WatchConnectivityService: WCSessionDelegate {
    nonisolated func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        Task { @MainActor in self.pushActiveWorkoutState() }
    }

    nonisolated func sessionDidBecomeInactive(_ session: WCSession) {}

    nonisolated func sessionDidDeactivate(_ session: WCSession) {
        Task { @MainActor in WCSession.default.activate() }
    }

    nonisolated func sessionWatchStateDidChange(_ session: WCSession) {
        Task { @MainActor in self.pushActiveWorkoutState() }
    }

    nonisolated func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        Task { @MainActor in self.handleIncomingAction(message) }
    }

    nonisolated func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        Task { @MainActor in
            self.handleIncomingAction(message)
            replyHandler(["ok": true])
        }
    }

    nonisolated func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any] = [:]) {
        Task { @MainActor in self.handleIncomingAction(userInfo) }
    }
}
#endif
