import SwiftUI

struct CoachTabView: View {
    let vm: AppViewModel
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var appeared: Bool = false
    @State private var expandedInsightIds: Set<String> = []
    @State private var expandedRecIds: Set<String> = []
    @State private var showWeeklyReview: Bool = false
    @State private var showReadinessCheckIn: Bool = false
    @State private var showMoreSignals: Bool = false
    @State private var showCoachingHistory: Bool = false
    @State private var showWatchDetails: Bool = false
    @State private var toast: STRQToast?
    @State private var lastAppliedCount: Int = 0

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                authorityHero

                if vm.isEarlyStage {
                    earlyStateCard

                    if shouldShowCalibrationChecklist {
                        calibrationChecklist
                    }
                } else {
                    if let comeback = vm.comebackGuidance {
                        ComebackCard(
                            guidance: comeback,
                            onEaseNext: comeback.offersLighterSession ? {
                                Analytics.shared.track(.comeback_cta_tapped, [
                                    "action": "ease",
                                    "tier": comeback.tier.rawValue,
                                    "surface": "coach"
                                ])
                                vm.applyComebackLighterSession()
                            } : nil,
                            onCheckIn: vm.hasCheckedInToday ? nil : {
                                Analytics.shared.track(.comeback_cta_tapped, [
                                    "action": "checkin",
                                    "tier": comeback.tier.rawValue,
                                    "surface": "coach"
                                ])
                                showReadinessCheckIn = true
                            }
                        )
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 10)
                        .animation(reduceMotion ? .easeOut(duration: 0.12) : .easeOut(duration: 0.5).delay(0.04), value: appeared)
                        .onAppear {
                            Analytics.shared.track(.comeback_card_viewed, [
                                "tier": comeback.tier.rawValue,
                                "days_since": String(comeback.daysSinceLastWorkout),
                                "surface": "coach"
                            ])
                        }
                    }
                    decisionStack
                }

                if !vm.isEarlyStage, let outlook = vm.phaseOutlook {
                    PhaseOutlookCard(outlook: outlook)
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 10)
                        .animation(reduceMotion ? .easeOut(duration: 0.12) : .easeOut(duration: 0.5).delay(0.12), value: appeared)
                }

                recentChangeBridge

                weeklyCheckInRow
            }
            .padding(.horizontal, 16)
            .padding(.top, 4)
            .padding(.bottom, 32)
        }
        .background(Color(.systemBackground))
        .navigationTitle(L10n.tr("Coach"))
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            withAnimation(reduceMotion ? .easeOut(duration: 0.12) : .easeOut(duration: 0.5)) { appeared = true }
            lastAppliedCount = vm.appliedActionIds.count
            Analytics.shared.track(.coach_viewed)
        }
        .onChange(of: vm.appliedActionIds.count) { old, new in
            if new > old {
                toast = STRQToast(
                    title: L10n.tr("Coach adjustment applied"),
                    detail: L10n.tr("Your plan has been updated"),
                    style: .applied
                )
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
        .sheet(isPresented: $showMoreSignals) {
            NavigationStack {
                MoreSignalsSheet(vm: vm)
            }
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
            .presentationContentInteraction(.scrolls)
        }
        .sheet(isPresented: $showCoachingHistory) {
            NavigationStack {
                CoachingHistoryView(vm: vm)
            }
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
            .presentationContentInteraction(.scrolls)
        }
        .strqToast($toast)
    }

    // MARK: - Authority Hero

    private var authorityHero: some View {
        let score = vm.effectiveRecoveryScore
        let color = coachReadinessColor(for: score)
        let phase = vm.currentPhase
        let status = vm.readinessBasedRecoveryStatus
        let readinessTeal = Color(red: 0.300, green: 0.780, blue: 0.740)
        let commandLine = STRQPalette.borderStrong.opacity(0.72)
        let moduleSurface = Color.white.opacity(0.035)

        return VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top, spacing: 15) {
                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [color.opacity(0.18), Color.white.opacity(0.025), Color.clear],
                                center: .center,
                                startRadius: 14,
                                endRadius: 43
                            )
                        )
                        .frame(width: 82, height: 82)
                    Circle()
                        .stroke(commandLine.opacity(0.62), lineWidth: 6)
                        .frame(width: 68, height: 68)
                    Circle()
                        .trim(from: 0, to: appeared ? CGFloat(score) / 100 : 0)
                        .stroke(color, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                        .frame(width: 68, height: 68)
                        .rotationEffect(.degrees(-90))
                        .animation(reduceMotion ? .easeOut(duration: 0.12) : .easeOut(duration: 1.0).delay(0.15), value: appeared)
                    Circle()
                        .stroke(color.opacity(0.20), lineWidth: 1)
                        .frame(width: 82, height: 82)
                    STRQCountUpText(value: Double(score), duration: 0.75)
                        .font(.system(size: 22, weight: .heavy, design: .rounded).monospacedDigit())
                        .foregroundStyle(STRQPalette.textPrimary)
                }
                .frame(width: 88, height: 88)
                .background(moduleSurface, in: .rect(cornerRadius: 18))
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .strokeBorder(Color.white.opacity(0.08), lineWidth: 1)
                )

                VStack(alignment: .leading, spacing: 9) {
                    HStack(spacing: 7) {
                        Circle()
                            .fill(color)
                            .frame(width: 6, height: 6)
                        Text(status.uppercased())
                            .font(.system(size: 10, weight: .black))
                            .tracking(1.2)
                            .foregroundStyle(color)
                    }
                    .padding(.top, 2)

                    Text(headline)
                        .font(.system(.title3, design: .rounded, weight: .bold))
                        .foregroundStyle(STRQPalette.textPrimary)
                        .lineLimit(2)
                }

                Spacer(minLength: 0)
            }

            HStack(alignment: .center, spacing: 8) {
                HStack(spacing: 5) {
                    Image(systemName: phase.icon)
                        .font(.system(size: 9, weight: .bold))
                    Text(phase.displayName)
                        .font(.system(size: 10, weight: .black))
                        .tracking(0.6)
                        .textCase(.uppercase)
                }
                .foregroundStyle(STRQPalette.textSecondary)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(Color.white.opacity(0.045), in: Capsule())
                .overlay(
                    Capsule()
                        .strokeBorder(commandLine.opacity(0.72), lineWidth: 1)
                )

                Text(L10n.format("Week %d", vm.trainingPhaseState.weeksInPhase))
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(STRQPalette.textMuted)

                Spacer(minLength: 8)

                if !vm.hasCheckedInToday {
                    Button {
                        showReadinessCheckIn = true
                    } label: {
                        HStack(spacing: 5) {
                            Image(systemName: "heart.text.clipboard")
                                .font(.system(size: 9, weight: .semibold))
                            Text(L10n.tr("Check in"))
                                .font(.system(size: 10, weight: .bold))
                        }
                        .foregroundStyle(readinessTeal)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(readinessTeal.opacity(0.12), in: Capsule())
                        .overlay(
                            Capsule()
                                .strokeBorder(readinessTeal.opacity(0.34), lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.top, 2)
            .overlay(alignment: .top) {
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [Color.clear, commandLine.opacity(0.62), Color.clear],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(height: 1)
                    .offset(y: -8)
            }
        }
        .padding(14)
        .background {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [STRQPalette.surfaceRaised, STRQPalette.backgroundCarbon],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [Color.white.opacity(0.055), Color.clear],
                        startPoint: .topLeading,
                        endPoint: .center
                    )
                )
            VStack(alignment: .trailing, spacing: 6) {
                Rectangle()
                    .fill(commandLine.opacity(0.42))
                    .frame(width: 58, height: 1)
                Rectangle()
                    .fill(commandLine.opacity(0.28))
                    .frame(width: 34, height: 1)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
            .padding(.top, 16)
            .padding(.trailing, 16)
        }
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .strokeBorder(
                    LinearGradient(
                        colors: [Color.white.opacity(0.15), STRQPalette.borderSubtle.opacity(0.76), Color.black.opacity(0.36)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .shadow(color: .black.opacity(0.26), radius: 18, y: 7)
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 10)
    }

    private func coachReadinessColor(for score: Int) -> Color {
        switch score {
        case 85...:
            return STRQPalette.success
        case 70..<85:
            return Color(red: 0.36, green: 0.74, blue: 0.50)
        case 55..<70:
            return STRQPalette.warning
        case 40..<55:
            return STRQPalette.danger.opacity(0.84)
        default:
            return STRQPalette.danger
        }
    }

    private var headline: String {
        if let briefing = vm.dailyBriefing {
            return briefing.primary.title
        }
        if let guidance = vm.earlyStateGuidance {
            return guidance.headline
        }
        if let action = vm.nextBestAction {
            return action.title
        }
        return L10n.tr("You're on plan. Stay the course.")
    }

    // MARK: - Decision Stack (primary move / watch / momentum)

    @ViewBuilder
    private var decisionStack: some View {
        if let briefing = vm.dailyBriefing {
            let density = vm.profile.coachingPreferences.density
            let sideLimit = density.sideSignalsLimit
            let emphasis = vm.profile.coachingPreferences.emphasis
            let showWatch = briefing.watch != nil && sideLimit >= 1
            let showMomentum = briefing.momentum != nil && sideLimit >= (showWatch ? 2 : 1) && emphasis != .simplicity
            VStack(spacing: 14) {
                primaryMoveCard(briefing.primary)

                if showWatch, let watch = briefing.watch {
                    watchCard(watch)
                }

                if showMomentum, let momentum = briefing.momentum {
                    momentumCard(momentum)
                }

                if briefing.moreSignalsCount > 0, density != .focused {
                    Button {
                        showMoreSignals = true
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "list.bullet.rectangle")
                                .font(.caption)
                                .foregroundStyle(STRQBrand.steel)
                            Text(moreSignalsLabel(briefing.moreSignalsCount))
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(.primary)
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

                // Lift tracker only when coach has real signal.
                if vm.coachingConfidence >= .moderate {
                    liftTrackerSection
                }
            }
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 10)
            .animation(reduceMotion ? .easeOut(duration: 0.12) : .easeOut(duration: 0.5).delay(0.05), value: appeared)
        }
    }

    private func primaryMoveCard(_ primary: DailyBriefing.Primary) -> some View {
        let tint = ForgeTheme.color(for: primary.colorName)
        return VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 6) {
                RoundedRectangle(cornerRadius: 2)
                    .fill(tint)
                    .frame(width: 3, height: 14)
                Text(L10n.tr("COACH RECOMMENDS"))
                    .font(.system(size: 10, weight: .black))
                    .tracking(1.2)
                    .foregroundStyle(tint)
                Spacer()
                Text(primary.eyebrow)
                    .font(.system(size: 9, weight: .bold))
                    .tracking(0.6)
                    .foregroundStyle(tint)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(tint.opacity(0.12), in: Capsule())
            }

            HStack(alignment: .top, spacing: 14) {
                Image(systemName: primary.icon)
                    .font(.title3.weight(.medium))
                    .foregroundStyle(.white)
                    .frame(width: 50, height: 50)
                    .background(tint.opacity(0.20), in: .rect(cornerRadius: 14))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .strokeBorder(tint.opacity(0.24), lineWidth: 1)
                    )

                VStack(alignment: .leading, spacing: 4) {
                    Text(primary.title)
                        .font(.system(.title3, design: .rounded, weight: .bold))
                        .foregroundStyle(.primary)
                    Text(primary.detail)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer(minLength: 0)
            }

            coachPrimaryCTA(primary)

            if let sinceLast = vm.dailyBriefing?.sinceLast {
                HStack(spacing: 10) {
                    Image(systemName: "arrow.up.right.circle.fill")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(STRQPalette.success)
                        .frame(width: 22, height: 22)
                        .background(STRQPalette.successSoft, in: .rect(cornerRadius: 7))
                    Text("\(sinceLast.eyebrow.capitalized) — \(sinceLast.summary)")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                    Spacer(minLength: 0)
                }
                .padding(.top, 2)
            }
        }
        .padding(16)
        .background(
            LinearGradient(
                colors: [Color(.secondarySystemGroupedBackground), tint.opacity(0.08)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            in: .rect(cornerRadius: 20)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .strokeBorder(tint.opacity(0.22), lineWidth: 1)
        )
        .shadow(color: tint.opacity(0.10), radius: 18, y: 6)
    }

    @ViewBuilder
    private func coachPrimaryCTA(_ primary: DailyBriefing.Primary) -> some View {
        switch primary.kind {
        case .checkInBeforeTraining:
            ForgePrimaryButton(icon: "heart.text.clipboard", title: L10n.tr("Check in")) {
                showReadinessCheckIn = true
            }
        case .startFirstSession:
            if let day = vm.todaysWorkout ?? vm.nextWorkout {
                ForgePrimaryButton(icon: "sparkles", title: L10n.tr("Start Workout 1")) {
                    vm.prepareWorkoutHandoff(day: day)
                }
            }
        case .resumeWorkout:
            if let day = vm.todaysWorkout {
                ForgePrimaryButton(icon: "play.fill", title: L10n.tr("Resume Workout")) {
                    vm.prepareWorkoutHandoff(day: day)
                }
            }
        case .trainToday, .recoverToday:
            if let day = vm.todaysWorkout {
                ForgePrimaryButton(
                    icon: primary.kind == .recoverToday ? "heart.circle.fill" : "bolt.fill",
                    title: primary.kind == .recoverToday ? L10n.tr("Start Light Workout") : L10n.tr("Start Workout")
                ) {
                    vm.prepareWorkoutHandoff(day: day)
                }
            }
        default:
            EmptyView()
        }
    }

    private func watchCard(_ watch: DailyBriefing.Watch) -> some View {
        let tint = ForgeTheme.color(for: watch.colorName)
        return VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                RoundedRectangle(cornerRadius: 2)
                    .fill(tint)
                    .frame(width: 3, height: 12)
                Text(L10n.tr("WATCH"))
                    .font(.system(size: 10, weight: .black))
                    .tracking(1.2)
                    .foregroundStyle(.primary)
                Spacer()
            }

            HStack(alignment: .top, spacing: 12) {
                Image(systemName: watch.icon)
                    .font(.subheadline)
                    .foregroundStyle(tint)
                    .frame(width: 34, height: 34)
                    .background(tint.opacity(0.15), in: .rect(cornerRadius: 10))

                VStack(alignment: .leading, spacing: 2) {
                    Text(watch.title)
                        .font(.subheadline.weight(.semibold))
                    Button {
                        withAnimation(reduceMotion ? .easeOut(duration: 0.12) : .snappy(duration: 0.22)) {
                            showWatchDetails.toggle()
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Text(L10n.tr("common.details", fallback: "Details"))
                                .font(.caption.weight(.semibold))
                            Image(systemName: showWatchDetails ? "chevron.up" : "chevron.down")
                                .font(.caption2.weight(.bold))
                        }
                        .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)

                    if showWatchDetails {
                        Text(watch.detail)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(4)
                            .transition(.opacity.combined(with: .move(edge: .top)))
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

    private func momentumCard(_ momentum: DailyBriefing.Momentum) -> some View {
        HStack(spacing: 12) {
            Image(systemName: momentum.icon)
                .font(.subheadline)
                .foregroundStyle(STRQPalette.success)
                .frame(width: 34, height: 34)
                .background(STRQPalette.successSoft, in: .rect(cornerRadius: 10))

            VStack(alignment: .leading, spacing: 1) {
                Text(L10n.tr("MOMENTUM"))
                    .font(.system(size: 9, weight: .black))
                    .tracking(1.1)
                    .foregroundStyle(STRQPalette.success)
                Text(momentum.title)
                    .font(.subheadline.weight(.semibold))
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

    private func moreSignalsLabel(_ count: Int) -> String {
        count == 1
            ? L10n.format("%d more signal", count)
            : L10n.format("%d more signals", count)
    }

    // MARK: - Early State

    @ViewBuilder
    private var earlyStateCard: some View {
        if let guidance = vm.earlyStateGuidance {
            let tierIndex = max(0, min(3, guidance.tier.rawValue))
            let completedStages = tierIndex + 1

            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .top, spacing: 14) {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 8) {
                            Text(L10n.tr("COACH CALIBRATION"))
                                .font(.system(size: 10, weight: .black))
                                .tracking(1.2)
                                .foregroundStyle(STRQBrand.steel)
                                .lineLimit(1)
                                .minimumScaleFactor(0.82)

                            Text(guidance.tier.label.uppercased())
                                .font(.system(size: 9, weight: .black))
                                .foregroundStyle(.white.opacity(0.9))
                                .lineLimit(1)
                                .minimumScaleFactor(0.65)
                                .padding(.horizontal, 7)
                                .padding(.vertical, 3)
                                .background(Color.white.opacity(0.08), in: Capsule())
                                .overlay(
                                    Capsule()
                                        .strokeBorder(Color.white.opacity(0.12), lineWidth: 0.5)
                                )
                        }

                        Text(guidance.headline)
                            .font(.system(.title3, design: .rounded, weight: .bold))
                            .foregroundStyle(.primary)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Spacer(minLength: 0)

                    earlyStateSignalMark(icon: guidance.icon, completedStages: completedStages)
                }

                Text(coachEarlyStateMessage)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)

                if let unlocksNext = guidance.unlocksNext {
                    VStack(alignment: .leading, spacing: 5) {
                        Text(L10n.tr("NEXT"))
                            .font(.system(size: 9, weight: .black))
                            .tracking(1.1)
                            .foregroundStyle(STRQBrand.steel)
                        Text(unlocksNext)
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(Color.primary.opacity(0.9))
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.white.opacity(0.045), in: .rect(cornerRadius: 14))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .strokeBorder(Color.white.opacity(0.08), lineWidth: 1)
                    )
                }

                earlyStateProgressTrack(completedStages: completedStages)
            }
            .padding(16)
            .background(
                LinearGradient(
                    colors: [
                        STRQPalette.surfaceHero,
                        STRQPalette.surfaceBase,
                        STRQPalette.backgroundPrimary
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                in: .rect(cornerRadius: 22)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 22)
                    .strokeBorder(Color.white.opacity(0.12), lineWidth: 1)
            )
            .overlay(alignment: .topLeading) {
                LinearGradient(
                    colors: [STRQBrand.steel.opacity(0.22), Color.clear],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .frame(height: 1)
                .padding(.horizontal, 18)
            }
            .shadow(color: .black.opacity(0.22), radius: 16, y: 6)
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 10)
            .animation(reduceMotion ? .easeOut(duration: 0.12) : .easeOut(duration: 0.5).delay(0.05), value: appeared)
        }
    }

    private func earlyStateSignalMark(icon: String, completedStages: Int) -> some View {
        ZStack(alignment: .bottomTrailing) {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.white.opacity(0.045))
                .frame(width: 72, height: 78)
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.10), lineWidth: 1)
                )

            Image(systemName: icon)
                .font(.system(size: 24, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 54, height: 54)
                .background(STRQBrand.steelGradient, in: .rect(cornerRadius: 16))
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.20), lineWidth: 1)
                )
                .offset(x: -10, y: -12)

            HStack(spacing: 3) {
                ForEach(0..<4, id: \.self) { index in
                    Circle()
                        .fill(index < completedStages ? STRQBrand.steel : Color.white.opacity(0.16))
                        .frame(width: 4, height: 4)
                }
            }
            .padding(.horizontal, 7)
            .padding(.vertical, 5)
            .background(Color.black.opacity(0.28), in: Capsule())
            .overlay(
                Capsule()
                    .strokeBorder(Color.white.opacity(0.08), lineWidth: 0.5)
            )
        }
        .frame(width: 78, height: 82)
    }

    private func earlyStateProgressTrack(completedStages: Int) -> some View {
        HStack(spacing: 5) {
            ForEach(0..<4, id: \.self) { index in
                Capsule()
                    .fill(index < completedStages ? STRQBrand.steel : Color.white.opacity(0.08))
                    .frame(maxWidth: .infinity, minHeight: 3, maxHeight: 3)
            }
        }
    }

    private var coachEarlyStateMessage: String {
        switch vm.dataMaturityTier {
        case .fresh:
            return L10n.tr("Today owns the next step. Coach will start shaping load and recovery once your first real workout is in.")
        case .firstSession:
            return L10n.tr("Baseline is set. Keep the week moving and Coach will sharpen the details quietly in the background.")
        case .earlyWeek:
            return L10n.tr("A little more real training data will make Coach's next calls feel much more personal.")
        case .established:
            return L10n.tr("You're on plan. Stay the course.")
        }
    }

    private var shouldShowCalibrationChecklist: Bool {
        vm.dataMaturityTier != .firstSession
    }

    private var calibrationChecklist: some View {
        let completed = vm.totalCompletedWorkouts
        let weekSessions = vm.weeklyStats.sessions
        let hasRecoveryContext = vm.hasCheckedInToday || vm.todaysReadiness != nil
        let calibrationAccent = Color(red: 0.50, green: 0.58, blue: 0.66)
        let calibrationInk = Color(red: 0.72, green: 0.78, blue: 0.84)
        let calibrationDim = Color(red: 0.08, green: 0.10, blue: 0.12)
        let completedSignal = STRQColors.successGreen

        let items: [(String, String, Bool)] = [
            (L10n.tr("Plan shape captured"), "doc.text.fill", vm.currentPlan != nil),
            (L10n.tr("Real training inputs logged"), "figure.strengthtraining.traditional", completed >= 1),
            (L10n.tr("Recovery context logged"), "heart.text.clipboard.fill", hasRecoveryContext),
            (L10n.tr("Week rhythm started"), "calendar.badge.clock", weekSessions >= 1)
        ]
        let completedCount = items.filter { $0.2 }.count
        let progress = CGFloat(completedCount) / CGFloat(items.count)

        return VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(calibrationAccent.opacity(0.14))
                    Image(systemName: "waveform.path.ecg")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(calibrationInk)
                }
                .frame(width: 30, height: 30)
                .overlay(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .strokeBorder(calibrationAccent.opacity(0.22), lineWidth: 1)
                )
                .accessibilityHidden(true)

                Text(L10n.tr("What STRQ has picked up"))
                    .font(.system(size: 11, weight: .black))
                    .tracking(1.1)
                    .foregroundStyle(calibrationInk)
                    .textCase(.uppercase)
                    .lineLimit(1)
                    .minimumScaleFactor(0.78)

                Spacer(minLength: 8)

                HStack(spacing: 4) {
                    ForEach(0..<items.count, id: \.self) { index in
                        Capsule()
                            .fill(index < completedCount ? completedSignal : calibrationAccent.opacity(0.24))
                            .frame(width: index < completedCount ? 12 : 5, height: 5)
                    }
                }
            }

            VStack(alignment: .leading, spacing: 14) {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(calibrationAccent.opacity(0.14))
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [calibrationInk.opacity(0.70), calibrationAccent.opacity(0.90)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: progress == 0 ? 0 : max(6, geo.size.width * progress))
                    }
                }
                .frame(height: 4)

                VStack(spacing: 7) {
                    ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                        HStack(spacing: 11) {
                            VStack(spacing: 3) {
                                ZStack {
                                    Circle()
                                        .fill(item.2 ? completedSignal.opacity(0.16) : calibrationAccent.opacity(0.09))
                                        .frame(width: 24, height: 24)
                                    Circle()
                                        .strokeBorder(item.2 ? completedSignal.opacity(0.62) : calibrationAccent.opacity(0.28), lineWidth: 1)
                                        .frame(width: 24, height: 24)
                                    Image(systemName: item.2 ? "checkmark" : "circle.fill")
                                        .font(.system(size: item.2 ? 10 : 5, weight: .black))
                                        .foregroundStyle(item.2 ? completedSignal : calibrationAccent.opacity(0.48))
                                }

                                if index < items.count - 1 {
                                    Capsule()
                                        .fill(item.2 ? completedSignal.opacity(0.42) : calibrationAccent.opacity(0.16))
                                        .frame(width: 2, height: 13)
                                }
                            }
                            .frame(width: 24)

                            Image(systemName: item.1)
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(item.2 ? calibrationInk : calibrationAccent.opacity(0.56))
                                .frame(width: 28, height: 28)
                                .background(
                                    RoundedRectangle(cornerRadius: 9, style: .continuous)
                                        .fill(Color.white.opacity(item.2 ? 0.055 : 0.030))
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 9, style: .continuous)
                                        .strokeBorder(Color.white.opacity(item.2 ? 0.090 : 0.045), lineWidth: 1)
                                )

                            Text(item.0)
                                .font(.subheadline.weight(item.2 ? .semibold : .medium))
                                .foregroundStyle(item.2 ? Color.primary : calibrationInk.opacity(0.62))
                                .lineLimit(2)
                                .fixedSize(horizontal: false, vertical: true)

                            Spacer(minLength: 0)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 9)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(Color.white.opacity(item.2 ? 0.045 : 0.020))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .strokeBorder(Color.white.opacity(item.2 ? 0.080 : 0.045), lineWidth: 1)
                        )
                    }
                }
            }
            .padding(14)
            .background(
                LinearGradient(
                    colors: [
                        calibrationDim,
                        STRQPalette.surfaceBase,
                        STRQPalette.backgroundCarbon
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                in: .rect(cornerRadius: 18)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .strokeBorder(calibrationAccent.opacity(0.18), lineWidth: 1)
            )
            .overlay(alignment: .topLeading) {
                LinearGradient(
                    colors: [calibrationInk.opacity(0.28), Color.clear],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .frame(height: 1)
                .padding(.horizontal, 16)
            }
            .shadow(color: .black.opacity(0.18), radius: 12, y: 5)
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 10)
        .animation(reduceMotion ? .easeOut(duration: 0.12) : .easeOut(duration: 0.5).delay(0.1), value: appeared)
    }

    // MARK: - Lift Tracker

    @ViewBuilder
    private var liftTrackerSection: some View {
        let stalled = vm.stalledExercises.prefix(2)
        let progressing = vm.progressingExercises.prefix(2)
        if !stalled.isEmpty || !progressing.isEmpty {
            VStack(alignment: .leading, spacing: 10) {
                ForgeSectionHeader(title: L10n.tr("Lift Tracker"))

                ForEach(Array(stalled)) { state in
                    liftRow(state: state, isStalled: true)
                }

                ForEach(Array(progressing)) { state in
                    liftRow(state: state, isStalled: false)
                }
            }
            .padding(.top, 4)
        }
    }

    private func liftRow(state: ExerciseProgressionState, isStalled: Bool) -> some View {
        let exercise = vm.library.exercise(byId: state.exerciseId)
        let color: Color = isStalled ? (state.plateauStatus == .regressing ? STRQPalette.danger : STRQPalette.warning) : STRQPalette.success

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
                    Text(isStalled ? state.plateauStatus.displayName : L10n.tr("coach.liftTracker.progressing", fallback: "Progressing"))
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(color)
                    if let next = state.suggestedNextWeight, !isStalled {
                        Text(L10n.format("Next: %.1fkg", next))
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

    // MARK: - Recent Change Bridge

    @ViewBuilder
    private var recentChangeBridge: some View {
        let timeline = CoachingMemoryService().buildTimeline(
            adjustments: vm.coachAdjustments,
            phaseState: vm.trainingPhaseState,
            planEvolutionSignals: vm.planEvolutionSignals,
            outlook: vm.phaseOutlook,
            physique: vm.physiqueOutcome,
            activeWeekAdjustment: vm.weekAdjustmentActive,
            nutritionTrackingEnabled: vm.profile.nutritionTrackingEnabled,
            limit: 1
        )
        if let latest = timeline.first {
            Button {
                showCoachingHistory = true
                Analytics.shared.track(.coach_viewed, ["surface": "memory_bridge"])
            } label: {
                CoachMemoryBridgeRow(entry: latest, totalCount: totalMemoryCount)
            }
            .buttonStyle(.plain)
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 10)
            .animation(reduceMotion ? .easeOut(duration: 0.12) : .easeOut(duration: 0.5).delay(0.16), value: appeared)
        } else if !vm.isEarlyStage {
            Button {
                showCoachingHistory = true
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "clock.arrow.circlepath")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(STRQBrand.steel)
                        .frame(width: 24, height: 24)
                        .background(STRQBrand.steelGradient.opacity(0.5), in: .rect(cornerRadius: 7))
                    VStack(alignment: .leading, spacing: 1) {
                        Text(L10n.tr("Coaching memory"))
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.primary)
                        Text(L10n.tr("No changes yet — every decision will be logged here."))
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
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
            .buttonStyle(.plain)
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 10)
            .animation(reduceMotion ? .easeOut(duration: 0.12) : .easeOut(duration: 0.5).delay(0.16), value: appeared)
        }
    }

    private var totalMemoryCount: Int {
        CoachingMemoryService().buildTimeline(
            adjustments: vm.coachAdjustments,
            phaseState: vm.trainingPhaseState,
            planEvolutionSignals: vm.planEvolutionSignals,
            outlook: vm.phaseOutlook,
            physique: vm.physiqueOutcome,
            activeWeekAdjustment: vm.weekAdjustmentActive,
            nutritionTrackingEnabled: vm.profile.nutritionTrackingEnabled,
            limit: 30
        ).count
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
                    weeklyReviewLabel(subtitle: L10n.tr("Review your week and adjust"), ready: true)
                }
            } else if vm.isEarlyStage {
                passiveWeeklyCheckInLabel(
                    subtitle: vm.sessionsUntilReviewReady == 0
                        ? L10n.tr("Almost there — one more workout rounds out the week")
                        : L10n.format(vm.sessionsUntilReviewReady == 1 ? "%d more workout and your first weekly read will come into focus" : "%d more workouts and your first weekly read will come into focus", vm.sessionsUntilReviewReady)
                )
            } else {
                Button {
                    vm.generateWeeklyReview()
                    showWeeklyReview = true
                } label: {
                    weeklyReviewLabel(subtitle: L10n.tr("Review your week and adjust"), ready: true)
                }
            }
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 10)
        .animation(reduceMotion ? .easeOut(duration: 0.12) : .easeOut(duration: 0.5).delay(0.18), value: appeared)
    }

    private func passiveWeeklyCheckInLabel(subtitle: String) -> some View {
        let weeklyPassiveAccent = Color(red: 0.16, green: 0.25, blue: 0.62)
        let weeklyPassiveInk = Color(red: 0.46, green: 0.56, blue: 0.92)
        let weeklyPassiveDim = Color(red: 0.03, green: 0.04, blue: 0.14)

        return HStack(alignment: .center, spacing: 12) {
            RoundedRectangle(cornerRadius: 2, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            weeklyPassiveInk.opacity(0.56),
                            weeklyPassiveAccent.opacity(0.22)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 3, height: 44)
                .accessibilityHidden(true)

            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                weeklyPassiveAccent.opacity(0.20),
                                weeklyPassiveDim.opacity(0.72)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                Image(systemName: "calendar.badge.clock")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(weeklyPassiveInk)
            }
            .frame(width: 38, height: 38)
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .strokeBorder(weeklyPassiveInk.opacity(0.20), lineWidth: 1)
            )
            .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 3) {
                Text(L10n.tr("Weekly Check-In"))
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(Color.white.opacity(0.62))
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)

            ZStack {
                Circle()
                    .strokeBorder(weeklyPassiveAccent.opacity(0.28), lineWidth: 1)
                    .frame(width: 20, height: 20)
                Circle()
                    .fill(weeklyPassiveInk.opacity(0.38))
                    .frame(width: 5, height: 5)
            }
            .accessibilityHidden(true)
        }
        .padding(14)
        .background(
            LinearGradient(
                colors: [
                    weeklyPassiveDim.opacity(0.92),
                    STRQPalette.surfaceBase.opacity(0.96),
                    weeklyPassiveAccent.opacity(0.10)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            in: .rect(cornerRadius: 14)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .strokeBorder(weeklyPassiveAccent.opacity(0.24), lineWidth: 1)
        )
        .overlay(alignment: .topLeading) {
            LinearGradient(
                colors: [weeklyPassiveInk.opacity(0.22), Color.clear],
                startPoint: .leading,
                endPoint: .trailing
            )
            .frame(height: 1)
            .padding(.horizontal, 16)
        }
    }

    private func weeklyReviewLabel(subtitle: String, ready: Bool) -> some View {
        HStack(spacing: 12) {
            Image(systemName: ready ? "doc.text.magnifyingglass" : "calendar.badge.clock")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.white)
                .frame(width: 36, height: 36)
                .background(STRQBrand.steelGradient, in: .rect(cornerRadius: 10))

            VStack(alignment: .leading, spacing: 2) {
                Text(L10n.tr("Weekly Check-In"))
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
                    Text(L10n.tr("Plan Quality"))
                        .font(.subheadline.weight(.semibold))
                    Text(quality.localizedOverallLabel)
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
}

// MARK: - More Signals Sheet

struct MoreSignalsSheet: View {
    let vm: AppViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var expandedInsightIds: Set<String> = []
    @State private var expandedRecIds: Set<String> = []

    var body: some View {
        ScrollView {
            VStack(spacing: 14) {
                let insights = Array(vm.highPriorityInsights.dropFirst())
                let recs = Array(vm.recommendations.dropFirst(vm.highPriorityInsights.isEmpty ? 1 : 0))

                if !insights.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        ForgeSectionHeader(title: L10n.tr("coach.moreSignals.watch", fallback: "Watch"))
                        ForEach(insights) { insight in
                            ExpandableInsightCard(
                                insight: insight,
                                actions: CoachActionMapper.actions(for: insight),
                                vm: vm,
                                isExpanded: Binding(
                                    get: { expandedInsightIds.contains(insight.id) },
                                    set: { v in if v { expandedInsightIds.insert(insight.id) } else { expandedInsightIds.remove(insight.id) } }
                                ),
                                onAction: { _ in }
                            )
                        }
                    }
                }

                if !recs.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        ForgeSectionHeader(title: L10n.tr("Recommendations"))
                        ForEach(recs) { rec in
                            ExpandableRecommendationCard(
                                recommendation: rec,
                                actions: CoachActionMapper.actions(for: rec),
                                vm: vm,
                                isExpanded: Binding(
                                    get: { expandedRecIds.contains(rec.id) },
                                    set: { v in if v { expandedRecIds.insert(rec.id) } else { expandedRecIds.remove(rec.id) } }
                                ),
                                onAction: { _ in }
                            )
                        }
                    }
                }

                if insights.isEmpty && recs.isEmpty {
                    VStack(spacing: 10) {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.title)
                            .foregroundStyle(STRQPalette.success)
                        Text(L10n.tr("Nothing else to flag"))
                            .font(.subheadline.weight(.semibold))
                        Text(L10n.tr("Coach is satisfied with the rest of your picture."))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top, 40)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 32)
        }
        .background(Color(.systemBackground))
        .navigationTitle(L10n.tr("More signals"))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(L10n.tr("Done")) { dismiss() }
                    .font(.subheadline.weight(.semibold))
            }
        }
    }
}
