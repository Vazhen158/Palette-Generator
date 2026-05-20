import SwiftUI

struct ColorGenerateView: View {
    @StateObject private var viewModel = ColorGenerateViewModel()
    @State private var showingSavedToast = false

    var body: some View {
        NavigationStack {
            ZStack {
                background

                VStack(spacing: 0) {
                    header
                    content
                    Spacer(minLength: 0)
                    generateButton
                }
            }
            .toolbar(.hidden, for: .navigationBar)
        }
        .task {
            viewModel.generateInitialPaletteIfNeeded()
            await viewModel.loadSavedPalettes()
        }
        .sheet(isPresented: $viewModel.showingHistory) {
            PaletteHistoryView(palettes: viewModel.savedPalettes) { palette in
                Task { await viewModel.deletePalette(palette) }
            }
        }
    }

    private var background: some View {
        LinearGradient(
            colors: [
                Color.indigo.opacity(0.3),
                Color.blue.opacity(0.2),
                Color.cyan.opacity(0.1)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .background(.ultraThinMaterial)
        .ignoresSafeArea()
    }

    private var header: some View {
        HStack {
            Text("Generator")
                .font(.system(size: 28, weight: .bold))

            Spacer()

            Button {
                viewModel.showingHistory = true
            } label: {
                Image(systemName: "clock")
                    .font(.system(size: 18, weight: .medium))
            }

            Button {
                Task {
                    await viewModel.saveCurrentPalette()
                    withAnimation { showingSavedToast = true }
                }
            } label: {
                Image(systemName: "square.and.arrow.down")
                    .font(.system(size: 18, weight: .medium))
            }
            .disabled(!viewModel.hasGeneratedColors)
            .padding(.leading, 16)
        }
        .foregroundStyle(.primary)
        .buttonStyle(.plain)
        .padding(.horizontal, 20)
        .padding(.top, 20)
        .padding(.bottom, 24)
        .copiedToast(isPresented: $showingSavedToast, text: "Saved")
    }

    @ViewBuilder
    private var content: some View {
        if viewModel.hasGeneratedColors {
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(Array(viewModel.currentColors.enumerated()), id: \.element.id) { index, color in
                        ColorCardView(color: color) { updated in
                            viewModel.updateColor(updated, at: index)
                        }
                        .padding(.horizontal, 16)
                    }
                }
                .padding(.vertical, 8)
            }
        } else {
            emptyState
        }
    }

    private var emptyState: some View {
        VStack(spacing: 20) {
            Image(systemName: "paintpalette")
                .font(.system(size: 48, weight: .light))
                .foregroundStyle(.primary.opacity(0.7))
                .frame(width: 120, height: 120)
                .background(.ultraThinMaterial, in: Circle())
                .overlay(Circle().stroke(.white.opacity(0.2), lineWidth: 1))

            VStack(spacing: 8) {
                Text("Create your own palette")
                    .font(.system(size: 20, weight: .semibold))
                Text("Click the button to create a unique color palette")
                    .font(.system(size: 16))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.vertical, 40)
        .lightGlass(cornerRadius: 20)
        .padding(.horizontal, 16)
    }

    private var generateButton: some View {
        Button {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                viewModel.generatePalette()
            }
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "sparkles")
                Text("Create a palette").fontWeight(.semibold)
            }
            .font(.system(size: 18))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(
                LinearGradient(
                    colors: [.blue, .purple],
                    startPoint: .leading,
                    endPoint: .trailing
                ),
                in: RoundedRectangle(cornerRadius: 16)
            )
            .shadow(color: .blue.opacity(0.3), radius: 12, y: 6)
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 16)
        .padding(.bottom, 32)
    }
}

struct ColorCardView: View {
    let color: RecognizedColor
    let onChange: (RecognizedColor) -> Void

    @State private var showingCopied = false
    @State private var showingEditor = false
    @State private var showingDetails = false
    private let clipboardService: ClipboardManaging

    init(
        color: RecognizedColor,
        clipboardService: ClipboardManaging = ClipboardService.shared,
        onChange: @escaping (RecognizedColor) -> Void
    ) {
        self.color = color
        self.clipboardService = clipboardService
        self.onChange = onChange
    }

    var body: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(color.swiftUIColor)
            .frame(height: 80)
            .overlay {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(color.name)
                            .font(.system(size: 18))
                        Text(color.hexValue)
                            .font(.system(size: 14, weight: .light, design: .monospaced))
                    }
                    .foregroundStyle(adaptiveTextColor)
                    .shadow(color: adaptiveShadowColor, radius: 2, x: 1, y: 1)

                    Spacer()

                    HStack(spacing: 16) {
                        Button {
                            showingDetails = true
                        } label: {
                            Image(systemName: "info.circle")
                        }

                        Button {
                            showingEditor = true
                        } label: {
                            Image(systemName: "slider.horizontal.3")
                        }
                    }
                    .font(.system(size: 18))
                    .foregroundStyle(adaptiveTextColor)
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            }
            .shadow(color: .black.opacity(0.2), radius: 4, y: 2)
            .contentShape(RoundedRectangle(cornerRadius: 16))
            .onTapGesture { copyToClipboard() }
            .copiedToast(isPresented: $showingCopied)
            .sheet(isPresented: $showingEditor) {
                ColorEditorView(color: color, onCommit: onChange)
            }
            .sheet(isPresented: $showingDetails) {
                ColorDetailsView(color: color)
            }
    }

    private var isDarkColor: Bool {
        let c = color.color.rgbHSBComponents
        let luminance = 0.299 * c.red + 0.587 * c.green + 0.114 * c.blue
        return luminance < 0.5
    }

    private var adaptiveTextColor: Color {
        isDarkColor ? .white : .black
    }

    private var adaptiveShadowColor: Color {
        isDarkColor ? .black : .white.opacity(0.8)
    }

    private func copyToClipboard() {
        clipboardService.copy(color.hexValue)
        withAnimation(.easeInOut(duration: 0.3)) {
            showingCopied = true
        }
    }
}

#Preview {
    ColorGenerateView()
}
