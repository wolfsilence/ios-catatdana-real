import Foundation

/// 请求描述 —— 汇总一次 HTTP 调用所需的全部参数
struct RequestBlueprint {
    /// 接口路径，如 "/v1/user/login"
    let route: String
    /// HTTP 动词
    let verb: HttpVerb
    /// 请求头
    let headerFields: [String: String]
    /// URL 查询参数
    let queryParameters: [String: String]?
    /// 需要 JSON 编码的请求体模型
    let encodableBody: Codable?
    /// 原始二进制请求体（优先级高于 encodableBody）
    let rawBody: Data?

    /// 拼接后的完整 URL
    var fullURL: URL? {
        guard var components = URLComponents(string: GatewayConfig.baseURLString + route) else {
            return nil
        }
        if let params = queryParameters, !params.isEmpty {
            components.queryItems = params.map { URLQueryItem(name: $0.key, value: $0.value) }
        }
        return components.url
    }
}
