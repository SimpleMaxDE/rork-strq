import Foundation

struct ExerciseFamilyService {
    static let shared = ExerciseFamilyService()

    let families: [ExerciseFamilyGroup]
    private let familyMap: [String: ExerciseFamilyGroup]
    private let exerciseToFamily: [String: String]

    private init() {
        let all = Self.buildFamilies()
        self.families = all
        var fMap: [String: ExerciseFamilyGroup] = [:]
        var eMap: [String: String] = [:]
        for family in all {
            fMap[family.id] = family
            for memberId in family.memberIds {
                eMap[memberId] = family.id
            }
        }
        self.familyMap = fMap
        self.exerciseToFamily = eMap
    }

    func family(byId id: String) -> ExerciseFamilyGroup? {
        familyMap[id]
    }

    func family(forExercise exerciseId: String) -> ExerciseFamilyGroup? {
        guard let familyId = exerciseToFamily[exerciseId] else { return nil }
        return familyMap[familyId]
    }

    func familyMembers(forExercise exerciseId: String) -> [Exercise] {
        guard let family = family(forExercise: exerciseId) else { return [] }
        let library = ExerciseLibrary.shared
        return family.memberIds.compactMap { library.exercise(byId: $0) }
    }

    func progressionChain(forExercise exerciseId: String) -> [Exercise] {
        guard let family = family(forExercise: exerciseId) else { return [] }
        let library = ExerciseLibrary.shared
        return family.progressionChain.compactMap { library.exercise(byId: $0) }
    }

    func homeAlternatives(forExercise exerciseId: String) -> [Exercise] {
        guard let family = family(forExercise: exerciseId) else { return [] }
        let library = ExerciseLibrary.shared
        return family.homeAlternativeIds.compactMap { library.exercise(byId: $0) }
    }

    func jointFriendlyOptions(forExercise exerciseId: String) -> [Exercise] {
        guard let family = family(forExercise: exerciseId) else { return [] }
        let library = ExerciseLibrary.shared
        return family.jointFriendlyIds.compactMap { library.exercise(byId: $0) }
    }

    func families(forMuscle muscle: MuscleGroup) -> [ExerciseFamilyGroup] {
        families.filter { $0.primaryMuscles.contains(muscle) }
    }

    func families(forPattern pattern: MovementPattern) -> [ExerciseFamilyGroup] {
        families.filter { $0.movementPattern == pattern }
    }

