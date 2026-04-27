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
    @State private var showCoachNote: Bool = false

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
                VStack(spacing: 24) {
                    heroSection
                    planOverviewCard
                    firstWeekRoadmap
                    onboardingImpactSection
                    weekPreview
                    if let quality = planQuality {
                        qualitySection(quality)
                    }
                    explanationSection
                    Color.clear.frame(height: 90)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }

            VStack(spacing: 0) {
                Spacer()
                stickyStartBar
            }
            .ignoresSafeArea(edges: .bottom)
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

            VStack(spacing: 6) {
                Text(L10n.tr("Your Plan is Ready"))
                    .font(.title.bold())
                Text(profile.name.isEmpty ? L10n.tr("Start Session 1 now. STRQ will tune the rest from real training.") : L10n.format("%@, start Session 1 now. STRQ will tune the rest from real training.", profile.name))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
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
                    Text(SplitDisplayName.localizedDisplayName(for: plan.splitType))
                        .font(.headline)
                    Text("\(profile.goal.localizedDisplayName) · \(profile.trainingLevel.localizedShortName)")
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
                overviewStat(value: "\(plan.days.count)", label: L10n.tr("Days/Week"), icon: "calendar")
                overviewStat(value: L10n.format("%dm", profile.minutesPerSession), label: L10n.tr("Per Session"), icon: "clock")
                overviewStat(value: L10n.format("%dwk", plan.durationWeeks), label: L10n.tr("Duration"), icon: "repeat")
                overviewStat(value: totalExercises, label: L10n.tr("Exercises"), icon: "figure.strengthtraining.traditional")
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
                Text(L10n.tr("YOUR WEEK"))
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
            Text(L10n.format("Day %d", index + 1))
                .font(.system(size: 10, weight: .bold).monospacedDigit())
                .foregroundStyle(STRQBrand.steel)
                .frame(width: 38)

            VStack(alignment: .leading, spacing: 3) {
                Text(day.name)
                    .font(.subheadline.weight(.semibold))
                HStack(spacing: 4) {
                    Text(day.focusMuscles.prefix(3).map(\.localizedDisplayName).joined(separator: ", "))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("·")
                        .foregroundStyle(.secondary)
                    Text(L10n.format("%d exercises", day.exercises.count))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            Text(L10n.format("~%dm", day.estimatedMinutes))
                .font(.caption.weight(.medium).monospacedDigit())
                .foregroundStyle(.white.opacity(0.4))
        }
        .padding(.vertical, 2)
    }

    @ViewBuilder
    private func qualitySection(_ quality: PlanQualityScore) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text(L10n.tr("COACH ASSESSMENT"))
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(STRQBrand.steel)
                    .tracking(0.5)
                Spacer()
                Text(quality.localizedOverallLabel)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(qualityColor(quality.overallColor))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(qualityColor(quality.overallColor).opacity(0.12), in: Capsule())
            }

            LazyVGrid(columns: [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)], spacing: 10) {
                qualityItem(L10n.tr("Recovery Fit"), rating: quality.recoveryFit)
                qualityItem(L10n.tr("Time Fit"), rating: quality.timeFit)
                qualityItem(L10n.tr("Muscle Balance"), rating: quality.muscleBalance)
                qualityItem(L10n.tr("Equipment Fit"), rating: quality.equipmentFit)
            }

            if !quality.strengths.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(quality.strengths.prefix(2), id: \.self) { strength in
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 10))
                                .foregroundStyle(STRQPalette.success)
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
                Text(rating.localizedLabel)
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
                Text(L10n.tr("YOUR INPUTS SHAPED THIS PLAN"))
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
        case "green": return STRQPalette.success
        case "purple": return STRQBrand.slate
        case "red": return STRQPalette.danger
        case "cyan": return STRQBrand.steel
        case "steel": return STRQBrand.steel
        default: return STRQBrand.steel
        }
    }

    private var explanationSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Button {
                withAnimation(.snappy(duration: 0.22)) {
                    showCoachNote.toggle()
                }
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "brain.head.profile.fill")
                        .font(.caption)
                        .foregroundStyle(STRQBrand.steel)
                    Text(L10n.tr("coachNote.title", fallback: "Coach note"))
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(STRQBrand.steel)
                        .tracking(0.5)
                    Spacer()
                    Text(L10n.tr("common.details", fallback: "Details"))
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                    Image(systemName: showCoachNote ? "chevron.up" : "chevron.down")
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(.secondary)
                }
            }
            .buttonStyle(.plain)

            if showCoachNote {
                Text(plan.explanation)
                    .font(.callout)
                    .foregroundStyle(.white.opacity(0.66))
                    .lineSpacing(2)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
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

    private var stickyStartBar: some View {
        VStack(spacing: 0) {
            LinearGradient(colors: [.black.opacity(0), .black], startPoint: .top, endPoint: .bottom)
                .frame(height: 36)
            VStack(spacing: 8) {
                Button {
                    onStart()
                } label: {
                    HStack(spacing: 10) {
                        Text(L10n.tr("Start Session 1"))
                            .font(.body.weight(.bold))
                        Image(systemName: "arrow.right")
                            .font(.subheadline.weight(.bold))
                    }
                    .foregroundStyle(.black)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(STRQBrand.accentGradient, in: .rect(cornerRadius: 16))
                    .shadow(color: .white.opacity(0.1), radius: 14, y: 3)
                }
                .sensoryFeedback(.impact(flexibility: .soft, intensity: 0.6), trigger: showQuality)

                Text(L10n.tr("You'll go straight into today's session. You can fine-tune the plan later in Train."))
                    .font(.caption2)
                    .foregroundStyle(.white.opacity(0.35))
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 28)
            .background(Color.black)
        }
        .opacity(showQuality ? 1 : 0)
        .animation(.easeOut(duration: 0.5).delay(1.0), value: showQuality)
    }

    private func qualityColor(_ name: String) -> Color {
        ForgeTheme.color(for: name)
    }

    private var firstWeekRoadmap: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 8) {
                Image(systemName: "map.fill")
                    .font(.caption)
                    .foregroundStyle(STRQBrand.steel)
                Text(L10n.tr("WHAT TO DO FIRST"))
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(STRQBrand.steel)
                    .tracking(0.5)
            }

            VStack(spacing: 0) {
                roadmapRow(
                    index: 1,
                    title: L10n.tr("Start Session 1"),
                    detail: L10n.tr("Train normally. STRQ sets your real baseline from this workout."),
                    isLast: false
                )
                roadmapRow(
                    index: 2,
                    title: L10n.tr("Come back for Session 2"),
                    detail: L10n.tr("Progression starts once STRQ sees your first-session data."),
                    isLast: false
                )
                roadmapRow(
                    index: 3,
                    title: L10n.tr("Complete week one"),
                    detail: L10n.tr("Recovery, balance, and workload get sharper after your first week."),
                    isLast: true
                )
            }
        }
        .padding(18)
        .background(Color.white.opacity(0.04), in: .rect(cornerRadius: 18))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .strokeBorder(Color.white.opacity(0.06), lineWidth: 1)
        )
        .opacity(showDays ? 1 : 0)
        .offset(y: showDays ? 0 : 12)
    }

    private func roadmapRow(index: Int, title: String, detail: String, isLast: Bool) -> some View {
        HStack(alignment: .top, spacing: 14) {
            VStack(spacing: 0) {
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.08))
                        .frame(width: 26, height: 26)
                    Text("\(index)")
                        .font(.system(size: 11, weight: .bold, design: .rounded).monospacedDigit())
                        .foregroundStyle(.white.opacity(0.85))
                }
                if !isLast {
                    Rectangle()
                        .fill(Color.white.opacity(0.08))
                        .frame(width: 1)
                        .frame(maxHeight: .infinity)
                }
            }
            .frame(width: 26)

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                Text(detail)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.bottom, isLast ? 0 : 14)
            Spacer(minLength: 0)
        }
    }
}
