import Foundation

struct CoachingEngine {
    let library = ExerciseLibrary.shared
    private let progressionEngine = ProgressionEngine()
    private let volumeEngine = SmartVolumeEngine()

    private func muscleDisplayName(_ raw: String) -> String {
        switch raw.lowercased() {
        case "back": return "Back"
        case "chest": return "Chest"
        case "shoulders": return "Shoulders"
        case "arms": return "Arms"
        case "quads": return "Quads"
        case "hamstrings": return "Hamstrings"
        case "glutes": return "Glutes"
        case "calves": return "Calves"
        case "abs": return "Abs"
        default: return raw
        }
    }

    private func lowWorkDetail(for rawMuscle: String) -> String {
        "\(muscleDisplayName(rawMuscle)) work is low. Add a little work when the next session has room."
    }

    private func coachDecimal(_ value: Double) -> String {
        let rounded = (value * 10).rounded() / 10
        let format = abs(rounded.rounded() - rounded) < 0.01 ? "%.0f" : "%.1f"
        return String(format: format, rounded).replacingOccurrences(of: ".", with: ",")
    }

    private func coachLoad(_ value: Double) -> String {
        "\(coachDecimal(value)) kg"
    }

    private func coachMultiplier(_ value: Double) -> String {
        "\(coachDecimal(value))×"
    }

    private func safeShortWindowTrainingLoadMessage(count: Int, days: Int) -> String {
        if count > 3 {
            return "Keep today lighter and keep the next session easy."
        }
        return "\(count) sessions logged in the last \(days) days. Keep today lighter."
    }

    func generateInsights(
        profile: UserProfile,
        workoutHistory: [WorkoutSession],
        progressEntries: [ProgressEntry],
        personalRecords: [PersonalRecord],
        currentPlan: WorkoutPlan?,
        muscleBalance: [MuscleBalanceEntry],
        progressionStates: [ExerciseProgressionState] = [],
        phase: TrainingPhase = .build,
        volumeLandmarks: [VolumeLandmark] = [],
        confidence: CoachingConfidence = .high
    ) -> [SmartInsight] {
        var insights: [SmartInsight] = []

        // When confidence is low, we deliberately stay quieter — only recovery / phase /
        // plateau signals that survive on thin data. Volume imbalance, push/pull ratio,
        // and 1-week frequency comparisons need more data to be credible.
        let completedCount = workoutHistory.filter(\.isCompleted).count

        if confidence >= .moderate {
            insights.append(contentsOf: volumeImbalanceInsights(muscleBalance: muscleBalance, profile: profile))
            insights.append(contentsOf: pushPullBalanceInsights(workoutHistory: workoutHistory))
            insights.append(contentsOf: upperLowerBalanceInsights(muscleBalance: muscleBalance))
            insights.append(contentsOf: frequencyInsights(workoutHistory: workoutHistory, profile: profile))
            insights.append(contentsOf: bodyweightInsights(progressEntries: progressEntries, profile: profile))
        }
        insights.append(contentsOf: recoveryInsights(workoutHistory: workoutHistory, profile: profile))
        insights.append(contentsOf: progressionInsights(personalRecords: personalRecords, workoutHistory: workoutHistory))
        if confidence >= .moderate {
            insights.append(contentsOf: consistencyInsights(workoutHistory: workoutHistory))
            insights.append(contentsOf: fatigueInsights(workoutHistory: workoutHistory, progressEntries: progressEntries))
            insights.append(contentsOf: deloadInsights(workoutHistory: workoutHistory, progressEntries: progressEntries))
        }
        if completedCount >= 3 {
            insights.append(contentsOf: plateauInsights(progressionStates: progressionStates))
        }
        insights.append(contentsOf: phaseInsights(phase: phase, profile: profile))
        if confidence >= .moderate {
            insights.append(contentsOf: volumeLandmarkInsights(landmarks: volumeLandmarks, profile: profile))
            insights.append(contentsOf: exerciseSpecificProgressionInsights(progressionStates: progressionStates, profile: profile))
        }

        // Trim thin-signal cases: cap total and soften severity when confidence is low.
        let sorted = insights.sorted { $0.severityRank > $1.severityRank }
        if confidence == .low {
            return Array(sorted.prefix(3)).map { softenForLowConfidence($0) }
        }
        if confidence == .moderate {
            return Array(sorted.prefix(6))
        }
        return sorted
    }

