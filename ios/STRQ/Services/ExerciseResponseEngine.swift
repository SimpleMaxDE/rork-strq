import Foundation

// Derives `ExerciseFamilyResponseProfile` from existing STRQ data
// (workoutHistory, progressionStates). Runs deterministically — same inputs
// always produce the same response profile. Intentionally conservative:
// signals only diverge from neutral once real exposure exists, and stay
// clamped so noisy days can't swing plans.

nonisolated struct ExerciseResponseEngine: Sendable {
    private let familyService = ExerciseFamilyService.shared
    private let library = ExerciseLibrary.shared

    // Tunable horizons.
    private let recentWindowDays: Int = 21
    private let minSetsForResponse: Int = 2
    // Minimum corroborating sessions before a note signal is allowed to
    // meaningfully shift family scores. Single-day notes stay quiet.
    private let minNoteCorroboration: Int = 2

    func compute(
        workoutHistory: [WorkoutSession],
        progressionStates: [ExerciseProgressionState],
        now: Date = Date()
    ) -> ExerciseFamilyResponseProfile {
        guard !workoutHistory.isEmpty || !progressionStates.isEmpty else {
            return .empty
        }

        // Collect per-family raw signals.
        var snapshots: [String: FamilySnapshot] = [:]
        let recentCutoff = Calendar.current.date(byAdding: .day, value: -recentWindowDays, to: now) ?? now

        for session in workoutHistory where session.isCompleted {
            // Families touched this session → used for note attribution.
            var sessionSetsByFamily: [String: Int] = [:]
            var sessionTotalSets: Int = 0

            for log in session.exerciseLogs {
                guard let family = familyService.family(forExercise: log.exerciseId) else { continue }
                var snap = snapshots[family.id] ?? FamilySnapshot(familyId: family.id)

                let totalSets = log.sets.count
                let completedSets = log.sets.filter(\.isCompleted).count
                guard totalSets >= minSetsForResponse else { continue }

                snap.sessionCount += 1
                snap.plannedSets += totalSets
                snap.completedSets += completedSets
                if session.startTime >= recentCutoff {
                    snap.recentExposure += 1
                }

                // Tolerance signal from set quality markers.
                for set in log.sets where set.isCompleted {
                    if let q = set.quality {
                        switch q {
                        case .onTarget: snap.toleranceAccumulator += 1.0
                        case .tooEasy:  snap.toleranceAccumulator += 0.4
                        case .grinder:  snap.toleranceAccumulator -= 0.4
                        case .formBreakdown: snap.toleranceAccumulator -= 1.0
                        case .pain: snap.toleranceAccumulator -= 2.0
                        }
                        snap.qualityObservations += 1
                    }
                }

                snap.lastSeen = max(snap.lastSeen ?? session.startTime, session.startTime)
                snapshots[family.id] = snap
                sessionSetsByFamily[family.id, default: 0] += max(completedSets, totalSets)
                sessionTotalSets += max(completedSets, totalSets)
            }

            // Session-level note interpretation — apply only when a clean,
            // high-signal keyword is present. Weighted by each family's share
            // of the session so dominant families absorb more of the signal.
            // Corroboration (>= minNoteCorroboration sessions) is required
            // before the signal can actually move ranking.
            if sessionTotalSets > 0,
               let signal = Self.interpretNote(session.notes) {
                for (fid, sets) in sessionSetsByFamily {
                    var snap = snapshots[fid] ?? FamilySnapshot(familyId: fid)
                    let share = Double(sets) / Double(sessionTotalSets)
                    switch signal {
                    case .pain:
                        snap.painNoteSessions += 1
                        snap.painNoteWeight += share
                    case .tooHard:
                        snap.hardNoteSessions += 1
                        snap.hardNoteWeight += share
                    case .tooEasy:
                        snap.easyNoteSessions += 1
                        snap.easyNoteWeight += share
                    case .positive:
                        snap.positiveNoteSessions += 1
                        snap.positiveNoteWeight += share
                    }
                    snapshots[fid] = snap
                }
            }
        }

        // Fold progression signal from `progressionStates`.
        for state in progressionStates {
            guard let family = familyService.family(forExercise: state.exerciseId) else { continue }
            var snap = snapshots[family.id] ?? FamilySnapshot(familyId: family.id)

            let progDelta: Double
            switch state.plateauStatus {
            case .progressing: progDelta = 1.0
            case .stalling: progDelta = -0.2
            case .plateaued: progDelta = -0.8
            case .regressing: progDelta = -1.2
            }
            // Weight progression signal by how much data we have for that
            // specific exercise so one-session bounces don't dominate.
            let weight = min(1.0, Double(state.sessionCount) / 6.0)
            snap.progressionAccumulator += progDelta * weight
            snap.progressionObservations += weight
            snapshots[family.id] = snap
        }

        // Normalize into PersonalExerciseResponse values.
        let prior = ExerciseFamilyPriorsCatalog.self
        var responses: [String: PersonalExerciseResponse] = [:]
        responses.reserveCapacity(snapshots.count)

        for (familyId, snap) in snapshots {
            let adherence: Double = {
                guard snap.plannedSets > 0 else { return 1.0 }
                return (Double(snap.completedSets) / Double(snap.plannedSets))
                    .clamped(to: 0...1)
            }()

            let progression: Double = {
                guard snap.progressionObservations > 0 else { return 0 }
                let raw = snap.progressionAccumulator / snap.progressionObservations
                return raw.clamped(to: -1...1)
            }()

            let jointTolerance: Double = {
                guard snap.qualityObservations > 0 else { return 0 }
                let raw = snap.toleranceAccumulator / Double(snap.qualityObservations)
                // Compress into -1...1; quality markers already span that range.
                return raw.clamped(to: -1...1)
            }()

            // Fatigue cost — start at the prior, then nudge based on tolerance
            // and adherence. Negative tolerance or low adherence → higher
            // perceived fatigue cost for this user.
            let p = prior.prior(forFamily: familyId)
            var fatigue = p.fatigueCost
            if jointTolerance < -0.2 { fatigue += 0.1 }
            if jointTolerance > 0.3 { fatigue -= 0.05 }
            if adherence < 0.6 { fatigue += 0.1 }

            // Corroborated note signals — softly shift tolerance / fatigue
            // when the user has repeatedly left high-signal notes. Capped,
            // and only active once the corroboration floor is cleared so one
            // bad note can never tank a family.
            var toleranceDelta: Double = 0
            if snap.painNoteSessions >= minNoteCorroboration {
                let d = min(0.35, snap.painNoteWeight * 0.18)
                toleranceDelta -= d
                fatigue += d * 0.4
            }
            if snap.hardNoteSessions >= minNoteCorroboration {
                fatigue += min(0.18, snap.hardNoteWeight * 0.08)
            }
            if snap.easyNoteSessions >= minNoteCorroboration {
                toleranceDelta += min(0.1, snap.easyNoteWeight * 0.04)
            }
            if snap.positiveNoteSessions >= minNoteCorroboration {
                toleranceDelta += min(0.1, snap.positiveNoteWeight * 0.04)
            }
            let jointToleranceAdjusted = (jointTolerance + toleranceDelta).clamped(to: -1...1)
            fatigue = fatigue.clamped(to: 0...1)

            // Confidence: ramps from 0 to 1 across confidence window; weighted
            // by recency so dormant families fade toward neutral.
            let exposureConfidence = min(
                1.0,
                Double(snap.sessionCount) / Double(PersonalExerciseResponse.confidenceSaturationSessions)
            )
            let recencyBoost = snap.recentExposure > 0 ? 1.0 : 0.6
            let confidence = (exposureConfidence * recencyBoost).clamped(to: 0...1)

            responses[familyId] = PersonalExerciseResponse(
                familyId: familyId,
                progressionSignal: progression,
                fatigueCost: fatigue,
                jointTolerance: jointToleranceAdjusted,
                adherenceScore: adherence,
                confidence: confidence,
                sessionCount: snap.sessionCount,
                recentExposure: snap.recentExposure,
                lastUpdated: snap.lastSeen ?? now
            )
        }

        return ExerciseFamilyResponseProfile(familyResponses: responses, lastUpdated: now)
    }

    // MARK: - Scoring adjustments

    /// Personal-response adjustment to add on top of the base heuristic score
    /// during plan generation. Returns a value centered on 0. Capped to
    /// prevent a single strong/weak data point from dominating selection.
    static func personalAdjustment(
        for exercise: Exercise,
        role: PlanExerciseRole,
        profile: ExerciseFamilyResponseProfile,
        phase: TrainingPhase,
        recoveryScore: Int
    ) -> Double {
        guard let familyId = ExerciseFamilyService.shared.family(forExercise: exercise.id)?.id,
              let response = profile.response(forFamily: familyId),
              response.hasUsableData
        else { return 0 }

        // Confidence scales everything — weak data barely moves ranking.
        let c = response.confidence

        var adjustment: Double = 0

        // Progression & adherence contribute positively.
        adjustment += response.progressionSignal * 8 * c
        adjustment += (response.adherenceScore - 0.8) * 6 * c

        // Joint tolerance — strong negative signal demotes family.
        adjustment += response.jointTolerance * 4 * c

        // Fatigue cost — penalize only when recovery isn't great.
        let fatiguePenalty = (response.fatigueCost - 0.5)
        if recoveryScore < 65 {
            adjustment -= fatiguePenalty * 8 * c
        } else {
            adjustment -= fatiguePenalty * 2 * c
        }

        // Phase-aware interpretation — deload / fatigue management weight the
        // fatigue penalty more heavily; push phase pulls stronger families up.
        switch phase {
        case .deload, .fatigueManagement:
            adjustment -= fatiguePenalty * 4 * c
            if response.jointTolerance < 0 {
                adjustment += response.jointTolerance * 2 * c
            }
        case .push:
            if response.progressionSignal > 0 {
                adjustment += response.progressionSignal * 3 * c
            }
        case .build, .rebalance:
            break
        }

        // Stimulus-to-fatigue tempering — progressing but fatigue-heavy and
        // poorly tolerated should NOT rank the same as progressing + well
        // tolerated. Small deterministic penalty when the user is paying too
        // much for the gain. Conservative: only fires on clear combined data.
        if response.progressionSignal > 0.3 &&
           response.fatigueCost > 0.7 &&
           response.jointTolerance < 0.2 {
            adjustment -= 4 * c
        }
        // Conversely, clearly tolerated + progressing families get a small
        // extra nudge up — the sweet spot for this user.
        if response.progressionSignal > 0.4 &&
           response.fatigueCost < 0.5 &&
           response.jointTolerance > 0.3 {
            adjustment += 2 * c
        }

        // Role guardrails — isolations shouldn't swing as hard as anchors.
        switch role {
        case .anchor, .secondary:
            break
        case .accessory, .isolation:
            adjustment *= 0.8
        }

        // Final clamp — no personal adjustment should ever swing a single
        // pick by more than ~16 points of raw score. This keeps generation
        // stable even with unusual history.
        return adjustment.clamped(to: -16...16)
    }

    /// Adjustment for swap ranking. Same idea as generation but tuned for
    /// per-candidate re-ranking — slightly softer since swap already carries
    /// intent-level filters.
    static func swapAdjustment(
        for candidate: Exercise,
        replacing original: Exercise,
        profile: ExerciseFamilyResponseProfile,
        recoveryScore: Int
    ) -> Double {
        let famService = ExerciseFamilyService.shared
        guard let famId = famService.family(forExercise: candidate.id)?.id,
              let response = profile.response(forFamily: famId),
              response.hasUsableData
        else { return 0 }

        let c = response.confidence
        var adj: Double = 0

        adj += response.progressionSignal * 5 * c
        adj += (response.adherenceScore - 0.8) * 4 * c
        adj += response.jointTolerance * 3 * c

        let fatiguePenalty = (response.fatigueCost - 0.5)
        if recoveryScore < 60 {
            adj -= fatiguePenalty * 6 * c
        }

        // If candidate's family has stronger personal data than the original's,
        // give a small additional nudge — the user demonstrably does better on
        // the candidate family.
        if let origFam = famService.family(forExercise: original.id)?.id,
           origFam != famId,
           let origResponse = profile.response(forFamily: origFam),
           origResponse.hasUsableData {
            let delta = (response.progressionSignal - origResponse.progressionSignal)
                + (response.adherenceScore - origResponse.adherenceScore) * 0.5
            adj += delta * 4 * min(c, origResponse.confidence)
        }

        return adj.clamped(to: -10...10)
    }

    // MARK: - Internals

    private struct FamilySnapshot {
        let familyId: String
        var sessionCount: Int = 0
        var plannedSets: Int = 0
        var completedSets: Int = 0
        var recentExposure: Int = 0
        var toleranceAccumulator: Double = 0
        var qualityObservations: Int = 0
        var progressionAccumulator: Double = 0
        var progressionObservations: Double = 0
        var lastSeen: Date?
        // Note-derived corroboration counters (per session that contained the
        // signal) plus share-weighted magnitude (family's share of session sets).
        var painNoteSessions: Int = 0
        var painNoteWeight: Double = 0
        var hardNoteSessions: Int = 0
        var hardNoteWeight: Double = 0
        var easyNoteSessions: Int = 0
        var easyNoteWeight: Double = 0
        var positiveNoteSessions: Int = 0
        var positiveNoteWeight: Double = 0
    }

    // MARK: - Note interpretation

    enum NoteSignal: Sendable { case pain, tooHard, tooEasy, positive }

    static func interpretNote(_ raw: String) -> NoteSignal? {
        let s = raw
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
        guard !s.isEmpty else { return nil }

        // Order matters — pain wins over fatigue wins over fatigue-positive.
        let painTerms = ["pain", "hurt", "tweak", "injur", "sharp", "pinch", "aggravat", "flare", "sore joint", "bad knee", "bad shoulder", "bad back"]
        if painTerms.contains(where: { s.contains($0) }) { return .pain }

        let hardTerms = ["smoked", "crushed me", "gassed", "fried", "cooked", "brutal", "wrecked", "destroyed", "too hard", "way too hard", "couldn't finish", "couldnt finish", "exhaust"]
        if hardTerms.contains(where: { s.contains($0) }) { return .tooHard }

        let easyTerms = ["too easy", "too light", "no challenge", "sandbag", "felt weak", "weight was light"]
        if easyTerms.contains(where: { s.contains($0) }) { return .tooEasy }

        let goodTerms = ["felt strong", "felt great", "felt good", "felt solid", "crisp", "snappy", "dialed", "dialled", "moved well"]
        if goodTerms.contains(where: { s.contains($0) }) { return .positive }

        return nil
    }
}

nonisolated extension Double {
    fileprivate func clamped(to range: ClosedRange<Double>) -> Double {
        min(range.upperBound, max(range.lowerBound, self))
    }
}
