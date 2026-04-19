import SwiftUI

struct OnboardingView: View {
    @Bindable var vm: AppViewModel
    @State private var step: Int = 0
    @State private var appeared: Bool = false
    @State private var selectionPulse: Bool = false

    private let totalSteps = 9

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
                    basicInfoStep.tag(1)
                    bodyMetricsStep.tag(2)
                    startingWeightStep.tag(3)
                    goalStep.tag(4)
                    trainingInfoStep.tag(5)
                    locationEquipmentStep.tag(6)
                    muscleFocusStep.tag(7)
                    lifestyleStep.tag(8)
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
        .sensoryFeedback(.selection, trigger: step)
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

    private var header: some View {
        VStack(spacing: 12) {
            HStack {
                stepLabel
                Spacer()
                Text("\(step)/\(totalSteps - 1)")
                    .font(.caption2.weight(.medium).monospacedDigit())
                    .foregroundStyle(.white.opacity(0.35))
            }
            progressBar
        }
    }

    private var stepLabel: some View {
        Text(stepCategoryLabel)
            .font(.caption2.weight(.semibold))
            .foregroundStyle(STRQBrand.steel)
            .tracking(0.5)
    }

    private var stepCategoryLabel: String {
        switch step {
        case 1: return "PERSONAL"
        case 2: return "BODY METRICS"
        case 3: return "STARTING POINT"
        case 4: return "YOUR GOAL"
        case 5: return "TRAINING"
        case 6: return "EQUIPMENT"
        case 7: return "FOCUS AREAS"
        case 8: return "LIFESTYLE"
        default: return ""
        }
    }

