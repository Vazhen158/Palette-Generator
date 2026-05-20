
extension RecognizedColor {
    var hsbColor: HSBColor {
        HSBColor(
            hue: hue,
            saturation: saturation * 100,
            brightness: brightness * 100,
            alpha: 1.0
        )
    }
}

