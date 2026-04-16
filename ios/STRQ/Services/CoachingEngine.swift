import Foundation

struct CoachingEngine {
    let library = ExerciseLibrary.shared
    private let progressionEngine = ProgressionEngine()
    private let volumeEngine = SmartVolumeEngine()

    func generateInsights(
        profile: UserProfile,
        workoutHistory: [WorkoutSession],
        progressEntries: [ProgressEntry],
        personalRecords: [PersonalRecord],
        currentPlan: WorkoutPlan?,
        muscleBalance: [MuscleBalanceEntry],
        progressionStates: [ExerciseProgressionState] = [],
        phase: TrainingPhase = .build,
        volumeLandmarks: [VolumeLandmark] = []
    ) -> [SmartInsight] {
        var insights: [SmartInsight] = []

        insights.append(contentsOf: volumeImbalanceInsights(muscleBalance: muscleBalance, profile: profile))
        insights.append(contentsOf: pushPullBalanceInsights(workoutHistory: workoutHistory))
        insights.append(contentsOf: upperLowerBalanceInsights(muscleBalance: muscleBalance))
        insights.append(contentsOf: recoveryInsights(workoutHistory: workoutHistory, profile: profile))
        insights.append(contentsOf: frequencyInsights(workoutHistory: workoutHistory, profile: profile))
        insights.append(contentsOf: progressionInsights(personalRecords: personalRecords, workoutHistory: workoutHistory))
        insights.append(contentsOf: consistencyInsights(workoutHistory: workoutHistory))
        insights.append(contentsOf: bodyweightInsights(progressEntries: progressEntries, profile: profile))
        insights.append(contentsOf: fatigueInsights(workoutHistory: workoutHistory, progressEntries: progressEntries))
        insights.append(contentsOf: deloadInsights(workoutHistory: workoutHistory, progressEntries: progressEntries))
        insights.append(contentsOf: plateauInsights(progressionStates: progressionStates))
        insights.append(contentsOf: phaseInsights(phase: phase, profile: profile))
        insights.append(contentsOf: volumeLandmarkInsights(landmarks: volumeLandmarks, profile: profile))
        insights.append(contentsOf: exerciseSpecificProgressionInsights(progressionStates: progressionStates, profile: profile))

        return insights
            .sorted { $0.severityRank > $1.severityRank }
    }

    func generateRecommendations(
        profile: UserProfile,
        workoutHistory: [WorkoutSession],
        progressEntries: [ProgressEntry],
        personalRecords: [PersonalRecord],
        muscleBalance: [MuscleBalanceEntry],
        progressionStates: [ExerciseProgressionState] = [],
        phase: TrainingPhase = .build
    ) -> [Recommendation] {
        var recs: [Recommendation] = []

        recs.append(contentsOf: volumeRecommendations(muscleBalance: muscleBalance, profile: profile))
        recs.append(contentsOf: progressionRecommendations(personalRecords: personalRecords, workoutHistory: workoutHistory))
        recs.append(contentsOf: recoveryRecommendations(workoutHistory: workoutHistory, profile: profile))
        recs.append(contentsOf: exerciseSwapRecommendations(workoutHistory: workoutHistory, profile: profile))
        recs.append(contentsOf: planRecommendations(profile: profile, workoutHistory: workoutHistory))
        recs.append(contentsOf: smartProgressionRecommendations(progressionStates: progressionStates, phase: phase))
        recs.append(contentsOf: plateauRecommendations(progressionStates: progressionStates))

        return recs.sorted { $0.priority > $1.priority }
    }

