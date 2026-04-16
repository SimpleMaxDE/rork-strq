import Foundation

nonisolated struct ExerciseFamilyGroup: Identifiable, Sendable {
    let id: String
    let name: String
    let movementPattern: MovementPattern
    let primaryMuscles: [MuscleGroup]
    let description: String
    let standardExerciseId: String
    let memberIds: [String]
    let progressionChain: [String]
    let homeAlternativeIds: [String]
    let jointFriendlyIds: [String]

    var icon: String {
        switch movementPattern {
        case .horizontalPush: "arrow.right.circle.fill"
        case .horizontalPull: "arrow.left.circle.fill"
        case .verticalPush: "arrow.up.circle.fill"
        case .verticalPull: "arrow.down.circle.fill"
        case .hipHinge: "figure.cooldown"
        case .squat: "figure.strengthtraining.traditional"
        case .lunge: "figure.walk"
        case .carry: "figure.walk"
        case .rotation: "arrow.triangle.2.circlepath"
        case .antiRotation: "arrow.triangle.2.circlepath"
        case .flexion: "figure.core.training"
        case .extension_: "figure.pilates"
        case .abduction: "figure.dance"
        case .adduction: "figure.dance"
        case .isometric: "pause.circle.fill"
        case .plyometric: "figure.run"
        case .locomotion: "figure.run"
        }
    }
}
