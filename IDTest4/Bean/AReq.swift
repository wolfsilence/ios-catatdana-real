import Foundation

// AReq
struct AReq: Codable {
    var type: String?
    var data: [String: String]? // 可以传入任意发挥的字段
}
