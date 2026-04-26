import Foundation

// Personal exercise-family response layer.
//
// Tracks how well each curated exercise family works for THIS user so plan
// generation and swap ranking can gradually prefer families that progress
// well, are better tolerated, and are actually adhered to — and demote the
// families that cost too much fatigue for the stimulus they deliver.
//
// Signals are conservative by design: low data → low confidence → near-zero
// adjustment. Strong effects only emerge once enough real exposures exist.

nonisolated struct PersonalExerciseResponse: Codable, Sendable, Equatable {
    /// Curated family id (see `ExerciseFamilyService`).
    var familyId: String

    /// Progression signal for this family. Range `-1 ... 1`.
    /// Positive = user keeps progressing on this family.
    /// Negative = user stalls / regresses on this family.
    var progressionSignal: Double

    /// Fatigue cost for this family. Range `0 ... 1`.
    /// Higher = more recovery cost per unit stimulus.
    var fatigueCost: Double

    /// Joint tolerance for this family. Range `-1 ... 1`.
    /// Positive = well tolerated.
    /// Negative = repeated grinder / form-breakdown / pain markers.
    var jointTolerance: Double

    /// Adherence score for this family. Range `0 ... 1`.
    /// Fraction of planned sets that the user actually logged as completed
    /// when this family appeared in recent sessions.
    var adherenceScore: Double

    /// Confidence in all of the above. Range `0 ... 1`.
    /// Driven by total exposures and recency.
    var confidence: Double

    /// Number of completed sessions that touched this family.
    var sessionCount: Int

    /// Sessions in the last ~21 days — used by `recentExposure` gating.
    var recentExposure: Int

    /// When this response was last computed.
    var lastUpdated: Date

    init(
        familyId: String,
        progressionSignal: Double = 0,
        fatigueCost: Double = 0.5,
        jointTolerance: Double = 0,
        adherenceScore: Double = 1.0,
        confidence: Double = 0,
        sessionCount: Int = 0,
        recentExposure: Int = 0,
        lastUpdated: Date = Date()
    ) {
        self.familyId = familyId
        self.progressionSignal = progressionSignal
        self.fatigueCost = fatigueCost
        self.jointTolerance = jointTolerance
        self.adherenceScore = adherenceScore
        self.confidence = confidence
        self.sessionCount = sessionCount
        self.recentExposure = recentExposure
        self.lastUpdated = lastUpdated
    }

    enum CodingKeys: String, CodingKey {
        case familyId, progressionSignal, fatigueCost, jointTolerance
        case adherenceScore, confidence, sessionCount, recentExposure, lastUpdated
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        self.familyId = try c.decodeIfPresent(String.self, forKey: .familyId) ?? ""
        self.progressionSignal = try c.decodeIfPresent(Double.self, forKey: .progressionSignal) ?? 0
        self.fatigueCost = try c.decodeIfPresent(Double.self, forKey: .fatigueCost) ?? 0.5
        self.jointTolerance = try c.decodeIfPresent(Double.self, forKey: .jointTolerance) ?? 0
        self.adherenceScore = try c.decodeIfPresent(Double.self, forKey: .adherenceScore) ?? 1.0
        self.confidence = try c.decodeIfPresent(Double.self, forKey: .confidence) ?? 0
        self.sessionCount = try c.decodeIfPresent(Int.self, forKey: .sessionCount) ?? 0
        self.recentExposure = try c.decodeIfPresent(Int.self, forKey: .recentExposure) ?? 0
        self.lastUpdated = try c.decodeIfPresent(Date.self, forKey: .lastUpdated) ?? Date()
    }

    /// Minimum exposures before this response is allowed to meaningfully
    /// nudge plan generation or swap ranking.
    static let confidenceThresholdSessions: Int = 3

    /// Exposures needed before confidence saturates.
    static let confidenceSaturationSessions: Int = 10

    var hasUsableData: Bool {
        sessionCount >= Self.confidenceThresholdSessions && confidence > 0.2
    }
}

nonisolated struct ExerciseFamilyResponseProfile: Codable, Sendable, Equatable {
    /// Keyed by curated family id.
    var familyResponses: [String: PersonalExerciseResponse]
    var lastUpdated: Date

    init(
        familyResponses: [String: PersonalExerciseResponse] = [:],
        lastUpdated: Date = Date()
    ) {
        self.familyResponses = familyResponses
        self.lastUpdated = lastUpdated
    }

    enum CodingKeys: String, CodingKey {
        case familyResponses, lastUpdated
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        self.familyResponses = try c.decodeIfPresent([String: PersonalExerciseResponse].self, forKey: .familyResponses) ?? [:]
        self.lastUpdated = try c.decodeIfPresent(Date.self, forKey: .lastUpdated) ?? Date()
    }

    static let empty: ExerciseFamilyResponseProfile = .init()

    func response(forFamily familyId: String) -> PersonalExerciseResponse? {
        familyResponses[familyId]
    }

    /// Compact debug summary — useful for internal harness and logging.
    var debugSummary: String {
        guard !familyResponses.isEmpty else { return "ExerciseFamilyResponseProfile(empty)" }
        let top = familyResponses.values
            .sorted { $0.confidence > $1.confidence }
            .prefix(6)
            .map { r in
                String(
                    format: "%@: prog=%+.2f fat=%.2f tol=%+.2f adh=%.2f conf=%.2f n=%d",
                    r.familyId, r.progressionSignal, r.fatigueCost,
                    r.jointTolerance, r.adherenceScore, r.confidence, r.sessionCount
                )
            }
            .joined(separator: "\n  ")
        return "ExerciseFamilyResponseProfile(n=\(familyResponses.count))\n  \(top)"
    }
}
