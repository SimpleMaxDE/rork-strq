import SwiftUI

struct MuscleFocusView: View {
    @Binding var focusMuscles: [MuscleGroup]
    @Binding var neglectMuscles: [MuscleGroup]
    let gender: Gender

    @State private var selectionMode: FocusMode = .focus
    @State private var showingBack: Bool = false
    @State private var lastTapped: MuscleGroup?

    private enum FocusMode: String {
        case focus, neglect
    }

    private let muscleGroups: [(section: MuscleRegion, muscles: [MuscleGroup])] = [
        (.upper, [.chest, .shoulders, .back, .lats, .arms]),
        (.core, [.abs, .obliques, .lowerBack]),
        (.lower, [.glutes, .quads, .hamstrings, .calves])
    ]

    private let focusColor: Color = STRQBrand.steel
    private let neglectColor: Color = Color(red: 0.4, green: 0.55, blue: 0.8)

    private var bodyImageURL: URL? {
        let urlString: String
        if showingBack {
            urlString = gender == .female
                ? "https://r2-pub.rork.com/generated-images/6c7fdad5-4238-4399-9237-67022aa3e1e0.png"
                : "https://r2-pub.rork.com/generated-images/03d16f56-1097-419b-92d6-c323a188d5b8.png"
        } else {
            urlString = gender == .female
                ? "https://r2-pub.rork.com/generated-images/fa00b1d8-f222-4696-8ecc-3de1a9406c4d.png"
                : "https://r2-pub.rork.com/generated-images/abca8d9e-de48-4d40-b7fb-fef0bd66a2cb.png"
        }
        return URL(string: urlString)
    }

    var body: some View {
        VStack(spacing: 0) {
            modeToggle
                .padding(.bottom, 16)

            bodyPreview
                .padding(.bottom, 20)

            muscleSelector
                .padding(.bottom, 16)

            selectionSummary
        }
    }

    // MARK: - Mode Toggle

    private var modeToggle: some View {
        HStack(spacing: 0) {
            modeTab(.focus, icon: "flame.fill", label: L10n.tr("muscleFocus.focus", fallback: "Focus"), count: focusMuscles.count, color: focusColor)
            modeTab(.neglect, icon: "arrow.down.right.circle.fill", label: L10n.tr("muscleFocus.reduce", fallback: "Reduce"), count: neglectMuscles.count, color: neglectColor)
        }
        .padding(3)
        .background(Color.white.opacity(0.04), in: .rect(cornerRadius: 14))
    }

