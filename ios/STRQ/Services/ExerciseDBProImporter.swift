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
    private let _familyByExerciseId: [String: String]
    /// Alias map — raw or prefixed ids of duplicate rows that were collapsed
    /// into a canonical exercise. Resolves both directions so any caller that
    /// still holds a legacy id can reach canonical media / family.
    private let _canonicalIdByAlias: [String: String]

    var exercises: [Exercise] { _exercises }
    var familyAssignments: [String: String] { _familyByExerciseId }
    /// Remote GIF URL for an imported exercise id. Follows alias mappings so
    /// collapsed duplicates still resolve to the canonical row's media.
    func remoteGifURL(for id: String) -> String? {
        if let direct = _remoteGif[id] { return direct }
        if let canonical = _canonicalIdByAlias[id], let url = _remoteGif[canonical] { return url }
        return nil
    }
    func familyId(for exerciseId: String) -> String? {
        if let fam = _familyByExerciseId[exerciseId] { return fam }
        if let canonical = _canonicalIdByAlias[exerciseId] { return _familyByExerciseId[canonical] }
        return nil
    }
    /// Canonical id for an imported row id when it was collapsed as a duplicate.
    /// Returns the input id when it is already canonical or unknown.
    func canonicalId(for id: String) -> String { _canonicalIdByAlias[id] ?? id }

    private init() {
        guard let raws = Self.loadRaws() else {
            self._exercises = []
            self._remoteGif = [:]
            self._familyByExerciseId = [:]
            self._canonicalIdByAlias = [:]
            return
        }
        var out: [Exercise] = []
        var gifs: [String: String] = [:]
        var families: [String: String] = [:]
        var aliases: [String: String] = [:]
        // Canonical row index, keyed by fingerprint, so we can upgrade a
        // previously-seen duplicate when a later row brings better data
        // (e.g. an imported GIF the first duplicate was missing).
        var canonicalIndexByFingerprint: [String: Int] = [:]
        out.reserveCapacity(raws.count)
        for r in raws {
            guard let result = Self.normalize(r) else { continue }
            let rawGif = r.gifUrl.flatMap { $0.isEmpty ? nil : $0 }

            if let existingIdx = canonicalIndexByFingerprint[result.fingerprint] {
                // Duplicate collapsed by fingerprint. Register both raw and
                // prefixed ids as aliases of the canonical row so lookups by
                // either id resolve to canonical family / media.
                let canonicalId = out[existingIdx].id
                aliases[r.exerciseId] = canonicalId
                aliases[Self.importedPrefix + r.exerciseId] = canonicalId
                // If the canonical row had no GIF but this duplicate does,
                // upgrade canonical media — avoids the "first-seen wins even
                // when blank" failure mode.
                if gifs[canonicalId] == nil, let g = rawGif {
                    gifs[canonicalId] = g
                }
                continue
            }

            canonicalIndexByFingerprint[result.fingerprint] = out.count
            out.append(result.exercise)
            if let g = rawGif {
                gifs[r.exerciseId] = g
                gifs[result.exercise.id] = g
            }
            if let famId = result.familyId { families[result.exercise.id] = famId }
        }
        self._exercises = out
        self._remoteGif = gifs
        self._familyByExerciseId = families
        self._canonicalIdByAlias = aliases
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

    struct NormalizedExercise {
        let exercise: Exercise
        let fingerprint: String
        let familyId: String?
    }

    private static func normalize(_ r: ExerciseDBProRaw) -> NormalizedExercise? {
        let cleanedName = cleanDisplayName(r.name)
        guard !cleanedName.isEmpty else { return nil }
        let primary = mapPrimaryMuscle(r) ?? .coreStability
        let secondaries = r.secondaryMuscles.compactMap(mapMuscle).filter { $0 != primary }
        let equipment = normalizeEquipment(r.equipments)
        let isBodyweight = r.equipments.contains("body weight") || equipment == [.none] || equipment.isEmpty
        let pattern = inferPattern(name: cleanedName, primary: primary, bodyParts: r.bodyParts)
        let category = inferCategory(name: cleanedName, bodyParts: r.bodyParts, equipment: equipment, isBodyweight: isBodyweight)
        let difficulty = inferDifficulty(name: cleanedName, equipment: equipment, category: category)
        let jointFriendly = inferJointFriendly(name: cleanedName, equipment: equipment, pattern: pattern, category: category)
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
        let familyId = inferFamily(cleanName: cleanedName, primary: primary, pattern: pattern, isBodyweight: isBodyweight)
        let fingerprint = makeFingerprint(cleanName: cleanedName, equipment: equipment, isBodyweight: isBodyweight)

        let exercise = Exercise(
            id: importedPrefix + r.exerciseId,
            name: prettifyName(cleanedName),
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
        return NormalizedExercise(exercise: exercise, fingerprint: fingerprint, familyId: familyId)
    }

    // MARK: - Name cleanup / dedup

    /// Strips raw third-party naming artifacts so display names feel STRQ-grade:
    /// - removes `(male)` / `(female)` gender tags
    /// - removes trailing `male` / `female`
    /// - removes versioning noise like `v. 2` / trailing standalone digits
    /// - collapses whitespace
    private static func cleanDisplayName(_ raw: String) -> String {
        var n = raw
        let patterns: [(String, String)] = [
            (#"\s*\((?i:male|female)\)\s*"#, " "),
            (#"\s+(?i:male|female)\s*$"#, ""),
            (#"\s+v\.\s*\d+\s*$"#, ""),
            (#"\s+\d+\s*$"#, ""),
            (#"\s+"#, " ")
        ]
        for (pattern, replacement) in patterns {
            n = n.replacingOccurrences(of: pattern, with: replacement, options: .regularExpression)
        }
        return n.trimmingCharacters(in: .whitespaces)
    }

    /// Canonicalizes a cleaned name for fingerprinting only — lowercases,
    /// normalizes punctuation/hyphens/apostrophes, collapses whitespace, and
    /// applies conservative singular/plural + known alias normalization so
    /// trivial naming variants collapse without merging genuinely different
    /// exercises.
    ///
    /// Kept intentionally conservative: we only strip trailing `s` for tokens
    /// that have a safe plural form in this domain (raises → raise, curls →
    /// curl, rows → row, etc.) and preserve equipment/target names that
    /// would change meaning (e.g. `triceps`, `lats`, `abs`).
    private static func canonicalFingerprintName(_ cleanedName: String) -> String {
        let lowered = cleanedName.lowercased()
        let punctStripped = lowered
            .replacingOccurrences(of: "’", with: "")
            .replacingOccurrences(of: "'", with: "")
            .replacingOccurrences(of: "`", with: "")
            .replacingOccurrences(of: "-", with: " ")
            .replacingOccurrences(of: "/", with: " ")
            .replacingOccurrences(of: ".", with: " ")
            .replacingOccurrences(of: ",", with: " ")
        let parts = punctStripped.split { !$0.isLetter && !$0.isNumber }
        var tokens: [String] = []
        tokens.reserveCapacity(parts.count)
        for part in parts {
            var t = String(part)
            if let alias = tokenAliasMap[t] {
                t = alias
            } else if let singular = safeSingular(t) {
                t = singular
            }
            tokens.append(t)
        }
        return tokens.joined(separator: " ")
    }

    /// Safe plural→singular reductions. Returns nil when a token should be
    /// left alone (e.g. `triceps`, `lats`, `abs` — anatomy, not plural noise).
    private static func safeSingular(_ token: String) -> String? {
        if preserveAsIs.contains(token) { return nil }
        // "raises", "pulses", "crunches" → "raise", "pulse", "crunch"
        if token.hasSuffix("ies"), token.count > 3 {
            return String(token.dropLast(3)) + "y"
        }
        if token.hasSuffix("sses"), token.count > 4 {
            return String(token.dropLast(2))
        }
        if token.hasSuffix("ches") || token.hasSuffix("shes") {
            return String(token.dropLast(2))
        }
        if token.hasSuffix("ses"), token.count > 3 {
            return String(token.dropLast(2))
        }
        if token.hasSuffix("s"), !token.hasSuffix("ss"), token.count > 3 {
            return String(token.dropLast())
        }
        return nil
    }

    /// Anatomy / equipment tokens that look plural but are not — preserve.
    private static let preserveAsIs: Set<String> = [
        "triceps", "biceps", "lats", "abs", "glutes", "traps", "quads",
        "hamstrings", "calves", "delts", "pecs", "obliques", "adductors",
        "abductors", "forearms", "shoulders", "shins", "hips", "knees",
        "ankles", "wrists", "hands", "legs", "arms", "dumbbells",
        "kettlebells", "barbells"
    ]

    /// Token-level canonical aliases — collapses common naming variants
    /// (`pushup` / `push up` / `push-up`) at the fingerprint layer.
    private static let tokenAliasMap: [String: String] = [
        "pushups": "pushup",
        "push": "push",
        "pullup": "pullup",
        "pullups": "pullup",
        "chinup": "chinup",
        "chinups": "chinup",
        "situp": "situp",
        "situps": "situp",
        "signle": "single",
        "db": "dumbbell",
        "bb": "barbell",
        "kb": "kettlebell",
        "rdl": "rdl",
        "romanian": "rdl",
        "stifflegged": "rdl",
        "stiffleg": "rdl"
    ]

    /// Deterministic fingerprint that groups true duplicates together:
    /// canonicalized name (singular, punctuation-normalized, alias-folded) +
    /// sorted normalized equipment set. Conservative — only collapses
    /// trivial naming noise, not genuinely different exercises.
    private static func makeFingerprint(cleanName: String, equipment: [Equipment], isBodyweight: Bool) -> String {
        let eq: [String]
        if equipment.isEmpty || equipment == [.none] || isBodyweight {
            eq = ["bodyweight"]
        } else {
            eq = equipment.filter { $0 != .none }.map(\.rawValue).sorted()
        }
        return canonicalFingerprintName(cleanName) + "|" + eq.joined(separator: ",")
    }

    // MARK: - Family classification

    /// Maps an imported exercise onto a curated STRQ family id based on name /
    /// movement cues. Conservative — returns `nil` when no strong match exists
    /// so imports don't dilute curated family coherence.
    private static func inferFamily(cleanName: String, primary: MuscleGroup, pattern: MovementPattern, isBodyweight: Bool) -> String? {
        let n = cleanName.lowercased()
        // Rear delt / upper back isolations first (face pull can contain "pull")
        if n.contains("face pull") || n.contains("reverse fly") || n.contains("rear delt") || n.contains("pull apart") || n.contains("rear deltoid") {
            return "rear-delt-family"
        }
        // Presses
        if n.contains("incline") && (n.contains("press") || n.contains("bench")) && !n.contains("row") && !n.contains("fly") && !n.contains("curl") && !n.contains("raise") {
            return "incline-press-family"
        }
        if n.contains("bench press") || n.contains("chest press") || n.contains("floor press") {
            return "bench-press-family"
        }
        if n.contains("fly") || n.contains("crossover") || n.contains("pec deck") {
            return "chest-fly-family"
        }
        if n.contains("dip") && !n.contains("dip kickback") {
            return "dip-family"
        }
        if n.contains("push-up") || n.contains("push up") || n.contains("pushup") {
            if n.contains("pike") || n.contains("handstand") { return "overhead-push-bw-family" }
            return "push-up-family"
        }
        // Pulls
        if n.contains("pull-up") || n.contains("pull up") || n.contains("pullup") || n.contains("chin-up") || n.contains("chin up") || n.contains("muscle up") || n.contains("muscle-up") {
            return "pull-up-family"
        }
        if n.contains("pulldown") || n.contains("lat pull") {
            return "lat-pulldown-family"
        }
        if n.contains("pullover") {
            return "pullover-family"
        }
        if n.contains("row") && !n.contains("upright") {
            return "row-family"
        }
        if n.contains("shrug") {
            return "shrug-family"
        }
        // Shoulders
        if n.contains("lateral raise") || n.contains("side raise") || n.contains("side lateral") || n.contains("upright row") {
            return "lateral-raise-family"
        }
        if n.contains("shoulder press") || n.contains("military press") || n.contains("overhead press") || n.contains("arnold press") || n.contains("push press") {
            return "shoulder-press-family"
        }
        // Hinge
        if n.contains("deadlift") || n.contains("rdl") || n.contains("romanian") || n.contains("good morning") || n.contains("stiff leg") || n.contains("stiff-leg") {
            return "deadlift-family"
        }
        if n.contains("hip thrust") || n.contains("glute bridge") || n.contains("glute kickback") || n.contains("pull-through") || n.contains("pull through") {
            return "hip-thrust-family"
        }
        if n.contains("swing") && (n.contains("kettlebell") || n.contains("dumbbell")) {
            return "kettlebell-swing-family"
        }
        // Legs
        if n.contains("lunge") || n.contains("split squat") || n.contains("step-up") || n.contains("step up") {
            return "lunge-family"
        }
        if n.contains("squat") {
            if isBodyweight || n.contains("pistol") || n.contains("cossack") || n.contains("shrimp") || n.contains("hindu squat") || n.contains("dragon") {
                return "bw-squat-family"
            }
            return "squat-family"
        }
        if n.contains("leg curl") || n.contains("hamstring curl") || n.contains("nordic") {
            return "hamstring-curl-family"
        }
        if n.contains("leg extension") || n.contains("sissy") {
            return "quad-extension-family"
        }
        if n.contains("calf raise") || (primary == .calves && (n.contains("calf") || n.contains("heel raise"))) {
            return "calf-raise-family"
        }
        // Arms
        if n.contains("curl") && (primary == .biceps || n.contains("bicep") || n.contains("hammer") || n.contains("preacher") || n.contains("spider") || n.contains("concentration")) {
            return "bicep-curl-family"
        }
        if n.contains("tricep") || n.contains("skull") || n.contains("pushdown") || n.contains("overhead extension") || n.contains("jm press") || n.contains("kickback") {
            return "tricep-extension-family"
        }
        // Core
        if n.contains("plank") || n.contains("dead bug") || n.contains("bird dog") || n.contains("hollow") || n.contains("body saw") {
            return "plank-family"
        }
        if n.contains("crunch") || n.contains("sit-up") || n.contains("sit up") || n.contains("sitted") || n.contains("leg raise") || n.contains("v-up") || n.contains("v up") || n.contains("toe touch") || n.contains("flutter") || n.contains("bicycle crunch") {
            return "crunch-family"
        }
        if n.contains("twist") || n.contains("wood chop") || n.contains("woodchop") || n.contains("pallof") || n.contains("rotation") {
            return "rotation-family"
        }
        // Carries
        if n.contains("farmer") || n.contains("carry") {
            return "carry-family"
        }
        return nil
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
            if ["ez", "trx", "rdl", "tk", "jm"].contains(lower) { return lower.uppercased() }
            // Keep roman-like single letters uppercase when they follow a hyphen pattern
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
