import SwiftUI

struct OnboardingView: View {
    @Bindable var vm: AppViewModel
    @State private var step: Int = 0
    @State private var appeared: Bool = false
    @State private var selectionPulse: Bool = false
    @FocusState private var nameFocused: Bool
    @State private var editingMetric: MetricEdit?

    private let totalSteps = 8  // 0 welcome + 7 chapters
    private let scrollBottomPadding: CGFloat = 112

    var body: some View {
        ZStack {
            backgroundGradient
            VStack(spacing: 0) {
                if step > 0 {
                    header
                        .padding(.horizontal, 20)
                        .padding(.top, 8)
                        .transition(.opacity)
                }

                TabView(selection: $step) {
                    welcomeStep.tag(0)
                    aboutStep.tag(1)
                    bodyStep.tag(2)
                    goalStep.tag(3)
                    trainingStep.tag(4)
                    setupStep.tag(5)
                    muscleFocusStep.tag(6)
                    lifestyleStep.tag(7)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.smooth(duration: 0.4), value: step)
                .clipped()
            }
        }
        .preferredColorScheme(.dark)
        .safeAreaInset(edge: .bottom, spacing: 0) {
            navigationButtons
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 16)
                .background(navigationShelfBackground)
        }
        .onAppear { withAnimation(.easeOut(duration: 0.8)) { appeared = true } }
        .onChange(of: step) { _, newValue in
            if newValue == 1 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                    nameFocused = true
                }
            } else {
                nameFocused = false
            }
        }
        .sensoryFeedback(.selection, trigger: step)
        .sheet(item: $editingMetric) { metric in
            MetricEditSheet(metric: metric, profile: $vm.profile)
                .presentationDetents([.height(340)])
                .presentationDragIndicator(.visible)
                .presentationBackground(.ultraThinMaterial)
        }
    }

    private var backgroundGradient: some View {
        ZStack {
            STRQBrand.obsidian.ignoresSafeArea()
            LinearGradient(
                colors: [
                    Color.white.opacity(0.055),
                    Color.clear,
                    STRQBrand.graphite.opacity(0.36),
                    Color.black.opacity(0.58)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                Color.white.opacity(0.035).frame(height: 1)
                Spacer()
                Color.white.opacity(0.025).frame(height: 1)
            }
            .ignoresSafeArea()
        }
    }

    private var navigationShelfBackground: some View {
        LinearGradient(
            colors: [
                STRQBrand.obsidian.opacity(0.0),
                STRQBrand.obsidian.opacity(0.94),
                STRQBrand.obsidian
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea(edges: .bottom)
    }

    // MARK: - Header

    private var header: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
                    Image(systemName: stepSymbolName)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(STRQBrand.steel)
                }
                .frame(width: 34, height: 34)

                VStack(alignment: .leading, spacing: 2) {
                    Text(stepCategoryLabel)
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(.white.opacity(0.62))
                        .tracking(0.8)
                    Text(stepSupportText)
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(.white.opacity(0.36))
                        .lineLimit(1)
                }

                Spacer()

                Text("\(step) / \(totalSteps - 1)")
                    .font(.caption.weight(.semibold).monospacedDigit())
                    .foregroundStyle(.white.opacity(0.7))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color.white.opacity(0.055), in: Capsule())
                    .overlay(Capsule().strokeBorder(Color.white.opacity(0.08), lineWidth: 1))
            }
            progressBar
        }
        .padding(12)
        .background(
            LinearGradient(
                colors: [Color.white.opacity(0.075), Color.white.opacity(0.028)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            in: .rect(cornerRadius: 18)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .strokeBorder(Color.white.opacity(0.08), lineWidth: 1)
        )
    }

    private var stepCategoryLabel: String {
        switch step {
        case 1: return L10n.tr("ABOUT")
        case 2: return L10n.tr("BODY")
        case 3: return L10n.tr("GOAL")
        case 4: return L10n.tr("TRAINING")
        case 5: return L10n.tr("SETUP")
        case 6: return L10n.tr("FOCUS")
        case 7: return L10n.tr("LIFESTYLE")
        default: return ""
        }
    }

    private var stepSymbolName: String {
        switch step {
        case 1: return "person.crop.circle"
        case 2: return "ruler"
        case 3: return "target"
        case 4: return "calendar"
        case 5: return "dumbbell"
        case 6: return "scope"
        case 7: return "waveform.path.ecg"
        default: return "sparkles"
        }
    }

    private var stepSupportText: String {
        switch step {
        case 1: return L10n.tr("Name and basics")
        case 2: return L10n.tr("Plan calibration")
        case 3: return L10n.tr("Training direction")
        case 4: return L10n.tr("Weekly rhythm")
        case 5: return L10n.tr("Exercise matching")
        case 6: return L10n.tr("Muscle priorities")
        case 7: return L10n.tr("Load readiness")
        default: return ""
        }
    }

    private var progressBar: some View {
        HStack(spacing: 5) {
            ForEach(1..<totalSteps, id: \.self) { index in
                Capsule()
                    .fill(index <= step ? STRQBrand.steel : Color.white.opacity(0.07))
                    .overlay(
                        Capsule()
                            .strokeBorder(index <= step ? Color.white.opacity(0.12) : Color.clear, lineWidth: 0.5)
                    )
                    .frame(height: index == step ? 5 : 3)
                    .animation(.spring(response: 0.42, dampingFraction: 0.86), value: step)
            }
        }
        .frame(height: 5)
    }

    // MARK: - Navigation

    private var navigationButtons: some View {
        VStack(spacing: 10) {
            Button {
                advance()
            } label: {
                HStack(spacing: 8) {
                    Text(primaryButtonLabel)
                        .font(.body.weight(.bold))
                    if step == 0 {
                        Image(systemName: "arrow.right")
                            .font(.subheadline.weight(.bold))
                    }
                    if step == totalSteps - 1 {
                        Image(systemName: "sparkles")
                            .font(.subheadline.weight(.semibold))
                    }
                }
                .foregroundStyle(canAdvance ? .black : .white.opacity(0.5))
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(
                    (canAdvance ? AnyShapeStyle(STRQBrand.steelGradient) : AnyShapeStyle(Color.white.opacity(0.08))),
                    in: .rect(cornerRadius: 16)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(canAdvance ? Color.white.opacity(0.18) : Color.white.opacity(0.08), lineWidth: 1)
                )
                .opacity(canAdvance ? 1 : 0.55)
            }
            .buttonStyle(.strqPressable)
            .disabled(!canAdvance)
            .accessibilityIdentifier("strq.onboarding.primary")
            .sensoryFeedback(.impact(flexibility: .rigid, intensity: 0.5), trigger: step)

            if step > 0 {
                Button {
                    nameFocused = false
                    withAnimation(.smooth(duration: 0.35)) { step -= 1 }
                } label: {
                    Text(L10n.tr("Back"))
                        .font(.footnote.weight(.medium))
                        .foregroundStyle(.white.opacity(0.4))
                        .frame(maxWidth: .infinity)
                        .frame(height: 32)
                }
                .accessibilityIdentifier("strq.onboarding.back")
            }
        }
    }

    private func advance() {
        nameFocused = false
        if step < totalSteps - 1 {
            withAnimation(.smooth(duration: 0.35)) { step += 1 }
        } else {
            vm.beginPlanGeneration()
        }
    }

    private var canAdvance: Bool {
        switch step {
        case 1: return !vm.profile.name.trimmingCharacters(in: .whitespaces).isEmpty
        default: return true
        }
    }

    private var primaryButtonLabel: String {
        switch step {
        case 0: return L10n.tr("Get Started")
        case totalSteps - 1: return L10n.tr("See My Plan")
        default: return L10n.tr("Continue")
        }
    }

    // MARK: - Welcome

    private var welcomeStep: some View {
        VStack(spacing: 0) {
            Spacer()
            VStack(spacing: 26) {
                ZStack {
                    RoundedRectangle(cornerRadius: 28)
                        .fill(
                            LinearGradient(
                                colors: [Color.white.opacity(0.10), Color.white.opacity(0.025)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 120, height: 120)
                        .overlay(
                            RoundedRectangle(cornerRadius: 28)
                                .strokeBorder(Color.white.opacity(0.10), lineWidth: 1)
                        )
                    STRQLogoView(size: 76, animated: true)
                }
                    .opacity(appeared ? 1 : 0)
                    .scaleEffect(appeared ? 1 : 0.8)
                    .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.2), value: appeared)

                VStack(spacing: 14) {
                    Text(L10n.tr("STRQ"))
                        .font(.system(size: 40, weight: .black, design: .default))
                        .tracking(4)
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 16)
                        .animation(.easeOut(duration: 0.6).delay(0.35), value: appeared)

                    Text(L10n.tr("A training system built around you."))
                        .font(.title2.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.9))
                        .multilineTextAlignment(.center)
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 12)
                        .animation(.easeOut(duration: 0.6).delay(0.5), value: appeared)

                    Text(L10n.tr("Seven quick chapters. Then a plan that actually fits."))
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.58))
                        .multilineTextAlignment(.center)
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 10)
                        .animation(.easeOut(duration: 0.6).delay(0.6), value: appeared)
                }
            }
            Spacer()
            VStack(spacing: 12) {
                profileSignalStrip
                VStack(spacing: 10) {
                    welcomeFeatureRow(icon: "slider.horizontal.3", text: L10n.tr("Calibrated to your body, goal, and schedule"))
                    welcomeFeatureRow(icon: "chart.line.uptrend.xyaxis", text: L10n.tr("Progression that adapts after every workout"))
                    welcomeFeatureRow(icon: "waveform.path.ecg", text: L10n.tr("Recovery signals help guide load and volume"))
                }
            }
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 20)
            .animation(.easeOut(duration: 0.6).delay(0.65), value: appeared)
            Spacer().frame(height: 40)
        }
        .padding(.horizontal, 20)
    }

    private var profileSignalStrip: some View {
        HStack(spacing: 8) {
            welcomeSignal(label: L10n.tr("Goal"), value: L10n.tr("Direction"))
            welcomeSignal(label: L10n.tr("Week"), value: L10n.tr("Rhythm"))
            welcomeSignal(label: L10n.tr("Setup"), value: L10n.tr("Equipment"))
        }
    }

    private func welcomeSignal(label: String, value: String) -> some View {
        VStack(spacing: 3) {
            Text(label.uppercased())
                .font(.system(size: 9, weight: .bold))
                .foregroundStyle(.white.opacity(0.36))
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            Text(value)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.white.opacity(0.82))
                .lineLimit(1)
                .minimumScaleFactor(0.75)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color.white.opacity(0.045), in: .rect(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .strokeBorder(Color.white.opacity(0.08), lineWidth: 1)
        )
    }

    private func welcomeFeatureRow(icon: String, text: String) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.body)
                .foregroundStyle(STRQBrand.steel)
                .frame(width: 36, height: 36)
                .background(Color.white.opacity(0.06), in: .rect(cornerRadius: 10))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .strokeBorder(Color.white.opacity(0.08), lineWidth: 1)
                )
            Text(text)
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.8))
            Spacer()
        }
        .padding(12)
        .background(Color.white.opacity(0.035), in: .rect(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .strokeBorder(Color.white.opacity(0.065), lineWidth: 1)
        )
    }

    // MARK: - Chapter 1: About

    private var aboutStep: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                stepHero(
                    eyebrow: L10n.tr("Start here"),
                    title: L10n.tr("What should we call you?"),
                    subtitle: L10n.tr("STRQ personalizes everything from your goal to your schedule.")
                )

                TextField(L10n.tr("Your name"), text: $vm.profile.name)
                    .textFieldStyle(.plain)
                    .font(.title3.weight(.semibold))
                    .accessibilityIdentifier("strq.onboarding.name")
                    .focused($nameFocused)
                    .submitLabel(.next)
                    .onSubmit { if canAdvance { advance() } }
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.words)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 18)
                    .background(Color.white.opacity(0.05), in: .rect(cornerRadius: 14))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .strokeBorder(nameFocused ? Color.white.opacity(0.35) : Color.white.opacity(0.08), lineWidth: 1)
                    )
                    .animation(.easeOut(duration: 0.18), value: nameFocused)

                fieldGroup(L10n.tr("Age")) {
                    tapValueTile(
                        value: "\(vm.profile.age)",
                        unit: L10n.tr("years"),
                        accessibilityIdentifier: "strq.onboarding.metric.age"
                    ) { editingMetric = .age }
                }

                fieldGroup(L10n.tr("Gender")) {
                    LazyVGrid(columns: [GridItem(.flexible(), spacing: 8), GridItem(.flexible(), spacing: 8)], spacing: 8) {
                        ForEach(Gender.allCases) { gender in
                            selectionChip(gender.displayName, selected: vm.profile.gender == gender, accessibilityIdentifier: onboardingIdentifier("gender", gender.rawValue)) {
                                vm.profile.gender = gender
                            }
                        }
                    }
                }
            }
            .padding(20)
            .padding(.bottom, scrollBottomPadding)
        }
        .scrollDismissesKeyboard(.interactively)
    }

    // MARK: - Chapter 2: Body metrics (all tap tiles)

    private var bodyStep: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                stepHero(
                    eyebrow: L10n.tr("Baseline"),
                    title: L10n.tr("Your body metrics"),
                    subtitle: L10n.tr("Tap any value to edit. Used to calibrate volume and exercise selection.")
                )

                LazyVGrid(columns: [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)], spacing: 10) {
                    metricTile(
                        label: L10n.tr("Height"),
                        value: "\(Int(vm.profile.heightCm))",
                        unit: "cm",
                        filled: true,
                        accessibilityIdentifier: "strq.onboarding.metric.height"
                    ) { editingMetric = .height }

                    metricTile(
                        label: L10n.tr("Weight"),
                        value: String(format: "%.1f", vm.profile.weightKg),
                        unit: "kg",
                        filled: true,
                        accessibilityIdentifier: "strq.onboarding.metric.weight"
                    ) { editingMetric = .weight }

                    metricTile(
                        label: L10n.tr("Target weight"),
                        value: vm.profile.targetWeightKg.map { String(format: "%.1f", $0) } ?? "—",
                        unit: "kg",
                        filled: vm.profile.targetWeightKg != nil,
                        accessibilityIdentifier: "strq.onboarding.metric.targetWeight",
                        trailingClear: vm.profile.targetWeightKg != nil ? { vm.profile.targetWeightKg = nil } : nil
                    ) { editingMetric = .targetWeight }

                    metricTile(
                        label: L10n.tr("Body fat"),
                        value: vm.profile.bodyFatPercentage.map { "\(Int($0))" } ?? "—",
                        unit: "%",
                        filled: vm.profile.bodyFatPercentage != nil,
                        accessibilityIdentifier: "strq.onboarding.metric.bodyFat",
                        trailingClear: vm.profile.bodyFatPercentage != nil ? { vm.profile.bodyFatPercentage = nil } : nil
                    ) { editingMetric = .bodyFat }
                }

                if let target = vm.profile.targetWeightKg {
                    let diff = target - vm.profile.weightKg
                    HStack(spacing: 8) {
                        Image(systemName: diff > 0.05 ? "arrow.up.right" : diff < -0.05 ? "arrow.down.right" : "equal")
                            .font(.system(size: 11, weight: .bold))
                        Text(diff > 0.05 ? L10n.format("+%.1f kg to gain", diff)
                             : diff < -0.05 ? L10n.format("%.1f kg to lose", diff)
                             : L10n.tr("Maintaining current weight"))
                            .font(.caption.weight(.semibold))
                    }
                    .foregroundStyle(STRQBrand.steel)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.white.opacity(0.04), in: Capsule())
                    .overlay(Capsule().strokeBorder(Color.white.opacity(0.06), lineWidth: 0.5))
                }

                Text(L10n.tr("Target weight and body fat are optional."))
                    .font(.caption2)
                    .foregroundStyle(.white.opacity(0.35))
            }
            .padding(20)
            .padding(.bottom, scrollBottomPadding)
        }
    }

    // MARK: - Chapter 3: Goal

    private var goalStep: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                stepHero(
                    eyebrow: L10n.tr("Direction"),
                    title: L10n.tr("What's your goal?"),
                    subtitle: L10n.tr("Shapes exercises, volume, intensity, and progression.")
                )

                LazyVGrid(columns: [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)], spacing: 10) {
                    ForEach(FitnessGoal.allCases) { goal in
                        let isSelected = vm.profile.goal == goal
                        Button {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                                vm.profile.goal = goal
                                selectionPulse.toggle()
                            }
                        } label: {
                            VStack(spacing: 10) {
                                Image(systemName: goal.symbolName)
                                    .font(.title2)
                                    .foregroundStyle(isSelected ? STRQBrand.steel : .white)
                                    .frame(width: 42, height: 42)
                                    .background(
                                        isSelected ? STRQBrand.steel.opacity(0.14) : Color.white.opacity(0.06),
                                        in: Circle()
                                    )
                                Text(goal.displayName)
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(.white)
                                    .multilineTextAlignment(.center)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 108)
                            .background(
                                isSelected
                                    ? AnyShapeStyle(LinearGradient(colors: [Color.white.opacity(0.105), STRQBrand.steel.opacity(0.085)], startPoint: .topLeading, endPoint: .bottomTrailing))
                                    : AnyShapeStyle(Color.white.opacity(0.04)),
                                in: .rect(cornerRadius: 16)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .strokeBorder(isSelected ? STRQBrand.steel.opacity(0.44) : Color.white.opacity(0.06), lineWidth: 1)
                            )
                            .overlay(alignment: .topTrailing) {
                                if isSelected {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 10, weight: .black))
                                        .foregroundStyle(.black)
                                        .frame(width: 18, height: 18)
                                        .background(STRQBrand.steelGradient, in: Circle())
                                        .padding(8)
                                }
                            }
                        }
                        .sensoryFeedback(.selection, trigger: selectionPulse)
                        .accessibilityIdentifier(onboardingIdentifier("goal", goal.rawValue))
                    }
                }
            }
            .padding(20)
            .padding(.bottom, scrollBottomPadding)
        }
    }

    // MARK: - Chapter 4: Training

    private var trainingStep: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                stepHero(
                    eyebrow: L10n.tr("Structure"),
                    title: L10n.tr("How you train"),
                    subtitle: L10n.tr("Experience, schedule, and split preference.")
                )

                fieldGroup(L10n.tr("Experience level")) {
                    VStack(spacing: 8) {
                        ForEach(TrainingLevel.allCases) { level in
                            levelRow(level)
                        }
                    }
                }

                fieldGroup(L10n.tr("Training days / week")) {
                    HStack(spacing: 6) {
                        ForEach(1...6, id: \.self) { n in
                            pillNumber(n, selected: vm.profile.daysPerWeek == n, accessibilityIdentifier: "strq.onboarding.days.\(n)") {
                                vm.profile.daysPerWeek = n
                            }
                        }
                    }
                }

                fieldGroup(L10n.tr("Workout length")) {
                    let presets = [30, 45, 60, 75, 90, 120]
                    LazyVGrid(columns: [GridItem(.flexible(), spacing: 6), GridItem(.flexible(), spacing: 6), GridItem(.flexible(), spacing: 6)], spacing: 6) {
                        ForEach(presets, id: \.self) { m in
                            let isSelected = vm.profile.minutesPerSession == m
                            Button {
                                withAnimation(STRQMotion.tap) { vm.profile.minutesPerSession = m }
                                selectionPulse.toggle()
                            } label: {
                                VStack(spacing: 2) {
                                    Text("\(m)")
                                        .font(.system(.title3, design: .rounded, weight: .bold))
                                        .monospacedDigit()
                                    Text("min")
                                        .font(.caption2.weight(.semibold))
                                        .foregroundStyle(isSelected ? .black.opacity(0.55) : .white.opacity(0.4))
                                }
                                .foregroundStyle(isSelected ? .black : .white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                                .background(
                                    isSelected ? AnyShapeStyle(STRQBrand.steelGradient) : AnyShapeStyle(Color.white.opacity(0.04)),
                                    in: .rect(cornerRadius: 12)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .strokeBorder(isSelected ? Color.white.opacity(0.16) : Color.white.opacity(0.06), lineWidth: 1)
                                )
                            }
                            .buttonStyle(.strqPressable)
                            .accessibilityIdentifier("strq.onboarding.minutes.\(m)")
                        }
                    }
                }

                fieldGroup(L10n.tr("Preferred split")) {
                    LazyVGrid(columns: [GridItem(.flexible(), spacing: 8), GridItem(.flexible(), spacing: 8)], spacing: 8) {
                        ForEach(SplitPreference.allCases) { split in
                            selectionChip(split.displayName, selected: vm.profile.splitPreference == split, accessibilityIdentifier: onboardingIdentifier("split", split.rawValue)) {
                                vm.profile.splitPreference = split
                            }
                        }
                    }
                }
            }
            .padding(20)
            .padding(.bottom, scrollBottomPadding)
        }
    }

    @ViewBuilder
    private func levelRow(_ level: TrainingLevel) -> some View {
        let isSelected = vm.profile.trainingLevel == level
        Button {
            withAnimation(.spring(response: 0.3)) {
                vm.profile.trainingLevel = level
                selectionPulse.toggle()
            }
        } label: {
            HStack(spacing: 14) {
                Image(systemName: levelIcon(level))
                    .font(.body.weight(.semibold))
                    .foregroundStyle(isSelected ? STRQBrand.steel : .white)
                    .frame(width: 36, height: 36)
                    .background(
                        isSelected ? STRQBrand.steel.opacity(0.14) : Color.white.opacity(0.08),
                        in: .rect(cornerRadius: 10)
                    )
                VStack(alignment: .leading, spacing: 2) {
                    Text(level.shortName)
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(.white)
                    Text(levelSubtitle(level))
                        .font(.caption)
                        .foregroundStyle(isSelected ? .white.opacity(0.72) : .white.opacity(0.55))
                }
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.caption.weight(.black))
                        .foregroundStyle(.black)
                        .frame(width: 20, height: 20)
                        .background(STRQBrand.steelGradient, in: Circle())
                }
            }
            .padding(14)
            .background(
                isSelected ? AnyShapeStyle(LinearGradient(colors: [Color.white.opacity(0.10), STRQBrand.steel.opacity(0.08)], startPoint: .topLeading, endPoint: .bottomTrailing)) : AnyShapeStyle(Color.white.opacity(0.04)),
                in: .rect(cornerRadius: 14)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .strokeBorder(isSelected ? STRQBrand.steel.opacity(0.44) : Color.white.opacity(0.06), lineWidth: 1)
            )
        }
        .buttonStyle(.strqPressable)
        .sensoryFeedback(.selection, trigger: selectionPulse)
        .accessibilityIdentifier(onboardingIdentifier("trainingLevel", level.rawValue))
    }

    @ViewBuilder
    private func pillNumber(_ n: Int, selected: Bool, accessibilityIdentifier: String? = nil, action: @escaping () -> Void) -> some View {
        Button {
            withAnimation(STRQMotion.tap) { action() }
            selectionPulse.toggle()
        } label: {
            Text("\(n)")
                .font(.system(.title3, design: .rounded, weight: .bold).monospacedDigit())
                .foregroundStyle(selected ? .black : .white)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(
                    selected ? AnyShapeStyle(STRQBrand.steelGradient) : AnyShapeStyle(Color.white.opacity(0.04)),
                    in: .rect(cornerRadius: 12)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(selected ? Color.white.opacity(0.16) : Color.white.opacity(0.06), lineWidth: 1)
                )
        }
        .buttonStyle(.strqPressable)
        .sensoryFeedback(.selection, trigger: selectionPulse)
        .strqOptionalAccessibilityIdentifier(accessibilityIdentifier)
    }

    private func levelIcon(_ level: TrainingLevel) -> String {
        switch level {
        case .beginner: return "leaf.fill"
        case .intermediate: return "bolt.fill"
        case .advanced: return "star.fill"
        }
    }

    private func levelSubtitle(_ level: TrainingLevel) -> String {
        switch level {
        case .beginner: return L10n.tr("Less than 1 year of consistent training")
        case .intermediate: return L10n.tr("1–3 years of structured training")
        case .advanced: return L10n.tr("3+ years with solid technique")
        }
    }

    // MARK: - Chapter 5: Setup

    private var setupStep: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                stepHero(
                    eyebrow: L10n.tr("Environment"),
                    title: L10n.tr("Your training setup"),
                    subtitle: L10n.tr("Exercises are matched to your equipment and any restrictions.")
                )

                fieldGroup(L10n.tr("Where do you train?")) {
                    HStack(spacing: 10) {
                        ForEach(TrainingLocation.allCases) { loc in
                            locationTile(loc)
                        }
                    }
                }

                if vm.profile.trainingLocation != .gym {
                    fieldGroup(L10n.tr("Available equipment")) {
                        let homeEquipment: [Equipment] = [.dumbbell, .kettlebell, .resistanceBand, .pullUpBar, .bench, .stabilityBall, .foamRoller, .mat, .trx, .rings, .abWheel]
                        LazyVGrid(columns: [GridItem(.flexible(), spacing: 8), GridItem(.flexible(), spacing: 8)], spacing: 8) {
                            ForEach(homeEquipment) { equip in
                                selectionChip(equip.displayName, selected: vm.profile.availableEquipment.contains(equip), accessibilityIdentifier: onboardingIdentifier("equipment", equip.rawValue)) {
                                    if vm.profile.availableEquipment.contains(equip) {
                                        vm.profile.availableEquipment.removeAll { $0 == equip }
                                    } else {
                                        vm.profile.availableEquipment.append(equip)
                                    }
                                }
                            }
                        }
                    }
                }

                fieldGroup(L10n.tr("Injuries or restrictions")) {
                    Text(L10n.tr("Select any areas of concern so STRQ can avoid poor exercise matches."))
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.5))
                        .padding(.bottom, 2)

                    LazyVGrid(columns: [GridItem(.flexible(), spacing: 8), GridItem(.flexible(), spacing: 8), GridItem(.flexible(), spacing: 8)], spacing: 8) {
                        ForEach(InjuryRestriction.allCases) { injury in
                            selectionChip(injury.localizedDisplayName, selected: vm.profile.injuries.contains(injury.rawValue), accessibilityIdentifier: onboardingIdentifier("injury", injury.rawValue)) {
                                if vm.profile.injuries.contains(injury.rawValue) {
                                    vm.profile.injuries.removeAll { $0 == injury.rawValue }
                                } else {
                                    vm.profile.injuries.append(injury.rawValue)
                                }
                            }
                        }
                    }
                }
            }
            .padding(20)
            .padding(.bottom, scrollBottomPadding)
        }
    }

    @ViewBuilder
    private func locationTile(_ loc: TrainingLocation) -> some View {
        let isSelected = vm.profile.trainingLocation == loc
        Button {
            withAnimation(.spring(response: 0.3)) {
                vm.profile.trainingLocation = loc
                selectionPulse.toggle()
            }
        } label: {
            VStack(spacing: 8) {
                Image(systemName: loc.symbolName)
                    .font(.title3)
                    .foregroundStyle(isSelected ? STRQBrand.steel : .white)
                Text(loc.displayName)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 92)
            .background(
                isSelected ? AnyShapeStyle(LinearGradient(colors: [Color.white.opacity(0.10), STRQBrand.steel.opacity(0.08)], startPoint: .topLeading, endPoint: .bottomTrailing)) : AnyShapeStyle(Color.white.opacity(0.04)),
                in: .rect(cornerRadius: 14)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .strokeBorder(isSelected ? STRQBrand.steel.opacity(0.44) : Color.white.opacity(0.06), lineWidth: 1)
            )
            .overlay(alignment: .topTrailing) {
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 9, weight: .black))
                        .foregroundStyle(.black)
                        .frame(width: 16, height: 16)
                        .background(STRQBrand.steelGradient, in: Circle())
                        .padding(6)
                }
            }
        }
        .buttonStyle(.strqPressable)
        .sensoryFeedback(.selection, trigger: selectionPulse)
        .accessibilityIdentifier(onboardingIdentifier("location", loc.rawValue))
    }

    // MARK: - Chapter 6: Muscle focus

    private var muscleFocusStep: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                stepHero(
                    eyebrow: L10n.tr("Priorities"),
                    title: L10n.tr("Muscle focus"),
                    subtitle: L10n.tr("Tap muscles to give them more — or less — attention. Optional.")
                )

                MuscleFocusView(
                    focusMuscles: $vm.profile.focusMuscles,
                    neglectMuscles: $vm.profile.neglectMuscles,
                    gender: vm.profile.gender
                )
            }
            .padding(20)
            .padding(.bottom, scrollBottomPadding)
        }
    }

    // MARK: - Chapter 7: Lifestyle

    private var lifestyleStep: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                stepHero(
                    eyebrow: L10n.tr("Recovery"),
                    title: L10n.tr("Lifestyle & recovery"),
                    subtitle: L10n.tr("Quick recovery signals that shape training load.")
                )

                fieldGroup(L10n.tr("Sleep")) {
                    VStack(spacing: 8) {
                        ForEach(SleepQuality.allCases) { sleep in
                            selectionChip(sleep.displayName, selected: vm.profile.sleepQuality == sleep, accessibilityIdentifier: onboardingIdentifier("sleep", sleep.rawValue)) {
                                vm.profile.sleepQuality = sleep
                            }
                        }
                    }
                }

                fieldGroup(L10n.tr("Stress")) {
                    LazyVGrid(columns: [GridItem(.flexible(), spacing: 8), GridItem(.flexible(), spacing: 8)], spacing: 8) {
                        ForEach(StressLevel.allCases) { stress in
                            selectionChip(stress.displayName, selected: vm.profile.stressLevel == stress, accessibilityIdentifier: onboardingIdentifier("stress", stress.rawValue)) {
                                vm.profile.stressLevel = stress
                            }
                        }
                    }
                }

                fieldGroup(L10n.tr("Activity")) {
                    VStack(spacing: 8) {
                        ForEach(ActivityLevel.allCases) { level in
                            selectionChip(level.displayName, selected: vm.profile.activityLevel == level, accessibilityIdentifier: onboardingIdentifier("activity", level.rawValue)) {
                                vm.profile.activityLevel = level
                            }
                        }
                    }
                }

                fieldGroup(L10n.tr("Recovery")) {
                    HStack(spacing: 8) {
                        ForEach(RecoveryCapacity.allCases) { rec in
                            selectionChip(rec.displayName, selected: vm.profile.recoveryCapacity == rec, accessibilityIdentifier: onboardingIdentifier("recovery", rec.rawValue)) {
                                vm.profile.recoveryCapacity = rec
                            }
                        }
                    }
                }
            }
            .padding(20)
            .padding(.bottom, scrollBottomPadding)
        }
    }

    // MARK: - Shared components

    @ViewBuilder
    private func stepHero(eyebrow: String, title: String, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 10) {
                Image(systemName: stepSymbolName)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(STRQBrand.steel)
                    .frame(width: 30, height: 30)
                    .background(Color.white.opacity(0.055), in: .rect(cornerRadius: 10))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .strokeBorder(Color.white.opacity(0.08), lineWidth: 1)
                    )
                Text(eyebrow.uppercased())
                    .font(.caption2.weight(.bold))
                    .tracking(1.0)
                    .foregroundStyle(STRQBrand.steel)
                Spacer()
                Text(String(format: "%02d", step))
                    .font(.caption2.weight(.bold).monospacedDigit())
                    .foregroundStyle(.white.opacity(0.48))
            }

            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.title.bold())
                    .foregroundStyle(.white)
                    .fixedSize(horizontal: false, vertical: true)
                Text(subtitle)
                    .font(.callout)
                    .foregroundStyle(.white.opacity(0.6))
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            LinearGradient(
                colors: [Color.white.opacity(0.075), Color.white.opacity(0.025)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            in: .rect(cornerRadius: 22)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 22)
                .strokeBorder(Color.white.opacity(0.08), lineWidth: 1)
        )
    }

    @ViewBuilder
    private func fieldGroup(_ label: String, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                RoundedRectangle(cornerRadius: 2)
                    .fill(STRQBrand.steel.opacity(0.75))
                    .frame(width: 3, height: 15)
                Text(label.uppercased())
                    .font(.caption2.weight(.bold))
                    .tracking(0.8)
                    .foregroundStyle(.white.opacity(0.55))
                Spacer()
            }
            content()
        }
        .padding(14)
        .background(Color.white.opacity(0.025), in: .rect(cornerRadius: 18))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .strokeBorder(Color.white.opacity(0.055), lineWidth: 1)
        )
    }

    @ViewBuilder
    private func tapValueTile(value: String, unit: String, accessibilityIdentifier: String? = nil, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(alignment: .firstTextBaseline, spacing: 6) {
                Text(value)
                    .font(.system(.title2, design: .rounded, weight: .bold))
                    .foregroundStyle(.white)
                    .monospacedDigit()
                Text(unit)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.white.opacity(0.55))
                Spacer()
                Image(systemName: "pencil")
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.4))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(Color.white.opacity(0.05), in: .rect(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .strokeBorder(Color.white.opacity(0.08), lineWidth: 1)
            )
            .contentShape(.rect(cornerRadius: 14))
        }
        .buttonStyle(.strqPressable)
        .strqOptionalAccessibilityIdentifier(accessibilityIdentifier)
    }

    @ViewBuilder
    private func metricTile(
        label: String,
        value: String,
        unit: String,
        filled: Bool,
        accessibilityIdentifier: String? = nil,
        trailingClear: (() -> Void)? = nil,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(label.uppercased())
                        .font(.caption2.weight(.bold))
                        .tracking(0.8)
                        .foregroundStyle(.white.opacity(0.5))
                    Spacer()
                    if let trailingClear {
                        Button {
                            withAnimation(STRQMotion.tap) { trailingClear() }
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.footnote)
                                .foregroundStyle(.white.opacity(0.3))
                        }
                        .buttonStyle(.plain)
                    } else {
                        Image(systemName: "pencil")
                            .font(.caption2.weight(.semibold))
                            .foregroundStyle(.white.opacity(0.3))
                    }
                }
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text(value)
                        .font(.system(size: 30, weight: .bold, design: .rounded))
                        .foregroundStyle(filled ? .white : .white.opacity(0.4))
                        .monospacedDigit()
                        .minimumScaleFactor(0.7)
                        .lineLimit(1)
                    Text(unit)
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.white.opacity(0.5))
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(14)
            .background(
                LinearGradient(
                    colors: filled ? [Color.white.opacity(0.07), Color.white.opacity(0.035)] : [Color.white.opacity(0.035), Color.white.opacity(0.02)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                in: .rect(cornerRadius: 14)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .strokeBorder(Color.white.opacity(filled ? 0.10 : 0.06), lineWidth: 1)
            )
            .contentShape(.rect(cornerRadius: 14))
        }
        .buttonStyle(.strqPressable)
        .strqOptionalAccessibilityIdentifier(accessibilityIdentifier)
    }

    @ViewBuilder
    private func selectionChip(_ title: String, selected: Bool, accessibilityIdentifier: String? = nil, action: @escaping () -> Void) -> some View {
        Button {
            withAnimation(STRQMotion.tap) { action() }
            selectionPulse.toggle()
        } label: {
            HStack(spacing: 6) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
                    .multilineTextAlignment(.center)
                if selected {
                    Image(systemName: "checkmark")
                        .font(.caption2.weight(.black))
                        .foregroundStyle(STRQBrand.steel)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 13)
            .padding(.horizontal, 10)
            .background(
                selected ? AnyShapeStyle(LinearGradient(colors: [Color.white.opacity(0.10), STRQBrand.steel.opacity(0.08)], startPoint: .topLeading, endPoint: .bottomTrailing)) : AnyShapeStyle(Color.white.opacity(0.04)),
                in: .rect(cornerRadius: 12)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(selected ? STRQBrand.steel.opacity(0.44) : Color.white.opacity(0.06), lineWidth: 1)
            )
            .contentShape(.rect(cornerRadius: 12))
        }
        .buttonStyle(.strqPressable)
        .sensoryFeedback(.selection, trigger: selectionPulse)
        .strqOptionalAccessibilityIdentifier(accessibilityIdentifier)
    }

    private func onboardingIdentifier(_ group: String, _ value: String) -> String {
        let safeValue = value
            .lowercased()
            .replacingOccurrences(of: " ", with: "-")
            .replacingOccurrences(of: "/", with: "-")
            .replacingOccurrences(of: "+", with: "plus")
            .filter { $0.isLetter || $0.isNumber || $0 == "-" || $0 == "." }
        return "strq.onboarding.\(group).\(safeValue)"
    }
}

private extension View {
    @ViewBuilder
    func strqOptionalAccessibilityIdentifier(_ identifier: String?) -> some View {
        if let identifier {
            accessibilityIdentifier(identifier)
        } else {
            self
        }
    }
}
