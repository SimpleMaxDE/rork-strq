import SwiftUI
import Foundation

struct STRQSuccessPulse: View {
    var size: CGFloat = 54
    var color: Color = STRQPalette.success
    var icon: String = "checkmark"
    var trigger: Int = 0

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var pulsed: Bool = false

    var body: some View {
        ZStack {
            Circle()
                .fill(color.opacity(0.14))

            Circle()
                .stroke(color.opacity(pulsed ? 0 : 0.44), lineWidth: 2)
                .scaleEffect(pulsed ? 1.35 : 0.86)

            Circle()
                .strokeBorder(color.opacity(0.24), lineWidth: 1)

            Image(systemName: icon)
                .font(.system(size: size * 0.34, weight: .bold))
                .foregroundStyle(color)
                .scaleEffect(pulsed && !reduceMotion ? 1.04 : 1.0)
        }
        .frame(width: size, height: size)
        .onAppear(perform: runPulse)
        .onChange(of: trigger) { _, _ in runPulse() }
    }

    private func runPulse() {
        pulsed = false
        guard !reduceMotion else {
            pulsed = true
            return
        }
        withAnimation(.spring(response: 0.42, dampingFraction: 0.72)) {
            pulsed = true
        }
    }
}

struct STRQPulseMark<Content: View>: View {
    enum EnergyLine: Equatable {
        case none
        case horizontal
        case vertical
    }

    var size: CGFloat = 64
    var tint: Color = STRQBrand.steel
    var line: EnergyLine = .none
    var ringOpacityMultiplier: Double = 1
    var lineOpacityMultiplier: Double = 1
    var trigger: Int = 0
    let content: Content

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var pulse: Bool = false

    init(
        size: CGFloat = 64,
        tint: Color = STRQBrand.steel,
        line: EnergyLine = .none,
        ringOpacityMultiplier: Double = 1,
        lineOpacityMultiplier: Double = 1,
        trigger: Int = 0,
        @ViewBuilder content: () -> Content
    ) {
        self.size = size
        self.tint = tint
        self.line = line
        self.ringOpacityMultiplier = ringOpacityMultiplier
        self.lineOpacityMultiplier = lineOpacityMultiplier
        self.trigger = trigger
        self.content = content()
    }

    var body: some View {
        ZStack {
            energyLine
            ringStack
                .opacity(ringOpacityMultiplier)

            content
                .frame(width: size * 0.72, height: size * 0.58)
        }
        .frame(width: frameWidth, height: frameHeight)
        .onAppear(perform: runPulse)
        .onChange(of: trigger) { _, _ in runPulse() }
    }

    private var frameWidth: CGFloat {
        line == .horizontal ? size * 2.1 : size
    }

    private var frameHeight: CGFloat {
        line == .vertical ? size * 2.1 : size
    }

    @ViewBuilder
    private var energyLine: some View {
        switch line {
        case .horizontal:
            Capsule()
                .fill(lineGradient(start: .leading, end: .trailing))
                .frame(width: size * 2.05, height: 1)
                .overlay(
                    Capsule()
                        .fill(tint.opacity(0.10))
                        .frame(height: 5)
                        .blur(radius: 4)
                )
                .opacity(lineOpacityMultiplier)
        case .vertical:
            Capsule()
                .fill(lineGradient(start: .top, end: .bottom))
                .frame(width: 1, height: size * 2.05)
                .overlay(
                    Capsule()
                        .fill(tint.opacity(0.10))
                        .frame(width: 5)
                        .blur(radius: 4)
                )
                .opacity(lineOpacityMultiplier)
        case .none:
            EmptyView()
        }
    }

    private var ringStack: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [tint.opacity(0.12), Color.white.opacity(0.025), Color.clear],
                        center: .center,
                        startRadius: 1,
                        endRadius: size * 0.62
                    )
                )

            Circle()
                .stroke(tint.opacity(reduceMotion ? 0.14 : (pulse ? 0 : 0.24)), lineWidth: 1.2)
                .scaleEffect(reduceMotion ? 1.06 : (pulse ? 1.24 : 0.84))

            Circle()
                .stroke(
                    AngularGradient(
                        colors: [
                            Color.white.opacity(0.04),
                            tint.opacity(0.44),
                            Color.white.opacity(0.18),
                            tint.opacity(0.12),
                            Color.white.opacity(0.04)
                        ],
                        center: .center
                    ),
                    lineWidth: 1.1
                )

            Circle()
                .strokeBorder(Color.white.opacity(0.10), lineWidth: 0.8)
        }
        .frame(width: size, height: size)
    }

    private func lineGradient(start: UnitPoint, end: UnitPoint) -> LinearGradient {
        LinearGradient(
            colors: [
                Color.clear,
                tint.opacity(0.12),
                Color.white.opacity(0.48),
                tint.opacity(0.12),
                Color.clear
            ],
            startPoint: start,
            endPoint: end
        )
    }

    private func runPulse() {
        pulse = false
        guard !reduceMotion else {
            pulse = true
            return
        }
        withAnimation(.easeOut(duration: 1.1)) {
            pulse = true
        }
    }
}

extension STRQPulseMark where Content == EmptyView {
    init(
        size: CGFloat = 64,
        tint: Color = STRQBrand.steel,
        line: EnergyLine = .none,
        ringOpacityMultiplier: Double = 1,
        lineOpacityMultiplier: Double = 1,
        trigger: Int = 0
    ) {
        self.init(
            size: size,
            tint: tint,
            line: line,
            ringOpacityMultiplier: ringOpacityMultiplier,
            lineOpacityMultiplier: lineOpacityMultiplier,
            trigger: trigger
        ) {
            EmptyView()
        }
    }
}

