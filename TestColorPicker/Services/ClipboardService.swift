import UIKit

protocol ClipboardManaging {
    func copy(_ text: String)
}

final class ClipboardService: ClipboardManaging {
    static let shared = ClipboardService()

    private init() {}

    func copy(_ text: String) {
        UIPasteboard.general.string = text
    }
}

