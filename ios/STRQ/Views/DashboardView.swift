import SwiftUI

struct DashboardView: View {
    let vm: AppViewModel
    @State private var appeared: Bool = false
    @State private var showReadinessCheckIn: Bool = false
    @State private var showWeeklyReview: Bool = false
    @State private var showNutritionLog: Bool = false
    @State private var showSleepLog: Bool = false
    @State private var showWeightLog: Bool = false

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                todayHero
                    .padding(.horizontal, 16)
                    .padding(.top, 4)

                todayAction
                    .padding(.horizontal, 16)

                if let guidance = vm.earlyStateGuidance {
                    earlyStageHint(guidance)
                        .padding(.horizontal, 16)
                }

                scheduleTimeline
                    .padding(.horizontal, 16)

                if vm.earlyStateGuidance == nil, let bridge = scienceBridge, !bridge.isEmpty {
                    scienceNoteCard(bridge)
                        .padding(.horizontal, 16)
                }

                signalsRow
                    .padding(.horizontal, 16)

                if !vm.isEarlyStage {
                    weekPulse
                        .padding(.horizontal, 16)
                }

                if vm.latestWeight != nil || !vm.isEarlyStage {
                    weightSnapshotCard
                        .padding(.horizontal, 16)
                }
            }
            .padding(.bottom, 32)
        }
        .background(Color(.systemBackground))
        .navigationTitle("Today")
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) { appeared = true }
            vm.refreshDailyState()
            Analytics.shared.track(.today_viewed)
        }
        .sheet(isPresented: $showReadinessCheckIn) {
            ReadinessCheckInView(vm: vm) { readiness in
                vm.submitReadiness(readiness)
            }
        }
        .sheet(isPresented: $showWeeklyReview) {
            if let review = vm.weeklyReview {
                WeeklyCheckInView(vm: vm, review: review)
            }
        }
        .sheet(isPresented: $showNutritionLog) {
            NavigationStack {
                NutritionLogView(vm: vm)
            }
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showSleepLog) {
            NavigationStack {
                SleepLogView(vm: vm)
            }
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showWeightLog) {
            WeightQuickLogSheet(vm: vm)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.hidden)
                .presentationContentInteraction(.scrolls)
        }
    }

    private func earlyStageHint(_ guidance: EarlyStateGuidance) -> some View {
        let tierIndex = max(0, min(3, guidance.tier.rawValue))
        return VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: guidance.icon)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.white)
                    .frame(width: 36, height: 36)
                    .background(STRQBrand.steelGradient, in: .rect(cornerRadius: 10))

                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 6) {
                        Text("GETTING STARTED")
                            .font(.system(size: 9, weight: .black))
                            .tracking(1.1)
                            .foregroundStyle(STRQBrand.steel)
                        Spacer()
                        Text("Step \(tierIndex + 1) of 4")
                            .font(.system(size: 9, weight: .bold).monospacedDigit())
                            .foregroundStyle(.white.opacity(0.5))
                    }
                    Text(guidance.headline)
                        .font(.subheadline.weight(.semibold))
                    Text(guidance.message)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                    if let unlocks = guidance.unlocksNext {
                        HStack(spacing: 4) {
                            Image(systemName: "lock.open.fill")
                                .font(.system(size: 9))
                            Text(unlocks)
                                .font(.caption2.weight(.semibold))
                        }
                        .foregroundStyle(STRQBrand.steel)
                        .padding(.top, 2)
                    }
                }
                Spacer(minLength: 0)
            }

            HStack(spacing: 4) {
                ForEach(0..<4, id: \.self) { i in
                    Capsule()
                        .fill(i <= tierIndex ? AnyShapeStyle(STRQBrand.accentGradient) : AnyShapeStyle(Color.white.opacity(0.08)))
                        .frame(height: 3)
                }
            }
        }
        .padding(12)
        .background(Color(.secondarySystemGroupedBackground), in: .rect(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .strokeBorder(STRQBrand.cardBorder, lineWidth: 1)
        )
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 8)
        .animation(.easeOut(duration: 0.5).delay(0.07), value: appeared)
    }

    private var todayHero: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 3) {
                    Text(greeting)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Text(vm.profile.name.isEmpty ? "Athlete" : vm.profile.name)
                        .font(.system(.title2, design: .rounded, weight: .bold))
                }
                Spacer()
                readinessBadge
            }

            if !vm.hasCheckedInToday {
                Button {
                    showReadinessCheckIn = true
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: "heart.text.clipboard")
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(.white)
                            .frame(width: 36, height: 36)
                            .background(STRQBrand.steelGradient, in: .rect(cornerRadius: 10))

                        VStack(alignment: .leading, spacing: 2) {
                            Text("How are you feeling?")
                                .font(.subheadline.weight(.semibold))
                            Text("Quick check-in to optimize today")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(STRQBrand.steel)
                    }
                    .padding(12)
                    .background(STRQBrand.cardElevated, in: .rect(cornerRadius: 14))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .strokeBorder(STRQBrand.steel.opacity(0.15), lineWidth: 1)
                    )
                }
                .sensoryFeedback(.selection, trigger: showReadinessCheckIn)
            }
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 8)
    }

    private var readinessBadge: some View {
        Group {
            if let readiness = vm.todaysReadiness {
                let score = readiness.readinessScore
                let color = ForgeTheme.recoveryColor(for: score)
                VStack(spacing: 3) {
                    ZStack {
                        Circle()
                            .stroke(Color.white.opacity(0.08), lineWidth: 4)
                            .frame(width: 46, height: 46)
                        Circle()
                            .trim(from: 0, to: appeared ? CGFloat(score) / 100 : 0)
                            .stroke(color, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                            .frame(width: 46, height: 46)
                            .rotationEffect(.degrees(-90))
                            .animation(.easeOut(duration: 0.8).delay(0.2), value: appeared)
                        Text("\(score)")
                            .font(.system(size: 14, weight: .bold, design: .rounded).monospacedDigit())
                    }
                    Text("Ready")
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundStyle(.secondary)
                        .textCase(.uppercase)
                        .tracking(0.3)
                }
            } else if vm.streak > 0 {
                HStack(spacing: 5) {
                    Image(systemName: "flame.fill")
                        .font(.caption)
                        .foregroundStyle(STRQBrand.steel)
                    Text("\(vm.streak)")
                        .font(.system(.subheadline, design: .rounded, weight: .bold).monospacedDigit())
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 7)
                .background(STRQBrand.steel.opacity(0.12), in: Capsule())
            }
        }
    }

    // MARK: - Today Action

    private var todayAction: some View {
        Group {
            if let today = vm.todaysWorkout {
                workoutCard(today)
            } else {
                restDayCard
            }
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 10)
        .animation(.easeOut(duration: 0.5).delay(0.05), value: appeared)
    }

    private func workoutCard(_ day: WorkoutDay) -> some View {
        VStack(spacing: 0) {
            ZStack(alignment: .topLeading) {
                Canvas { context, size in
                    for i in 0..<3 {
                        let xF: [CGFloat] = [0.15, 0.65, 0.9]
                        let yF: [CGFloat] = [0.25, 0.75, 0.35]
                        let radius = CGFloat(60 + i * 30)
                        let circle = Path(ellipseIn: CGRect(
                            x: xF[i] * size.width - radius,
                            y: yF[i] * size.height - radius,
                            width: radius * 2, height: radius * 2
                        ))
                        context.fill(circle, with: .color(.white.opacity(0.025)))
                    }
                }
                .allowsHitTesting(false)

                VStack(alignment: .leading, spacing: 16) {
                    let phaseColor = ForgeTheme.color(for: vm.currentPhase.colorName)
                    HStack(spacing: 6) {
                        Image(systemName: vm.currentPhase.icon)
                            .font(.system(size: 9, weight: .bold))
                        Text(vm.currentPhase.displayName.uppercased())
                            .font(.system(size: 9, weight: .black))
                            .tracking(1.2)
                        Spacer()
                        Text("TODAY")
                            .font(.system(size: 9, weight: .black))
                            .tracking(1.2)
                            .foregroundStyle(.white.opacity(0.4))
                    }
                    .foregroundStyle(phaseColor)

                    Text(day.name)
                        .font(.system(size: 30, weight: .heavy, design: .rounded))
                        .foregroundStyle(.white)
                        .lineLimit(2)
                        .minimumScaleFactor(0.7)

                    if let adj = vm.adjustment(for: day.id) {
                        coachAdjustmentChip(adj)
                    }

                    HStack(spacing: 6) {
                        ForEach(day.focusMuscles.prefix(3)) { muscle in
                            ForgeChip(text: muscle.displayName)
                        }
                    }

                    Divider().opacity(0.3)

                    HStack(spacing: 0) {
                        ForgeStatCell(value: "\(day.exercises.count)", label: "Exercises")
                        ForgeStatCell(value: "~\(day.estimatedMinutes)m", label: "Duration")
                        ForgeStatCell(value: "\(day.exercises.reduce(0) { $0 + $1.sets })", label: "Total Sets")
                    }
                }
                .padding(20)
            }

            ForgePrimaryButton(icon: "bolt.fill", title: "Review & Start") {
                vm.prepareWorkoutHandoff(day: day)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        }
        .background(
            LinearGradient(
                colors: [Color(white: 0.16), Color(white: 0.10)],
                startPoint: .topLeading, endPoint: .bottomTrailing
            ),
            in: .rect(cornerRadius: 22)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 22)
                .strokeBorder(Color.white.opacity(0.12), lineWidth: 1)
        )
        .overlay(alignment: .top) {
            STRQBrand.accentGradient
                .frame(height: 3)
                .clipShape(.rect(cornerRadii: .init(topLeading: 22, bottomLeading: 0, bottomTrailing: 0, topTrailing: 22)))
        }
        .shadow(color: .black.opacity(0.25), radius: 18, y: 6)
    }

    private func coachAdjustmentChip(_ adj: CoachAdjustment) -> some View {
        HStack(spacing: 6) {
            Image(systemName: "brain.head.profile.fill")
                .font(.system(size: 9))
            Text(adj.description)
                .font(.caption2.weight(.semibold))
                .lineLimit(1)
        }
        .foregroundStyle(STRQBrand.steel)
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(STRQBrand.steel.opacity(0.1), in: Capsule())
    }

    private var restDayCard: some View {
        HStack(spacing: 14) {
            Image(systemName: "leaf.fill")
                .font(.title3)
                .foregroundStyle(STRQPalette.success)
                .frame(width: 44, height: 44)
                .background(STRQPalette.successSoft, in: .rect(cornerRadius: 12))

            VStack(alignment: .leading, spacing: 3) {
                Text("Recovery Day")
                    .font(.subheadline.weight(.semibold))
                Text("Rest, eat well, and come back stronger.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer(minLength: 0)
        }
        .padding(14)
        .background(Color(.secondarySystemGroupedBackground), in: .rect(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(STRQBrand.cardBorder, lineWidth: 1)
        )
    }

    // MARK: - Schedule Timeline

    @ViewBuilder
    private var scheduleTimeline: some View {
        if let plan = vm.currentPlan, plan.days.contains(where: { $0.scheduledWeekday != nil }) {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    ForgeSectionHeader(title: "Training Week", showAccent: true)
                    Spacer()
                    if let next = nextScheduledDay {
                        Text("Next: \(vm.weekdayName(next.scheduledWeekday ?? 0))")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(STRQBrand.steel)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(STRQBrand.steel.opacity(0.1), in: Capsule())
                    }
                }

                HStack(spacing: 0) {
                    ForEach(1...7, id: \.self) { weekday in
                        let matchingDay = plan.days.first { $0.scheduledWeekday == weekday && !$0.isSkipped }
                        let isToday = Calendar.current.component(.weekday, from: Date()) == weekday
                        let isPast = Calendar.current.component(.weekday, from: Date()) > weekday

                        VStack(spacing: 5) {
                            Text(vm.weekdayName(weekday))
                                .font(.system(size: 9, weight: isToday ? .bold : .medium))
                                .foregroundStyle(isToday ? Color.white : Color.secondary)

                            ZStack {
                                if matchingDay != nil {
                                    Circle()
                                        .fill(isToday ? Color.white : isPast ? STRQBrand.steel.opacity(0.3) : STRQBrand.steel)
                                        .frame(width: 28, height: 28)
                                    Image(systemName: "figure.strengthtraining.traditional")
                                        .font(.system(size: 10, weight: .medium))
                                        .foregroundStyle(isToday ? .black : .white)
                                } else {
                                    Circle()
                                        .fill(Color.white.opacity(isToday ? 0.1 : 0.04))
                                        .frame(width: 28, height: 28)
                                    if isToday {
                                        Circle()
                                            .strokeBorder(Color.white.opacity(0.3), lineWidth: 1.5)
                                            .frame(width: 28, height: 28)
                                    }
                                }
                            }

                            if let day = matchingDay {
                                Text(shortName(day.name))
                                    .font(.system(size: 8, weight: .medium))
                                    .foregroundStyle(isToday ? STRQBrand.steel : Color.gray)
                                    .lineLimit(1)
                            } else {
                                Text(isToday ? "Rest" : "")
                                    .font(.system(size: 8, weight: .medium))
                                    .foregroundStyle(Color.gray)
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                .padding(.vertical, 10)
                .padding(.horizontal, 4)
            }
            .padding(14)
            .background(Color(.secondarySystemGroupedBackground), in: .rect(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(STRQBrand.cardBorder, lineWidth: 1)
            )
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 10)
            .animation(.easeOut(duration: 0.5).delay(0.07), value: appeared)
        }
    }

    private var nextScheduledDay: WorkoutDay? {
        guard let plan = vm.currentPlan else { return nil }
        let todayWeekday = Calendar.current.component(.weekday, from: Date())
        let future = plan.days.filter { !$0.isSkipped && ($0.scheduledWeekday ?? 0) > todayWeekday }
            .sorted { ($0.scheduledWeekday ?? 0) < ($1.scheduledWeekday ?? 0) }
        if let next = future.first { return next }
        return plan.days.filter { !$0.isSkipped && $0.scheduledWeekday != nil }
            .sorted { ($0.scheduledWeekday ?? 0) < ($1.scheduledWeekday ?? 0) }
            .first
    }

    private func shortName(_ name: String) -> String {
        let words = name.split(separator: " ")
        if words.count > 1 { return String(words[0]) }
        return String(name.prefix(6))
    }

    // MARK: - Weight Snapshot

    private var scienceBridge: String? {
        let bridge = vm.recoveryTrainingBridge
        return bridge.isEmpty ? nil : bridge
    }

    private func scienceNoteCard(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "brain.head.profile.fill")
                .font(.caption)
                .foregroundStyle(STRQBrand.steel)
                .padding(.top, 1)
            Text(text)
                .font(.caption)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(12)
        .background(STRQBrand.steel.opacity(0.05), in: .rect(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(STRQBrand.steel.opacity(0.08), lineWidth: 1)
        )
        .opacity(appeared ? 1 : 0)
        .animation(.easeOut(duration: 0.5).delay(0.08), value: appeared)
    }

    private var weekPulse: some View {
        VStack(spacing: 14) {
            HStack {
                ForgeSectionHeader(title: "This Week", showAccent: true)
                Spacer()
                if let momentum = vm.momentumData {
                    let paceColor = ForgeTheme.color(for: momentum.weeklyPace.colorName)
                    Text(momentum.paceMessage)
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(paceColor)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(paceColor.opacity(0.1), in: Capsule())
                }
            }

            HStack(spacing: 0) {
                ForEach(vm.weeklyActivity) { day in
                    VStack(spacing: 6) {
                        Text(day.label)
                            .font(.system(size: 10, weight: .medium))
                            .foregroundStyle(.tertiary)
                        Circle()
                            .fill(day.didTrain ? Color.white : Color.white.opacity(0.06))
                            .frame(width: 28, height: 28)
                            .overlay {
                                if day.didTrain {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 9, weight: .bold))
                                        .foregroundStyle(.black)
                                }
                            }
                    }
                    .frame(maxWidth: .infinity)
                }
            }

            HStack(spacing: 12) {
                ForgeStatCell(value: "\(vm.weeklyStats.sessions)/\(vm.profile.daysPerWeek)", label: "Sessions")
                ForgeStatCell(value: ForgeTheme.formatVolume(vm.weeklyStats.volume), label: "Volume")
                ForgeStatCell(value: "\(vm.effectiveRecoveryScore)%", label: "Recovery", valueColor: ForgeTheme.recoveryColor(for: vm.effectiveRecoveryScore))
            }
        }
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground), in: .rect(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(STRQBrand.cardBorder, lineWidth: 1)
        )
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 10)
        .animation(.easeOut(duration: 0.5).delay(0.1), value: appeared)
    }

    @ViewBuilder
    private var weightSnapshotCard: some View {
        let latest = vm.latestWeight
        let startW = vm.profile.startWeightKg ?? vm.profile.weightKg
        let change = latest.map { $0 - startW }
        let trend = vm.weightTrendDescription

        Button { showWeightLog = true } label: {
            HStack(spacing: 14) {
                Image(systemName: "scalemass.fill")
                    .font(.title3.weight(.medium))
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
                    .background(STRQBrand.steelGradient, in: .rect(cornerRadius: 12))

                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 8) {
                        Text(latest.map { String(format: "%.1f kg", $0) } ?? "Log weight")
                            .font(.system(.subheadline, design: .rounded, weight: .bold).monospacedDigit())
                        if let c = change, abs(c) >= 0.1 {
                            Text(String(format: "%+.1f", c))
                                .font(.system(size: 11, weight: .bold).monospacedDigit())
                                .foregroundStyle(weightChangeColor(c))
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(weightChangeColor(c).opacity(0.12), in: Capsule())
                        }
                    }
                    if latest != nil {
                        Text(trend)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    } else {
                        Text("Track your body weight")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                Spacer()
                Image(systemName: "plus.circle.fill")
                    .font(.title3)
                    .foregroundStyle(STRQBrand.steel)
            }
            .padding(14)
            .background(Color(.secondarySystemGroupedBackground), in: .rect(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(STRQBrand.cardBorder, lineWidth: 1)
            )
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 10)
        .animation(.easeOut(duration: 0.5).delay(0.06), value: appeared)
    }

    private func weightChangeColor(_ change: Double) -> Color {
        switch vm.nutritionTarget.weightGoalDirection {
        case .gaining: return change > 0 ? STRQPalette.success : STRQBrand.steel
        case .losing: return change < 0 ? STRQPalette.success : STRQBrand.steel
        case .maintaining: return abs(change) < 1 ? STRQPalette.success : STRQPalette.warning
        }
    }

    private var signalsRow: some View {
        HStack(spacing: 10) {
            Button { showNutritionLog = true } label: {
                signalCard(
                    icon: "fork.knife",
                    title: "Protein",
                    value: "\(Int(vm.todayProteinProgress * 100))%",
                    progress: vm.todayProteinProgress,
                    progressColor: STRQBrand.steel
                )
            }

            Button { showSleepLog = true } label: {
                let sleepColor = ForgeTheme.sleepColor(for: vm.averageSleepHours)
                signalCard(
                    icon: "moon.zzz.fill",
                    title: "Sleep",
                    value: String(format: "%.1fh", vm.averageSleepHours),
                    progress: min(1.0, vm.averageSleepHours / 8.0),
                    progressColor: sleepColor
                )
            }

            if vm.isWeeklyReviewReady {
                Button {
                    vm.generateWeeklyReview()
                    showWeeklyReview = true
                } label: {
                    VStack(spacing: 6) {
                        Image(systemName: "doc.text.magnifyingglass")
                            .font(.caption)
                            .foregroundStyle(STRQBrand.steel)
                        Text("Review")
                            .font(.caption2.weight(.semibold))
                        Text("Ready")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundStyle(STRQBrand.steel)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color(.secondarySystemGroupedBackground), in: .rect(cornerRadius: 14))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .strokeBorder(STRQBrand.cardBorder, lineWidth: 1)
                    )
                }
            }
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 10)
        .animation(.easeOut(duration: 0.5).delay(0.12), value: appeared)
    }

    private func signalCard(icon: String, title: String, value: String, progress: Double, progressColor: Color) -> some View {
        VStack(spacing: 6) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 10))
                    .foregroundStyle(STRQBrand.steel)
                Text(title)
                    .font(.system(size: 10, weight: .bold))
                    .textCase(.uppercase)
                    .tracking(0.2)
            }
            Text(value)
                .font(.system(.subheadline, design: .rounded, weight: .bold).monospacedDigit())

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.white.opacity(0.08))
                        .frame(height: 5)
                    Capsule()
                        .fill(progressColor.gradient)
                        .frame(width: max(0, geo.size.width * min(progress, 1.0)), height: 5)
                }
            }
            .frame(height: 5)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .padding(.horizontal, 10)
        .background(Color(.secondarySystemGroupedBackground), in: .rect(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .strokeBorder(STRQBrand.cardBorder, lineWidth: 1)
        )
    }

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "Good morning"
        case 12..<17: return "Good afternoon"
        case 17..<22: return "Good evening"
        default: return "Late night"
        }
    }
}
