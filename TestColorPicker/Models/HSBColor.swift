
import SwiftUI
import UIKit

/// Hue is expressed in degrees (0...360); saturation, brightness and alpha in
/// percent/normalised form (0...100 / 0...1). Inputs are clamped on init so
/// the derived `Color`/`UIColor` are always valid.
struct HSBColor {
    var hue: Double
    var saturation: Double
    var brightness: Double
    var alpha: Double

    init(hue: Double, saturation: Double, brightness: Double, alpha: Double = 1.0) {
        self.hue = hue.clamped(to: 0...360)
        self.saturation = saturation.clamped(to: 0...100)
        self.brightness = brightness.clamped(to: 0...100)
        self.alpha = alpha.clamped(to: 0...1)
    }

    var color: Color {
        Color(
            hue: hue / 360.0,
            saturation: saturation / 100.0,
            brightness: brightness / 100.0,
            opacity: alpha
        )
    }

    var uiColor: UIColor {
        UIColor(
            hue: hue / 360.0,
            saturation: saturation / 100.0,
            brightness: brightness / 100.0,
            alpha: alpha
        )
    }
}

