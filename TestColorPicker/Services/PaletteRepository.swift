import Foundation

/// Abstraction over palette persistence so the UI layer never depends on a
/// concrete storage technology and can be exercised with in-memory fakes.
protocol PaletteRepository: Sendable {
    func load() async throws -> [ColorPalette]
    func save(_ palette: ColorPalette) async throws
    func delete(_ palette: ColorPalette) async throws
}

/// File-backed implementation that stores palettes as a single JSON document
/// in the app's Application Support directory.
///
/// An `actor` is used so concurrent reads/writes from the UI are serialized
/// without callers needing to reason about locking.
actor FilePaletteRepository: PaletteRepository {
    private let fileURL: URL
    private let fileManager: FileManager
    private let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }()
    private let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()

    init(fileManager: FileManager = .default, fileName: String = "palettes.json") {
        self.fileManager = fileManager
        let directory = (try? fileManager.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )) ?? fileManager.temporaryDirectory
        self.fileURL = directory.appendingPathComponent(fileName)
    }

    func load() async throws -> [ColorPalette] {
        guard fileManager.fileExists(atPath: fileURL.path) else { return [] }
        let data = try Data(contentsOf: fileURL)
        return try decoder.decode([ColorPalette].self, from: data)
    }

    func save(_ palette: ColorPalette) async throws {
        var palettes = try await load()
        if let index = palettes.firstIndex(where: { $0.id == palette.id }) {
            palettes[index] = palette
        } else {
            palettes.insert(palette, at: 0)
        }
        try persist(palettes)
    }

    func delete(_ palette: ColorPalette) async throws {
        var palettes = try await load()
        palettes.removeAll { $0.id == palette.id }
        try persist(palettes)
    }

    private func persist(_ palettes: [ColorPalette]) throws {
        let data = try encoder.encode(palettes)
        try data.write(to: fileURL, options: .atomic)
    }
}

/// Lightweight repository used by SwiftUI previews and unit tests.
actor InMemoryPaletteRepository: PaletteRepository {
    private var palettes: [ColorPalette]

    init(palettes: [ColorPalette] = []) {
        self.palettes = palettes
    }

    func load() async throws -> [ColorPalette] {
        palettes
    }

    func save(_ palette: ColorPalette) async throws {
        if let index = palettes.firstIndex(where: { $0.id == palette.id }) {
            palettes[index] = palette
        } else {
            palettes.insert(palette, at: 0)
        }
    }

    func delete(_ palette: ColorPalette) async throws {
        palettes.removeAll { $0.id == palette.id }
    }
}
