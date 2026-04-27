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
        case .compound: L10n.tr("exercise.category.compound.displayName")
        case .isolation: L10n.tr("exercise.category.isolation.displayName")
        case .bodyweight: L10n.tr("exercise.category.bodyweight.displayName")
        case .cardio: L10n.tr("exercise.category.cardio.displayName")
        case .mobility: L10n.tr("exercise.category.mobility.displayName")
        case .warmup: L10n.tr("exercise.category.warmup.displayName")
        case .recovery: L10n.tr("exercise.category.recovery.displayName")
        case .pilates: L10n.tr("exercise.category.pilates.displayName")
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
        case .horizontalPush: L10n.tr("exercise.movementPattern.horizontalPush.displayName")
        case .horizontalPull: L10n.tr("exercise.movementPattern.horizontalPull.displayName")
        case .verticalPush: L10n.tr("exercise.movementPattern.verticalPush.displayName")
        case .verticalPull: L10n.tr("exercise.movementPattern.verticalPull.displayName")
        case .hipHinge: L10n.tr("exercise.movementPattern.hipHinge.displayName")
        case .squat: L10n.tr("exercise.movementPattern.squat.displayName")
        case .lunge: L10n.tr("exercise.movementPattern.lunge.displayName")
        case .carry: L10n.tr("exercise.movementPattern.carry.displayName")
        case .rotation: L10n.tr("exercise.movementPattern.rotation.displayName")
        case .antiRotation: L10n.tr("exercise.movementPattern.antiRotation.displayName")
        case .flexion: L10n.tr("exercise.movementPattern.flexion.displayName")
        case .extension_: L10n.tr("exercise.movementPattern.extension.displayName")
        case .abduction: L10n.tr("exercise.movementPattern.abduction.displayName")
        case .adduction: L10n.tr("exercise.movementPattern.adduction.displayName")
        case .isometric: L10n.tr("exercise.movementPattern.isometric.displayName")
        case .plyometric: L10n.tr("exercise.movementPattern.plyometric.displayName")
        case .locomotion: L10n.tr("exercise.movementPattern.locomotion.displayName")
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
        case .gymStrength: L10n.tr("exercise.trainingWorld.gymStrength.displayName")
        case .homeGym: L10n.tr("exercise.trainingWorld.homeGym.displayName")
        case .homeNoEquipment: L10n.tr("exercise.trainingWorld.homeNoEquipment.displayName")
        case .calisthenics: L10n.tr("exercise.trainingWorld.calisthenics.displayName")
        case .pilates: L10n.tr("exercise.trainingWorld.pilates.displayName")
        case .mobilityStretching: L10n.tr("exercise.trainingWorld.mobilityStretching.displayName")
        case .recoveryRehab: L10n.tr("exercise.trainingWorld.recoveryRehab.displayName")
        case .warmupActivation: L10n.tr("exercise.trainingWorld.warmupActivation.displayName")
        case .functionalAthletic: L10n.tr("exercise.trainingWorld.functionalAthletic.displayName")
        case .cardioConditioning: L10n.tr("exercise.trainingWorld.cardioConditioning.displayName")
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
        case .none: L10n.tr("exercise.equipment.none.displayName")
        case .barbell: L10n.tr("exercise.equipment.barbell.displayName")
        case .dumbbell: L10n.tr("exercise.equipment.dumbbell.displayName")
        case .kettlebell: L10n.tr("exercise.equipment.kettlebell.displayName")
        case .cable: L10n.tr("exercise.equipment.cable.displayName")
        case .machine: L10n.tr("exercise.equipment.machine.displayName")
        case .smithMachine: L10n.tr("exercise.equipment.smithMachine.displayName")
        case .resistanceBand: L10n.tr("exercise.equipment.resistanceBand.displayName")
        case .pullUpBar: L10n.tr("exercise.equipment.pullUpBar.displayName")
        case .bench: L10n.tr("exercise.equipment.bench.displayName")
        case .dipStation: L10n.tr("exercise.equipment.dipStation.displayName")
        case .stabilityBall: L10n.tr("exercise.equipment.stabilityBall.displayName")
        case .foamRoller: L10n.tr("exercise.equipment.foamRoller.displayName")
        case .mat: L10n.tr("exercise.equipment.mat.displayName")
        case .box: L10n.tr("exercise.equipment.box.displayName")
        case .trx: L10n.tr("exercise.equipment.trx.displayName")
        case .medicineBall: L10n.tr("exercise.equipment.medicineBall.displayName")
        case .abWheel: L10n.tr("exercise.equipment.abWheel.displayName")
        case .rings: L10n.tr("exercise.equipment.rings.displayName")
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
        case .beginner: L10n.tr("exercise.difficulty.beginner.displayName")
        case .intermediate: L10n.tr("exercise.difficulty.intermediate.displayName")
        case .advanced: L10n.tr("exercise.difficulty.advanced.displayName")
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
        case .gym: L10n.tr("exercise.location.gym.displayName")
        case .homeGym: L10n.tr("exercise.location.homeGym.displayName")
        case .homeNoEquipment: L10n.tr("exercise.location.homeNoEquipment.displayName")
        case .anywhere: L10n.tr("exercise.location.anywhere.displayName")
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
        case .regression: L10n.tr("exercise.progressionLevel.regression.displayName")
        case .standard: L10n.tr("exercise.progressionLevel.standard.displayName")
        case .progression: L10n.tr("exercise.progressionLevel.progression.displayName")
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
