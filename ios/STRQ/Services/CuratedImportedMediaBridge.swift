import Foundation

/// Bridges curated STRQ exercises to ExerciseDBPro GIFs when a strong match
/// exists in the same curated family. Strict quality-gates prevent wrong
/// mappings: curated and imported must share the same family and the same
/// equipment class, and must agree on at least one movement noun.
///
/// A canonical-lift path allows well-known base lifts (bench press, overhead
/// press, pullover, etc.) to resolve through a single noun + equipment class
/// match when the curated name is short — this fixes the case where a
/// 2-token curated name could not reach the 2-token overlap bar against a
/// longer imported variant.
///
/// Synonym expansion unifies common naming pairs (overhead ↔ shoulder,
/// pull-up ↔ chin-up, etc.) so canonical lifts reliably inherit coverage
/// without opening the door to cross-family mismatches.
///
/// Built once at first access and cached in memory. Safe to call from any
/// thread — purely data-driven and immutable.
nonisolated final class CuratedImportedMediaBridge: Sendable {
    static let shared = CuratedImportedMediaBridge()

    private let urlByCuratedId: [String: URL]
    private let diagnostics: [String: Diagnostic]

    var coverageCount: Int { urlByCuratedId.count }

    private init() {
        let importer = ExerciseDBProImporter.shared
        let familyService = ExerciseFamilyService.shared
        let curated = ExerciseLibrary.shared.exercises
        var result: [String: URL] = [:]
        var diags: [String: Diagnostic] = [:]
        result.reserveCapacity(curated.count)
        diags.reserveCapacity(curated.count)

        for ex in curated {
            let outcome = Self.resolve(for: ex, familyService: familyService, importer: importer)
            diags[ex.id] = outcome.diagnostic
            if let url = outcome.url { result[ex.id] = url }
        }
        self.urlByCuratedId = result
        self.diagnostics = diags
    }

    /// Remote GIF URL for a curated exercise when a high-confidence imported
    /// sibling exists in the same family. Returns nil for imported ids
    /// (they already resolve through `ExerciseCatalog.gifURL`).
    func gifURL(forCuratedId id: String) -> URL? {
        guard !id.hasPrefix(Self.importedPrefix) else { return nil }
        return urlByCuratedId[id]
    }

    // MARK: - Diagnostics

    struct Diagnostic: Sendable {
        let curatedId: String
        let curatedName: String
        let familyId: String?
        let equipmentClass: String
        let importedCandidateCount: Int
        let equipmentRejections: Int
        let nounRejections: Int
        let overlapRejections: Int
        let matchedImportedName: String?
        let matchedOverlap: Int
        let matchStrategy: String?
        let reason: String
    }

    /// Returns the diagnostic record for a curated exercise id — explains why
    /// the bridge did or did not assign imported media. Internal-only; safe
    /// to call from any thread.
    func diagnostic(forCuratedId id: String) -> Diagnostic? {
        diagnostics[id]
    }

    /// Canonical lifts we expect to inherit imported media. Used by
    /// `canonicalCoverageReport()` to verify media inheritance after changes.
    static let canonicalLiftIds: [String] = [
        "barbell-bench-press",
        "dumbbell-bench-press",
        "machine-chest-press",
        "incline-barbell-press",
        "incline-dumbbell-press",
        "overhead-press",
        "dumbbell-shoulder-press",
        "machine-shoulder-press",
        "lateral-raise",
        "barbell-row",
        "dumbbell-row",
        "seated-cable-row",
        "lat-pulldown",
        "cable-pullover",
        "dumbbell-pullover",
        "barbell-squat",
        "leg-press",
        "romanian-deadlift",
        "deadlift",
        "hip-thrust",
        "leg-extension",
        "leg-curl",
        "barbell-curl",
        "dumbbell-curl",
        "hammer-curl",
        "tricep-pushdown",
        "face-pull",
        "cable-chest-fly"
    ]

    /// Coverage snapshot for canonical lifts — pairs of `(curatedId, hasMedia)`.
    /// Use to catch regressions after tweaking matching heuristics.
    func canonicalCoverageReport() -> [(String, Bool)] {
        Self.canonicalLiftIds.map { id in (id, urlByCuratedId[id] != nil) }
    }

    // MARK: - Resolution

    private struct Resolution {
        let url: URL?
        let diagnostic: Diagnostic
    }

    private static func resolve(
        for ex: Exercise,
        familyService: ExerciseFamilyService,
        importer: ExerciseDBProImporter
    ) -> Resolution {
        let eqClass = equipmentClass(ex)
        guard let family = familyService.family(forExercise: ex.id) else {
            return Resolution(
                url: nil,
                diagnostic: Diagnostic(
                    curatedId: ex.id, curatedName: ex.name, familyId: nil,
                    equipmentClass: eqClass.rawValue, importedCandidateCount: 0,
                    equipmentRejections: 0, nounRejections: 0, overlapRejections: 0,
                    matchedImportedName: nil, matchedOverlap: 0, matchStrategy: nil,
                    reason: "no curated family assignment"
                )
            )
        }
        let imported = familyService.importedMembers(for: family.id)
        guard !imported.isEmpty else {
            return Resolution(
                url: nil,
                diagnostic: Diagnostic(
                    curatedId: ex.id, curatedName: ex.name, familyId: family.id,
                    equipmentClass: eqClass.rawValue, importedCandidateCount: 0,
                    equipmentRejections: 0, nounRejections: 0, overlapRejections: 0,
                    matchedImportedName: nil, matchedOverlap: 0, matchStrategy: nil,
                    reason: "no imported siblings in family"
                )
            )
        }

        let curatedTokens = tokens(from: ex.name)
        let expandedCurated = expandSynonyms(curatedTokens)
        let curatedNouns = expandedCurated.intersection(movementNouns)

        var equipmentRejections = 0
        var nounRejections = 0
        var overlapRejections = 0
        var bestMatch: (exercise: Exercise, score: Int, overlap: Int, strategy: String)?

        for imp in imported {
            guard equipmentClass(imp) == eqClass else {
                equipmentRejections += 1
                continue
            }
            let impTokens = expandSynonyms(tokens(from: imp.name))
            let sharedNoun = !curatedNouns.isDisjoint(with: impTokens)
            guard sharedNoun else {
                nounRejections += 1
                continue
            }
            let overlap = expandedCurated.intersection(impTokens).count

            // Canonical-lift path: short curated names (≤3 tokens) can match a
            // single-noun imported sibling when the curated name has no tokens
            // left beyond the shared noun(s) + equipment-implied qualifier.
            let curatedCount = expandedCurated.count
            let isCanonicalShort = curatedCount <= 3 && overlap >= 1
            let passesOverlap = overlap >= 2 || isCanonicalShort
            guard passesOverlap else {
                overlapRejections += 1
                continue
            }

            // Scoring: token overlap dominates, then prefer less noisy names,
            // and a small canonical bonus when the imported sibling is
            // structurally close (few extra tokens) to the curated name.
            let strategy = overlap >= 2 ? "overlap" : "canonical-short"
            let lengthPenalty = abs(curatedCount - impTokens.count)
            let score = overlap * 10 - lengthPenalty

            if bestMatch == nil || score > bestMatch!.score {
                bestMatch = (imp, score, overlap, strategy)
            }
        }

        guard let match = bestMatch,
              match.exercise.id.hasPrefix(importedPrefix) else {
            let reason: String
            if equipmentRejections == imported.count {
                reason = "equipment-class mismatch across all siblings"
            } else if nounRejections > 0 && bestMatch == nil {
                reason = "no shared movement noun"
            } else if overlapRejections > 0 && bestMatch == nil {
                reason = "name token overlap below threshold"
            } else {
                reason = "no confident sibling"
            }
            return Resolution(
                url: nil,
                diagnostic: Diagnostic(
                    curatedId: ex.id, curatedName: ex.name, familyId: family.id,
                    equipmentClass: eqClass.rawValue,
                    importedCandidateCount: imported.count,
                    equipmentRejections: equipmentRejections,
                    nounRejections: nounRejections,
                    overlapRejections: overlapRejections,
                    matchedImportedName: nil, matchedOverlap: 0,
                    matchStrategy: nil, reason: reason
                )
            )
        }

        let rawId = String(match.exercise.id.dropFirst(importedPrefix.count))
        guard let raw = importer.remoteGifURL(for: rawId),
              let url = URL(string: raw) else {
            return Resolution(
                url: nil,
                diagnostic: Diagnostic(
                    curatedId: ex.id, curatedName: ex.name, familyId: family.id,
                    equipmentClass: eqClass.rawValue,
                    importedCandidateCount: imported.count,
                    equipmentRejections: equipmentRejections,
                    nounRejections: nounRejections,
                    overlapRejections: overlapRejections,
                    matchedImportedName: match.exercise.name,
                    matchedOverlap: match.overlap,
                    matchStrategy: match.strategy,
                    reason: "matched sibling has no remote GIF"
                )
            )
        }

        return Resolution(
            url: url,
            diagnostic: Diagnostic(
                curatedId: ex.id, curatedName: ex.name, familyId: family.id,
                equipmentClass: eqClass.rawValue,
                importedCandidateCount: imported.count,
                equipmentRejections: equipmentRejections,
                nounRejections: nounRejections,
                overlapRejections: overlapRejections,
                matchedImportedName: match.exercise.name,
                matchedOverlap: match.overlap,
                matchStrategy: match.strategy,
                reason: "matched"
            )
        )
    }

    // MARK: - Matching helpers

    private static let importedPrefix = "edb-"

    private static let stopwords: Set<String> = [
        "the", "a", "an", "with", "and", "of", "on", "in", "to", "for"
    ]

    /// Movement nouns used as a hard filter so a "curl" never matches a
    /// "press" just because they share equipment tokens.
    private static let movementNouns: Set<String> = [
        "press", "bench", "squat", "deadlift", "rdl", "row", "curl", "raise",
        "pulldown", "fly", "extension", "pushdown", "pull", "push", "dip",
        "lunge", "plank", "crunch", "bridge", "thrust", "shrug", "carry",
        "twist", "swing", "kickback", "pullover", "chin", "hinge", "hold",
        "fold", "reach", "stretch", "rotation", "calf", "goodmorning",
        "thruster", "snatch", "clean", "jerk"
    ]

    /// Token-level synonym groups. When any token in a group is present the
    /// whole group is added — this lets "overhead press" match "shoulder
    /// press", "chin-up" match "pull-up", etc., without weakening the
    /// family/equipment-class hard filters.
    private static let synonymGroups: [Set<String>] = [
        ["overhead", "shoulder"],
        ["bench", "barbellbench"],
        ["pulldown", "latpulldown"],
        ["pullup", "chinup"],
        ["db", "dumbbell"],
        ["bb", "barbell"],
        ["rdl", "romanian", "stifflegged", "stiffleg"],
        ["glutebridge", "hipthrust"]
    ]

    private static func tokens(from name: String) -> Set<String> {
        let lowered = name.lowercased()
            .replacingOccurrences(of: "-", with: " ")
            .replacingOccurrences(of: "/", with: " ")
        let parts = lowered.split { !$0.isLetter }
        var out: Set<String> = []
        for part in parts {
            let s = String(part)
            guard s.count >= 2, !stopwords.contains(s) else { continue }
            out.insert(s)
        }
        return out
    }

    /// Expands a token set with synonym-group members so canonical lifts match
    /// their common naming variants without cross-family risk.
    private static func expandSynonyms(_ set: Set<String>) -> Set<String> {
        var out = set
        for group in synonymGroups where !group.isDisjoint(with: set) {
            out.formUnion(group)
        }
        return out
    }

    private enum EquipClass: String, Hashable {
        case barbell, smith, dumbbell, kettlebell, cable, machine, band, bodyweight, other
    }

    private static func equipmentClass(_ ex: Exercise) -> EquipClass {
        let eq = ex.equipment
        if ex.isBodyweight || eq.isEmpty || eq == [.none] { return .bodyweight }
        if eq.contains(.barbell) { return .barbell }
        if eq.contains(.smithMachine) { return .smith }
        if eq.contains(.dumbbell) { return .dumbbell }
        if eq.contains(.kettlebell) { return .kettlebell }
        if eq.contains(.cable) { return .cable }
        if eq.contains(.machine) { return .machine }
        if eq.contains(.resistanceBand) { return .band }
        return .other
    }
}