    func suggestExerciseReplacement(
        for exercise: Exercise,
        profile: UserProfile,
        reason: ReplacementReason
    ) -> [Exercise] {
        var candidates = library.alternatives(for: exercise)

        if candidates.isEmpty {
            candidates = library.exercises(forMuscle: exercise.primaryMuscle)
                .filter { $0.id != exercise.id }
        }

        let location: LocationType = {
            switch profile.trainingLocation {
            case .gym: return .gym
            case .homeGym: return .homeGym
            case .homeNoEquipment: return .homeNoEquipment
            }
        }()

        candidates = candidates.filter { ex in
            switch location {
            case .gym: return true
            case .homeGym: return ex.locationType != .gym
            case .homeNoEquipment: return ex.locationType == .homeNoEquipment || ex.locationType == .anywhere
            case .anywhere: return true
            }
        }

        if !profile.availableEquipment.isEmpty && profile.trainingLocation != .gym {
            candidates = candidates.filter { ex in
                ex.equipment.contains(.none) || ex.equipment.contains(where: { profile.availableEquipment.contains($0) })
            }
        }

        switch reason {
        case .injuryAvoidance:
            candidates = candidates.filter { $0.isJointFriendly }
        case .equipmentUnavailable:
            break
        case .samePattern:
            candidates = candidates.filter { $0.movementPattern == exercise.movementPattern }
        case .easier:
            candidates = candidates.filter { $0.difficulty.rawValue <= exercise.difficulty.rawValue || $0.isBeginnerFriendly }
        case .harder:
            candidates = candidates.filter { $0.difficulty.rawValue >= exercise.difficulty.rawValue }
        case .general:
            break
        }

        let avoided = Set(profile.avoidedExercises.map { $0.lowercased() })
        candidates = candidates.filter { !avoided.contains($0.name.lowercased()) }

        return Array(candidates.prefix(5))
    }

    // MARK: - Volume Imbalance

    private func volumeImbalanceInsights(muscleBalance: [MuscleBalanceEntry], profile: UserProfile) -> [SmartInsight] {
        var results: [SmartInsight] = []

        for entry in muscleBalance {
            let ratio = entry.percentOfAverage
            if ratio < 0.7 {
                results.append(SmartInsight(
                    icon: "exclamationmark.triangle.fill",
                    color: "red",
                    title: "\(entry.muscle) Volume Significantly Low",
                    message: "Your \(entry.muscle.lowercased()) volume is \(Int((1.0 - ratio) * 100))% below your recent average. This could slow progress on that muscle group.",
                    severity: .high,
                    category: .volumeBalance
                ))
            } else if ratio < 0.85 {
                results.append(SmartInsight(
                    icon: "arrow.down.circle.fill",
                    color: "yellow",
                    title: "\(entry.muscle) Volume Below Average",
                    message: "Your \(entry.muscle.lowercased()) work is \(Int((1.0 - ratio) * 100))% below your 4-week average. Consider adding an extra set next session.",
                    severity: .medium,
                    category: .volumeBalance
                ))
            } else if ratio > 1.25 {
                results.append(SmartInsight(
                    icon: "arrow.up.circle.fill",
                    color: "orange",
                    title: "\(entry.muscle) Volume Very High",
                    message: "Your \(entry.muscle.lowercased()) volume is \(Int((ratio - 1.0) * 100))% above average. Be mindful of recovery if you feel joint fatigue.",
                    severity: .low,
                    category: .volumeBalance
                ))
            }
        }

        let focusMuscleNames = Set(profile.focusMuscles.map { $0.displayName })
        let undertrainedFocused = muscleBalance.filter { focusMuscleNames.contains($0.muscle) && $0.percentOfAverage < 0.85 }
        for entry in undertrainedFocused {
            results.append(SmartInsight(
                icon: "target",
                color: "red",
                title: "\(entry.muscle) is a Focus Muscle but Undertrained",
                message: "You marked \(entry.muscle.lowercased()) as a priority, but your volume is below average. Prioritize it in your next session.",
                severity: .high,
                category: .volumeBalance
            ))
        }

        return results
    }

    // MARK: - Push/Pull Balance

    private func pushPullBalanceInsights(workoutHistory: [WorkoutSession]) -> [SmartInsight] {
        let weekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        let recent = workoutHistory.filter { $0.startTime > weekAgo && $0.isCompleted }

        var pushVolume: Double = 0
        var pullVolume: Double = 0

        for session in recent {
            for log in session.exerciseLogs {
                guard let exercise = ExerciseLibrary.shared.exercise(byId: log.exerciseId) else { continue }
                let volume = log.sets.filter(\.isCompleted).reduce(0.0) { $0 + $1.weight * Double($1.reps) }
                switch exercise.movementPattern {
                case .horizontalPush, .verticalPush:
                    pushVolume += volume
                case .horizontalPull, .verticalPull:
                    pullVolume += volume
                default:
                    break
                }
            }
        }

        guard pushVolume > 0 || pullVolume > 0 else { return [] }

        let total = pushVolume + pullVolume
        let pushRatio = pushVolume / total
        let pullRatio = pullVolume / total

        if pushRatio > 0.65 {
            return [SmartInsight(
                icon: "arrow.left.arrow.right",
                color: "orange",
                title: "Push Volume Dominates Pull",
                message: "Your push:pull ratio is \(Int(pushRatio * 100)):\(Int(pullRatio * 100)). Add more rowing or pull-up variations to balance your upper body.",
                severity: .medium,
                category: .movementBalance
            )]
        } else if pullRatio > 0.65 {
            return [SmartInsight(
                icon: "arrow.left.arrow.right",
                color: "orange",
                title: "Pull Volume Dominates Push",
                message: "Your pull:push ratio is \(Int(pullRatio * 100)):\(Int(pushRatio * 100)). Consider adding pressing movements for balance.",
                severity: .medium,
                category: .movementBalance
            )]
        }

        return []
    }

