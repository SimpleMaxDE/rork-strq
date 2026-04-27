import SwiftUI

struct ActivationRoadmapCard: View {
    let roadmap: ActivationRoadmap
    var compact: Bool = false
    @State private var isExpanded: Bool

    init(roadmap: ActivationRoadmap, compact: Bool = false) {
        self.roadmap = roadmap
        self.compact = compact
        _isExpanded = State(initialValue: !compact)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            if compact {
                Button {
                    withAnimation(.snappy(duration: 0.22)) {
                        isExpanded.toggle()
                    }
                } label: {
                    compactHeader
                }
                .buttonStyle(.plain)
            } else {
                header
            }

            if isExpanded {
                progressTrack

                VStack(spacing: 10) {
                    ForEach(Array(roadmap.steps.enumerated()), id: \.element.id) { index, step in
                        stepRow(step, isLast: index == roadmap.steps.count - 1)
                    }
                }
            } else {
                collapsedNextStep
            }
        }
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground), in: .rect(cornerRadius: 18))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .strokeBorder(Color.white.opacity(0.08), lineWidth: 1)
        )
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 6) {
                RoundedRectangle(cornerRadius: 2)
                    .fill(STRQBrand.accentGradient)
                    .frame(width: 3, height: 14)
                Text(L10n.tr("YOUR FIRST WEEK"))
                    .font(.system(size: 10, weight: .black))
                    .tracking(1.2)
                    .foregroundStyle(.primary)
                Spacer()
                Text("\(roadmap.completedCount)/\(roadmap.steps.count)")
                    .font(.system(size: 10, weight: .black).monospacedDigit())
                    .foregroundStyle(STRQBrand.steel)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(STRQBrand.steel.opacity(0.12), in: Capsule())
            }

            Text(roadmap.headline)
                .font(.subheadline.weight(.bold))
                .foregroundStyle(.primary)

            Text(roadmap.subhead)
                .font(.caption)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var compactHeader: some View {
        HStack(spacing: 10) {
            VStack(alignment: .leading, spacing: 4) {
                Text(L10n.tr("activationRoadmap.title", fallback: "Your first week"))
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(.primary)
                Text(L10n.format(
                    "activationRoadmap.progressDone",
                    fallback: "%d/%d done",
                    roadmap.completedCount,
                    roadmap.steps.count
                ))
                .font(.caption.weight(.semibold))
                .foregroundStyle(STRQBrand.steel)
            }

            Spacer(minLength: 0)

            Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                .font(.caption.weight(.bold))
                .foregroundStyle(.secondary)
        }
        .contentShape(.rect)
    }

    private var collapsedNextStep: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: nextStep.icon)
                .font(.caption.weight(.semibold))
                .foregroundStyle(STRQBrand.steel)
                .frame(width: 22, height: 22)
                .background(STRQBrand.steel.opacity(0.12), in: .rect(cornerRadius: 7))

            Text(nextStepLine)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.85)

            Spacer(minLength: 0)
        }
        .padding(.top, -4)
    }

    private var progressTrack: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.white.opacity(0.06))
                Capsule()
                    .fill(STRQBrand.accentGradient)
                    .frame(width: max(6, geo.size.width * roadmap.progress))
            }
        }
        .frame(height: 4)
    }

    private var nextStep: ActivationRoadmap.Step {
        roadmap.steps.first(where: { !$0.isComplete }) ?? roadmap.steps.last!
    }

    private var nextStepLine: String {
        if nextStep.isComplete {
            return L10n.tr("activationRoadmap.complete", fallback: "Week one is complete.")
        }
        return nextStep.title
    }

    private func stepRow(_ step: ActivationRoadmap.Step, isLast: Bool) -> some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(spacing: 0) {
                ZStack {
                    Circle()
                        .fill(step.isComplete
                              ? AnyShapeStyle(STRQPalette.successSoft)
                              : step.isActive
                                ? AnyShapeStyle(STRQBrand.steel.opacity(0.18))
                                : AnyShapeStyle(Color.white.opacity(0.05)))
                        .frame(width: 28, height: 28)
                    if step.isActive && !step.isComplete {
                        Circle()
                            .strokeBorder(STRQBrand.steel.opacity(0.55), lineWidth: 1.2)
                            .frame(width: 28, height: 28)
                    }
                    Image(systemName: step.isComplete ? "checkmark" : step.icon)
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(
                            step.isComplete
                                ? STRQPalette.success
                                : step.isActive
                                    ? STRQBrand.steel
                                    : Color.white.opacity(0.45)
                        )
                }
                if !isLast {
                    Rectangle()
                        .fill(Color.white.opacity(0.06))
                        .frame(width: 1)
                        .frame(maxHeight: .infinity)
                        .padding(.top, 2)
                }
            }
            .frame(width: 28)

            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 6) {
                    Text(step.title)
                        .font(.subheadline.weight(step.isActive ? .bold : .semibold))
                        .foregroundStyle(step.isComplete || step.isActive ? .primary : .secondary)
                    if step.isActive && !step.isComplete {
                        Text(L10n.tr("NEXT"))
                            .font(.system(size: 8, weight: .black))
                            .tracking(0.8)
                            .foregroundStyle(STRQBrand.steel)
                            .padding(.horizontal, 5)
                            .padding(.vertical, 2)
                            .background(STRQBrand.steel.opacity(0.12), in: Capsule())
                    }
                }
                Text(step.detail)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                HStack(spacing: 4) {
                    Image(systemName: step.isComplete ? "lock.open.fill" : "lock.fill")
                        .font(.system(size: 8, weight: .bold))
                    Text(step.learning)
                        .font(.caption2.weight(.semibold))
                }
                .foregroundStyle(step.isComplete ? STRQPalette.success : STRQBrand.steel.opacity(0.8))
                .padding(.top, 1)
            }
            .padding(.bottom, isLast ? 0 : 10)

            Spacer(minLength: 0)
        }
    }
}
