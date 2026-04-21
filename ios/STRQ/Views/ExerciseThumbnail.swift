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
        Color(.secondarySystemGroupedBackground)
            .frame(width: size.side, height: size.side)
            .overlay {
                ZStack {
                    LinearGradient(
                        colors: [gradient[0].opacity(0.55), gradient[1].opacity(0.28)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    if let url = remoteURL {
                        RemoteExerciseImage(
                            url: url,
                            contentMode: .fit,
                            fallback: AnyView(fallbackSymbol)
                        )
                        .padding(size == .mini ? 2 : 4)
                    } else {
                        fallbackSymbol
                    }
                }
                .allowsHitTesting(false)
            }
            .clipShape(.rect(cornerRadius: cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .strokeBorder(Color.white.opacity(0.04), lineWidth: 0.5)
            )
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
        Color.black.opacity(0.25)
            .frame(height: height)
            .overlay {
                ZStack {
                    LinearGradient(
                        colors: [gradient[0].opacity(0.5), gradient[1].opacity(0.25)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    if let url = remoteURL {
                        RemoteExerciseImage(
                            url: url,
                            contentMode: .fit,
                            fallback: AnyView(symbolFallback)
                        )
                        .padding(6)
                    } else {
                        symbolFallback
                    }
                    if overlayTint > 0 {
                        Color.black.opacity(overlayTint)
                    }
                }
                .allowsHitTesting(false)
            }
            .clipShape(.rect(cornerRadius: cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .strokeBorder(Color.white.opacity(0.06), lineWidth: 0.5)
            )
    }

    private var symbolFallback: some View {
        Image(systemName: symbol)
            .font(.system(size: 26, weight: .thin))
            .foregroundStyle(.white.opacity(0.88))
    }
}
