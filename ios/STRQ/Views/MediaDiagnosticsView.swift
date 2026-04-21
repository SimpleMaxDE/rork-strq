import SwiftUI

/// Internal-only end-to-end media pipeline diagnostics. Verifies:
/// 1. `exercises2.json` is in the app bundle and parses
/// 2. URL resolution works for known canonical lifts (direct → bridge → nil)
/// 3. A raw remote GIF fetch returns animated bytes and decodes
/// 4. The real render path (RemoteExerciseImage) displays correctly
///
/// Reached from Profile via a long-press on the app version string.
struct MediaDiagnosticsView: View {
    @State private var bundleReport: BundleReport = .init()
    @State private var urlReport: [URLReport] = []
    @State private var smokeReport: SmokeReport = .init()
    @State private var smokeTask: Task<Void, Never>?

    private let targetLifts: [String] = [
        "barbell-bench-press",
        "overhead-press",
        "dumbbell-shoulder-press",
        "cable-pullover"
    ]

    var body: some View {
        List {
            Section("1. Bundle / JSON") {
                row("exercises2.json in bundle", value: bundleReport.bundleFound ? "yes" : "NO", ok: bundleReport.bundleFound)
                row("parsed exercises", value: "\(bundleReport.parsedCount)", ok: bundleReport.parsedCount > 0)
                row("with gifUrl", value: "\(bundleReport.withGif)", ok: bundleReport.withGif > 0)
                if let sample = bundleReport.sampleURL {
                    Text(sample).font(.caption2.monospaced()).foregroundStyle(.secondary)
                }
            }

            Section("2. URL resolution") {
                ForEach(urlReport, id: \.id) { r in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(r.name).font(.subheadline.weight(.semibold))
                        Text(r.id).font(.caption2.monospaced()).foregroundStyle(.tertiary)
                        HStack {
                            Text("direct:").font(.caption).foregroundStyle(.secondary)
                            Text(r.direct ?? "nil").font(.caption2.monospaced()).lineLimit(1).truncationMode(.middle)
                        }
                        HStack {
                            Text("bridge:").font(.caption).foregroundStyle(.secondary)
                            Text(r.bridge ?? "nil").font(.caption2.monospaced()).lineLimit(1).truncationMode(.middle)
                        }
                        HStack {
                            Text("final:").font(.caption).foregroundStyle(.secondary)
                            Text(r.final ?? "nil").font(.caption2.monospaced()).lineLimit(1).truncationMode(.middle)
                                .foregroundStyle(r.final == nil ? .red : .primary)
                        }
                        if let reason = r.bridgeReason {
                            Text("bridge reason: \(reason)").font(.caption2).foregroundStyle(.tertiary)
                        }
                    }
                    .padding(.vertical, 2)
                }
            }

            Section("3. Raw fetch smoke test") {
                row("url", value: smokeReport.urlString ?? "—", ok: smokeReport.urlString != nil)
                row("http status", value: smokeReport.status.map(String.init) ?? "—", ok: (smokeReport.status ?? 0) == 200)
                row("bytes", value: "\(smokeReport.bytes)", ok: smokeReport.bytes > 0)
                row("is GIF signature", value: smokeReport.isGIF ? "yes" : "no", ok: smokeReport.isGIF)
                row("decoded frames", value: "\(smokeReport.frameCount)", ok: smokeReport.frameCount > 0)
                if let err = smokeReport.error {
                    Text(err).font(.caption).foregroundStyle(.red)
                }
            }

            Section("4. Live render (real pipeline)") {
                ForEach(urlReport, id: \.id) { r in
                    HStack(spacing: 12) {
                        Color(.secondarySystemBackground)
                            .frame(width: 72, height: 72)
                            .overlay {
                                if let s = r.final, let url = URL(string: s) {
                                    RemoteExerciseImage(url: url, contentMode: .fit)
                                } else {
                                    Image(systemName: "xmark.octagon")
                                        .foregroundStyle(.red)
                                }
                            }
                            .clipShape(.rect(cornerRadius: 10))
                        VStack(alignment: .leading) {
                            Text(r.name).font(.subheadline.weight(.semibold))
                            Text(r.final == nil ? "no url → fallback" : "loading live")
                                .font(.caption).foregroundStyle(.secondary)
                        }
                    }
                }
            }

            Section("5. Direct URL smoke render") {
                if let s = smokeReport.urlString, let url = URL(string: s) {
                    Color(.secondarySystemBackground)
                        .frame(height: 220)
                        .overlay {
                            RemoteExerciseImage(url: url, contentMode: .fit)
                        }
                        .clipShape(.rect(cornerRadius: 12))
                        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                }
            }

            Section("Canonical coverage") {
                ForEach(CuratedImportedMediaBridge.shared.canonicalCoverageReport(), id: \.0) { pair in
                    HStack {
                        Image(systemName: pair.1 ? "checkmark.circle.fill" : "xmark.circle")
                            .foregroundStyle(pair.1 ? .green : .red)
                        Text(pair.0).font(.caption.monospaced())
                    }
                }
            }
        }
        .navigationTitle("Media Diagnostics")
        .navigationBarTitleDisplayMode(.inline)
        .task { runAudit() }
    }

    private func row(_ label: String, value: String, ok: Bool) -> some View {
        HStack {
            Image(systemName: ok ? "checkmark.circle.fill" : "xmark.circle")
                .foregroundStyle(ok ? .green : .red)
            Text(label)
            Spacer()
            Text(value).font(.caption.monospaced()).foregroundStyle(.secondary)
        }
    }

    private func runAudit() {
        // 1. Bundle
        var br = BundleReport()
        if let url = Bundle.main.url(forResource: "exercises2", withExtension: "json") {
            br.bundleFound = true
            if let data = try? Data(contentsOf: url),
               let raws = try? JSONDecoder().decode([ExerciseDBProRaw].self, from: data) {
                br.parsedCount = raws.count
                br.withGif = raws.filter { ($0.gifUrl ?? "").isEmpty == false }.count
                br.sampleURL = raws.first(where: { ($0.gifUrl ?? "").isEmpty == false })?.gifUrl
            }
        }
        // Fallback: check importer's own cached list in case bundle path differs
        if br.parsedCount == 0 {
            br.parsedCount = ExerciseDBProImporter.shared.exercises.count
        }
        self.bundleReport = br

        // 2. URL resolution
        let catalog = ExerciseCatalog.shared
        let provider = ExerciseMediaProvider.shared
        let bridge = CuratedImportedMediaBridge.shared
        self.urlReport = targetLifts.map { id in
            let ex = catalog.exercise(byId: id) ?? ExerciseLibrary.shared.exercise(byId: id)
            let name = ex?.name ?? id
            let direct = ex.flatMap { catalog.gifURL(for: $0) }?.absoluteString
            let bridgeURL = bridge.gifURL(forCuratedId: id)?.absoluteString
            let final = ex.flatMap { provider.remoteGifURL(for: $0) }?.absoluteString
            let diag = bridge.diagnostic(forCuratedId: id)
            return URLReport(
                id: id, name: name,
                direct: direct, bridge: bridgeURL, final: final,
                bridgeReason: diag?.reason
            )
        }

        // 3. Raw fetch smoke test — use first parsed raw URL so we prove the
        // entire pipeline from bundle → network → decode independently of
        // curated matching.
        smokeTask?.cancel()
        smokeTask = Task { await runSmokeTest() }
    }

    private func runSmokeTest() async {
        var sr = SmokeReport()
        guard let urlString = bundleReport.sampleURL ?? ExerciseDBProImporter.shared.exercises.first.flatMap({
            ExerciseDBProImporter.shared.remoteGifURL(for: String($0.id.dropFirst("edb-".count)))
        }),
              let url = URL(string: urlString) else {
            sr.error = "no sample URL found"
            await MainActor.run { self.smokeReport = sr }
            return
        }
        sr.urlString = urlString
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            if let http = response as? HTTPURLResponse {
                sr.status = http.statusCode
            }
            sr.bytes = data.count
            sr.isGIF = data.starts(with: [0x47, 0x49, 0x46]) // "GIF"
            if let decoded = RemoteGIFDecoder.decode(data) {
                sr.frameCount = decoded.image.images?.count ?? 1
            }
        } catch {
            sr.error = String(describing: error)
        }
        await MainActor.run { self.smokeReport = sr }
    }

    // MARK: - Reports

    private struct BundleReport {
        var bundleFound: Bool = false
        var parsedCount: Int = 0
        var withGif: Int = 0
        var sampleURL: String?
    }

    private struct URLReport {
        let id: String
        let name: String
        let direct: String?
        let bridge: String?
        let final: String?
        let bridgeReason: String?
    }

    private struct SmokeReport {
        var urlString: String?
        var status: Int?
        var bytes: Int = 0
        var isGIF: Bool = false
        var frameCount: Int = 0
        var error: String?
    }
}
