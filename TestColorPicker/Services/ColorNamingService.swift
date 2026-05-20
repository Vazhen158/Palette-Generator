import Foundation
import OSLog
import UIKit

protocol ColorNaming {
    func name(for color: UIColor) -> String
}

/// Resolves a human-readable name for a colour.
///
/// Matching is done in CIE L*a*b* space (ΔE / CIE76) rather than naive sRGB
/// Euclidean distance, which is perceptually inaccurate. Lab values for the
/// reference database are computed once and cached.
final class ColorNamingService: ColorNaming {
    static let shared = ColorNamingService()

    private struct LabEntry {
        let name: String
        let l: Double
        let a: Double
        let b: Double
    }

    private let logger = Logger(subsystem: "TestColorPicker", category: "ColorNaming")
    private let lock = NSLock()
    private var cachedEntries: [LabEntry]?
    private var didAttemptLoad = false

    init() {}

    func name(for color: UIColor) -> String {
        let entries = referenceEntries()
        guard !entries.isEmpty else {
            return fallbackName(for: color)
        }

        let target = color.toLAB()
        var closestName: String?
        var smallestDistance = Double.infinity

        for entry in entries {
            let dL = target.L - entry.l
            let dA = target.A - entry.a
            let dB = target.B - entry.b
            let distance = dL * dL + dA * dA + dB * dB
            if distance < smallestDistance {
                smallestDistance = distance
                closestName = entry.name
            }
        }

        return closestName?.capitalized ?? fallbackName(for: color)
    }

    // MARK: - Database loading

    private func referenceEntries() -> [LabEntry] {
        lock.lock()
        defer { lock.unlock() }

        if let cachedEntries {
            return cachedEntries
        }
        guard !didAttemptLoad else {
            return []
        }
        didAttemptLoad = true

        guard let database = loadDatabase() else {
            logger.warning("Color database not found in bundle. Falling back to heuristic naming.")
            return []
        }

        let entries = database.colors.map { entry -> LabEntry in
            let lab = entry.uiColor.toLAB()
            return LabEntry(name: entry.color, l: lab.L, a: lab.A, b: lab.B)
        }
        cachedEntries = entries
        return entries
    }

    private func loadDatabase(bundle: Bundle = .main) -> ColorDatabase? {
        for fileName in ["ColorName", "colors", "color_database"] {
            guard let url = bundle.url(forResource: fileName, withExtension: "json"),
                  let data = try? Data(contentsOf: url),
                  let database = try? JSONDecoder().decode(ColorDatabase.self, from: data)
            else {
                continue
            }
            return database
        }
        return nil
    }

    private func fallbackName(for color: UIColor) -> String {
        let components = color.rgbHSBComponents

        if components.saturation < 0.12 {
            switch components.brightness {
            case ..<0.15: return "Black"
            case ..<0.35: return "Dark Gray"
            case ..<0.65: return "Gray"
            case ..<0.85: return "Light Gray"
            default: return "White"
            }
        }

        switch components.hue * 360 {
        case ..<15, 345...: return "Red"
        case ..<45: return "Orange"
        case ..<75: return "Yellow"
        case ..<165: return "Green"
        case ..<255: return "Blue"
        case ..<285: return "Purple"
        default: return "Pink"
        }
    }
}
