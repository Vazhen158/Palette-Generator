import SwiftUI

extension View {
    func glassmorphism(cornerRadius: CGFloat = 20, borderOpacity: Double = 0.2) -> some View {
        modifier(GlassmorphismModifier(cornerRadius: cornerRadius, borderOpacity: borderOpacity))
    }

    func lightGlass(cornerRadius: CGFloat = 16) -> some View {
        modifier(LightGlassModifier(cornerRadius: cornerRadius))
    }
}

