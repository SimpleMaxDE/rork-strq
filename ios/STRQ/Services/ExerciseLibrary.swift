import Foundation

struct ExerciseLibrary {
    static let shared = ExerciseLibrary()

    let exercises: [Exercise]
    private let exerciseMap: [String: Exercise]

    private init() {
        let all = Self.chestExercises + Self.backExercises + Self.shoulderExercises + Self.armExercises + Self.legExercises + Self.coreExercises + Self.pilatesExercises + Self.mobilityExercises + Self.functionalExercises + Self.extendedMobilityExercises
        self.exercises = all
        var map: [String: Exercise] = [:]
        for ex in all { map[ex.id] = ex }
        self.exerciseMap = map
    }

    func exercise(byId id: String) -> Exercise? {
        if let curated = exerciseMap[id] { return curated }
        // Fallback to imported (ExerciseDBPro) for id-based lookups so swaps/
        // details keep resolving after an imported exercise is chosen.
        // Canonicalize first so legacy alias ids still resolve to the
        // canonical imported row after dedup.
        if id.hasPrefix("edb-") {
            let canonical = ExerciseIdentity.canonical(id)
            return ExerciseDBProImporter.shared.exercises.first(where: { $0.id == canonical })
        }
        return nil
    }

    func exercises(forMuscle muscle: MuscleGroup) -> [Exercise] {
        exercises.filter { $0.primaryMuscle == muscle || $0.secondaryMuscles.contains(muscle) }
    }

    func exercises(forWorld world: TrainingWorld) -> [Exercise] {
        exercises.filter { $0.trainingWorlds.contains(world) }
    }

    func exercises(forEquipment equip: Equipment) -> [Exercise] {
        exercises.filter { $0.equipment.contains(equip) }
    }

    func search(_ query: String) -> [Exercise] {
        let q = query.lowercased()
        return exercises.filter { ex in
            ex.name.lowercased().contains(q) ||
            ex.primaryMuscle.displayName.lowercased().contains(q) ||
            ex.secondaryMuscles.contains(where: { $0.displayName.lowercased().contains(q) }) ||
            ex.equipment.contains(where: { $0.displayName.lowercased().contains(q) }) ||
            ex.tags.contains(where: { $0.lowercased().contains(q) }) ||
            ex.shortDescription.lowercased().contains(q)
        }
    }

    func filtered(
        muscle: MuscleGroup? = nil,
        world: TrainingWorld? = nil,
        equipment: Equipment? = nil,
        difficulty: ExerciseDifficulty? = nil,
        location: LocationType? = nil,
        beginnerOnly: Bool = false,
        bodyweightOnly: Bool = false,
        jointFriendly: Bool = false
    ) -> [Exercise] {
        exercises.filter { ex in
            if let m = muscle, ex.primaryMuscle != m && !ex.secondaryMuscles.contains(m) { return false }
            if let w = world, !ex.trainingWorlds.contains(w) { return false }
            if let e = equipment, !ex.equipment.contains(e) { return false }
            if let d = difficulty, ex.difficulty != d { return false }
            if let l = location {
                switch l {
                case .gym: break
                case .homeGym: if ex.locationType == .gym { return false }
                case .homeNoEquipment: if ex.locationType != .homeNoEquipment && ex.locationType != .anywhere { return false }
                case .anywhere: break
                }
            }
            if beginnerOnly && !ex.isBeginnerFriendly { return false }
            if jointFriendly && !ex.isJointFriendly { return false }
            if bodyweightOnly && !ex.isBodyweight { return false }
            return true
        }
    }

    func alternatives(for exercise: Exercise) -> [Exercise] {
        let altIds = exercise.alternatives
        let directAlts = altIds.compactMap { exerciseMap[$0] }
        if !directAlts.isEmpty { return directAlts }
        return exercises.filter { ex in
            ex.id != exercise.id &&
            ex.primaryMuscle == exercise.primaryMuscle &&
            ex.movementPattern == exercise.movementPattern
        }.prefix(5).map { $0 }
    }

    func progressions(for exercise: Exercise) -> [Exercise] {
        exercises.filter { $0.progressionOf == exercise.id }
    }

    func regressions(for exercise: Exercise) -> [Exercise] {
        exercises.filter { $0.regressionOf == exercise.id }
    }

    func family(for exercise: Exercise) -> ExerciseFamilyGroup? {
        ExerciseFamilyService.shared.family(forExercise: exercise.id)
    }

    func familyMembers(for exercise: Exercise) -> [Exercise] {
        ExerciseFamilyService.shared.familyMembers(forExercise: exercise.id)
            .filter { $0.id != exercise.id }
    }

    func progressionChain(for exercise: Exercise) -> [Exercise] {
        ExerciseFamilyService.shared.progressionChain(forExercise: exercise.id)
    }

    func homeAlternatives(for exercise: Exercise) -> [Exercise] {
        ExerciseFamilyService.shared.homeAlternatives(forExercise: exercise.id)
            .filter { $0.id != exercise.id }
    }

    func jointFriendlyOptions(for exercise: Exercise) -> [Exercise] {
        ExerciseFamilyService.shared.jointFriendlyOptions(forExercise: exercise.id)
            .filter { $0.id != exercise.id }
    }
}
