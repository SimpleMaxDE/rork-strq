import Foundation

nonisolated struct ExerciseBuilder {
    static func make(
        _ id: String,
        _ name: String,
        primary: MuscleGroup,
        secondary: [MuscleGroup] = [],
        cat: ExerciseCategory = .compound,
        move: MovementPattern = .horizontalPush,
        worlds: [TrainingWorld] = [.gymStrength],
        equip: [Equipment] = [.none],
        loc: LocationType = .gym,
        diff: ExerciseDifficulty = .intermediate,
        beginnerOk: Bool = false,
        bw: Bool = false,
        jointFriendly: Bool = true,
        prog: ProgressionLevel = .standard,
        progOf: String? = nil,
        regOf: String? = nil,
        desc: String = "",
        instructions: [String] = [],
        mistakes: [String] = [],
        cues: [String] = [],
        alts: [String] = [],
        tags: [String] = []
    ) -> Exercise {
        Exercise(
            id: id,
            name: name,
            primaryMuscle: primary,
            secondaryMuscles: secondary,
            category: cat,
            movementPattern: move,
            trainingWorlds: worlds,
            equipment: equip,
            locationType: loc,
            difficulty: diff,
            isBeginnerFriendly: beginnerOk,
            isJointFriendly: jointFriendly,
            isBodyweight: bw,
            progressionLevel: prog,
            progressionOf: progOf,
            regressionOf: regOf,
            shortDescription: desc,
            instructions: instructions,
            commonMistakes: mistakes,
            cues: cues,
            alternatives: alts,
            tags: tags
        )
    }
}
