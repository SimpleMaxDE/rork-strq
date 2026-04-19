import SwiftUI

/// Hero verdict card that answers "am I on track?" in one glance.
///
/// Reads from `PhysiqueIntelligenceEngine` output (already computed on the
/// view-model) so Body Progress and Nutrition share a single source of truth.
struct PhysiqueVerdictCard: View {
    let vm: AppViewModel
    var compact: Bool = false

    var body: some View {
        let outcome = vm.physiqueOutcome
        let state = verdictState(for: outcome)
        let color = STRQPalette.color(for: state)

        VStack(alignment: .leading, spacing: 14) {
            header(state: state, color: color, outcome: outcome)
            headline(outcome: outcome, state: state)
            metricStrip(outcome: outcome, color: color)
            if !compact {
                confidenceFooter(outcome: outcome, color: color)
            }
        }
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground), in: .rect(cornerRadius: 18))
        .background(
            LinearGradient(
                colors: [color.opacity(0.10), color.opacity(0.0)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            in: .rect(cornerRadius: 18)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .strokeBorder(color.opacity(0.22), lineWidth: 0.5)
        )
    }

    // MARK: - Header

    private func header(state: STRQPalette.State, color: Color, outcome: PhysiqueOutcome?) -> some View {
        HStack(spacing: 8) {
            Image(systemName: verdictIcon(for: outcome))
                .font(.caption.weight(.bold))
                .foregroundStyle(color)
            Text(kickerLabel(for: outcome))
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(color)
                .tracking(0.8)
            Spacer()
            Text(vm.nutritionTarget.nutritionGoal.displayName.uppercased())
                .font(.system(size: 9, weight: .bold))
                .foregroundStyle(.secondary)
                .tracking(0.5)
                .padding(.horizontal, 7)
                .padding(.vertical, 3)
                .background(Color.white.opacity(0.06), in: Capsule())
        }
    }

    @ViewBuilder
    private func headline(outcome: PhysiqueOutcome?, state: STRQPalette.State) -> some View {
        let color = STRQPalette.color(for: state)
        VStack(alignment: .leading, spacing: 4) {
            Text(headlineText(for: outcome))
                .font(.title3.weight(.semibold))
                .foregroundStyle(.primary)
                .fixedSize(horizontal: false, vertical: true)
            if let detail = detailText(for: outcome) {
                Text(detail)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            if let bridge = bridgeText() {
                HStack(alignment: .top, spacing: 6) {
                    Image(systemName: "link")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(color)
                        .padding(.top, 3)
                    Text(bridge)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.top, 2)
            }
        }
    }

    // MARK: - Metric strip

    private func metricStrip(outcome: PhysiqueOutcome?, color: Color) -> some View {
        HStack(spacing: 0) {
            metricCell(
                label: "Trend",
                value: trendValue(outcome: outcome),
                tint: color
            )
            divider
            metricCell(
                label: "Target",
                value: String(format: "%+.2f", vm.nutritionTarget.targetWeeklyChangeKg) + " kg",
                tint: STRQBrand.steel
            )
            divider
            metricCell(
                label: "Protein",
                value: proteinValue(outcome: outcome),
                tint: proteinTint(outcome: outcome)
            )
            divider
            metricCell(
                label: "Recovery",
                value: "\(vm.effectiveRecoveryScore)",
                tint: STRQPalette.recovery(for: vm.effectiveRecoveryScore)
            )
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 4)
        .background(Color.black.opacity(0.18), in: .rect(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(Color.white.opacity(0.05), lineWidth: 0.5)
        )
    }

    private var divider: some View {
        Rectangle()
            .fill(Color.white.opacity(0.06))
            .frame(width: 0.5, height: 28)
    }

    private func metricCell(label: String, value: String, tint: Color) -> some View {
        VStack(spacing: 3) {
            Text(value)
                .font(.system(size: 13, weight: .bold, design: .rounded).monospacedDigit())
                .foregroundStyle(tint)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            Text(label.uppercased())
                .font(.system(size: 8, weight: .semibold))
                .foregroundStyle(.secondary)
                .tracking(0.4)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Confidence footer

    private func confidenceFooter(outcome: PhysiqueOutcome?, color: Color) -> some View {
        let trendStr = strengthLabel(outcome?.trend.strength)
        let nutStr = strengthLabel(outcome?.nutrition.strength)
        let trendCount = outcome?.trend.entryCount ?? 0
        let nutCount = outcome?.nutrition.loggedDays ?? 0

        return HStack(spacing: 6) {
            Image(systemName: "waveform.path.ecg")
                .font(.system(size: 9, weight: .semibold))
                .foregroundStyle(.secondary)
            Text("Signal · weigh-ins \(trendStr) (\(trendCount)) · nutrition \(nutStr) (\(nutCount))")
                .font(.caption2.weight(.medium))
                .foregroundStyle(.secondary)
            Spacer()
            if outcome?.trend.strength == .insufficient || outcome?.nutrition.strength == .insufficient {
                Text("CALIBRATING")
                    .font(.system(size: 8, weight: .bold))
                    .foregroundStyle(STRQPalette.info)
                    .tracking(0.6)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(STRQPalette.infoSoft, in: Capsule())
            }
        }
    }

    // MARK: - Derivations

    private func verdictState(for outcome: PhysiqueOutcome?) -> STRQPalette.State {
        guard let outcome else { return .info }
        switch outcome.paceVerdict {
        case .onTrack, .aligned: return .success
        case .tooSlow, .drifting: return .warning
        case .tooFast: return .danger
        case .noSignal: return .info
        }
    }

    private func verdictIcon(for outcome: PhysiqueOutcome?) -> String {
        guard let outcome else { return "waveform.path" }
        switch outcome.paceVerdict {
        case .onTrack, .aligned: return "checkmark.seal.fill"
        case .tooSlow: return "arrow.right.circle.fill"
        case .tooFast: return "exclamationmark.triangle.fill"
        case .drifting: return "arrow.left.arrow.right.circle.fill"
        case .noSignal: return "waveform.path"
        }
    }

    private func kickerLabel(for outcome: PhysiqueOutcome?) -> String {
        guard let outcome else { return "PHYSIQUE · CALIBRATING" }
        switch outcome.paceVerdict {
        case .onTrack: return "ON TRACK"
        case .aligned: return "ALIGNED"
        case .tooSlow: return "BEHIND PACE"
        case .tooFast: return "AHEAD OF PACE"
        case .drifting: return "DRIFTING"
        case .noSignal: return "CALIBRATING"
        }
    }

    private func headlineText(for outcome: PhysiqueOutcome?) -> String {
        guard let outcome else {
            return "Calibrating your physique signal."
        }
        let goal = vm.nutritionTarget.nutritionGoal.displayName
        switch outcome.paceVerdict {
        case .onTrack:
            return "\(goal) is tracking."
        case .aligned:
            return "Bodyweight is holding — \(goal.lowercased()) aligned."
        case .tooSlow:
            switch vm.nutritionTarget.nutritionGoal {
            case .leanBulk, .muscleGain: return "Gaining slower than your goal."
            case .fatLoss, .aggressiveCut: return "Cut has stalled."
            case .maintenance, .recomp: return "Barely moving — stable enough."
            }
        case .tooFast:
            switch vm.nutritionTarget.nutritionGoal {
            case .leanBulk, .muscleGain: return "Gaining too fast — risking fat gain."
            case .fatLoss, .aggressiveCut: return "Cutting too aggressively."
            default: return "Moving faster than planned."
            }
        case .drifting:
            let dir = outcome.trend.weeklyChangeKg > 0 ? "up" : "down"
            return "Weight drifting \(dir) while targeting \(goal.lowercased())."
        case .noSignal:
            return "Not enough signal yet to judge \(goal.lowercased())."
        }
    }

    private func detailText(for outcome: PhysiqueOutcome?) -> String? {
        guard let outcome else {
            return "Log a weigh-in and a couple of nutrition days — STRQ needs a week to read your real trajectory."
        }
        switch outcome.paceVerdict {
        case .noSignal:
            let weeks = outcome.trend.entryCount
            if weeks == 0 {
                return "Log a weigh-in to start reading your trajectory."
            }
            return "Keep logging — a few more days of weight and nutrition will lock in the read."
        case .onTrack, .aligned:
            return nil
        case .tooSlow, .tooFast, .drifting:
            return nil
        }
    }

    private func bridgeText() -> String? {
        let s = vm.recoveryTrainingBridge
        return s.isEmpty ? nil : s
    }

    private func trendValue(outcome: PhysiqueOutcome?) -> String {
        guard let trend = outcome?.trend, trend.strength != .insufficient else {
            return "—"
        }
        return String(format: "%+.2f", trend.weeklyChangeKg) + " kg"
    }

    private func proteinValue(outcome: PhysiqueOutcome?) -> String {
        guard let n = outcome?.nutrition, n.strength != .insufficient else {
            return "—"
        }
        return "\(Int(n.proteinHitRate * 100))%"
    }

    private func proteinTint(outcome: PhysiqueOutcome?) -> Color {
        guard let n = outcome?.nutrition, n.strength != .insufficient else {
            return STRQBrand.steel
        }
        return STRQPalette.adherence(ratio: n.proteinHitRate)
    }

    private func strengthLabel(_ s: PhysiqueSignalStrength?) -> String {
        switch s {
        case .strong: return "strong"
        case .moderate: return "moderate"
        case .weak: return "weak"
        case .insufficient, .none: return "low"
        }
    }
}
