import Foundation

nonisolated enum MuscleGroup: String, Codable, CaseIterable, Identifiable, Sendable, Hashable {
    case chest
    case back
    case lats
    case shoulders
    case biceps
    case triceps
    case forearms
    case traps
    case neck
    case arms
    case abs
    case obliques
    case lowerBack
    case glutes
    case quads
    case hamstrings
    case calves
    case adductors
    case abductors
    case hipFlexors
    case tibialis
    case coreStability
    case rotationAntiRotation

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .chest: "Chest"
        case .back: "Back"
        case .lats: "Lats"
        case .shoulders: "Shoulders"
        case .biceps: "Biceps"
        case .triceps: "Triceps"
        case .forearms: "Forearms"
        case .traps: "Traps"
        case .neck: "Neck"
        case .arms: "Arms"
        case .abs: "Abs"
        case .obliques: "Obliques"
        case .lowerBack: "Lower Back"
        case .glutes: "Glutes"
        case .quads: "Quads"
        case .hamstrings: "Hamstrings"
        case .calves: "Calves"
        case .adductors: "Adductors"
        case .abductors: "Abductors"
        case .hipFlexors: "Hip Flexors"
        case .tibialis: "Tibialis"
        case .coreStability: "Core Stability"
        case .rotationAntiRotation: "Rotation"
        }
    }

    var region: MuscleRegion {
        switch self {
        case .chest, .back, .lats, .shoulders, .biceps, .triceps, .forearms, .traps, .neck, .arms:
            return .upper
        case .abs, .obliques, .lowerBack, .coreStability, .rotationAntiRotation:
            return .core
        case .glutes, .quads, .hamstrings, .calves, .adductors, .abductors, .hipFlexors, .tibialis:
            return .lower
        }
    }

    var symbolName: String {
        switch self {
        case .chest: "figure.strengthtraining.traditional"
        case .back, .lats: "figure.rowing"
        case .shoulders: "figure.boxing"
        case .biceps: "dumbbell.fill"
        case .triceps: "figure.strengthtraining.functional"
        case .forearms: "hand.raised.fill"
        case .traps: "figure.highintensity.intervaltraining"
        case .neck: "person.crop.circle"
        case .arms: "dumbbell.fill"
        case .abs: "figure.core.training"
        case .obliques: "figure.flexibility"
        case .lowerBack: "figure.pilates"
        case .glutes: "figure.step.training"
        case .quads: "figure.run"
        case .hamstrings: "figure.cooldown"
        case .calves: "figure.walk"
        case .adductors, .abductors: "figure.dance"
        case .hipFlexors: "figure.mind.and.body"
        case .tibialis: "figure.hiking"
        case .coreStability: "figure.core.training"
        case .rotationAntiRotation: "arrow.triangle.2.circlepath"
        }
    }
}

nonisolated enum MuscleRegion: String, Codable, CaseIterable, Identifiable, Sendable {
    case upper
    case core
    case lower

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .upper: "Upper Body"
        case .core: "Core"
        case .lower: "Lower Body"
        }
    }

    var muscles: [MuscleGroup] {
        MuscleGroup.allCases.filter { $0.region == self }
    }
}
