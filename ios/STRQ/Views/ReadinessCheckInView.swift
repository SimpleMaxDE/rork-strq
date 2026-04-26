import SwiftUI

struct ReadinessCheckInView: View {
    let vm: AppViewModel
    let onComplete: (DailyReadiness) -> Void

    @State private var currentStep: Int = 0
    @State private var sleepQuality: ReadinessLevel = .good
    @State private var energyLevel: ReadinessLevel = .good
    @State private var stressLevel: ReadinessLevel = .okay
    @State private var soreness: SorenessLevel = .mild
    @State private var motivation: DailyMotivation = .high
    @State private var painOrRestriction: Bool = false
    @State private var painNote: String = ""
    @State private var showResult: Bool = false
    @State private var coachResponse: ReadinessCoachResponse?
    @State private var appeared: Bool = false
    @FocusState private var painFieldFocused: Bool
    @Environment(\.dismiss) private var dismiss

    private let totalSteps = 3

    private var hasWorkoutToday: Bool { vm.todaysWorkout != nil }

    var body: some View {
        VStack(spacing: 0) {
            header
            progressBar
            ScrollView {
                VStack(spacing: 28) {
                    if showResult, let response = coachResponse {
                        resultView(response)
                    } else {
                        stepContent
                            .transition(.asymmetric(
                                insertion: .offset(x: 14).combined(with: .opacity),
                                removal: .offset(x: -14).combined(with: .opacity)
                            ))
                            .id(currentStep)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 40)
            }
            if !showResult {
                bottomBar
            }
        }
        .background(Color(.systemBackground))
        .onAppear {
            withAnimation(.easeOut(duration: 0.4)) { appeared = true }
        }
    }

    // MARK: Header + Progress

    private var header: some View {
        HStack {
            Button {
                if showResult || currentStep == 0 {
                    dismiss()
                } else {
                    withAnimation(.snappy(duration: 0.25)) { currentStep -= 1 }
                }
            } label: {
                Image(systemName: showResult || currentStep == 0 ? "xmark" : "chevron.left")
                    .font(.body.weight(.semibold))
                    .foregroundStyle(.primary)
                    .frame(width: 36, height: 36)
                    .background(Color(.tertiarySystemGroupedBackground), in: Circle())
            }
            Spacer()
            VStack(spacing: 2) {
                Text(showResult ? L10n.tr("Ready") : L10n.tr("Daily check-in"))
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.primary)
                Text(showResult ? L10n.tr("Today's plan") : contextLabel)
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(.secondary)
                    .tracking(0.3)
                    .textCase(.uppercase)
            }
            Spacer()
            Color.clear.frame(width: 36, height: 36)
        }
        .padding(.horizontal, 16)
        .padding(.top, 12)
    }

    private var contextLabel: String {
        hasWorkoutToday ? "Before training" : "Rest day check"
    }

