import SwiftUI

struct ExerciseHeroView: View {
    let exercise: Exercise
    var compact: Bool = false
    var showTitle: Bool = true

    @State private var appeared: Bool = false

    private let mediaProvider = ExerciseMediaProvider.shared
    private var height: CGFloat { compact ? 140 : 240 }
    private var gradientColors: [Color] { mediaProvider.heroGradient(for: exercise) }
    private var heroSymbol: String { mediaProvider.heroSymbol(for: exercise) }
    private var media: ExerciseMedia { mediaProvider.media(for: exercise) }
    private var isTopExercise: Bool { mediaProvider.isTopExercise(exercise.id) }

    var body: some View {
        Group {
            switch media.mediaType {
            case .staticImage:
                staticImageHero
            case .sfSymbol:
                symbolHero
            case .lottie, .rive, .video, .gif:
                symbolHero
            }
        }
    }

    private var staticImageHero: some View {
        VStack(spacing: 0) {
            if let assetName = media.assetName {
                Color(.secondarySystemBackground)
                    .frame(height: height)
                    .overlay {
                        Image(assetName)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .allowsHitTesting(false)
                    }
                    .clipShape(.rect(cornerRadius: compact ? 14 : 22))
                    .padding(.horizontal, compact ? 0 : 16)
            } else if let urlString = media.assetURL, let url = URL(string: urlString) {
                Color(.secondarySystemBackground)
                    .frame(height: height)
                    .overlay {
                        AsyncImage(url: url) { phase in
                            if let image = phase.image {
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                            } else if phase.error != nil {
                                symbolFallbackContent
                            } else {
                                ProgressView()
                            }
                        }
                        .allowsHitTesting(false)
                    }
                    .clipShape(.rect(cornerRadius: compact ? 14 : 22))
                    .padding(.horizontal, compact ? 0 : 16)
            }

            if showTitle && !compact {
                titleBlock
            }
        }
    }

    private var symbolHero: some View {
        VStack(spacing: 0) {
            ZStack {
                RoundedRectangle(cornerRadius: compact ? 14 : 22)
                    .fill(
                        LinearGradient(
                            colors: [
                                gradientColors[0],
                                gradientColors[1]
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(height: height)

                Canvas { context, size in
                    drawPremiumPattern(context: context, size: size)
                }
                .frame(height: height)
                .clipShape(.rect(cornerRadius: compact ? 14 : 22))
                .allowsHitTesting(false)

                VStack(spacing: compact ? 8 : 14) {
                    ZStack {
                        Circle()
                            .fill(.white.opacity(0.1))
                            .frame(width: compact ? 56 : 80, height: compact ? 56 : 80)
                            .blur(radius: compact ? 8 : 12)

                        Image(systemName: heroSymbol)
                            .font(.system(size: compact ? 30 : 44, weight: .thin))
                            .foregroundStyle(.white.opacity(0.95))
                            .shadow(color: .black.opacity(0.15), radius: 6, y: 3)
                    }
                    .scaleEffect(appeared ? 1 : 0.8)
                    .animation(.spring(response: 0.5, dampingFraction: 0.65), value: appeared)

                    if compact {
                        Text(exercise.name)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.white)
                            .lineLimit(1)
                            .shadow(color: .black.opacity(0.2), radius: 3, y: 1)
                    }

                    if !compact {
                        HStack(spacing: 6) {
                            muscleChip(exercise.primaryMuscle.displayName, primary: true)
                            if let secondary = exercise.secondaryMuscles.first {
                                muscleChip(secondary.displayName, primary: false)
                            }
                        }
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 6)
                        .animation(.easeOut(duration: 0.4).delay(0.15), value: appeared)
                    }

                    if isTopExercise && !compact {
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                                .font(.system(size: 8))
                            Text(movementFamilyLabel)
                                .font(.system(size: 10, weight: .medium))
                        }
                        .foregroundStyle(.white.opacity(0.65))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(.white.opacity(0.1), in: Capsule())
                        .opacity(appeared ? 1 : 0)
                        .animation(.easeOut(duration: 0.4).delay(0.25), value: appeared)
                    }
                }
            }
            .padding(.horizontal, compact ? 0 : 16)

            if showTitle && !compact {
                titleBlock
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) { appeared = true }
        }
    }

    private var movementFamilyLabel: String {
        let family = mediaProvider.movementFamily(for: exercise)
        switch family {
        case .press: return "Press Movement"
        case .pull: return "Pull Movement"
        case .squat: return "Squat Pattern"
        case .hinge: return "Hip Hinge"
        case .carry: return "Carry"
        case .lunge: return "Lunge Pattern"
        case .rotation: return "Rotation"
        case .isolation: return "Isolation"
        case .plank: return "Core Stability"
        case .stretch: return "Mobility"
        case .cardio: return "Conditioning"
        }
    }

