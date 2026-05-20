import SwiftUI

struct PaletteHistoryView: View {
    let palettes: [ColorPalette]
    let onDelete: (ColorPalette) -> Void

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Group {
                if palettes.isEmpty {
                    ContentUnavailableView(
                        "No Saved Palettes",
                        systemImage: "paintpalette",
                        description: Text("Saved palettes will appear here.")
                    )
                } else {
                    List {
                        ForEach(Array(palettes.enumerated()), id: \.element.id) { index, palette in
                            PaletteHistoryRow(palette: palette, index: index)
                        }
                        .onDelete { offsets in
                            offsets.map { palettes[$0] }.forEach(onDelete)
                        }
                    }
                }
            }
            .navigationTitle("History")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

private struct PaletteHistoryRow: View {
    let palette: ColorPalette
    let index: Int
    @State private var showingCopied = false
    private let clipboardService: ClipboardManaging = ClipboardService.shared

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 0) {
                ForEach(palette.colors) { color in
                    Rectangle().fill(color.swiftUIColor)
                }
            }
            .frame(height: 56)
            .clipShape(RoundedRectangle(cornerRadius: 12))

            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Palette #\(index + 1)")
                        .font(.subheadline.weight(.semibold))
                    Text("\(palette.colors.count) colors • \(palette.createdAt.formatted(date: .abbreviated, time: .shortened))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Button {
                    copyHexValues()
                } label: {
                    Image(systemName: "doc.on.doc")
                }
                .buttonStyle(.borderless)
            }
        }
        .padding(.vertical, 4)
        .copiedToast(isPresented: $showingCopied)
    }

    private func copyHexValues() {
        let hexValues = palette.colors.map(\.hexValue).joined(separator: ", ")
        clipboardService.copy(hexValues)
        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
            showingCopied = true
        }
    }
}
