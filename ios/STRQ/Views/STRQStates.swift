import SwiftUI

struct STRQPremiumLoader: View {
    let message: String
    @State private var pulse: Bool = false

    var body: some View {
        VStack(spacing: 18) {
            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.06), lineWidth: 3)
                    .frame(width: 52, height: 52)
                Circle()
                    .trim(from: 0, to: 0.3)
                    .stroke(STRQBrand.steelGradient, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                    .frame(width: 52, height: 52)
                    .rotationEffect(.degrees(pulse ? 360 : 0))
                    .animation(.linear(duration: 1.1).repeatForever(autoreverses: false), value: pulse)
            }
            Text(message)
                .font(.caption.weight(.medium))
                .foregroundStyle(.secondary)
                .textCase(.uppercase)
                .tracking(0.6)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .onAppear { pulse = true }
    }
}

struct STRQEmptyState: View {
    let icon: String
    let title: String
    let message: String
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.04))
                    .frame(width: 64, height: 64)
                Image(systemName: icon)
                    .font(.system(size: 26, weight: .light))
                    .foregroundStyle(STRQBrand.steel)
            }
            VStack(spacing: 5) {
                Text(title)
                    .font(.subheadline.weight(.bold))
                Text(message)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            if let actionTitle, let action {
                Button(action: action) {
                    Text(actionTitle)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.black)
                        .padding(.horizontal, 18)
                        .padding(.vertical, 9)
                        .background(STRQBrand.accentGradient, in: Capsule())
                }
                .padding(.top, 2)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .padding(.horizontal, 24)
    }
}

enum STRQToastStyle {
    case applied
    case success
    case info
    case undo

    var icon: String {
        switch self {
        case .applied: return "checkmark.seal.fill"
        case .success: return "checkmark.circle.fill"
        case .info: return "bolt.fill"
        case .undo: return "arrow.uturn.backward.circle.fill"
        }
    }

    var tint: Color {
        switch self {
        case .applied: return .green
        case .success: return .green
        case .info: return STRQBrand.steel
        case .undo: return STRQBrand.slate
        }
    }
}

struct STRQToast: Identifiable, Equatable {
    let id: UUID
    let title: String
    let detail: String?
    let style: STRQToastStyle

    init(title: String, detail: String? = nil, style: STRQToastStyle = .success) {
        self.id = UUID()
        self.title = title
        self.detail = detail
        self.style = style
    }

    static func == (lhs: STRQToast, rhs: STRQToast) -> Bool { lhs.id == rhs.id }
}

struct STRQToastView: View {
    let toast: STRQToast

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: toast.style.icon)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(toast.style.tint)
                .frame(width: 30, height: 30)
                .background(toast.style.tint.opacity(0.15), in: .rect(cornerRadius: 9))

            VStack(alignment: .leading, spacing: 1) {
                Text(toast.title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)
                if let detail = toast.detail {
                    Text(detail)
                        .font(.caption2)
                        .foregroundStyle(.white.opacity(0.65))
                        .lineLimit(1)
                }
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(white: 0.11))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .strokeBorder(Color.white.opacity(0.10), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.35), radius: 14, y: 6)
        )
    }
}

struct STRQToastHost: ViewModifier {
    @Binding var toast: STRQToast?
    var duration: Double = 2.2

    @State private var task: Task<Void, Never>?

    func body(content: Content) -> some View {
        content
            .overlay(alignment: .top) {
                if let toast {
                    STRQToastView(toast: toast)
                        .padding(.horizontal, 16)
                        .padding(.top, 8)
                        .transition(
                            .asymmetric(
                                insertion: .move(edge: .top).combined(with: .opacity),
                                removal: .opacity
                            )
                        )
                        .zIndex(1000)
                }
            }
            .animation(.spring(response: 0.45, dampingFraction: 0.78), value: toast)
            .onChange(of: toast) { _, newValue in
                task?.cancel()
                guard newValue != nil else { return }
                task = Task { @MainActor in
                    try? await Task.sleep(for: .seconds(duration))
                    if !Task.isCancelled {
                        toast = nil
                    }
                }
            }
    }
}

extension View {
    func strqToast(_ toast: Binding<STRQToast?>, duration: Double = 2.2) -> some View {
        modifier(STRQToastHost(toast: toast, duration: duration))
    }
}

struct STRQAppliedPill: View {
    var label: String = "Applied"

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 10, weight: .semibold))
            Text(label)
                .font(.system(size: 10, weight: .bold))
        }
        .foregroundStyle(.green)
        .padding(.horizontal, 8)
        .padding(.vertical, 3)
        .background(.green.opacity(0.14), in: Capsule())
        .overlay(Capsule().strokeBorder(.green.opacity(0.2), lineWidth: 0.5))
    }
}