    private var titleBlock: some View {
        VStack(spacing: 6) {
            Text(exercise.name)
                .font(.title2.bold())
                .multilineTextAlignment(.center)

            if !exercise.shortDescription.isEmpty {
                Text(exercise.shortDescription)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .padding(.horizontal, 32)
            }
        }
        .padding(.top, 14)
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 8)
        .animation(.easeOut(duration: 0.4).delay(0.1), value: appeared)
    }

    private func muscleChip(_ text: String, primary: Bool) -> some View {
        Text(text)
            .font(.system(size: compact ? 9 : 11, weight: .semibold))
            .foregroundStyle(.white.opacity(primary ? 0.95 : 0.75))
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(.white.opacity(primary ? 0.18 : 0.10), in: Capsule())
    }

    private var symbolFallbackContent: some View {
        Image(systemName: heroSymbol)
            .font(.system(size: 36))
            .foregroundStyle(.secondary)
    }

    private func drawPremiumPattern(context: GraphicsContext, size: CGSize) {
        let w = size.width
        let h = size.height

        for i in 0..<4 {
            let xFraction: [CGFloat] = [0.15, 0.55, 0.85, 0.35]
            let yFraction: [CGFloat] = [0.25, 0.6, 0.2, 0.75]
            let radius: CGFloat = CGFloat(30 + i * 18)
            let x = xFraction[i] * w
            let y = yFraction[i] * h

            let circle = Path(ellipseIn: CGRect(
                x: x - radius,
                y: y - radius,
                width: radius * 2,
                height: radius * 2
            ))
            context.fill(circle, with: .color(.white.opacity(0.035 - Double(i) * 0.005)))
        }

        let lineCount = 5
        for i in 0..<lineCount {
            let spacing = w / CGFloat(lineCount)
            let x = CGFloat(i) * spacing + spacing * 0.3
            var line = Path()
            line.move(to: CGPoint(x: x, y: h + 5))
            line.addLine(to: CGPoint(x: x + h * 0.3, y: -5))
            context.stroke(line, with: .color(.white.opacity(0.02)), lineWidth: 0.8)
        }

        var accentLine = Path()
        accentLine.move(to: CGPoint(x: 0, y: h * 0.85))
        accentLine.addQuadCurve(
            to: CGPoint(x: w, y: h * 0.65),
            control: CGPoint(x: w * 0.5, y: h * 0.95)
        )
        context.stroke(accentLine, with: .color(.white.opacity(0.04)), lineWidth: 1.2)
    }
}

struct ExerciseHeroView_Compact: View {
    let exercise: Exercise

    private let mediaProvider = ExerciseMediaProvider.shared
    private var gradientColors: [Color] { mediaProvider.heroGradient(for: exercise) }
    private var heroSymbol: String { mediaProvider.heroSymbol(for: exercise) }
    private var isTopExercise: Bool { mediaProvider.isTopExercise(exercise.id) }

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(
                        LinearGradient(
                            colors: [gradientColors[0], gradientColors[1]],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 56, height: 56)

                Image(systemName: heroSymbol)
                    .font(.system(size: 24, weight: .thin))
                    .foregroundStyle(.white.opacity(0.95))
            }

            VStack(alignment: .leading, spacing: 5) {
                HStack(spacing: 6) {
                    Text(exercise.name)
                        .font(.headline)
                        .lineLimit(1)

                    if isTopExercise {
                        Image(systemName: "star.fill")
                            .font(.system(size: 8))
                            .foregroundStyle(STRQBrand.steel.opacity(0.7))
                    }
                }

                HStack(spacing: 8) {
                    Text(exercise.primaryMuscle.displayName)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(gradientColors[0])

                    if exercise.category == .compound {
                        Text("Key Lift")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 7)
                            .padding(.vertical, 2.5)
                            .background(
                                LinearGradient(
                                    colors: [gradientColors[0], gradientColors[1]],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ),
                                in: Capsule()
                            )
                    } else if exercise.category == .bodyweight {
                        Text("Bodyweight")
                            .font(.system(size: 9, weight: .semibold))
                            .foregroundStyle(gradientColors[0])
                            .padding(.horizontal, 7)
                            .padding(.vertical, 2.5)
                            .background(gradientColors[0].opacity(0.12), in: Capsule())
                    }
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(.tertiary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        colors: [gradientColors[0].opacity(0.08), gradientColors[1].opacity(0.03)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(gradientColors[0].opacity(0.08), lineWidth: 0.5)
        )
    }
}
