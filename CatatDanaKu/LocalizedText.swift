import Foundation

/// 文案
enum LocalizedText {
    enum Error {
        static let serverUnavailable = NSLocalizedString(
            "error.serverUnavailable",
            value: "Server sedang sibuk, silakan coba lagi nanti",
            comment: ""
        )
    }
}
