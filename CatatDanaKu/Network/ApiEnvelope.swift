import Foundation

/// 服务端 JSON 响应的通用外层结构
/// JSON 形如: { "code": 200, "msg": "ok", "data": { ... } }
struct ApiEnvelope<T: Codable>: Codable {
    let httpCode: Int?
    let serverMessage: String?
    let content: T?

    enum CodingKeys: String, CodingKey {
        case httpCode      = "code"
        case serverMessage = "msg"
        case content       = "data"
    }
}