    private func softenForLowConfidence(_ insight: SmartInsight) -> SmartInsight {
        let severity: InsightSeverity = insight.severity == .high ? .medium : insight.severity
            return SmartInsight(
                id: insight.id,
                icon: insight.icon,
                color: insight.color,
                title: insight.title,
                message: insight.message + " STRQ is still calibrating - use this as a rough direction.",
                severity: severity,
                category: insight.category
            )
        }

    func generateRecommendations(
        profile: UserProfile,
        workoutHistory: [WorkoutSession],
        progressEntries: [ProgressEntry],
        personalRecords: [PersonalRecord],
        muscleBalance: [MuscleBalanceEntry],
        progressionStates: [ExerciseProgressionState] = [],
        phase: TrainingPhase = .build,
        confidence: CoachingConfidence = .high
    ) -> [Recommendation] {
        var recs: [Recommendation] = []

        if confidence >= .moderate {
            recs.append(contentsOf: volumeRecommendations(muscleBalance: muscleBalance, profile: profile))
            recs.append(contentsOf: exerciseSwapRecommendations(workoutHistory: workoutHistory, profile: profile))
            recs.append(contentsOf: planRecommendations(profile: profile, workoutHistory: workoutHistory))
        }
        recs.append(contentsOf: progressionRecommendations(personalRecords: personalRecords, workoutHistory: workoutHistory))
        recs.append(contentsOf: recoveryRecommendations(workoutHistory: workoutHistory, profile: profile))
        if confidence >= .moderate {
            recs.append(contentsOf: smartProgressionRecommendations(progressionStates: progressionStates, phase: phase))
            recs.append(contentsOf: plateauRecommendations(progressionStates: progressionStates))
        }

        let sorted = recs.sorted { $0.priority > $1.priority }
        if confidence == .low { return Array(sorted.prefix(2)) }
        if confidence == .moderate { return Array(sorted.prefix(5)) }
        return sorted
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
                    title: "\(muscleDisplayName(entry.muscle)) work is low",
                    message: lowWorkDetail(for: entry.muscle),
                    severity: .high,
                    category: .volumeBalance
                ))
            } else if ratio < 0.85 {
                results.append(SmartInsight(
                    icon: "arrow.down.circle.fill",
                    color: "yellow",
                    title: "\(muscleDisplayName(entry.muscle)) below average",
                    message: lowWorkDetail(for: entry.muscle),
                    severity: .medium,
                    category: .volumeBalance
                ))
            } else if ratio > 1.25 {
                results.append(SmartInsight(
                    icon: "arrow.up.circle.fill",
                    color: "orange",
                    title: "\(muscleDisplayName(entry.muscle)) volume high",
                    message: "\(muscleDisplayName(entry.muscle)) is \(Int((ratio - 1.0) * 100))% above average. Keep volume in view and don't force the next session.",
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
                title: "\(muscleDisplayName(entry.muscle)) focus check",
                message: "\(muscleDisplayName(entry.muscle)) is a focus area but sits below average. Prioritize it in the next fitting session.",
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
                title: "Push is dominating pull",
                message: "Push:Pull is \(Int(pushRatio * 100)):\(Int(pullRatio * 100)). Add row or pull-up work if the week has room.",
                severity: .medium,
                category: .movementBalance
            )]
        } else if pullRatio > 0.65 {
            return [SmartInsight(
                icon: "arrow.left.arrow.right",
                color: "orange",
                title: "Pull is dominating push",
                message: "Pull:Push is \(Int(pullRatio * 100)):\(Int(pushRatio * 100)). Add press work if the next session has room.",
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
                title: "Upper body is ahead",
                message: "Upper body is ahead. Give lower body more room next week.",
                severity: .medium,
                category: .movementBalance
            )]
        } else if ratio < 0.55 {
            return [SmartInsight(
                icon: "figure.stand",
                color: "yellow",
                title: "Lower body is ahead",
                message: "Lower body is ahead. Give upper body more room next week.",
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
                title: "High training density",
                message: safeShortWindowTrainingLoadMessage(count: recentSessions.count, days: 3),
                severity: .high,
                category: .recovery
            ))
        } else if recentSessions.count == 3 {
            results.append(SmartInsight(
                icon: "moon.fill",
                color: "yellow",
                title: "Keep today lighter",
                message: safeShortWindowTrainingLoadMessage(count: recentSessions.count, days: 3),
                severity: .medium,
                category: .recovery
            ))
        }

        if profile.sleepQuality == .poor || profile.sleepQuality == .fair {
            if recentSessions.count >= 2 {
                results.append(SmartInsight(
                    icon: "zzz",
                    color: "purple",
                    title: "Check sleep and load",
                    message: "Sleep quality and training load do not line up well right now. Plan today lighter.",
                    severity: .medium,
                    category: .recovery
                ))
            }
        }

        if profile.stressLevel == .high || profile.stressLevel == .veryHigh {
            results.append(SmartInsight(
                icon: "brain.head.profile.fill",
                color: "purple",
                title: "Watch stress",
                message: "Stress is high. Keep today lighter, use easier sets, or add more rest between hard sets.",
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
                title: "Frequency is rising",
                message: "More sessions are logged this week than last week. Keep rhythm without forcing extra volume.",
                severity: .positive,
                category: .consistency
            ))
        } else if thisWeekCount < lastWeekCount && thisWeekCount > 0 && lastWeekCount > 0 {
            results.append(SmartInsight(
                icon: "arrow.down.forward.circle.fill",
                color: "yellow",
                title: "Frequency is lower",
                message: "This week is behind last week. Plan the next session cleanly and rebuild rhythm.",
                severity: .low,
                category: .consistency
            ))
        }

        if thisWeekCount < profile.daysPerWeek && thisWeekCount > 0 {
            let gap = profile.daysPerWeek - thisWeekCount
            results.append(SmartInsight(
                icon: "calendar.badge.exclamationmark",
                color: "yellow",
                title: "Below weekly target",
                message: "\(thisWeekCount) of \(profile.daysPerWeek) planned sessions are logged. \(gap) left if the week has room.",
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
                title: "New PR: \(exerciseName)",
                message: "\(coachLoad(pr.weight)) × \(pr.reps) reps - e1RM \(coachLoad(pr.estimatedOneRepMax)). Confirm it cleanly next session.",
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
                title: "Steadiest training day: \(dayName)",
                message: "\(dayName) is your most logged day across the last 6 weeks. That is your most reliable training day.",
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
                    title: "Weight trend down",
                    message: "Body weight is down about \(coachLoad(abs(delta))) lately. Stay the course and keep watching the trend.",
                    severity: .positive,
                    category: .bodyComposition
                ))
            } else if delta > 0.3 {
                results.append(SmartInsight(
                    icon: "arrow.up.circle.fill",
                    color: "orange",
                    title: "Weight is rising in the cut",
                    message: "The goal is fat loss, but weight is trending up. Check nutrition and activity.",
                    severity: .medium,
                    category: .bodyComposition
                ))
            }
        case .muscleGain:
            if delta > 0.2 {
                results.append(SmartInsight(
                    icon: "arrow.up.circle.fill",
                    color: "green",
                    title: "Weight trend up",
                    message: "Up about \(coachLoad(delta)) lately. Fits the build phase if strength is moving too.",
                    severity: .positive,
                    category: .bodyComposition
                ))
            } else if delta < -0.3 {
                results.append(SmartInsight(
                    icon: "arrow.down.circle.fill",
                    color: "orange",
                    title: "Weight is dropping in the build",
                    message: "The goal is muscle gain, but weight is trending down. Check calories and training days.",
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
                title: "Check volume jump",
                message: "Set count is \(Int(setIncrease * 100))% above last week. Keep volume in view and avoid extra work next week.",
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
                title: "Check deload",
                message: "Recent weeks were dense. A lighter week keeps load controlled.",
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
                title: "\(muscleDisplayName(top.muscle)) and \(muscleDisplayName(bottom.muscle)) balance",
                message: "\(muscleDisplayName(top.muscle)) is above average, \(muscleDisplayName(bottom.muscle)) is below. Shift 1-2 sets in the next fitting session.",
                priority: 3
            ))
        }

        for entry in undertrained.prefix(2) {
            let focusMuscleNames = profile.focusMuscles.map { $0.displayName }
            if focusMuscleNames.contains(entry.muscle) {
                recs.append(Recommendation(
                    type: .volumeImbalance,
                    title: "\(muscleDisplayName(entry.muscle)) priority",
                    message: "\(muscleDisplayName(entry.muscle)) is a focus area but sits below recent average. Add work only if the week has room.",
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
                    title: "Add a little load: \(exercise.name)",
                    message: "\(coachLoad(pr.weight)) × \(pr.reps) was steady. Check \(coachLoad(suggestedWeight)) next session if rep quality is there.",
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
                title: "Recovery low",
                message: safeShortWindowTrainingLoadMessage(count: recentCount, days: 2),
                priority: 4
            ))
        }

        if profile.recoveryCapacity == .low && recentCount >= 2 {
            recs.append(Recommendation(
                type: .recoveryConcern,
                title: "Keep today lighter",
                message: "Recovery looks low. Add more rest between hard sessions.",
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
                    title: "\(suggestion.name) option",
                    message: "\(muscleDisplayName(muscle.displayName)) is a focus area. \(suggestion.name) can be an option if it fits the next session.",
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
                title: "More training than planned",
                message: "More than planned is logged. Keep volume in view and avoid extra work next week.",
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
                title: "\(name): Performance dropping",
                message: "\(state.coachNote) Next session lighter: reduce load by 10-15% and keep technique clean.",
                severity: .high,
                category: .progression
            ))
        }

        for state in plateaued.prefix(2) {
            let name = library.exercise(byId: state.exerciseId)?.name ?? state.exerciseId
            results.append(SmartInsight(
                icon: "pause.circle.fill",
                color: "orange",
                title: "\(name): Plateau",
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
                title: "Several lifts are stalling",
                message: "\(stallingCount) lifts are progressing more slowly. Load may be high. Check a lighter week or variation.",
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
                title: "Deload active",
                message: "Planned lighter phase. Keep technique clean and take load down.",
                severity: .low,
                category: .recovery
            )]
        case .fatigueManagement:
            return [SmartInsight(
                icon: "heart.circle.fill",
                color: "orange",
                title: "Recovery phase",
                message: "This week is lighter. Volume and intensity are reduced.",
                severity: .low,
                category: .recovery
            )]
        case .push:
            return [SmartInsight(
                icon: "arrow.up.right.circle.fill",
                color: "green",
                title: "Push phase: Check progression",
                message: "Check small increases while technique and recovery are holding.",
                severity: .positive,
                category: .progression
            )]
        case .rebalance:
            return [SmartInsight(
                icon: "arrow.left.arrow.right",
                color: "cyan",
                title: "Rebalance phase",
                message: "Focus shifts toward less-covered areas. Exercise selection may adjust for that.",
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
                title: "\(muscleDisplayName(lm.muscleGroup)) work is low",
                message: lowWorkDetail(for: lm.muscleGroup),
                severity: isFocus ? .high : .medium,
                category: .volumeBalance
            ))
        }

        for lm in aboveMRV.prefix(1) {
            results.append(SmartInsight(
                icon: "exclamationmark.triangle.fill",
                color: "orange",
                title: "\(muscleDisplayName(lm.muscleGroup)) volume check",
                message: "\(muscleDisplayName(lm.muscleGroup)) is at \(lm.currentWeeklySets) sets/week, above the target range (\(lm.maximumRecoverableVolume) sets). Keep volume in view.",
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
                    title: "Increase load: \(exercise.name)",
                    message: "\(coachLoad(state.lastWeight)) × \(state.lastReps) looks steady. Check \(coachLoad(nextWeight)) next session if quality is there.",
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
                title: "\(exercise.name): Hold steady",
                message: "Performance is not stable enough yet. Repeat \(coachLoad(state.lastWeight)) × \(state.lastReps) and confirm quality before adding load.",
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

            recs.append(Recommendation(
                type: .progressionSuggestion,
                title: state.recommendedStrategy == .loadFirst ? "Add a little load: \(exercise.name)" : "\(state.recommendedStrategy.displayName): \(exercise.name)",
                message: "Next session: \(coachLoad(nextWeight))\(state.suggestedNextReps.map { " for \($0) reps" } ?? "") if quality is there. \(state.recommendedStrategy.explanation)",
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
                    title: "Check a variation for \(exercise.name)",
                    message: "Performance is dropping on this exercise. A similar variation for \(muscleDisplayName(exercise.primaryMuscle.displayName)) can be the next move.",
                    priority: 4
                ))
            } else {
                let strategy = state.recommendedStrategy
                recs.append(Recommendation(
                    type: .progressionSuggestion,
                    title: "\(exercise.name): Break plateau",
                    message: "This lift is plateaued. Check the approach: \(strategy.displayName.lowercased()). \(strategy.explanation)",
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