    private var progressBar: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule().fill(Color.white.opacity(0.08))
                Capsule()
                    .fill(STRQBrand.accentGradient)
                    .frame(width: max(0, geo.size.width * CGFloat(step) / CGFloat(totalSteps - 1)))
                    .animation(.spring(response: 0.5, dampingFraction: 0.8), value: step)
            }
        }
        .frame(height: 3)
    }

    private var navigationButtons: some View {
        VStack(spacing: 10) {
            Button {
                if step < totalSteps - 1 {
                    withAnimation(.smooth(duration: 0.35)) { step += 1 }
                } else {
                    vm.beginPlanGeneration()
                }
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
                    (canAdvance ? AnyShapeStyle(STRQBrand.accentGradient) : AnyShapeStyle(Color.white.opacity(0.18))),
                    in: .rect(cornerRadius: 14)
                )
                .opacity(canAdvance ? 1 : 0.6)
            }
            .disabled(!canAdvance)

            if step > 0 {
                Button {
                    withAnimation(.smooth(duration: 0.35)) { step -= 1 }
                } label: {
                    Text("Back")
                        .font(.footnote.weight(.medium))
                        .foregroundStyle(.white.opacity(0.4))
                        .frame(maxWidth: .infinity)
                        .frame(height: 32)
                }
            }
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
        case 0: return "Get Started"
        case totalSteps - 1: return "Build My Plan"
        default: return "Continue"
        }
    }

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

                    Text("A training system built around you.")
                        .font(.title3.weight(.medium))
                        .foregroundStyle(.white.opacity(0.9))
                        .multilineTextAlignment(.center)
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 12)
                        .animation(.easeOut(duration: 0.6).delay(0.5), value: appeared)

                    Text("A few questions. Then a plan that actually fits.")
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
                welcomeFeatureRow(icon: "slider.horizontal.3", text: "Calibrated to your body, goal, and schedule")
                welcomeFeatureRow(icon: "chart.line.uptrend.xyaxis", text: "Progression that adapts after every session")
                welcomeFeatureRow(icon: "waveform.path.ecg", text: "Recovery-aware. No guesswork on load or volume")
            }
            .padding(.horizontal, 24)
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 20)
            .animation(.easeOut(duration: 0.6).delay(0.65), value: appeared)

            Spacer()
                .frame(height: 40)
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

    private var basicInfoStep: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                stepHero(
                    title: "About You",
                    subtitle: "STRQ personalizes everything based on who you are."
                )

                fieldGroup("Your Name") {
                    TextField("Enter your name", text: $vm.profile.name)
                        .textFieldStyle(.plain)
                        .font(.body)
                        .padding(16)
                        .background(Color.white.opacity(0.06), in: .rect(cornerRadius: 14))
                }
            }
            .padding(20)
            .padding(.bottom, 20)
        }
        .scrollDismissesKeyboard(.interactively)
    }

    private var bodyMetricsStep: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                stepHero(
                    title: "Body Metrics",
                    subtitle: "Helps calibrate volume, exercise selection, and recovery."
                )

                fieldGroup("Height") {
                    HStack {
                        Text("\(Int(vm.profile.heightCm))")
                            .font(.system(.title2, design: .rounded, weight: .bold))
                            .foregroundStyle(.white)
                            .monospacedDigit()
                        Text("cm")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Spacer()
                    }
                    Slider(value: $vm.profile.heightCm, in: 140...220, step: 1)
                        .tint(.white)
                }

                fieldGroup("Age") {
                    HStack {
                        Text("\(vm.profile.age)")
                            .font(.system(.title2, design: .rounded, weight: .bold))
                            .foregroundStyle(.white)
                            .monospacedDigit()
                        Text("years")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Spacer()
                    }
                    Slider(value: Binding(get: { Double(vm.profile.age) }, set: { vm.profile.age = Int($0) }), in: 14...80, step: 1)
                        .tint(.white)
                }

                fieldGroup("Gender") {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 130), spacing: 8)], spacing: 8) {
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
    }

    private var startingWeightStep: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                stepHero(
                    title: "Your Starting Point",
                    subtitle: "This is your baseline. STRQ tracks progress from here."
                )

                VStack(spacing: 6) {
                    Text(String(format: "%.1f", vm.profile.weightKg))
                        .font(.system(size: 56, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .monospacedDigit()
                    Text("kg")
                        .font(.title3.weight(.medium))
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)

                Slider(value: $vm.profile.weightKg, in: 40...200, step: 0.5)
                    .tint(.white)
                    .padding(.horizontal, 4)

                fieldGroup("Target Weight (optional)") {
                    HStack {
                        Text(vm.profile.targetWeightKg.map { String(format: "%.1f kg", $0) } ?? "Not set")
                            .font(.system(.title3, design: .rounded, weight: .semibold))
                            .foregroundStyle(vm.profile.targetWeightKg != nil ? .white : .secondary)
                        Spacer()
                        if vm.profile.targetWeightKg != nil {
                            Button {
                                vm.profile.targetWeightKg = nil
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.body)
                                    .foregroundStyle(.white.opacity(0.4))
                            }
                        }
                    }
                    Slider(
                        value: Binding(
                            get: { vm.profile.targetWeightKg ?? vm.profile.weightKg },
                            set: { vm.profile.targetWeightKg = $0 }
                        ),
                        in: 40...200, step: 0.5
                    )
                    .tint(.white)

                    if let target = vm.profile.targetWeightKg {
                        let diff = target - vm.profile.weightKg
                        HStack(spacing: 6) {
                            Image(systemName: diff > 0 ? "arrow.up.right" : diff < 0 ? "arrow.down.right" : "equal")
                                .font(.system(size: 10))
                            Text(diff > 0 ? String(format: "+%.1f kg to gain", diff) : diff < 0 ? String(format: "%.1f kg to lose", diff) : "Maintaining")
                                .font(.caption.weight(.medium))
                        }
                        .foregroundStyle(STRQBrand.steel)
                        .padding(.top, 2)
                    }
                }

                fieldGroup("Body Fat % (optional)") {
                    HStack {
                        Text(vm.profile.bodyFatPercentage.map { "\(Int($0))%" } ?? "Not set")
                            .font(.system(.title3, design: .rounded, weight: .semibold))
                            .foregroundStyle(vm.profile.bodyFatPercentage != nil ? .white : .secondary)
                        Spacer()
                    }
                    Slider(value: Binding(get: { vm.profile.bodyFatPercentage ?? 20 }, set: { vm.profile.bodyFatPercentage = $0 }), in: 5...50, step: 1)
                        .tint(.white)
                }
            }
            .padding(20)
            .padding(.bottom, 20)
        }
    }

    private var goalStep: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                stepHero(
                    title: "Your Goal",
                    subtitle: "This shapes everything — exercises, volume, intensity, and progression."
                )

                LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
                    ForEach(FitnessGoal.allCases) { goal in
                        let isSelected = vm.profile.goal == goal
                        Button {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                vm.profile.goal = goal
                                selectionPulse.toggle()
                            }
                        } label: {
                            VStack(spacing: 10) {
                                Image(systemName: goal.symbolName)
                                    .font(.title2)
                                    .foregroundStyle(isSelected ? .black : .white)
                                    .frame(width: 44, height: 44)
                                    .background(
                                        isSelected ? Color.black.opacity(0.15) : Color.white.opacity(0.08),
                                        in: Circle()
                                    )
                                Text(goal.displayName)
                                    .font(.subheadline.weight(.medium))
                                    .foregroundStyle(isSelected ? .black : .white)
                                    .multilineTextAlignment(.center)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 110)
                            .background(
                                isSelected
                                    ? AnyShapeStyle(STRQBrand.accentGradient)
                                    : AnyShapeStyle(Color.white.opacity(0.04)),
                                in: .rect(cornerRadius: 16)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .strokeBorder(isSelected ? Color.white.opacity(0.3) : Color.white.opacity(0.06), lineWidth: 1)
                            )
                        }
                        .sensoryFeedback(.selection, trigger: selectionPulse)
                    }
                }
            }
            .padding(20)
            .padding(.bottom, 20)
        }
    }

    private var trainingInfoStep: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                stepHero(
                    title: "Training Experience",
                    subtitle: "Your level shapes exercise complexity and progression speed."
                )

                fieldGroup("Experience Level") {
                    VStack(spacing: 8) {
                        ForEach(TrainingLevel.allCases) { level in
                            let isSelected = vm.profile.trainingLevel == level
                            Button {
                                withAnimation(.spring(response: 0.3)) { vm.profile.trainingLevel = level }
                            } label: {
                                HStack(spacing: 14) {
                                    Image(systemName: levelIcon(level))
                                        .font(.body.weight(.medium))
                                        .foregroundStyle(isSelected ? .black : .white)
                                        .frame(width: 36, height: 36)
                                        .background(
                                            isSelected ? Color.black.opacity(0.15) : Color.white.opacity(0.08),
                                            in: .rect(cornerRadius: 10)
                                        )
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(level.shortName)
                                            .font(.subheadline.weight(.semibold))
                                            .foregroundStyle(isSelected ? .black : .white)
                                        Text(levelSubtitle(level))
                                            .font(.caption)
                                            .foregroundStyle(isSelected ? .black.opacity(0.6) : .secondary)
                                    }
                                    Spacer()
                                    if isSelected {
                                        Image(systemName: "checkmark.circle.fill")
                                            .font(.body)
                                            .foregroundStyle(.black.opacity(0.6))
                                    }
                                }
                                .padding(14)
                                .background(
                                    isSelected ? AnyShapeStyle(STRQBrand.accentGradient) : AnyShapeStyle(Color.white.opacity(0.04)),
                                    in: .rect(cornerRadius: 14)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .strokeBorder(isSelected ? .clear : Color.white.opacity(0.06), lineWidth: 1)
                                )
                            }
                        }
                    }
                }

                fieldGroup("Training Days Per Week") {
                    HStack {
                        Text("\(vm.profile.daysPerWeek)")
                            .font(.system(.title2, design: .rounded, weight: .bold))
                            .foregroundStyle(.white)
                            .monospacedDigit()
                        Text("days")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Spacer()
                    }
                    Slider(value: Binding(get: { Double(vm.profile.daysPerWeek) }, set: { vm.profile.daysPerWeek = Int($0) }), in: 1...6, step: 1)
                        .tint(.white)
                }

                fieldGroup("Session Length") {
                    HStack {
                        Text("\(vm.profile.minutesPerSession)")
                            .font(.system(.title2, design: .rounded, weight: .bold))
                            .foregroundStyle(.white)
                            .monospacedDigit()
                        Text("minutes")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Spacer()
                    }
                    Slider(value: Binding(get: { Double(vm.profile.minutesPerSession) }, set: { vm.profile.minutesPerSession = Int($0) }), in: 20...120, step: 5)
                        .tint(.white)
                }

                fieldGroup("Preferred Split") {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 130), spacing: 8)], spacing: 8) {
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

    private func levelIcon(_ level: TrainingLevel) -> String {
        switch level {
        case .beginner: return "leaf.fill"
        case .intermediate: return "bolt.fill"
        case .advanced: return "star.fill"
        }
    }

    private func levelSubtitle(_ level: TrainingLevel) -> String {
        switch level {
        case .beginner: return "Less than 1 year of consistent training"
        case .intermediate: return "1-3 years of structured training"
        case .advanced: return "3+ years with solid technique"
        }
    }

    private var locationEquipmentStep: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                stepHero(
                    title: "Training Setup",
                    subtitle: "Exercises are matched to your equipment and environment."
                )

                fieldGroup("Where do you train?") {
                    HStack(spacing: 10) {
                        ForEach(TrainingLocation.allCases) { loc in
                            let isSelected = vm.profile.trainingLocation == loc
                            Button {
                                withAnimation(.spring(response: 0.3)) { vm.profile.trainingLocation = loc }
                            } label: {
                                VStack(spacing: 8) {
                                    Image(systemName: loc.symbolName)
                                        .font(.title3)
                                        .foregroundStyle(isSelected ? .black : .white)
                                    Text(loc.displayName)
                                        .font(.caption.weight(.medium))
                                        .foregroundStyle(isSelected ? .black : .white)
                                        .multilineTextAlignment(.center)
                                        .lineLimit(2)
                                        .minimumScaleFactor(0.8)
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 90)
                                .background(
                                    isSelected ? AnyShapeStyle(STRQBrand.accentGradient) : AnyShapeStyle(Color.white.opacity(0.04)),
                                    in: .rect(cornerRadius: 14)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .strokeBorder(isSelected ? .clear : Color.white.opacity(0.06), lineWidth: 1)
                                )
                            }
                        }
                    }
                }

                if vm.profile.trainingLocation != .gym {
                    fieldGroup("Available Equipment") {
                        let homeEquipment: [Equipment] = [.dumbbell, .kettlebell, .resistanceBand, .pullUpBar, .bench, .stabilityBall, .foamRoller, .mat, .trx, .rings, .abWheel]
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 100), spacing: 8)], spacing: 8) {
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

                fieldGroup("Injuries or Restrictions") {
                    Text("Select any areas of concern so exercises can be filtered for safety.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.bottom, 4)

                    let commonInjuries = ["Shoulder", "Knee", "Lower Back", "Wrist", "Neck", "Hip", "Ankle", "Elbow"]
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 80), spacing: 8)], spacing: 8) {
                        ForEach(commonInjuries, id: \.self) { injury in
                            selectionChip(injury, selected: vm.profile.injuries.contains(injury)) {
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

    private var muscleFocusStep: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                stepHero(
                    title: "Muscle Focus",
                    subtitle: "Prioritize or de-emphasize muscles. The coach adjusts volume and selection."
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

    private var lifestyleStep: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                stepHero(
                    title: "Lifestyle & Recovery",
                    subtitle: "Sleep, stress, and recovery capacity shape your training intensity."
                )

                fieldGroup("Sleep Quality") {
                    VStack(spacing: 8) {
                        ForEach(SleepQuality.allCases) { sleep in
                            selectionChip(sleep.displayName, selected: vm.profile.sleepQuality == sleep) {
                                vm.profile.sleepQuality = sleep
                            }
                        }
                    }
                }

                fieldGroup("Stress Level") {
                    HStack(spacing: 8) {
                        ForEach(StressLevel.allCases) { stress in
                            selectionChip(stress.displayName, selected: vm.profile.stressLevel == stress) {
                                vm.profile.stressLevel = stress
                            }
                        }
                    }
                }

                fieldGroup("Daily Activity") {
                    VStack(spacing: 8) {
                        ForEach(ActivityLevel.allCases) { level in
                            selectionChip(level.displayName, selected: vm.profile.activityLevel == level) {
                                vm.profile.activityLevel = level
                            }
                        }
                    }
                }

                fieldGroup("Recovery Capacity") {
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

    @ViewBuilder
    private func stepHero(title: String, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.title.bold())
            Text(subtitle)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.bottom, 4)
    }

    @ViewBuilder
    private func fieldGroup(_ label: String, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(label)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.white.opacity(0.7))
            content()
        }
    }

    @ViewBuilder
    private func selectionChip(_ title: String, selected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(selected ? .black : .white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    selected ? AnyShapeStyle(STRQBrand.accentGradient) : AnyShapeStyle(Color.white.opacity(0.04)),
                    in: .rect(cornerRadius: 12)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(selected ? .clear : Color.white.opacity(0.06), lineWidth: 1)
                )
        }
    }
}
