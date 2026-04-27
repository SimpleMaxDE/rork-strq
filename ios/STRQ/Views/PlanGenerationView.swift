import SwiftUI

struct PlanGenerationView: View {
    let profile: UserProfile
    let onComplete: () -> Void

    @State private var phase: Int = 0
    @State private var appeared: Bool = false
    @State private var progress: CGFloat = 0

    private let steps: [(icon: String, text: String)] = [
        ("person.text.rectangle", L10n.tr("Analyzing your profile")),
        ("figure.strengthtraining.traditional", L10n.tr("Selecting exercises")),
        ("chart.bar.fill", L10n.tr("Calibrating volume")),
        ("arrow.left.arrow.right", L10n.tr("Balancing muscle groups")),
        ("brain.head.profile.fill", L10n.tr("Applying coach intelligence")),
        ("sparkles", L10n.tr("Finalizing your plan")),
    ]

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            MeshGradient(width: 3, height: 3, points: [
                [0, 0], [0.5, 0], [1, 0],
                [0, 0.5], [0.6, 0.4], [1, 0.5],
                [0, 1], [0.5, 1], [1, 1]
            ], colors: [
                .black, .black, .black,
                .black, Color.white.opacity(0.04), .black,
                .black, Color.white.opacity(0.02), .black
            ])
            .ignoresSafeArea()

            VStack(spacing: 40) {
                Spacer()

                pulsingIcon

                VStack(spacing: 10) {
                    Text(L10n.tr("Building Your Plan"))
                        .font(.title2.bold())
                    Text(L10n.format("Personalizing for %@", profile.name.isEmpty ? L10n.tr("you") : profile.name))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 12)

                progressSection

                profileSummary

                Spacer()
            }
            .padding(.horizontal, 24)
        }
        .preferredColorScheme(.dark)
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) { appeared = true }
            startSequence()
        }
    }

    private var pulsingIcon: some View {
        ZStack {
            Circle()
                .fill(Color.white.opacity(0.04))
                .frame(width: 140, height: 140)
                .blur(radius: 30)
                .scaleEffect(appeared ? 1.2 : 0.8)
                .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: appeared)

            Circle()
                .fill(Color.white.opacity(0.06))
                .frame(width: 90, height: 90)
                .blur(radius: 15)

            STRQLogoView(size: 56, animated: true)
        }
        .opacity(appeared ? 1 : 0)
        .scaleEffect(appeared ? 1 : 0.6)
        .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.1), value: appeared)
    }

    private var progressSection: some View {
        VStack(spacing: 16) {
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.white.opacity(0.06))
                    Capsule()
                        .fill(STRQBrand.accentGradient)
                        .frame(width: max(0, geo.size.width * progress))
                        .animation(.easeInOut(duration: 0.6), value: progress)
                }
            }
            .frame(height: 4)

            HStack(spacing: 8) {
                Image(systemName: steps[min(phase, steps.count - 1)].icon)
                    .font(.caption)
                    .foregroundStyle(STRQBrand.steel)
                Text(steps[min(phase, steps.count - 1)].text)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Spacer()
            }
            .contentTransition(.numericText())
            .animation(.easeInOut(duration: 0.3), value: phase)
        }
        .opacity(appeared ? 1 : 0)
        .animation(.easeOut(duration: 0.5).delay(0.3), value: appeared)
    }

    private var profileSummary: some View {
        VStack(spacing: 10) {
            HStack(spacing: 20) {
                summaryItem(label: L10n.tr("Goal"), value: profile.goal.displayName)
                summaryItem(label: L10n.tr("Level"), value: profile.trainingLevel.shortName)
                summaryItem(label: L10n.tr("Days"), value: "\(profile.daysPerWeek)/wk")
            }
            HStack(spacing: 20) {
                summaryItem(label: L10n.tr("Workout"), value: "\(profile.minutesPerSession) min")
                summaryItem(label: L10n.tr("Location"), value: profile.trainingLocation.displayName)
                if !profile.focusMuscles.isEmpty {
                    summaryItem(label: L10n.tr("Focus"), value: L10n.format("%d muscles", profile.focusMuscles.count))
                }
            }
        }
        .padding(18)
        .background(Color.white.opacity(0.03), in: .rect(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(Color.white.opacity(0.05), lineWidth: 1)
        )
        .opacity(appeared ? 1 : 0)
        .animation(.easeOut(duration: 0.5).delay(0.5), value: appeared)
    }

    private func summaryItem(label: String, value: String) -> some View {
        VStack(spacing: 3) {
            Text(label)
                .font(.system(size: 9, weight: .medium))
                .foregroundStyle(.white.opacity(0.35))
                .textCase(.uppercase)
                .tracking(0.3)
            Text(value)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.white.opacity(0.8))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity)
    }

    private func startSequence() {
        let stepDuration: TimeInterval = 0.6

        for i in 0..<steps.count {
            let delay = TimeInterval(i) * stepDuration
            Task { @MainActor in
                try? await Task.sleep(for: .milliseconds(Int(delay * 1000)))
                withAnimation(.spring(response: 0.4)) {
                    phase = i
                    progress = CGFloat(i + 1) / CGFloat(steps.count)
                }
            }
        }

        let totalDelay = TimeInterval(steps.count) * stepDuration + 0.5
        Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(Int(totalDelay * 1000)))
            onComplete()
        }
    }
}
