import Foundation

struct ExercisePrescription {
    let role: ExerciseRole
    let whyThisExercise: String
    let whySetsReps: String
    let whyWeight: String
    let whyEffort: String
    let progressionNote: String?
    let suggestedWeight: String?
    let confidence: StartingLoadEngine.LoadConfidence?
    let guidanceAction: String?
    let guidanceColor: String
}

nonisolated struct OnboardingImpact: Identifiable, Sendable {
    let id: String
    let icon: String
    let title: String
    let detail: String
    let color: String

    init(id: String = UUID().uuidString, icon: String, title: String, detail: String, color: String) {
        self.id = id
        self.icon = icon
        self.title = title
        self.detail = detail
        self.color = color
    }
}
