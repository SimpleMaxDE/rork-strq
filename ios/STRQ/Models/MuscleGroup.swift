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

    var localizedDisplayName: String {
        switch self {
        case .chest: L10n.tr("muscle.chest", fallback: "Chest")
        case .back: L10n.tr("muscle.back", fallback: "Back")
        case .lats: L10n.tr("muscle.lats", fallback: "Lats")
        case .shoulders: L10n.tr("muscle.shoulders", fallback: "Shoulders")
        case .biceps: L10n.tr("muscle.biceps", fallback: "Biceps")
        case .triceps: L10n.tr("muscle.triceps", fallback: "Triceps")
        case .forearms: L10n.tr("muscle.forearms", fallback: "Forearms")
        case .traps: L10n.tr("muscle.traps", fallback: "Traps")
        case .neck: L10n.tr("muscle.neck", fallback: "Neck")
        case .arms: L10n.tr("muscle.arms", fallback: "Arms")
        case .abs: L10n.tr("muscle.abs", fallback: "Abs")
        case .obliques: L10n.tr("muscle.obliques", fallback: "Obliques")
        case .lowerBack: L10n.tr("muscle.lowerBack", fallback: "Lower Back")
        case .glutes: L10n.tr("muscle.glutes", fallback: "Glutes")
        case .quads: L10n.tr("muscle.quads", fallback: "Quads")
        case .hamstrings: L10n.tr("muscle.hamstrings", fallback: "Hamstrings")
        case .calves: L10n.tr("muscle.calves", fallback: "Calves")
        case .adductors: L10n.tr("muscle.adductors", fallback: "Adductors")
        case .abductors: L10n.tr("muscle.abductors", fallback: "Abductors")
        case .hipFlexors: L10n.tr("muscle.hipFlexors", fallback: "Hip Flexors")
        case .tibialis: L10n.tr("muscle.tibialis", fallback: "Tibialis")
        case .coreStability: L10n.tr("muscle.coreStability", fallback: "Core Stability")
        case .rotationAntiRotation: L10n.tr("muscle.rotationAntiRotation", fallback: "Rotation")
        }
    }

    static func localizedDisplayName(forDisplayName displayName: String) -> String {
        allCases.first { $0.displayName == displayName }?.localizedDisplayName ?? displayName
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

    var localizedDisplayName: String {
        switch self {
        case .upper: L10n.tr("muscleRegion.upper", fallback: "Upper Body")
        case .core: L10n.tr("muscleRegion.core", fallback: "Core")
        case .lower: L10n.tr("muscleRegion.lower", fallback: "Lower Body")
        }
    }

    var muscles: [MuscleGroup] {
        MuscleGroup.allCases.filter { $0.region == self }
    }
}
