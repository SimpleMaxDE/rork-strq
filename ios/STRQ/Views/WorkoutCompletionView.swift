import SwiftUI

struct WorkoutCompletionView: View {
    let vm: AppViewModel
    let session: WorkoutSession?
    let onDismiss: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var appeared: Bool = false
    @State private var trophyPulse: Bool = false
    @State private var highlightsAppeared: Bool = false
    @State private var sparkTrigger: Int = 0
    @State private var hapticTick: Int = 0
    @State private var celebrationTrigger: Bool = false

    private var highlights: [WorkoutHighlight] {
        guard let session else { return [] }
        return WorkoutHighlightBuilder.build(
            session: session,
            history: vm.workoutHistory,
            streak: vm.streak,
            exerciseName: { id in vm.library.exercise(byId: id)?.name ?? "Exercise" }
        )
    }

    private var hasPR: Bool {
        highlights.contains { $0.kind == .personalRecord }
    }

    var body: some View {
        ZStack {
            backgroundLayer

            if !reduceMotion {
                SparkField(trigger: sparkTrigger, intensity: hasPR ? 1.0 : 0.6)
                    .ignoresSafeArea()
                    .allowsHitTesting(false)
            }

            ScrollView {
                VStack(spacing: 28) {
                    Spacer(minLength: 32)
                    heroSection
                    statsSection
                    highlightsSection
                    Color.clear.frame(height: 100)
                }
            }
            .scrollIndicators(.hidden)

            VStack {
                Spacer()
                bottomActions
            }
        }
        .preferredColorScheme(.dark)
        .sensoryFeedback(.success, trigger: celebrationTrigger)
        .sensoryFeedback(.impact(flexibility: .soft, intensity: 0.6), trigger: hapticTick)
        .onAppear(perform: onFirstAppear)
    }

    // MARK: - Layers

