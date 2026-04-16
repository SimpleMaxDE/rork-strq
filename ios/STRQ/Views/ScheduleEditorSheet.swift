import SwiftUI

struct ScheduleEditorSheet: View {
    let vm: AppViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var appeared: Bool = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    headerInfo
                    weekOverview
                    dayAssignments
                    quickActions
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 32)
            }
            .background(Color(.systemBackground))
            .navigationTitle("Schedule")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
            .onAppear {
                withAnimation(.easeOut(duration: 0.4)) { appeared = true }
            }
        }
    }

    private var headerInfo: some View {
        VStack(spacing: 8) {
            Image(systemName: "calendar.badge.clock")
                .font(.title2)
                .foregroundStyle(STRQBrand.steel)
                .frame(width: 50, height: 50)
                .background(STRQBrand.steel.opacity(0.1), in: Circle())

            Text("Training Schedule")
                .font(.headline)
            Text("Assign workouts to specific days. Tap a day to change it.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, 8)
        .opacity(appeared ? 1 : 0)
        .animation(.easeOut(duration: 0.4), value: appeared)
    }

    private var weekOverview: some View {
        HStack(spacing: 0) {
            ForEach(1...7, id: \.self) { weekday in
                let hasWorkout = vm.currentPlan?.days.contains { $0.scheduledWeekday == weekday && !$0.isSkipped } ?? false
                let dayName = vm.currentPlan?.days.first { $0.scheduledWeekday == weekday && !$0.isSkipped }

                VStack(spacing: 6) {
                    Text(vm.weekdayName(weekday))
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(.secondary)

                    ZStack {
                        Circle()
                            .fill(hasWorkout ? STRQBrand.steel : Color.white.opacity(0.06))
                            .frame(width: 32, height: 32)
                            .overlay {
                                if hasWorkout {
                                    Circle()
                                        .strokeBorder(STRQBrand.steel.opacity(0.3), lineWidth: 1)
                                        .frame(width: 36, height: 36)
                                }
                            }

                        if hasWorkout {
                            Image(systemName: "figure.strengthtraining.traditional")
                                .font(.system(size: 12))
                                .foregroundStyle(.white)
                        }
                    }

                    if let day = dayName {
                        Text(shortName(day.name))
                            .font(.system(size: 8, weight: .medium))
                            .foregroundStyle(STRQBrand.steel)
                            .lineLimit(1)
                    } else {
                        Text("Rest")
                            .font(.system(size: 8, weight: .medium))
                            .foregroundStyle(.tertiary)
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 8)
        .background(Color(.secondarySystemGroupedBackground), in: .rect(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(STRQBrand.cardBorder, lineWidth: 1)
        )
        .opacity(appeared ? 1 : 0)
        .animation(.easeOut(duration: 0.4).delay(0.1), value: appeared)
    }

    private var dayAssignments: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("ASSIGN DAYS")
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(STRQBrand.steel)
                .tracking(0.5)
                .padding(.leading, 4)

            if let plan = vm.currentPlan {
                ForEach(Array(plan.days.enumerated()), id: \.element.id) { index, day in
                    dayAssignmentRow(day: day, index: index)
                }
            }
        }
        .opacity(appeared ? 1 : 0)
        .animation(.easeOut(duration: 0.4).delay(0.2), value: appeared)
    }

    private func dayAssignmentRow(day: WorkoutDay, index: Int) -> some View {
        VStack(spacing: 8) {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(day.name)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(day.isSkipped ? .secondary : .primary)
                    Text(day.focusMuscles.prefix(3).map(\.displayName).joined(separator: ", "))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                if day.isSkipped {
                    Text("Skipped")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.red)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Color.red.opacity(0.1), in: Capsule())
                }
            }

            ScrollView(.horizontal) {
                HStack(spacing: 6) {
                    ForEach(1...7, id: \.self) { weekday in
                        let isAssigned = day.scheduledWeekday == weekday
                        let isConflict = !isAssigned && (vm.currentPlan?.days.contains { $0.scheduledWeekday == weekday && $0.id != day.id } ?? false)

                        Button {
                            withAnimation(.snappy(duration: 0.3)) {
                                if isAssigned {
                                    vm.assignSchedule(dayId: day.id, weekday: nil)
                                } else {
                                    vm.assignSchedule(dayId: day.id, weekday: weekday)
                                }
                            }
                        } label: {
                            Text(vm.weekdayName(weekday))
                                .font(.system(size: 11, weight: isAssigned ? .bold : .medium))
                                .foregroundStyle(isAssigned ? Color.black : isConflict ? Color.secondary : Color.primary)
                                .frame(width: 40, height: 34)
                                .background(
                                    isAssigned
                                        ? AnyShapeStyle(STRQBrand.accentGradient)
                                        : AnyShapeStyle(Color.white.opacity(0.04)),
                                    in: .rect(cornerRadius: 8)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .strokeBorder(isAssigned ? Color.clear : Color.white.opacity(0.06), lineWidth: 1)
                                )
                        }
                        .disabled(isConflict)
                    }
                }
            }
            .scrollIndicators(.hidden)
        }
        .padding(14)
        .background(Color(.secondarySystemGroupedBackground), in: .rect(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .strokeBorder(STRQBrand.cardBorder, lineWidth: 1)
        )
    }

    private var quickActions: some View {
        VStack(spacing: 10) {
            Button {
                withAnimation(.snappy(duration: 0.3)) { vm.autoScheduleDays() }
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "wand.and.stars")
                        .font(.subheadline)
                    Text("Auto-Schedule")
                        .font(.subheadline.weight(.bold))
                }
                .foregroundStyle(.black)
                .frame(maxWidth: .infinity)
                .frame(height: 46)
                .background(STRQBrand.accentGradient, in: .rect(cornerRadius: 12))
                .shadow(color: .white.opacity(0.06), radius: 8, y: 2)
            }
        }
        .opacity(appeared ? 1 : 0)
        .animation(.easeOut(duration: 0.4).delay(0.3), value: appeared)
    }

    private func shortName(_ name: String) -> String {
        let words = name.split(separator: " ")
        if words.count > 1 { return String(words[0]) }
        return String(name.prefix(6))
    }
}