    private var progressBar: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.white.opacity(0.06))
                    .frame(height: 3)
                Capsule()
                    .fill(STRQBrand.accentGradient)
                    .frame(
                        width: showResult
                            ? geo.size.width
                            : geo.size.width * CGFloat(currentStep + 1) / CGFloat(totalSteps),
                        height: 3
                    )
                    .animation(.snappy(duration: 0.3), value: currentStep)
                    .animation(.snappy(duration: 0.3), value: showResult)
            }
        }
        .frame(height: 3)
        .padding(.horizontal, 16)
        .padding(.top, 12)
    }

    // MARK: Step content (3 compact blocks)

    @ViewBuilder
    private var stepContent: some View {
        switch currentStep {
        case 0: sleepEnergyStep
        case 1: loadStep
        case 2: mindsetStep
        default: EmptyView()
        }
    }

    // Step 1 — Sleep + Energy
    private var sleepEnergyStep: some View {
        VStack(spacing: 24) {
            stepHeader(
                title: "How's your body?",
                subtitle: "Sleep recovery and current energy are the biggest signals for today."
            )

            VStack(alignment: .leading, spacing: 10) {
                fieldLabel(L10n.tr("Sleep quality"))
                readinessSegment(selection: $sleepQuality)
            }

            VStack(alignment: .leading, spacing: 10) {
                fieldLabel(L10n.tr("Energy right now"))
                readinessSegment(selection: $energyLevel)
            }
        }
    }

    // Step 2 — Load (soreness + stress)
    private var loadStep: some View {
        VStack(spacing: 24) {
            stepHeader(
                title: "What's taxing you?",
                subtitle: "Soreness and stress affect what's worth pushing today."
            )

            VStack(alignment: .leading, spacing: 10) {
                fieldLabel(L10n.tr("Muscle soreness"))
                sorenessSegment
            }

            VStack(alignment: .leading, spacing: 10) {
                fieldLabel(L10n.tr("Life stress"))
                readinessSegment(selection: $stressLevel, invertSemantic: true)
            }
        }
    }

    // Step 3 — Mindset + pain gate
    private var mindsetStep: some View {
        VStack(spacing: 24) {
            stepHeader(
                title: hasWorkoutToday ? "One more check" : "Mindset check",
                subtitle: hasWorkoutToday
                    ? "Motivation shapes intent. Pain reshapes the whole session."
                    : "A quick note so STRQ can tune recovery and next session."
            )

            VStack(alignment: .leading, spacing: 10) {
                fieldLabel(L10n.tr("Motivation"))
                motivationSegment
            }

            VStack(alignment: .leading, spacing: 10) {
                fieldLabel(L10n.tr("Pain or restriction"))
                painToggle
                if painOrRestriction {
                    TextField(L10n.tr("e.g. Left shoulder, lower back"), text: $painNote)
                        .textFieldStyle(.plain)
                        .focused($painFieldFocused)
                        .submitLabel(.done)
                        .onSubmit { painFieldFocused = false }
                        .padding(14)
                        .background(Color(.secondarySystemGroupedBackground), in: .rect(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .strokeBorder(STRQPalette.danger.opacity(0.3), lineWidth: 1)
                        )
                        .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
        }
    }

    private func stepHeader(title: String, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(.title2, design: .rounded, weight: .bold))
            Text(subtitle)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 8)
    }

    private func fieldLabel(_ text: String) -> some View {
        Text(text.uppercased())
            .font(.system(size: 10, weight: .bold))
            .foregroundStyle(.secondary)
            .tracking(0.6)
    }

    // MARK: Semantic segment pickers

    private func readinessSegment(selection: Binding<ReadinessLevel>, invertSemantic: Bool = false) -> some View {
        HStack(spacing: 6) {
            ForEach(ReadinessLevel.allCases) { level in
                let isSelected = selection.wrappedValue == level
                let color = readinessColor(level, inverted: invertSemantic)
                Button {
                    withAnimation(.snappy(duration: 0.2)) { selection.wrappedValue = level }
                } label: {
                    VStack(spacing: 5) {
                        Text("\(level.rawValue)")
                            .font(.system(.headline, design: .rounded, weight: .heavy).monospacedDigit())
                            .foregroundStyle(isSelected ? .white : .primary)
                        Text(shortLabel(level))
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundStyle(isSelected ? .white.opacity(0.9) : .secondary)
                            .lineLimit(1)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        isSelected
                            ? AnyShapeStyle(LinearGradient(colors: [color, color.opacity(0.85)], startPoint: .top, endPoint: .bottom))
                            : AnyShapeStyle(Color(.secondarySystemGroupedBackground)),
                        in: .rect(cornerRadius: 12)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(
                                isSelected ? Color.white.opacity(0.25) : Color.white.opacity(0.05),
                                lineWidth: 1
                            )
                    )
                    .shadow(color: isSelected ? color.opacity(0.35) : .clear, radius: 12, y: 4)
                }
                .sensoryFeedback(.selection, trigger: isSelected)
            }
        }
    }

    private var sorenessSegment: some View {
        HStack(spacing: 6) {
            ForEach(SorenessLevel.allCases) { level in
                let isSelected = soreness == level
                let color = sorenessColor(level)
                Button {
                    withAnimation(.snappy(duration: 0.2)) { soreness = level }
                } label: {
                    VStack(spacing: 4) {
                        Text(level.label)
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(isSelected ? .white : .primary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        isSelected
                            ? AnyShapeStyle(LinearGradient(colors: [color, color.opacity(0.85)], startPoint: .top, endPoint: .bottom))
                            : AnyShapeStyle(Color(.secondarySystemGroupedBackground)),
                        in: .rect(cornerRadius: 12)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(
                                isSelected ? Color.white.opacity(0.25) : Color.white.opacity(0.05),
                                lineWidth: 1
                            )
                    )
                    .shadow(color: isSelected ? color.opacity(0.3) : .clear, radius: 10, y: 3)
                }
                .sensoryFeedback(.selection, trigger: isSelected)
            }
        }
    }

    private var motivationSegment: some View {
        HStack(spacing: 6) {
            ForEach(DailyMotivation.allCases) { level in
                let isSelected = motivation == level
                Button {
                    withAnimation(.snappy(duration: 0.2)) { motivation = level }
                } label: {
                    VStack(spacing: 4) {
                        Text("\(level.rawValue)")
                            .font(.system(.headline, design: .rounded, weight: .heavy).monospacedDigit())
                        Text(level.label)
                            .font(.system(size: 10, weight: .semibold))
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                    }
                    .foregroundStyle(isSelected ? .black : .primary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        isSelected
                            ? AnyShapeStyle(STRQBrand.accentGradient)
                            : AnyShapeStyle(Color(.secondarySystemGroupedBackground)),
                        in: .rect(cornerRadius: 12)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(
                                isSelected ? Color.clear : Color.white.opacity(0.05),
                                lineWidth: 1
                            )
                    )
                }
                .sensoryFeedback(.selection, trigger: isSelected)
            }
        }
    }

    private var painToggle: some View {
        HStack(spacing: 8) {
            painChoiceButton(
                title: "All clear",
                icon: "checkmark.circle.fill",
                selected: !painOrRestriction,
                color: STRQPalette.success
            ) {
                withAnimation(.snappy(duration: 0.2)) {
                    painOrRestriction = false
                    painFieldFocused = false
                }
            }
            painChoiceButton(
                title: "Something's off",
                icon: "exclamationmark.triangle.fill",
                selected: painOrRestriction,
                color: STRQPalette.danger
            ) {
                withAnimation(.snappy(duration: 0.2)) {
                    painOrRestriction = true
                }
            }
        }
    }

    private func painChoiceButton(title: String, icon: String, selected: Bool, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.subheadline.weight(.semibold))
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .foregroundStyle(selected ? .white : .primary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                selected
                    ? AnyShapeStyle(LinearGradient(colors: [color, color.opacity(0.85)], startPoint: .top, endPoint: .bottom))
                    : AnyShapeStyle(Color(.secondarySystemGroupedBackground)),
                in: .rect(cornerRadius: 12)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(selected ? Color.white.opacity(0.2) : Color.white.opacity(0.05), lineWidth: 1)
            )
            .shadow(color: selected ? color.opacity(0.3) : .clear, radius: 10, y: 3)
        }
        .sensoryFeedback(.selection, trigger: selected)
    }

    // MARK: Result

    private func resultView(_ response: ReadinessCoachResponse) -> some View {
        let readiness = buildReadiness()
        let statusColor = ForgeTheme.color(for: readiness.readinessColorName)
        let adviceColor = ForgeTheme.color(for: response.colorName)

        return VStack(spacing: 20) {
            // Readiness dial
            VStack(spacing: 14) {
                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.06), lineWidth: 8)
                        .frame(width: 128, height: 128)
                    Circle()
                        .trim(from: 0, to: CGFloat(readiness.readinessScore) / 100)
                        .stroke(
                            LinearGradient(colors: [statusColor, statusColor.opacity(0.7)], startPoint: .top, endPoint: .bottom),
                            style: StrokeStyle(lineWidth: 8, lineCap: .round)
                        )
                        .frame(width: 128, height: 128)
                        .rotationEffect(.degrees(-90))
                    VStack(spacing: 2) {
                        Text("\(readiness.readinessScore)")
                            .font(.system(size: 44, weight: .heavy, design: .rounded).monospacedDigit())
                        Text(L10n.tr("READINESS"))
                            .font(.system(size: 9, weight: .bold))
                            .tracking(0.8)
                            .foregroundStyle(.secondary)
                    }
                }

                Text(readiness.readinessLabel)
                    .font(.system(.subheadline, design: .rounded, weight: .bold))
                    .foregroundStyle(statusColor)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 6)
                    .background(statusColor.opacity(0.12), in: Capsule())
                    .overlay(Capsule().strokeBorder(statusColor.opacity(0.3), lineWidth: 0.5))
            }
            .padding(.top, 4)

            // Primary advice card
            VStack(alignment: .leading, spacing: 14) {
                HStack(spacing: 12) {
                    Image(systemName: response.icon)
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(.white)
                        .frame(width: 46, height: 46)
                        .background(
                            LinearGradient(colors: [adviceColor, adviceColor.opacity(0.7)], startPoint: .topLeading, endPoint: .bottomTrailing),
                            in: .rect(cornerRadius: 12)
                        )

                    VStack(alignment: .leading, spacing: 3) {
                        Text(response.trainingAdvice.label.uppercased())
                            .font(.system(size: 9, weight: .bold))
                            .tracking(0.6)
                            .foregroundStyle(adviceColor)
                        Text(response.headline)
                            .font(.system(.headline, design: .rounded, weight: .bold))
                    }
                    Spacer(minLength: 0)
                }

                Text(response.message)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)

                if !response.adjustments.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(response.adjustments, id: \.self) { adj in
                            HStack(alignment: .top, spacing: 10) {
                                Image(systemName: "arrow.turn.down.right")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundStyle(adviceColor)
                                    .frame(width: 16, alignment: .leading)
                                Text(adj)
                                    .font(.caption)
                                    .foregroundStyle(.primary.opacity(0.85))
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                    }
                    .padding(.top, 2)
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.secondarySystemGroupedBackground), in: .rect(cornerRadius: 18))
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .strokeBorder(STRQBrand.cardBorder, lineWidth: 1)
            )

            // Signal breakdown
            signalBreakdown(readiness: readiness)

            // Done
            Button {
                onComplete(readiness)
                dismiss()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: hasWorkoutToday ? "figure.strengthtraining.traditional" : "checkmark")
                        .font(.subheadline.weight(.semibold))
                    Text(hasWorkoutToday ? L10n.tr("Go to today's session") : L10n.tr("Done"))
                        .font(.body.weight(.bold))
                }
                .foregroundStyle(.black)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(STRQBrand.accentGradient, in: .rect(cornerRadius: 14))
            }
            .sensoryFeedback(.success, trigger: showResult)
        }
    }

    private func signalBreakdown(readiness: DailyReadiness) -> some View {
        VStack(spacing: 0) {
            signalRow(label: "Sleep", value: readiness.sleepQuality.label, color: readinessColor(readiness.sleepQuality))
            Divider().overlay(Color.white.opacity(0.05))
            signalRow(label: "Energy", value: readiness.energyLevel.label, color: readinessColor(readiness.energyLevel))
            Divider().overlay(Color.white.opacity(0.05))
            signalRow(label: "Stress", value: readiness.stressLevel.label, color: readinessColor(readiness.stressLevel, inverted: true))
            Divider().overlay(Color.white.opacity(0.05))
            signalRow(label: "Soreness", value: readiness.soreness.label, color: sorenessColor(readiness.soreness))
            if readiness.painOrRestriction {
                Divider().overlay(Color.white.opacity(0.05))
                signalRow(label: "Flag", value: readiness.painNote.isEmpty ? "Pain reported" : readiness.painNote, color: STRQPalette.danger)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 4)
        .background(Color(.secondarySystemGroupedBackground), in: .rect(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(STRQBrand.cardBorder, lineWidth: 1))
    }

    private func signalRow(label: String, value: String, color: Color) -> some View {
        HStack(spacing: 10) {
            Circle().fill(color).frame(width: 7, height: 7)
            Text(label)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.primary)
                .lineLimit(1)
        }
        .padding(.vertical, 11)
    }

    // MARK: Bottom bar

    private var bottomBar: some View {
        VStack(spacing: 0) {
            Divider().overlay(Color.white.opacity(0.05))
            HStack(spacing: 12) {
                if currentStep > 0 {
                    Button {
                        withAnimation(.snappy(duration: 0.25)) { currentStep -= 1 }
                    } label: {
                        Text(L10n.tr("Back"))
                            .font(.body.weight(.semibold))
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 18)
                            .frame(height: 48)
                            .frame(minWidth: 88)
                            .background(Color(.tertiarySystemGroupedBackground), in: Capsule())
                    }
                }
                Button {
                    if currentStep < totalSteps - 1 {
                        painFieldFocused = false
                        withAnimation(.snappy(duration: 0.25)) { currentStep += 1 }
                    } else {
                        painFieldFocused = false
                        submitCheckIn()
                    }
                } label: {
                    HStack(spacing: 8) {
                        Text(currentStep == totalSteps - 1 ? L10n.tr("See today's plan") : L10n.tr("Continue"))
                            .font(.body.weight(.bold))
                        Image(systemName: currentStep == totalSteps - 1 ? "sparkles" : "arrow.right")
                            .font(.subheadline.weight(.bold))
                    }
                    .foregroundStyle(.black)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(STRQBrand.accentGradient, in: Capsule())
                }
                .sensoryFeedback(.impact(flexibility: .soft), trigger: currentStep)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .background(.ultraThinMaterial)
    }

    // MARK: Helpers

    private func shortLabel(_ level: ReadinessLevel) -> String {
        switch level {
        case .terrible: "Bad"
        case .poor: "Low"
        case .okay: "Ok"
        case .good: "Good"
        case .great: "Peak"
        }
    }

    private func readinessColor(_ level: ReadinessLevel, inverted: Bool = false) -> Color {
        let effective: ReadinessLevel
        if inverted {
            // For stress: higher = worse. Flip mapping.
            effective = ReadinessLevel(rawValue: 6 - level.rawValue) ?? level
        } else {
            effective = level
        }
        switch effective {
        case .terrible: return STRQPalette.danger
        case .poor: return Color(red: 0.95, green: 0.55, blue: 0.32)
        case .okay: return STRQPalette.warning
        case .good: return STRQPalette.success
        case .great: return Color(red: 0.30, green: 0.85, blue: 0.62)
        }
    }

    private func sorenessColor(_ level: SorenessLevel) -> Color {
        switch level {
        case .none: return STRQPalette.success
        case .mild: return Color(red: 0.55, green: 0.82, blue: 0.48)
        case .moderate: return STRQPalette.warning
        case .significant: return Color(red: 0.95, green: 0.55, blue: 0.32)
        case .severe: return STRQPalette.danger
        }
    }

    private func buildReadiness() -> DailyReadiness {
        DailyReadiness(
            sleepQuality: sleepQuality,
            energyLevel: energyLevel,
            stressLevel: stressLevel,
            soreness: soreness,
            motivation: motivation,
            painOrRestriction: painOrRestriction,
            painNote: painNote
        )
    }

    private func submitCheckIn() {
        let readiness = buildReadiness()
        let engine = DailyCoachEngine()
        let response = engine.generateCoachResponse(
            readiness: readiness,
            recoveryScore: vm.recoveryScore,
            todaysWorkout: vm.todaysWorkout,
            recentSessions: vm.workoutHistory,
            phase: vm.currentPhase
        )
        withAnimation(.easeOut(duration: 0.4)) {
            coachResponse = response
            showResult = true
        }
    }
}
