import SwiftUI
import UIKit

/// An immutable, persistable colour together with its human-readable name and
/// pre-computed RGB/HSB components.
///
/// Components are stored rather than recomputed so the value can round-trip
/// through `Codable` without depending on `UIColor` at decode time.
struct RecognizedColor: Identifiable, Codable, Equatable, Sendable {
    let id: UUID
    let hexValue: String
    let name: String
    let timestamp: Date

    /// 0...255
    let red: Int
    let green: Int
    let blue: Int

    /// Hue in degrees (0...360); saturation and brightness in 0...1.
    let hue: Double
    let saturation: Double
    let brightness: Double

    var color: UIColor {
        UIColor(
            red: CGFloat(red) / 255.0,
            green: CGFloat(green) / 255.0,
            blue: CGFloat(blue) / 255.0,
            alpha: 1.0
        )
    }

    var swiftUIColor: Color {
        Color(color)
    }

    var rgbString: String {
        "RGB(\(red), \(green), \(blue))"
    }

    var hsbString: String {
        "HSB(\(Int(hue))°, \(Int(saturation * 100))%, \(Int(brightness * 100))%)"
    }

    private init(
        id: UUID,
        red: Int,
        green: Int,
        blue: Int,
        hue: Double,
        saturation: Double,
        brightness: Double,
        hexValue: String,
        name: String,
        timestamp: Date
    ) {
        self.id = id
        self.red = red
        self.green = green
        self.blue = blue
        self.hue = hue
        self.saturation = saturation
        self.brightness = brightness
        self.hexValue = hexValue
        self.name = name
        self.timestamp = timestamp
    }

    init(
        color: UIColor,
        id: UUID = UUID(),
        timestamp: Date = Date(),
        colorNamingService: ColorNaming = ColorNamingService.shared
    ) {
        let components = color.rgbHSBComponents
        self.init(
            id: id,
            red: Int(components.red * 255),
            green: Int(components.green * 255),
            blue: Int(components.blue * 255),
            hue: Double(components.hue * 360),
            saturation: Double(components.saturation),
            brightness: Double(components.brightness),
            hexValue: color.toHexString(),
            name: colorNamingService.name(for: color),
            timestamp: timestamp
        )
    }

    init(
        red: Int,
        green: Int,
        blue: Int,
        name: String,
        id: UUID = UUID(),
        timestamp: Date = Date()
    ) {
        let color = UIColor(
            red: CGFloat(red) / 255.0,
            green: CGFloat(green) / 255.0,
            blue: CGFloat(blue) / 255.0,
            alpha: 1.0
        )
        let components = color.rgbHSBComponents
        self.init(
            id: id,
            red: red,
            green: green,
            blue: blue,
            hue: Double(components.hue * 360),
            saturation: Double(components.saturation),
            brightness: Double(components.brightness),
            hexValue: color.toHexString(),
            name: name,
            timestamp: timestamp
        )
    }
}
