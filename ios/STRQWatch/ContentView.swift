import Foundation
import SwiftUI

private enum WatchL10n {
    static func tr(_ key: String, comment: String = "") -> String {
        NSLocalizedString(key, comment: comment)
    }

    static func format(_ key: String, _ arguments: CVarArg..., comment: String = "") -> String {
        String(format: tr(key, comment: comment), locale: Locale.current, arguments: arguments)
    }
}

struct ContentView: View {
    @Bindable var store: WatchWorkoutStore

    var body: some View {
        NavigationStack {
            Group {
                if store.isActive && !store.isCompleted {
                    ActiveWorkoutWatchView(store: store)
                } else {
                    IdleWatchView(completed: store.isCompleted, dayName: store.dayName)
                }
            }
            .containerBackground(STRQWatchPalette.backgroundGradient, for: .navigation)
        }
    }
}

// MARK: - Idle

struct IdleWatchView: View {
    let completed: Bool
    let dayName: String

    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: completed ? "checkmark.seal.fill" : "dumbbell.fill")
                .font(.system(size: 30, weight: .semibold))
                .foregroundStyle(completed ? Color.green : .white.opacity(0.75))
            Text(completed ? WatchL10n.tr("Session Logged") : WatchL10n.tr("STRQ"))
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(.white)
            Text(completed ? (dayName.isEmpty ? WatchL10n.tr("Nice work") : dayName) : WatchL10n.tr("Start a workout on iPhone"))
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(.white.opacity(0.55))
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .padding(.horizontal, 8)
    }
}

// MARK: - Active Workout

struct ActiveWorkoutWatchView: View {
    @Bindable var store: WatchWorkoutStore
    @State private var elapsed: Int = 0
    @State private var timerTask: Task<Void, Never>?
    @State private var showQuality: Bool = false

    var body: some View {
        TabView {
            loggingPage
                .tag(0)
            controlsPage
                .tag(1)
            infoPage
                .tag(2)
        }
        .tabViewStyle(.verticalPage)
        .onAppear { startTimer() }
        .onDisappear { timerTask?.cancel() }
        .sheet(isPresented: $showQuality) { qualitySheet }
    }