    // MARK: - Upper/Lower Balance

    private func upperLowerBalanceInsights(muscleBalance: [MuscleBalanceEntry]) -> [SmartInsight] {
        let upperMuscles: Set<String> = ["Chest", "Back", "Shoulders", "Arms"]
        let lowerMuscles: Set<String> = ["Quads", "Hamstrings", "Glutes", "Calves"]

        let upperVolume = muscleBalance.filter { upperMuscles.contains($0.muscle) }.reduce(0.0) { $0 + $1.thisWeek }
        let lowerVolume = muscleBalance.filter { lowerMuscles.contains($0.muscle) }.reduce(0.0) { $0 + $1.thisWeek }

        guard upperVolume > 0, lowerVolume > 0 else { return [] }

        let ratio = upperVolume / lowerVolume
        if ratio > 1.8 {
            return [SmartInsight(
                icon: "figure.stand",
                color: "yellow",
                title: "Upper Body Dominant Training",
                message: "Your upper body volume is \(String(format: "%.1f", ratio))x your lower body. This imbalance may limit athletic performance and increase injury risk.",
                severity: .medium,
                category: .movementBalance
            )]
        } else if ratio < 0.55 {
            return [SmartInsight(
                icon: "figure.stand",
                color: "yellow",
                title: "Lower Body Dominant Training",
                message: "Your lower body volume significantly exceeds upper body. Consider balancing with more pressing and rowing work.",
                severity: .medium,
                category: .movementBalance
            )]
        }

        return []
    }

    // MARK: - Recovery

    private func recoveryInsights(workoutHistory: [WorkoutSession], profile: UserProfile) -> [SmartInsight] {
        var results: [SmartInsight] = []

        let threeDaysAgo = Calendar.current.date(byAdding: .day, value: -3, to: Date()) ?? Date()
        let recentSessions = workoutHistory.filter { $0.startTime > threeDaysAgo && $0.isCompleted }

        if recentSessions.count >= 4 {
            results.append(SmartInsight(
                icon: "bed.double.fill",
                color: "red",
                title: "High Training Density",
                message: "\(recentSessions.count) sessions in the last 3 days is very demanding. Consider a rest day to allow your muscles and CNS to recover.",
                severity: .high,
                category: .recovery
            ))
        } else if recentSessions.count == 3 {
            results.append(SmartInsight(
                icon: "moon.fill",
                color: "yellow",
                title: "3 Sessions in 3 Days",
                message: "Training daily is fine occasionally, but sustained high frequency may impair recovery. Listen to your body.",
                severity: .medium,
                category: .recovery
            ))
        }

        if profile.sleepQuality == .poor || profile.sleepQuality == .fair {
            if recentSessions.count >= 2 {
                results.append(SmartInsight(
                    icon: "zzz",
                    color: "purple",
                    title: "Sleep & Training Load Mismatch",
                    message: "Your sleep quality is reported as \(profile.sleepQuality.displayName.lowercased()). High training volume with poor sleep can lead to overtraining. Prioritize rest.",
                    severity: .medium,
                    category: .recovery
                ))
            }
        }

        if profile.stressLevel == .high || profile.stressLevel == .veryHigh {
            results.append(SmartInsight(
                icon: "brain.head.profile.fill",
                color: "purple",
                title: "High Stress May Limit Recovery",
                message: "Elevated stress reduces your body's ability to recover. Consider lighter sessions or more recovery-focused work this week.",
                severity: .low,
                category: .recovery
            ))
        }

        return results
    }

    // MARK: - Frequency

