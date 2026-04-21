import Foundation

/// Bridges curated STRQ exercises to ExerciseDBPro GIFs when a strong match
/// exists in the same curated family. Strictly quality-gated: curated exercise
/// and imported sibling must share the same family, the same equipment class,
/// a movement noun, and have ≥2 name tokens overlap. When no confident match
/// exists the curated exercise keeps its gradient + SF Symbol fallback — a
/// wrong GIF would be worse than no GIF.
///
/// Built once at first access and cached in memory. Safe to call from any
/// thread — purely data-driven and immutable.
nonisolated final class CuratedImportedMediaBridge: Sendable {
    static let shared = CuratedImportedMediaBridge()

    private let urlByCuratedId: [String: URL]

    var coverageCount: Int { urlByCuratedId.count }

    private init() {
        let importer = ExerciseDBProImporter.shared
        let familyService = ExerciseFamilyService.shared
        let curated = ExerciseLibrary.shared.exercises
        var result: [String: URL] = [:]
        result.reserveCapacity(curated.count)

        for ex in curated {
            guard let family = familyService.family(forExercise: ex.id) else { continue }
            let imported = familyService.importedMembers(for: family.id)
            guard !imported.isEmpty else { continue }

            let curatedTokens = Self.tokens(from: ex.name)
            let curatedClass = Self.equipmentClass(ex)
            let curatedNouns = curatedTokens.intersection(Self.movementNouns)

            var bestMatch: (exercise: Exercise, score: Int)?
            for imp in imported {
                guard Self.equipmentClass(imp) == curatedClass else { continue }
                let impTokens = Self.tokens(from: imp.name)
                let sharedNoun = !curatedNouns.isDisjoint(with: impTokens)
                guard sharedNoun else { continue }
                let overlap = curatedTokens.intersection(impTokens).count
                guard overlap >= 2 else { continue }
                let score = overlap * 10 - abs(curatedTokens.count - impTokens.count)
                if bestMatch == nil || score > bestMatch!.score {
                    bestMatch = (imp, score)
                }
            }

            guard let match = bestMatch,
                  match.exercise.id.hasPrefix(Self.importedPrefix) else { continue }
            let rawId = String(match.exercise.id.dropFirst(Self.importedPrefix.count))
            guard let raw = importer.remoteGifURL(for: rawId),
                  let url = URL(string: raw) else { continue }
            result[ex.id] = url
        }
        self.urlByCuratedId = result
    }

    /// Remote GIF URL for a curated exercise when a high-confidence imported
    /// sibling exists in the same family. Returns nil for imported ids
    /// (they already resolve through `ExerciseCatalog.gifURL`).
    func gifURL(forCuratedId id: String) -> URL? {
        guard !id.hasPrefix(Self.importedPrefix) else { return nil }
        return urlByCuratedId[id]
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
        "fold", "reach", "stretch", "rotation", "calf", "good-morning"
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

    private enum EquipClass: Hashable {
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