    // Page 1 — core logging
    private var loggingPage: some View {
        VStack(spacing: 6) {
            header

            HStack(spacing: 0) {
                stepperColumn(
                    label: WatchL10n.tr("KG"),
                    value: store.weight <= 0 ? "BW" : formatWeight(store.weight),
                    onMinus: { store.adjustWeight(-2.5) },
                    onPlus: { store.adjustWeight(2.5) }
                )
                Rectangle().fill(Color.white.opacity(0.08)).frame(width: 1, height: 38)
                stepperColumn(
                    label: WatchL10n.tr("REPS"),
                    value: "\(store.reps)",
                    onMinus: { store.adjustReps(-1) },
                    onPlus: { store.adjustReps(1) }
                )
            }
            .frame(maxWidth: .infinity)

            Button {
                store.sendCompleteSet()
                WKHaptic.success()
                showQuality = true
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "checkmark")
                        .font(.system(size: 12, weight: .bold))
                    Text(WatchL10n.format("Log Set %d", store.setNumber))
                        .font(.system(size: 14, weight: .bold))
                }
                .foregroundStyle(.black)
                .frame(maxWidth: .infinity)
                .frame(height: 40)
                .background(Color.white, in: Capsule())
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 6)
    }

    private var header: some View {
        VStack(spacing: 2) {
            HStack(spacing: 6) {
                Text(WatchL10n.format("SET %d / %d", store.setNumber, store.totalSets))
                    .font(.system(size: 9, weight: .black))
                    .tracking(1.1)
                    .foregroundStyle(.white.opacity(0.55))
                Spacer()
                Text(formatTime(elapsed))
                    .font(.system(size: 10, weight: .bold, design: .rounded).monospacedDigit())
                    .foregroundStyle(.white.opacity(0.7))
            }
            Text(store.exerciseName)
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.top, 2)
    }

    private func stepperColumn(label: String, value: String, onMinus: @escaping () -> Void, onPlus: @escaping () -> Void) -> some View {
        VStack(spacing: 2) {
            Text(label)
                .font(.system(size: 8, weight: .bold))
                .tracking(0.6)
                .foregroundStyle(.white.opacity(0.4))
            Text(value)
                .font(.system(size: 22, weight: .heavy, design: .rounded).monospacedDigit())
                .foregroundStyle(.white)
                .contentTransition(.numericText())
                .minimumScaleFactor(0.7)
                .lineLimit(1)
            HStack(spacing: 6) {
                smallRound(icon: "minus", action: onMinus)
                smallRound(icon: "plus", action: onPlus)
            }
        }
        .frame(maxWidth: .infinity)
    }

    private func smallRound(icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(.white.opacity(0.85))
                .frame(width: 26, height: 26)
                .background(Color.white.opacity(0.10), in: Circle())
        }
        .buttonStyle(.plain)
    }

    // Page 2 — secondary actions
    private var controlsPage: some View {
        VStack(spacing: 8) {
            Text(WatchL10n.tr("CONTROLS"))
                .font(.system(size: 9, weight: .black))
                .tracking(1.3)
                .foregroundStyle(.white.opacity(0.45))
                .frame(maxWidth: .infinity, alignment: .leading)

            Button {
                store.sendNextExercise()
                WKHaptic.directionUp()
            } label: {
                HStack {
                    Image(systemName: "forward.end.fill")
                    Text(WatchL10n.tr("Next Exercise"))
                    Spacer()
                }
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.white)
                .padding(.horizontal, 10)
                .frame(height: 38)
                .background(Color.white.opacity(0.10), in: .rect(cornerRadius: 10))
            }
            .buttonStyle(.plain)
            .disabled(store.exerciseIndex >= store.totalExercises - 1)

            Button {
                showQuality = true
            } label: {
                HStack {
                    Image(systemName: "waveform.path.ecg")
                    Text(WatchL10n.tr("Set Feel"))
                    Spacer()
                }
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.white)
                .padding(.horizontal, 10)
                .frame(height: 38)
                .background(Color.white.opacity(0.10), in: .rect(cornerRadius: 10))
            }
            .buttonStyle(.plain)

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 6)
    }

    // Page 3 — context
    private var infoPage: some View {
        VStack(alignment: .leading, spacing: 8) {
            VStack(alignment: .leading, spacing: 2) {
                Text(WatchL10n.tr("DAY"))
                    .font(.system(size: 8, weight: .black))
                    .tracking(1.1)
                    .foregroundStyle(.white.opacity(0.4))
                Text(store.dayName)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(.white)
                    .lineLimit(1)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(WatchL10n.tr("PROGRESS"))
                    .font(.system(size: 8, weight: .black))
                    .tracking(1.1)
                    .foregroundStyle(.white.opacity(0.4))
                Text(WatchL10n.format("Exercise %d of %d", store.exerciseIndex + 1, store.totalExercises))
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.85))
            }

            if let next = store.nextExerciseName {
                VStack(alignment: .leading, spacing: 2) {
                    Text(WatchL10n.tr("NEXT"))
                        .font(.system(size: 8, weight: .black))
                        .tracking(1.1)
                        .foregroundStyle(.white.opacity(0.4))
                    Text(next)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.75))
                        .lineLimit(2)
                }
            }

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 6)
    }

    // Quality sheet
    private var qualitySheet: some View {
        let qualities: [(raw: String, label: String, icon: String, color: Color)] = [
            ("tooEasy", WatchL10n.tr("Easy"), "arrow.up.circle", .blue),
            ("onTarget", WatchL10n.tr("Clean"), "checkmark.circle.fill", .green),
            ("grinder", WatchL10n.tr("Grind"), "flame.fill", .orange),
            ("formBreakdown", WatchL10n.tr("Form"), "exclamationmark.triangle.fill", .yellow),
            ("pain", WatchL10n.tr("Pain"), "cross.case.fill", .red)
        ]
        return ScrollView {
            VStack(spacing: 6) {
                Text(WatchL10n.tr("SET FEEL"))
                    .font(.system(size: 9, weight: .black))
                    .tracking(1.3)
                    .foregroundStyle(.white.opacity(0.5))
                    .padding(.top, 4)
                ForEach(qualities, id: \.raw) { q in
                    Button {
                        store.sendQuality(q.raw)
                        WKHaptic.click()
                        showQuality = false
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: q.icon)
                                .foregroundStyle(q.color)
                            Text(q.label)
                                .foregroundStyle(.white)
                            Spacer()
                        }
                        .font(.system(size: 13, weight: .semibold))
                        .padding(.horizontal, 10)
                        .frame(height: 38)
                        .background(Color.white.opacity(0.08), in: .rect(cornerRadius: 10))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 6)
        }
    }

    private func startTimer() {
        elapsed = max(0, Int(Date().timeIntervalSince(store.startedAt)))
        timerTask?.cancel()
        timerTask = Task { @MainActor in
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(1))
                if Task.isCancelled { break }
                elapsed = max(0, Int(Date().timeIntervalSince(store.startedAt)))
            }
        }
    }

    private func formatTime(_ seconds: Int) -> String {
        let m = seconds / 60
        let s = seconds % 60
        return String(format: "%02d:%02d", m, s)
    }

    private func formatWeight(_ w: Double) -> String {
        if w.truncatingRemainder(dividingBy: 1) == 0 { return String(format: "%.0f", w) }
        return String(format: "%.1f", w)
    }
}

// MARK: - Palette & Haptics

enum STRQWatchPalette {
    static let backgroundGradient = LinearGradient(
        colors: [Color.black, Color(red: 0.07, green: 0.08, blue: 0.10)],
        startPoint: .top, endPoint: .bottom
    )
}

enum WKHaptic {
    static func success() {
        #if os(watchOS)
        WKInterfaceDevice.current().play(.success)
        #endif
    }
    static func click() {
        #if os(watchOS)
        WKInterfaceDevice.current().play(.click)
        #endif
    }
    static func directionUp() {
        #if os(watchOS)
        WKInterfaceDevice.current().play(.directionUp)
        #endif
    }
}

#if os(watchOS)
import WatchKit
#endif
