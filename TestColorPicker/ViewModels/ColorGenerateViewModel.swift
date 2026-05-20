import Combine
import Foundation
import OSLog

@MainActor
final class ColorGenerateViewModel: ObservableObject {
    @Published private(set) var currentPalette: ColorPalette = .empty
    @Published private(set) var savedPalettes: [ColorPalette] = []
    @Published var showingHistory = false

    private let paletteGenerator: PaletteGenerating
    private let repository: PaletteRepository
    private let logger = Logger(subsystem: "TestColorPicker", category: "ColorGenerate")

    var currentColors: [RecognizedColor] {
        currentPalette.colors
    }

    var hasGeneratedColors: Bool {
        !currentPalette.colors.isEmpty
    }

    init(
        paletteGenerator: PaletteGenerating = PaletteGeneratorService(),
        repository: PaletteRepository = FilePaletteRepository()
    ) {
        self.paletteGenerator = paletteGenerator
        self.repository = repository
    }

    func generateInitialPaletteIfNeeded() {
        guard currentPalette.colors.isEmpty else { return }
        generatePalette()
    }

    func generatePalette() {
        currentPalette = paletteGenerator.generatePalette()
    }

    func updateColor(_ color: RecognizedColor, at index: Int) {
        guard currentPalette.colors.indices.contains(index) else { return }
        var colors = currentPalette.colors
        colors[index] = color
        currentPalette = ColorPalette(
            id: currentPalette.id,
            colors: colors,
            createdAt: currentPalette.createdAt
        )
    }

    func loadSavedPalettes() async {
        do {
            savedPalettes = try await repository.load()
        } catch {
            logger.error("Failed to load palettes: \(error.localizedDescription, privacy: .public)")
        }
    }

    func saveCurrentPalette() async {
        guard hasGeneratedColors else { return }
        do {
            try await repository.save(currentPalette)
            savedPalettes = try await repository.load()
        } catch {
            logger.error("Failed to save palette: \(error.localizedDescription, privacy: .public)")
        }
    }

    func deletePalette(_ palette: ColorPalette) async {
        do {
            try await repository.delete(palette)
            savedPalettes = try await repository.load()
        } catch {
            logger.error("Failed to delete palette: \(error.localizedDescription, privacy: .public)")
        }
    }
}
