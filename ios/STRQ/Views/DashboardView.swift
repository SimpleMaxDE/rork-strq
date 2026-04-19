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
            VStack(spacing: 16) {
                todayHero
                    .padding(.horizontal, 16)
                    .padding(.top, 4)

                primaryActionCard
                    .padding(.horizontal, 16)

                if let since = vm.dailyBriefing?.sinceLast {
                    sinceLastCard(since)
                        .padding(.horizontal, 16)
                }

                if let guidance = vm.earlyStateGuidance {
                    earlyStageHint(guidance)
                        .padding(.horizontal, 16)
                }

                scheduleTimeline
                    .padding(.horizontal, 16)

                dailySignalsRow
                    .padding(.horizontal, 16)

                if !vm.isEarlyStage {
                    weekPulse
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

    // MARK: - Today Hero

    private var todayHero: some View {
        HStack(alignment: .center, spacing: 16) {
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

    // MARK: - Primary Action Card (Daily Briefing)

    @ViewBuilder
    private var primaryActionCard: some View {
        if let briefing = vm.dailyBriefing {
            let primary = briefing.primary
            if let today = vm.todaysWorkout, primaryTrainsToday(primary.kind) {
                workoutCard(today, briefing: briefing)
            } else {
                briefingCard(primary, briefing: briefing)
            }
        }
    }

    private func primaryTrainsToday(_ kind: DailyBriefing.PrimaryKind) -> Bool {
        switch kind {
        case .trainToday, .checkInBeforeTraining, .resumeWorkout, .recoverToday:
            return true
        default:
            return false
        }
    }

    private func briefingCard(_ primary: DailyBriefing.Primary, briefing: DailyBriefing) -> some View {
        let tint = ForgeTheme.color(for: primary.colorName)
        return VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 6) {
                RoundedRectangle(cornerRadius: 2)
                    .fill(tint)
                    .frame(width: 3, height: 12)
                Text(primary.eyebrow)
                    .font(.system(size: 10, weight: .black))
                    .tracking(1.2)
                    .foregroundStyle(tint)
                Spacer()
                if let momentum = briefing.momentum {
                    HStack(spacing: 4) {
                        Image(systemName: momentum.icon)
                            .font(.system(size: 9, weight: .bold))
                        Text(momentum.title)
                            .font(.system(size: 10, weight: .bold))
                            .lineLimit(1)
                    }
                    .foregroundStyle(STRQBrand.steel)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(STRQBrand.steel.opacity(0.12), in: Capsule())
                }
            }

            HStack(alignment: .top, spacing: 14) {
                Image(systemName: primary.icon)
                    .font(.title3.weight(.medium))
                    .foregroundStyle(.white)
                    .frame(width: 46, height: 46)
                    .background(STRQBrand.steelGradient, in: .rect(cornerRadius: 12))

                VStack(alignment: .leading, spacing: 4) {
                    Text(primary.title)
                        .font(.title3.weight(.bold))
                        .foregroundStyle(.primary)
                    Text(primary.detail)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer(minLength: 0)
            }

            if let rest = briefing.restPrep {
                HStack(spacing: 10) {
                    Image(systemName: rest.icon)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(STRQBrand.steel)
                        .frame(width: 24, height: 24)
                        .background(STRQBrand.steel.opacity(0.12), in: .rect(cornerRadius: 7))
                    VStack(alignment: .leading, spacing: 1) {
                        Text(rest.title)
                            .font(.caption.weight(.semibold))
                        Text(rest.detail)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                    }
                    Spacer(minLength: 0)
                }
                .padding(.top, 2)
            }

            primaryCTA(primary)
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

    @ViewBuilder
    private func primaryCTA(_ primary: DailyBriefing.Primary) -> some View {
        switch primary.kind {
        case .checkInBeforeTraining:
            ForgePrimaryButton(icon: "heart.text.clipboard", title: "Check in") {
                showReadinessCheckIn = true
            }
        case .logBodyWeight:
            ForgePrimaryButton(icon: "scalemass.fill", title: primary.ctaTitle) {
                showWeightLog = true
            }
        case .startFirstSession:
            if let day = vm.todaysWorkout ?? vm.nextWorkout {
                ForgePrimaryButton(icon: "sparkles", title: "Begin first session") {
                    vm.prepareWorkoutHandoff(day: day)
                }
            }
        case .resumeWorkout:
            if let day = vm.todaysWorkout {
                ForgePrimaryButton(icon: "play.fill", title: "Resume session") {
                    vm.prepareWorkoutHandoff(day: day)
                }
            }
        default:
            EmptyView()
        }
    }

    // MARK: - Since Last Session

    private func sinceLastCard(_ since: DailyBriefing.SinceLast) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "arrow.up.right.circle.fill")
                .font(.title3)
                .foregroundStyle(STRQPalette.success)
                .frame(width: 36, height: 36)
                .background(STRQPalette.successSoft, in: .rect(cornerRadius: 10))

            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 6) {
                    Text(since.eyebrow)
                        .font(.system(size: 9, weight: .black))
                        .tracking(1.1)
                        .foregroundStyle(STRQPalette.success)
                    Text(timeLabel(since.hoursAgo))
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(.tertiary)
                }
                Text(since.summary)
                    .font(.subheadline.weight(.semibold))
                    .lineLimit(2)
                Text(since.sessionName)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            Spacer(minLength: 0)
        }
        .padding(12)
        .background(STRQPalette.successSoft.opacity(0.5), in: .rect(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .strokeBorder(STRQPalette.success.opacity(0.2), lineWidth: 1)
        )
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 10)
        .animation(.easeOut(duration: 0.5).delay(0.06), value: appeared)
    }

    private func timeLabel(_ hours: Int) -> String {
        if hours < 1 { return "JUST NOW" }
        if hours < 24 { return "\(hours)H AGO" }
        return "YESTERDAY"
    }

    // MARK: - Early Stage

    private func earlyStageHint(_ guidance: EarlyStateGuidance) -> some View {
        let tierIndex = max(0, min(3, guidance.tier.rawValue))
        return VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: guidance.icon)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.white)
                    .frame(width: 32, height: 32)
                    .background(STRQBrand.steelGradient, in: .rect(cornerRadius: 9))

                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Text("CALIBRATING")
                            .font(.system(size: 9, weight: .black))
                            .tracking(1.1)
                            .foregroundStyle(STRQBrand.steel)
                        Spacer()
                        Text("\(tierIndex + 1)/4")
                            .font(.system(size: 9, weight: .bold).monospacedDigit())
                            .foregroundStyle(.white.opacity(0.5))
                    }
                    Text(guidance.headline)
                        .font(.subheadline.weight(.semibold))
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

    // MARK: - Workout Card (training-day primary)

    private func workoutCard(_ day: WorkoutDay, briefing: DailyBriefing) -> some View {
        let primary = briefing.primary
        let tint = ForgeTheme.color(for: primary.colorName)
        return VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 14) {
                HStack(spacing: 6) {
                    Image(systemName: vm.currentPhase.icon)
                        .font(.system(size: 9, weight: .bold))
                    Text(primary.eyebrow)
                        .font(.system(size: 9, weight: .black))
                        .tracking(1.2)
                    Spacer()
                    if let momentum = briefing.momentum {
                        Text(momentum.title)
                            .font(.system(size: 9, weight: .bold))
                            .foregroundStyle(.white.opacity(0.55))
                            .lineLimit(1)
                    } else {
                        Text("TODAY")
                            .font(.system(size: 9, weight: .black))
                            .tracking(1.2)
                            .foregroundStyle(.white.opacity(0.4))
                    }
                }
                .foregroundStyle(tint)

                Text(day.name)
                    .font(.system(size: 28, weight: .heavy, design: .rounded))
                    .foregroundStyle(.white)
                    .lineLimit(2)
                    .minimumScaleFactor(0.7)

                Text(primary.detail)
                    .font(.footnote)
                    .foregroundStyle(.white.opacity(0.7))
                    .fixedSize(horizontal: false, vertical: true)

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

            if primary.kind == .checkInBeforeTraining {
                HStack(spacing: 10) {
                    Button {
                        showReadinessCheckIn = true
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "heart.text.clipboard")
                            Text("Check in")
                        }
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.primary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 13)
                        .background(Color.white.opacity(0.1), in: .rect(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .strokeBorder(Color.white.opacity(0.15), lineWidth: 1)
                        )
                    }
                    .buttonStyle(.strqPressable)

                    Button {
                        vm.prepareWorkoutHandoff(day: day)
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "bolt.fill")
                            Text("Start")
                        }
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 13)
                        .background(STRQBrand.accentGradient, in: .rect(cornerRadius: 12))
                    }
                    .buttonStyle(.strqPressable)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
            } else {
                ForgePrimaryButton(
                    icon: primary.kind == .resumeWorkout ? "play.fill" : "bolt.fill",
                    title: primary.kind == .resumeWorkout ? "Resume session" : "Review & start"
                ) {
                    vm.prepareWorkoutHandoff(day: day)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
            }
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
            tint
                .frame(height: 3)
                .clipShape(.rect(cornerRadii: .init(topLeading: 22, bottomLeading: 0, bottomTrailing: 0, topTrailing: 22)))
        }
        .shadow(color: .black.opacity(0.25), radius: 18, y: 6)
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 10)
        .animation(.easeOut(duration: 0.5).delay(0.05), value: appeared)
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

    // MARK: - Daily Signals Row (compact)

    private var dailySignalsRow: some View {
        VStack(spacing: 10) {
            HStack(spacing: 10) {
                signalButton(
                    icon: "fork.knife",
                    label: "Protein",
                    value: "\(Int(vm.todayProteinProgress * 100))%",
                    progress: vm.todayProteinProgress,
                    color: STRQBrand.steel
                ) {
                    showNutritionLog = true
                }

                signalButton(
                    icon: "moon.zzz.fill",
                    label: "Sleep",
                    value: String(format: "%.1fh", vm.averageSleepHours),
                    progress: min(1.0, vm.averageSleepHours / 8.0),
                    color: ForgeTheme.sleepColor(for: vm.averageSleepHours)
                ) {
                    showSleepLog = true
                }

                signalButton(
                    icon: "scalemass.fill",
                    label: "Weight",
                    value: vm.latestWeight.map { String(format: "%.1f", $0) } ?? "—",
                    progress: vm.latestWeight != nil ? 1.0 : 0.0,
                    color: STRQBrand.steel
                ) {
                    showWeightLog = true
                }
            }

            if vm.isWeeklyReviewReady {
                Button {
                    vm.generateWeeklyReview()
                    showWeeklyReview = true
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: "doc.text.magnifyingglass")
                            .font(.subheadline)
                            .foregroundStyle(.white)
                            .frame(width: 28, height: 28)
                            .background(STRQBrand.steelGradient, in: .rect(cornerRadius: 8))
                        VStack(alignment: .leading, spacing: 1) {
                            Text("Weekly review ready")
                                .font(.subheadline.weight(.semibold))
                            Text("Review this week and adjust")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption2.weight(.semibold))
                            .foregroundStyle(.quaternary)
                    }
                    .padding(12)
                    .background(Color(.secondarySystemGroupedBackground), in: .rect(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(STRQBrand.cardBorder, lineWidth: 1)
                    )
                }
                .buttonStyle(.strqPressable)
            }
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 10)
        .animation(.easeOut(duration: 0.5).delay(0.1), value: appeared)
    }

    private func signalButton(icon: String, label: String, value: String, progress: Double, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 5) {
                HStack(spacing: 4) {
                    Image(systemName: icon)
                        .font(.system(size: 10))
                        .foregroundStyle(STRQBrand.steel)
                    Text(label)
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
                            .frame(height: 4)
                        Capsule()
                            .fill(color.gradient)
                            .frame(width: max(0, geo.size.width * min(progress, 1.0)), height: 4)
                    }
                }
                .frame(height: 4)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .padding(.horizontal, 8)
            .background(Color(.secondarySystemGroupedBackground), in: .rect(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(STRQBrand.cardBorder, lineWidth: 1)
            )
        }
        .buttonStyle(.strqPressable)
    }

    // MARK: - Week Pulse

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
        .animation(.easeOut(duration: 0.5).delay(0.12), value: appeared)
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
