import SwiftUI

/// Long-term adaptation / mesocycle clarity surface.
///
/// A single card that answers:
///   - what phase am I in and what is it optimizing for?
///   - how far am I into the typical block?
///   - what's the next likely shift and why?
///   - what's the intent of this week inside the phase?
///
/// Designed to live at the top of Coach and at the bottom of Train as a
/// bridge between daily guidance and the long-term plan.
struct PhaseOutlookCard: View {
    let outlook: PhaseOutlook
    var style: Style = .standard

    enum Style {
        case standard   // Coach — full card
        case compact    // Train — condensed under mission card
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            header
            progressTrack
            if style == .standard {
                blockIntentBlock
            }
            weekIntentRow
            if style == .standard {
                nextShiftBlock
            } else {
                compactNextShiftRow
            }
        }
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground), in: .rect(cornerRadius: 18))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .strokeBorder(STRQBrand.cardBorder, lineWidth: 1)
        )
        .overlay(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 2)
                .fill(STRQBrand.accentGradient)
                .frame(width: 3, height: 26)
                .padding(.leading, 0)
                .padding(.top, 16)
                .opacity(0.6)
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack(alignment: .center, spacing: 10) {
            Image(systemName: outlook.currentPhase.icon)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(.white)
                .frame(width: 36, height: 36)
                .background(STRQBrand.steelGradient, in: .rect(cornerRadius: 10))

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text("PHASE · WEEK \(outlook.weekInBlock)/\(outlook.typicalWeeks)")
                        .font(.system(size: 9, weight: .black))
                        .tracking(1.1)
                        .foregroundStyle(STRQBrand.steel)
                    Spacer(minLength: 0)
                }
                Text(outlook.currentPhase.shortLabel)
                    .font(.system(.headline, design: .rounded, weight: .bold))
                    .foregroundStyle(.primary)
                    .lineLimit(1)
            }
            Spacer(minLength: 0)
            STRQStateBadge(
                label: outlook.nextShiftLikelihood.label,
                state: outlook.nextShiftDirection.paletteState
            )
        }
    }

    // MARK: - Progress track

    private var progressTrack: some View {
        VStack(alignment: .leading, spacing: 6) {
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.white.opacity(0.06))
                    Capsule()
                        .fill(STRQBrand.accentGradient)
                        .frame(width: max(6, geo.size.width * outlook.progressFraction))
                        .opacity(0.85)
                }
            }
            .frame(height: 4)

            HStack {
                Text(outlook.currentPhase.optimizingFor.uppercased())
                    .font(.system(size: 9, weight: .bold))
                    .tracking(0.6)
                    .foregroundStyle(.secondary)
                Spacer()
                Text("Expected: \(outlook.currentPhase.expectedIntensityLabel)")
                    .font(.system(size: 9, weight: .bold))
                    .tracking(0.4)
                    .foregroundStyle(.tertiary)
            }
        }
    }

    // MARK: - Block intent

    private var blockIntentBlock: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "scope")
                .font(.caption)
                .foregroundStyle(STRQBrand.steel)
                .frame(width: 18)
            Text(outlook.blockIntent)
                .font(.footnote)
                .foregroundStyle(.primary.opacity(0.9))
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.top, 2)
    }

    // MARK: - Week intent

    private var weekIntentRow: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "calendar.circle.fill")
                .font(.subheadline)
                .foregroundStyle(STRQPalette.info)
                .frame(width: 18)
            VStack(alignment: .leading, spacing: 2) {
                Text(L10n.tr("THIS WEEK"))
                    .font(.system(size: 9, weight: .black))
                    .tracking(0.8)
                    .foregroundStyle(STRQPalette.info)
                Text(outlook.weekIntent)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
        }
        .padding(10)
        .background(STRQPalette.infoSoft.opacity(0.4), in: .rect(cornerRadius: 10))
    }

    // MARK: - Next shift (standard)

    private var nextShiftBlock: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: outlook.nextShiftDirection.icon)
                .font(.subheadline)
                .foregroundStyle(STRQPalette.color(for: outlook.nextShiftDirection.paletteState))
                .frame(width: 28, height: 28)
                .background(
                    STRQPalette.soft(for: outlook.nextShiftDirection.paletteState),
                    in: .rect(cornerRadius: 8)
                )

            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 6) {
                    Text(L10n.tr("NEXT SHIFT"))
                        .font(.system(size: 9, weight: .black))
                        .tracking(0.8)
                        .foregroundStyle(.secondary)
                    Text("→ \(outlook.nextPhase.shortLabel)")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.primary)
                }
                Text(outlook.nextShiftReason)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                if let driver = outlook.driverLine {
                    HStack(spacing: 4) {
                        Image(systemName: "chart.bar.doc.horizontal")
                            .font(.system(size: 8, weight: .bold))
                        Text(driver)
                            .font(.system(size: 10, weight: .semibold))
                    }
                    .foregroundStyle(.tertiary)
                    .padding(.top, 1)
                }
            }
            Spacer(minLength: 0)
        }
    }

    // MARK: - Next shift (compact)

    private var compactNextShiftRow: some View {
        HStack(spacing: 8) {
            Image(systemName: outlook.nextShiftDirection.icon)
                .font(.caption)
                .foregroundStyle(STRQPalette.color(for: outlook.nextShiftDirection.paletteState))
            Text("Next → \(outlook.nextPhase.shortLabel)")
                .font(.caption.weight(.bold))
                .foregroundStyle(.primary)
            Text(outlook.nextShiftReason)
                .font(.caption2)
                .foregroundStyle(.secondary)
                .lineLimit(2)
            Spacer(minLength: 0)
        }
    }
}
