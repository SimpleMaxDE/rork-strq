import SwiftUI

/// Hero verdict card that answers "am I on track?" in one glance,
/// then explains the dominant drivers and the single next-step priority.
///
/// Reads from `PhysiqueIntelligenceEngine` output (already computed on the
/// view-model) so Body Progress and Nutrition share a single source of truth.
struct PhysiqueVerdictCard: View {
    let vm: AppViewModel
    var compact: Bool = false

    var body: some View {
        if !vm.profile.nutritionTrackingEnabled {
            optInCard
        } else {
            trackingCard
        }
    }

    private var optInCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "sparkles")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(STRQPalette.info)
                Text("PHYSIQUE COACHING")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(STRQPalette.info)
                    .tracking(0.8)
                Spacer()
                Text("OPTIONAL")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(.secondary)
                    .tracking(0.5)
                    .padding(.horizontal, 7)
                    .padding(.vertical, 3)
                    .background(Color.white.opacity(0.06), in: Capsule())
            }
            Text("Physique tracking is off.")
                .font(.title3.weight(.semibold))
            Text("STRQ is coaching your training and recovery. Turn on physique tracking anytime to add bodyweight and nutrition intelligence — only when you want it.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            Button {
                vm.profile.nutritionTrackingEnabled = true
                vm.refreshNutritionInsights()
                vm.refreshCoachingInsights()
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "plus.circle.fill")
                        .font(.caption)
                    Text("Enable Physique Tracking")
                        .font(.subheadline.weight(.semibold))
                }
                .foregroundStyle(.black)
                .frame(maxWidth: .infinity)
                .frame(height: 40)
                .background(STRQBrand.accentGradient, in: .rect(cornerRadius: 11))
            }
            .buttonStyle(.plain)
        }
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground), in: .rect(cornerRadius: 18))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .strokeBorder(STRQPalette.info.opacity(0.18), lineWidth: 0.5)
        )
    }

    private var trackingCard: some View {
        let outcome = vm.physiqueOutcome
        let state = verdictState(for: outcome)
        let color = STRQPalette.color(for: state)

        return VStack(alignment: .leading, spacing: 14) {
            header(state: state, color: color, outcome: outcome)
            headline(outcome: outcome, state: state)
            metricStrip(outcome: outcome, color: color)
            if !compact {
                if let outcome, !outcome.drivers.isEmpty {
                    driversSection(drivers: outcome.drivers)
                }
                if let outcome, let priority = outcome.priority {
                    prioritySection(priority: priority, state: state, color: color)
                }
                if let bridge = outcome?.trainingBridge, !bridge.isEmpty {
                    trainingBridgeSection(text: bridge, color: color)
                }
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
            if let projection = projectionText(for: outcome) {
                Text(projection)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
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

    // MARK: - Drivers

    private func driversSection(drivers: [PhysiqueDriver]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("WHY")
                .font(.system(size: 9, weight: .bold))
                .foregroundStyle(.secondary)
                .tracking(0.8)
            VStack(spacing: 6) {
                ForEach(drivers.prefix(3)) { driver in
                    driverRow(driver)
                }
            }
        }
    }

    private func driverRow(_ driver: PhysiqueDriver) -> some View {
        let color = STRQPalette.color(for: paletteState(for: driver.state))
        return HStack(spacing: 10) {
            Image(systemName: driver.icon)
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(color)
                .frame(width: 20, height: 20)
                .background(color.opacity(0.14), in: .rect(cornerRadius: 6))
            VStack(alignment: .leading, spacing: 1) {
                Text(driver.label)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.primary)
                Text(driver.detail)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .truncationMode(.tail)
            }
            Spacer(minLength: 0)
            Image(systemName: polarityIcon(driver.polarity))
                .font(.system(size: 9, weight: .bold))
                .foregroundStyle(color.opacity(0.9))
        }
    }

    // MARK: - Priority

    private func prioritySection(priority: PhysiquePriority, state: STRQPalette.State, color: Color) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: priority.icon)
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(color)
                .frame(width: 28, height: 28)
                .background(color.opacity(0.16), in: .rect(cornerRadius: 8))
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text("THIS WEEK")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(color)
                        .tracking(0.8)
                    Rectangle()
                        .fill(color.opacity(0.3))
                        .frame(height: 0.5)
                }
                Text(priority.headline)
                    .font(.subheadline.weight(.semibold))
                Text(priority.detail)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(12)
        .background(color.opacity(0.08), in: .rect(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(color.opacity(0.22), lineWidth: 0.5)
        )
    }

    // MARK: - Training bridge

    private func trainingBridgeSection(text: String, color: Color) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "link")
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(color.opacity(0.85))
                .padding(.top, 2)
            Text(text)
                .font(.caption)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 0)
        }
    }

    // MARK: - Confidence footer

    private func confidenceFooter(outcome: PhysiqueOutcome?, color: Color) -> some View {
        let trendStr = strengthLabel(outcome?.trend.strength)
        let nutStr = strengthLabel(outcome?.nutrition.strength)
        let trendCount = outcome?.trend.entryCount ?? 0
        let nutCount = outcome?.nutrition.loggedDays ?? 0
        let tier = outcome?.confidence ?? .calibrating

        return HStack(spacing: 6) {
            Image(systemName: "waveform.path.ecg")
                .font(.system(size: 9, weight: .semibold))
                .foregroundStyle(.secondary)
            Text("Signal · weigh-ins \(trendStr) (\(trendCount)) · nutrition \(nutStr) (\(nutCount))")
                .font(.caption2.weight(.medium))
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.85)
            Spacer()
            Text(tierBadge(tier))
                .font(.system(size: 8, weight: .bold))
                .foregroundStyle(tierColor(tier))
                .tracking(0.6)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(tierColor(tier).opacity(0.16), in: Capsule())
        }
    }

    private func tierBadge(_ tier: PhysiqueConfidenceTier) -> String {
        switch tier {
        case .calibrating: return "CALIBRATING"
        case .directional: return "DIRECTIONAL"
        case .confident:   return "CONFIDENT"
        }
    }

    private func tierColor(_ tier: PhysiqueConfidenceTier) -> Color {
        switch tier {
        case .calibrating: return STRQPalette.info
        case .directional: return STRQPalette.warning
        case .confident:   return STRQPalette.success
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

    private func paletteState(for s: PhysiqueDriver.DriverState) -> STRQPalette.State {
        switch s {
        case .success: return .success
        case .warning: return .warning
        case .danger:  return .danger
        case .info:    return .info
        case .neutral: return .neutral
        }
    }

    private func polarityIcon(_ p: PhysiqueDriver.Polarity) -> String {
        switch p {
        case .supports: return "arrow.up.right"
        case .limits:   return "arrow.down.right"
        case .neutral:  return "equal"
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

    private func projectionText(for outcome: PhysiqueOutcome?) -> String? {
        guard let outcome, outcome.trend.strength != .insufficient else { return nil }
        let proj = outcome.trend.projected4wKg
        guard abs(proj) >= 0.1 else {
            return "Projects to hold within ±0.1 kg over the next 4 weeks at this pace."
        }
        let verb: String = {
            switch vm.nutritionTarget.nutritionGoal {
            case .leanBulk, .muscleGain:
                return proj > 0 ? "Projects" : "Projects to lose"
            case .fatLoss, .aggressiveCut:
                return proj < 0 ? "Projects to drop" : "Projects to gain"
            case .maintenance, .recomp:
                return "Projects to drift"
            }
        }()
        return "\(verb) \(String(format: "%+.1f", proj)) kg over 4 weeks if this pace holds."
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
