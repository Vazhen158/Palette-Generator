import UIKit

protocol PaletteGenerating {
    func generatePalette() -> ColorPalette
}

final class PaletteGeneratorService: PaletteGenerating {
    func generatePalette() -> ColorPalette {
        let paletteType = Int.random(in: 0...4)

        switch paletteType {
        case 0:
            return generateMonochromaticPalette()
        case 1:
            return generateAnalogousPalette()
        case 2:
            return generateComplementaryPalette()
        case 3:
            return generateTriadicPalette()
        default:
            return generateTetradicPalette()
        }
    }

    private func generateMonochromaticPalette() -> ColorPalette {
        let baseHue = Double.random(in: 0...1)
        let baseSaturation = Double.random(in: 0.3...0.8)

        let colors = (0..<5).map { index in
            let brightness = 0.2 + (Double(index) * 0.2)
            let saturation = baseSaturation - (Double(index) * 0.1)

            return makeRecognizedColor(
                hue: baseHue,
                saturation: max(0, saturation),
                brightness: brightness
            )
        }

        return ColorPalette(colors: colors)
    }

    private func generateAnalogousPalette() -> ColorPalette {
        let baseHue = Double.random(in: 0...1)
        let baseSaturation = Double.random(in: 0.4...0.8)
        let baseBrightness = Double.random(in: 0.5...0.9)

        let colors = (0..<5).map { index in
            let hue = (baseHue + Double(index - 2) * 0.05).truncatingRemainder(dividingBy: 1.0)
            let saturation = baseSaturation + Double.random(in: -0.2...0.2)
            let brightness = baseBrightness + Double.random(in: -0.2...0.2)

            return makeRecognizedColor(
                hue: hue < 0 ? hue + 1 : hue,
                saturation: saturation.clamped(to: 0...1),
                brightness: brightness.clamped(to: 0.2...1)
            )
        }

        return ColorPalette(colors: colors)
    }

    private func generateComplementaryPalette() -> ColorPalette {
        let baseHue = Double.random(in: 0...1)
        let complementaryHue = (baseHue + 0.5).truncatingRemainder(dividingBy: 1.0)

        let baseColors = (0..<3).map { index in
            makeRecognizedColor(
                hue: baseHue,
                saturation: 0.4 + Double(index) * 0.2,
                brightness: 0.3 + Double(index) * 0.3
            )
        }

        let complementaryColors = (0..<2).map { index in
            makeRecognizedColor(
                hue: complementaryHue,
                saturation: 0.5 + Double(index) * 0.3,
                brightness: 0.4 + Double(index) * 0.4
            )
        }

        return ColorPalette(colors: baseColors + complementaryColors)
    }

    private func generateTriadicPalette() -> ColorPalette {
        let baseHue = Double.random(in: 0...1)
        let hues = [
            baseHue,
            (baseHue + 0.33).truncatingRemainder(dividingBy: 1.0),
            (baseHue + 0.66).truncatingRemainder(dividingBy: 1.0)
        ]

        let colors = (0..<5).map { index in
            makeRecognizedColor(
                hue: hues[index % hues.count],
                saturation: Double.random(in: 0.4...0.8),
                brightness: Double.random(in: 0.4...0.9)
            )
        }

        return ColorPalette(colors: colors)
    }

    private func generateTetradicPalette() -> ColorPalette {
        let baseHue = Double.random(in: 0...1)
        let hues = [
            baseHue,
            (baseHue + 0.25).truncatingRemainder(dividingBy: 1.0),
            (baseHue + 0.5).truncatingRemainder(dividingBy: 1.0),
            (baseHue + 0.75).truncatingRemainder(dividingBy: 1.0)
        ]

        var colors = hues.map { hue in
            makeRecognizedColor(
                hue: hue,
                saturation: Double.random(in: 0.3...0.7),
                brightness: Double.random(in: 0.4...0.8)
            )
        }

        colors.append(
            makeRecognizedColor(
                hue: 0,
                saturation: 0,
                brightness: Double.random(in: 0.2...0.8)
            )
        )

        return ColorPalette(colors: colors)
    }

    private func makeRecognizedColor(hue: Double, saturation: Double, brightness: Double) -> RecognizedColor {
        let color = UIColor(
            hue: CGFloat(hue),
            saturation: CGFloat(saturation),
            brightness: CGFloat(brightness),
            alpha: 1.0
        )

        return RecognizedColor(color: color)
    }
}