    private func frequencyInsights(workoutHistory: [WorkoutSession], profile: UserProfile) -> [SmartInsight] {
        let weekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        let thisWeekCount = workoutHistory.filter { $0.startTime > weekAgo && $0.isCompleted }.count

        let twoWeeksAgo = Calendar.current.date(byAdding: .day, value: -14, to: Date()) ?? Date()
        let lastWeekCount = workoutHistory.filter { $0.startTime > twoWeeksAgo && $0.startTime <= weekAgo && $0.isCompleted }.count

        var results: [SmartInsight] = []

        if thisWeekCount > lastWeekCount && lastWeekCount > 0 {
            results.append(SmartInsight(
                icon: "arrow.up.forward.circle.fill",
                color: "green",
                title: "Frequency Improved",
                message: "You trained \(thisWeekCount) times this week vs \(lastWeekCount) last week. Great consistency improvement!",
                severity: .positive,
                category: .consistency
            ))
        } else if thisWeekCount < lastWeekCount && thisWeekCount > 0 && lastWeekCount > 0 {
            results.append(SmartInsight(
                icon: "arrow.down.forward.circle.fill",
                color: "yellow",
                title: "Frequency Dropped",
                message: "You trained \(thisWeekCount) times this week vs \(lastWeekCount) last week. Try to stay consistent with your \(profile.daysPerWeek)-day plan.",
                severity: .low,
                category: .consistency
            ))
        }

        if thisWeekCount < profile.daysPerWeek && thisWeekCount > 0 {
            let gap = profile.daysPerWeek - thisWeekCount
            results.append(SmartInsight(
                icon: "calendar.badge.exclamationmark",
                color: "yellow",
                title: "Below Target Frequency",
                message: "You've completed \(thisWeekCount) of your planned \(profile.daysPerWeek) sessions this week. \(gap) more to go to hit your target.",
                severity: .low,
                category: .consistency
            ))
        }

        return results
    }

    // MARK: - Progression

    private func progressionInsights(personalRecords: [PersonalRecord], workoutHistory: [WorkoutSession]) -> [SmartInsight] {
        var results: [SmartInsight] = []

        let recentPRs = personalRecords.filter {
            $0.date > Calendar.current.date(byAdding: .day, value: -7, to: Date())!
        }

        for pr in recentPRs.prefix(2) {
            let exerciseName = library.exercise(byId: pr.exerciseId)?.name ?? pr.exerciseId
            results.append(SmartInsight(
                icon: "trophy.fill",
                color: "yellow",
                title: "New Best: \(exerciseName)",
                message: "\(Int(pr.weight))kg × \(pr.reps) reps — estimated 1RM of \(Int(pr.estimatedOneRepMax))kg. Keep pushing!",
                severity: .positive,
                category: .progression
            ))
        }

        return results
    }

    // MARK: - Consistency Patterns

    private func consistencyInsights(workoutHistory: [WorkoutSession]) -> [SmartInsight] {
        let calendar = Calendar.current
        let sixWeeksAgo = calendar.date(byAdding: .weekOfYear, value: -6, to: Date()) ?? Date()
        let recentSessions = workoutHistory.filter { $0.startTime > sixWeeksAgo && $0.isCompleted }

        var weekdayCounts: [Int: Int] = [:]
        for session in recentSessions {
            let weekday = calendar.component(.weekday, from: session.startTime)
            weekdayCounts[weekday, default: 0] += 1
        }

        if let (bestDay, count) = weekdayCounts.max(by: { $0.value < $1.value }), count >= 4 {
            let dayName = calendar.weekdaySymbols[bestDay - 1]
            return [SmartInsight(
                icon: "calendar.badge.checkmark",
                color: "blue",
                title: "Strongest Day: \(dayName)",
                message: "You've trained on \(dayName) \(count) times in the last 6 weeks. This is your most consistent training day.",
                severity: .positive,
                category: .consistency
            )]
        }

        return []
    }

    // MARK: - Bodyweight

