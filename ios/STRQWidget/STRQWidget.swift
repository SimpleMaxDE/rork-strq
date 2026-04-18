import WidgetKit
import SwiftUI

nonisolated enum WidgetBridge {
    static let appGroup = "group.app.rork.40gfu7dywfru7n82xfoy4"
    static let snapshotKey = "strq_widget_snapshot_v1"

    nonisolated struct Snapshot: Codable, Sendable {
        var todayWorkoutName: String?
        var todayFocus: String?
        var isRestDay: Bool
        var hasCheckedIn: Bool
        var readinessScore: Int
        var readinessLabel: String
        var nextActionTitle: String
        var streak: Int
        var weeklyCompleted: Int
        var weeklyTarget: Int
        var updatedAt: Date

        static let placeholder = Snapshot(
            todayWorkoutName: "Upper Strength",
            todayFocus: "Chest & Back",
            isRestDay: false,
            hasCheckedIn: false,
            readinessScore: 78,
            readinessLabel: "Well Prepared",
            nextActionTitle: "Ready to train",
            streak: 4,
            weeklyCompleted: 2,
            weeklyTarget: 4,
            updatedAt: Date()
        )
    }

    static func read() -> Snapshot? {
        guard let defaults = UserDefaults(suiteName: appGroup),
              let data = defaults.data(forKey: snapshotKey),
              let decoded = try? JSONDecoder().decode(Snapshot.self, from: data) else {
            return nil
        }
        return decoded
    }
}

nonisolated struct STRQEntry: TimelineEntry {
    let date: Date
    let snapshot: WidgetBridge.Snapshot
}

nonisolated struct STRQProvider: TimelineProvider {
    func placeholder(in context: Context) -> STRQEntry {
        STRQEntry(date: .now, snapshot: .placeholder)
    }

    func getSnapshot(in context: Context, completion: @escaping (STRQEntry) -> Void) {
        let snap = WidgetBridge.read() ?? .placeholder
        completion(STRQEntry(date: .now, snapshot: snap))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<STRQEntry>) -> Void) {
        let snap = WidgetBridge.read() ?? .placeholder
        let entry = STRQEntry(date: .now, snapshot: snap)
        let next = Calendar.current.date(byAdding: .hour, value: 1, to: .now) ?? Date().addingTimeInterval(3600)
        completion(Timeline(entries: [entry], policy: .after(next)))
    }
}

// MARK: - Shared styling

private let steel = Color(red: 0.62, green: 0.67, blue: 0.73)
private let steelDark = Color(red: 0.42, green: 0.47, blue: 0.53)

private func readinessColor(_ score: Int) -> Color {
    if score >= 80 { return .green }
    if score >= 60 { return .yellow }
    if score >= 45 { return .orange }
    return .red
}

// MARK: - Today Widget

struct TodayWidgetView: View {
    @Environment(\.widgetFamily) var family
    var entry: STRQEntry

    var body: some View {
        switch family {
        case .systemSmall: small
        case .accessoryRectangular: accessoryRect
        case .accessoryInline: Text(inlineText)
        case .accessoryCircular: accessoryCircular
        default: medium
        }
    }

    private var inlineText: String {
        if entry.snapshot.isRestDay { return "STRQ · Rest day" }
        return "STRQ · \(entry.snapshot.todayWorkoutName ?? "Ready to train")"
    }

