import SwiftUI

struct BodyMapView: View {
    let primaryMuscles: [MuscleGroup]
    let secondaryMuscles: [MuscleGroup]
    var selectable: Bool = false
    var selectedMuscles: Binding<[MuscleGroup]>?
    var compact: Bool = false

    private let size: CGFloat

    init(primaryMuscles: [MuscleGroup] = [], secondaryMuscles: [MuscleGroup] = [], selectable: Bool = false, selectedMuscles: Binding<[MuscleGroup]>? = nil, compact: Bool = false) {
        self.primaryMuscles = primaryMuscles
        self.secondaryMuscles = secondaryMuscles
        self.selectable = selectable
        self.selectedMuscles = selectedMuscles
        self.compact = compact
        self.size = compact ? 140 : 220
    }

    var body: some View {
        HStack(spacing: compact ? 8 : 16) {
            bodyView(isFront: true)
            bodyView(isFront: false)
        }
    }

    @ViewBuilder
    private func bodyView(isFront: Bool) -> some View {
        let muscles = isFront ? frontMuscles : backMuscles
        ZStack {
            bodyOutline(isFront: isFront)
                .stroke(Color.white.opacity(0.15), lineWidth: 1)
                .frame(width: size * 0.55, height: size)

            ForEach(muscles, id: \.muscle) { item in
                muscleRegion(item: item, isFront: isFront)
            }
        }
        .frame(width: size * 0.6, height: size + 10)
    }

    @ViewBuilder
    private func muscleRegion(item: MuscleItem, isFront: Bool) -> some View {
        let color = muscleColor(for: item.muscle)
        let position = musclePosition(item.muscle, isFront: isFront, size: size)

        if selectable {
            Button {
                toggleMuscle(item.muscle)
            } label: {
                muscleShape(item: item, color: color)
            }
            .position(position)
        } else {
            muscleShape(item: item, color: color)
                .position(position)
        }
    }

    @ViewBuilder
    private func muscleShape(item: MuscleItem, color: Color) -> some View {
        RoundedRectangle(cornerRadius: item.cornerRadius)
            .fill(color)
            .frame(width: item.width * (compact ? 0.65 : 1), height: item.height * (compact ? 0.65 : 1))
            .overlay {
                if !compact {
                    Text(item.muscle.displayName)
                        .font(.system(size: 6, weight: .medium))
                        .foregroundStyle(.white.opacity(0.8))
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                }
            }
    }

    private func muscleColor(for muscle: MuscleGroup) -> Color {
        if selectable, let selected = selectedMuscles?.wrappedValue {
            return selected.contains(muscle) ? STRQBrand.steel : .white.opacity(0.08)
        }
        if primaryMuscles.contains(muscle) { return STRQBrand.steel }
        if secondaryMuscles.contains(muscle) { return STRQBrand.steel.opacity(0.4) }
        return .white.opacity(0.06)
    }

    private func toggleMuscle(_ muscle: MuscleGroup) {
        guard var selected = selectedMuscles?.wrappedValue else { return }
        if selected.contains(muscle) {
            selected.removeAll { $0 == muscle }
        } else {
            selected.append(muscle)
        }
        selectedMuscles?.wrappedValue = selected
    }

    private func bodyOutline(isFront: Bool) -> Path {
        Path { path in
            let w = size * 0.55
            let h = size
            path.addRoundedRect(in: CGRect(x: w * 0.3, y: 0, width: w * 0.4, height: h * 0.12), cornerSize: CGSize(width: w * 0.15, height: h * 0.06))
            path.addRoundedRect(in: CGRect(x: w * 0.15, y: h * 0.14, width: w * 0.7, height: h * 0.35), cornerSize: CGSize(width: 8, height: 8))
            path.addRoundedRect(in: CGRect(x: 0, y: h * 0.16, width: w * 0.2, height: h * 0.28), cornerSize: CGSize(width: 6, height: 6))
            path.addRoundedRect(in: CGRect(x: w * 0.8, y: h * 0.16, width: w * 0.2, height: h * 0.28), cornerSize: CGSize(width: 6, height: 6))
            path.addRoundedRect(in: CGRect(x: w * 0.18, y: h * 0.5, width: w * 0.28, height: h * 0.38), cornerSize: CGSize(width: 6, height: 6))
            path.addRoundedRect(in: CGRect(x: w * 0.54, y: h * 0.5, width: w * 0.28, height: h * 0.38), cornerSize: CGSize(width: 6, height: 6))
        }
    }

