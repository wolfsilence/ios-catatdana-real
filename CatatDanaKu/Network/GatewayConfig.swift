import Foundation

/// 网关全局配置
enum GatewayConfig {
    /// 接口基地址
    static let baseURLString: String = "https://api.example.com"
    /// 请求超时（秒）
    static let timeoutInterval: TimeInterval = 30
    /// 是否启用请求体加密
    static let useEncryption: Bool = false
}
