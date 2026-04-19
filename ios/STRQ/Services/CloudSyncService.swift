import Foundation
import Observation

nonisolated enum CloudSyncStatus: Sendable, Equatable {
    case idle
    case syncing
    case success(Date)
    case failed(String)
    case unavailable
}

@Observable
@MainActor
final class CloudSyncService {
    static let shared = CloudSyncService()

    private let snapshotKey = "strq_state_snapshot_v1"
    private let snapshotTimestampKey = "strq_state_snapshot_ts_v1"
    private let lastLocalSyncKey = "strq_last_cloud_sync_v1"
    private let maxPayloadBytes = 900_000

    private(set) var status: CloudSyncStatus = .idle
    private(set) var lastSyncDate: Date?
    private(set) var hasRemoteSnapshot: Bool = false

    private let store = NSUbiquitousKeyValueStore.default
    private var onRemoteChange: (() -> Void)?

    init() {
        if let ts = UserDefaults.standard.object(forKey: lastLocalSyncKey) as? Date {
            self.lastSyncDate = ts
        }
        refreshRemoteAvailability()
        store.synchronize()
        NotificationCenter.default.addObserver(
            forName: NSUbiquitousKeyValueStore.didChangeExternallyNotification,
            object: store,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                guard let self else { return }
                self.refreshRemoteAvailability()
                self.onRemoteChange?()
            }
        }
    }

    func setRemoteChangeHandler(_ handler: @escaping () -> Void) {
        self.onRemoteChange = handler
    }

    var isAvailable: Bool {
        FileManager.default.ubiquityIdentityToken != nil
    }

    func upload(_ state: PersistedAppState, isSignedIn: Bool) {
        guard isSignedIn else {
            status = .idle
            return
        }
        guard isAvailable else {
            status = .unavailable
            return
        }
        status = .syncing
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let data = try encoder.encode(state)
            guard data.count <= maxPayloadBytes else {
                status = .failed("Snapshot too large to sync")
                Analytics.shared.track(.cloud_sync_failed, ["reason": "too_large"])
                return
            }
            let now = Date()
            store.set(data, forKey: snapshotKey)
            store.set(now.timeIntervalSince1970, forKey: snapshotTimestampKey)
            store.synchronize()
            lastSyncDate = now
            UserDefaults.standard.set(now, forKey: lastLocalSyncKey)
            hasRemoteSnapshot = true
            status = .success(now)
            Analytics.shared.track(.cloud_sync_uploaded)
        } catch {
            status = .failed(error.localizedDescription)
            Analytics.shared.track(.cloud_sync_failed, ["reason": "encode"])
            ErrorReporter.shared.breadcrumb("Cloud upload failed: \(error.localizedDescription)", category: "sync")
        }
    }

    enum RemoteSnapshotLoad {
        case success(state: PersistedAppState, timestamp: Date)
        case empty
        case decodeFailed
        case unavailable
    }

    func loadRemoteSnapshot() -> (state: PersistedAppState, timestamp: Date)? {
        if case .success(let state, let timestamp) = loadRemoteSnapshotResult() {
            return (state, timestamp)
        }
        return nil
    }

    func loadRemoteSnapshotResult() -> RemoteSnapshotLoad {
        guard isAvailable else { return .unavailable }
        store.synchronize()
        guard let data = store.data(forKey: snapshotKey) else { return .empty }
        let ts = store.double(forKey: snapshotTimestampKey)
        let timestamp = ts > 0 ? Date(timeIntervalSince1970: ts) : Date()
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let state = try decoder.decode(PersistedAppState.self, from: data)
            return .success(state: state, timestamp: timestamp)
        } catch {
            ErrorReporter.shared.breadcrumb("Cloud decode failed: \(error.localizedDescription)", category: "sync")
            Analytics.shared.track(.cloud_sync_failed, ["reason": "decode"])
            return .decodeFailed
        }
    }

    func clearRemote() {
        store.removeObject(forKey: snapshotKey)
        store.removeObject(forKey: snapshotTimestampKey)
        store.synchronize()
        hasRemoteSnapshot = false
        lastSyncDate = nil
        UserDefaults.standard.removeObject(forKey: lastLocalSyncKey)
        status = .idle
    }

    private func refreshRemoteAvailability() {
        hasRemoteSnapshot = store.data(forKey: snapshotKey) != nil
    }

    var lastSyncText: String? {
        guard let date = lastSyncDate else { return nil }
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}
