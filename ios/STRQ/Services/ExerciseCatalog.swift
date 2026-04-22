import Foundation

/// Unified, read-only catalog that combines STRQ's curated library with
/// normalized ExerciseDBPro imports.
///
/// The curated library remains the source of truth for plan generation,
/// progression chains, and family relationships. Imported exercises are
/// additive and surfaced through Library / Detail / Add / Swap only.
///
/// Plan generation and substitution logic keep using `ExerciseLibrary.shared`
/// directly until individual imported exercises are explicitly promoted.
struct ExerciseCatalog {
    static let shared = ExerciseCatalog()

    let curated: [Exercise]
    let imported: [Exercise]

    private let map: [String: Exercise]

    private init() {
        let curatedList = ExerciseLibrary.shared.exercises
        let importedList = ExerciseDBProImporter.shared.exercises
        self.curated = curatedList
        let curatedIds = Set(curatedList.map(\.id))
        self.imported = importedList.filter { !curatedIds.contains($0.id) }
        var m: [String: Exercise] = [:]
        for ex in curatedList { m[ex.id] = ex }
        for ex in self.imported { m[ex.id] = ex }
        self.map = m
    }

    var all: [Exercise] { curated + imported }

    func exercise(byId id: String) -> Exercise? {
        if let direct = map[id] { return direct }
        // Canonicalize alias ids so legacy references still resolve.
        let canonical = ExerciseIdentity.canonical(id)
        if canonical != id { return map[canonical] }
        return nil
    }

    func isImported(_ id: String) -> Bool {
        id.hasPrefix("edb-")
    }

    func gifURL(for exercise: Exercise) -> URL? {
        guard isImported(exercise.id) else { return nil }
        // Resolve through canonical id so collapsed alias rows still inherit
        // the canonical media. The importer already follows aliases, but
        // calling canonical() here makes the intent explicit.
        let canonical = ExerciseIdentity.canonical(exercise.id)
        let rawId = String(canonical.dropFirst("edb-".count))
        guard let s = ExerciseDBProImporter.shared.remoteGifURL(for: rawId) else { return nil }
        return URL(string: s)
    }

    // MARK: - Discovery helpers (combined)

    func search(_ query: String, includeImported: Bool = true) -> [Exercise] {
        let q = query.lowercased()
        guard !q.isEmpty else { return all }
        let pool = includeImported ? all : curated
        return pool.filter { ex in
            ex.name.lowercased().contains(q) ||
            ex.primaryMuscle.displayName.lowercased().contains(q) ||
            ex.secondaryMuscles.contains(where: { $0.displayName.lowercased().contains(q) }) ||
            ex.equipment.contains(where: { $0.displayName.lowercased().contains(q) }) ||
            ex.tags.contains(where: { $0.lowercased().contains(q) })
        }
    }

    func exercises(forMuscle muscle: MuscleGroup, includeImported: Bool = true) -> [Exercise] {
        let pool = includeImported ? all : curated
        return pool.filter { $0.primaryMuscle == muscle || $0.secondaryMuscles.contains(muscle) }
    }
}
