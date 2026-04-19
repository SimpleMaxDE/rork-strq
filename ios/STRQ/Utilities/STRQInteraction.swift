import SwiftUI

/// Unified interaction primitives for STRQ.
/// Keeps pressed-state, haptics, and motion consistent across the app.
enum STRQMotion {
    /// Baseline spring for UI state changes (selection, toggle, expand).
    static let spring: Animation = .spring(response: 0.32, dampingFraction: 0.82)
    /// Snappier spring for tactile controls (steppers, row taps).
    static let tap: Animation = .spring(response: 0.22, dampingFraction: 0.78)
    /// Short ease for fades and minor transitions.
    static let fade: Animation = .easeOut(duration: 0.22)
}

// MARK: - Pressable button style

/// Subtle scale + dim on touch down. Matches iOS native row/button feel.
struct STRQPressableStyle: ButtonStyle {
    var scale: CGFloat = 0.97
    var dim: Double = 0.6

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? scale : 1.0)
            .opacity(configuration.isPressed ? dim : 1.0)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

/// Tighter press for dense rows and list items — no scale, just a soft highlight overlay.
struct STRQRowPressStyle: ButtonStyle {
    var cornerRadius: CGFloat = 0

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(
                Color.white.opacity(configuration.isPressed ? 0.05 : 0),
                in: .rect(cornerRadius: cornerRadius)
            )
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

/// For stepper +/- controls: firmer, more tactile dim+scale.
struct STRQStepperStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.88 : 1.0)
            .opacity(configuration.isPressed ? 0.55 : 1.0)
            .animation(.spring(response: 0.18, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

extension ButtonStyle where Self == STRQPressableStyle {
    static var strqPressable: STRQPressableStyle { STRQPressableStyle() }
}

extension ButtonStyle where Self == STRQRowPressStyle {
    static var strqRow: STRQRowPressStyle { STRQRowPressStyle() }
    static func strqRow(cornerRadius: CGFloat) -> STRQRowPressStyle { STRQRowPressStyle(cornerRadius: cornerRadius) }
}

extension ButtonStyle where Self == STRQStepperStyle {
    static var strqStepper: STRQStepperStyle { STRQStepperStyle() }
}
