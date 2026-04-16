import SwiftUI

struct WeekRegenerationSheet: View {
    let vm: AppViewModel
    let preview: WeekRegenerationPreview
    var onApply: () -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    headerSection
                    reasonCard
                    changesSection
                    beforeAfterSection
                    applySection
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 40)
            }
            .background(Color.black)
            .navigationTitle("Regenerate Week")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(.secondary)
                }
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
    }

    private var headerSection: some View {
        VStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.blue, .cyan],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 64, height: 64)
                Image(systemName: "arrow.triangle.2.circlepath.circle.fill")
                    .font(.title)
                    .foregroundStyle(.white)
            }

            Text("Smart Week Regeneration")
                .font(.title3.bold())

            Text("Your upcoming week will be intelligently rebuilt based on your recent training data, recovery, and muscle balance.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 8)
    }

    private var reasonCard: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "brain.head.profile.fill")
                .font(.caption)
                .foregroundStyle(.cyan)
            Text(preview.reason)
                .font(.caption)
                .foregroundStyle(.white.opacity(0.8))
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(14)
        .background(Color.cyan.opacity(0.08), in: .rect(cornerRadius: 12))
        .overlay {
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.cyan.opacity(0.15), lineWidth: 1)
        }
    }

    private var changesSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Changes")
                    .font(.headline)
                Spacer()
                Text("\(preview.changes.count) updates")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            ForEach(preview.changes) { change in
                HStack(spacing: 10) {
                    Image(systemName: changeIcon(change.type))
                        .font(.caption)
                        .foregroundStyle(changeColor(change.type))
                        .frame(width: 24)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(change.dayName)
                            .font(.caption.weight(.semibold))
                        Text(change.change)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                }
                .padding(10)
                .background(Color.white.opacity(0.04), in: .rect(cornerRadius: 10))
            }
        }
        .padding(16)
        .background(Color.white.opacity(0.05), in: .rect(cornerRadius: 16))
    }

    private var beforeAfterSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Week Comparison")
                .font(.headline)

            HStack(spacing: 12) {
                weekColumn(title: "Current", days: preview.originalDays, color: .white.opacity(0.4))
                weekColumn(title: "New", days: preview.newDays, color: .cyan)
            }
        }
        .padding(16)
        .background(Color.white.opacity(0.05), in: .rect(cornerRadius: 16))
    }

    private func weekColumn(title: String, days: [DayPreviewSummary], color: Color) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.caption.weight(.bold))
                .foregroundStyle(color)

            let totalSets = days.reduce(0) { $0 + $1.totalSets }
            let totalMin = days.reduce(0) { $0 + $1.estimatedMinutes }

            HStack(spacing: 4) {
                Text("\(totalSets)")
                    .font(.title3.bold())
                Text("sets")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            HStack(spacing: 4) {
                Text("~\(totalMin)")
                    .font(.caption.weight(.semibold))
                Text("min total")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            ForEach(days) { day in
                VStack(alignment: .leading, spacing: 2) {
                    Text(day.name)
                        .font(.caption2.weight(.semibold))
                    Text("\(day.exerciseCount) ex · \(day.totalSets) sets")
                        .font(.system(size: 10))
                        .foregroundStyle(.secondary)
                }
                .padding(8)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.white.opacity(0.04), in: .rect(cornerRadius: 8))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var applySection: some View {
        Button {
            onApply()
            dismiss()
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "arrow.triangle.2.circlepath")
                    .font(.subheadline.weight(.semibold))
                Text("Apply Regenerated Week")
                    .font(.body.weight(.semibold))
            }
            .foregroundStyle(.black)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(
                LinearGradient(
                    colors: [.cyan, .blue],
                    startPoint: .leading,
                    endPoint: .trailing
                ),
                in: .rect(cornerRadius: 14)
            )
        }
        .sensoryFeedback(.impact(flexibility: .rigid, intensity: 0.7), trigger: false)
    }

    private func changeIcon(_ type: WeekChangeType) -> String {
        switch type {
        case .exerciseChanged: return "arrow.triangle.2.circlepath"
        case .volumeChanged: return "chart.bar.fill"
        case .emphasisChanged: return "target"
        case .removed: return "minus.circle.fill"
        case .added: return "plus.circle.fill"
        }
    }

    private func changeColor(_ type: WeekChangeType) -> Color {
        switch type {
        case .exerciseChanged: return .blue
        case .volumeChanged: return STRQBrand.steel
        case .emphasisChanged: return .cyan
        case .removed: return .red
        case .added: return .green
        }
    }
}

