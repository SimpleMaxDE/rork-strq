import SwiftUI

/// Lightweight in-memory cache for remote exercise GIFs/images.
/// Images are decoded once and reused across views within a session.
@MainActor
final class RemoteExerciseImageCache {
    static let shared = RemoteExerciseImageCache()

    private let cache: NSCache<NSURL, UIImage> = {
        let c = NSCache<NSURL, UIImage>()
        c.countLimit = 120
        c.totalCostLimit = 32 * 1024 * 1024
        return c
    }()

    private var inflight: [URL: Task<UIImage?, Never>] = [:]

    func image(for url: URL) -> UIImage? {
        cache.object(forKey: url as NSURL)
    }

    func load(_ url: URL) async -> UIImage? {
        if let cached = cache.object(forKey: url as NSURL) { return cached }
        if let task = inflight[url] { return await task.value }
        let task = Task<UIImage?, Never> { [weak self] in
            defer { Task { @MainActor in self?.inflight[url] = nil } }
            var request = URLRequest(url: url)
            request.cachePolicy = .returnCacheDataElseLoad
            request.timeoutInterval = 15
            guard let (data, response) = try? await URLSession.shared.data(for: request) else { return nil }
            if let http = response as? HTTPURLResponse, !(200...299).contains(http.statusCode) { return nil }
            guard let img = UIImage(data: data) else { return nil }
            await MainActor.run {
                self?.cache.setObject(img, forKey: url as NSURL, cost: data.count)
            }
            return img
        }
        inflight[url] = task
        return await task.value
    }
}

/// Renders a remote exercise image (GIF first frame / static image) safely.
/// Use inside a sized container with `.overlay` per layout rules.
struct RemoteExerciseImage: View {
    let url: URL?
    var contentMode: ContentMode = .fill
    var fallback: AnyView? = nil

    @State private var image: UIImage?
    @State private var failed: Bool = false

    var body: some View {
        Group {
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: contentMode)
                    .transition(.opacity)
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
            if let cached = RemoteExerciseImageCache.shared.image(for: url) {
                self.image = cached
                return
            }
            if let loaded = await RemoteExerciseImageCache.shared.load(url) {
                withAnimation(.easeOut(duration: 0.25)) { self.image = loaded }
            } else {
                self.failed = true
            }
        }
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
