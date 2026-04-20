import SwiftUI

struct ExerciseMediaProvider {
    static let shared = ExerciseMediaProvider()

    func media(for exercise: Exercise) -> ExerciseMedia {
        if let override = topExerciseMedia[exercise.id] {
            return override
        }
        if let url = ExerciseCatalog.shared.gifURL(for: exercise) {
            return ExerciseMedia(
                mediaType: .gif,
                assetURL: url.absoluteString,
                movementFamily: movementFamily(for: exercise)
            )
        }
        return ExerciseMedia(
            mediaType: .sfSymbol,
            movementFamily: movementFamily(for: exercise)
        )
    }

    func remoteGifURL(for exercise: Exercise) -> URL? {
        ExerciseCatalog.shared.gifURL(for: exercise)
    }

    func heroSymbol(for exercise: Exercise) -> String {
        if let specific = exerciseSpecificSymbol[exercise.id] {
            return specific
        }
        let family = movementFamily(for: exercise)
        let muscle = exercise.primaryMuscle
        switch (family, muscle) {
        case (.press, .chest): return "figure.strengthtraining.traditional"
        case (.press, .shoulders): return "figure.boxing"
        case (.press, .triceps): return "figure.strengthtraining.functional"
        case (.pull, .back), (.pull, .lats): return "figure.rowing"
        case (.pull, .biceps): return "figure.strengthtraining.functional"
        case (.squat, _): return "figure.step.training"
        case (.hinge, .glutes): return "figure.cooldown"
        case (.hinge, _): return "figure.strengthtraining.traditional"
        case (.lunge, _): return "figure.step.training"
        case (.plank, _): return "figure.core.training"
        case (.stretch, _): return "figure.mind.and.body"
        case (.cardio, _): return "figure.run"
        case (.carry, _): return "figure.walk"
        case (.rotation, _): return "figure.flexibility"
        case (.isolation, .biceps): return "dumbbell.fill"
        case (.isolation, .triceps): return "dumbbell.fill"
        case (.isolation, .calves): return "figure.step.training"
        case (.isolation, .abs): return "figure.core.training"
        case (.isolation, _): return "dumbbell.fill"
        default: return "figure.strengthtraining.traditional"
        }
    }

    func heroGradient(for exercise: Exercise) -> [Color] {
        if let specific = exerciseSpecificGradient[exercise.id] {
            return specific
        }
        let family = movementFamily(for: exercise)
        let cat = exercise.category
        switch (family, cat) {
        case (.press, .compound):
            return [Color(white: 0.38), Color(white: 0.18)]
        case (.press, .bodyweight):
            return [Color(white: 0.32), Color(white: 0.15)]
        case (.pull, .compound):
            return [Color(red: 0.28, green: 0.32, blue: 0.40), Color(red: 0.14, green: 0.16, blue: 0.22)]
        case (.pull, _):
            return [Color(red: 0.25, green: 0.30, blue: 0.38), Color(red: 0.12, green: 0.15, blue: 0.22)]
        case (.squat, .compound):
            return [Color(white: 0.35), Color(white: 0.16)]
        case (.squat, _):
            return [Color(white: 0.30), Color(white: 0.14)]
        case (.hinge, _):
            return [Color(red: 0.32, green: 0.28, blue: 0.35), Color(red: 0.16, green: 0.13, blue: 0.20)]
        case (.lunge, _):
            return [Color(white: 0.34), Color(white: 0.17)]
        case (.plank, _), (.isolation, _) where exercise.primaryMuscle == .abs || exercise.primaryMuscle == .coreStability:
            return [Color(red: 0.30, green: 0.28, blue: 0.38), Color(red: 0.15, green: 0.13, blue: 0.22)]
        case (.stretch, _):
            return [Color(red: 0.25, green: 0.32, blue: 0.32), Color(red: 0.12, green: 0.18, blue: 0.18)]
        case (.cardio, _):
            return [Color(red: 0.35, green: 0.25, blue: 0.25), Color(red: 0.20, green: 0.12, blue: 0.12)]
        default:
            break
        }
        switch cat {
        case .compound:
            return [Color(white: 0.36), Color(white: 0.17)]
        case .isolation:
            return [Color(red: 0.28, green: 0.30, blue: 0.36), Color(red: 0.14, green: 0.16, blue: 0.22)]
        case .bodyweight:
            return [Color(white: 0.30), Color(white: 0.14)]
        case .cardio:
            return [Color(red: 0.32, green: 0.24, blue: 0.24), Color(red: 0.18, green: 0.12, blue: 0.12)]
        case .mobility:
            return [Color(red: 0.24, green: 0.30, blue: 0.30), Color(red: 0.12, green: 0.18, blue: 0.18)]
        case .warmup:
            return [Color(white: 0.34), Color(white: 0.18)]
        case .recovery:
            return [Color(red: 0.24, green: 0.30, blue: 0.28), Color(red: 0.12, green: 0.18, blue: 0.15)]
        case .pilates:
            return [Color(red: 0.30, green: 0.26, blue: 0.32), Color(red: 0.16, green: 0.13, blue: 0.20)]
        }
    }

    func movementFamily(for exercise: Exercise) -> MovementFamily {
        switch exercise.movementPattern {
        case .horizontalPush, .verticalPush: return .press
        case .horizontalPull, .verticalPull: return .pull
        case .squat: return .squat
        case .hipHinge: return .hinge
        case .carry: return .carry
        case .lunge: return .lunge
        case .rotation, .antiRotation: return .rotation
        case .flexion, .extension_, .abduction, .adduction: return .isolation
        case .isometric: return .plank
        case .plyometric, .locomotion: return .cardio
        }
    }

