import Foundation

// Evidence-style family priors.
//
// Conservative internal scoring of exercise families by structural
// usefulness. These are NOT scientific certainty — they are a reasonable
// starting bias so generation and swap ranking can do something sensible
// before personal response data exists. Once personal data accrues,
// `ExerciseResponseEngine` shifts rankings away from these defaults.

nonisolated struct ExerciseFamilyPrior: Sendable, Equatable {
    let familyId: String
    /// How loadable / progressable the family tends to be. `0 ... 1`.
    let loadability: Double
    /// How stable and repeatable the technique is across sessions. `0 ... 1`.
    let stability: Double
    /// Hypertrophy suitability. `0 ... 1`.
    let hypertrophySuitability: Double
    /// Relative systemic/local fatigue cost per productive set. `0 ... 1`.
    /// Higher = more expensive.
    let fatigueCost: Double
    /// Joint-friendliness for the general population. `0 ... 1`.
    let jointFriendliness: Double
    /// Skill demand. `0 ... 1`. Higher = more coaching / practice required.
    let skillDemand: Double
    /// How well the family survives home / limited-equipment contexts. `0 ... 1`.
    let homeCompatibility: Double
}

nonisolated enum ExerciseFamilyPriorsCatalog {
    /// Prior for a curated family id. Returns a neutral default for unknown
    /// or imported-only family ids so nothing crashes on lookup.
    static func prior(forFamily familyId: String) -> ExerciseFamilyPrior {
        if let p = priors[familyId] { return p }
        return neutral(familyId: familyId)
    }

    static func neutral(familyId: String) -> ExerciseFamilyPrior {
        ExerciseFamilyPrior(
            familyId: familyId,
            loadability: 0.5,
            stability: 0.5,
            hypertrophySuitability: 0.5,
            fatigueCost: 0.5,
            jointFriendliness: 0.5,
            skillDemand: 0.5,
            homeCompatibility: 0.5
        )
    }

    private static let priors: [String: ExerciseFamilyPrior] = [
        "bench-press-family":        .init(familyId: "bench-press-family",        loadability: 0.85, stability: 0.80, hypertrophySuitability: 0.85, fatigueCost: 0.55, jointFriendliness: 0.50, skillDemand: 0.55, homeCompatibility: 0.30),
        "incline-press-family":      .init(familyId: "incline-press-family",      loadability: 0.75, stability: 0.75, hypertrophySuitability: 0.85, fatigueCost: 0.55, jointFriendliness: 0.55, skillDemand: 0.55, homeCompatibility: 0.30),
        "chest-fly-family":          .init(familyId: "chest-fly-family",          loadability: 0.40, stability: 0.75, hypertrophySuitability: 0.80, fatigueCost: 0.35, jointFriendliness: 0.70, skillDemand: 0.35, homeCompatibility: 0.40),
        "push-up-family":            .init(familyId: "push-up-family",            loadability: 0.40, stability: 0.80, hypertrophySuitability: 0.55, fatigueCost: 0.35, jointFriendliness: 0.70, skillDemand: 0.35, homeCompatibility: 1.00),
        "dip-family":                .init(familyId: "dip-family",                loadability: 0.65, stability: 0.65, hypertrophySuitability: 0.75, fatigueCost: 0.60, jointFriendliness: 0.35, skillDemand: 0.55, homeCompatibility: 0.35),
        "pull-up-family":            .init(familyId: "pull-up-family",            loadability: 0.65, stability: 0.70, hypertrophySuitability: 0.80, fatigueCost: 0.55, jointFriendliness: 0.55, skillDemand: 0.55, homeCompatibility: 0.70),
        "lat-pulldown-family":       .init(familyId: "lat-pulldown-family",       loadability: 0.70, stability: 0.85, hypertrophySuitability: 0.80, fatigueCost: 0.35, jointFriendliness: 0.80, skillDemand: 0.30, homeCompatibility: 0.25),
        "row-family":                .init(familyId: "row-family",                loadability: 0.80, stability: 0.75, hypertrophySuitability: 0.85, fatigueCost: 0.55, jointFriendliness: 0.60, skillDemand: 0.50, homeCompatibility: 0.40),
        "pullover-family":           .init(familyId: "pullover-family",           loadability: 0.40, stability: 0.70, hypertrophySuitability: 0.65, fatigueCost: 0.35, jointFriendliness: 0.70, skillDemand: 0.45, homeCompatibility: 0.40),
        "rear-delt-family":          .init(familyId: "rear-delt-family",          loadability: 0.30, stability: 0.80, hypertrophySuitability: 0.70, fatigueCost: 0.25, jointFriendliness: 0.85, skillDemand: 0.30, homeCompatibility: 0.65),
        "shoulder-press-family":     .init(familyId: "shoulder-press-family",     loadability: 0.75, stability: 0.70, hypertrophySuitability: 0.75, fatigueCost: 0.60, jointFriendliness: 0.45, skillDemand: 0.55, homeCompatibility: 0.35),
        "lateral-raise-family":      .init(familyId: "lateral-raise-family",      loadability: 0.30, stability: 0.85, hypertrophySuitability: 0.85, fatigueCost: 0.25, jointFriendliness: 0.80, skillDemand: 0.30, homeCompatibility: 0.65),
        "overhead-push-bw-family":   .init(familyId: "overhead-push-bw-family",   loadability: 0.35, stability: 0.55, hypertrophySuitability: 0.55, fatigueCost: 0.55, jointFriendliness: 0.45, skillDemand: 0.70, homeCompatibility: 1.00),
        "squat-family":              .init(familyId: "squat-family",              loadability: 0.90, stability: 0.65, hypertrophySuitability: 0.85, fatigueCost: 0.85, jointFriendliness: 0.45, skillDemand: 0.70, homeCompatibility: 0.35),
        "lunge-family":              .init(familyId: "lunge-family",              loadability: 0.60, stability: 0.55, hypertrophySuitability: 0.75, fatigueCost: 0.65, jointFriendliness: 0.55, skillDemand: 0.55, homeCompatibility: 0.70),
        "bw-squat-family":           .init(familyId: "bw-squat-family",           loadability: 0.30, stability: 0.55, hypertrophySuitability: 0.55, fatigueCost: 0.50, jointFriendliness: 0.60, skillDemand: 0.70, homeCompatibility: 1.00),
        "deadlift-family":           .init(familyId: "deadlift-family",           loadability: 0.95, stability: 0.60, hypertrophySuitability: 0.70, fatigueCost: 0.95, jointFriendliness: 0.35, skillDemand: 0.80, homeCompatibility: 0.30),
        "hip-thrust-family":         .init(familyId: "hip-thrust-family",         loadability: 0.75, stability: 0.75, hypertrophySuitability: 0.85, fatigueCost: 0.45, jointFriendliness: 0.75, skillDemand: 0.40, homeCompatibility: 0.40),
        "hamstring-curl-family":     .init(familyId: "hamstring-curl-family",     loadability: 0.55, stability: 0.85, hypertrophySuitability: 0.75, fatigueCost: 0.30, jointFriendliness: 0.80, skillDemand: 0.25, homeCompatibility: 0.25),
        "quad-extension-family":     .init(familyId: "quad-extension-family",     loadability: 0.55, stability: 0.85, hypertrophySuitability: 0.70, fatigueCost: 0.30, jointFriendliness: 0.65, skillDemand: 0.25, homeCompatibility: 0.25),
        "calf-raise-family":         .init(familyId: "calf-raise-family",         loadability: 0.55, stability: 0.85, hypertrophySuitability: 0.70, fatigueCost: 0.25, jointFriendliness: 0.80, skillDemand: 0.20, homeCompatibility: 0.55),
        "bicep-curl-family":         .init(familyId: "bicep-curl-family",         loadability: 0.45, stability: 0.85, hypertrophySuitability: 0.80, fatigueCost: 0.25, jointFriendliness: 0.80, skillDemand: 0.25, homeCompatibility: 0.55),
        "tricep-extension-family":   .init(familyId: "tricep-extension-family",   loadability: 0.45, stability: 0.80, hypertrophySuitability: 0.75, fatigueCost: 0.30, jointFriendliness: 0.70, skillDemand: 0.30, homeCompatibility: 0.50),
        "plank-family":              .init(familyId: "plank-family",              loadability: 0.20, stability: 0.85, hypertrophySuitability: 0.35, fatigueCost: 0.25, jointFriendliness: 0.85, skillDemand: 0.35, homeCompatibility: 1.00),
        "crunch-family":             .init(familyId: "crunch-family",             loadability: 0.30, stability: 0.80, hypertrophySuitability: 0.55, fatigueCost: 0.25, jointFriendliness: 0.70, skillDemand: 0.25, homeCompatibility: 0.85),
        "rotation-family":           .init(familyId: "rotation-family",           loadability: 0.35, stability: 0.75, hypertrophySuitability: 0.45, fatigueCost: 0.30, jointFriendliness: 0.80, skillDemand: 0.45, homeCompatibility: 0.75),
        "pilates-core-family":       .init(familyId: "pilates-core-family",       loadability: 0.20, stability: 0.75, hypertrophySuitability: 0.40, fatigueCost: 0.25, jointFriendliness: 0.85, skillDemand: 0.55, homeCompatibility: 1.00),
        "shrug-family":              .init(familyId: "shrug-family",              loadability: 0.70, stability: 0.85, hypertrophySuitability: 0.70, fatigueCost: 0.30, jointFriendliness: 0.75, skillDemand: 0.25, homeCompatibility: 0.45),
        "carry-family":              .init(familyId: "carry-family",              loadability: 0.70, stability: 0.65, hypertrophySuitability: 0.40, fatigueCost: 0.55, jointFriendliness: 0.65, skillDemand: 0.35, homeCompatibility: 0.50),
        "kettlebell-swing-family":   .init(familyId: "kettlebell-swing-family",   loadability: 0.55, stability: 0.60, hypertrophySuitability: 0.50, fatigueCost: 0.60, jointFriendliness: 0.55, skillDemand: 0.60, homeCompatibility: 0.75),
    ]
}

