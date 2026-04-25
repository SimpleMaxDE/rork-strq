import SwiftUI

struct OnboardingView: View {
    @Bindable var vm: AppViewModel
    @State private var step: Int = 0
    @State private var appeared: Bool = false
    @State private var selectionPulse: Bool = false
    @FocusState private var nameFocused: Bool
    @State private var editingMetric: MetricEdit?

    private let totalSteps = 8  // 0 welcome + 7 chapters

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

                navigationButtons
                    .padding(.horizontal, 20)
                    .padding(.bottom, 16)
            }
        }
        .preferredColorScheme(.dark)
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
            Color.black.ignoresSafeArea()
            MeshGradient(width: 3, height: 3, points: [
                [0, 0], [0.5, 0], [1, 0],
                [0, 0.5], [0.5, 0.5], [1, 0.5],
                [0, 1], [0.5, 1], [1, 1]
            ], colors: [
                .black, .black, .black,
                .black, Color.white.opacity(0.03), .black,
                .black, .black, .black
            ])
            .ignoresSafeArea()
        }
    }

    // MARK: - Header

    private var header: some View {
        VStack(spacing: 12) {
            HStack(spacing: 10) {
                Text(String(format: "%02d", step))
                    .font(.caption2.weight(.bold).monospacedDigit())
                    .foregroundStyle(.white)
                    .padding(.horizontal, 7)
                    .padding(.vertical, 3)
                    .background(Color.white.opacity(0.10), in: Capsule())
                Text(stepCategoryLabel)
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.6))
                    .tracking(0.8)
                Spacer()
                Text("\(step) / \(totalSteps - 1)")
                    .font(.caption2.weight(.medium).monospacedDigit())
                    .foregroundStyle(.white.opacity(0.35))
            }
            progressBar
        }
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

    private var progressBar: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule().fill(Color.white.opacity(0.06))
                Capsule()
                    .fill(STRQBrand.accentGradient)
                    .frame(width: max(0, geo.size.width * CGFloat(step) / CGFloat(totalSteps - 1)))
                    .animation(.spring(response: 0.5, dampingFraction: 0.85), value: step)
            }
        }
        .frame(height: 3)
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
                .foregroundStyle(.black)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(
                    (canAdvance ? AnyShapeStyle(STRQBrand.accentGradient) : AnyShapeStyle(Color.white.opacity(0.14))),
                    in: .rect(cornerRadius: 14)
                )
                .opacity(canAdvance ? 1 : 0.55)
            }
            .buttonStyle(.strqPressable)
            .disabled(!canAdvance)
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
            VStack(spacing: 28) {
                STRQLogoView(size: 80, animated: true)
                    .opacity(appeared ? 1 : 0)
                    .scaleEffect(appeared ? 1 : 0.8)
                    .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.2), value: appeared)

                VStack(spacing: 12) {
                    Text("STRQ")
                        .font(.system(size: 38, weight: .black, design: .default))
                        .tracking(4)
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 16)
                        .animation(.easeOut(duration: 0.6).delay(0.35), value: appeared)

                    Text(L10n.tr("A training system built around you."))
                        .font(.title3.weight(.medium))
                        .foregroundStyle(.white.opacity(0.9))
                        .multilineTextAlignment(.center)
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 12)
                        .animation(.easeOut(duration: 0.6).delay(0.5), value: appeared)

                    Text(L10n.tr("Seven quick chapters. Then a plan that actually fits."))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 10)
                        .animation(.easeOut(duration: 0.6).delay(0.6), value: appeared)
                }
            }
            Spacer()
            VStack(spacing: 14) {
                welcomeFeatureRow(icon: "slider.horizontal.3", text: L10n.tr("Calibrated to your body, goal, and schedule"))
                welcomeFeatureRow(icon: "chart.line.uptrend.xyaxis", text: L10n.tr("Progression that adapts after every session"))
                welcomeFeatureRow(icon: "waveform.path.ecg", text: L10n.tr("Recovery-aware. No guesswork on load or volume"))
            }
            .padding(.horizontal, 24)
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 20)
            .animation(.easeOut(duration: 0.6).delay(0.65), value: appeared)
            Spacer().frame(height: 40)
        }
        .padding(.horizontal, 20)
    }

    private func welcomeFeatureRow(icon: String, text: String) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.body)
                .foregroundStyle(.white)
                .frame(width: 36, height: 36)
                .background(Color.white.opacity(0.08), in: .rect(cornerRadius: 10))
            Text(text)
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.8))
            Spacer()
        }
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
                        unit: L10n.tr("years")
                    ) { editingMetric = .age }
                }

                fieldGroup(L10n.tr("Gender")) {
                    LazyVGrid(columns: [GridItem(.flexible(), spacing: 8), GridItem(.flexible(), spacing: 8)], spacing: 8) {
                        ForEach(Gender.allCases) { gender in
                            selectionChip(gender.displayName, selected: vm.profile.gender == gender) {
                                vm.profile.gender = gender
                            }
                        }
                    }
                }
            }
            .padding(20)
            .padding(.bottom, 20)
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
                        filled: true
                    ) { editingMetric = .height }

                    metricTile(
                        label: L10n.tr("Weight"),
                        value: String(format: "%.1f", vm.profile.weightKg),
                        unit: "kg",
                        filled: true
                    ) { editingMetric = .weight }

                    metricTile(
                        label: L10n.tr("Target weight"),
                        value: vm.profile.targetWeightKg.map { String(format: "%.1f", $0) } ?? "—",
                        unit: "kg",
                        filled: vm.profile.targetWeightKg != nil,
                        trailingClear: vm.profile.targetWeightKg != nil ? { vm.profile.targetWeightKg = nil } : nil
                    ) { editingMetric = .targetWeight }

                    metricTile(
                        label: L10n.tr("Body fat"),
                        value: vm.profile.bodyFatPercentage.map { "\(Int($0))" } ?? "—",
                        unit: "%",
                        filled: vm.profile.bodyFatPercentage != nil,
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
            .padding(.bottom, 20)
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
                                    .foregroundStyle(isSelected ? .black : .white)
                                    .frame(width: 42, height: 42)
                                    .background(
                                        isSelected ? Color.black.opacity(0.12) : Color.white.opacity(0.06),
                                        in: Circle()
                                    )
                                Text(goal.displayName)
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(isSelected ? .black : .white)
                                    .multilineTextAlignment(.center)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 108)
                            .background(
                                isSelected
                                    ? AnyShapeStyle(STRQBrand.accentGradient)
                                    : AnyShapeStyle(Color.white.opacity(0.04)),
                                in: .rect(cornerRadius: 16)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .strokeBorder(isSelected ? Color.white.opacity(0.35) : Color.white.opacity(0.06), lineWidth: 1)
                            )
                            .overlay(alignment: .topTrailing) {
                                if isSelected {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 10, weight: .black))
                                        .foregroundStyle(.white)
                                        .frame(width: 18, height: 18)
                                        .background(Color.black.opacity(0.85), in: Circle())
                                        .padding(8)
                                }
                            }
                        }
                        .sensoryFeedback(.selection, trigger: selectionPulse)
                    }
                }
            }
            .padding(20)
            .padding(.bottom, 20)
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
                            pillNumber(n, selected: vm.profile.daysPerWeek == n) {
                                vm.profile.daysPerWeek = n
                            }
                        }
                    }
                }

                fieldGroup(L10n.tr("Session length")) {
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
                                    Text(L10n.tr("min"))
                                        .font(.caption2.weight(.semibold))
                                        .foregroundStyle(isSelected ? .black.opacity(0.55) : .white.opacity(0.4))
                                }
                                .foregroundStyle(isSelected ? .black : .white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                                .background(
                                    isSelected ? AnyShapeStyle(STRQBrand.accentGradient) : AnyShapeStyle(Color.white.opacity(0.04)),
                                    in: .rect(cornerRadius: 12)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .strokeBorder(isSelected ? .clear : Color.white.opacity(0.06), lineWidth: 1)
                                )
                            }
                            .buttonStyle(.strqPressable)
                        }
                    }
                }

                fieldGroup(L10n.tr("Preferred split")) {
                    LazyVGrid(columns: [GridItem(.flexible(), spacing: 8), GridItem(.flexible(), spacing: 8)], spacing: 8) {
                        ForEach(SplitPreference.allCases) { split in
                            selectionChip(split.displayName, selected: vm.profile.splitPreference == split) {
                                vm.profile.splitPreference = split
                            }
                        }
                    }
                }
            }
            .padding(20)
            .padding(.bottom, 20)
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
                    .foregroundStyle(isSelected ? .black : .white)
                    .frame(width: 36, height: 36)
                    .background(
                        isSelected ? Color.black.opacity(0.12) : Color.white.opacity(0.08),
                        in: .rect(cornerRadius: 10)
                    )
                VStack(alignment: .leading, spacing: 2) {
                    Text(level.shortName)
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(isSelected ? .black : .white)
                    Text(levelSubtitle(level))
                        .font(.caption)
                        .foregroundStyle(isSelected ? .black.opacity(0.65) : .white.opacity(0.55))
                }
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.caption.weight(.black))
                        .foregroundStyle(.white)
                        .frame(width: 20, height: 20)
                        .background(Color.black.opacity(0.85), in: Circle())
                }
            }
            .padding(14)
            .background(
                isSelected ? AnyShapeStyle(STRQBrand.accentGradient) : AnyShapeStyle(Color.white.opacity(0.04)),
                in: .rect(cornerRadius: 14)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .strokeBorder(isSelected ? Color.white.opacity(0.25) : Color.white.opacity(0.06), lineWidth: 1)
            )
        }
        .buttonStyle(.strqPressable)
        .sensoryFeedback(.selection, trigger: selectionPulse)
    }

    @ViewBuilder
    private func pillNumber(_ n: Int, selected: Bool, action: @escaping () -> Void) -> some View {
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
                    selected ? AnyShapeStyle(STRQBrand.accentGradient) : AnyShapeStyle(Color.white.opacity(0.04)),
                    in: .rect(cornerRadius: 12)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(selected ? .clear : Color.white.opacity(0.06), lineWidth: 1)
                )
        }
        .buttonStyle(.strqPressable)
        .sensoryFeedback(.selection, trigger: selectionPulse)
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
                                selectionChip(equip.displayName, selected: vm.profile.availableEquipment.contains(equip)) {
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
                    Text(L10n.tr("Select any areas of concern so exercises can be filtered for safety."))
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.5))
                        .padding(.bottom, 2)

                    let commonInjuries = ["Shoulder", "Knee", "Lower Back", "Wrist", "Neck", "Hip", "Ankle", "Elbow"]
                    LazyVGrid(columns: [GridItem(.flexible(), spacing: 8), GridItem(.flexible(), spacing: 8), GridItem(.flexible(), spacing: 8)], spacing: 8) {
                        ForEach(commonInjuries, id: \.self) { injury in
                            selectionChip(L10n.tr(injury), selected: vm.profile.injuries.contains(injury)) {
                                if vm.profile.injuries.contains(injury) {
                                    vm.profile.injuries.removeAll { $0 == injury }
                                } else {
                                    vm.profile.injuries.append(injury)
                                }
                            }
                        }
                    }
                }
            }
            .padding(20)
            .padding(.bottom, 20)
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
                    .foregroundStyle(isSelected ? .black : .white)
                Text(loc.displayName)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(isSelected ? .black : .white)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 92)
            .background(
                isSelected ? AnyShapeStyle(STRQBrand.accentGradient) : AnyShapeStyle(Color.white.opacity(0.04)),
                in: .rect(cornerRadius: 14)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .strokeBorder(isSelected ? Color.white.opacity(0.25) : Color.white.opacity(0.06), lineWidth: 1)
            )
            .overlay(alignment: .topTrailing) {
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 9, weight: .black))
                        .foregroundStyle(.white)
                        .frame(width: 16, height: 16)
                        .background(Color.black.opacity(0.85), in: Circle())
                        .padding(6)
                }
            }
        }
        .buttonStyle(.strqPressable)
        .sensoryFeedback(.selection, trigger: selectionPulse)
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
            .padding(.bottom, 20)
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
                            selectionChip(sleep.displayName, selected: vm.profile.sleepQuality == sleep) {
                                vm.profile.sleepQuality = sleep
                            }
                        }
                    }
                }

                fieldGroup(L10n.tr("Stress")) {
                    LazyVGrid(columns: [GridItem(.flexible(), spacing: 8), GridItem(.flexible(), spacing: 8)], spacing: 8) {
                        ForEach(StressLevel.allCases) { stress in
                            selectionChip(stress.displayName, selected: vm.profile.stressLevel == stress) {
                                vm.profile.stressLevel = stress
                            }
                        }
                    }
                }

                fieldGroup(L10n.tr("Activity")) {
                    VStack(spacing: 8) {
                        ForEach(ActivityLevel.allCases) { level in
                            selectionChip(level.displayName, selected: vm.profile.activityLevel == level) {
                                vm.profile.activityLevel = level
                            }
                        }
                    }
                }

                fieldGroup(L10n.tr("Recovery")) {
                    HStack(spacing: 8) {
                        ForEach(RecoveryCapacity.allCases) { rec in
                            selectionChip(rec.displayName, selected: vm.profile.recoveryCapacity == rec) {
                                vm.profile.recoveryCapacity = rec
                            }
                        }
                    }
                }
            }
            .padding(20)
            .padding(.bottom, 20)
        }
    }

    // MARK: - Shared components

    @ViewBuilder
    private func stepHero(eyebrow: String, title: String, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(eyebrow.uppercased())
                .font(.caption2.weight(.bold))
                .tracking(1.2)
                .foregroundStyle(STRQBrand.steel)
            Text(title)
                .font(.title.bold())
                .foregroundStyle(.white)
                .fixedSize(horizontal: false, vertical: true)
            Text(subtitle)
                .font(.callout)
                .foregroundStyle(.white.opacity(0.58))
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.bottom, 2)
    }

    @ViewBuilder
    private func fieldGroup(_ label: String, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(label.uppercased())
                .font(.caption2.weight(.bold))
                .tracking(0.8)
                .foregroundStyle(.white.opacity(0.5))
            content()
        }
    }

    @ViewBuilder
    private func tapValueTile(value: String, unit: String, action: @escaping () -> Void) -> some View {
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
    }

    @ViewBuilder
    private func metricTile(
        label: String,
        value: String,
        unit: String,
        filled: Bool,
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
            .background(Color.white.opacity(filled ? 0.06 : 0.03), in: .rect(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .strokeBorder(Color.white.opacity(filled ? 0.10 : 0.06), lineWidth: 1)
            )
            .contentShape(.rect(cornerRadius: 14))
        }
        .buttonStyle(.strqPressable)
    }

    @ViewBuilder
    private func selectionChip(_ title: String, selected: Bool, action: @escaping () -> Void) -> some View {
        Button {
            withAnimation(STRQMotion.tap) { action() }
            selectionPulse.toggle()
        } label: {
            HStack(spacing: 6) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(selected ? .black : .white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)
                if selected {
                    Image(systemName: "checkmark")
                        .font(.caption2.weight(.black))
                        .foregroundStyle(.black)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 13)
            .padding(.horizontal, 10)
            .background(
                selected ? AnyShapeStyle(STRQBrand.accentGradient) : AnyShapeStyle(Color.white.opacity(0.04)),
                in: .rect(cornerRadius: 12)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(selected ? Color.white.opacity(0.25) : Color.white.opacity(0.06), lineWidth: 1)
            )
            .contentShape(.rect(cornerRadius: 12))
        }
        .buttonStyle(.strqPressable)
        .sensoryFeedback(.selection, trigger: selectionPulse)
    }
}
