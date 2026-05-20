
import SwiftUI

/// Presents a transient "Copied" confirmation pill, removing the duplicated
/// `DispatchQueue.asyncAfter` toast logic that previously lived in views.
private struct CopiedToastModifier: ViewModifier {
    @Binding var isPresented: Bool
    var text: String

    func body(content: Content) -> some View {
        content.overlay(alignment: .center) {
            if isPresented {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark")
                        .font(.system(size: 12, weight: .semibold))
                    Text(text)
                        .font(.caption.weight(.medium))
                }
                .foregroundStyle(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(.green, in: Capsule())
                .shadow(color: .black.opacity(0.2), radius: 4, y: 2)
                .transition(.scale.combined(with: .opacity))
                .task {
                    try? await Task.sleep(for: .seconds(1.5))
                    withAnimation(.easeOut(duration: 0.3)) {
                        isPresented = false
                    }
                }
            }
        }
    }
}

extension View {
    func copiedToast(isPresented: Binding<Bool>, text: String = "Copied") -> some View {
        modifier(CopiedToastModifier(isPresented: isPresented, text: text))
    }
}
