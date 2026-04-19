import Foundation

/// Owns cloud restore / apply-snapshot decisions and persistence handoff.
/// Keeps snapshot-maturity guards and restore plumbing out of `AppViewModel`.
@MainActor
final class ContinuityCoordinator {
    private unowned let vm: AppViewModel
    private let persistence = PersistenceStore.shared
    private let cloudSync = CloudSyncService.shared

    init(vm: AppViewModel) {
        self.vm = vm
    }

    var isCloudAvailable: Bool { cloudSync.isAvailable }

    func save(snapshot: PersistedAppState) {
        persistence.save(snapshot)
    }

    func uploadIfSignedIn(_ snapshot: PersistedAppState) {
        if vm.account.isSignedIn {
            cloudSync.upload(snapshot, isSignedIn: true)
        }
    }

    func uploadNow() {
        guard vm.account.isSignedIn else { return }
        let snapshot = SnapshotBuilder.build(from: vm, version: persistence.version)
        cloudSync.upload(snapshot, isSignedIn: true)
    }

    @discardableResult
    func restore(force: Bool) -> CloudRestoreOutcome {
        guard cloudSync.isAvailable else { return .unavailable }
        // Never clobber an in-progress workout with a remote snapshot.
        if vm.activeWorkout != nil {
            ErrorReporter.shared.breadcrumb("Cloud restore skipped: active workout", category: "sync")
            return .staleIgnored
        }
        let result = cloudSync.loadRemoteSnapshotResult()
        switch result {
        case .unavailable: return .unavailable
        case .empty: return .noSnapshot
        case .decodeFailed: return .decodeFailed
        case .success(let state, _):
            let local = SnapshotBuilder.build(from: vm, version: persistence.version)
            let localScore = SnapshotBuilder.maturityScore(local)
            let remoteScore = SnapshotBuilder.maturityScore(state)
            if !force, localScore > remoteScore + 5 {
                Analytics.shared.track(.cloud_sync_failed, ["reason": "local_richer"])
                ErrorReporter.shared.breadcrumb(
                    "Cloud restore skipped: local richer (\(localScore) vs \(remoteScore))",
                    category: "sync"
                )
                return .staleIgnored
            }
            vm.apply(snapshot: state)
            Analytics.shared.track(.cloud_sync_restored)
            ErrorReporter.shared.breadcrumb("Cloud snapshot restored", category: "sync")
            return .restored
        }
    }
}
