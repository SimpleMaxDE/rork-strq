import Foundation

/// Quality-gated activation layer for imported (ExerciseDBPro) exercises.
///
/// Imported exercises are cataloged freely, but are only promoted into
/// STRQ coaching logic (swap suggestions, progression chains, eventual plan
/// generation) when their readiness score is high enough for that tier.
///
/// Curated STRQ exercises are always canonical and bypass this gate.
nonisolated final class ImportedExerciseReadinessService: Sendable {
    static let shared = ImportedExerciseReadinessService()

    private let scores: [String: ImportedReadinessScore]

    private init() {
        let importer = ExerciseDBProImporter.shared
        let familyAssignments = importer.familyAssignments
        var map: [String: ImportedReadinessScore] = [:]
        map.reserveCapacity(importer.exercises.count)
        for exercise in importer.exercises {
            let familyId = familyAssignments[exercise.id]
            map[exercise.id] = Self.evaluate(exercise: exercise, familyId: familyId)
        }
        self.scores = map
    }

    // MARK: - Public API

    func score(for exerciseId: String) -> ImportedReadinessScore? {
        scores[exerciseId]
    }

    /// Returns the activation tier for any exercise id. Curated STRQ
    /// exercises return `.generation` (canonical, always available). Imported
    /// exercises return their computed tier. Unknown ids return `.catalogOnly`.
    func tier(for exerciseId: String) -> ImportedReadinessTier {
        if !exerciseId.hasPrefix("edb-") { return .generation }
        return scores[exerciseId]?.tier ?? .catalogOnly
    }

    /// Whether an exercise is safe for coach-suggested swap / substitution.
    func isEligibleForSubstitution(_ exerciseId: String) -> Bool {
        tier(for: exerciseId) >= .substitution
    }

    /// Whether an exercise can participate in progression / regression chains.
    func isEligibleForProgression(_ exerciseId: String) -> Bool {
        tier(for: exerciseId) >= .progression
    }

    /// Whether an exercise can enter plan generation.
    func isEligibleForGeneration(_ exerciseId: String) -> Bool {
        tier(for: exerciseId) >= .generation
    }

    func roleFit(for exerciseId: String) -> Set<ImportedRoleFit> {
        scores[exerciseId]?.roleFit ?? []
    }

    /// Imported exercises grouped by their assigned tier. Useful for future
    /// curation tooling.
    func byTier() -> [ImportedReadinessTier: [String]] {
        var out: [ImportedReadinessTier: [String]] = [:]
        for (id, score) in scores {
            out[score.tier, default: []].append(id)
        }
        return out
    }

    // MARK: - Scoring

    private static func evaluate(exercise: Exercise, familyId: String?) -> ImportedReadinessScore {
        var score: Double = 0
        var factors: [String] = []
        var gaps: [String] = []

        // Family assignment is the single strongest quality signal — it means
        // the importer could confidently map this movement onto a curated family.
        let hasFamily = familyId != nil
        if hasFamily {
            score += 30
            factors.append("Curated family match")
        } else {
            gaps.append("No curated family match")
        }

        // Equipment clarity.
        let realEquipment = exercise.equipment.filter { $0 != .none }
        if !realEquipment.isEmpty || exercise.isBodyweight {
            score += 10
            factors.append("Equipment resolved")
        } else {
            gaps.append("Ambiguous equipment")
        }

        // Movement-pattern confidence: patterns that fell through to a muscle
        // heuristic tend to be weakest. Primary compound patterns are strong.
        switch exercise.movementPattern {
        case .squat, .hipHinge, .horizontalPush, .verticalPush, .horizontalPull, .verticalPull, .lunge, .carry:
            score += 10
            factors.append("Primary movement pattern")
        case .flexion, .extension_, .abduction, .adduction, .rotation, .antiRotation, .isometric:
            score += 6
        case .plyometric, .locomotion:
            score += 2
        }

        // Instruction quality — at least 2 cleaned steps makes detail surfaces
        // look legitimate.
        if exercise.instructions.count >= 2 {
            score += 6
            factors.append("Has execution steps")
        } else {
            gaps.append("Thin instructions")
        }

        // Naming quality — cleanup already stripped gender tags / version noise.
        // Penalize anything still noisy.
        let name = exercise.name
        if name.count < 4 || name.rangeOfCharacter(from: .decimalDigits) != nil {
            gaps.append("Name quality low")
            score -= 6
        } else {
            score += 4
        }

        // Category confidence — mobility / warmup / cardio get capped at
        // manual use to avoid diluting strength coaching suggestions.
        let categoryCap: ImportedReadinessTier? = {
            switch exercise.category {
            case .mobility, .warmup, .recovery, .cardio: return .manualOnly
            case .compound, .isolation, .bodyweight, .pilates: return nil
            }
        }()

        // Role fit — derived deterministically from category + pattern + muscle.
        var roles: Set<ImportedRoleFit> = []
        switch exercise.category {
        case .compound:
            roles.insert(.anchor)
            roles.insert(.secondary)
        case .isolation:
            roles.insert(.accessory)
            roles.insert(.isolation)
        case .bodyweight:
            roles.insert(.accessory)
            if exercise.progressionLevel == .progression {
                roles.insert(.secondary)
            }
        case .mobility, .warmup, .recovery:
            roles.insert(.mobility)
        case .pilates:
            roles.insert(.accessory)
        case .cardio:
            break
        }
        if !roles.isEmpty {
            score += 6
            factors.append("Role fit assigned")
        } else {
            gaps.append("No strong role fit")
        }

        // Joint-friendliness for isolations is a mild plus.
        if exercise.isJointFriendly && (exercise.category == .isolation || exercise.category == .bodyweight) {
            score += 2
        }

        // Difficulty extremes weaken generator eligibility.
        let generationBlocked = exercise.difficulty == .advanced && !hasFamily

        // Map to tier.
        var tier: ImportedReadinessTier
        switch score {
        case ..<15: tier = .catalogOnly
        case 15..<28: tier = .manualOnly
        case 28..<42: tier = .substitution
        case 42..<55: tier = .progression
        default: tier = .generation
        }

        if let cap = categoryCap, tier > cap { tier = cap }
        if generationBlocked && tier > .progression { tier = .progression }

        // A family match is required for anything above manual-only —
        // prevents unfamilied imports from polluting swap suggestions.
        if !hasFamily && tier > .manualOnly {
            tier = .manualOnly
            gaps.append("Family required for coaching use")
        }

        return ImportedReadinessScore(
            exerciseId: exercise.id,
            score: score,
            tier: tier,
            hasFamily: hasFamily,
            factors: factors,
            gaps: gaps,
            roleFit: roles
        )
    }
}
