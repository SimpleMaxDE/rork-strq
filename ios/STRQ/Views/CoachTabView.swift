import SwiftUI

struct CoachTabView: View {
    let vm: AppViewModel
    @State private var appeared: Bool = false
    @State private var expandedInsightIds: Set<String> = []
    @State private var expandedRecIds: Set<String> = []
    @State private var showWeeklyReview: Bool = false
    @State private var showReadinessCheckIn: Bool = false
    @State private var toast: STRQToast?
    @State private var lastAppliedCount: Int = 0

    var body: some View {
        ScrollView {
            VStack(spacing: 22) {
                authorityHero
                if vm.isEarlyStage {
                    earlyStateCard
                    calibrationChecklist
                } else {
                    directionCard
                    watchSection
                    momentumSection
                    liftTrackerSection
                }
                weeklyCheckInRow
            }
            .padding(.horizontal, 16)
            .padding(.top, 4)
            .padding(.bottom, 32)
        }
        .background(Color(.systemBackground))
        .navigationTitle("Coach")
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) { appeared = true }
            lastAppliedCount = vm.appliedActionIds.count
            Analytics.shared.track(.coach_viewed)
        }
        .onChange(of: vm.appliedActionIds.count) { old, new in
            if new > old {
                toast = STRQToast(title: "Coach adjustment applied", detail: "Your plan has been updated", style: .applied)
            }
            lastAppliedCount = new
        }
        .sheet(isPresented: $showWeeklyReview) {
            if let review = vm.weeklyReview {
                WeeklyCheckInView(vm: vm, review: review)
            }
        }
        .sheet(isPresented: $showReadinessCheckIn) {
            ReadinessCheckInView(vm: vm) { readiness in
                vm.submitReadiness(readiness)
            }
        }
        .strqToast($toast)
    }

    // MARK: - Authority Hero

    private var authorityHero: some View {
        let score = vm.effectiveRecoveryScore
        let color = ForgeTheme.recoveryColor(for: score)
        let phase = vm.currentPhase
        let status = vm.readinessBasedRecoveryStatus

        return VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .center, spacing: 16) {
                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.06), lineWidth: 5)
                        .frame(width: 66, height: 66)
                    Circle()
                        .trim(from: 0, to: appeared ? CGFloat(score) / 100 : 0)
                        .stroke(color, style: StrokeStyle(lineWidth: 5, lineCap: .round))
                        .frame(width: 66, height: 66)
                        .rotationEffect(.degrees(-90))
                        .animation(.easeOut(duration: 1.0).delay(0.15), value: appeared)
                    Text("\(score)")
                        .font(.system(size: 22, weight: .heavy, design: .rounded).monospacedDigit())
                }

                VStack(alignment: .leading, spacing: 5) {
                    Text(status.uppercased())
                        .font(.system(size: 10, weight: .black))
                        .tracking(1.2)
                        .foregroundStyle(color)
                    Text(headline)
                        .font(.system(.title3, design: .rounded, weight: .bold))
                        .foregroundStyle(.primary)
                        .lineLimit(2)
                }
                Spacer(minLength: 0)
            }

            HStack(spacing: 6) {
                HStack(spacing: 4) {
                    Image(systemName: phase.icon)
                        .font(.system(size: 9, weight: .bold))
                    Text(phase.displayName)
                        .font(.system(size: 10, weight: .black))
                        .tracking(0.6)
                        .textCase(.uppercase)
                }
                .foregroundStyle(STRQBrand.steel)
                .padding(.horizontal, 9)
                .padding(.vertical, 4)
                .background(STRQBrand.steel.opacity(0.12), in: Capsule())

                Text("Week \(vm.trainingPhaseState.weeksInPhase)")
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(.tertiary)

                Spacer()

                if !vm.hasCheckedInToday {
                    Button {
                        showReadinessCheckIn = true
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "heart.text.clipboard")
                                .font(.system(size: 9))
                            Text("Check in")
                                .font(.system(size: 10, weight: .bold))
                        }
                        .foregroundStyle(.black)
                        .padding(.horizontal, 9)
                        .padding(.vertical, 4)
                        .background(STRQBrand.accentGradient, in: Capsule())
                    }
                }
            }
        }
        .padding(16)
        .background(
            LinearGradient(
                colors: [Color(white: 0.14), Color(white: 0.09)],
                startPoint: .topLeading, endPoint: .bottomTrailing
            ),
            in: .rect(cornerRadius: 20)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .strokeBorder(Color.white.opacity(0.10), lineWidth: 1)
        )
        .overlay(alignment: .top) {
            STRQBrand.accentGradient
                .frame(height: 2)
                .clipShape(.rect(cornerRadii: .init(topLeading: 20, bottomLeading: 0, bottomTrailing: 0, topTrailing: 20)))
                .opacity(0.5)
        }
        .shadow(color: .black.opacity(0.2), radius: 14, y: 4)
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 10)
    }

    private var headline: String {
        if let guidance = vm.earlyStateGuidance {
            return guidance.headline
        }
        if let action = vm.nextBestAction {
            return action.title
        }
        if vm.stalledExercises.count > 0 {
            return "Hold load. Rebuild reps."
        }
        if vm.progressingExercises.count >= 3 {
            return "Momentum is yours. Keep pushing."
        }
        return "You're on plan. Stay the course."
    }

    // MARK: - Early State

    @ViewBuilder
    private var earlyStateCard: some View {
        if let guidance = vm.earlyStateGuidance {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 6) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(STRQBrand.accentGradient)
                        .frame(width: 3, height: 14)
                    Text("COACH CALIBRATION")
                        .font(.system(size: 10, weight: .black))
                        .tracking(1.2)
                        .foregroundStyle(.primary)
                    Spacer()
                    Text(guidance.tier.label.uppercased())
                        .font(.system(size: 9, weight: .bold))
                        .tracking(0.4)
                        .foregroundStyle(STRQBrand.steel)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(STRQBrand.steel.opacity(0.12), in: Capsule())
                }

                HStack(alignment: .top, spacing: 14) {
                    Image(systemName: guidance.icon)
                        .font(.title3.weight(.medium))
                        .foregroundStyle(.white)
                        .frame(width: 46, height: 46)
                        .background(STRQBrand.steelGradient, in: .rect(cornerRadius: 12))

                    VStack(alignment: .leading, spacing: 6) {
                        Text(guidance.message)
                            .font(.subheadline)
                            .foregroundStyle(.primary.opacity(0.9))
                            .fixedSize(horizontal: false, vertical: true)
                        if let unlocks = guidance.unlocksNext {
                            HStack(spacing: 5) {
                                Image(systemName: "lock.open.fill")
                                    .font(.system(size: 9))
                                Text(unlocks)
                                    .font(.caption2.weight(.semibold))
                            }
                            .foregroundStyle(STRQBrand.steel)
                        }
                    }
                    Spacer(minLength: 0)
                }
            }
            .padding(16)
            .background(Color(.secondarySystemGroupedBackground), in: .rect(cornerRadius: 18))
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .strokeBorder(Color.white.opacity(0.08), lineWidth: 1)
            )
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 10)
            .animation(.easeOut(duration: 0.5).delay(0.05), value: appeared)
        }
    }

    private var calibrationChecklist: some View {
        let tier = vm.dataMaturityTier
        let completed = vm.totalCompletedWorkouts
        let weekSessions = vm.weeklyStats.sessions
        let planned = vm.profile.daysPerWeek

        let items: [(String, String, Bool)] = [
            ("Plan generated", "doc.text.fill", vm.currentPlan != nil),
            ("First session logged", "figure.strengthtraining.traditional", completed >= 1),
            ("Baseline loads locked", "scalemass.fill", completed >= 2),
            ("Weekly signal ready", "chart.line.uptrend.xyaxis", weekSessions >= max(1, planned - 1)),
            ("Progression intelligence", "brain.head.profile.fill", tier == .established)
        ]

        return VStack(alignment: .leading, spacing: 10) {
            ForgeSectionHeader(title: "Unlock Path")

            VStack(spacing: 8) {
                ForEach(Array(items.enumerated()), id: \.offset) { _, item in
                    HStack(spacing: 12) {
                        Image(systemName: item.2 ? "checkmark.circle.fill" : "circle")
                            .font(.subheadline)
                            .foregroundStyle(item.2 ? .green : STRQBrand.steel.opacity(0.55))
                            .frame(width: 22)
                        Image(systemName: item.1)
                            .font(.caption)
                            .foregroundStyle(item.2 ? .primary : .secondary)
                            .frame(width: 20)
                        Text(item.0)
                            .font(.subheadline.weight(item.2 ? .semibold : .medium))
                            .foregroundStyle(item.2 ? .primary : .secondary)
                        Spacer()
                    }
                }
            }
            .padding(14)
            .background(Color(.secondarySystemGroupedBackground), in: .rect(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .strokeBorder(STRQBrand.cardBorder, lineWidth: 1)
            )
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 10)
        .animation(.easeOut(duration: 0.5).delay(0.1), value: appeared)
    }

    // MARK: - Direction (Your Move)

    @ViewBuilder
    private var directionCard: some View {
        if let action = vm.nextBestAction {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 6) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(STRQBrand.accentGradient)
                        .frame(width: 3, height: 14)
                    Text("YOUR MOVE")
                        .font(.system(size: 10, weight: .black))
                        .tracking(1.2)
                        .foregroundStyle(.primary)
                    Spacer()
                    confidencePill(action.confidence)
                }

                HStack(alignment: .top, spacing: 14) {
                    Image(systemName: action.icon)
                        .font(.title3.weight(.medium))
                        .foregroundStyle(.white)
                        .frame(width: 46, height: 46)
                        .background(STRQBrand.steelGradient, in: .rect(cornerRadius: 12))

                    VStack(alignment: .leading, spacing: 4) {
                        Text(action.title)
                            .font(.body.weight(.bold))
                            .foregroundStyle(.primary)
                        Text(action.explanation)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    Spacer(minLength: 0)
                }
            }
            .padding(16)
            .background(Color(.secondarySystemGroupedBackground), in: .rect(cornerRadius: 18))
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .strokeBorder(Color.white.opacity(0.08), lineWidth: 1)
            )
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 10)
            .animation(.easeOut(duration: 0.5).delay(0.05), value: appeared)
        }
    }

    private func confidencePill(_ confidence: Double) -> some View {
        let label = confidence >= 0.75 ? "High confidence" : confidence >= 0.5 ? "Confident" : "Consider"
        return Text(label)
            .font(.system(size: 9, weight: .bold))
            .textCase(.uppercase)
            .tracking(0.4)
            .foregroundStyle(STRQBrand.steel)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(STRQBrand.steel.opacity(0.12), in: Capsule())
    }

    // MARK: - Watch (single focused item)

    @ViewBuilder
    private var watchSection: some View {
        let topInsight = vm.highPriorityInsights.first
        let topRec = vm.recommendations.first
        let hasContent = topInsight != nil || topRec != nil

        if hasContent {
            VStack(alignment: .leading, spacing: 10) {
                ForgeSectionHeader(title: "Watch")

                if let insight = topInsight {
                    ExpandableInsightCard(
                        insight: insight,
                        actions: CoachActionMapper.actions(for: insight),
                        vm: vm,
                        isExpanded: insightBinding(insight.id),
                        onAction: { _ in }
                    )
                } else if let rec = topRec {
                    ExpandableRecommendationCard(
                        recommendation: rec,
                        actions: CoachActionMapper.actions(for: rec),
                        vm: vm,
                        isExpanded: recBinding(rec.id),
                        onAction: { _ in }
                    )
                }
            }
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 10)
            .animation(.easeOut(duration: 0.5).delay(0.08), value: appeared)
        }
    }

    // MARK: - Momentum

    @ViewBuilder
    private var momentumSection: some View {
        let wins = vm.positiveInsights.prefix(1)
        if let win = wins.first {
            VStack(alignment: .leading, spacing: 10) {
                ForgeSectionHeader(title: "Momentum")

                HStack(spacing: 12) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.green.opacity(0.12))
                            .frame(width: 38, height: 38)
                        Image(systemName: win.icon)
                            .font(.subheadline)
                            .foregroundStyle(.green)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text(win.title)
                            .font(.subheadline.weight(.semibold))
                        Text(win.message)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                    }
                    Spacer(minLength: 0)
                }
                .padding(14)
                .background(Color(.secondarySystemGroupedBackground), in: .rect(cornerRadius: 14))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .strokeBorder(STRQBrand.cardBorder, lineWidth: 1)
                )
            }
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 10)
            .animation(.easeOut(duration: 0.5).delay(0.12), value: appeared)
        }
    }

    // MARK: - Lift Tracker

    @ViewBuilder
    private var liftTrackerSection: some View {
        let stalled = vm.stalledExercises.prefix(2)
        let progressing = vm.progressingExercises.prefix(2)
        if !stalled.isEmpty || !progressing.isEmpty {
            VStack(alignment: .leading, spacing: 10) {
                ForgeSectionHeader(title: "Lift Tracker")

                ForEach(Array(stalled)) { state in
                    liftRow(state: state, isStalled: true)
                }

                ForEach(Array(progressing)) { state in
                    liftRow(state: state, isStalled: false)
                }
            }
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 10)
            .animation(.easeOut(duration: 0.5).delay(0.15), value: appeared)
        }
    }

    private func liftRow(state: ExerciseProgressionState, isStalled: Bool) -> some View {
        let exercise = vm.library.exercise(byId: state.exerciseId)
        let color: Color = isStalled ? (state.plateauStatus == .regressing ? .red : .yellow) : .green

        return HStack(spacing: 12) {
            Image(systemName: isStalled ? state.plateauStatus.icon : "arrow.up.right")
                .font(.caption)
                .foregroundStyle(color)
                .frame(width: 28, height: 28)
                .background(color.opacity(0.15), in: .rect(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 2) {
                Text(exercise?.name ?? state.exerciseId)
                    .font(.subheadline.weight(.semibold))
                    .lineLimit(1)
                HStack(spacing: 6) {
                    Text(isStalled ? state.plateauStatus.displayName : "Progressing")
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(color)
                    if let next = state.suggestedNextWeight, !isStalled {
                        Text("Next: \(String(format: "%.1f", next))kg")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    if isStalled {
                        Text(state.recommendedStrategy.displayName)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            Spacer()
        }
        .padding(12)
        .background(Color(.secondarySystemGroupedBackground), in: .rect(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .strokeBorder(STRQBrand.cardBorder, lineWidth: 1)
        )
    }

    // MARK: - Weekly Check-In

    @ViewBuilder
    private var weeklyCheckInRow: some View {
        VStack(spacing: 10) {
            if !vm.isEarlyStage, let quality = vm.planQuality {
                planQualityRow(quality)
            }

            if vm.isWeeklyReviewReady {
                Button {
                    vm.generateWeeklyReview()
                    showWeeklyReview = true
                } label: {
                    weeklyReviewLabel(subtitle: "Review your week and adjust", ready: true)
                }
            } else if vm.isEarlyStage {
                weeklyReviewLabel(subtitle: vm.sessionsUntilReviewReady == 0 ? "Log another session to unlock" : "Unlocks in \(vm.sessionsUntilReviewReady) more session\(vm.sessionsUntilReviewReady == 1 ? "" : "s") this week", ready: false)
                    .opacity(0.7)
            } else {
                Button {
                    vm.generateWeeklyReview()
                    showWeeklyReview = true
                } label: {
                    weeklyReviewLabel(subtitle: "Review your week and adjust", ready: true)
                }
            }
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 10)
        .animation(.easeOut(duration: 0.5).delay(0.18), value: appeared)
    }

    private func weeklyReviewLabel(subtitle: String, ready: Bool) -> some View {
        HStack(spacing: 12) {
            Image(systemName: ready ? "doc.text.magnifyingglass" : "lock.fill")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.white)
                .frame(width: 36, height: 36)
                .background(STRQBrand.steelGradient, in: .rect(cornerRadius: 10))

            VStack(alignment: .leading, spacing: 2) {
                Text("Weekly Check-In")
                    .font(.subheadline.weight(.semibold))
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            if ready {
                Image(systemName: "chevron.right")
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(.quaternary)
            }
        }
        .padding(14)
        .background(Color(.secondarySystemGroupedBackground), in: .rect(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .strokeBorder(STRQBrand.cardBorder, lineWidth: 1)
        )
    }

    private func planQualityRow(_ quality: PlanQualityScore) -> some View {
        let overallColor = ForgeTheme.color(for: quality.overallColor)
        return HStack(spacing: 14) {
            Image(systemName: quality.overall >= 0.7 ? "checkmark.seal.fill" : "exclamationmark.circle.fill")
                .font(.title3)
                .foregroundStyle(overallColor)
                .frame(width: 36)

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text("Plan Quality")
                        .font(.subheadline.weight(.semibold))
                    Text(quality.overallLabel)
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(overallColor)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(overallColor.opacity(0.1), in: Capsule())
                }
                if let strength = quality.strengths.first {
                    Label(strength, systemImage: "checkmark.circle.fill")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }
            Spacer()
        }
        .padding(14)
        .background(Color(.secondarySystemGroupedBackground), in: .rect(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .strokeBorder(STRQBrand.cardBorder, lineWidth: 1)
        )
    }

    // MARK: - Bindings

    private func insightBinding(_ id: String) -> Binding<Bool> {
        Binding(
            get: { expandedInsightIds.contains(id) },
            set: { v in if v { expandedInsightIds.insert(id) } else { expandedInsightIds.remove(id) } }
        )
    }

    private func recBinding(_ id: String) -> Binding<Bool> {
        Binding(
            get: { expandedRecIds.contains(id) },
            set: { v in if v { expandedRecIds.insert(id) } else { expandedRecIds.remove(id) } }
        )
    }
}
