import Foundation

nonisolated enum ExerciseCategory: String, Codable, CaseIterable, Identifiable, Sendable {
    case compound
    case isolation
    case bodyweight
    case cardio
    case mobility
    case warmup
    case recovery
    case pilates

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .compound: "Compound"
        case .isolation: "Isolation"
        case .bodyweight: "Bodyweight"
        case .cardio: "Cardio"
        case .mobility: "Mobility"
        case .warmup: "Warm-Up"
        case .recovery: "Recovery"
        case .pilates: "Pilates"
        }
    }
}

nonisolated enum MovementPattern: String, Codable, CaseIterable, Identifiable, Sendable {
    case horizontalPush
    case horizontalPull
    case verticalPush
    case verticalPull
    case hipHinge
    case squat
    case lunge
    case carry
    case rotation
    case antiRotation
    case flexion
    case extension_
    case abduction
    case adduction
    case isometric
    case plyometric
    case locomotion

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .horizontalPush: "Horizontal Push"
        case .horizontalPull: "Horizontal Pull"
        case .verticalPush: "Vertical Push"
        case .verticalPull: "Vertical Pull"
        case .hipHinge: "Hip Hinge"
        case .squat: "Squat"
        case .lunge: "Lunge"
        case .carry: "Carry"
        case .rotation: "Rotation"
        case .antiRotation: "Anti-Rotation"
        case .flexion: "Flexion"
        case .extension_: "Extension"
        case .abduction: "Abduction"
        case .adduction: "Adduction"
        case .isometric: "Isometric"
        case .plyometric: "Plyometric"
        case .locomotion: "Locomotion"
        }
    }
}

nonisolated enum TrainingWorld: String, Codable, CaseIterable, Identifiable, Sendable {
    case gymStrength
    case homeGym
    case homeNoEquipment
    case calisthenics
    case pilates
    case mobilityStretching
    case recoveryRehab
    case warmupActivation
    case functionalAthletic
    case cardioConditioning

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .gymStrength: "Gym Strength"
        case .homeGym: "Home Gym"
        case .homeNoEquipment: "Home (No Equipment)"
        case .calisthenics: "Calisthenics"
        case .pilates: "Pilates"
        case .mobilityStretching: "Mobility & Stretching"
        case .recoveryRehab: "Recovery & Rehab"
        case .warmupActivation: "Warm-Up & Activation"
        case .functionalAthletic: "Functional & Athletic"
        case .cardioConditioning: "Cardio & Conditioning"
        }
    }

    var symbolName: String {
        switch self {
        case .gymStrength: "dumbbell.fill"
        case .homeGym: "house.fill"
        case .homeNoEquipment: "figure.stand"
        case .calisthenics: "figure.gymnastics"
        case .pilates: "figure.pilates"
        case .mobilityStretching: "figure.flexibility"
        case .recoveryRehab: "heart.circle.fill"
        case .warmupActivation: "flame.fill"
        case .functionalAthletic: "figure.highintensity.intervaltraining"
        case .cardioConditioning: "figure.run"
        }
    }

    var accentColor: String {
        switch self {
        case .gymStrength: "orange"
        case .homeGym: "blue"
        case .homeNoEquipment: "green"
        case .calisthenics: "purple"
        case .pilates: "pink"
        case .mobilityStretching: "teal"
        case .recoveryRehab: "mint"
        case .warmupActivation: "red"
        case .functionalAthletic: "yellow"
        case .cardioConditioning: "cyan"
        }
    }
}

nonisolated enum Equipment: String, Codable, CaseIterable, Identifiable, Sendable {
    case none
    case barbell
    case dumbbell
    case kettlebell
    case cable
    case machine
    case smithMachine
    case resistanceBand
    case pullUpBar
    case bench
    case dipStation
    case stabilityBall
    case foamRoller
    case mat
    case box
    case trx
    case medicineBall
    case abWheel
    case rings

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .none: "No Equipment"
        case .barbell: "Barbell"
        case .dumbbell: "Dumbbell"
        case .kettlebell: "Kettlebell"
        case .cable: "Cable"
        case .machine: "Machine"
        case .smithMachine: "Smith Machine"
        case .resistanceBand: "Resistance Band"
        case .pullUpBar: "Pull-Up Bar"
        case .bench: "Bench"
        case .dipStation: "Dip Station"
        case .stabilityBall: "Stability Ball"
        case .foamRoller: "Foam Roller"
        case .mat: "Mat"
        case .box: "Box"
        case .trx: "TRX"
        case .medicineBall: "Medicine Ball"
        case .abWheel: "Ab Wheel"
        case .rings: "Rings"
        }
    }
}

nonisolated enum ExerciseDifficulty: String, Codable, CaseIterable, Identifiable, Sendable {
    case beginner
    case intermediate
    case advanced

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .beginner: "Beginner"
        case .intermediate: "Intermediate"
        case .advanced: "Advanced"
        }
    }

    var color: String {
        switch self {
        case .beginner: "green"
        case .intermediate: "orange"
        case .advanced: "red"
        }
    }
}

nonisolated enum LocationType: String, Codable, CaseIterable, Identifiable, Sendable {
    case gym
    case homeGym
    case homeNoEquipment
    case anywhere

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .gym: "Gym"
        case .homeGym: "Home Gym"
        case .homeNoEquipment: "Home (No Equipment)"
        case .anywhere: "Anywhere"
        }
    }
}

nonisolated enum ProgressionLevel: Int, Codable, CaseIterable, Identifiable, Sendable {
    case regression = -1
    case standard = 0
    case progression = 1

    var id: Int { rawValue }

    var displayName: String {
        switch self {
        case .regression: "Easier"
        case .standard: "Standard"
        case .progression: "Harder"
        }
    }
}

nonisolated struct Exercise: Identifiable, Codable, Hashable, Sendable {
    let id: String
    let name: String
    let primaryMuscle: MuscleGroup
    let secondaryMuscles: [MuscleGroup]
    let category: ExerciseCategory
    let movementPattern: MovementPattern
    let trainingWorlds: [TrainingWorld]
    let equipment: [Equipment]
    let locationType: LocationType
    let difficulty: ExerciseDifficulty
    let isBeginnerFriendly: Bool
    let isJointFriendly: Bool
    let isBodyweight: Bool
    let progressionLevel: ProgressionLevel
    let progressionOf: String?
    let regressionOf: String?
    let shortDescription: String
    let instructions: [String]
    let commonMistakes: [String]
    let cues: [String]
    let alternatives: [String]
    let tags: [String]

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: Exercise, rhs: Exercise) -> Bool {
        lhs.id == rhs.id
    }
}
