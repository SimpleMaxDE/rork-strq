import SwiftUI

/// Lightweight in-memory cache for remote exercise GIFs/images.
/// Stores decoded animated or static `UIImage` instances ready for playback
/// via `AnimatedGIFView`. GIF frame arrays are expensive to re-decode, so
/// we cache the decoded form rather than raw data.
@MainActor
final class RemoteExerciseImageCache {
    static let shared = RemoteExerciseImageCache()

    private let cache: NSCache<NSURL, CachedEntry> = {
        let c = NSCache<NSURL, CachedEntry>()
        c.countLimit = 120
        c.totalCostLimit = 48 * 1024 * 1024
        return c
    }()

    final class CachedEntry {
        let image: UIImage
        let isAnimated: Bool
        let byteCount: Int
        init(image: UIImage, isAnimated: Bool, byteCount: Int) {
            self.image = image
            self.isAnimated = isAnimated
            self.byteCount = byteCount
        }
    }

    private var inflight: [URL: Task<CachedEntry?, Never>] = [:]

    func entry(for url: URL) -> CachedEntry? {
        cache.object(forKey: url as NSURL)
    }

    func load(_ url: URL) async -> CachedEntry? {
        if let cached = cache.object(forKey: url as NSURL) { return cached }
        if let task = inflight[url] { return await task.value }
        let task = Task<CachedEntry?, Never> { [weak self] in
            defer { Task { @MainActor in self?.inflight[url] = nil } }
            var request = URLRequest(url: url)
            request.cachePolicy = .returnCacheDataElseLoad
            request.timeoutInterval = 15
            guard let (data, response) = try? await URLSession.shared.data(for: request) else { return nil }
            if let http = response as? HTTPURLResponse, !(200...299).contains(http.statusCode) { return nil }
            guard !data.isEmpty, let decoded = RemoteGIFDecoder.decode(data) else { return nil }
            let entry = CachedEntry(image: decoded.image, isAnimated: decoded.isAnimated, byteCount: decoded.byteCount)
            await MainActor.run {
                self?.cache.setObject(entry, forKey: url as NSURL, cost: decoded.byteCount)
            }
            return entry
        }
        inflight[url] = task
        return await task.value
    }
}

/// Renders a remote exercise image, animating GIFs natively via ImageIO
/// decode + UIImageView playback. Use inside a sized container with `.overlay`
/// per layout rules.
struct RemoteExerciseImage: View {
    let url: URL?
    var contentMode: ContentMode = .fill
    var fallback: AnyView? = nil

    @State private var entry: RemoteExerciseImageCache.CachedEntry?
    @State private var failed: Bool = false

    var body: some View {
        Group {
            if let entry {
                if entry.isAnimated {
                    AnimatedGIFView(image: entry.image, contentMode: uiContentMode)
                        .transition(.opacity)
                } else {
                    Image(uiImage: entry.image)
                        .resizable()
                        .aspectRatio(contentMode: contentMode)
                        .transition(.opacity)
                }
            } else if failed {
                fallbackContent
            } else if url != nil {
                ZStack {
                    Color(.tertiarySystemBackground)
                    ProgressView().controlSize(.small)
                }
            } else {
                fallbackContent
            }
        }
        .task(id: url) {
            guard let url else { failed = true; return }
            if let cached = RemoteExerciseImageCache.shared.entry(for: url) {
                self.entry = cached
                return
            }
            if let loaded = await RemoteExerciseImageCache.shared.load(url) {
                withAnimation(.easeOut(duration: 0.25)) { self.entry = loaded }
            } else {
                self.failed = true
            }
        }
    }

    private var uiContentMode: UIView.ContentMode {
        contentMode == .fill ? .scaleAspectFill : .scaleAspectFit
    }

    private var fallbackContent: some View {
        Group {
            if let fallback {
                fallback
            } else {
                ZStack {
                    Color(.secondarySystemBackground)
                    Image(systemName: "figure.strengthtraining.traditional")
                        .font(.system(size: 36, weight: .thin))
                        .foregroundStyle(.tertiary)
                }
            }
        }
    }
}
