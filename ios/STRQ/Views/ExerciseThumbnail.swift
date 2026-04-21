import SwiftUI

/// Premium, reusable exercise thumbnail used across Library, Add, Swap, Detail rails,
/// and the Active Workout context. Uses Color + overlay layout pattern so remote GIFs
/// never overflow grid/list layouts. Falls back to a gradient + SF Symbol tile when
/// no remote media is available — keeping the catalog visually consistent.
struct ExerciseThumbnail: View {
    let exercise: Exercise
    var size: Size = .medium
    var cornerRadius: CGFloat = 10

    enum Size {
        case mini
        case small
        case medium
        case large

        var side: CGFloat {
            switch self {
            case .mini: return 32
            case .small: return 44
            case .medium: return 56
            case .large: return 72
            }
        }

        var symbolSize: CGFloat {
            switch self {
            case .mini: return 14
            case .small: return 18
            case .medium: return 22
            case .large: return 28
            }
        }
    }

    private let mediaProvider = ExerciseMediaProvider.shared

    private var gradient: [Color] { mediaProvider.heroGradient(for: exercise) }
    private var symbol: String { mediaProvider.heroSymbol(for: exercise) }
    private var remoteURL: URL? { mediaProvider.remoteGifURL(for: exercise) }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [gradient[0], gradient[1]],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            if let url = remoteURL {
                RemoteExerciseImage(
                    url: url,
                    contentMode: .fill,
                    fallback: AnyView(fallbackSymbol),
                    trimWhitespace: true
                )
                .blendMode(.luminosity)
                .opacity(0.92)
            } else {
                fallbackSymbol
            }
            LinearGradient(
                colors: [Color.black.opacity(0.25), Color.clear, Color.black.opacity(0.18)],
                startPoint: .top,
                endPoint: .bottom
            )
            .blendMode(.multiply)
        }
        .frame(width: size.side, height: size.side)
        .clipShape(.rect(cornerRadius: cornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius)
                .strokeBorder(Color.white.opacity(0.06), lineWidth: 0.5)
        )
        .allowsHitTesting(false)
    }

    private var fallbackSymbol: some View {
        Image(systemName: symbol)
            .font(.system(size: size.symbolSize, weight: .thin))
            .foregroundStyle(.white.opacity(0.92))
            .shadow(color: .black.opacity(0.2), radius: 3, y: 1)
    }
}

/// Wider rectangular preview used in cards/hero slots (e.g. Active Workout preview).
struct ExerciseMediaPreview: View {
    let exercise: Exercise
    var height: CGFloat = 72
    var cornerRadius: CGFloat = 10
    var overlayTint: Double = 0.0

    private let mediaProvider = ExerciseMediaProvider.shared
    private var gradient: [Color] { mediaProvider.heroGradient(for: exercise) }
    private var symbol: String { mediaProvider.heroSymbol(for: exercise) }
    private var remoteURL: URL? { mediaProvider.remoteGifURL(for: exercise) }

    var body: some View {
        Color.black
            .frame(height: height)
            .overlay {
                ZStack {
                    LinearGradient(
                        colors: [gradient[0], gradient[1]],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    if let url = remoteURL {
                        RemoteExerciseImage(
                            url: url,
                            contentMode: .fill,
                            fallback: AnyView(symbolFallback),
                            trimWhitespace: true
                        )
                        .blendMode(.luminosity)
                        .opacity(0.9)
                    } else {
                        symbolFallback
                    }
                    LinearGradient(
                        colors: [Color.black.opacity(0.35), Color.clear, Color.black.opacity(0.25)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .blendMode(.multiply)
                    if overlayTint > 0 {
                        Color.black.opacity(overlayTint)
                    }
                }
                .allowsHitTesting(false)
            }
            .clipShape(.rect(cornerRadius: cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .strokeBorder(Color.white.opacity(0.08), lineWidth: 0.5)
            )
    }

    private var symbolFallback: some View {
        Image(systemName: symbol)
            .font(.system(size: 26, weight: .thin))
            .foregroundStyle(.white.opacity(0.88))
    }
}