    private func bodyweightInsights(progressEntries: [ProgressEntry], profile: UserProfile) -> [SmartInsight] {
        let weightEntries = progressEntries
            .compactMap { entry -> (Date, Double)? in
                guard let w = entry.bodyWeight else { return nil }
                return (entry.date, w)
            }
            .sorted { $0.0 < $1.0 }

        guard weightEntries.count >= 4 else { return [] }

        let recentFour = weightEntries.suffix(4).map(\.1)
        let olderFour = weightEntries.dropLast(4).suffix(4).map(\.1)

        guard !recentFour.isEmpty, !olderFour.isEmpty else { return [] }

        let recentAvg = recentFour.reduce(0, +) / Double(recentFour.count)
        let olderAvg = olderFour.reduce(0, +) / Double(olderFour.count)
        let delta = recentAvg - olderAvg

        var results: [SmartInsight] = []

        switch profile.goal {
        case .fatLoss:
            if delta < -0.3 {
                results.append(SmartInsight(
                    icon: "arrow.down.circle.fill",
                    color: "green",
                    title: "Weight Trending Down",
                    message: "Your bodyweight is dropping at a healthy pace (about \(String(format: "%.1f", abs(delta)))kg recently). Stay the course.",
                    severity: .positive,
                    category: .bodyComposition
                ))
            } else if delta > 0.3 {
                results.append(SmartInsight(
                    icon: "arrow.up.circle.fill",
                    color: "orange",
                    title: "Weight Trending Up During Cut",
                    message: "Your goal is fat loss, but bodyweight is trending up. Review your nutrition or increase activity.",
                    severity: .medium,
                    category: .bodyComposition
                ))
            }
        case .muscleGain:
            if delta > 0.2 {
                results.append(SmartInsight(
                    icon: "arrow.up.circle.fill",
                    color: "green",
                    title: "Weight Trending Up",
                    message: "Gaining at about \(String(format: "%.1f", delta))kg recently — on track for muscle gain. Ensure strength is also increasing.",
                    severity: .positive,
                    category: .bodyComposition
                ))
            } else if delta < -0.3 {
                results.append(SmartInsight(
                    icon: "arrow.down.circle.fill",
                    color: "orange",
                    title: "Weight Dropping During Bulk",
                    message: "Your goal is muscle gain, but you're losing weight. You may need to increase calories to support growth.",
                    severity: .medium,
                    category: .bodyComposition
                ))
            }
        default:
            break
        }

        return results
    }

    // MARK: - Fatigue

    private func fatigueInsights(workoutHistory: [WorkoutSession], progressEntries: [ProgressEntry]) -> [SmartInsight] {
        let weekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        let twoWeeksAgo = Calendar.current.date(byAdding: .day, value: -14, to: Date()) ?? Date()

        let thisWeekEntries = progressEntries.filter { $0.date > weekAgo }
        let lastWeekEntries = progressEntries.filter { $0.date > twoWeeksAgo && $0.date <= weekAgo }

        let thisWeekSets = thisWeekEntries.reduce(0) { $0 + $1.totalSets }
        let lastWeekSets = lastWeekEntries.reduce(0) { $0 + $1.totalSets }

        guard lastWeekSets > 0 else { return [] }

        let setIncrease = Double(thisWeekSets - lastWeekSets) / Double(lastWeekSets)

        if setIncrease > 0.3 {
            return [SmartInsight(
                icon: "exclamationmark.triangle.fill",
                color: "orange",
                title: "Training Volume Spike",
                message: "Your set count jumped \(Int(setIncrease * 100))% vs last week. Sharp volume increases raise injury risk. Consider tapering next week.",
                severity: .medium,
                category: .recovery
            )]
        }

        return []
    }

    // MARK: - Deload

    private func deloadInsights(workoutHistory: [WorkoutSession], progressEntries: [ProgressEntry]) -> [SmartInsight] {
        let fourWeeksAgo = Calendar.current.date(byAdding: .weekOfYear, value: -4, to: Date()) ?? Date()
        let recentSessions = workoutHistory.filter { $0.startTime > fourWeeksAgo && $0.isCompleted }

        if recentSessions.count >= 16 {
            return [SmartInsight(
                icon: "arrow.down.to.line",
                color: "blue",
                title: "Consider a Deload Week",
                message: "You've completed \(recentSessions.count) sessions in 4 weeks with no deload. A lighter week can boost long-term progress and reduce injury risk.",
                severity: .medium,
                category: .recovery
            )]
        }

        return []
    }

    // MARK: - Recommendations

