import SwiftUI

struct PlanRevealView: View {
    let plan: WorkoutPlan
    let profile: UserProfile
    let planQuality: PlanQualityScore?
    let onStart: () -> Void
    var impacts: [OnboardingImpact] = []

    @State private var appeared: Bool = false
    @State private var showDays: Bool = false
    @State private var showQuality: Bool = false
    @State private var showImpacts: Bool = false

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            MeshGradient(width: 3, height: 3, points: [
                [0, 0], [0.5, 0], [1, 0],
                [0, 0.5], [0.5, 0.5], [1, 0.5],
                [0, 1], [0.5, 1], [1, 1]
            ], colors: [
                .black, .black, .black,
                .black, Color.white.opacity(0.04), .black,
                .black, .black, .black
            ])
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 28) {
                    heroSection
                    planOverviewCard
                    onboardingImpactSection
                    weekPreview
                    if let quality = planQuality {
                        qualitySection(quality)
                    }
                    explanationSection
                    startButton
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 60)
            }
        }
        .preferredColorScheme(.dark)
        .onAppear {
            withAnimation(.easeOut(duration: 0.7)) { appeared = true }
            withAnimation(.easeOut(duration: 0.5).delay(0.5)) { showDays = true }
            withAnimation(.easeOut(duration: 0.5).delay(0.6)) { showImpacts = true }
            withAnimation(.easeOut(duration: 0.5).delay(0.8)) { showQuality = true }
        }
    }

    private var heroSection: some View {
        VStack(spacing: 20) {
            Spacer().frame(height: 24)

            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.04))
                    .frame(width: 100, height: 100)
                    .blur(radius: 20)
                STRQLogoView(size: 56, animated: true)
            }
            .scaleEffect(appeared ? 1 : 0.5)
            .opacity(appeared ? 1 : 0)
            .animation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.1), value: appeared)

            VStack(spacing: 8) {
                Text("Your Plan is Ready")
                    .font(.title.bold())
                Text("Personalized for \(profile.name.isEmpty ? "you" : profile.name)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 12)
            .animation(.easeOut(duration: 0.5).delay(0.2), value: appeared)
        }
    }

    private var planOverviewCard: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(plan.splitType)
                        .font(.headline)
                    Text("\(profile.goal.displayName) · \(profile.trainingLevel.shortName)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Image(systemName: profile.goal.symbolName)
                    .font(.title2)
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
                    .background(Color.white.opacity(0.08), in: .rect(cornerRadius: 12))
            }

            Divider().opacity(0.3)

            HStack(spacing: 0) {
                overviewStat(value: "\(plan.days.count)", label: "Days/Week", icon: "calendar")
                overviewStat(value: "\(profile.minutesPerSession)m", label: "Per Session", icon: "clock")
                overviewStat(value: "\(plan.durationWeeks)wk", label: "Duration", icon: "repeat")
                overviewStat(value: totalExercises, label: "Exercises", icon: "figure.strengthtraining.traditional")
            }
        }
        .padding(18)
        .background(Color.white.opacity(0.04), in: .rect(cornerRadius: 18))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .strokeBorder(Color.white.opacity(0.06), lineWidth: 1)
        )
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 16)
        .animation(.easeOut(duration: 0.5).delay(0.35), value: appeared)
    }

    private func overviewStat(value: String, label: String, icon: String) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(STRQBrand.steel)
            Text(value)
                .font(.subheadline.bold().monospacedDigit())
            Text(label)
                .font(.system(size: 9, weight: .medium))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }

    private var totalExercises: String {
        let count = Set(plan.days.flatMap { $0.exercises.map(\.exerciseId) }).count
        return "\(count)"
    }

    private var weekPreview: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("YOUR WEEK")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(STRQBrand.steel)
                    .tracking(0.5)
                Spacer()
            }

            ForEach(Array(plan.days.enumerated()), id: \.element.id) { index, day in
                dayRow(day, index: index)
                    .opacity(showDays ? 1 : 0)
                    .offset(x: showDays ? 0 : -20)
                    .animation(
                        .spring(response: 0.4, dampingFraction: 0.8)
                            .delay(Double(index) * 0.08),
                        value: showDays
                    )
            }
        }
        .padding(18)
        .background(Color.white.opacity(0.04), in: .rect(cornerRadius: 18))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .strokeBorder(Color.white.opacity(0.06), lineWidth: 1)
        )
    }

    private func dayRow(_ day: WorkoutDay, index: Int) -> some View {
        HStack(spacing: 14) {
            Text("Day \(index + 1)")
                .font(.system(size: 10, weight: .bold).monospacedDigit())
                .foregroundStyle(STRQBrand.steel)
                .frame(width: 38)

            VStack(alignment: .leading, spacing: 3) {
                Text(day.name)
                    .font(.subheadline.weight(.semibold))
                HStack(spacing: 4) {
                    Text(day.focusMuscles.prefix(3).map(\.displayName).joined(separator: ", "))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("·")
                        .foregroundStyle(.secondary)
                    Text("\(day.exercises.count) exercises")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            Text("~\(day.estimatedMinutes)m")
                .font(.caption.weight(.medium).monospacedDigit())
                .foregroundStyle(.white.opacity(0.4))
        }
        .padding(.vertical, 2)
    }

    @ViewBuilder
    private func qualitySection(_ quality: PlanQualityScore) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("COACH ASSESSMENT")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(STRQBrand.steel)
                    .tracking(0.5)
                Spacer()
                Text(quality.overallLabel)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(qualityColor(quality.overallColor))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(qualityColor(quality.overallColor).opacity(0.12), in: Capsule())
            }

            LazyVGrid(columns: [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)], spacing: 10) {
                qualityItem("Recovery Fit", rating: quality.recoveryFit)
                qualityItem("Time Fit", rating: quality.timeFit)
                qualityItem("Muscle Balance", rating: quality.muscleBalance)
                qualityItem("Equipment Fit", rating: quality.equipmentFit)
            }

            if !quality.strengths.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(quality.strengths.prefix(2), id: \.self) { strength in
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 10))
                                .foregroundStyle(.green)
                            Text(strength)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
        .padding(18)
        .background(Color.white.opacity(0.04), in: .rect(cornerRadius: 18))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .strokeBorder(Color.white.opacity(0.06), lineWidth: 1)
        )
        .opacity(showQuality ? 1 : 0)
        .offset(y: showQuality ? 0 : 16)
    }

    private func qualityItem(_ label: String, rating: QualityRating) -> some View {
        HStack(spacing: 8) {
            Image(systemName: rating.icon)
                .font(.caption)
                .foregroundStyle(qualityColor(rating.colorName))
            VStack(alignment: .leading, spacing: 1) {
                Text(label)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(.secondary)
                Text(rating.label)
                    .font(.caption.weight(.semibold))
            }
            Spacer()
        }
        .padding(10)
        .background(Color.white.opacity(0.03), in: .rect(cornerRadius: 10))
    }

    private var onboardingImpactSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 8) {
                Image(systemName: "person.fill.viewfinder")
                    .font(.caption)
                    .foregroundStyle(STRQBrand.steel)
                Text("YOUR INPUTS SHAPED THIS PLAN")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(STRQBrand.steel)
                    .tracking(0.5)
            }

            ForEach(Array(impacts.enumerated()), id: \.element.id) { index, impact in
                HStack(spacing: 12) {
                    Image(systemName: impact.icon)
                        .font(.caption)
                        .foregroundStyle(impactColor(impact.color))
                        .frame(width: 28, height: 28)
                        .background(impactColor(impact.color).opacity(0.12), in: .rect(cornerRadius: 8))

                    VStack(alignment: .leading, spacing: 2) {
                        Text(impact.title)
                            .font(.caption.weight(.bold))
                        Text(impact.detail)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                    }
                    Spacer()
                }
                .opacity(showImpacts ? 1 : 0)
                .offset(x: showImpacts ? 0 : -16)
                .animation(
                    .spring(response: 0.4, dampingFraction: 0.8)
                        .delay(Double(index) * 0.06),
                    value: showImpacts
                )
            }
        }
        .padding(18)
        .background(Color.white.opacity(0.04), in: .rect(cornerRadius: 18))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .strokeBorder(Color.white.opacity(0.06), lineWidth: 1)
        )
    }

    private func impactColor(_ name: String) -> Color {
        switch name {
        case "blue": return STRQBrand.steel
        case "green": return .green
        case "purple": return STRQBrand.slate
        case "red": return .red
        case "cyan": return STRQBrand.steel
        case "steel": return STRQBrand.steel
        default: return STRQBrand.steel
        }
    }

    private var explanationSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "brain.head.profile.fill")
                    .font(.caption)
                    .foregroundStyle(STRQBrand.steel)
                Text("WHY THIS PLAN")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(STRQBrand.steel)
                    .tracking(0.5)
            }

            Text(plan.explanation)
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.7))
                .lineSpacing(4)
        }
        .padding(18)
        .background(Color.white.opacity(0.04), in: .rect(cornerRadius: 18))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .strokeBorder(Color.white.opacity(0.06), lineWidth: 1)
        )
        .opacity(showQuality ? 1 : 0)
        .offset(y: showQuality ? 0 : 12)
        .animation(.easeOut(duration: 0.5).delay(1.0), value: showQuality)
    }

    private var startButton: some View {
        Button {
            onStart()
        } label: {
            HStack(spacing: 10) {
                Text("Start Training")
                    .font(.body.weight(.semibold))
                Image(systemName: "arrow.right")
                    .font(.subheadline.weight(.semibold))
            }
            .foregroundStyle(.black)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(STRQBrand.accentGradient, in: .rect(cornerRadius: 16))
        }
        .sensoryFeedback(.impact(flexibility: .soft, intensity: 0.6), trigger: showQuality)
        .opacity(showQuality ? 1 : 0)
        .animation(.easeOut(duration: 0.5).delay(1.2), value: showQuality)
    }

    private func qualityColor(_ name: String) -> Color {
        ForgeTheme.color(for: name)
    }
}
