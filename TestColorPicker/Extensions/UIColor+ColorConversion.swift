import Foundation
import UIKit

extension UIColor {
    struct Components {
        let red: CGFloat
        let green: CGFloat
        let blue: CGFloat
        let hue: CGFloat
        let saturation: CGFloat
        let brightness: CGFloat
        let alpha: CGFloat
    }

    /// Extracts RGB and HSB components in a single call to avoid the repeated
    /// `getRed`/`getHue` boilerplate scattered across the codebase.
    var rgbHSBComponents: Components {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)

        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)

        return Components(
            red: red,
            green: green,
            blue: blue,
            hue: hue,
            saturation: saturation,
            brightness: brightness,
            alpha: alpha
        )
    }

    func toHexString() -> String {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0

        getRed(&red, green: &green, blue: &blue, alpha: &alpha)

        let rgb = Int(red * 255) << 16 | Int(green * 255) << 8 | Int(blue * 255)
        return String(format: "#%06x", rgb)
    }

    func toLAB() -> (L: Double, A: Double, B: Double) {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)

        let redLinear = Double(red > 0.04045 ? pow((red + 0.055) / 1.055, 2.4) : red / 12.92)
        let greenLinear = Double(green > 0.04045 ? pow((green + 0.055) / 1.055, 2.4) : green / 12.92)
        let blueLinear = Double(blue > 0.04045 ? pow((blue + 0.055) / 1.055, 2.4) : blue / 12.92)

        let x = redLinear * 0.4124564 + greenLinear * 0.3575761 + blueLinear * 0.1804375
        let y = redLinear * 0.2126729 + greenLinear * 0.7151522 + blueLinear * 0.0721750
        let z = redLinear * 0.0193339 + greenLinear * 0.1191920 + blueLinear * 0.9503041

        let normalizedX = x / 0.95047
        let normalizedY = y / 1.00000
        let normalizedZ = z / 1.08883

        let fx = normalizedX > 0.008856 ? pow(normalizedX, 1.0 / 3.0) : (7.787 * normalizedX + 16.0 / 116.0)
        let fy = normalizedY > 0.008856 ? pow(normalizedY, 1.0 / 3.0) : (7.787 * normalizedY + 16.0 / 116.0)
        let fz = normalizedZ > 0.008856 ? pow(normalizedZ, 1.0 / 3.0) : (7.787 * normalizedZ + 16.0 / 116.0)

        let luminance = 116.0 * fy - 16.0
        let a = 500.0 * (fx - fy)
        let b = 200.0 * (fy - fz)

        return (luminance, a, b)
    }

    convenience init?(hex: String) {
        let hexString = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanHex = hexString.hasPrefix("#") ? String(hexString.dropFirst()) : hexString

        guard cleanHex.count == 6 else {
            return nil
        }

        var rgbValue: UInt64 = 0
        Scanner(string: cleanHex).scanHexInt64(&rgbValue)

        self.init(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: 1.0
        )
    }
}