struct STRQCountUpText: View {
    let value: Double
    var duration: Double = 0.55
    var steps: Int = 18
    let formatter: (Double) -> String

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var displayedValue: Double = 0
    @State private var task: Task<Void, Never>?

    init(
        value: Double,
        duration: Double = 0.55,
        steps: Int = 18,
        formatter: @escaping (Double) -> String = { String(format: "%.0f", $0) }
    ) {
        self.value = value
        self.duration = duration
        self.steps = steps
        self.formatter = formatter
    }

    var body: some View {
        Text(formatter(displayedValue))
            .contentTransition(.numericText())
            .onAppear {
                animate(from: reduceMotion ? value : 0, to: value)
            }
            .onChange(of: value) { _, newValue in
                animate(from: displayedValue, to: newValue)
            }
            .onDisappear {
                task?.cancel()
            }
    }

    private func animate(from start: Double, to end: Double) {
        task?.cancel()
        guard !reduceMotion, steps > 0, duration > 0 else {
            displayedValue = end
            return
        }

        displayedValue = start
        task = Task { @MainActor in
            let sleepNanos = UInt64(max(0.01, duration / Double(steps)) * 1_000_000_000)
            for step in 1...steps {
                if Task.isCancelled { return }
                try? await Task.sleep(nanoseconds: sleepNanos)
                if Task.isCancelled { return }
                let progress = Double(step) / Double(steps)
                let eased = 1 - pow(1 - progress, 3)
                displayedValue = start + (end - start) * eased
            }
            displayedValue = end
        }
    }
}

struct STRQCelebrationBadge: View {
    enum Variant {
        case gold
        case green
        case steel

        var tint: Color {
            switch self {
            case .gold: return STRQPalette.gold
            case .green: return STRQPalette.success
            case .steel: return STRQBrand.steel
            }
        }

        var soft: Color {
            switch self {
            case .gold: return STRQPalette.goldSoft
            case .green: return STRQPalette.successSoft
            case .steel: return STRQBrand.steel.opacity(0.14)
            }
        }
    }

    let title: String
    var subtitle: String?
    var icon: String = "sparkles"
    var variant: Variant = .steel

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(variant.tint)

            VStack(alignment: .leading, spacing: 1) {
                Text(title.uppercased())
                    .font(.system(size: 10, weight: .black))
                    .tracking(0.8)
                    .foregroundStyle(variant.tint)
                if let subtitle {
                    Text(subtitle)
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, subtitle == nil ? 6 : 7)
        .background(variant.soft, in: Capsule())
        .overlay(
            Capsule()
                .strokeBorder(variant.tint.opacity(0.24), lineWidth: 0.7)
        )
    }
}

struct STRQRewardMoment: Identifiable, Equatable {
    enum Style {
        case success
        case gold
        case calm
        case steel

        var tint: Color {
            switch self {
            case .success: return STRQPalette.success
            case .gold: return STRQPalette.gold
            case .calm: return STRQPalette.steel
            case .steel: return STRQBrand.steel
            }
        }

        var icon: String {
            switch self {
            case .success: return "checkmark.circle.fill"
            case .gold: return "trophy.fill"
            case .calm: return "heart.circle.fill"
            case .steel: return "bolt.fill"
            }
        }
    }

    let id = UUID()
    let title: String
    let subtitle: String?
    let style: Style

    init(title: String, subtitle: String? = nil, style: Style = .success) {
        self.title = title
        self.subtitle = subtitle
        self.style = style
    }

    static func == (lhs: STRQRewardMoment, rhs: STRQRewardMoment) -> Bool {
        lhs.id == rhs.id
    }
}

struct STRQRewardToast: View {
    let moment: STRQRewardMoment

    var body: some View {
        HStack(spacing: 12) {
            STRQSuccessPulse(size: 34, color: moment.style.tint, icon: moment.style.icon)

            VStack(alignment: .leading, spacing: 2) {
                Text(moment.title)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(.white)
                if let subtitle = moment.subtitle {
                    Text(subtitle)
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(.white.opacity(0.64))
                        .lineLimit(1)
                }
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 13)
        .padding(.vertical, 11)
        .background(
            LinearGradient(
                colors: [Color(white: 0.14), Color(white: 0.10)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            in: .rect(cornerRadius: 16)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(moment.style.tint.opacity(0.20), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.34), radius: 16, y: 8)
    }
}

struct STRQRewardToastHost: ViewModifier {
    @Binding var moment: STRQRewardMoment?
    var duration: Double = 2.0
    var topPadding: CGFloat = 10

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var task: Task<Void, Never>?

    func body(content: Content) -> some View {
        content
            .overlay(alignment: .top) {
                if let moment {
                    STRQRewardToast(moment: moment)
                        .padding(.horizontal, 16)
                        .padding(.top, topPadding)
                        .transition(
                            .asymmetric(
                                insertion: .move(edge: .top).combined(with: .opacity),
                                removal: .opacity
                            )
                        )
                        .zIndex(1000)
                }
            }
            .animation(reduceMotion ? .easeOut(duration: 0.12) : .spring(response: 0.42, dampingFraction: 0.82), value: moment)
            .onChange(of: moment) { _, newValue in
                task?.cancel()
                guard newValue != nil else { return }
                task = Task { @MainActor in
                    try? await Task.sleep(nanoseconds: UInt64(duration * 1_000_000_000))
                    if !Task.isCancelled {
                        moment = nil
                    }
                }
            }
    }
}

extension View {
    func strqRewardToast(_ moment: Binding<STRQRewardMoment?>, duration: Double = 2.0, topPadding: CGFloat = 10) -> some View {
        modifier(STRQRewardToastHost(moment: moment, duration: duration, topPadding: topPadding))
    }
}