    private func modeTab(_ mode: FocusMode, icon: String, label: String, count: Int, color: Color) -> some View {
        let isActive = selectionMode == mode
        return Button {
            withAnimation(.spring(response: 0.3)) { selectionMode = mode }
        } label: {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 12, weight: .semibold))
                Text(label)
                    .font(.subheadline.weight(.semibold))
                if count > 0 {
                    Text("\(count)")
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundStyle(isActive ? color : .white.opacity(0.3))
                        .frame(width: 20, height: 20)
                        .background(isActive ? .white.opacity(0.15) : .white.opacity(0.06), in: Circle())
                }
            }
            .foregroundStyle(isActive ? .white : .white.opacity(0.35))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 11)
            .background(isActive ? color.opacity(0.22) : .clear, in: .rect(cornerRadius: 11))
        }
    }

    // MARK: - Body Preview

    private var bodyPreview: some View {
        VStack(spacing: 10) {
            viewToggle

            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            colors: [Color.white.opacity(0.04), Color.white.opacity(0.015)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .strokeBorder(Color.white.opacity(0.06), lineWidth: 1)
                    )

                GeometryReader { geo in
                    ZStack {
                        bodyImage(in: geo.size)
                        calloutLayer(in: geo.size)
                    }
                    .id(showingBack ? "back" : "front")
                    .transition(.opacity.combined(with: .scale(scale: 0.98)))
                }
                .padding(.vertical, 12)
            }
            .aspectRatio(0.74, contentMode: .fit)
            .frame(maxHeight: 320)
        }
    }

    private var viewToggle: some View {
        HStack(spacing: 0) {
            viewTab(label: L10n.tr("muscleFocus.front", fallback: "FRONT"), isActive: !showingBack) {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) { showingBack = false }
            }
            viewTab(label: L10n.tr("muscleFocus.back", fallback: "BACK"), isActive: showingBack) {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) { showingBack = true }
            }
        }
        .padding(2)
        .background(Color.white.opacity(0.04), in: .rect(cornerRadius: 9))
    }

    private func viewTab(label: String, isActive: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: 10, weight: .bold))
                .tracking(1)
                .foregroundStyle(isActive ? .white : .white.opacity(0.3))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 7)
                .background(isActive ? Color.white.opacity(0.08) : .clear, in: .rect(cornerRadius: 7))
        }
    }

    private func bodyImage(in size: CGSize) -> some View {
        AsyncImage(url: bodyImageURL) { phase in
            switch phase {
            case .success(let image):
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: size.width * 0.52, height: size.height * 0.96)
                    .opacity(0.55)
            case .failure:
                bodyFallback(in: size)
            case .empty:
                ProgressView()
                    .tint(.white.opacity(0.2))
                    .frame(width: size.width, height: size.height)
            @unknown default:
                bodyFallback(in: size)
            }
        }
        .frame(width: size.width, height: size.height)
        .allowsHitTesting(false)
    }

    private func bodyFallback(in size: CGSize) -> some View {
        Image(systemName: "figure.stand")
            .font(.system(size: min(size.width, size.height) * 0.45))
            .foregroundStyle(.white.opacity(0.06))
            .frame(width: size.width, height: size.height)
    }

    // MARK: - Callouts

    private struct CalloutAnchor {
        let muscle: MuscleGroup
        let position: CGPoint
        let side: Side
        enum Side { case left, right }
    }

    private var frontAnchors: [CalloutAnchor] {
        [
            .init(muscle: .shoulders, position: CGPoint(x: 0.18, y: 0.18), side: .left),
            .init(muscle: .chest,     position: CGPoint(x: 0.82, y: 0.24), side: .right),
            .init(muscle: .arms,      position: CGPoint(x: 0.10, y: 0.34), side: .left),
            .init(muscle: .abs,       position: CGPoint(x: 0.82, y: 0.40), side: .right),
            .init(muscle: .obliques,  position: CGPoint(x: 0.14, y: 0.46), side: .left),
            .init(muscle: .quads,     position: CGPoint(x: 0.84, y: 0.62), side: .right),
            .init(muscle: .calves,    position: CGPoint(x: 0.16, y: 0.84), side: .left)
        ]
    }

    private var backAnchors: [CalloutAnchor] {
        [
            .init(muscle: .shoulders, position: CGPoint(x: 0.82, y: 0.18), side: .right),
            .init(muscle: .back,      position: CGPoint(x: 0.14, y: 0.26), side: .left),
            .init(muscle: .lats,      position: CGPoint(x: 0.84, y: 0.34), side: .right),
            .init(muscle: .arms,      position: CGPoint(x: 0.10, y: 0.40), side: .left),
            .init(muscle: .lowerBack, position: CGPoint(x: 0.84, y: 0.46), side: .right),
            .init(muscle: .glutes,    position: CGPoint(x: 0.14, y: 0.56), side: .left),
            .init(muscle: .hamstrings,position: CGPoint(x: 0.84, y: 0.68), side: .right),
            .init(muscle: .calves,    position: CGPoint(x: 0.14, y: 0.86), side: .left)
        ]
    }

    private func calloutLayer(in size: CGSize) -> some View {
        let anchors = showingBack ? backAnchors : frontAnchors
        let active = anchors.filter { muscleState(for: $0.muscle) != .none }

        return ZStack(alignment: .topLeading) {
            ForEach(active, id: \.muscle) { anchor in
                calloutChip(for: anchor, in: size)
            }
        }
        .frame(width: size.width, height: size.height, alignment: .topLeading)
        .allowsHitTesting(false)
    }

    private func calloutChip(for anchor: CalloutAnchor, in size: CGSize) -> some View {
        let state = muscleState(for: anchor.muscle)
        let isFocus = state == .focus
        let color: Color = isFocus ? focusColor : neglectColor
        let x = anchor.position.x * size.width
        let y = anchor.position.y * size.height

        return HStack(spacing: 6) {
            if anchor.side == .right {
                dotConnector(color: color)
            }
            Text(anchor.muscle.localizedDisplayName)
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(isFocus ? .black : .white)
                .padding(.horizontal, 9)
                .padding(.vertical, 4)
                .background(
                    Capsule()
                        .fill(isFocus ? color.opacity(0.95) : color.opacity(0.28))
                )
                .overlay(
                    Capsule()
                        .strokeBorder(isFocus ? Color.white.opacity(0.35) : color.opacity(0.55), lineWidth: 0.8)
                )
            if anchor.side == .left {
                dotConnector(color: color)
            }
        }
        .fixedSize()
        .position(x: x, y: y)
        .transition(.opacity.combined(with: .scale(scale: 0.85)))
    }

    private func dotConnector(color: Color) -> some View {
        Circle()
            .fill(color)
            .frame(width: 5, height: 5)
            .overlay(
                Circle()
                    .strokeBorder(Color.white.opacity(0.5), lineWidth: 0.6)
            )
    }

    // MARK: - Muscle Selector (Primary)

    private var muscleSelector: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(L10n.tr("Tap muscles to set priority"))
                .font(.footnote.weight(.medium))
                .foregroundStyle(.white.opacity(0.45))

            ForEach(muscleGroups, id: \.section) { group in
                VStack(alignment: .leading, spacing: 8) {
                    Text(group.section.localizedDisplayName.uppercased())
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(.white.opacity(0.25))
                        .tracking(0.8)

                    FlowLayout(spacing: 7) {
                        ForEach(group.muscles) { muscle in
                            muscleChip(muscle)
                        }
                    }
                }
            }
        }
    }

    private func muscleChip(_ muscle: MuscleGroup) -> some View {
        let state = muscleState(for: muscle)
        let isSelected = state != .none
        let chipColor: Color = state == .focus ? focusColor : state == .neglect ? neglectColor : .clear

        return Button {
            withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) {
                toggleMuscle(muscle)
            }
            withAnimation(.spring(response: 0.2, dampingFraction: 0.5)) {
                lastTapped = muscle
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                if lastTapped == muscle {
                    withAnimation(.easeOut(duration: 0.2)) { lastTapped = nil }
                }
            }
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        } label: {
            HStack(spacing: 5) {
                Image(systemName: muscle.symbolName)
                    .font(.system(size: 11, weight: .medium))
                Text(muscle.localizedDisplayName)
                    .font(.subheadline.weight(.medium))
            }
            .foregroundStyle(isSelected ? (state == .focus ? .black : .white) : .white.opacity(0.55))
            .padding(.horizontal, 14)
            .padding(.vertical, 9)
            .background(
                isSelected ? chipColor.opacity(state == .focus ? 0.95 : 0.3) : Color.white.opacity(0.05),
                in: Capsule()
            )
            .overlay(
                Capsule()
                    .strokeBorder(isSelected ? chipColor.opacity(0.5) : Color.white.opacity(0.07), lineWidth: 1)
            )
        }
    }

    // MARK: - Selection Summary

    @ViewBuilder
    private var selectionSummary: some View {
        if !focusMuscles.isEmpty || !neglectMuscles.isEmpty {
            VStack(alignment: .leading, spacing: 10) {
                if !focusMuscles.isEmpty {
                    summaryRow(title: L10n.tr("muscleFocus.focus", fallback: "Focus"), muscles: focusMuscles, color: focusColor) { m in
                        withAnimation(.spring(response: 0.3)) { focusMuscles.removeAll { $0 == m } }
                    }
                }
                if !neglectMuscles.isEmpty {
                    summaryRow(title: L10n.tr("muscleFocus.reduce", fallback: "Reduce"), muscles: neglectMuscles, color: neglectColor) { m in
                        withAnimation(.spring(response: 0.3)) { neglectMuscles.removeAll { $0 == m } }
                    }
                }
            }
            .padding(12)
            .background(Color.white.opacity(0.03), in: .rect(cornerRadius: 14))
        }
    }

    private func summaryRow(title: String, muscles: [MuscleGroup], color: Color, onRemove: @escaping (MuscleGroup) -> Void) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title.uppercased())
                .font(.system(size: 9, weight: .bold))
                .foregroundStyle(color.opacity(0.7))
                .tracking(0.5)

            FlowLayout(spacing: 6) {
                ForEach(muscles) { muscle in
                    Button { onRemove(muscle) } label: {
                        HStack(spacing: 4) {
                            Text(muscle.localizedDisplayName)
                                .font(.caption.weight(.medium))
                            Image(systemName: "xmark")
                                .font(.system(size: 8, weight: .bold))
                        }
                        .foregroundStyle(color == focusColor ? .black : .white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(color.opacity(color == focusColor ? 0.95 : 0.3), in: Capsule())
                    }
                }
            }
        }
    }

    // MARK: - State Logic

    private enum MuscleState {
        case none, focus, neglect
    }

    private func muscleState(for muscle: MuscleGroup) -> MuscleState {
        if focusMuscles.contains(muscle) { return .focus }
        if neglectMuscles.contains(muscle) { return .neglect }
        return .none
    }

    private func toggleMuscle(_ muscle: MuscleGroup) {
        switch selectionMode {
        case .focus:
            neglectMuscles.removeAll { $0 == muscle }
            if focusMuscles.contains(muscle) {
                focusMuscles.removeAll { $0 == muscle }
            } else {
                focusMuscles.append(muscle)
            }
        case .neglect:
            focusMuscles.removeAll { $0 == muscle }
            if neglectMuscles.contains(muscle) {
                neglectMuscles.removeAll { $0 == muscle }
            } else {
                neglectMuscles.append(muscle)
            }
        }
    }

}

struct FlowLayout: Layout {
    var spacing: CGFloat = 6

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = arrangeSubviews(proposal: proposal, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = arrangeSubviews(proposal: proposal, subviews: subviews)
        for (index, position) in result.positions.enumerated() {
            subviews[index].place(at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y), proposal: .unspecified)
        }
    }

    private func arrangeSubviews(proposal: ProposedViewSize, subviews: Subviews) -> (size: CGSize, positions: [CGPoint]) {
        let maxWidth = proposal.width ?? .infinity
        var positions: [CGPoint] = []
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0
        var maxX: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > maxWidth, x > 0 {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            positions.append(CGPoint(x: x, y: y))
            rowHeight = max(rowHeight, size.height)
            x += size.width + spacing
            maxX = max(maxX, x)
        }

        return (CGSize(width: maxX, height: y + rowHeight), positions)
    }
}
