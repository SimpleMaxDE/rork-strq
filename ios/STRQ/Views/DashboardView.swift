import SwiftUI

struct DashboardView: View {
    let vm: AppViewModel
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var appeared: Bool = false
    @State private var showReadinessCheckIn: Bool = false
    @State private var showWeeklyReview: Bool = false
    @State private var showNutritionLog: Bool = false
    @State private var showSleepLog: Bool = false
    @State private var showWeightLog: Bool = false
    @State private var showWeekPulseDetails: Bool = false
    @State private var showActivationRoadmapDetails: Bool = false

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                premiumTodayFirstViewport
                lowerTodayRunway
            }
            .padding(.bottom, 32)
        }
        .background {
            LinearGradient(
                colors: [STRQPalette.backgroundPrimary, STRQPalette.backgroundCarbon],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        }
        .navigationTitle(L10n.tr("Today"))
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            withAnimation(reduceMotion ? .easeOut(duration: 0.12) : .easeOut(duration: 0.5)) { appeared = true }
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

    // MARK: - Today Lower Runway

    private var lowerTodayRunway: some View {
        let bridge = postWorkoutBridge

        return VStack(spacing: 12) {
            if let bridge {
                postWorkoutBridgeCard(bridge)
            }

            lowerGuidanceBlock

            scheduleTimeline

            dailySignalsRow

            if let since = vm.dailyBriefing?.sinceLast, bridge == nil {
                sinceLastCard(since)
            }

            if !vm.isEarlyStage {
                weekPulse
            }
        }
        .padding(.horizontal, 16)
    }

    @ViewBuilder
    private var lowerGuidanceBlock: some View {
        if let roadmap = vm.activationRoadmap {
            activationRunwayCard(roadmap)
        } else if let comeback = vm.comebackGuidance {
            comebackRunwayCard(comeback)
        } else if let guidance = vm.earlyStateGuidance {
            earlyStageHint(guidance)
        }
    }

    private func activationRunwayCard(_ roadmap: ActivationRoadmap) -> some View {
        sandowRunwayCard(accent: STRQBrand.steel) {
            VStack(alignment: .leading, spacing: 12) {
                Button {
                    withAnimation(reduceMotion ? .easeOut(duration: 0.12) : .snappy(duration: 0.22)) {
                        showActivationRoadmapDetails.toggle()
                    }
                } label: {
                    HStack(alignment: .center, spacing: 12) {
                        sandowIconBox(
                            icon: "checkmark.seal.fill",
                            tint: roadmap.progress >= 1 ? STRQPalette.signalGreen : STRQBrand.steel,
                            size: 38,
                            cornerRadius: 12
                        )

                        VStack(alignment: .leading, spacing: 5) {
                            Text(L10n.tr("activationRoadmap.title", fallback: "Your first week"))
                                .font(.system(size: 17, weight: .black, design: .rounded))
                                .foregroundStyle(STRQPalette.textPrimary)
                                .lineLimit(1)
                                .minimumScaleFactor(0.76)

                            Text(L10n.format(
                                "activationRoadmap.progressDone",
                                fallback: "%d/%d done",
                                roadmap.completedCount,
                                roadmap.steps.count
                            ))
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(STRQPalette.textSecondary)
                        }

                        Spacer(minLength: 8)

                        Image(systemName: showActivationRoadmapDetails ? "chevron.up" : "chevron.down")
                            .font(.system(size: 13, weight: .black))
                            .foregroundStyle(STRQPalette.textMuted)
                            .frame(width: 22, height: 22)
                    }
                    .contentShape(.rect)
                }
                .buttonStyle(.plain)

                sandowProgressBar(progress: roadmap.progress, tint: STRQBrand.steel)

                if showActivationRoadmapDetails {
                    VStack(spacing: 10) {
                        ForEach(Array(roadmap.steps.enumerated()), id: \.element.id) { index, step in
                            activationStepRow(step, isLast: index == roadmap.steps.count - 1)
                        }
                    }
                    .transition(.opacity.combined(with: .move(edge: .top)))
                } else if let nextStep = activationNextStep(for: roadmap) {
                    HStack(alignment: .top, spacing: 10) {
                        sandowIconBox(
                            icon: nextStep.isComplete ? "checkmark" : nextStep.icon,
                            tint: nextStep.isComplete ? STRQPalette.signalGreen : STRQBrand.steel,
                            size: 32,
                            cornerRadius: 10
                        )

                        VStack(alignment: .leading, spacing: 3) {
                            Text(nextStepLine(for: nextStep))
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(STRQPalette.textPrimary.opacity(0.90))
                                .lineLimit(1)
                                .minimumScaleFactor(0.78)

                            Text(activationSubheadLine(roadmap.subhead))
                                .font(.system(size: 12, weight: .medium))
                                .foregroundStyle(STRQPalette.textMuted)
                                .lineLimit(2)
                                .fixedSize(horizontal: false, vertical: true)
                        }

                        Spacer(minLength: 0)
                    }
                    .padding(.top, 2)
                }
            }
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 8)
        .animation(reduceMotion ? .easeOut(duration: 0.12) : .easeOut(duration: 0.5).delay(0.06), value: appeared)
        .onAppear {
            Analytics.shared.track(.activation_roadmap_viewed, [
                "completed": String(roadmap.completedCount),
                "surface": "today"
            ])
        }
    }

    private func activationStepRow(_ step: ActivationRoadmap.Step, isLast: Bool) -> some View {
        HStack(alignment: .top, spacing: 11) {
            VStack(spacing: 4) {
                ZStack {
                    Circle()
                        .fill(activationStepFill(step))
                        .frame(width: 26, height: 26)
                    if step.isActive && !step.isComplete {
                        Circle()
                            .strokeBorder(STRQBrand.steel.opacity(0.55), lineWidth: 1.2)
                            .frame(width: 26, height: 26)
                    }
                    Image(systemName: step.isComplete ? "checkmark" : step.icon)
                        .font(.system(size: 10, weight: .black))
                        .foregroundStyle(activationStepTint(step))
                }

                if !isLast {
                    Rectangle()
                        .fill(Color.white.opacity(0.07))
                        .frame(width: 1, height: 18)
                }
            }

            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 6) {
                    Text(step.title)
                        .font(.system(size: 14, weight: step.isActive ? .black : .semibold))
                        .foregroundStyle(step.isComplete || step.isActive ? STRQPalette.textPrimary : STRQPalette.textSecondary)
                        .lineLimit(1)

                    if step.isActive && !step.isComplete {
                        Text(L10n.tr("NEXT"))
                            .font(.system(size: 9, weight: .black))
                            .foregroundStyle(STRQBrand.steel)
                            .padding(.horizontal, 6)
                            .frame(height: 18)
                            .background(STRQBrand.steel.opacity(0.12), in: Capsule())
                    }
                }

                Text(activationLearningLine(step.learning))
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(step.isComplete ? STRQPalette.signalGreen : STRQPalette.textMuted)
                    .lineLimit(1)
                    .minimumScaleFactor(0.78)
            }

            Spacer(minLength: 0)
        }
    }

    private func activationStepFill(_ step: ActivationRoadmap.Step) -> AnyShapeStyle {
        if step.isComplete {
            return AnyShapeStyle(STRQPalette.signalGreen.opacity(0.20))
        }
        if step.isActive {
            return AnyShapeStyle(STRQBrand.steel.opacity(0.16))
        }
        return AnyShapeStyle(Color.white.opacity(0.055))
    }

    private func activationStepTint(_ step: ActivationRoadmap.Step) -> Color {
        if step.isComplete {
            return STRQPalette.signalGreen
        }
        if step.isActive {
            return STRQBrand.steel
        }
        return STRQPalette.textMuted
    }

    private func activationNextStep(for roadmap: ActivationRoadmap) -> ActivationRoadmap.Step? {
        roadmap.steps.first(where: { !$0.isComplete }) ?? roadmap.steps.last
    }

    private func nextStepLine(for step: ActivationRoadmap.Step) -> String {
        if step.isComplete {
            return L10n.tr("activationRoadmap.complete", fallback: "Week one is complete.")
        }
        return step.title
    }

    private func activationLearningLine(_ line: String) -> String {
        switch line {
        case "Progressionsintelligenz aktiv":
            return "Fortschrittssignal aktiv"
        case "Coach erkennt deine Muster":
            return "Muster werden lesbar"
        default:
            return line
        }
    }

    private func activationSubheadLine(_ line: String) -> String {
        if line == "Wochensignal ist aktiv — der Coach ist vollständig auf dich kalibriert." {
            return "Wochensignal ist aktiv — dein Trainingsrhythmus wird lesbar."
        }
        return line
    }

    private func comebackRunwayCard(_ comeback: ComebackGuidance) -> some View {
        let tint = ForgeTheme.color(for: comeback.colorName)

        return sandowRunwayCard(accent: tint) {
            VStack(alignment: .leading, spacing: 14) {
                HStack(alignment: .top, spacing: 12) {
                    sandowIconBox(icon: comeback.icon, tint: tint)

                    VStack(alignment: .leading, spacing: 5) {
                        HStack(spacing: 7) {
                            Text(comeback.tier.eyebrow)
                                .font(.system(size: 10, weight: .black))
                                .foregroundStyle(tint)
                                .lineLimit(1)

                            Text(L10n.format("%dD SINCE LAST WORKOUT", comeback.daysSinceLastWorkout))
                                .font(.system(size: 10, weight: .black).monospacedDigit())
                                .foregroundStyle(STRQPalette.textMuted)
                                .lineLimit(1)
                                .minimumScaleFactor(0.72)
                        }

                        Text(comeback.headline)
                            .font(.system(size: 18, weight: .black, design: .rounded))
                            .foregroundStyle(STRQPalette.textPrimary)
                            .lineLimit(2)
                            .minimumScaleFactor(0.78)

                        Text(comeback.detail)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(STRQPalette.textSecondary)
                            .lineLimit(3)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Spacer(minLength: 0)
                }

                if !comeback.steps.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(Array(comeback.steps.prefix(3).enumerated()), id: \.offset) { _, step in
                            HStack(alignment: .top, spacing: 8) {
                                Circle()
                                    .fill(tint)
                                    .frame(width: 5, height: 5)
                                    .padding(.top, 6)
                                Text(step)
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundStyle(STRQPalette.textPrimary.opacity(0.84))
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                    }
                }

                if comeback.offersLighterSession || !vm.hasCheckedInToday {
                    HStack(spacing: 10) {
                        if !vm.hasCheckedInToday {
                            sandowSecondaryButton(icon: "heart.text.clipboard", title: L10n.tr("Check in")) {
                                Analytics.shared.track(.comeback_cta_tapped, [
                                    "action": "checkin",
                                    "tier": comeback.tier.rawValue,
                                    "surface": "today"
                                ])
                                showReadinessCheckIn = true
                            }
                        }

                        if comeback.offersLighterSession {
                            sandowSecondaryButton(icon: "leaf.arrow.triangle.circlepath", title: L10n.tr("Ease next workout"), tint: tint) {
                                Analytics.shared.track(.comeback_cta_tapped, [
                                    "action": "ease",
                                    "tier": comeback.tier.rawValue,
                                    "surface": "today"
                                ])
                                vm.applyComebackLighterSession()
                            }
                        }
                    }
                }
            }
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 8)
        .animation(reduceMotion ? .easeOut(duration: 0.12) : .easeOut(duration: 0.5).delay(0.06), value: appeared)
        .onAppear {
            Analytics.shared.track(.comeback_card_viewed, [
                "tier": comeback.tier.rawValue,
                "days_since": String(comeback.daysSinceLastWorkout),
                "surface": "today"
            ])
        }
    }

    private func sandowRunwayCard<Content: View>(
        accent: Color? = nil,
        padding: CGFloat = 14,
        @ViewBuilder content: () -> Content
    ) -> some View {
        content()
            .padding(padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                LinearGradient(
                    colors: [
                        STRQPalette.surfaceRaised,
                        STRQPalette.surfaceBase,
                        STRQPalette.backgroundDeep
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                in: .rect(cornerRadius: 22, style: .continuous)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .strokeBorder((accent ?? STRQPalette.borderHairline).opacity(accent == nil ? 0.18 : 0.24), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.22), radius: 16, y: 8)
    }

    private func lowerSectionHeader(
        title: String,
        subtitle: String? = nil,
        trailing: String? = nil,
        accent: Color = STRQBrand.steel
    ) -> some View {
        HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .leading, spacing: subtitle == nil ? 0 : 3) {
                Text(title)
                    .font(.system(size: 17, weight: .black, design: .rounded))
                    .foregroundStyle(STRQPalette.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.76)

                if let subtitle {
                    Text(subtitle)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(STRQPalette.textMuted)
                        .lineLimit(1)
                        .minimumScaleFactor(0.76)
                }
            }

            Spacer(minLength: 8)

            if let trailing {
                Text(trailing)
                    .font(.system(size: 11, weight: .black).monospacedDigit())
                    .foregroundStyle(accent)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)
                    .padding(.horizontal, 10)
                    .frame(height: 28)
                    .background(accent.opacity(0.12), in: Capsule())
                    .overlay(Capsule().strokeBorder(accent.opacity(0.22), lineWidth: 1))
            }
        }
    }

    private func sandowIconBox(
        icon: String,
        tint: Color,
        size: CGFloat = 40,
        cornerRadius: CGFloat = 13
    ) -> some View {
        Image(systemName: icon)
            .font(.system(size: size * 0.34, weight: .black))
            .foregroundStyle(tint)
            .frame(width: size, height: size)
            .background(tint.opacity(0.14), in: .rect(cornerRadius: cornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .strokeBorder(tint.opacity(0.18), lineWidth: 1)
            )
    }

    private func sandowProgressBar(progress: Double, tint: Color) -> some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.white.opacity(0.075))
                Capsule()
                    .fill(tint.gradient)
                    .frame(width: max(6, geo.size.width * min(max(progress, 0), 1)))
            }
        }
        .frame(height: 5)
    }

    private func sandowSecondaryButton(
        icon: String,
        title: String,
        tint: Color = STRQBrand.steel,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 7) {
                Image(systemName: icon)
                    .font(.system(size: 12, weight: .black))
                Text(title)
                    .font(.system(size: 13, weight: .black))
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)
            }
            .foregroundStyle(STRQPalette.textPrimary.opacity(0.92))
            .frame(maxWidth: .infinity)
            .frame(height: 42)
            .background(Color.white.opacity(0.06), in: .rect(cornerRadius: 13, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 13, style: .continuous)
                    .strokeBorder(tint.opacity(0.18), lineWidth: 1)
            )
        }
        .buttonStyle(.strqPressable)
    }

    // MARK: - Premium Today First Viewport

    private struct TodayDecisionSignal: Identifiable {
        let id: String
        let icon: String
        let label: String
        let value: String
        let detail: String
        let tint: Color
        let action: (() -> Void)?
    }

    private var premiumTodayFirstViewport: some View {
        VStack(spacing: 12) {
            premiumTodayHeader

            if let briefing = vm.dailyBriefing {
                premiumSessionPoster(briefing)
            } else {
                premiumLoadingPoster
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 8)
        .animation(reduceMotion ? .easeOut(duration: 0.12) : .easeOut(duration: 0.5).delay(0.04), value: appeared)
    }

    private var premiumTodayHeader: some View {
        let name = vm.profile.name.isEmpty ? L10n.tr("Athlete") : vm.profile.name

        return HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(todayText(en: "Next move", de: "Nächster Schritt"))
                    .font(.system(size: 15, weight: .black))
                    .foregroundStyle(STRQPalette.textPrimary)
                    .lineLimit(1)

                Text("\(todayDateLabel) · \(name)")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(STRQPalette.textMuted)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)
            }

            Spacer(minLength: 8)

            HStack(spacing: 7) {
                if vm.streak > 0 {
                    HStack(spacing: 5) {
                        Image(systemName: "flame.fill")
                            .font(.system(size: 10, weight: .bold))
                        Text("\(vm.streak)")
                            .font(.system(size: 12, weight: .black).monospacedDigit())
                    }
                    .foregroundStyle(STRQPalette.gold)
                    .padding(.horizontal, 8)
                    .frame(height: 30)
                    .background(Color.white.opacity(0.055), in: Capsule())
                    .overlay(Capsule().strokeBorder(STRQPalette.gold.opacity(0.22), lineWidth: 1))
                }

                Text(vm.profile.name.prefix(1).isEmpty ? "A" : String(vm.profile.name.prefix(1)).uppercased())
                    .font(.system(size: 14, weight: .black))
                    .foregroundStyle(STRQPalette.backgroundDeep)
                    .frame(width: 38, height: 38)
                    .background(Color.white, in: Circle())
                    .overlay(Circle().strokeBorder(Color.white.opacity(0.36), lineWidth: 1))
                    .shadow(color: .black.opacity(0.28), radius: 14, y: 6)
            }
        }
        .frame(maxWidth: .infinity, minHeight: 46, alignment: .center)
    }

    private func premiumSessionPoster(_ briefing: DailyBriefing) -> some View {
        let primary = briefing.primary
        let day = todayDecisionWorkout(for: primary)
        let accent = todayCommandAccent(for: primary)

        return VStack(spacing: 0) {
            ZStack(alignment: .bottomLeading) {
                premiumPosterBackdrop(accent: accent)

                VStack(alignment: .leading, spacing: 14) {
                    HStack(alignment: .center, spacing: 10) {
                        premiumCommandBadge(primary: primary, accent: accent)

                        Spacer(minLength: 8)

                        premiumReadinessSeal(accent: accent)
                    }

                    Spacer(minLength: 44)

                    VStack(alignment: .leading, spacing: 8) {
                        Text(premiumDecisionEyebrow(for: primary))
                            .font(.system(size: 10, weight: .black))
                            .tracking(1.2)
                            .foregroundStyle(accent)
                            .lineLimit(1)

                        Text(premiumDecisionTitle(primary: primary, day: day))
                            .font(.system(size: 32, weight: .black, design: .rounded))
                            .foregroundStyle(.white)
                            .lineLimit(2)
                            .minimumScaleFactor(0.66)

                        if let focus = premiumFocusLine(for: day) {
                            Text(focus)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(.white.opacity(0.76))
                                .lineLimit(1)
                                .minimumScaleFactor(0.76)
                        }
                    }

                    premiumCoachReason(primary: primary, day: day, briefing: briefing, accent: accent)
                }
                .padding(18)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 326)

            VStack(spacing: 12) {
                HStack(spacing: 8) {
                    ForEach(Array(todayDecisionSignals.prefix(3))) { signal in
                        premiumSignalTile(signal)
                    }
                }

                premiumPrimaryAction(primary: primary, day: day)
            }
            .padding(14)
            .background(
                LinearGradient(
                    colors: [
                        STRQPalette.surfaceRaised,
                        STRQPalette.surfaceBase,
                        STRQPalette.backgroundCarbon
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
        }
        .clipShape(.rect(cornerRadius: 26, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .strokeBorder(Color.white.opacity(0.11), lineWidth: 1)
                .allowsHitTesting(false)
        )
        .shadow(color: .black.opacity(0.34), radius: 28, y: 18)
    }

    private var premiumLoadingPoster: some View {
        VStack(alignment: .leading, spacing: 14) {
            premiumCommandBadge(
                title: todayText(en: "Today", de: "Heute"),
                icon: "bolt.fill",
                accent: STRQBrand.steel
            )

            Spacer(minLength: 72)

            Text(todayText(en: "STRQ is reading today.", de: "STRQ liest den Tag."))
                .font(.system(size: 30, weight: .black, design: .rounded))
                .foregroundStyle(.white)

            Text(todayText(en: "Your training decision will appear here.", de: "Deine Trainingsentscheidung erscheint hier."))
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(STRQPalette.textSecondary)
        }
        .padding(18)
        .frame(maxWidth: .infinity, minHeight: 430, alignment: .leading)
        .background(STRQPalette.surfaceRaised, in: .rect(cornerRadius: 26))
        .overlay(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .strokeBorder(Color.white.opacity(0.10), lineWidth: 1)
        )
    }

    private func premiumPosterBackdrop(accent: Color) -> some View {
        ZStack {
            LinearGradient(
                colors: [
                    STRQPalette.backgroundDeep,
                    STRQPalette.surfaceStrong,
                    STRQPalette.backgroundCarbon
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            VStack(spacing: 12) {
                ForEach(0..<9, id: \.self) { index in
                    Rectangle()
                        .fill(index.isMultiple(of: 3) ? accent.opacity(0.18) : Color.white.opacity(0.035))
                        .frame(height: index.isMultiple(of: 3) ? 2 : 1)
                        .offset(x: CGFloat(index % 3) * 18)
                }
            }
            .rotationEffect(.degrees(-12))
            .scaleEffect(1.22)
            .allowsHitTesting(false)

            HStack(alignment: .center, spacing: 12) {
                VStack(spacing: 10) {
                    ForEach(0..<3, id: \.self) { index in
                        RoundedRectangle(cornerRadius: 3, style: .continuous)
                            .fill(Color.white.opacity(index == 1 ? 0.14 : 0.08))
                            .frame(width: 7, height: CGFloat(52 + index * 18))
                    }
                }

                RoundedRectangle(cornerRadius: 4, style: .continuous)
                    .fill(Color.white.opacity(0.18))
                    .frame(width: 118, height: 8)

                VStack(spacing: 10) {
                    ForEach(0..<3, id: \.self) { index in
                        RoundedRectangle(cornerRadius: 3, style: .continuous)
                            .fill(Color.white.opacity(index == 1 ? 0.14 : 0.08))
                            .frame(width: 7, height: CGFloat(52 + index * 18))
                    }
                }
            }
            .opacity(0.34)
            .offset(x: 92, y: -36)
            .rotationEffect(.degrees(-8))
            .allowsHitTesting(false)

            STRQIconView(.barbell, size: 122, tint: .white.opacity(0.10))
                .offset(x: 86, y: 58)
                .allowsHitTesting(false)

            LinearGradient(
                colors: [
                    Color.clear,
                    STRQPalette.backgroundDeep.opacity(0.32),
                    STRQPalette.backgroundDeep.opacity(0.92)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        }
    }

    private func premiumCommandBadge(primary: DailyBriefing.Primary, accent: Color) -> some View {
        premiumCommandBadge(
            title: premiumCommandBadgeTitle(for: primary),
            icon: primary.icon,
            accent: accent
        )
    }

    private func premiumCommandBadge(title: String, icon: String, accent: Color) -> some View {
        HStack(spacing: 7) {
            Image(systemName: icon)
                .font(.system(size: 10, weight: .black))
            Text(title)
                .font(.system(size: 10, weight: .black))
                .tracking(1.0)
                .lineLimit(1)
                .minimumScaleFactor(0.72)
        }
        .foregroundStyle(accent)
        .padding(.horizontal, 10)
        .frame(height: 30)
        .background(Color.black.opacity(0.26), in: .rect(cornerRadius: 10))
        .overlay(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .strokeBorder(accent.opacity(0.24), lineWidth: 1)
        )
    }

    private func premiumReadinessSeal(accent: Color) -> some View {
        let score = vm.todaysReadiness?.readinessScore ?? vm.effectiveRecoveryScore
        let tint = vm.todaysReadiness.map { ForgeTheme.recoveryColor(for: $0.readinessScore) } ?? accent

        return HStack(spacing: 7) {
            Text("\(score)")
                .font(.system(size: 13, weight: .black).monospacedDigit())
            Text(L10n.tr("Recovery"))
                .font(.system(size: 10, weight: .bold))
                .lineLimit(1)
                .minimumScaleFactor(0.78)
        }
        .foregroundStyle(.white)
        .padding(.horizontal, 10)
        .frame(height: 30)
        .background(Color.white.opacity(0.075), in: Capsule())
        .overlay(Capsule().strokeBorder(tint.opacity(0.28), lineWidth: 1))
    }

    private func premiumCoachReason(
        primary: DailyBriefing.Primary,
        day: WorkoutDay?,
        briefing: DailyBriefing,
        accent: Color
    ) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "quote.opening")
                .font(.system(size: 12, weight: .black))
                .foregroundStyle(accent)
                .frame(width: 28, height: 28)
                .background(accent.opacity(0.14), in: .rect(cornerRadius: 9))

            VStack(alignment: .leading, spacing: 4) {
                Text(todayText(en: "Why this workout", de: "Warum dieses Workout"))
                    .font(.system(size: 10, weight: .black))
                    .tracking(0.8)
                    .foregroundStyle(.white.opacity(0.46))
                    .lineLimit(1)

                Text(premiumReasonCopy(primary: primary, day: day, briefing: briefing))
                    .font(.system(size: 13, weight: .semibold))
                    .lineSpacing(2)
                    .foregroundStyle(.white.opacity(0.86))
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)
        }
        .padding(12)
        .background(Color.black.opacity(0.26), in: .rect(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(Color.white.opacity(0.08), lineWidth: 1)
        )
    }

    @ViewBuilder
    private func premiumSignalTile(_ signal: TodayDecisionSignal) -> some View {
        let content = VStack(alignment: .leading, spacing: 7) {
            HStack(spacing: 6) {
                Image(systemName: signal.icon)
                    .font(.system(size: 10, weight: .black))
                    .foregroundStyle(signal.tint)

                Text(signal.label)
                    .font(.system(size: 9, weight: .black))
                    .tracking(0.1)
                    .foregroundStyle(STRQPalette.textMuted)
                    .lineLimit(1)
                    .minimumScaleFactor(0.68)
            }

            Text(signal.value)
                .font(.system(size: 17, weight: .black, design: .rounded).monospacedDigit())
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.66)

            Text(signal.detail)
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(STRQPalette.textSecondary)
                .lineLimit(1)
                .minimumScaleFactor(0.62)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity, minHeight: 78, alignment: .leading)
        .background(Color.white.opacity(0.045), in: .rect(cornerRadius: 15))
        .overlay(
            RoundedRectangle(cornerRadius: 15, style: .continuous)
                .strokeBorder(signal.tint.opacity(0.16), lineWidth: 1)
        )

        if let action = signal.action {
            Button(action: action) { content }
                .buttonStyle(.strqPressable)
        } else {
            content
        }
    }

    @ViewBuilder
    private func premiumPrimaryAction(primary: DailyBriefing.Primary, day: WorkoutDay?) -> some View {
        switch primary.kind {
        case .checkInBeforeTraining:
            HStack(spacing: 10) {
                premiumCTA(icon: "heart.text.clipboard", title: L10n.tr("Check in"), tone: .primary) {
                    showReadinessCheckIn = true
                }

                if let day {
                    premiumCTA(icon: "bolt.fill", title: L10n.tr("Preview workout"), tone: .secondary) {
                        vm.prepareWorkoutHandoff(day: day)
                    }
                    .accessibilityIdentifier("strq.today.start-workout")
                }
            }
        case .logBodyWeight:
            premiumCTA(icon: "scalemass.fill", title: primary.ctaTitle, tone: .primary) {
                showWeightLog = true
            }
        case .recoveryDay where day == nil:
            premiumCTA(icon: vm.hasCheckedInToday ? "moon.zzz.fill" : "heart.text.clipboard", title: vm.hasCheckedInToday ? todayText(en: "Log sleep", de: "Schlaf eintragen") : L10n.tr("Check in"), tone: .primary) {
                if vm.hasCheckedInToday {
                    showSleepLog = true
                } else {
                    showReadinessCheckIn = true
                }
            }
        default:
            if let day {
                premiumCTA(icon: primary.kind == .resumeWorkout ? "play.fill" : "bolt.fill", title: premiumWorkoutActionTitle(for: primary), tone: .primary) {
                    vm.prepareWorkoutHandoff(day: day)
                }
                .accessibilityIdentifier("strq.today.start-workout")
            } else {
                premiumCTA(icon: "heart.text.clipboard", title: L10n.tr("Check in"), tone: .primary) {
                    showReadinessCheckIn = true
                }
            }
        }
    }

    private enum PremiumCTATone: Equatable {
        case primary
        case secondary
    }

    private func premiumCTA(icon: String, title: String, tone: PremiumCTATone, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 9) {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .black))
                Text(title)
                    .font(.system(size: tone == .primary ? 16 : 13, weight: .black))
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)
            }
            .foregroundStyle(tone == .primary ? STRQPalette.backgroundDeep : STRQPalette.textPrimary)
            .frame(maxWidth: .infinity)
            .frame(height: 54)
            .background {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(premiumCTAFill(for: tone))
            }
            .overlay(alignment: .top) {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.white.opacity(tone == .primary ? 0.36 : 0.08))
                    .frame(height: 24)
                    .allowsHitTesting(false)
            }
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .strokeBorder(Color.white.opacity(tone == .primary ? 0.36 : 0.12), lineWidth: 1)
            )
            .shadow(color: tone == .primary ? Color.white.opacity(0.08) : Color.clear, radius: 14, y: 6)
            .shadow(color: .black.opacity(tone == .primary ? 0.30 : 0.10), radius: 18, y: 9)
        }
        .buttonStyle(.strqPressable)
    }

    private func premiumCTAFill(for tone: PremiumCTATone) -> AnyShapeStyle {
        if tone == .primary {
            return AnyShapeStyle(
                LinearGradient(
                    colors: [Color.white, Color(red: 0.88, green: 0.89, blue: 0.91)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
        }

        return AnyShapeStyle(
            LinearGradient(
                colors: [Color.white.opacity(0.08), Color.white.opacity(0.045)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }

    private var todayDecisionSignals: [TodayDecisionSignal] {
        let weeklyTarget = max(1, vm.profile.daysPerWeek)
        let recoveryScore = vm.todaysReadiness?.readinessScore ?? vm.effectiveRecoveryScore
        let sleepValue = vm.averageSleepHours > 0 ? String(format: "%.1fh", vm.averageSleepHours) : "—"
        let sleepDetail = vm.averageSleepHours > 0 ? todayText(en: "7-day avg", de: "7 Tage Ø") : todayText(en: "Log needed", de: "Eintrag offen")
        let rhythmDetail = vm.weeklyStats.sessions >= weeklyTarget ? todayText(en: "Target met", de: "Ziel erreicht") : todayText(en: "Planned slot", de: "Geplante Einheit")

        return [
            TodayDecisionSignal(
                id: "recovery",
                icon: vm.hasCheckedInToday ? "checkmark.circle.fill" : "heart.text.clipboard",
                label: L10n.tr("Recovery"),
                value: "\(recoveryScore)%",
                detail: recoveryEvidenceDetail(for: recoveryScore),
                tint: ForgeTheme.recoveryColor(for: recoveryScore),
                action: vm.hasCheckedInToday ? nil : { showReadinessCheckIn = true }
            ),
            TodayDecisionSignal(
                id: "sleep",
                icon: "moon.zzz.fill",
                label: L10n.tr("Sleep"),
                value: sleepValue,
                detail: sleepDetail,
                tint: ForgeTheme.sleepColor(for: vm.averageSleepHours),
                action: { showSleepLog = true }
            ),
            TodayDecisionSignal(
                id: "week",
                icon: "calendar.badge.checkmark",
                label: todayText(en: "Rhythm", de: "Rhythmus"),
                value: "\(vm.weeklyStats.sessions)/\(weeklyTarget)",
                detail: rhythmDetail,
                tint: vm.weeklyStats.sessions >= weeklyTarget ? STRQPalette.signalGreen : STRQBrand.steel,
                action: nil
            )
        ]
    }

    private func todayDecisionWorkout(for primary: DailyBriefing.Primary) -> WorkoutDay? {
        switch primary.kind {
        case .prepNextSession, .recoveryDay, .logBodyWeight:
            return vm.todaysWorkout ?? vm.nextWorkout
        default:
            return vm.todaysWorkout ?? vm.nextWorkout
        }
    }

    private func premiumDecisionTitle(primary: DailyBriefing.Primary, day: WorkoutDay?) -> String {
        switch primary.kind {
        case .trainToday:
            return day.map { localizedWorkoutName($0.name) } ?? primary.title
        case .checkInBeforeTraining:
            return L10n.tr("Check in, then train")
        case .resumeWorkout:
            return L10n.tr("Resume Workout")
        case .recoverToday:
            return L10n.tr("Keep it light today")
        case .startFirstSession:
            return L10n.tr("Start your first workout")
        case .prepNextSession:
            return day.map { localizedWorkoutName($0.name) } ?? primary.title
        default:
            return primary.title
        }
    }

    private func premiumDecisionEyebrow(for primary: DailyBriefing.Primary) -> String {
        switch primary.kind {
        case .trainToday:
            return todayText(en: "TRAIN TODAY", de: "HEUTE TRAINIEREN")
        case .checkInBeforeTraining:
            return todayText(en: "READINESS FIRST", de: "ERST CHECK-IN")
        case .resumeWorkout:
            return todayText(en: "IN PROGRESS", de: "LÄUFT")
        case .recoverToday, .recoveryDay:
            return todayText(en: "RECOVERY CALL", de: "ERHOLUNG HEUTE")
        case .startFirstSession:
            return todayText(en: "WORKOUT ONE", de: "WORKOUT EINS")
        case .prepNextSession:
            return todayText(en: "NEXT SESSION", de: "NÄCHSTE EINHEIT")
        case .logBodyWeight:
            return todayText(en: "QUICK LOG", de: "KURZER LOG")
        case .logCompletion:
            return todayText(en: "TODAY", de: "HEUTE")
        }
    }

    private func premiumCommandBadgeTitle(for primary: DailyBriefing.Primary) -> String {
        switch primary.kind {
        case .trainToday, .checkInBeforeTraining, .resumeWorkout, .recoverToday, .startFirstSession:
            return L10n.tr("TRAINING DAY")
        case .prepNextSession:
            return todayText(en: "PREP RECOMMENDED", de: "VORBEREITEN")
        case .recoveryDay:
            return L10n.tr("Recovery")
        case .logBodyWeight:
            return todayText(en: "BODY DATA", de: "KÖRPERDATEN")
        case .logCompletion:
            return todayText(en: "TODAY", de: "HEUTE")
        }
    }

    private func premiumReasonCopy(primary: DailyBriefing.Primary, day: WorkoutDay?, briefing: DailyBriefing) -> String {
        switch primary.kind {
        case .trainToday:
            return plannedExposureReason(for: day)
        case .checkInBeforeTraining:
            return todayText(
                en: "A quick check-in lets STRQ tune today before the first working set.",
                de: "Ein kurzer Check-in stimmt STRQ vor dem ersten Arbeitssatz auf heute ab."
            )
        case .resumeWorkout:
            return todayText(
                en: "The session is already open; finish the signal you started.",
                de: "Die Einheit läuft bereits; schließe das begonnene Signal sauber ab."
            )
        case .recoverToday:
            return todayText(
                en: "The useful move is lighter work that you can actually absorb.",
                de: "Der sinnvolle Reiz ist heute leichter und gut verarbeitbar."
            )
        case .startFirstSession:
            return todayText(
                en: "Workout one gives STRQ the baseline it needs for real coaching.",
                de: "Workout eins gibt STRQ die Baseline für echtes Coaching."
            )
        case .prepNextSession:
            return plannedExposureReason(for: day)
        case .logBodyWeight:
            return todayText(
                en: "One body-weight entry keeps the trend honest without making it the focus.",
                de: "Ein Gewichtseintrag hält den Trend ehrlich, ohne ihn zum Fokus zu machen."
            )
        case .recoveryDay:
            return briefing.restPrep?.detail ?? todayText(
                en: "No lift today; recovery is the work that protects the next push.",
                de: "Heute kein schwerer Lift; Erholung schützt den nächsten Push."
            )
        case .logCompletion:
            return primary.detail
        }
    }

    private func premiumWorkoutActionTitle(for primary: DailyBriefing.Primary) -> String {
        switch primary.kind {
        case .prepNextSession, .recoveryDay, .logBodyWeight:
            return L10n.tr("Preview workout")
        case .recoverToday:
            return L10n.tr("Start Light Workout")
        default:
            return todayText(en: "Begin workout", de: "Training starten")
        }
    }

    private func recoveryEvidenceDetail(for score: Int) -> String {
        if score >= 75 {
            return todayText(en: "Stable", de: "Stabil")
        }
        if score >= 60 {
            return todayText(en: "Workable", de: "Nutzbar")
        }
        return todayText(en: "Limited", de: "Begrenzt")
    }

    private func plannedExposureReason(for day: WorkoutDay?) -> String {
        let recoveryLead: String
        let recoveryScore = vm.todaysReadiness?.readinessScore ?? vm.effectiveRecoveryScore
        if recoveryScore >= 75 {
            recoveryLead = todayText(en: "Recovery is stable.", de: "Erholung ist stabil.")
        } else if recoveryScore >= 60 {
            recoveryLead = todayText(en: "Recovery is workable.", de: "Erholung ist nutzbar.")
        } else {
            recoveryLead = todayText(en: "Recovery is limited.", de: "Erholung ist begrenzt.")
        }

        if isGermanToday {
            return "\(recoveryLead) \(plannedExposureLabel(for: day)) ist als Nächstes geplant."
        }

        return "\(recoveryLead) \(plannedExposureLabel(for: day)) is the next planned exposure."
    }

    private func plannedExposureLabel(for day: WorkoutDay?) -> String {
        guard let day else {
            return todayText(en: "This workout", de: "Diese Einheit")
        }

        let lowerCount = day.focusMuscles.filter { $0.region == .lower }.count
        let upperCount = day.focusMuscles.filter { $0.region == .upper }.count
        let coreCount = day.focusMuscles.filter { $0.region == .core }.count

        if lowerCount > upperCount && lowerCount > coreCount {
            return todayText(en: "Lower-body work", de: "Unterkörperarbeit")
        }
        if upperCount > lowerCount && upperCount > coreCount {
            return todayText(en: "Upper-body work", de: "Oberkörperarbeit")
        }
        if coreCount > lowerCount && coreCount > upperCount {
            return todayText(en: "Core work", de: "Rumpfarbeit")
        }

        return todayText(en: "This workout", de: "Diese Einheit")
    }

    private func premiumFocusLine(for day: WorkoutDay?) -> String? {
        guard let day else { return nil }
        let muscles = day.focusMuscles.prefix(2).map(\.localizedDisplayName)
        guard !muscles.isEmpty else {
            return L10n.tr("Workouts")
        }
        return muscles.joined(separator: " · ")
    }

    private func localizedWorkoutName(_ name: String) -> String {
        let localized = L10n.tr(name, fallback: name)
        guard isGermanToday, localized == name else { return localized }

        let exactGermanNames: [String: String] = [
            "Upper Strength": "Oberkörper Kraft",
            "Lower Strength": "Unterkörper Kraft",
            "Lower Power": "Unterkörper Kraft",
            "Upper Power": "Oberkörper Kraft",
            "Pull Volume": "Pull Volumen",
            "Push Volume": "Push Volumen",
            "Legs Volume": "Beine Volumen"
        ]

        if let exact = exactGermanNames[name] {
            return exact
        }

        let replacements = [
            ("Full Body", "Ganzkörper"),
            ("Upper", "Oberkörper"),
            ("Lower", "Unterkörper"),
            ("Strength", "Kraft"),
            ("Power", "Kraft"),
            ("Volume", "Volumen"),
            ("Legs", "Beine")
        ]

        return replacements.reduce(name) { partial, replacement in
            partial.replacingOccurrences(of: replacement.0, with: replacement.1)
        }
    }

    private var isGermanToday: Bool {
        Locale.current.language.languageCode?.identifier == "de"
    }

    private func todayText(en: String, de: String) -> String {
        isGermanToday ? de : en
    }

    // MARK: - Today Hero


    private var todayHero: some View {
        let primary = vm.dailyBriefing?.primary
        let accent = todayCommandAccent(for: primary)
        let name = vm.profile.name.isEmpty ? L10n.tr("Athlete") : vm.profile.name

        return VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 12) {
                VStack(alignment: .leading, spacing: 5) {
                    Text(todayDateLabel.uppercased())
                        .font(.system(size: 10, weight: .black))
                        .tracking(1.1)
                        .foregroundStyle(STRQPalette.textMuted)
                        .lineLimit(1)

                    Text("\(greeting), \(name)")
                        .font(.system(size: 24, weight: .heavy, design: .rounded))
                        .foregroundStyle(STRQPalette.textPrimary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.72)
                }

                Spacer(minLength: 8)

                readinessBadge(accent: accent)
            }

            if let primary {
                HStack(spacing: 10) {
                    Image(systemName: primary.icon)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(accent)
                        .frame(width: 28, height: 28)
                        .background(accent.opacity(0.12), in: Circle())

                    Text(primary.title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(STRQPalette.textPrimary.opacity(0.92))
                        .lineLimit(1)
                        .minimumScaleFactor(0.78)

                    Spacer(minLength: 0)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(Color.white.opacity(0.045), in: .rect(cornerRadius: 15))
                .overlay(
                    RoundedRectangle(cornerRadius: 15, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.08), lineWidth: 1)
                )
            }
        }
        .padding(.horizontal, 2)
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 6)
    }

    @ViewBuilder
    private func readinessBadge(accent: Color) -> some View {
        if let readiness = vm.todaysReadiness {
            let score = readiness.readinessScore
            let color = ForgeTheme.recoveryColor(for: score)
            HStack(spacing: 8) {
                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.08), lineWidth: 3)
                    Circle()
                        .trim(from: 0, to: appeared ? Double(score) / 100 : 0)
                        .stroke(color, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                    Text("\(score)")
                        .font(.system(size: 11, weight: .black).monospacedDigit())
                        .foregroundStyle(STRQPalette.textPrimary)
                }
                .frame(width: 34, height: 34)

                Text(L10n.tr("Ready"))
                    .font(.system(size: 10, weight: .black))
                    .tracking(0.8)
                    .foregroundStyle(STRQPalette.textSecondary)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 7)
            .background(Color.white.opacity(0.055), in: Capsule())
            .overlay(Capsule().strokeBorder(color.opacity(0.22), lineWidth: 1))
            .animation(reduceMotion ? .easeOut(duration: 0.12) : .easeOut(duration: 0.8).delay(0.2), value: appeared)
        } else if vm.streak > 0 {
            HStack(spacing: 6) {
                Image(systemName: "flame.fill")
                    .font(.system(size: 11, weight: .bold))
                Text("\(vm.streak)")
                    .font(.system(size: 12, weight: .black).monospacedDigit())
            }
            .foregroundStyle(accent)
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background(accent.opacity(0.10), in: Capsule())
            .overlay(Capsule().strokeBorder(accent.opacity(0.22), lineWidth: 1))
        }
    }

    private var todayDateLabel: String {
        Date().formatted(.dateTime.weekday(.wide).month(.abbreviated).day())
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
        return ForgeSurface(variant: .elevated, accent: tint, padding: 16) {
            VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 6) {
                Capsule()
                    .fill(tint.gradient)
                    .frame(width: 3, height: 14)
                Text(primary.eyebrow)
                    .font(.system(size: 10, weight: .black))
                    .tracking(1.2)
                    .foregroundStyle(tint)
                Spacer()
                if vm.isEarlyStage {
                    todayPriorityPill
                } else if let momentum = briefing.momentum {
                    STRQBadgeChip(label: momentum.title, icon: momentum.icon, variant: .neutral)
                }
            }

            HStack(alignment: .top, spacing: 14) {
                Image(systemName: primary.icon)
                    .font(.title3.weight(.medium))
                    .foregroundStyle(tint)
                    .frame(width: 46, height: 46)
                    .background(tint.opacity(0.14), in: .rect(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(tint.opacity(0.24), lineWidth: 1)
                    )

                VStack(alignment: .leading, spacing: 4) {
                    Text(primary.title)
                        .font(.title3.weight(.bold))
                        .foregroundStyle(STRQPalette.textPrimary)
                    Text(primary.detail)
                        .font(.footnote)
                        .foregroundStyle(STRQPalette.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer(minLength: 0)
            }

            if let rest = briefing.restPrep {
                HStack(spacing: 10) {
                    Image(systemName: rest.icon)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(STRQPalette.steel)
                        .frame(width: 24, height: 24)
                        .background(STRQPalette.steelSoft, in: .rect(cornerRadius: 7))
                    VStack(alignment: .leading, spacing: 1) {
                        Text(rest.title)
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(STRQPalette.textPrimary)
                        Text(rest.detail)
                            .font(.caption2)
                            .foregroundStyle(STRQPalette.textMuted)
                            .lineLimit(2)
                    }
                    Spacer(minLength: 0)
                }
                .padding(.top, 2)
            }

            primaryCTA(primary)
            }
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 10)
        .animation(reduceMotion ? .easeOut(duration: 0.12) : .easeOut(duration: 0.5).delay(0.05), value: appeared)
    }

    @ViewBuilder
    private func primaryCTA(_ primary: DailyBriefing.Primary) -> some View {
        switch primary.kind {
        case .checkInBeforeTraining:
            STRQPrimaryCTA(icon: "heart.text.clipboard", title: L10n.tr("Check in")) {
                showReadinessCheckIn = true
            }
        case .logBodyWeight:
            STRQPrimaryCTA(icon: "scalemass.fill", title: primary.ctaTitle) {
                showWeightLog = true
            }
        case .startFirstSession:
            if let day = vm.todaysWorkout ?? vm.nextWorkout {
                STRQPrimaryCTA(icon: "sparkles", title: L10n.tr("Start Workout 1")) {
                    vm.prepareWorkoutHandoff(day: day)
                }
                .accessibilityIdentifier("strq.today.start-workout")
            }
        case .resumeWorkout:
            if let day = vm.todaysWorkout {
                STRQPrimaryCTA(icon: "play.fill", title: L10n.tr("Resume Workout")) {
                    vm.prepareWorkoutHandoff(day: day)
                }
                .accessibilityIdentifier("strq.today.start-workout")
            }
        default:
            EmptyView()
        }
    }

    private var todayPriorityPill: some View {
        HStack(spacing: 4) {
            Image(systemName: "arrow.forward.circle.fill")
                .font(.system(size: 9, weight: .bold))
            Text(L10n.tr("START HERE"))
                .font(.system(size: 9, weight: .black))
                .tracking(0.8)
        }
        .foregroundStyle(STRQPalette.textPrimary)
        .padding(.horizontal, 8)
        .padding(.vertical, 3)
        .background(Color.white.opacity(0.09), in: Capsule())
        .overlay(Capsule().strokeBorder(Color.white.opacity(0.18), lineWidth: 0.7))
    }

    private struct PostWorkoutBridge {
        let sessionName: String
        let timeLabel: String
        let stats: String
        let outcomes: [String]
        let nextStep: String
        let accent: Color
        let icon: String
    }

    private var postWorkoutBridge: PostWorkoutBridge? {
        guard let session = vm.workoutHistory.first(where: \.isCompleted) else { return nil }
        let referenceDate = session.endTime ?? session.startTime
        let minutesAgo = max(0, Int(Date().timeIntervalSince(referenceDate) / 60))
        guard minutesAgo <= 180 else { return nil }

        let result = WorkoutHighlightBuilder.buildResult(
            session: session,
            history: vm.workoutHistory,
            streak: vm.streak,
            exerciseName: { id in vm.library.exercise(byId: id)?.name ?? L10n.tr("Exercise") }
        )
        let completedExercises = session.distinctCompletedExerciseCount
        let completedSets = session.completedSetCount

        return PostWorkoutBridge(
            sessionName: session.dayName,
            timeLabel: postWorkoutTimeLabel(minutesAgo),
            stats: postWorkoutStatsText(exercises: completedExercises, sets: completedSets),
            outcomes: postWorkoutOutcomes(session: session, result: result, completedSets: completedSets),
            nextStep: postWorkoutNextStep(),
            accent: postWorkoutAccent(for: result.verdict.kind),
            icon: postWorkoutIcon(for: result.verdict.kind)
        )
    }

    private func postWorkoutStatsText(exercises: Int, sets: Int) -> String {
        let exerciseText = L10n.countLabel(
            exercises,
            singularKey: "count.exercise.one",
            pluralKey: "count.exercise.other",
            singularFallback: "exercise",
            pluralFallback: "exercises"
        )
        let setText = L10n.countLabel(
            sets,
            singularKey: "count.set.one",
            pluralKey: "count.set.other",
            singularFallback: "set",
            pluralFallback: "sets"
        )
        return "\(exerciseText) · \(setText)"
    }

    private func postWorkoutBridgeCard(_ bridge: PostWorkoutBridge) -> some View {
        sandowRunwayCard(accent: bridge.accent) {
            VStack(alignment: .leading, spacing: 14) {
                HStack(alignment: .top, spacing: 12) {
                    sandowIconBox(icon: bridge.icon, tint: bridge.accent)

                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 7) {
                            Text(L10n.tr("Workout saved"))
                                .font(.system(size: 10, weight: .black))
                                .foregroundStyle(bridge.accent)
                                .lineLimit(1)
                            Text(bridge.timeLabel)
                                .font(.system(size: 10, weight: .bold))
                                .foregroundStyle(STRQPalette.textMuted)
                        }

                        Text(bridge.sessionName)
                            .font(.system(size: 18, weight: .black, design: .rounded))
                            .foregroundStyle(STRQPalette.textPrimary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.78)

                        Text(bridge.stats)
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(STRQPalette.textSecondary)
                            .lineLimit(1)
                    }

                    Spacer(minLength: 0)
                }

                ForEach(Array(bridge.outcomes.prefix(2)), id: \.self) { outcome in
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(bridge.accent)
                        Text(outcome)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(STRQPalette.textPrimary.opacity(0.88))
                            .lineLimit(1)
                            .minimumScaleFactor(0.78)
                    }
                }

                Rectangle()
                    .fill(Color.white.opacity(0.08))
                    .frame(height: 1)

                HStack(alignment: .top, spacing: 10) {
                    Text(L10n.tr("NEXT ACTION"))
                        .font(.system(size: 10, weight: .black))
                        .foregroundStyle(STRQPalette.textMuted)
                        .frame(width: 82, alignment: .leading)
                    Text(bridge.nextStep)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(STRQPalette.textPrimary.opacity(0.88))
                        .fixedSize(horizontal: false, vertical: true)
                    Spacer(minLength: 0)
                }
            }
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 8)
        .animation(reduceMotion ? .easeOut(duration: 0.12) : .easeOut(duration: 0.5).delay(0.06), value: appeared)
    }

    private func postWorkoutOutcomes(
        session: WorkoutSession,
        result: WorkoutHighlightBuilder.Result,
        completedSets: Int
    ) -> [String] {
        var outcomes: [String] = []

        if let line = result.highlights.first?.improvedLine {
            outcomes.append(line)
        }

        if completedSets > 0 {
            let setLabel = L10n.countLabel(
                completedSets,
                singularKey: "count.set.one",
                pluralKey: "count.set.other",
                singularFallback: "set",
                pluralFallback: "sets"
            )
            outcomes.append(L10n.format("%@ completed", setLabel))
        }

        if session.totalVolume > 0 && outcomes.count < 2 {
            outcomes.append(L10n.format("Volume updated: %@", ForgeTheme.formatVolume(session.totalVolume)))
        }

        if outcomes.isEmpty {
            outcomes.append(L10n.tr("First signal collected"))
        }

        return Array(outcomes.prefix(2))
    }

    private func postWorkoutTimeLabel(_ minutesAgo: Int) -> String {
        if minutesAgo < 2 { return L10n.tr("JUST NOW") }
        if minutesAgo < 60 { return L10n.format("%dM AGO", minutesAgo) }
        return L10n.format("%dH AGO", max(1, minutesAgo / 60))
    }

    private func postWorkoutTakeaway(for kind: SessionVerdict.Kind) -> String {
        switch kind {
        case .firstSession:
            return L10n.tr("Baseline loads are now tied to what you actually lifted.")
        case .personalRecord:
            return L10n.tr("That PR gives STRQ room to push the next exposure.")
        case .bestSet:
            return L10n.tr("Your top set moved up, so progression can keep climbing.")
        case .volumeUp:
            return L10n.tr("You handled more work than last time. Capacity is moving up.")
        case .volumeDown:
            return L10n.tr("Today read lighter, which still sharpens STRQ's load pacing.")
        case .consolidated:
            return L10n.tr("Execution held steady, so the next call can stay confident.")
        }
    }

    private func postWorkoutNextStep() -> String {
        if vm.dataMaturityTier == .firstSession {
            return L10n.tr("Come back for Workout 2")
        }
        if let title = vm.dailyBriefing?.primary.title {
            return title
        }
        if let day = nextScheduledDay {
            return L10n.format("Prep for %@.", day.name)
        }
        return L10n.tr("Let recovery carry this forward.")
    }

    private func postWorkoutAccent(for kind: SessionVerdict.Kind) -> Color {
        switch kind {
        case .personalRecord:
            return STRQPalette.gold
        case .bestSet, .volumeUp:
            return STRQPalette.success
        case .volumeDown:
            return STRQPalette.warning
        case .firstSession:
            return STRQPalette.energyAccent
        case .consolidated:
            return STRQBrand.steel
        }
    }

    private func postWorkoutIcon(for kind: SessionVerdict.Kind) -> String {
        switch kind {
        case .personalRecord:
            return "trophy.fill"
        case .bestSet:
            return "bolt.fill"
        case .volumeUp:
            return "arrow.up.right.circle.fill"
        case .volumeDown:
            return "equal.circle.fill"
        case .firstSession:
            return "sparkles"
        case .consolidated:
            return "checkmark.seal.fill"
        }
    }

    // MARK: - Since Last Session

    private func sinceLastCard(_ since: DailyBriefing.SinceLast) -> some View {
        sandowRunwayCard(accent: STRQPalette.signalGreen, padding: 14) {
            HStack(spacing: 12) {
                sandowIconBox(
                    icon: "arrow.up.right.circle.fill",
                    tint: STRQPalette.signalGreen,
                    size: 34,
                    cornerRadius: 11
                )

                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Text(since.eyebrow)
                            .font(.system(size: 10, weight: .black))
                            .foregroundStyle(STRQPalette.signalGreen)
                            .lineLimit(1)
                        Text(timeLabel(since.hoursAgo))
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(STRQPalette.textMuted)
                    }

                    Text(since.summary)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(STRQPalette.textPrimary)
                        .lineLimit(2)
                        .minimumScaleFactor(0.78)

                    Text(since.sessionName)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(STRQPalette.textMuted)
                        .lineLimit(1)
                }

                Spacer(minLength: 0)
            }
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 10)
        .animation(reduceMotion ? .easeOut(duration: 0.12) : .easeOut(duration: 0.5).delay(0.06), value: appeared)
    }

    private func timeLabel(_ hours: Int) -> String {
        if hours < 1 { return L10n.tr("JUST NOW") }
        if hours < 24 { return L10n.format("%dH AGO", hours) }
        return L10n.tr("YESTERDAY")
    }

    private var isPostFirstSessionState: Bool {
        vm.dataMaturityTier == .firstSession
    }

    // MARK: - Early Stage

    private func earlyStageHint(_ guidance: EarlyStateGuidance) -> some View {
        let tierIndex = max(0, min(3, guidance.tier.rawValue))
        return sandowRunwayCard(accent: STRQBrand.steel) {
            VStack(alignment: .leading, spacing: 13) {
                HStack(alignment: .top, spacing: 12) {
                    sandowIconBox(icon: guidance.icon, tint: STRQBrand.steel)

                    VStack(alignment: .leading, spacing: 5) {
                        HStack(spacing: 7) {
                            Text(L10n.tr("CALIBRATING"))
                                .font(.system(size: 10, weight: .black))
                                .foregroundStyle(STRQBrand.steel)
                            Text("\(tierIndex + 1)/4")
                                .font(.system(size: 10, weight: .black).monospacedDigit())
                                .foregroundStyle(STRQPalette.textMuted)
                        }

                        Text(guidance.headline)
                            .font(.system(size: 18, weight: .black, design: .rounded))
                            .foregroundStyle(STRQPalette.textPrimary)
                            .lineLimit(2)
                            .minimumScaleFactor(0.78)

                        Text(guidance.message)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(STRQPalette.textSecondary)
                            .lineLimit(3)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Spacer(minLength: 0)
                }

                HStack(spacing: 5) {
                    ForEach(0..<4, id: \.self) { i in
                        Capsule()
                            .fill(i <= tierIndex ? AnyShapeStyle(STRQBrand.steel.gradient) : AnyShapeStyle(Color.white.opacity(0.08)))
                            .frame(height: 5)
                    }
                }

                if let unlock = guidance.unlocksNext {
                    Text(unlock)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(STRQPalette.textMuted)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 8)
        .animation(reduceMotion ? .easeOut(duration: 0.12) : .easeOut(duration: 0.5).delay(0.07), value: appeared)
    }

    // MARK: - Workout Card (training-day primary)

    private func workoutCard(_ day: WorkoutDay, briefing: DailyBriefing) -> some View {
        let primary = briefing.primary
        let tint = todayCommandAccent(for: primary)
        let isRecovery = primary.kind == .recoverToday
        let isFirstSession = primary.kind == .startFirstSession
        return ForgeSurface(variant: .hero, accent: tint, padding: 0) {
            VStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 16) {
                    HStack(alignment: .center, spacing: 12) {
                        Image(systemName: primary.icon)
                            .font(.system(size: 14, weight: .black))
                            .foregroundStyle(tint)
                            .frame(width: 40, height: 40)
                            .background(tint.opacity(0.13), in: .rect(cornerRadius: 13))
                            .overlay(
                                RoundedRectangle(cornerRadius: 13, style: .continuous)
                                    .strokeBorder(tint.opacity(0.24), lineWidth: 1)
                            )

                        VStack(alignment: .leading, spacing: 3) {
                            Text(primary.eyebrow)
                                .font(.system(size: 9, weight: .black))
                                .tracking(1.2)
                                .foregroundStyle(tint)
                                .lineLimit(1)
                            Text(workoutPrimaryTitle(for: primary.kind))
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(STRQPalette.textSecondary)
                                .lineLimit(1)
                        }

                        Spacer(minLength: 0)

                        workoutStatusBadge(
                            isRecovery: isRecovery,
                            isFirstSession: isFirstSession,
                            briefing: briefing
                        )
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text(day.name)
                            .font(.system(size: isRecovery ? 25 : 30, weight: .heavy, design: .rounded))
                            .foregroundStyle(.white)
                            .lineLimit(2)
                            .minimumScaleFactor(0.68)

                        Text(primary.detail)
                            .font(.footnote)
                            .lineSpacing(2)
                            .foregroundStyle(.white.opacity(0.68))
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    if let adj = vm.adjustment(for: day.id) {
                        coachAdjustmentChip(adj)
                    }

                    if let watch = briefing.watch {
                        workoutCoachHint(watch)
                    }

                    HStack(spacing: 6) {
                        ForEach(day.focusMuscles.prefix(3)) { muscle in
                            STRQBadgeChip(label: muscle.displayName, variant: .neutral)
                        }
                    }

                    HStack(spacing: 8) {
                        workoutMetric(
                            value: "\(day.exercises.count)",
                            label: L10n.tr("Exercises"),
                            icon: "figure.strengthtraining.traditional",
                            tint: tint
                        )
                        workoutMetric(
                            value: "~\(day.estimatedMinutes)m",
                            label: L10n.tr("Duration"),
                            icon: "clock.fill",
                            tint: STRQPalette.steel
                        )
                        workoutMetric(
                            value: "\(day.exercises.reduce(0) { $0 + $1.sets })",
                            label: L10n.tr("Total Sets"),
                            icon: "square.stack.3d.up.fill",
                            tint: STRQPalette.textSecondary
                        )
                    }
                }
                .padding(20)

                if primary.kind == .checkInBeforeTraining {
                    HStack(spacing: 10) {
                        todayCommandCTA(icon: "heart.text.clipboard", title: L10n.tr("Check in"), tint: tint) {
                            showReadinessCheckIn = true
                        }

                        todaySecondaryCTA(icon: "bolt.fill", title: L10n.tr("Start Workout")) {
                            vm.prepareWorkoutHandoff(day: day)
                        }
                        .accessibilityIdentifier("strq.today.start-workout")
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
                } else {
                    todayCommandCTA(
                        icon: primary.kind == .resumeWorkout ? "play.fill" : "bolt.fill",
                        title: workoutPrimaryTitle(for: primary.kind),
                        tint: tint
                    ) {
                        vm.prepareWorkoutHandoff(day: day)
                    }
                    .accessibilityIdentifier("strq.today.start-workout")
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
                }
            }
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 10)
        .animation(reduceMotion ? .easeOut(duration: 0.12) : .easeOut(duration: 0.5).delay(0.05), value: appeared)
    }

    private func todayCommandAccent(for primary: DailyBriefing.Primary?) -> Color {
        guard let primary else {
            return vm.todaysReadiness.map { ForgeTheme.recoveryColor(for: $0.readinessScore) } ?? STRQPalette.steel
        }

        switch primary.kind {
        case .trainToday:
            return STRQPalette.signalGreen
        case .checkInBeforeTraining, .resumeWorkout:
            return STRQPalette.steel
        case .recoverToday, .recoveryDay:
            return STRQPalette.warningAmber
        case .startFirstSession:
            return STRQPalette.gold
        case .prepNextSession, .logCompletion, .logBodyWeight:
            return ForgeTheme.color(for: primary.colorName)
        }
    }

    @ViewBuilder
    private func workoutStatusBadge(
        isRecovery: Bool,
        isFirstSession: Bool,
        briefing: DailyBriefing
    ) -> some View {
        if vm.isEarlyStage {
            todayPriorityPill
        } else if isRecovery {
            STRQBadgeChip(label: L10n.tr("Recovery first"), icon: "heart.circle.fill", variant: .warning)
        } else if isFirstSession {
            STRQBadgeChip(label: L10n.tr("Milestone"), icon: "sparkles", variant: .success)
        } else if let momentum = briefing.momentum {
            STRQBadgeChip(label: momentum.title, icon: momentum.icon, variant: .neutral)
        } else {
            Text(L10n.tr("TODAY"))
                .font(.system(size: 9, weight: .black))
                .tracking(1.2)
                .foregroundStyle(.white.opacity(0.4))
        }
    }

    private func workoutCoachHint(_ watch: DailyBriefing.Watch) -> some View {
        let tint = ForgeTheme.color(for: watch.colorName)
        return HStack(alignment: .top, spacing: 10) {
            Image(systemName: watch.icon)
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(tint)
                .frame(width: 28, height: 28)
                .background(tint.opacity(0.12), in: .rect(cornerRadius: 9))

            VStack(alignment: .leading, spacing: 2) {
                Text(watch.title)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(STRQPalette.textPrimary.opacity(0.92))
                    .lineLimit(1)
                Text(watch.detail)
                    .font(.caption2)
                    .foregroundStyle(STRQPalette.textMuted)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)
        }
        .padding(10)
        .background(Color.white.opacity(0.045), in: .rect(cornerRadius: 13))
        .overlay(
            RoundedRectangle(cornerRadius: 13, style: .continuous)
                .strokeBorder(Color.white.opacity(0.07), lineWidth: 1)
        )
    }

    private func workoutMetric(value: String, label: String, icon: String, tint: Color) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(tint)

            Text(value)
                .font(.system(size: 17, weight: .heavy, design: .rounded).monospacedDigit())
                .foregroundStyle(STRQPalette.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.68)

            Text(label.uppercased())
                .font(.system(size: 8, weight: .black))
                .tracking(0.7)
                .foregroundStyle(STRQPalette.textMuted)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity, minHeight: 66, alignment: .leading)
        .padding(.horizontal, 10)
        .padding(.vertical, 9)
        .background(Color.white.opacity(0.045), in: .rect(cornerRadius: 13))
        .overlay(
            RoundedRectangle(cornerRadius: 13, style: .continuous)
                .strokeBorder(tint.opacity(0.15), lineWidth: 1)
        )
    }

    private func todayCommandCTA(icon: String, title: String, tint: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 9) {
                Image(systemName: icon)
                    .font(.system(size: 15, weight: .black))
                Text(title)
                    .font(.system(size: 16, weight: .black))
                    .lineLimit(1)
                    .minimumScaleFactor(0.76)
            }
            .foregroundStyle(STRQPalette.backgroundDeep)
            .frame(maxWidth: .infinity)
            .frame(height: 54)
            .background(
                LinearGradient(
                    colors: [
                        Color.white,
                        Color(red: 0.84, green: 0.86, blue: 0.88)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                in: .rect(cornerRadius: 15)
            )
            .overlay(alignment: .top) {
                RoundedRectangle(cornerRadius: 15, style: .continuous)
                    .fill(Color.white.opacity(0.42))
                    .frame(height: 24)
                    .allowsHitTesting(false)
            }
            .overlay(
                RoundedRectangle(cornerRadius: 15, style: .continuous)
                    .strokeBorder(tint.opacity(0.24), lineWidth: 1)
            )
            .shadow(color: tint.opacity(0.12), radius: 16, y: 7)
            .shadow(color: .black.opacity(0.26), radius: 18, y: 8)
        }
        .buttonStyle(.strqPressable)
    }

    private func todaySecondaryCTA(icon: String, title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                Text(title)
                    .lineLimit(1)
                    .minimumScaleFactor(0.76)
            }
            .font(.subheadline.weight(.bold))
            .foregroundStyle(STRQPalette.textPrimary.opacity(0.86))
            .frame(maxWidth: .infinity)
            .frame(height: 54)
            .background(Color.white.opacity(0.075), in: .rect(cornerRadius: 15))
            .overlay(
                RoundedRectangle(cornerRadius: 15, style: .continuous)
                    .strokeBorder(Color.white.opacity(0.12), lineWidth: 1)
            )
        }
        .buttonStyle(.strqPressable)
    }

    private func workoutPrimaryTitle(for kind: DailyBriefing.PrimaryKind) -> String {
        switch kind {
        case .resumeWorkout:
            return L10n.tr("Resume Workout")
        case .startFirstSession:
            return L10n.tr("Start Workout 1")
        case .recoverToday:
            return L10n.tr("Start Light Workout")
        default:
            return L10n.tr("Start Workout")
        }
    }

    private func coachAdjustmentChip(_ adj: CoachAdjustment) -> some View {
        STRQBadgeChip(label: adj.description, icon: "brain.head.profile.fill", variant: .muted)
    }

    // MARK: - Schedule Timeline

    @ViewBuilder
    private var scheduleTimeline: some View {
        if let plan = vm.currentPlan, plan.days.contains(where: { $0.scheduledWeekday != nil }) {
            sandowRunwayCard(accent: STRQBrand.steel) {
                VStack(alignment: .leading, spacing: 14) {
                    lowerSectionHeader(
                        title: L10n.tr("Training Week"),
                        subtitle: todayText(en: "Planned rhythm", de: "Geplanter Rhythmus"),
                        trailing: nextScheduledDay.map { L10n.format("Next: %@", vm.weekdayName($0.scheduledWeekday ?? 0)) },
                        accent: STRQBrand.steel
                    )

                    HStack(alignment: .top, spacing: 0) {
                        ForEach(1...7, id: \.self) { weekday in
                            trainingWeekDay(plan: plan, weekday: weekday)
                        }
                    }
                }
            }
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 10)
            .animation(reduceMotion ? .easeOut(duration: 0.12) : .easeOut(duration: 0.5).delay(0.07), value: appeared)
        }
    }

    private func trainingWeekDay(plan: WorkoutPlan, weekday: Int) -> some View {
        let matchingDay = plan.days.first { $0.scheduledWeekday == weekday && !$0.isSkipped }
        let todayWeekday = Calendar.current.component(.weekday, from: Date())
        let isToday = todayWeekday == weekday
        let isPast = todayWeekday > weekday
        let tint: Color = {
            if matchingDay == nil {
                return isToday ? STRQBrand.steel : STRQPalette.textMuted
            }
            if isToday {
                return STRQBrand.steel
            }
            return isPast ? STRQPalette.signalGreen : STRQPalette.textSecondary
        }()

        return VStack(spacing: 7) {
            Text(vm.weekdayName(weekday))
                .font(.system(size: 11, weight: isToday ? .black : .semibold))
                .foregroundStyle(isToday ? STRQPalette.textPrimary : STRQPalette.textMuted)
                .lineLimit(1)
                .minimumScaleFactor(0.62)

            ZStack {
                Circle()
                    .fill(trainingWeekFill(hasWorkout: matchingDay != nil, isToday: isToday, isPast: isPast, tint: tint))
                    .frame(width: 32, height: 32)

                if isToday {
                    Circle()
                        .strokeBorder(tint.opacity(0.55), lineWidth: 1.4)
                        .frame(width: 32, height: 32)
                }

                if matchingDay != nil {
                    Image(systemName: "figure.strengthtraining.traditional")
                        .font(.system(size: 12, weight: .black))
                        .foregroundStyle(isToday ? STRQPalette.backgroundDeep : STRQPalette.textPrimary.opacity(0.82))
                }
            }

            Text(matchingDay.map { shortName($0.name) } ?? (isToday ? L10n.tr("Rest") : ""))
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(isToday ? tint : STRQPalette.textMuted)
                .lineLimit(1)
                .minimumScaleFactor(0.62)
                .frame(height: 12)
        }
        .frame(maxWidth: .infinity)
    }

    private func trainingWeekFill(hasWorkout: Bool, isToday: Bool, isPast: Bool, tint: Color) -> AnyShapeStyle {
        if hasWorkout {
            if isToday {
                return AnyShapeStyle(tint.gradient)
            }
            return AnyShapeStyle((isPast ? STRQPalette.signalGreen : STRQPalette.textSecondary).opacity(isPast ? 0.22 : 0.12))
        }
        return AnyShapeStyle(Color.white.opacity(isToday ? 0.075 : 0.045))
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
        sandowRunwayCard(accent: STRQBrand.steel) {
            VStack(alignment: .leading, spacing: 12) {
                lowerSectionHeader(
                    title: todayText(en: "Quick logs", de: "Kurz eintragen"),
                    subtitle: todayText(en: "Support the next call", de: "Stützt die nächste Entscheidung"),
                    accent: STRQBrand.steel
                )

                VStack(spacing: 0) {
                    if vm.profile.nutritionTrackingEnabled {
                        signalButton(
                            icon: "fork.knife",
                            label: L10n.tr("Protein"),
                            value: "\(Int(vm.todayProteinProgress * 100))%",
                            progress: vm.todayProteinProgress,
                            color: STRQPalette.signalGreen,
                            accessibilityIdentifier: "strq.today.signal.protein"
                        ) {
                            showNutritionLog = true
                        }

                        sandowRowDivider
                    }

                    signalButton(
                        icon: "moon.zzz.fill",
                        label: L10n.tr("Sleep"),
                        value: String(format: "%.1fh", vm.averageSleepHours),
                        progress: min(1.0, vm.averageSleepHours / 8.0),
                        color: ForgeTheme.sleepColor(for: vm.averageSleepHours),
                        accessibilityIdentifier: "strq.today.signal.sleep"
                    ) {
                        showSleepLog = true
                    }

                    if vm.profile.nutritionTrackingEnabled {
                        sandowRowDivider

                        signalButton(
                            icon: "scalemass.fill",
                            label: L10n.tr("Weight"),
                            value: vm.latestWeight.map { String(format: "%.1f", $0) } ?? "—",
                            progress: vm.latestWeight != nil ? 1.0 : 0.0,
                            color: STRQBrand.steel,
                            accessibilityIdentifier: "strq.today.signal.weight"
                        ) {
                            showWeightLog = true
                        }
                    }

                    if vm.isWeeklyReviewReady {
                        sandowRowDivider
                        weeklyReviewRow
                    }
                }
            }
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 10)
        .animation(reduceMotion ? .easeOut(duration: 0.12) : .easeOut(duration: 0.5).delay(0.1), value: appeared)
    }

    private var sandowRowDivider: some View {
        Rectangle()
            .fill(Color.white.opacity(0.075))
            .frame(height: 1)
            .padding(.leading, 52)
    }

    private var weeklyReviewRow: some View {
        Button {
            vm.generateWeeklyReview()
            showWeeklyReview = true
        } label: {
            HStack(spacing: 12) {
                sandowIconBox(
                    icon: "doc.text.magnifyingglass",
                    tint: STRQBrand.steel,
                    size: 36,
                    cornerRadius: 11
                )

                VStack(alignment: .leading, spacing: 3) {
                    Text(L10n.tr("Weekly review ready"))
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(STRQPalette.textPrimary)
                        .lineLimit(1)
                    Text(L10n.tr("Review this week and adjust"))
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(STRQPalette.textMuted)
                        .lineLimit(1)
                }

                Spacer(minLength: 0)

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(STRQPalette.textMuted)
            }
            .padding(.vertical, 11)
            .contentShape(.rect)
        }
        .buttonStyle(.strqPressable)
        .accessibilityIdentifier("strq.today.weekly-review")
    }

    private func signalButton(
        icon: String,
        label: String,
        value: String,
        progress: Double,
        color: Color,
        accessibilityIdentifier: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                sandowIconBox(icon: icon, tint: color, size: 34, cornerRadius: 11)

                VStack(alignment: .leading, spacing: 5) {
                    HStack(alignment: .firstTextBaseline, spacing: 8) {
                        Text(label)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(STRQPalette.textPrimary)
                            .lineLimit(1)

                        Spacer(minLength: 8)

                        Text(value)
                            .font(.system(size: 16, weight: .black, design: .rounded).monospacedDigit())
                            .foregroundStyle(STRQPalette.textPrimary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.72)
                    }

                    sandowProgressBar(progress: progress, tint: color)
                }

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(STRQPalette.textMuted.opacity(0.72))
            }
            .padding(.vertical, 9)
            .contentShape(.rect)
        }
        .buttonStyle(.strqPressable)
        .accessibilityIdentifier(accessibilityIdentifier)
    }

    // MARK: - Week Pulse

    private var weekPulse: some View {
        sandowRunwayCard(accent: STRQPalette.signalGreen) {
            VStack(alignment: .leading, spacing: 15) {
            Button {
                withAnimation(reduceMotion ? .easeOut(duration: 0.12) : .snappy(duration: 0.22)) {
                    showWeekPulseDetails.toggle()
                }
            } label: {
                HStack(spacing: 12) {
                    lowerSectionHeader(
                        title: L10n.tr("This Week"),
                        subtitle: todayText(en: "Weekly signal", de: "Wochensignal"),
                        trailing: vm.momentumData?.paceMessage,
                        accent: STRQPalette.signalGreen
                    )

                    Spacer()

                    Image(systemName: showWeekPulseDetails ? "chevron.up" : "chevron.down")
                        .font(.system(size: 12, weight: .black))
                        .foregroundStyle(STRQPalette.textMuted)
                        .frame(width: 24, height: 24)
                }
                .contentShape(.rect)
            }
            .buttonStyle(.plain)

                HStack(spacing: 0) {
                    ForEach(vm.weeklyActivity) { day in
                        VStack(spacing: 7) {
                            Text(day.label)
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundStyle(STRQPalette.textMuted)

                            Circle()
                                .fill(day.didTrain ? STRQPalette.signalGreen.opacity(0.24) : Color.white.opacity(0.045))
                                .frame(width: 32, height: 32)
                                .overlay {
                                    if day.didTrain {
                                        Image(systemName: "checkmark")
                                            .font(.system(size: 10, weight: .black))
                                            .foregroundStyle(STRQPalette.signalGreen)
                                    }
                                }
                        }
                        .frame(maxWidth: .infinity)
                    }
                }

            if showWeekPulseDetails {
                    VStack(spacing: 0) {
                        sandowRowDivider
                        weekPulseDetailRow(
                            value: "\(vm.weeklyStats.sessions)/\(vm.profile.daysPerWeek)",
                            label: L10n.tr("Workouts"),
                            icon: "checkmark.seal.fill",
                            tint: STRQPalette.signalGreen
                        )
                        sandowRowDivider
                        weekPulseDetailRow(
                            value: ForgeTheme.formatVolume(vm.weeklyStats.volume),
                            label: L10n.tr("Volume"),
                            icon: "chart.bar.fill",
                            tint: STRQBrand.steel
                        )
                        sandowRowDivider
                        weekPulseDetailRow(
                            value: "\(vm.effectiveRecoveryScore)%",
                            label: L10n.tr("Recovery"),
                            icon: "waveform.path.ecg",
                            tint: ForgeTheme.recoveryColor(for: vm.effectiveRecoveryScore)
                        )
                    }
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 10)
        .animation(reduceMotion ? .easeOut(duration: 0.12) : .easeOut(duration: 0.5).delay(0.12), value: appeared)
    }

    private func weekPulseDetailRow(value: String, label: String, icon: String, tint: Color) -> some View {
        HStack(spacing: 12) {
            sandowIconBox(icon: icon, tint: tint, size: 34, cornerRadius: 11)

            Text(label)
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(STRQPalette.textSecondary)

            Spacer(minLength: 8)

            Text(value)
                .font(.system(size: 14, weight: .black, design: .rounded).monospacedDigit())
                .foregroundStyle(STRQPalette.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.68)
        }
        .padding(.vertical, 10)
    }

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return L10n.tr("Good morning")
        case 12..<17: return L10n.tr("Good afternoon")
        case 17..<22: return L10n.tr("Good evening")
        default: return L10n.tr("Late night")
        }
    }
}
