import SwiftUI

// Phase 13 — Trust / Explainability / Change Log.
//
// A premium, compact system history of coaching changes. It is opened from
// the Coach tab and shows what changed, why, what it means now, and current
// status. Read-only by design: this is coaching memory, not a control panel.

struct CoachingHistoryView: View {
    let vm: AppViewModel
    @Environment(\.dismiss) private var dismiss

    private var entries: [CoachMemoryEntry] {
        CoachingMemoryService().buildTimeline(
            adjustments: vm.coachAdjustments,
            phaseState: vm.trainingPhaseState,
            planEvolutionSignals: vm.planEvolutionSignals,
            outlook: vm.phaseOutlook,
            physique: vm.physiqueOutcome,
            activeWeekAdjustment: vm.weekAdjustmentActive,
            nutritionTrackingEnabled: vm.profile.nutritionTrackingEnabled,
            limit: 30
        )
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                intro

                if entries.isEmpty {
                    emptyState
                } else {
                    bridgeStrip
                    VStack(spacing: 10) {
                        ForEach(entries) { entry in
                            CoachMemoryRow(entry: entry)
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 32)
        }
        .background(Color(.systemBackground))
        .navigationTitle(L10n.tr("Coaching memory"))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(L10n.tr("Done")) { dismiss() }
                    .font(.subheadline.weight(.semibold))
            }
        }
        .onAppear {
            Analytics.shared.track(.coach_viewed, ["surface": "memory"])
        }
    }

    private var intro: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(L10n.tr("Why STRQ changed your plan"))
                .font(.system(.title3, design: .rounded, weight: .bold))
            Text(L10n.tr("A record of the decisions Coach has made for you — what shifted, why it shifted, and what it means for training now."))
                .font(.footnote)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 10) {
            Image(systemName: "tray")
                .font(.title)
                .foregroundStyle(STRQBrand.steel)
            Text(L10n.tr("No coaching changes yet"))
                .font(.subheadline.weight(.semibold))
            Text(L10n.tr("Once Coach adjusts volume, swaps a lift, or shifts your phase, every change will show up here with the reason behind it."))
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }

    // Bridges the daily / weekly / block levels in one line so users feel
    // the connection between today's instruction and recent changes.
    private var bridgeStrip: some View {
        let phase = vm.trainingPhaseState.currentPhase
        let week = vm.trainingPhaseState.weeksInPhase
        let outlookLine: String? = vm.phaseOutlook?.weekIntent
        return VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 6) {
                Image(systemName: phase.icon)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.white)
                    .frame(width: 22, height: 22)
                    .background(STRQBrand.steelGradient, in: .rect(cornerRadius: 6))
                Text("\(phase.shortLabel) · Week \(week)")
                    .font(.system(size: 11, weight: .bold))
                    .tracking(0.6)
                    .foregroundStyle(.primary)
                Spacer()
                Text(L10n.tr("THE BRIDGE"))
                    .font(.system(size: 9, weight: .black))
                    .tracking(1.0)
                    .foregroundStyle(.tertiary)
            }
            if let outlookLine {
                Text(outlookLine)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            } else {
                Text(L10n.tr("Your recent changes are shaping how this week runs."))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(12)
        .background(Color(.secondarySystemGroupedBackground), in: .rect(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(STRQBrand.cardBorder, lineWidth: 1)
        )
    }
}

// MARK: - Row

