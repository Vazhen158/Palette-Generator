import Foundation

struct ColorPalette: Identifiable, Codable, Equatable, Sendable {
    let id: UUID
    let colors: [RecognizedColor]
    let createdAt: Date

    init(id: UUID = UUID(), colors: [RecognizedColor], createdAt: Date = Date()) {
        self.id = id
        self.colors = colors
        self.createdAt = createdAt
    }

    static let empty = ColorPalette(colors: [])
}