/// Goal-weighted score derived from the prior. Used as a starting bias for
/// plan generation before personal response data exists. Return value is
/// centered around 0 so it can be added to existing heuristic scores.
nonisolated enum ExerciseFamilyPriorScoring {
    static func score(prior: ExerciseFamilyPrior, goal: FitnessGoal, isHome: Bool) -> Double {
        var s: Double = 0

        switch goal {
        case .strength:
            s += (prior.loadability - 0.5) * 12
            s += (prior.stability - 0.5) * 6
            s -= (prior.skillDemand - 0.5) * 2
        case .muscleGain:
            s += (prior.hypertrophySuitability - 0.5) * 12
            s += (prior.stability - 0.5) * 4
            s -= (prior.fatigueCost - 0.5) * 4
        case .fatLoss, .generalFitness:
            s += (prior.hypertrophySuitability - 0.5) * 6
            s += (prior.jointFriendliness - 0.5) * 4
            s -= (prior.fatigueCost - 0.5) * 4
        case .athleticPerformance:
            s += (prior.loadability - 0.5) * 8
            s += (prior.hypertrophySuitability - 0.5) * 4
        case .endurance:
            s += (prior.stability - 0.5) * 4
            s -= (prior.fatigueCost - 0.5) * 6
        case .flexibility, .rehabilitation:
            s += (prior.jointFriendliness - 0.5) * 10
            s -= (prior.fatigueCost - 0.5) * 6
            s -= (prior.skillDemand - 0.5) * 4
        }

        if isHome {
            s += (prior.homeCompatibility - 0.5) * 8
        }

        return s
    }
}