    private func volumeRecommendations(muscleBalance: [MuscleBalanceEntry], profile: UserProfile) -> [Recommendation] {
        var recs: [Recommendation] = []

        let overtrained = muscleBalance.filter { $0.percentOfAverage > 1.2 }
        let undertrained = muscleBalance.filter { $0.percentOfAverage < 0.8 }

        if let top = overtrained.first, let bottom = undertrained.first {
            recs.append(Recommendation(
                type: .volumeImbalance,
                title: "Balance \(top.muscle) and \(bottom.muscle)",
                message: "\(top.muscle) volume is \(Int((top.percentOfAverage - 1.0) * 100))% above average while \(bottom.muscle) is \(Int((1.0 - bottom.percentOfAverage) * 100))% below. Shift a set or two from \(top.muscle.lowercased()) to \(bottom.muscle.lowercased()).",
                priority: 3
            ))
        }

        for entry in undertrained.prefix(2) {
            let focusMuscleNames = profile.focusMuscles.map { $0.displayName }
            if focusMuscleNames.contains(entry.muscle) {
                recs.append(Recommendation(
                    type: .volumeImbalance,
                    title: "Prioritize \(entry.muscle)",
                    message: "\(entry.muscle) is one of your focus muscles but volume is below your recent average. Add 2-3 extra sets this week.",
                    priority: 4
                ))
            }
        }

        return recs
    }

    private func progressionRecommendations(personalRecords: [PersonalRecord], workoutHistory: [WorkoutSession]) -> [Recommendation] {
        var recs: [Recommendation] = []

        let recentPRs = personalRecords
            .sorted { $0.date > $1.date }
            .prefix(3)

        for pr in recentPRs {
            guard let exercise = library.exercise(byId: pr.exerciseId) else { continue }
            if exercise.category == .compound {
                let suggestedWeight = pr.weight + (exercise.primaryMuscle.region == .lower ? 5.0 : 2.5)
                recs.append(Recommendation(
                    type: .progressionSuggestion,
                    title: "Progress \(exercise.name)",
                    message: "You hit \(Int(pr.weight))kg × \(pr.reps). Try \(String(format: "%.1f", suggestedWeight))kg next session, aiming for the same reps.",
                    priority: 2
                ))
            }
        }

        return recs
    }

    private func recoveryRecommendations(workoutHistory: [WorkoutSession], profile: UserProfile) -> [Recommendation] {
        var recs: [Recommendation] = []

        let twoDaysAgo = Calendar.current.date(byAdding: .day, value: -2, to: Date()) ?? Date()
        let recentCount = workoutHistory.filter { $0.startTime > twoDaysAgo && $0.isCompleted }.count

        if recentCount >= 3 {
            recs.append(Recommendation(
                type: .recoveryConcern,
                title: "Recovery Day Recommended",
                message: "You've trained \(recentCount) times in 2 days. A rest day will help your muscles repair and grow stronger. Consider light stretching or a walk instead.",
                priority: 4
            ))
        }

        if profile.recoveryCapacity == .low && recentCount >= 2 {
            recs.append(Recommendation(
                type: .recoveryConcern,
                title: "Manage Training Load",
                message: "With your current recovery capacity, spacing sessions with rest days is important. Avoid back-to-back heavy sessions.",
                priority: 3
            ))
        }

        return recs
    }

    private func exerciseSwapRecommendations(workoutHistory: [WorkoutSession], profile: UserProfile) -> [Recommendation] {
        var recs: [Recommendation] = []

        let recentExercises = Set(workoutHistory.prefix(8).flatMap(\.exerciseLogs).map(\.exerciseId))
        let focusedMuscles = profile.focusMuscles

        for muscle in focusedMuscles.prefix(2) {
            let muscleExercises = library.exercises(forMuscle: muscle)
            let unused = muscleExercises.filter { !recentExercises.contains($0.id) && $0.category == .compound }
            if let suggestion = unused.first {
                recs.append(Recommendation(
                    type: .exerciseSwap,
                    title: "Try \(suggestion.name)",
                    message: "Since \(muscle.displayName.lowercased()) is a focus area, adding \(suggestion.name) could provide a new stimulus for growth.",
                    priority: 1
                ))
            }
        }

        return recs
    }

    private func planRecommendations(profile: UserProfile, workoutHistory: [WorkoutSession]) -> [Recommendation] {
        var recs: [Recommendation] = []

        let weekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        let weeklyCount = workoutHistory.filter { $0.startTime > weekAgo && $0.isCompleted }.count

        if weeklyCount > profile.daysPerWeek + 1 {
            recs.append(Recommendation(
                type: .splitSuggestion,
                title: "You're Training More Than Planned",
                message: "You completed \(weeklyCount) sessions vs your \(profile.daysPerWeek)-day plan. Consider updating your plan to match your actual frequency for better volume management.",
                priority: 2
            ))
        }

        return recs
    }

