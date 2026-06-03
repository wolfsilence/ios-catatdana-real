import Foundation

/// 调试日志输出（仅在 DEBUG 构建中生效）
enum LogWriter {
    static func trace(_ message: String) {
        #if DEBUG
        Swift.print(message)
        #endif
    }
}
