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
    @State private var showReadinessDetails: Bool = false
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
                Text(showResult ? "Ready" : L10n.tr("Daily check-in"))
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.primary)
                Text(showResult ? "Today's plan" : contextLabel)
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
        hasWorkoutToday ? L10n.tr("Before training") : L10n.tr("Rest day check")
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
                title: L10n.tr("How's your body?"),
                subtitle: L10n.tr("Sleep recovery and current energy are the biggest signals for today.")
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
                title: L10n.tr("What's taxing you?"),
                subtitle: L10n.tr("Soreness and stress affect what's worth pushing today.")
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
                title: hasWorkoutToday ? L10n.tr("One more check") : L10n.tr("Mindset check"),
                subtitle: hasWorkoutToday
                    ? L10n.tr("Motivation shapes intent. Pain reshapes the whole workout.")
                    : L10n.tr("A quick note so STRQ can tune recovery and next workout.")
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
                title: L10n.tr("All clear"),
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
                title: L10n.tr("Something's off"),
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
        let adjustments = readinessAdjustments(for: response, readiness: readiness)

        return VStack(spacing: 20) {
            VStack(alignment: .leading, spacing: 14) {
                HStack(alignment: .center, spacing: 14) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(statusColor.opacity(0.14))
                        Image(systemName: readinessStateIcon(for: readiness.readinessScore))
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundStyle(statusColor)
                    }
                    .frame(width: 64, height: 64)
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .strokeBorder(statusColor.opacity(0.24), lineWidth: 1)
                    )

                    VStack(alignment: .leading, spacing: 4) {
                        Text("TODAY'S STATE")
                            .font(.system(size: 10, weight: .black))
                            .tracking(1.1)
                            .foregroundStyle(statusColor)
                        Text(readinessStateLabel(for: readiness.readinessScore))
                            .font(.system(size: 38, weight: .heavy, design: .rounded))
                            .foregroundStyle(.primary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.78)
                        Text("Treat this as context, not a verdict")
                            .font(.footnote.weight(.medium))
                            .foregroundStyle(.secondary)
                    }

                    Spacer(minLength: 0)
                }
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
                        Text(readinessAdviceLabel(response.trainingAdvice).uppercased())
                            .font(.system(size: 9, weight: .bold))
                            .tracking(0.6)
                            .foregroundStyle(adviceColor)
                        Text(readinessHeadline(for: response, readiness: readiness))
                            .font(.system(.headline, design: .rounded, weight: .bold))
                    }
                    Spacer(minLength: 0)
                }

                Text(readinessMessage(for: response, readiness: readiness))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)

                if !adjustments.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(adjustments, id: \.self) { adj in
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

            if readiness.painOrRestriction {
                painWarningCard(readiness)
            }

            signalBreakdown(readiness: readiness)

            // Done
            Button {
                onComplete(readiness)
                dismiss()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: hasWorkoutToday ? "figure.strengthtraining.traditional" : "checkmark")
                        .font(.subheadline.weight(.semibold))
                    Text(hasWorkoutToday ? "See today's plan" : "Done")
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
            Button {
                withAnimation(.snappy(duration: 0.22)) {
                    showReadinessDetails.toggle()
                }
            } label: {
                HStack {
                    Text("Details")
                        .font(.caption.weight(.semibold))
                    Spacer()
                    Text("Sleep, energy, stress, soreness")
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                    Image(systemName: showReadinessDetails ? "chevron.up" : "chevron.down")
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 10)
            }
            .buttonStyle(.plain)

            if showReadinessDetails {
                Divider().overlay(Color.white.opacity(0.05))
                signalRow(label: "Sleep", value: readinessLevelLabel(readiness.sleepQuality), color: readinessColor(readiness.sleepQuality))
                Divider().overlay(Color.white.opacity(0.05))
                signalRow(label: "Energy", value: readinessLevelLabel(readiness.energyLevel), color: readinessColor(readiness.energyLevel))
                Divider().overlay(Color.white.opacity(0.05))
                signalRow(label: "Stress", value: readinessLevelLabel(readiness.stressLevel), color: readinessColor(readiness.stressLevel, inverted: true))
                Divider().overlay(Color.white.opacity(0.05))
                signalRow(label: "Soreness", value: sorenessLevelLabel(readiness.soreness), color: sorenessColor(readiness.soreness))
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 4)
        .background(Color(.secondarySystemGroupedBackground), in: .rect(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(STRQBrand.cardBorder, lineWidth: 1))
    }

    private func painWarningCard(_ readiness: DailyReadiness) -> some View {
        HStack(spacing: 10) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.caption.weight(.bold))
                .foregroundStyle(STRQPalette.danger)
            Text(readiness.painNote.isEmpty ? "Pain reported" : readiness.painNote)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.primary)
                .lineLimit(2)
            Spacer(minLength: 0)
        }
        .padding(12)
        .background(STRQPalette.danger.opacity(0.10), in: .rect(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(STRQPalette.danger.opacity(0.18), lineWidth: 1))
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

    private func readinessStateLabel(for score: Int) -> String {
        switch score {
        case 85...: return "Ready"
        case 70..<85: return "Steady"
        case 55..<70: return "Light"
        case 40..<55: return "Low"
        default: return "Rest"
        }
    }

    private func readinessStateIcon(for score: Int) -> String {
        switch score {
        case 85...: return "bolt.fill"
        case 70..<85: return "checkmark.circle.fill"
        case 55..<70: return "arrow.down.circle.fill"
        case 40..<55: return "heart.circle.fill"
        default: return "bed.double.fill"
        }
    }

    private func readinessAdviceLabel(_ advice: TrainingAdvice) -> String {
        switch advice {
        case .trainAsPlanned, .pushHard:
            return "Keep the plan"
        case .trainButLighter, .shortenSession, .reduceAccessories, .useSaferVariations:
            return "Keep it controlled"
        case .restDay:
            return "Back off today"
        }
    }

    private func readinessHeadline(for response: ReadinessCoachResponse, readiness: DailyReadiness) -> String {
        if readiness.painOrRestriction {
            return "Keep it controlled"
        }

        switch response.trainingAdvice {
        case .restDay:
            return "Back off today"
        case .trainButLighter, .shortenSession, .reduceAccessories, .useSaferVariations:
            return "Keep it controlled"
        case .trainAsPlanned, .pushHard:
            return "Keep the plan"
        }
    }

    private func readinessMessage(for response: ReadinessCoachResponse, readiness: DailyReadiness) -> String {
        if readiness.painOrRestriction {
            return hasWorkoutToday
                ? "Restriction noted. Keep the work controlled, reduce load, and end sets when form breaks."
                : "Restriction noted. Back off today and check in again before the next workout."
        }

        return response.message
    }

    private func readinessAdjustments(for response: ReadinessCoachResponse, readiness: DailyReadiness) -> [String] {
        guard readiness.painOrRestriction else { return response.adjustments }

        if hasWorkoutToday {
            return [
                "Keep load conservative",
                "Choose clean, controlled movements",
                "End the set when form breaks"
            ]
        }

        return [
            "Light movement only",
            "Eat, hydrate, sleep",
            "Check in again tomorrow"
        ]
    }

    private func shortLabel(_ level: ReadinessLevel) -> String {
        switch level {
        case .terrible: "Bad"
        case .poor: "Low"
        case .okay: "Ok"
        case .good: "Good"
        case .great: "Peak"
        }
    }

    private func readinessLevelLabel(_ level: ReadinessLevel) -> String {
        switch level {
        case .terrible: "Terrible"
        case .poor: "Poor"
        case .okay: "Okay"
        case .good: "Good"
        case .great: "Great"
        }
    }

    private func sorenessLevelLabel(_ level: SorenessLevel) -> String {
        switch level {
        case .none: "None"
        case .mild: "Mild"
        case .moderate: "Moderate"
        case .significant: "Significant"
        case .severe: "Severe"
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