    // MARK: - Plateau Insights

    private func plateauInsights(progressionStates: [ExerciseProgressionState]) -> [SmartInsight] {
        var results: [SmartInsight] = []

        let plateaued = progressionStates.filter { $0.plateauStatus == .plateaued }
        let regressing = progressionStates.filter { $0.plateauStatus == .regressing }

        for state in regressing.prefix(2) {
            let name = library.exercise(byId: state.exerciseId)?.name ?? state.exerciseId
            results.append(SmartInsight(
                icon: "arrow.down.right",
                color: "red",
                title: "\(name) Performance Declining",
                message: "\(state.coachNote) Consider reducing load by 10-15% and rebuilding with strict form.",
                severity: .high,
                category: .progression
            ))
        }

        for state in plateaued.prefix(2) {
            let name = library.exercise(byId: state.exerciseId)?.name ?? state.exerciseId
            results.append(SmartInsight(
                icon: "pause.circle.fill",
                color: "orange",
                title: "\(name) Has Plateaued",
                message: "\(state.coachNote)",
                severity: .medium,
                category: .progression
            ))
        }

        let stallingCount = progressionStates.filter { $0.plateauStatus == .stalling }.count
        if stallingCount >= 3 {
            results.append(SmartInsight(
                icon: "arrow.right",
                color: "yellow",
                title: "Multiple Exercises Stalling",
                message: "\(stallingCount) exercises are showing slowed progress. This may signal accumulated fatigue. Consider a lighter week or exercise rotation.",
                severity: .medium,
                category: .progression
            ))
        }

        return results
    }

    // MARK: - Phase Insights

    private func phaseInsights(phase: TrainingPhase, profile: UserProfile) -> [SmartInsight] {
        switch phase {
        case .deload:
            return [SmartInsight(
                icon: "arrow.down.to.line",
                color: "purple",
                title: "Deload Phase Active",
                message: "This is a planned recovery period. Focus on form, reduce intensity, and let your body adapt to recent training stress.",
                severity: .low,
                category: .recovery
            )]
        case .fatigueManagement:
            return [SmartInsight(
                icon: "heart.circle.fill",
                color: "orange",
                title: "Recovery Phase",
                message: "Managing accumulated fatigue. Volume and intensity are reduced to protect long-term progress. You'll push harder next phase.",
                severity: .low,
                category: .recovery
            )]
        case .push:
            return [SmartInsight(
                icon: "arrow.up.right.circle.fill",
                color: "green",
                title: "Push Phase — Time to Progress",
                message: "You're in a progression phase. Aim for small improvements each session. Recovery supports harder training right now.",
                severity: .positive,
                category: .progression
            )]
        case .rebalance:
            return [SmartInsight(
                icon: "arrow.left.arrow.right",
                color: "cyan",
                title: "Rebalance Phase",
                message: "Addressing muscle imbalances and weak points. Some exercises may change to prioritize undertrained areas.",
                severity: .low,
                category: .volumeBalance
            )]
        case .build:
            return []
        }
    }

    // MARK: - Volume Landmark Insights

    private func volumeLandmarkInsights(landmarks: [VolumeLandmark], profile: UserProfile) -> [SmartInsight] {
        var results: [SmartInsight] = []

        let belowMEV = landmarks.filter { $0.status == .belowMEV }
        let aboveMRV = landmarks.filter { $0.status == .aboveMRV }

        for lm in belowMEV.prefix(2) {
            let isFocus = profile.focusMuscles.contains(where: { $0.displayName == lm.muscleGroup })
            results.append(SmartInsight(
                icon: "exclamationmark.circle.fill",
                color: isFocus ? "red" : "orange",
                title: "\(lm.muscleGroup) Below Minimum Effective Volume",
                message: "At \(lm.currentWeeklySets) sets/week, \(lm.muscleGroup.lowercased()) isn't receiving enough stimulus to grow. Minimum effective volume is \(lm.minimumEffectiveVolume) sets.",
                severity: isFocus ? .high : .medium,
                category: .volumeBalance
            ))
        }

        for lm in aboveMRV.prefix(1) {
            results.append(SmartInsight(
                icon: "exclamationmark.triangle.fill",
                color: "orange",
                title: "\(lm.muscleGroup) Exceeding Recovery Capacity",
                message: "At \(lm.currentWeeklySets) sets/week, \(lm.muscleGroup.lowercased()) volume exceeds your maximum recoverable volume (\(lm.maximumRecoverableVolume) sets). This can lead to overtraining.",
                severity: .medium,
                category: .volumeBalance
            ))
        }

        return results
    }

