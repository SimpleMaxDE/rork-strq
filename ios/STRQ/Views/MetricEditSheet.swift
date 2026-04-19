import SwiftUI

enum MetricEdit: String, Identifiable {
    case height
    case age
    case weight
    case targetWeight
    case bodyFat

    var id: String { rawValue }

    var title: String {
        switch self {
        case .height: "Height"
        case .age: "Age"
        case .weight: "Weight"
        case .targetWeight: "Target Weight"
        case .bodyFat: "Body Fat"
        }
    }

    var unit: String {
        switch self {
        case .height: "cm"
        case .age: "years"
        case .weight, .targetWeight: "kg"
        case .bodyFat: "%"
        }
    }

    var range: ClosedRange<Double> {
        switch self {
        case .height: 140...220
        case .age: 14...80
        case .weight, .targetWeight: 40...200
        case .bodyFat: 5...50
        }
    }

    var allowsDecimal: Bool {
        switch self {
        case .weight, .targetWeight: true
        default: false
        }
    }
}

struct MetricEditSheet: View {
    let metric: MetricEdit
    @Binding var profile: UserProfile
    @Environment(\.dismiss) private var dismiss
    @FocusState private var focused: Bool
    @State private var text: String = ""

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button("Cancel") { dismiss() }
                    .foregroundStyle(.white.opacity(0.6))
                Spacer()
                Text(metric.title)
                    .font(.headline)
                Spacer()
                Button("Save") { save() }
                    .fontWeight(.semibold)
                    .foregroundStyle(isValid ? .white : .white.opacity(0.3))
                    .disabled(!isValid)
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)

            Spacer(minLength: 16)

            HStack(alignment: .firstTextBaseline, spacing: 10) {
                TextField("0", text: $text)
                    .focused($focused)
                    .keyboardType(metric.allowsDecimal ? .decimalPad : .numberPad)
                    .font(.system(size: 64, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .monospacedDigit()
                    .multilineTextAlignment(.trailing)
                    .frame(maxWidth: 200)
                    .onSubmit { save() }
                Text(metric.unit)
                    .font(.title2.weight(.medium))
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)

            Text("Range \(rangeText)")
                .font(.caption)
                .foregroundStyle(.white.opacity(0.4))
                .padding(.top, 12)

            Spacer(minLength: 16)
        }
        .onAppear {
            text = initialText
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                focused = true
            }
        }
    }

    private var initialText: String {
        switch metric {
        case .height: return "\(Int(profile.heightCm))"
        case .age: return "\(profile.age)"
        case .weight: return String(format: "%.1f", profile.weightKg)
        case .targetWeight:
            if let t = profile.targetWeightKg { return String(format: "%.1f", t) }
            return String(format: "%.1f", profile.weightKg)
        case .bodyFat:
            if let b = profile.bodyFatPercentage { return "\(Int(b))" }
            return "20"
        }
    }

    private var rangeText: String {
        let r = metric.range
        if metric.allowsDecimal {
            return "\(Int(r.lowerBound))–\(Int(r.upperBound)) \(metric.unit)"
        }
        return "\(Int(r.lowerBound))–\(Int(r.upperBound)) \(metric.unit)"
    }

    private var parsedValue: Double? {
        let normalized = text.replacingOccurrences(of: ",", with: ".")
        guard let v = Double(normalized) else { return nil }
        return v
    }

    private var isValid: Bool {
        guard let v = parsedValue else { return false }
        return metric.range.contains(v)
    }

    private func save() {
        guard let v = parsedValue else { return }
        let clamped = min(max(v, metric.range.lowerBound), metric.range.upperBound)
        switch metric {
        case .height: profile.heightCm = clamped.rounded()
        case .age: profile.age = Int(clamped.rounded())
        case .weight: profile.weightKg = (clamped * 10).rounded() / 10
        case .targetWeight: profile.targetWeightKg = (clamped * 10).rounded() / 10
        case .bodyFat: profile.bodyFatPercentage = clamped.rounded()
        }
        dismiss()
    }
}