struct DeloadWeekSheet: View {
    let vm: AppViewModel
    let preview: DeloadWeekPreview
    var onApply: () -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    headerSection
                    reasonCard
                    statsOverview
                    dayComparisonSection
                    applySection
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 40)
            }
            .background(Color.black)
            .navigationTitle("Deload Week")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(.secondary)
                }
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
    }

    private var headerSection: some View {
        VStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.purple, .indigo],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 64, height: 64)
                Image(systemName: "arrow.down.to.line")
                    .font(.title)
                    .foregroundStyle(.white)
            }

            Text("Strategic Deload Week")
                .font(.title3.bold())

            Text("A lighter week to let accumulated fatigue dissipate. You keep the same structure and movements, but at reduced intensity.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 8)
    }

    private var reasonCard: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "heart.text.clipboard.fill")
                .font(.caption)
                .foregroundStyle(.purple)
            Text(preview.reason)
                .font(.caption)
                .foregroundStyle(.white.opacity(0.8))
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(14)
        .background(Color.purple.opacity(0.08), in: .rect(cornerRadius: 12))
        .overlay {
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.purple.opacity(0.15), lineWidth: 1)
        }
    }

    private var statsOverview: some View {
        HStack(spacing: 10) {
            deloadStat(
                value: "−\(preview.volumeReductionPercent)%",
                label: "Volume",
                icon: "chart.bar.fill",
                color: STRQBrand.steel
            )
            deloadStat(
                value: "−\(String(format: "%.1f", preview.rpeReduction))",
                label: "RPE",
                icon: "gauge.with.dots.needle.33percent",
                color: .purple
            )
            deloadStat(
                value: "~\(preview.estimatedTimeSaved)m",
                label: "Saved",
                icon: "clock.fill",
                color: .green
            )
        }
    }

    private func deloadStat(value: String, label: String, icon: String, color: Color) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.body)
                .foregroundStyle(color)
            Text(value)
                .font(.title3.bold())
                .minimumScaleFactor(0.7)
            Text(label)
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(color.opacity(0.06), in: .rect(cornerRadius: 14))
        .overlay {
            RoundedRectangle(cornerRadius: 14)
                .stroke(color.opacity(0.1), lineWidth: 1)
        }
    }

    private var dayComparisonSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Day-by-Day Preview")
                .font(.headline)

            ForEach(Array(zip(preview.originalDays, preview.deloadDays)), id: \.0.id) { original, deload in
                dayComparisonRow(original: original, deload: deload)
            }
        }
        .padding(16)
        .background(Color.white.opacity(0.05), in: .rect(cornerRadius: 16))
    }

    private func dayComparisonRow(original: DayPreviewSummary, deload: DayPreviewSummary) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(original.name)
                .font(.subheadline.weight(.semibold))

            HStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Current")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(.white.opacity(0.4))
                    Text("\(original.exerciseCount) ex · \(original.totalSets) sets · ~\(original.estimatedMinutes)m")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }

                Image(systemName: "arrow.right")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(.purple.opacity(0.6))

                VStack(alignment: .leading, spacing: 4) {
                    Text("Deload")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(.purple)
                    Text("\(deload.exerciseCount) ex · \(deload.totalSets) sets · ~\(deload.estimatedMinutes)m")
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(.purple.opacity(0.8))
                }
            }
        }
        .padding(12)
        .background(Color.white.opacity(0.04), in: .rect(cornerRadius: 12))
    }

    private var applySection: some View {
        Button {
            onApply()
            dismiss()
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "arrow.down.to.line")
                    .font(.subheadline.weight(.semibold))
                Text("Start Deload Week")
                    .font(.body.weight(.semibold))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(
                LinearGradient(
                    colors: [.purple, .indigo],
                    startPoint: .leading,
                    endPoint: .trailing
                ),
                in: .rect(cornerRadius: 14)
            )
        }
        .sensoryFeedback(.impact(flexibility: .rigid, intensity: 0.7), trigger: false)
    }
}