    func isTopExercise(_ id: String) -> Bool {
        topExerciseMedia[id] != nil
    }

    private let exerciseSpecificSymbol: [String: String] = [
        "barbell-bench-press": "figure.strengthtraining.traditional",
        "dumbbell-bench-press": "figure.strengthtraining.traditional",
        "incline-barbell-press": "figure.strengthtraining.traditional",
        "incline-dumbbell-press": "figure.strengthtraining.traditional",
        "push-up": "figure.strengthtraining.functional",
        "pull-up": "figure.climbing",
        "chin-up": "figure.climbing",
        "lat-pulldown": "figure.rowing",
        "seated-cable-row": "figure.rowing",
        "barbell-row": "figure.rowing",
        "shoulder-press": "figure.boxing",
        "dumbbell-shoulder-press": "figure.boxing",
        "lateral-raise": "figure.arms.open",
        "bicep-curl": "dumbbell.fill",
        "hammer-curl": "dumbbell.fill",
        "tricep-pushdown": "figure.strengthtraining.functional",
        "barbell-squat": "figure.step.training",
        "leg-press": "figure.step.training",
        "romanian-deadlift": "figure.strengthtraining.traditional",
        "deadlift": "figure.strengthtraining.traditional",
        "hip-thrust": "figure.cooldown",
        "glute-bridge": "figure.cooldown",
        "lunge": "figure.step.training",
        "bulgarian-split-squat": "figure.step.training",
        "plank": "figure.core.training",
        "crunch": "figure.core.training",
        "dips": "figure.strengthtraining.functional",
        "cable-chest-fly": "figure.strengthtraining.traditional",
    ]

    private let exerciseSpecificGradient: [String: [Color]] = [
        "barbell-bench-press": [Color(white: 0.40), Color(white: 0.18)],
        "barbell-squat": [Color(white: 0.38), Color(white: 0.16)],
        "deadlift": [Color(white: 0.36), Color(white: 0.15)],
        "pull-up": [Color(red: 0.30, green: 0.34, blue: 0.42), Color(red: 0.14, green: 0.17, blue: 0.24)],
        "shoulder-press": [Color(red: 0.32, green: 0.30, blue: 0.40), Color(red: 0.16, green: 0.14, blue: 0.24)],
        "romanian-deadlift": [Color(white: 0.34), Color(white: 0.16)],
        "hip-thrust": [Color(white: 0.32), Color(white: 0.15)],
        "push-up": [Color(white: 0.30), Color(white: 0.14)],
        "dips": [Color(white: 0.36), Color(white: 0.17)],
        "lat-pulldown": [Color(red: 0.28, green: 0.32, blue: 0.40), Color(red: 0.13, green: 0.16, blue: 0.23)],
        "plank": [Color(red: 0.28, green: 0.26, blue: 0.35), Color(red: 0.14, green: 0.12, blue: 0.20)],
    ]

    private let topExerciseMedia: [String: ExerciseMedia] = [
        "barbell-bench-press": ExerciseMedia(movementFamily: .press, hasFrontView: true),
        "dumbbell-bench-press": ExerciseMedia(movementFamily: .press, hasFrontView: true),
        "incline-barbell-press": ExerciseMedia(movementFamily: .press, hasFrontView: true),
        "incline-dumbbell-press": ExerciseMedia(movementFamily: .press, hasFrontView: true),
        "push-up": ExerciseMedia(movementFamily: .press, hasFrontView: true),
        "pull-up": ExerciseMedia(movementFamily: .pull, hasFrontView: false, hasBackView: true),
        "lat-pulldown": ExerciseMedia(movementFamily: .pull, hasFrontView: true),
        "seated-cable-row": ExerciseMedia(movementFamily: .pull, hasFrontView: false, hasBackView: true),
        "barbell-row": ExerciseMedia(movementFamily: .pull, hasFrontView: false, hasBackView: true),
        "shoulder-press": ExerciseMedia(movementFamily: .press, hasFrontView: true),
        "dumbbell-shoulder-press": ExerciseMedia(movementFamily: .press, hasFrontView: true),
        "lateral-raise": ExerciseMedia(movementFamily: .isolation, hasFrontView: true),
        "bicep-curl": ExerciseMedia(movementFamily: .isolation, hasFrontView: true),
        "tricep-pushdown": ExerciseMedia(movementFamily: .isolation, hasFrontView: true),
        "barbell-squat": ExerciseMedia(movementFamily: .squat, hasFrontView: true),
        "leg-press": ExerciseMedia(movementFamily: .squat, hasFrontView: true),
        "romanian-deadlift": ExerciseMedia(movementFamily: .hinge, hasFrontView: false, hasBackView: true),
        "deadlift": ExerciseMedia(movementFamily: .hinge, hasFrontView: true),
        "bulgarian-split-squat": ExerciseMedia(movementFamily: .lunge, hasFrontView: true),
        "lunge": ExerciseMedia(movementFamily: .lunge, hasFrontView: true),
        "hip-thrust": ExerciseMedia(movementFamily: .hinge, hasFrontView: true),
        "glute-bridge": ExerciseMedia(movementFamily: .hinge, hasFrontView: true),
        "plank": ExerciseMedia(movementFamily: .plank, hasFrontView: true),
        "crunch": ExerciseMedia(movementFamily: .plank, hasFrontView: true),
        "dips": ExerciseMedia(movementFamily: .press, hasFrontView: true),
        "cable-chest-fly": ExerciseMedia(movementFamily: .isolation, hasFrontView: true),
        "leg-extension": ExerciseMedia(movementFamily: .isolation, hasFrontView: true),
        "leg-curl": ExerciseMedia(movementFamily: .isolation, hasFrontView: true),
    ]
}
