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
    @Environment(\.dismiss) private var dismiss

    private let totalSteps = 5

    var body: some View {
        VStack(spacing: 0) {
            header
            progressBar
            ScrollView {
                VStack(spacing: 32) {
                    if showResult, let response = coachResponse {
                        resultView(response)
                    } else {
                        stepContent
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 24)
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
                    .font(.body.weight(.medium))
                    .foregroundStyle(.secondary)
                    .frame(width: 36, height: 36)
                    .background(Color(.tertiarySystemGroupedBackground), in: Circle())
            }
            Spacer()
            if !showResult {
                Text("Step \(currentStep + 1) of \(totalSteps)")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Color.clear.frame(width: 36, height: 36)
        }
        .padding(.horizontal, 16)
        .padding(.top, 12)
    }

    private var progressBar: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color(.tertiarySystemGroupedBackground))
                    .frame(height: 3)
                Capsule()
                    .fill(STRQBrand.accentGradient)
                    .frame(width: showResult ? geo.size.width : geo.size.width * CGFloat(currentStep + 1) / CGFloat(totalSteps), height: 3)
                    .animation(.snappy(duration: 0.3), value: currentStep)
                    .animation(.snappy(duration: 0.3), value: showResult)
            }
        }
        .frame(height: 3)
        .padding(.horizontal, 16)
        .padding(.top, 12)
    }

    @ViewBuilder
    private var stepContent: some View {
        switch currentStep {
        case 0:
            readinessStep(
                title: "How did you sleep?",
                subtitle: "Sleep quality strongly affects recovery and performance",
                selection: $sleepQuality,
                options: ReadinessLevel.allCases
            )
        case 1:
            readinessStep(
                title: "Energy level right now?",
                subtitle: "How your body feels at this moment",
                selection: $energyLevel,
                options: ReadinessLevel.allCases
            )
        case 2:
            readinessStep(
                title: "Current stress level?",
                subtitle: "Mental and life stress affects recovery capacity",
                selection: $stressLevel,
                options: ReadinessLevel.allCases
            )
        case 3:
            sorenessStep
        case 4:
            painStep
        default:
            EmptyView()
        }
    }

    private func readinessStep<T: Identifiable & Hashable>(
        title: String,
        subtitle: String,
        selection: Binding<T>,
        options: [T]
    ) -> some View where T: RawRepresentable<Int> {
        VStack(spacing: 24) {
            VStack(spacing: 8) {
                Text(title)
                    .font(.title2.bold())
                    .multilineTextAlignment(.center)
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 10)

            VStack(spacing: 8) {
                ForEach(options) { option in
                    let isSelected = selection.wrappedValue.rawValue == option.rawValue
                    Button {
                        withAnimation(.snappy(duration: 0.2)) {
                            selection.wrappedValue = option
                        }
                    } label: {
                        HStack(spacing: 14) {
                            if let level = option as? ReadinessLevel {
                                Text(level.emoji)
                                    .font(.title3)
                            }
                            Text(optionLabel(option))
                                .font(.body.weight(isSelected ? .semibold : .regular))
                                .foregroundStyle(isSelected ? .white : .primary)
                            Spacer()
                            if isSelected {
                                Image(systemName: "checkmark")
                                    .font(.subheadline.weight(.bold))
                                    .foregroundStyle(.white)
                            }
                        }
                        .padding(.horizontal, 18)
                        .padding(.vertical, 16)
                        .background(
                            isSelected ?
                            AnyShapeStyle(STRQBrand.accentGradient) :
                            AnyShapeStyle(Color(.secondarySystemGroupedBackground)),
                            in: .rect(cornerRadius: 14)
                        )
                    }
                    .sensoryFeedback(.selection, trigger: isSelected)
                }
            }
        }
    }

    private func optionLabel<T>(_ option: T) -> String {
        if let level = option as? ReadinessLevel { return level.label }
        if let level = option as? SorenessLevel { return level.label }
        if let level = option as? DailyMotivation { return level.label }
        return ""
    }

    private var sorenessStep: some View {
        VStack(spacing: 24) {
            VStack(spacing: 8) {
                Text("Muscle soreness?")
                    .font(.title2.bold())
                Text("General body soreness from recent training")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            VStack(spacing: 8) {
                ForEach(SorenessLevel.allCases) { level in
                    let isSelected = soreness == level
                    Button {
                        withAnimation(.snappy(duration: 0.2)) { soreness = level }
                    } label: {
                        HStack(spacing: 14) {
                            Text(level.label)
                                .font(.body.weight(isSelected ? .semibold : .regular))
                                .foregroundStyle(isSelected ? .white : .primary)
                            Spacer()
                            if isSelected {
                                Image(systemName: "checkmark")
                                    .font(.subheadline.weight(.bold))
                                    .foregroundStyle(.white)
                            }
                        }
                        .padding(.horizontal, 18)
                        .padding(.vertical, 16)
                        .background(
                            isSelected ?
                            AnyShapeStyle(STRQBrand.accentGradient) :
                            AnyShapeStyle(Color(.secondarySystemGroupedBackground)),
                            in: .rect(cornerRadius: 14)
                        )
                    }
                    .sensoryFeedback(.selection, trigger: isSelected)
                }
            }

            VStack(spacing: 12) {
                Text("How motivated are you today?")
                    .font(.subheadline.weight(.semibold))

                HStack(spacing: 8) {
                    ForEach(DailyMotivation.allCases) { level in
                        let isSelected = motivation == level
                        Button {
                            withAnimation(.snappy(duration: 0.2)) { motivation = level }
                        } label: {
                            VStack(spacing: 4) {
                                Text("\(level.rawValue)")
                                    .font(.headline.monospacedDigit())
                                Text(level.label)
                                    .font(.system(size: 9, weight: .medium))
                                    .lineLimit(1)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .foregroundStyle(isSelected ? .white : .primary)
                            .background(
                                isSelected ?
                                AnyShapeStyle(STRQBrand.accentGradient) :
                                AnyShapeStyle(Color(.secondarySystemGroupedBackground)),
                                in: .rect(cornerRadius: 12)
                            )
                        }
                        .sensoryFeedback(.selection, trigger: isSelected)
                    }
                }
            }
            .padding(.top, 8)
        }
    }

    private var painStep: some View {
        VStack(spacing: 24) {
            VStack(spacing: 8) {
                Text("Any pain or restrictions?")
                    .font(.title2.bold())
                Text("Injuries, joint pain, or movement limitations today")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            VStack(spacing: 8) {
                Button {
                    withAnimation(.snappy(duration: 0.2)) { painOrRestriction = false }
                } label: {
                    HStack(spacing: 14) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.title3)
                            .foregroundStyle(!painOrRestriction ? .white : .green)
                        Text("No issues today")
                            .font(.body.weight(!painOrRestriction ? .semibold : .regular))
                            .foregroundStyle(!painOrRestriction ? .white : .primary)
                        Spacer()
                    }
                    .padding(.horizontal, 18)
                    .padding(.vertical, 16)
                    .background(
                        !painOrRestriction ?
                        AnyShapeStyle(Color.green.gradient) :
                        AnyShapeStyle(Color(.secondarySystemGroupedBackground)),
                        in: .rect(cornerRadius: 14)
                    )
                }

                Button {
                    withAnimation(.snappy(duration: 0.2)) { painOrRestriction = true }
                } label: {
                    HStack(spacing: 14) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.title3)
                            .foregroundStyle(painOrRestriction ? .white : STRQBrand.steel)
                        Text("Yes, something feels off")
                            .font(.body.weight(painOrRestriction ? .semibold : .regular))
                            .foregroundStyle(painOrRestriction ? .white : .primary)
                        Spacer()
                    }
                    .padding(.horizontal, 18)
                    .padding(.vertical, 16)
                    .background(
                        painOrRestriction ?
                        AnyShapeStyle(STRQBrand.accentGradient) :
                        AnyShapeStyle(Color(.secondarySystemGroupedBackground)),
                        in: .rect(cornerRadius: 14)
                    )
                }
            }

            if painOrRestriction {
                VStack(alignment: .leading, spacing: 8) {
                    Text("What's bothering you?")
                        .font(.subheadline.weight(.medium))
                    TextField("e.g. Left shoulder discomfort", text: $painNote)
                        .textFieldStyle(.plain)
                        .padding(14)
                        .background(Color(.secondarySystemGroupedBackground), in: .rect(cornerRadius: 12))
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }

    private func resultView(_ response: ReadinessCoachResponse) -> some View {
        let readiness = buildReadiness()
        return VStack(spacing: 24) {
            VStack(spacing: 12) {
                ZStack {
                    Circle()
                        .stroke(Color(.separator), lineWidth: 6)
                        .frame(width: 100, height: 100)
                    Circle()
                        .trim(from: 0, to: CGFloat(readiness.readinessScore) / 100)
                        .stroke(colorFor(readiness.readinessColorName).gradient, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                        .frame(width: 100, height: 100)
                        .rotationEffect(.degrees(-90))
                    VStack(spacing: 2) {
                        Text("\(readiness.readinessScore)")
                            .font(.title.bold().monospacedDigit())
                        Text("Readiness")
                            .font(.caption2.weight(.medium))
                            .foregroundStyle(.secondary)
                    }
                }

                Text(readiness.readinessLabel)
                    .font(.headline)
                    .foregroundStyle(colorFor(readiness.readinessColorName))
            }
            .padding(.top, 8)

            VStack(alignment: .leading, spacing: 14) {
                HStack(spacing: 10) {
                    Image(systemName: response.icon)
                        .font(.body.weight(.medium))
                        .foregroundStyle(.white)
                        .frame(width: 40, height: 40)
                        .background(colorFor(response.colorName).gradient, in: .rect(cornerRadius: 10))

                    VStack(alignment: .leading, spacing: 2) {
                        Text(response.headline)
                            .font(.subheadline.weight(.semibold))
                        Text(response.trainingAdvice.label)
                            .font(.caption)
                            .foregroundStyle(colorFor(response.colorName))
                    }
                }

                Text(response.message)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)

                if !response.adjustments.isEmpty {
                    VStack(alignment: .leading, spacing: 6) {
                        ForEach(response.adjustments, id: \.self) { adj in
                            HStack(spacing: 8) {
                                Image(systemName: "circle.fill")
                                    .font(.system(size: 4))
                                    .foregroundStyle(colorFor(response.colorName))
                                Text(adj)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }
            .padding(16)
            .background(Color(.secondarySystemGroupedBackground), in: .rect(cornerRadius: 16))

            Button {
                onComplete(readiness)
                dismiss()
            } label: {
                Text("Done")
                    .font(.body.weight(.semibold))
                    .foregroundStyle(.black)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(STRQBrand.accentGradient, in: .rect(cornerRadius: 14))
            }
            .sensoryFeedback(.impact(flexibility: .soft), trigger: true)
        }
    }

    private var bottomBar: some View {
        VStack(spacing: 0) {
            Divider()
            HStack {
                if currentStep > 0 {
                    Button {
                        withAnimation(.snappy(duration: 0.25)) { currentStep -= 1 }
                    } label: {
                        Text("Back")
                            .font(.body.weight(.medium))
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                    }
                }
                Spacer()
                Button {
                    if currentStep < totalSteps - 1 {
                        withAnimation(.snappy(duration: 0.25)) { currentStep += 1 }
                    } else {
                        submitCheckIn()
                    }
                } label: {
                    Text(currentStep == totalSteps - 1 ? "Get Results" : "Next")
                        .font(.body.weight(.semibold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 28)
                        .padding(.vertical, 12)
                        .background(STRQBrand.accentGradient, in: Capsule())
                }
                .sensoryFeedback(.impact(flexibility: .soft), trigger: currentStep)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .background(.ultraThinMaterial)
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

    private func colorFor(_ name: String) -> Color {
        switch name {
        case "orange": return STRQBrand.steel
        case "yellow": return .yellow
        case "green": return .green
        case "red": return .red
        case "blue": return STRQBrand.steel
        case "purple": return STRQBrand.slate
        case "cyan": return STRQBrand.steel
        case "mint": return STRQBrand.steel
        default: return STRQBrand.steel
        }
    }
}