    // MARK: - Exercise-Specific Progression Insights

    private func exerciseSpecificProgressionInsights(progressionStates: [ExerciseProgressionState], profile: UserProfile) -> [SmartInsight] {
        var results: [SmartInsight] = []

        let readyToProgress = progressionStates.filter {
            $0.plateauStatus == .progressing && $0.sessionCount >= 3 && $0.recommendedStrategy == .loadFirst
        }

        for state in readyToProgress.prefix(2) {
            guard let exercise = library.exercise(byId: state.exerciseId) else { continue }
            if let nextWeight = state.suggestedNextWeight {
                results.append(SmartInsight(
                    icon: "arrow.up.right",
                    color: "green",
                    title: "Ready to Progress: \(exercise.name)",
                    message: "Performance is stable at \(Int(state.lastWeight))kg × \(state.lastReps). Try \(String(format: "%.1f", nextWeight))kg next session.",
                    severity: .positive,
                    category: .progression
                ))
            }
        }

        let needsConsolidation = progressionStates.filter {
            $0.recommendedStrategy == .holdAndConsolidate && $0.consecutiveSamePerformance >= 2
        }

        for state in needsConsolidation.prefix(1) {
            guard let exercise = library.exercise(byId: state.exerciseId) else { continue }
            results.append(SmartInsight(
                icon: "pause.circle",
                color: "blue",
                title: "Hold Steady: \(exercise.name)",
                message: "Performance isn't stable yet. Repeat at \(Int(state.lastWeight))kg × \(state.lastReps) with focus on quality before increasing.",
                severity: .low,
                category: .progression
            ))
        }

        return results
    }

    // MARK: - Smart Progression Recommendations

    private func smartProgressionRecommendations(progressionStates: [ExerciseProgressionState], phase: TrainingPhase) -> [Recommendation] {
        var recs: [Recommendation] = []

        guard phase == .push || phase == .build else { return recs }

        let progressing = progressionStates.filter { $0.plateauStatus == .progressing && $0.suggestedNextWeight != nil }
        for state in progressing.prefix(2) {
            guard let exercise = library.exercise(byId: state.exerciseId),
                  let nextWeight = state.suggestedNextWeight else { continue }

            let strategyLabel = state.recommendedStrategy.displayName.lowercased()
            recs.append(Recommendation(
                type: .progressionSuggestion,
                title: "\(state.recommendedStrategy.displayName): \(exercise.name)",
                message: "Strategy: \(strategyLabel). Try \(String(format: "%.1f", nextWeight))kg\(state.suggestedNextReps.map { " for \($0) reps" } ?? ""). \(state.recommendedStrategy.explanation)",
                priority: 3
            ))
        }

        return recs
    }

    // MARK: - Plateau Recommendations

    private func plateauRecommendations(progressionStates: [ExerciseProgressionState]) -> [Recommendation] {
        var recs: [Recommendation] = []

        let plateaued = progressionStates.filter { $0.plateauStatus == .plateaued || $0.plateauStatus == .regressing }
        for state in plateaued.prefix(2) {
            guard let exercise = library.exercise(byId: state.exerciseId) else { continue }

            if state.plateauStatus == .regressing {
                recs.append(Recommendation(
                    type: .exerciseSwap,
                    title: "Consider Replacing \(exercise.name)",
                    message: "Performance is declining on this exercise. A fresh variation targeting \(exercise.primaryMuscle.displayName.lowercased()) may restart progress.",
                    priority: 4
                ))
            } else {
                let strategy = state.recommendedStrategy
                recs.append(Recommendation(
                    type: .progressionSuggestion,
                    title: "Unstick \(exercise.name)",
                    message: "This lift has plateaued. Recommended approach: \(strategy.displayName.lowercased()). \(strategy.explanation)",
                    priority: 3
                ))
            }
        }

        return recs
    }
}

nonisolated enum ReplacementReason: Sendable {
    case injuryAvoidance
    case equipmentUnavailable
    case samePattern
    case easier
    case harder
    case general
}
