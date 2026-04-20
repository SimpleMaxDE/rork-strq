import Foundation

// MARK: - Raw external DTOs (ExerciseDBPro schema)

nonisolated struct ExerciseDBProRaw: Codable, Sendable {
    let exerciseId: String
    let name: String
    let gifUrl: String?
    let targetMuscles: [String]
    let bodyParts: [String]
    let equipments: [String]
    let secondaryMuscles: [String]
    let instructions: [String]
}

// MARK: - Importer

/// Loads ExerciseDBPro bundled JSON, normalizes into STRQ `Exercise` values,
/// and enriches them with STRQ concepts (movement pattern, category, difficulty,
/// joint-friendliness, etc). Lazy-loaded, read-only, safe for app-wide use.
nonisolated final class ExerciseDBProImporter: Sendable {
    static let shared = ExerciseDBProImporter()

    private let _exercises: [Exercise]
    private let _remoteGif: [String: String]

    var exercises: [Exercise] { _exercises }
    func remoteGifURL(for id: String) -> String? { _remoteGif[id] }

    private init() {
        guard let raws = Self.loadRaws() else {
            self._exercises = []
            self._remoteGif = [:]
            return
        }
        var out: [Exercise] = []
        var gifs: [String: String] = [:]
        out.reserveCapacity(raws.count)
        for r in raws {
            guard let ex = Self.normalize(r) else { continue }
            out.append(ex)
            if let g = r.gifUrl, !g.isEmpty { gifs[ex.id] = g }
        }
        self._exercises = out
        self._remoteGif = gifs
    }

    // MARK: - Load

    private static func loadRaws() -> [ExerciseDBProRaw]? {
        let candidates = [
            Bundle.main.url(forResource: "exercises2", withExtension: "json"),
            Bundle.main.url(forResource: "exercises2", withExtension: "json", subdirectory: "ExerciseDBPro"),
            Bundle.main.url(forResource: "exercises2", withExtension: "json", subdirectory: "Data/External/ExerciseDBPro")
        ].compactMap { $0 }
        guard let url = candidates.first, let data = try? Data(contentsOf: url) else { return nil }
        return try? JSONDecoder().decode([ExerciseDBProRaw].self, from: data)
    }

    // MARK: - Normalization

    private static let importedPrefix = "edb-"

    private static func normalize(_ r: ExerciseDBProRaw) -> Exercise? {
        let primary = mapPrimaryMuscle(r) ?? .coreStability
        let secondaries = r.secondaryMuscles.compactMap(mapMuscle).filter { $0 != primary }
        let equipment = normalizeEquipment(r.equipments)
        let isBodyweight = r.equipments.contains("body weight") || equipment == [.none] || equipment.isEmpty
        let pattern = inferPattern(name: r.name, primary: primary, bodyParts: r.bodyParts)
        let category = inferCategory(name: r.name, bodyParts: r.bodyParts, equipment: equipment, isBodyweight: isBodyweight)
        let difficulty = inferDifficulty(name: r.name, equipment: equipment, category: category)
        let jointFriendly = inferJointFriendly(name: r.name, equipment: equipment, pattern: pattern, category: category)
        let worlds = inferWorlds(equipment: equipment, isBodyweight: isBodyweight, category: category, bodyParts: r.bodyParts)
        let location: LocationType = {
            if isBodyweight { return .anywhere }
            if equipment.contains(.barbell) || equipment.contains(.smithMachine) || equipment.contains(.machine) || equipment.contains(.cable) {
                return .gym
            }
            return .homeGym
        }()
        let instructions = r.instructions.map { stripStepPrefix($0) }.filter { !$0.isEmpty }
        let shortDesc = buildShortDescription(primary: primary, secondaries: secondaries, equipment: equipment, pattern: pattern)
        let tags = buildTags(r: r, pattern: pattern, category: category)

        return Exercise(
            id: importedPrefix + r.exerciseId,
            name: prettifyName(r.name),
            primaryMuscle: primary,
            secondaryMuscles: Array(Set(secondaries)).sorted { $0.rawValue < $1.rawValue },
            category: category,
            movementPattern: pattern,
            trainingWorlds: worlds,
            equipment: equipment.isEmpty ? [.none] : equipment,
            locationType: location,
            difficulty: difficulty,
            isBeginnerFriendly: difficulty == .beginner,
            isJointFriendly: jointFriendly,
            isBodyweight: isBodyweight,
            progressionLevel: .standard,
            progressionOf: nil,
            regressionOf: nil,
            shortDescription: shortDesc,
            instructions: instructions,
            commonMistakes: [],
            cues: [],
            alternatives: [],
            tags: tags
        )
    }

    // MARK: - Muscle mapping

    private static let muscleMap: [String: MuscleGroup] = [
        "pectorals": .chest, "chest": .chest, "upper chest": .chest,
        "latissimus dorsi": .lats, "lats": .lats,
        "upper back": .back, "back": .back, "rhomboids": .back,
        "trapezius": .traps, "traps": .traps,
        "deltoids": .shoulders, "delts": .shoulders, "shoulders": .shoulders,
        "rear deltoids": .shoulders, "rotator cuff": .shoulders, "serratus anterior": .shoulders,
        "levator scapulae": .traps,
        "biceps": .biceps, "brachialis": .biceps,
        "triceps": .triceps,
        "forearms": .forearms, "wrist extensors": .forearms, "wrist flexors": .forearms,
        "grip muscles": .forearms, "hands": .forearms, "wrists": .forearms,
        "sternocleidomastoid": .neck, "neck": .neck,
        "abdominals": .abs, "abs": .abs, "lower abs": .abs, "core": .coreStability,
        "obliques": .obliques,
        "spine": .lowerBack, "lower back": .lowerBack,
        "glutes": .glutes,
        "quadriceps": .quads, "quads": .quads,
        "hamstrings": .hamstrings,
        "calves": .calves, "soleus": .calves,
        "adductors": .adductors, "inner thighs": .adductors, "groin": .adductors,
        "abductors": .abductors,
        "hip flexors": .hipFlexors,
        "shins": .tibialis, "ankles": .tibialis, "ankle stabilizers": .tibialis, "feet": .tibialis
    ]

    private static func mapMuscle(_ s: String) -> MuscleGroup? {
        muscleMap[s.lowercased()]
    }

    private static func mapPrimaryMuscle(_ r: ExerciseDBProRaw) -> MuscleGroup? {
        if let first = r.targetMuscles.first, let m = mapMuscle(first) { return m }
        // Fall back to body part
        switch r.bodyParts.first?.lowercased() {
        case "chest": return .chest
        case "back": return .back
        case "shoulders": return .shoulders
        case "upper arms": return .biceps
        case "lower arms": return .forearms
        case "upper legs": return .quads
        case "lower legs": return .calves
        case "waist": return .abs
        case "neck": return .neck
        case "cardio": return .coreStability
        default: return nil
        }
    }

    // MARK: - Equipment

    private static func normalizeEquipment(_ raw: [String]) -> [Equipment] {
        var out: [Equipment] = []
        for e in raw {
            switch e.lowercased() {
            case "barbell", "olympic barbell", "ez barbell", "trap bar": out.append(.barbell)
            case "dumbbell": out.append(.dumbbell)
            case "kettlebell": out.append(.kettlebell)
            case "cable", "rope": out.append(.cable)
            case "leverage machine", "sled machine", "hammer",
                 "stationary bike", "elliptical machine", "stepmill machine",
                 "skierg machine", "upper body ergometer":
                out.append(.machine)
            case "smith machine": out.append(.smithMachine)
            case "band", "resistance band": out.append(.resistanceBand)
            case "body weight", "assisted", "weighted": out.append(.none)
            case "stability ball", "bosu ball": out.append(.stabilityBall)
            case "medicine ball": out.append(.medicineBall)
            case "roller": out.append(.foamRoller)
            case "wheel roller": out.append(.abWheel)
            case "tire": out.append(.none)
            default: break
            }
        }
        let unique = Array(Set(out))
        if unique.count > 1, unique.contains(.none) {
            return unique.filter { $0 != .none }
        }
        return unique
    }

    // MARK: - Pattern / category / difficulty heuristics

    private static func inferPattern(name: String, primary: MuscleGroup, bodyParts: [String]) -> MovementPattern {
        let n = name.lowercased()
        if n.contains("stretch") { return .flexion }
        if n.contains("deadlift") || n.contains("good morning") || n.contains("rdl") || n.contains("hip thrust") || n.contains("hip hinge") || n.contains("glute bridge") {
            return .hipHinge
        }
        if n.contains("squat") { return .squat }
        if n.contains("lunge") || n.contains("split squat") || n.contains("step-up") || n.contains("step up") {
            return .lunge
        }
        if n.contains("carry") || n.contains("farmer") { return .carry }
        if n.contains("row") || n.contains("pulldown") || n.contains("pull-up") || n.contains("pull up") || n.contains("chin-up") || n.contains("chin up") {
            if n.contains("pulldown") || n.contains("pull-up") || n.contains("pull up") || n.contains("chin") {
                return .verticalPull
            }
            return .horizontalPull
        }
        if n.contains("overhead press") || n.contains("shoulder press") || n.contains("military press") || n.contains("push press") {
            return .verticalPush
        }
        if n.contains("bench press") || n.contains("push-up") || n.contains("push up") || n.contains("chest press") || n.contains("dip") {
            return .horizontalPush
        }
        if n.contains("lateral raise") || n.contains("side raise") || n.contains("abduction") {
            return .abduction
        }
        if n.contains("adduction") { return .adduction }
        if n.contains("rotation") || n.contains("twist") || n.contains("wood chop") { return .rotation }
        if n.contains("plank") || n.contains("hold") || n.contains("isometric") { return .isometric }
        if n.contains("jump") || n.contains("plyo") || n.contains("bound") { return .plyometric }
        if n.contains("run") || n.contains("walk") || n.contains("sprint") || n.contains("bike") || n.contains("cycling") {
            return .locomotion
        }
        if n.contains("curl") { return .flexion }
        if n.contains("extension") { return .extension_ }

        switch primary {
        case .chest: return .horizontalPush
        case .lats, .back: return .horizontalPull
        case .shoulders: return .verticalPush
        case .biceps: return .flexion
        case .triceps: return .extension_
        case .quads: return .squat
        case .hamstrings, .glutes: return .hipHinge
        case .calves: return .extension_
        case .abs, .obliques, .coreStability, .lowerBack: return .isometric
        default: return .flexion
        }
    }

    private static func inferCategory(name: String, bodyParts: [String], equipment: [Equipment], isBodyweight: Bool) -> ExerciseCategory {
        let n = name.lowercased()
        if bodyParts.contains(where: { $0.lowercased() == "cardio" }) { return .cardio }
        if n.contains("stretch") || n.contains("mobility") || n.contains("yoga") { return .mobility }
        if n.contains("warm") || n.contains("activation") { return .warmup }

        let compoundKeywords = ["squat", "deadlift", "bench press", "overhead press", "shoulder press",
                                "row", "pull-up", "pull up", "chin-up", "chin up", "pulldown",
                                "clean", "snatch", "thruster", "dip", "push-up", "push up", "lunge",
                                "hip thrust", "step-up", "step up"]
        if compoundKeywords.contains(where: { n.contains($0) }) {
            if isBodyweight { return .bodyweight }
            return .compound
        }
        if isBodyweight { return .bodyweight }
        return .isolation
    }

    private static func inferDifficulty(name: String, equipment: [Equipment], category: ExerciseCategory) -> ExerciseDifficulty {
        let n = name.lowercased()
        let advanced = ["one arm", "one-arm", "single arm", "single-arm", "pistol", "muscle-up", "muscle up",
                        "snatch", "clean and jerk", "ring", "handstand", "archer", "plyo", "plyometric",
                        "deficit", "tempo", "pause", "behind the neck", "jefferson", "zercher"]
        if advanced.contains(where: { n.contains($0) }) { return .advanced }
        let beginner = ["assisted", "seated", "supported", "machine", "wall", "kneeling", "supine", "band"]
        if category == .mobility || category == .warmup { return .beginner }
        if beginner.contains(where: { n.contains($0) }) { return .beginner }
        if equipment.contains(.machine) || equipment.contains(.smithMachine) || equipment.contains(.cable) {
            return .beginner
        }
        return .intermediate
    }

    private static func inferJointFriendly(name: String, equipment: [Equipment], pattern: MovementPattern, category: ExerciseCategory) -> Bool {
        let n = name.lowercased()
        if category == .mobility || category == .recovery || category == .pilates { return true }
        if equipment.contains(.machine) || equipment.contains(.cable) || equipment.contains(.smithMachine) || equipment.contains(.resistanceBand) {
            return true
        }
        if pattern == .plyometric { return false }
        if n.contains("deadlift") || n.contains("snatch") || n.contains("clean") { return false }
        if n.contains("leg extension") || n.contains("leg curl") || n.contains("hip thrust") || n.contains("glute bridge") {
            return true
        }
        return false
    }

    private static func inferWorlds(equipment: [Equipment], isBodyweight: Bool, category: ExerciseCategory, bodyParts: [String]) -> [TrainingWorld] {
        var worlds: [TrainingWorld] = []
        if category == .mobility { worlds.append(.mobilityStretching) }
        if category == .warmup { worlds.append(.warmupActivation) }
        if category == .recovery { worlds.append(.recoveryRehab) }
        if bodyParts.contains(where: { $0.lowercased() == "cardio" }) { worlds.append(.cardioConditioning) }
        if isBodyweight {
            worlds.append(.calisthenics)
            worlds.append(.homeNoEquipment)
        }
        if equipment.contains(.barbell) || equipment.contains(.smithMachine) || equipment.contains(.machine) || equipment.contains(.cable) {
            worlds.append(.gymStrength)
        }
        if equipment.contains(.dumbbell) || equipment.contains(.kettlebell) || equipment.contains(.resistanceBand) {
            worlds.append(.homeGym)
            worlds.append(.gymStrength)
        }
        if worlds.isEmpty { worlds.append(.gymStrength) }
        return Array(Set(worlds))
    }

    // MARK: - Presentation helpers

    private static func stripStepPrefix(_ s: String) -> String {
        // "Step:1 Do X." -> "Do X."
        if let range = s.range(of: #"^Step:\d+\s*"#, options: .regularExpression) {
            return String(s[range.upperBound...]).trimmingCharacters(in: .whitespaces)
        }
        return s.trimmingCharacters(in: .whitespaces)
    }

    private static func prettifyName(_ s: String) -> String {
        s.split(separator: " ").map { part -> String in
            let lower = part.lowercased()
            // Keep short grip/brand tokens uppercase
            if ["ez", "trx", "rdl"].contains(lower) { return lower.uppercased() }
            return lower.prefix(1).uppercased() + lower.dropFirst()
        }.joined(separator: " ")
    }

    private static func buildShortDescription(primary: MuscleGroup, secondaries: [MuscleGroup], equipment: [Equipment], pattern: MovementPattern) -> String {
        let equipLabel = equipment.first(where: { $0 != .none })?.displayName ?? "Bodyweight"
        var desc = "\(equipLabel) \(pattern.displayName.lowercased()) targeting \(primary.displayName.lowercased())"
        if let sec = secondaries.first {
            desc += " with \(sec.displayName.lowercased()) support"
        }
        return desc + "."
    }

    private static func buildTags(r: ExerciseDBProRaw, pattern: MovementPattern, category: ExerciseCategory) -> [String] {
        var tags: [String] = ["ExerciseDBPro"]
        tags.append(contentsOf: r.targetMuscles)
        tags.append(contentsOf: r.bodyParts)
        tags.append(pattern.displayName)
        tags.append(category.displayName)
        return tags
    }
}