    private var frontMuscles: [MuscleItem] {
        [
            MuscleItem(muscle: .chest, width: 50, height: 22, cornerRadius: 6),
            MuscleItem(muscle: .shoulders, width: 18, height: 16, cornerRadius: 4),
            MuscleItem(muscle: .biceps, width: 14, height: 24, cornerRadius: 4),
            MuscleItem(muscle: .forearms, width: 12, height: 20, cornerRadius: 3),
            MuscleItem(muscle: .abs, width: 30, height: 32, cornerRadius: 4),
            MuscleItem(muscle: .obliques, width: 12, height: 26, cornerRadius: 3),
            MuscleItem(muscle: .quads, width: 22, height: 36, cornerRadius: 5),
            MuscleItem(muscle: .tibialis, width: 14, height: 22, cornerRadius: 3),
            MuscleItem(muscle: .adductors, width: 12, height: 20, cornerRadius: 3),
            MuscleItem(muscle: .hipFlexors, width: 18, height: 10, cornerRadius: 3),
        ]
    }

    private var backMuscles: [MuscleItem] {
        [
            MuscleItem(muscle: .traps, width: 36, height: 16, cornerRadius: 4),
            MuscleItem(muscle: .back, width: 44, height: 18, cornerRadius: 5),
            MuscleItem(muscle: .lats, width: 48, height: 22, cornerRadius: 5),
            MuscleItem(muscle: .lowerBack, width: 28, height: 16, cornerRadius: 4),
            MuscleItem(muscle: .triceps, width: 14, height: 22, cornerRadius: 4),
            MuscleItem(muscle: .glutes, width: 40, height: 20, cornerRadius: 6),
            MuscleItem(muscle: .hamstrings, width: 22, height: 34, cornerRadius: 5),
            MuscleItem(muscle: .calves, width: 16, height: 24, cornerRadius: 4),
            MuscleItem(muscle: .neck, width: 16, height: 10, cornerRadius: 3),
        ]
    }

    private func musclePosition(_ muscle: MuscleGroup, isFront: Bool, size: CGFloat) -> CGPoint {
        let w = size * 0.6
        let h = size + 10
        let cx = w * 0.5
        let positions: [MuscleGroup: CGPoint] = isFront ? [
            .chest: CGPoint(x: cx, y: h * 0.22),
            .shoulders: CGPoint(x: cx - w * 0.28, y: h * 0.17),
            .biceps: CGPoint(x: cx - w * 0.32, y: h * 0.32),
            .forearms: CGPoint(x: cx - w * 0.34, y: h * 0.42),
            .abs: CGPoint(x: cx, y: h * 0.36),
            .obliques: CGPoint(x: cx + w * 0.18, y: h * 0.35),
            .quads: CGPoint(x: cx - w * 0.1, y: h * 0.58),
            .tibialis: CGPoint(x: cx - w * 0.1, y: h * 0.78),
            .adductors: CGPoint(x: cx + w * 0.06, y: h * 0.55),
            .hipFlexors: CGPoint(x: cx, y: h * 0.47),
        ] : [
            .traps: CGPoint(x: cx, y: h * 0.13),
            .back: CGPoint(x: cx, y: h * 0.22),
            .lats: CGPoint(x: cx, y: h * 0.3),
            .lowerBack: CGPoint(x: cx, y: h * 0.38),
            .triceps: CGPoint(x: cx + w * 0.32, y: h * 0.3),
            .glutes: CGPoint(x: cx, y: h * 0.46),
            .hamstrings: CGPoint(x: cx - w * 0.1, y: h * 0.6),
            .calves: CGPoint(x: cx - w * 0.1, y: h * 0.78),
            .neck: CGPoint(x: cx, y: h * 0.06),
        ]
        return positions[muscle] ?? CGPoint(x: cx, y: h * 0.5)
    }
}

private struct MuscleItem {
    let muscle: MuscleGroup
    let width: CGFloat
    let height: CGFloat
    let cornerRadius: CGFloat
}