    private var small: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 4) {
                Image(systemName: entry.snapshot.isRestDay ? "leaf.fill" : "dumbbell.fill")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(steel)
                Text(entry.snapshot.isRestDay ? "REST" : "TODAY")
                    .font(.system(size: 9, weight: .heavy))
                    .tracking(0.6)
                    .foregroundStyle(steel)
            }
            Spacer(minLength: 0)
            Text(entry.snapshot.isRestDay ? "Recovery" : (entry.snapshot.todayWorkoutName ?? "Ready"))
                .font(.system(size: 17, weight: .heavy))
                .lineLimit(2)
                .minimumScaleFactor(0.8)
            if let focus = entry.snapshot.todayFocus, !entry.snapshot.isRestDay {
                Text(focus)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            Spacer(minLength: 0)
            HStack(spacing: 4) {
                Image(systemName: "bolt.heart.fill")
                    .font(.system(size: 9))
                    .foregroundStyle(readinessColor(entry.snapshot.readinessScore))
                Text("\(entry.snapshot.readinessScore)")
                    .font(.system(size: 11, weight: .bold).monospacedDigit())
                    .foregroundStyle(readinessColor(entry.snapshot.readinessScore))
                Text("readiness")
                    .font(.system(size: 9, weight: .medium))
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var medium: some View {
        HStack(alignment: .top, spacing: 14) {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 4) {
                    Image(systemName: entry.snapshot.isRestDay ? "leaf.fill" : "dumbbell.fill")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(steel)
                    Text(entry.snapshot.isRestDay ? "REST DAY" : "TODAY")
                        .font(.system(size: 9, weight: .heavy))
                        .tracking(0.6)
                        .foregroundStyle(steel)
                }
                Text(entry.snapshot.isRestDay ? "Recovery" : (entry.snapshot.todayWorkoutName ?? "Ready to train"))
                    .font(.system(size: 19, weight: .heavy))
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
                if let focus = entry.snapshot.todayFocus, !entry.snapshot.isRestDay {
                    Text(focus)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
                Spacer(minLength: 0)
                Text(entry.snapshot.nextActionTitle)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
            Spacer(minLength: 0)
            VStack(alignment: .trailing, spacing: 8) {
                readinessRing
                HStack(spacing: 4) {
                    Image(systemName: "flame.fill")
                        .font(.system(size: 10))
                        .foregroundStyle(.orange)
                    Text("\(entry.snapshot.streak)")
                        .font(.system(size: 13, weight: .bold).monospacedDigit())
                }
            }
        }
    }

    private var readinessRing: some View {
        ZStack {
            Circle()
                .stroke(Color.secondary.opacity(0.2), lineWidth: 4)
            Circle()
                .trim(from: 0, to: CGFloat(entry.snapshot.readinessScore) / 100)
                .stroke(readinessColor(entry.snapshot.readinessScore), style: StrokeStyle(lineWidth: 4, lineCap: .round))
                .rotationEffect(.degrees(-90))
            Text("\(entry.snapshot.readinessScore)")
                .font(.system(size: 14, weight: .heavy).monospacedDigit())
        }
        .frame(width: 44, height: 44)
    }

    private var accessoryRect: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(entry.snapshot.isRestDay ? "Rest day" : (entry.snapshot.todayWorkoutName ?? "Today"))
                .font(.system(size: 14, weight: .bold))
                .lineLimit(1)
            Text("Readiness \(entry.snapshot.readinessScore) · \(entry.snapshot.readinessLabel)")
                .font(.system(size: 11))
                .lineLimit(1)
        }
    }

    private var accessoryCircular: some View {
        ZStack {
            AccessoryWidgetBackground()
            VStack(spacing: 0) {
                Text("\(entry.snapshot.readinessScore)")
                    .font(.system(size: 16, weight: .heavy).monospacedDigit())
                Text("rdy")
                    .font(.system(size: 8, weight: .medium))
            }
        }
    }
}

struct TodayWidget: Widget {
    let kind: String = "STRQTodayWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: STRQProvider()) { entry in
            TodayWidgetView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Today's Workout")
        .description("See your scheduled session and readiness at a glance.")
        .supportedFamilies([.systemSmall, .systemMedium, .accessoryRectangular, .accessoryCircular, .accessoryInline])
    }
}

// MARK: - Streak / Week Widget

struct StreakWidgetView: View {
    @Environment(\.widgetFamily) var family
    var entry: STRQEntry

    var body: some View {
        switch family {
        case .accessoryCircular: circular
        case .accessoryInline: Text("STRQ · \(entry.snapshot.weeklyCompleted)/\(entry.snapshot.weeklyTarget) this week")
        default: small
        }
    }

    private var small: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 4) {
                Image(systemName: "flame.fill")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(.orange)
                Text("STREAK")
                    .font(.system(size: 9, weight: .heavy))
                    .tracking(0.6)
                    .foregroundStyle(.orange)
            }
            Text("\(entry.snapshot.streak)")
                .font(.system(size: 40, weight: .heavy).monospacedDigit())
            Text("days active")
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(.secondary)
            Spacer(minLength: 0)
            progressRow
        }
    }

    private var progressRow: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text("\(entry.snapshot.weeklyCompleted)/\(entry.snapshot.weeklyTarget)")
                    .font(.system(size: 11, weight: .bold).monospacedDigit())
                Text("this week")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(.secondary)
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.secondary.opacity(0.2))
                    Capsule()
                        .fill(steel)
                        .frame(width: geo.size.width * progress)
                }
            }
            .frame(height: 5)
        }
    }

    private var progress: CGFloat {
        let t = max(1, entry.snapshot.weeklyTarget)
        return min(1, CGFloat(entry.snapshot.weeklyCompleted) / CGFloat(t))
    }

    private var circular: some View {
        ZStack {
            AccessoryWidgetBackground()
            VStack(spacing: 0) {
                Image(systemName: "flame.fill")
                    .font(.system(size: 11))
                Text("\(entry.snapshot.streak)")
                    .font(.system(size: 14, weight: .heavy).monospacedDigit())
            }
        }
    }
}

struct StreakWidget: Widget {
    let kind: String = "STRQStreakWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: STRQProvider()) { entry in
            StreakWidgetView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Streak & Weekly Progress")
        .description("Track your STRQ streak and weekly training target.")
        .supportedFamilies([.systemSmall, .accessoryCircular, .accessoryInline])
    }
}