    private var backgroundLayer: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            RadialGradient(
                colors: [
                    (hasPR ? STRQPalette.gold.opacity(0.18) : Color.white.opacity(0.08)),
                    Color.clear
                ],
                center: .top,
                startRadius: 10,
                endRadius: 520
            )
            .ignoresSafeArea()
            RadialGradient(
                colors: [Color.white.opacity(0.04), Color.clear],
                center: .bottom,
                startRadius: 10,
                endRadius: 360
            )
            .ignoresSafeArea()
        }
    }

    // MARK: - Hero

    private var heroSection: some View {
        VStack(spacing: 22) {
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.04))
                    .frame(width: 148, height: 148)
                Circle()
                    .strokeBorder(Color.white.opacity(0.08), lineWidth: 1)
                    .frame(width: 148, height: 148)
                Circle()
                    .fill(
                        RadialGradient(
                            colors: hasPR
                                ? [STRQPalette.gold.opacity(0.32), Color.clear]
                                : [STRQPalette.success.opacity(0.22), Color.clear],
                            center: .center,
                            startRadius: 4,
                            endRadius: 80
                        )
                    )
                    .frame(width: 148, height: 148)

                Image(systemName: hasPR ? "trophy.fill" : "checkmark.seal.fill")
                    .font(.system(size: 56, weight: .semibold))
                    .foregroundStyle(hasPR ? AnyShapeStyle(STRQPalette.goldGradient) : AnyShapeStyle(STRQPalette.success.gradient))
                    .scaleEffect(trophyPulse ? 1.04 : 1.0)
                    .animation(reduceMotion ? nil : .easeInOut(duration: 1.6).repeatForever(autoreverses: true), value: trophyPulse)
            }
            .scaleEffect(appeared ? 1 : 0.7)
            .opacity(appeared ? 1 : 0)
            .animation(reduceMotion ? .easeOut(duration: 0.2) : .spring(response: 0.55, dampingFraction: 0.7), value: appeared)

            VStack(spacing: 8) {
                Text(hasPR ? "NEW PERSONAL RECORD" : "COMPLETE")
                    .font(.system(size: 11, weight: .black))
                    .foregroundStyle(hasPR ? STRQPalette.gold : STRQPalette.success)
                    .tracking(3)
                Text("Session Logged")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundStyle(.white)
                if let day = session?.dayName, !day.isEmpty {
                    Text(day)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(.white.opacity(0.55))
                }
            }
            .multilineTextAlignment(.center)
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 10)
            .animation(.easeOut(duration: 0.5).delay(0.15), value: appeared)
        }
    }

    // MARK: - Stats

    @ViewBuilder
    private var statsSection: some View {
        if let session {
            let duration = session.endTime.map { Int($0.timeIntervalSince(session.startTime) / 60) } ?? 0
            let totalSets = session.exerciseLogs.flatMap(\.sets).filter(\.isCompleted).count
            let totalReps = session.exerciseLogs.flatMap(\.sets).filter(\.isCompleted).reduce(0) { $0 + $1.reps }
            let completedExercises = session.exerciseLogs.filter(\.isCompleted).count

            VStack(spacing: 12) {
                HStack(spacing: 10) {
                    completionStat("Duration", value: "\(duration)", unit: "min")
                    completionStat("Exercises", value: "\(completedExercises)", unit: nil)
                    completionStat("Sets", value: "\(totalSets)", unit: nil)
                    completionStat("Reps", value: "\(totalReps)", unit: nil)
                }

                if session.totalVolume > 0 {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("TOTAL VOLUME")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundStyle(.white.opacity(0.42))
                                .tracking(1.2)
                            Text(String(format: "%.0f kg", session.totalVolume))
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .foregroundStyle(.white)
                        }
                        Spacer()
                        Image(systemName: "chart.bar.fill")
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundStyle(STRQBrand.steel.opacity(0.6))
                    }
                    .padding(.horizontal, 18)
                    .padding(.vertical, 18)
                    .background(Color.white.opacity(0.04), in: .rect(cornerRadius: 16))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .strokeBorder(Color.white.opacity(0.05), lineWidth: 1)
                    )
                }
            }
            .padding(.horizontal, 20)
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 12)
            .animation(.easeOut(duration: 0.5).delay(0.3), value: appeared)
        }
    }

    // MARK: - Highlights

    @ViewBuilder
    private var highlightsSection: some View {
        if !highlights.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 8) {
                    Text("HIGHLIGHTS")
                        .font(.system(size: 11, weight: .black))
                        .tracking(1.4)
                        .foregroundStyle(.white.opacity(0.55))
                    Spacer()
                    Text("\(highlights.count)")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(.white.opacity(0.35))
                }
                .padding(.horizontal, 4)

                VStack(spacing: 8) {
                    ForEach(Array(highlights.enumerated()), id: \.element.id) { idx, h in
                        HighlightRow(highlight: h)
                            .opacity(highlightsAppeared ? 1 : 0)
                            .offset(y: highlightsAppeared ? 0 : 14)
                            .animation(
                                reduceMotion
                                    ? .easeOut(duration: 0.2)
                                    : .spring(response: 0.5, dampingFraction: 0.82).delay(0.5 + Double(idx) * 0.08),
                                value: highlightsAppeared
                            )
                    }
                }
            }
            .padding(.horizontal, 20)
        }
    }

    // MARK: - Bottom actions

    private var bottomActions: some View {
        VStack(spacing: 0) {
            LinearGradient(colors: [Color.black.opacity(0), Color.black], startPoint: .top, endPoint: .bottom)
                .frame(height: 40)
            VStack(spacing: 10) {
                Button { onDismiss() } label: {
                    Text("Done")
                        .font(.body.weight(.bold))
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(STRQBrand.accentGradient, in: .rect(cornerRadius: 18))
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 28)
            .background(Color.black)
        }
        .opacity(appeared ? 1 : 0)
        .animation(.easeOut(duration: 0.5).delay(0.5), value: appeared)
    }

    // MARK: - Helpers

    private func completionStat(_ title: String, value: String, unit: String?) -> some View {
        VStack(spacing: 6) {
            HStack(alignment: .lastTextBaseline, spacing: 2) {
                Text(value)
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                if let unit {
                    Text(unit)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.4))
                }
            }
            Text(title.uppercased())
                .font(.system(size: 9, weight: .bold))
                .foregroundStyle(.white.opacity(0.4))
                .tracking(1.0)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color.white.opacity(0.04), in: .rect(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .strokeBorder(Color.white.opacity(0.05), lineWidth: 1)
        )
    }

    private func onFirstAppear() {
        withAnimation { appeared = true }
        trophyPulse = true
        celebrationTrigger.toggle()

        guard !reduceMotion else {
            highlightsAppeared = true
            return
        }

        // Sequential haptic pulses to sell the moment
        Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(120))
            sparkTrigger &+= 1
            try? await Task.sleep(for: .milliseconds(180))
            hapticTick &+= 1
            try? await Task.sleep(for: .milliseconds(200))
            highlightsAppeared = true
            if hasPR {
                try? await Task.sleep(for: .milliseconds(260))
                sparkTrigger &+= 1
                hapticTick &+= 1
            }
        }
    }
}

// MARK: - Highlight Row

private struct HighlightRow: View {
    let highlight: WorkoutHighlight

