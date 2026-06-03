import Foundation

/// 本地化文案
enum LocalizedText {
    enum Error {
        static let generalFailure = NSLocalizedString(
            "error.server.unavailable",
            value: "服务器繁忙，请稍后重试",
            comment: "通用服务端错误提示"
        )
    }
}
