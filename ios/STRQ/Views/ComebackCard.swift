import SwiftUI

/// Calm, adult comeback surface — shown only when the user has drifted out
/// of cadence enough to deserve guided re-entry. Never punitive, never
/// streak-shaming. Frames the lapse as something STRQ is actively helping
/// the user resolve.
struct ComebackCard: View {
    let guidance: ComebackGuidance
    var onEaseNext: (() -> Void)?
    var onCheckIn: (() -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            header
            detailBlock
            stepsBlock
            if guidance.offersLighterSession || onCheckIn != nil {
                ctaRow
            }
        }
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground), in: .rect(cornerRadius: 18))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .strokeBorder(Color.white.opacity(0.08), lineWidth: 1)
        )
    }

    private var tint: Color {
        ForgeTheme.color(for: guidance.colorName)
    }

    private var header: some View {
        HStack(spacing: 6) {
            RoundedRectangle(cornerRadius: 2)
                .fill(tint)
                .frame(width: 3, height: 14)
            Text(guidance.tier.eyebrow)
                .font(.system(size: 10, weight: .black))
                .tracking(1.2)
                .foregroundStyle(tint)
            Spacer()
            Text("\(guidance.daysSinceLastWorkout)D SINCE LAST SESSION")
                .font(.system(size: 9, weight: .bold).monospacedDigit())
                .tracking(0.6)
                .foregroundStyle(STRQBrand.steel)
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(STRQBrand.steel.opacity(0.12), in: Capsule())
        }
    }

    private var detailBlock: some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: guidance.icon)
                .font(.title3.weight(.medium))
                .foregroundStyle(.white)
                .frame(width: 46, height: 46)
                .background(STRQBrand.steelGradient, in: .rect(cornerRadius: 12))

            VStack(alignment: .leading, spacing: 4) {
                Text(guidance.headline)
                    .font(.body.weight(.bold))
                    .foregroundStyle(.primary)
                Text(guidance.detail)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
        }
    }

    @ViewBuilder
    private var stepsBlock: some View {
        if !guidance.steps.isEmpty {
            VStack(alignment: .leading, spacing: 6) {
                ForEach(Array(guidance.steps.enumerated()), id: \.offset) { _, step in
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: "circle.fill")
                            .font(.system(size: 4, weight: .bold))
                            .foregroundStyle(tint)
                            .padding(.top, 7)
                        Text(step)
                            .font(.caption)
                            .foregroundStyle(.primary.opacity(0.85))
                            .fixedSize(horizontal: false, vertical: true)
                        Spacer(minLength: 0)
                    }
                }
            }
            .padding(10)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white.opacity(0.03), in: .rect(cornerRadius: 10))
        }
    }

    @ViewBuilder
    private var ctaRow: some View {
        HStack(spacing: 10) {
            if let onCheckIn {
                Button(action: onCheckIn) {
                    HStack(spacing: 6) {
                        Image(systemName: "heart.text.clipboard")
                            .font(.caption)
                        Text(L10n.tr("Check in"))
                            .font(.subheadline.weight(.semibold))
                    }
                    .foregroundStyle(.primary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 11)
                    .background(Color.white.opacity(0.08), in: .rect(cornerRadius: 11))
                    .overlay(
                        RoundedRectangle(cornerRadius: 11)
                            .strokeBorder(Color.white.opacity(0.12), lineWidth: 1)
                    )
                }
                .buttonStyle(.strqPressable)
            }

            if guidance.offersLighterSession, let onEaseNext {
                Button(action: onEaseNext) {
                    HStack(spacing: 6) {
                        Image(systemName: "leaf.arrow.triangle.circlepath")
                            .font(.caption)
                        Text(L10n.tr("Ease next session"))
                            .font(.subheadline.weight(.bold))
                            .lineLimit(1)
                    }
                    .foregroundStyle(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 11)
                    .background(STRQBrand.accentGradient, in: .rect(cornerRadius: 11))
                }
                .buttonStyle(.strqPressable)
            }
        }
    }
}