    private var palette: (color: Color, soft: Color, icon: String) {
        switch highlight.kind {
        case .personalRecord:
            return (STRQPalette.gold, STRQPalette.goldSoft, "trophy.fill")
        case .bestSet:
            return (STRQPalette.success, STRQPalette.successSoft, "bolt.fill")
        case .volumeUp:
            return (STRQPalette.success, STRQPalette.successSoft, "arrow.up.right.circle.fill")
        case .volumeDown:
            return (STRQPalette.warning, STRQPalette.warningSoft, "arrow.down.right.circle.fill")
        case .firstTime:
            return (STRQPalette.info, STRQPalette.infoSoft, "sparkles")
        case .longestSession:
            return (STRQPalette.gold, STRQPalette.goldSoft, "timer")
        case .streakMilestone:
            return (STRQPalette.gold, STRQPalette.goldSoft, "flame.fill")
        case .setsMilestone:
            return (STRQPalette.gold, STRQPalette.goldSoft, "checkmark.seal.fill")
        }
    }

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(palette.soft)
                    .frame(width: 40, height: 40)
                Image(systemName: palette.icon)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(palette.color)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(highlight.title)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(.white)
                if let subtitle = highlight.subtitle {
                    Text(subtitle)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(.white.opacity(0.5))
                        .lineLimit(1)
                }
            }

            Spacer(minLength: 8)

            VStack(alignment: .trailing, spacing: 2) {
                Text(highlight.valuePrimary)
                    .font(.system(size: 14, weight: .bold, design: .rounded).monospacedDigit())
                    .foregroundStyle(palette.color)
                if let secondary = highlight.valueSecondary {
                    Text(secondary)
                        .font(.system(size: 10, weight: .semibold).monospacedDigit())
                        .foregroundStyle(.white.opacity(0.4))
                }
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(Color.white.opacity(0.035), in: .rect(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .strokeBorder(palette.color.opacity(0.18), lineWidth: 0.7)
        )
    }
}

// MARK: - Particle Field

private struct SparkField: View {
    let trigger: Int
    let intensity: Double

    @State private var particles: [Particle] = []

    private struct Particle: Identifiable {
        let id = UUID()
        var x: CGFloat
        var y: CGFloat
        var vx: CGFloat
        var vy: CGFloat
        var size: CGFloat
        var life: Double
        var maxLife: Double
        var hue: Double
        var isGold: Bool
    }

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 60.0)) { context in
            Canvas { ctx, size in
                let now = context.date.timeIntervalSinceReferenceDate
                for p in particles {
                    let alpha = max(0, 1.0 - (now - p.life) / p.maxLife)
                    guard alpha > 0 else { continue }
                    let color: Color = p.isGold
                        ? STRQPalette.gold.opacity(alpha)
                        : Color.white.opacity(alpha * 0.85)
                    let rect = CGRect(x: p.x - p.size / 2, y: p.y - p.size / 2, width: p.size, height: p.size)
                    ctx.fill(Path(ellipseIn: rect), with: .color(color))
                    if p.isGold {
                        let glow = CGRect(x: p.x - p.size, y: p.y - p.size, width: p.size * 2, height: p.size * 2)
                        ctx.fill(Path(ellipseIn: glow), with: .color(STRQPalette.gold.opacity(alpha * 0.18)))
                    }
                }
            }
            .onChange(of: context.date) { _, date in
                step(at: date.timeIntervalSinceReferenceDate, size: UIScreen.main.bounds.size)
            }
        }
        .onChange(of: trigger) { _, _ in
            burst(at: UIScreen.main.bounds.size)
        }
    }

    private func burst(at size: CGSize) {
        let count = Int(Double(70) * intensity)
        let now = Date().timeIntervalSinceReferenceDate
        let originX = size.width / 2
        let originY = size.height * 0.28
        var new: [Particle] = []
        for _ in 0..<count {
            let angle = Double.random(in: 0...(2 * .pi))
            let speed = CGFloat.random(in: 90...260)
            let isGold = Double.random(in: 0...1) < 0.55
            new.append(Particle(
                x: originX,
                y: originY,
                vx: CGFloat(cos(angle)) * speed,
                vy: CGFloat(sin(angle)) * speed - CGFloat.random(in: 20...80),
                size: CGFloat.random(in: 2.0...4.5),
                life: now,
                maxLife: Double.random(in: 0.8...1.6),
                hue: 0,
                isGold: isGold
            ))
        }
        particles.append(contentsOf: new)
    }

    private func step(at now: TimeInterval, size: CGSize) {
        guard !particles.isEmpty else { return }
        let dt: CGFloat = 1.0 / 60.0
        var next: [Particle] = []
        next.reserveCapacity(particles.count)
        for var p in particles {
            let age = now - p.life
            if age > p.maxLife { continue }
            p.vy += 260 * dt
            p.vx *= 0.985
            p.x += p.vx * dt
            p.y += p.vy * dt
            next.append(p)
        }
        particles = next
    }
}
