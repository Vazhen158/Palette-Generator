import UIKit

struct ColorDatabase: Codable {
    let colors: [ColorEntry]
}

struct ColorEntry: Codable {
    let color: String
    let hex: String

    /// Returns black for malformed hex strings; the reference database is a
    /// bundled, validated resource so this is a safe degradation.
    var uiColor: UIColor {
        UIColor(hex: hex) ?? .black
    }
}

