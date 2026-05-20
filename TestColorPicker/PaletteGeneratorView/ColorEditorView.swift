import SwiftUI

/// HSB editor for a single colour. The edited value is reported back through
/// `onCommit` so the view model stays the single source of truth.
struct ColorEditorView: View {
    let initialColor: RecognizedColor
    let onCommit: (RecognizedColor) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var hsb: HSBColor

    init(color: RecognizedColor, onCommit: @escaping (RecognizedColor) -> Void) {
        self.initialColor = color
        self.onCommit = onCommit
        _hsb = State(initialValue: color.hsbColor)
    }

    private var previewColor: RecognizedColor {
        RecognizedColor(color: hsb.uiColor)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                RoundedRectangle(cornerRadius: 16)
                    .fill(hsb.color)
                    .frame(height: 120)
                    .overlay(alignment: .bottomLeading) {
                        Text(previewColor.hexValue)
                            .font(.system(.callout, design: .monospaced))
                            .padding(10)
                    }
                    .shadow(color: .black.opacity(0.2), radius: 4, y: 2)

                slider("Hue", value: $hsb.hue, range: 0...360)
                slider("Saturation", value: $hsb.saturation, range: 0...100)
                slider("Brightness", value: $hsb.brightness, range: 0...100)

                Spacer()
            }
            .padding(20)
            .navigationTitle("Edit Color")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        onCommit(previewColor)
                        dismiss()
                    }
                }
            }
        }
    }

    private func slider(
        _ title: String,
        value: Binding<Double>,
        range: ClosedRange<Double>
    ) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(title)
                Spacer()
                Text("\(Int(value.wrappedValue))")
                    .foregroundStyle(.secondary)
                    .monospacedDigit()
            }
            .font(.subheadline)

            Slider(
                value: Binding(
                    get: { value.wrappedValue },
                    set: { value.wrappedValue = $0.clamped(to: range) }
                ),
                in: range
            )
        }
    }
}