    private static func buildFamilies() -> [ExerciseFamilyGroup] {
        [
            ExerciseFamilyGroup(
                id: "bench-press-family",
                name: "Bench Press",
                movementPattern: .horizontalPush,
                primaryMuscles: [.chest, .triceps],
                description: "Flat pressing movements for overall chest mass and pressing strength.",
                standardExerciseId: "barbell-bench-press",
                memberIds: ["barbell-bench-press", "dumbbell-bench-press", "machine-chest-press", "smith-bench-press", "floor-press-barbell", "floor-press-dumbbell", "close-grip-bench"],
                progressionChain: ["machine-chest-press", "dumbbell-bench-press", "barbell-bench-press", "close-grip-bench"],
                homeAlternativeIds: ["push-up", "band-chest-press", "dumbbell-bench-press"],
                jointFriendlyIds: ["machine-chest-press", "smith-bench-press", "floor-press-dumbbell"]
            ),
            ExerciseFamilyGroup(
                id: "incline-press-family",
                name: "Incline Press",
                movementPattern: .horizontalPush,
                primaryMuscles: [.chest, .shoulders],
                description: "Incline pressing for upper chest development and front delt involvement.",
                standardExerciseId: "incline-barbell-press",
                memberIds: ["incline-barbell-press", "incline-dumbbell-press", "incline-machine-press", "smith-incline-press", "low-incline-dumbbell-press"],
                progressionChain: ["incline-machine-press", "incline-dumbbell-press", "incline-barbell-press"],
                homeAlternativeIds: ["decline-push-up", "incline-dumbbell-press"],
                jointFriendlyIds: ["incline-machine-press", "low-incline-dumbbell-press"]
            ),
            ExerciseFamilyGroup(
                id: "chest-fly-family",
                name: "Chest Fly",
                movementPattern: .horizontalPush,
                primaryMuscles: [.chest],
                description: "Isolation chest movements through a wide arc for stretch and contraction.",
                standardExerciseId: "cable-chest-fly",
                memberIds: ["cable-chest-fly", "dumbbell-fly", "pec-deck", "cable-crossover", "incline-cable-fly", "svend-press"],
                progressionChain: ["pec-deck", "dumbbell-fly", "cable-chest-fly", "cable-crossover"],
                homeAlternativeIds: ["dumbbell-fly", "svend-press"],
                jointFriendlyIds: ["pec-deck", "cable-chest-fly"]
            ),
            ExerciseFamilyGroup(
                id: "push-up-family",
                name: "Push-Up",
                movementPattern: .horizontalPush,
                primaryMuscles: [.chest, .triceps],
                description: "Bodyweight horizontal pushing from beginner to advanced progressions.",
                standardExerciseId: "push-up",
                memberIds: ["push-up", "knee-push-up", "incline-push-up", "decline-push-up", "diamond-push-up", "wide-push-up", "deficit-push-up", "archer-push-up", "pseudo-planche-push-up", "hindu-push-up", "explosive-push-up"],
                progressionChain: ["knee-push-up", "incline-push-up", "push-up", "diamond-push-up", "decline-push-up", "deficit-push-up", "archer-push-up", "explosive-push-up"],
                homeAlternativeIds: ["push-up", "knee-push-up", "incline-push-up", "diamond-push-up"],
                jointFriendlyIds: ["knee-push-up", "incline-push-up"]
            ),
            ExerciseFamilyGroup(
                id: "dip-family",
                name: "Dip",
                movementPattern: .horizontalPush,
                primaryMuscles: [.chest, .triceps],
                description: "Vertical pressing with bodyweight for chest and tricep development.",
                standardExerciseId: "dips",
                memberIds: ["dips", "machine-dip", "bench-dip", "ring-dip", "dip-tricep"],
                progressionChain: ["bench-dip", "machine-dip", "dips", "dip-tricep", "ring-dip"],
                homeAlternativeIds: ["bench-dip"],
                jointFriendlyIds: ["machine-dip", "bench-dip"]
            ),
            ExerciseFamilyGroup(
                id: "pull-up-family",
                name: "Pull-Up / Chin-Up",
                movementPattern: .verticalPull,
                primaryMuscles: [.lats, .biceps],
                description: "Vertical pulling from a bar for back width and bicep development.",
                standardExerciseId: "pull-up",
                memberIds: ["pull-up", "chin-up", "assisted-pull-up", "wide-grip-pull-up", "neutral-grip-pull-up", "muscle-up", "commando-pull-up"],
                progressionChain: ["assisted-pull-up", "chin-up", "neutral-grip-pull-up", "pull-up", "wide-grip-pull-up", "commando-pull-up", "muscle-up"],
                homeAlternativeIds: ["pull-up", "chin-up", "inverted-row"],
                jointFriendlyIds: ["assisted-pull-up", "neutral-grip-pull-up", "chin-up"]
            ),
            ExerciseFamilyGroup(
                id: "lat-pulldown-family",
                name: "Lat Pulldown",
                movementPattern: .verticalPull,
                primaryMuscles: [.lats],
                description: "Cable-based vertical pulling for back width across all levels.",
                standardExerciseId: "lat-pulldown",
                memberIds: ["lat-pulldown", "close-grip-pulldown", "single-arm-pulldown", "straight-arm-pulldown", "reverse-grip-pulldown"],
                progressionChain: ["lat-pulldown", "close-grip-pulldown", "single-arm-pulldown"],
                homeAlternativeIds: ["band-row", "inverted-row"],
                jointFriendlyIds: ["lat-pulldown", "close-grip-pulldown"]
            ),
            ExerciseFamilyGroup(
                id: "row-family",
                name: "Row",
                movementPattern: .horizontalPull,
                primaryMuscles: [.back, .lats],
                description: "Horizontal pulling for back thickness and overall back development.",
                standardExerciseId: "barbell-row",
                memberIds: ["barbell-row", "dumbbell-row", "seated-cable-row", "t-bar-row", "pendlay-row", "seal-row", "meadows-row", "cable-row-wide", "chest-supported-row", "machine-row", "helms-row", "landmine-row"],
                progressionChain: ["machine-row", "seated-cable-row", "dumbbell-row", "barbell-row", "pendlay-row"],
                homeAlternativeIds: ["band-row", "dumbbell-row", "inverted-row", "kettlebell-row"],
                jointFriendlyIds: ["machine-row", "seated-cable-row", "chest-supported-row", "seal-row"]
            ),
            ExerciseFamilyGroup(
                id: "pullover-family",
                name: "Pullover",
                movementPattern: .verticalPull,
                primaryMuscles: [.lats, .chest],
                description: "Lat isolation with overhead pulling arc.",
                standardExerciseId: "cable-pullover",
                memberIds: ["cable-pullover", "dumbbell-pullover"],
                progressionChain: ["dumbbell-pullover", "cable-pullover"],
                homeAlternativeIds: ["dumbbell-pullover"],
                jointFriendlyIds: ["cable-pullover"]
            ),
            ExerciseFamilyGroup(
                id: "rear-delt-family",
                name: "Rear Delt",
                movementPattern: .horizontalPull,
                primaryMuscles: [.shoulders, .back],
                description: "Rear deltoid and upper back exercises for posture and shoulder health.",
                standardExerciseId: "face-pull",
                memberIds: ["face-pull", "reverse-fly", "reverse-fly-machine", "rear-delt-fly", "band-pull-apart", "band-face-pull", "cable-rear-delt-fly"],
                progressionChain: ["band-pull-apart", "reverse-fly-machine", "reverse-fly", "face-pull", "cable-rear-delt-fly"],
                homeAlternativeIds: ["band-pull-apart", "band-face-pull", "reverse-fly"],
                jointFriendlyIds: ["face-pull", "band-pull-apart", "reverse-fly-machine"]
            ),
            ExerciseFamilyGroup(
                id: "shoulder-press-family",
                name: "Shoulder Press",
                movementPattern: .verticalPush,
                primaryMuscles: [.shoulders, .triceps],
                description: "Vertical pressing for shoulder mass and overhead strength.",
                standardExerciseId: "overhead-press",
                memberIds: ["overhead-press", "dumbbell-shoulder-press", "machine-shoulder-press", "arnold-press", "z-press", "band-shoulder-press", "smith-shoulder-press"],
                progressionChain: ["machine-shoulder-press", "dumbbell-shoulder-press", "arnold-press", "overhead-press", "z-press"],
                homeAlternativeIds: ["pike-push-up", "band-shoulder-press", "dumbbell-shoulder-press"],
                jointFriendlyIds: ["machine-shoulder-press", "dumbbell-shoulder-press"]
            ),
            ExerciseFamilyGroup(
                id: "lateral-raise-family",
                name: "Lateral Raise",
                movementPattern: .abduction,
                primaryMuscles: [.shoulders],
                description: "Side deltoid isolation for shoulder width and roundness.",
                standardExerciseId: "lateral-raise",
                memberIds: ["lateral-raise", "cable-lateral-raise", "machine-lateral-raise", "band-lateral-raise", "lu-raise"],
                progressionChain: ["band-lateral-raise", "machine-lateral-raise", "lateral-raise", "cable-lateral-raise", "lu-raise"],
                homeAlternativeIds: ["band-lateral-raise", "lateral-raise"],
                jointFriendlyIds: ["machine-lateral-raise", "cable-lateral-raise"]
            ),
            ExerciseFamilyGroup(
                id: "overhead-push-bw-family",
                name: "Overhead Push (Bodyweight)",
                movementPattern: .verticalPush,
                primaryMuscles: [.shoulders],
                description: "Bodyweight overhead pressing progressions from pike to handstand.",
                standardExerciseId: "pike-push-up",
                memberIds: ["pike-push-up", "handstand-push-up", "elevated-pike-push-up"],
                progressionChain: ["pike-push-up", "elevated-pike-push-up", "handstand-push-up"],
                homeAlternativeIds: ["pike-push-up", "elevated-pike-push-up"],
                jointFriendlyIds: ["pike-push-up"]
            ),
            ExerciseFamilyGroup(
                id: "squat-family",
                name: "Squat",
                movementPattern: .squat,
                primaryMuscles: [.quads, .glutes],
                description: "Bilateral squatting patterns from bodyweight to heavy barbell.",
                standardExerciseId: "barbell-squat",
                memberIds: ["barbell-squat", "front-squat", "goblet-squat", "bodyweight-squat", "leg-press", "hack-squat", "smith-squat", "kettlebell-goblet-squat", "band-squat", "landmine-squat", "pendulum-squat", "belt-squat", "zercher-squat"],
                progressionChain: ["bodyweight-squat", "goblet-squat", "smith-squat", "leg-press", "barbell-squat", "front-squat", "zercher-squat"],
                homeAlternativeIds: ["bodyweight-squat", "goblet-squat", "band-squat", "kettlebell-goblet-squat"],
                jointFriendlyIds: ["leg-press", "smith-squat", "hack-squat", "landmine-squat", "belt-squat", "pendulum-squat"]
            ),
            ExerciseFamilyGroup(
                id: "lunge-family",
                name: "Lunge / Split Squat",
                movementPattern: .lunge,
                primaryMuscles: [.quads, .glutes],
                description: "Unilateral lower body patterns for balance and leg development.",
                standardExerciseId: "bulgarian-split-squat",
                memberIds: ["bulgarian-split-squat", "lunge", "reverse-lunge", "bodyweight-lunge", "step-up", "box-step-up-weighted", "curtsy-lunge", "walking-lunge-barbell"],
                progressionChain: ["bodyweight-lunge", "reverse-lunge", "lunge", "step-up", "bulgarian-split-squat", "walking-lunge-barbell"],
                homeAlternativeIds: ["bodyweight-lunge", "reverse-lunge"],
                jointFriendlyIds: ["reverse-lunge", "step-up"]
            ),
            ExerciseFamilyGroup(
                id: "bw-squat-family",
                name: "Bodyweight Squat Progressions",
                movementPattern: .squat,
                primaryMuscles: [.quads, .glutes],
                description: "Calisthenics squat progressions from basic to single-leg.",
                standardExerciseId: "bodyweight-squat",
                memberIds: ["bodyweight-squat", "hindu-squat", "cossack-squat", "pistol-squat", "dragon-squat", "sissy-squat", "shrimp-squat"],
                progressionChain: ["bodyweight-squat", "hindu-squat", "cossack-squat", "shrimp-squat", "pistol-squat", "dragon-squat"],
                homeAlternativeIds: ["bodyweight-squat", "hindu-squat", "cossack-squat"],
                jointFriendlyIds: ["bodyweight-squat"]
            ),
            ExerciseFamilyGroup(
                id: "deadlift-family",
                name: "Deadlift / Hip Hinge",
                movementPattern: .hipHinge,
                primaryMuscles: [.hamstrings, .glutes, .back],
                description: "Heavy hinge patterns for posterior chain strength.",
                standardExerciseId: "deadlift",
                memberIds: ["deadlift", "romanian-deadlift", "dumbbell-rdl", "single-leg-rdl", "trap-bar-deadlift", "sumo-deadlift", "kettlebell-deadlift", "good-morning", "stiff-leg-deadlift"],
                progressionChain: ["kettlebell-deadlift", "dumbbell-rdl", "trap-bar-deadlift", "romanian-deadlift", "deadlift", "sumo-deadlift"],
                homeAlternativeIds: ["dumbbell-rdl", "single-leg-rdl", "kettlebell-deadlift"],
                jointFriendlyIds: ["trap-bar-deadlift", "dumbbell-rdl", "kettlebell-deadlift"]
            ),
            ExerciseFamilyGroup(
                id: "hip-thrust-family",
                name: "Hip Thrust / Glute Bridge",
                movementPattern: .hipHinge,
                primaryMuscles: [.glutes],
                description: "Glute-dominant hinge patterns for glute hypertrophy.",
                standardExerciseId: "hip-thrust",
                memberIds: ["hip-thrust", "glute-bridge", "dumbbell-hip-thrust", "single-leg-glute-bridge", "shoulder-bridge", "glute-kickback-machine", "cable-pull-through"],
                progressionChain: ["glute-bridge", "single-leg-glute-bridge", "dumbbell-hip-thrust", "hip-thrust"],
                homeAlternativeIds: ["glute-bridge", "single-leg-glute-bridge", "dumbbell-hip-thrust"],
                jointFriendlyIds: ["glute-bridge", "glute-kickback-machine", "cable-pull-through"]
            ),
            ExerciseFamilyGroup(
                id: "hamstring-curl-family",
                name: "Hamstring Curl",
                movementPattern: .flexion,
                primaryMuscles: [.hamstrings],
                description: "Knee flexion movements for hamstring isolation.",
                standardExerciseId: "leg-curl",
                memberIds: ["leg-curl", "nordic-curl", "swiss-ball-curl", "seated-leg-curl", "single-leg-curl"],
                progressionChain: ["swiss-ball-curl", "leg-curl", "seated-leg-curl", "single-leg-curl", "nordic-curl"],
                homeAlternativeIds: ["swiss-ball-curl", "nordic-curl"],
                jointFriendlyIds: ["leg-curl", "seated-leg-curl"]
            ),
            ExerciseFamilyGroup(
                id: "quad-extension-family",
                name: "Quad Extension",
                movementPattern: .extension_,
                primaryMuscles: [.quads],
                description: "Knee extension for quad isolation.",
                standardExerciseId: "leg-extension",
                memberIds: ["leg-extension", "sissy-squat", "single-leg-extension"],
                progressionChain: ["leg-extension", "single-leg-extension", "sissy-squat"],
                homeAlternativeIds: ["sissy-squat", "wall-sit"],
                jointFriendlyIds: ["leg-extension"]
            ),
            ExerciseFamilyGroup(
                id: "calf-raise-family",
                name: "Calf Raise",
                movementPattern: .extension_,
                primaryMuscles: [.calves],
                description: "Plantar flexion for calf development.",
                standardExerciseId: "calf-raise-standing",
                memberIds: ["calf-raise-standing", "calf-raise-seated", "bodyweight-calf-raise", "donkey-calf-raise", "single-leg-calf-raise"],
                progressionChain: ["bodyweight-calf-raise", "calf-raise-seated", "calf-raise-standing", "donkey-calf-raise", "single-leg-calf-raise"],
                homeAlternativeIds: ["bodyweight-calf-raise", "single-leg-calf-raise"],
                jointFriendlyIds: ["calf-raise-seated", "bodyweight-calf-raise"]
            ),
            ExerciseFamilyGroup(
                id: "bicep-curl-family",
                name: "Bicep Curl",
                movementPattern: .flexion,
                primaryMuscles: [.biceps],
                description: "Elbow flexion for bicep and brachialis development.",
                standardExerciseId: "barbell-curl",
                memberIds: ["barbell-curl", "dumbbell-curl", "hammer-curl", "ez-bar-curl", "preacher-curl", "concentration-curl", "cable-curl", "incline-dumbbell-curl", "spider-curl", "cross-body-curl", "machine-curl", "band-curl", "bayesian-curl", "cable-hammer-curl", "overhead-cable-curl"],
                progressionChain: ["band-curl", "machine-curl", "dumbbell-curl", "barbell-curl", "preacher-curl", "incline-dumbbell-curl", "bayesian-curl"],
                homeAlternativeIds: ["band-curl", "dumbbell-curl", "hammer-curl"],
                jointFriendlyIds: ["ez-bar-curl", "cable-curl", "machine-curl", "hammer-curl"]
            ),
            ExerciseFamilyGroup(
                id: "tricep-extension-family",
                name: "Tricep Extension",
                movementPattern: .extension_,
                primaryMuscles: [.triceps],
                description: "Elbow extension for tricep isolation across all three heads.",
                standardExerciseId: "tricep-pushdown",
                memberIds: ["tricep-pushdown", "overhead-tricep-extension", "skull-crusher", "cable-overhead-extension", "tricep-kickback", "band-tricep-extension", "jm-press"],
                progressionChain: ["band-tricep-extension", "tricep-pushdown", "cable-overhead-extension", "skull-crusher", "jm-press"],
                homeAlternativeIds: ["band-tricep-extension", "overhead-tricep-extension", "diamond-push-up"],
                jointFriendlyIds: ["tricep-pushdown", "cable-overhead-extension", "tricep-kickback"]
            ),
            ExerciseFamilyGroup(
                id: "plank-family",
                name: "Plank / Anti-Extension",
                movementPattern: .isometric,
                primaryMuscles: [.coreStability, .abs],
                description: "Isometric core holds and anti-extension patterns.",
                standardExerciseId: "plank",
                memberIds: ["plank", "side-plank", "dead-bug", "bird-dog", "hollow-body-hold", "body-saw", "long-lever-plank"],
                progressionChain: ["dead-bug", "bird-dog", "plank", "side-plank", "hollow-body-hold", "body-saw", "long-lever-plank"],
                homeAlternativeIds: ["plank", "dead-bug", "bird-dog", "side-plank"],
                jointFriendlyIds: ["dead-bug", "bird-dog", "plank"]
            ),
            ExerciseFamilyGroup(
                id: "crunch-family",
                name: "Crunch / Spinal Flexion",
                movementPattern: .flexion,
                primaryMuscles: [.abs],
                description: "Spinal flexion exercises for rectus abdominis.",
                standardExerciseId: "crunch",
                memberIds: ["crunch", "cable-crunch", "machine-crunch", "sit-up", "hanging-leg-raise", "lying-leg-raise", "v-up", "reverse-crunch", "decline-sit-up", "toe-touch", "flutter-kick", "bicycle-crunch"],
                progressionChain: ["crunch", "lying-leg-raise", "bicycle-crunch", "cable-crunch", "reverse-crunch", "v-up", "hanging-leg-raise"],
                homeAlternativeIds: ["crunch", "lying-leg-raise", "bicycle-crunch", "v-up"],
                jointFriendlyIds: ["crunch", "dead-bug", "lying-leg-raise"]
            ),
            ExerciseFamilyGroup(
                id: "rotation-family",
                name: "Rotation / Anti-Rotation",
                movementPattern: .rotation,
                primaryMuscles: [.obliques, .rotationAntiRotation],
                description: "Rotational and anti-rotational core exercises.",
                standardExerciseId: "pallof-press",
                memberIds: ["russian-twist", "woodchop", "pallof-press", "landmine-rotation", "plate-twist"],
                progressionChain: ["pallof-press", "russian-twist", "woodchop", "landmine-rotation"],
                homeAlternativeIds: ["russian-twist", "bicycle-crunch"],
                jointFriendlyIds: ["pallof-press", "dead-bug"]
            ),
            ExerciseFamilyGroup(
                id: "pilates-core-family",
                name: "Pilates Core",
                movementPattern: .flexion,
                primaryMuscles: [.abs, .coreStability],
                description: "Classical Pilates mat exercises for core control and spinal articulation.",
                standardExerciseId: "the-hundred",
                memberIds: ["the-hundred", "roll-up", "pilates-criss-cross", "teaser", "pilates-roll-over", "single-leg-stretch", "double-leg-stretch", "open-leg-rocker", "jackknife", "corkscrew"],
                progressionChain: ["single-leg-stretch", "the-hundred", "roll-up", "pilates-criss-cross", "double-leg-stretch", "teaser", "pilates-roll-over"],
                homeAlternativeIds: ["the-hundred", "roll-up", "single-leg-stretch"],
                jointFriendlyIds: ["single-leg-stretch", "the-hundred", "roll-up"]
            ),
            ExerciseFamilyGroup(
                id: "shrug-family",
                name: "Shrug",
                movementPattern: .verticalPull,
                primaryMuscles: [.traps],
                description: "Trap isolation through shoulder elevation.",
                standardExerciseId: "shrug",
                memberIds: ["shrug", "dumbbell-shrug", "cable-shrug"],
                progressionChain: ["dumbbell-shrug", "shrug", "cable-shrug"],
                homeAlternativeIds: ["dumbbell-shrug"],
                jointFriendlyIds: ["dumbbell-shrug", "cable-shrug"]
            ),
            ExerciseFamilyGroup(
                id: "carry-family",
                name: "Loaded Carry",
                movementPattern: .carry,
                primaryMuscles: [.forearms, .coreStability, .traps],
                description: "Loaded walking for grip, core, and total body conditioning.",
                standardExerciseId: "farmer-walk",
                memberIds: ["farmer-walk", "farmers-carry-single", "overhead-carry", "goblet-carry"],
                progressionChain: ["goblet-carry", "farmer-walk", "farmers-carry-single", "overhead-carry"],
                homeAlternativeIds: ["farmer-walk", "goblet-carry"],
                jointFriendlyIds: ["farmer-walk", "goblet-carry"]
            ),
            ExerciseFamilyGroup(
                id: "kettlebell-swing-family",
                name: "Kettlebell Swing",
                movementPattern: .hipHinge,
                primaryMuscles: [.glutes, .hamstrings],
                description: "Explosive hip hinge patterns with kettlebell or dumbbell.",
                standardExerciseId: "kettlebell-swing",
                memberIds: ["kettlebell-swing", "dumbbell-swing", "kettlebell-snatch", "kettlebell-clean-press"],
                progressionChain: ["dumbbell-swing", "kettlebell-swing", "kettlebell-clean-press", "kettlebell-snatch"],
                homeAlternativeIds: ["dumbbell-swing", "kettlebell-swing"],
                jointFriendlyIds: ["kettlebell-swing", "dumbbell-swing"]
            ),
        ]
    }
}
