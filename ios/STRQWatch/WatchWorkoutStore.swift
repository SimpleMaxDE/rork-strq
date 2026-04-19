import Foundation
import SwiftUI
import WatchConnectivity

@Observable
@MainActor
final class WatchWorkoutStore: NSObject {
    var isActive: Bool = false
    var dayName: String = ""
    var exerciseName: String = ""
    var exerciseIndex: Int = 0
    var totalExercises: Int = 0
    var setNumber: Int = 1
    var totalSets: Int = 0
    var weight: Double = 0
    var reps: Int = 0
    var nextExerciseName: String?
    var startedAt: Date = Date()
    var isCompleted: Bool = false
    var restEndsAt: Date?
    var isReachable: Bool = false

    override init() {
        super.init()
        activate()
    }

    func activate() {
        guard WCSession.isSupported() else { return }
        let session = WCSession.default
        session.delegate = self
        if session.activationState != .activated {
            session.activate()
        }
        applyContext(session.receivedApplicationContext)
        isReachable = session.isReachable
    }

    fileprivate func applyContext(_ ctx: [String: Any]) {
        guard !ctx.isEmpty else { return }
        let active = (ctx["isActive"] as? Bool) ?? false
        isActive = active
        guard active else {
            isCompleted = (ctx["isCompleted"] as? Bool) ?? false
            return
        }
        dayName = (ctx["dayName"] as? String) ?? dayName
        exerciseName = (ctx["exerciseName"] as? String) ?? exerciseName
        exerciseIndex = (ctx["exerciseIndex"] as? Int) ?? exerciseIndex
        totalExercises = (ctx["totalExercises"] as? Int) ?? totalExercises
        setNumber = (ctx["setNumber"] as? Int) ?? setNumber
        totalSets = (ctx["totalSets"] as? Int) ?? totalSets
        weight = (ctx["weight"] as? Double) ?? weight
        reps = (ctx["reps"] as? Int) ?? reps
        nextExerciseName = ctx["nextExerciseName"] as? String
        if let ts = ctx["startedAt"] as? TimeInterval { startedAt = Date(timeIntervalSince1970: ts) }
        isCompleted = (ctx["isCompleted"] as? Bool) ?? false
    }

    // MARK: - Send Actions

    func sendCompleteSet() {
        send(["action": "completeSet", "weight": weight, "reps": reps])
    }

    func sendNextExercise() {
        send(["action": "nextExercise"])
    }

    func adjustWeight(_ delta: Double) {
        weight = max(0, weight + delta)
        send(["action": "adjustWeight", "delta": delta])
    }

    func adjustReps(_ delta: Int) {
        reps = max(0, reps + delta)
        send(["action": "adjustReps", "delta": delta])
    }

    func sendQuality(_ raw: String) {
        send(["action": "setQuality", "quality": raw])
    }

    private func send(_ payload: [String: Any]) {
        guard WCSession.isSupported() else { return }
        let session = WCSession.default
        guard session.activationState == .activated else { return }
        if session.isReachable {
            session.sendMessage(payload, replyHandler: nil, errorHandler: { _ in
                session.transferUserInfo(payload)
            })
        } else {
            session.transferUserInfo(payload)
        }
    }
}

extension WatchWorkoutStore: WCSessionDelegate {
    nonisolated func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        let ctx = session.receivedApplicationContext
        let reachable = session.isReachable
        Task { @MainActor in
            self.applyContext(ctx)
            self.isReachable = reachable
        }
    }

    nonisolated func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        Task { @MainActor in self.applyContext(applicationContext) }
    }

    nonisolated func sessionReachabilityDidChange(_ session: WCSession) {
        let reachable = session.isReachable
        Task { @MainActor in self.isReachable = reachable }
    }
}
