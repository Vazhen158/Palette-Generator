import SwiftUI

// MARK: - Glassmorphism Modifiers
struct GlassmorphismModifier: ViewModifier {
    var cornerRadius: CGFloat = 20
    var borderOpacity: Double = 0.2
    
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(.white.opacity(0.15))
                    .background(
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .fill(.ultraThinMaterial)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        .white.opacity(borderOpacity * 2),
                                        .white.opacity(borderOpacity * 0.5),
                                        .clear
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1.5
                            )
                    )
                    .shadow(color: .black.opacity(0.1), radius: 15, x: 0, y: 8)
                    .shadow(color: .white.opacity(0.8), radius: 1, x: 0, y: 1)
            )
    }
}

struct LightGlassModifier: ViewModifier {
    var cornerRadius: CGFloat = 16
    
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(.white.opacity(0.25))
                    .background(
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .fill(.thinMaterial)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .stroke(.white.opacity(0.5), lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.08), radius: 10, x: 0, y: 4)
            )
    }
}

struct GlassButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(width: 36, height: 36)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}
