import SwiftUI

struct ColorDetailsView: View {
    let color: RecognizedColor

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                color.swiftUIColor
                    .frame(height: 160)

                List {
                    LabeledContent("Name", value: color.name)
                    LabeledContent("HEX", value: color.hexValue)
                    LabeledContent("RGB", value: color.rgbString)
                    LabeledContent("HSB", value: color.hsbString)
                }
                .listStyle(.insetGrouped)
            }
            .ignoresSafeArea(edges: .top)
            .navigationTitle(color.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}