struct CoachMemoryRow: View {
    let entry: CoachMemoryEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            header
            driverBlock
            if let expectation = entry.expectation, !expectation.isEmpty {
                expectationBlock(expectation)
            }
            if !entry.details.isEmpty {
                detailsBlock
            }
        }
        .padding(14)
        .background(Color(.secondarySystemGroupedBackground), in: .rect(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .strokeBorder(STRQBrand.cardBorder, lineWidth: 1)
        )
        .overlay(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 2)
                .fill(STRQPalette.color(for: entry.state))
                .frame(width: 3, height: 22)
                .padding(.leading, 0)
                .padding(.top, 14)
                .opacity(0.7)
        }
    }

    private var header: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: entry.icon)
                .font(.subheadline)
                .foregroundStyle(STRQPalette.color(for: entry.state))
                .frame(width: 32, height: 32)
                .background(STRQPalette.soft(for: entry.state), in: .rect(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 6) {
                    Text(entry.scope.label.uppercased())
                        .font(.system(size: 9, weight: .black))
                        .tracking(0.9)
                        .foregroundStyle(STRQBrand.steel)
                    Text(L10n.tr("·"))
                        .font(.system(size: 9, weight: .black))
                        .foregroundStyle(.tertiary)
                    Text(relativeDate(entry.appliedAt))
                        .font(.system(size: 9, weight: .bold))
                        .tracking(0.4)
                        .foregroundStyle(.tertiary)
                    Spacer(minLength: 0)
                }
                Text(entry.title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)

            if let status = entry.status {
                Text(status.uppercased())
                    .font(.system(size: 9, weight: .bold))
                    .tracking(0.5)
                    .foregroundStyle(STRQPalette.color(for: entry.state))
                    .padding(.horizontal, 7)
                    .padding(.vertical, 3)
                    .background(STRQPalette.soft(for: entry.state), in: Capsule())
            }
        }
    }

    private var driverBlock: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "questionmark.circle.fill")
                .font(.caption2)
                .foregroundStyle(.tertiary)
                .frame(width: 14)
                .padding(.top, 2)
            VStack(alignment: .leading, spacing: 2) {
                Text(L10n.tr("WHY"))
                    .font(.system(size: 9, weight: .black))
                    .tracking(0.8)
                    .foregroundStyle(.tertiary)
                Text(entry.driver)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private func expectationBlock(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "flag.fill")
                .font(.caption2)
                .foregroundStyle(STRQPalette.color(for: entry.state))
                .frame(width: 14)
                .padding(.top, 2)
            VStack(alignment: .leading, spacing: 2) {
                Text(L10n.tr("WHAT IT MEANS NOW"))
                    .font(.system(size: 9, weight: .black))
                    .tracking(0.8)
                    .foregroundStyle(STRQPalette.color(for: entry.state))
                Text(text)
                    .font(.caption)
                    .foregroundStyle(.primary.opacity(0.85))
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private var detailsBlock: some View {
        VStack(alignment: .leading, spacing: 3) {
            ForEach(Array(entry.details.enumerated()), id: \.offset) { _, line in
                HStack(alignment: .top, spacing: 6) {
                    Circle()
                        .fill(STRQBrand.steel.opacity(0.4))
                        .frame(width: 3, height: 3)
                        .padding(.top, 6)
                    Text(line)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .padding(8)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white.opacity(0.03), in: .rect(cornerRadius: 8))
    }

    private func relativeDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

// MARK: - Bridge Row (inline on Coach tab)

struct CoachMemoryBridgeRow: View {
    let entry: CoachMemoryEntry
    let totalCount: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                RoundedRectangle(cornerRadius: 2)
                    .fill(STRQPalette.color(for: entry.state))
                    .frame(width: 3, height: 12)
                Text(L10n.tr("RECENT CHANGE"))
                    .font(.system(size: 10, weight: .black))
                    .tracking(1.2)
                    .foregroundStyle(.primary)
                Spacer()
                Text(totalCount > 1 ? "See all \(totalCount)" : "See history")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(STRQBrand.steel)
                Image(systemName: "chevron.right")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(.tertiary)
            }

            HStack(alignment: .top, spacing: 12) {
                Image(systemName: entry.icon)
                    .font(.subheadline)
                    .foregroundStyle(STRQPalette.color(for: entry.state))
                    .frame(width: 32, height: 32)
                    .background(STRQPalette.soft(for: entry.state), in: .rect(cornerRadius: 8))

                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 6) {
                        Text(entry.scope.label.uppercased())
                            .font(.system(size: 9, weight: .black))
                            .tracking(0.8)
                            .foregroundStyle(STRQBrand.steel)
                        if let status = entry.status {
                            Text(L10n.tr("·"))
                                .font(.system(size: 9, weight: .black))
                                .foregroundStyle(.tertiary)
                            Text(status)
                                .font(.system(size: 9, weight: .bold))
                                .tracking(0.4)
                                .foregroundStyle(STRQPalette.color(for: entry.state))
                        }
                        Spacer(minLength: 0)
                    }
                    Text(entry.title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.primary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                    if let expectation = entry.expectation, !expectation.isEmpty {
                        Text(expectation)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                    } else {
                        Text(entry.driver)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                    }
                }
                Spacer(minLength: 0)
            }
        }
        .padding(14)
        .background(Color(.secondarySystemGroupedBackground), in: .rect(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .strokeBorder(STRQBrand.cardBorder, lineWidth: 1)
        )
    }
}
