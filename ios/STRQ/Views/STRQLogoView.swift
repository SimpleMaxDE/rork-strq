import SwiftUI

struct STRQLogoView: View {
    var size: CGFloat = 64
    var animated: Bool = false

    @State private var revealed: Bool = false
    @State private var glowPulse: Bool = false

    var body: some View {
        ZStack {
            if animated {
                Circle()
                    .fill(Color.white.opacity(glowPulse ? 0.06 : 0.02))
                    .frame(width: size * 1.8, height: size * 1.8)
                    .blur(radius: size * 0.3)
                    .animation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true), value: glowPulse)
            }

            Image("STRQSigil")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: size, height: size)
                .opacity(animated ? (revealed ? 1 : 0) : 1)
                .scaleEffect(animated ? (revealed ? 1 : 0.7) : 1)
                .offset(x: animated ? (revealed ? 0 : -8) : 0)
        }
        .onAppear {
            if animated {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.15)) {
                    revealed = true
                }
                withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true).delay(0.8)) {
                    glowPulse = true
                }
            }
        }
    }
}

struct STRQBrandMark: View {
    var body: some View {
        HStack(spacing: 10) {
            STRQLogoView(size: 28, animated: false)
            Text(L10n.tr("STRQ"))
                .font(.system(size: 18, weight: .black, design: .default))
                .tracking(2)
                .foregroundStyle(.white)
        }
    }
}
