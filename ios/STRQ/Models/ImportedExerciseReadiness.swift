import Foundation

/// Activation tiers for imported (ExerciseDBPro) exercises. Curated STRQ
/// exercises are always treated as canonical and do not carry a tier.
///
/// Higher tiers imply all lower tiers — a `.generation` exercise is also
/// safe for progression chains, substitution, and manual use.
nonisolated enum ImportedReadinessTier: Int, Sendable, Comparable, Codable {
    /// Appears in Library / Detail only. Never suggested by coaching logic.
    case catalogOnly = 0
    /// Safe when a user manually chooses it in Add / Swap.
    case manualOnly = 1
    /// Safe for coach-suggested swap / substitution.
    case substitution = 2
    /// Safe to participate in progression / regression chains.
    case progression = 3
    /// Safe for curated plan generation.
    case generation = 4

    static func < (lhs: Self, rhs: Self) -> Bool { lhs.rawValue < rhs.rawValue }

    var label: String {
        switch self {
        case .catalogOnly: "Catalog only"
        case .manualOnly: "Manual only"
        case .substitution: "Substitution"
        case .progression: "Progression"
        case .generation: "Generation"
        }
    }
}

/// Deterministic quality signal for a single imported exercise. The score
/// aggregates family / pattern / equipment / role / naming factors and maps
/// to an `ImportedReadinessTier`.
///
/// `gaps` describes what keeps the exercise from a higher tier so the system
/// can reason about promotion candidates without exposing raw internals to
/// users.
nonisolated struct ImportedReadinessScore: Sendable {
    let exerciseId: String
    let score: Double
    let tier: ImportedReadinessTier
    let hasFamily: Bool
    let factors: [String]
    let gaps: [String]
    let roleFit: Set<ImportedRoleFit>
}

nonisolated enum ImportedRoleFit: String, Sendable, Codable, CaseIterable {
    case anchor
    case secondary
    case accessory
    case isolation
    case mobility
}
