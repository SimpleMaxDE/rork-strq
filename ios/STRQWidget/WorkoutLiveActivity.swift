import ActivityKit
import WidgetKit
import SwiftUI

@available(iOS 16.1, *)
struct WorkoutLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: WorkoutActivityAttributes.self) { context in
            lockScreen(context: context)
                .activityBackgroundTint(Color.black)
                .activitySystemActionForegroundColor(.white)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(context.state.dayName.uppercased())
                            .font(.system(size: 9, weight: .black))
                            .tracking(1.0)
                            .foregroundStyle(liveSteel)
                        Text(context.state.exerciseName)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(.white)
                            .lineLimit(1)
                    }
                }
                DynamicIslandExpandedRegion(.trailing) {
                    if context.state.isCompleted {
                        Label("Done", systemImage: "checkmark.circle.fill")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(.green)
                    } else if let rest = context.state.restEndsAt, rest > Date() {
                        VStack(alignment: .trailing, spacing: 1) {
                            Text("REST")
                                .font(.system(size: 9, weight: .heavy))
                                .tracking(0.8)
                                .foregroundStyle(liveSteel)
                            Text(timerInterval: Date()...rest, countsDown: true)
                                .font(.system(size: 16, weight: .heavy, design: .rounded).monospacedDigit())
                                .foregroundStyle(.orange)
                                .multilineTextAlignment(.trailing)
                                .frame(maxWidth: 60)
                        }
                    } else {
                        VStack(alignment: .trailing, spacing: 1) {
                            Text("SET")
                                .font(.system(size: 9, weight: .heavy))
                                .tracking(0.8)
                                .foregroundStyle(liveSteel)
                            Text("\(context.state.currentSetNumber)/\(context.state.totalSets)")
                                .font(.system(size: 16, weight: .heavy, design: .rounded).monospacedDigit())
                                .foregroundStyle(.white)
                        }
                    }
                }
                DynamicIslandExpandedRegion(.bottom) {
                    VStack(spacing: 6) {
                        ProgressView(value: progress(context.state))
                            .tint(.white)
                        HStack(spacing: 6) {
                            Text("Exercise \(context.state.currentExerciseIndex + 1) of \(context.state.totalExercises)")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundStyle(.white.opacity(0.7))
                            Spacer()
                            if let next = context.state.nextExerciseName, !context.state.isCompleted {
                                HStack(spacing: 3) {
                                    Image(systemName: "arrow.right")
                                        .font(.system(size: 9, weight: .bold))
                                    Text(next)
                                        .lineLimit(1)
                                }
                                .font(.system(size: 11, weight: .medium))
                                .foregroundStyle(.white.opacity(0.55))
                            }
                        }
                    }
                }
            } compactLeading: {
                Image(systemName: "dumbbell.fill")
                    .foregroundStyle(.white)
            } compactTrailing: {
                if context.state.isCompleted {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                } else if let rest = context.state.restEndsAt, rest > Date() {
                    Text(timerInterval: Date()...rest, countsDown: true)
                        .monospacedDigit()
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(.orange)
                        .frame(maxWidth: 44)
                } else {
                    Text("\(context.state.currentSetNumber)/\(context.state.totalSets)")
                        .font(.system(size: 12, weight: .bold).monospacedDigit())
                        .foregroundStyle(.white)
                }
            } minimal: {
                if let rest = context.state.restEndsAt, rest > Date(), !context.state.isCompleted {
                    Image(systemName: "timer")
                        .foregroundStyle(.orange)
                } else {
                    Image(systemName: "dumbbell.fill")
                        .foregroundStyle(.white)
                }
            }
            .keylineTint(.white)
        }
    }

    private func progress(_ state: WorkoutActivityAttributes.ContentState) -> Double {
        guard state.totalSessionSets > 0 else { return 0 }
        return min(1, Double(state.completedSets) / Double(state.totalSessionSets))
    }

    @ViewBuilder
    private func lockScreen(context: ActivityViewContext<WorkoutActivityAttributes>) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .center, spacing: 10) {
                Image(systemName: "dumbbell.fill")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(liveSteel)
                Text(context.state.dayName.uppercased())
                    .font(.system(size: 10, weight: .black))
                    .tracking(1.2)
                    .foregroundStyle(liveSteel)
                Spacer()
                if context.state.isCompleted {
                    Label("Complete", systemImage: "checkmark.circle.fill")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(.green)
                } else {
                    Text(timerInterval: context.state.startedAt...Date().addingTimeInterval(60 * 60 * 4), countsDown: false)
                        .monospacedDigit()
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(.white.opacity(0.7))
                        .frame(maxWidth: 60, alignment: .trailing)
                }
            }

            HStack(alignment: .center, spacing: 14) {
                VStack(alignment: .leading, spacing: 3) {
                    Text(context.state.exerciseName)
                        .font(.system(size: 17, weight: .heavy))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                    HStack(spacing: 6) {
                        Text("Exercise \(context.state.currentExerciseIndex + 1)/\(context.state.totalExercises)")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(.white.opacity(0.65))
                        if !context.state.isCompleted {
                            Text("·")
                                .foregroundStyle(.white.opacity(0.3))
                            Text("Set \(context.state.currentSetNumber)/\(context.state.totalSets)")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundStyle(.white.opacity(0.65))
                        }
                    }
                }
                Spacer()
                if !context.state.isCompleted, let rest = context.state.restEndsAt, rest > Date() {
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("REST")
                            .font(.system(size: 9, weight: .heavy))
                            .tracking(1.0)
                            .foregroundStyle(liveSteel)
                        Text(timerInterval: Date()...rest, countsDown: true)
                            .monospacedDigit()
                            .font(.system(size: 20, weight: .heavy, design: .rounded))
                            .foregroundStyle(.orange)
                            .multilineTextAlignment(.trailing)
                            .frame(maxWidth: 80)
                    }
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.white.opacity(0.12))
                        Capsule()
                            .fill(Color.white)
                            .frame(width: geo.size.width * progress(context.state))
                    }
                }
                .frame(height: 4)
                HStack {
                    Text("\(context.state.completedSets) of \(context.state.totalSessionSets) sets")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.6))
                    Spacer()
                    if let next = context.state.nextExerciseName, !context.state.isCompleted {
                        HStack(spacing: 3) {
                            Text("Next")
                                .foregroundStyle(.white.opacity(0.4))
                            Text(next)
                                .foregroundStyle(.white.opacity(0.75))
                                .lineLimit(1)
                        }
                        .font(.system(size: 10, weight: .semibold))
                    }
                }
            }
        }
        .padding(14)
    }
}

private let liveSteel = Color(red: 0.62, green: 0.67, blue: 0.73)
