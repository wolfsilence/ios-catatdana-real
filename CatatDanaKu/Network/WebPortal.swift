import Foundation

/// 对外暴露的 Web 请求门户（单例）
/// 提供便捷的 GET / POST / UPLOAD 方法，内部委托 HttpPerformer 执行
class WebPortal {
    static let shared = WebPortal()

    // MARK: - 默认请求头

    private let defaultHeaderFields: [String: String] = [
        "Content-Type": "application/json; charset=UTF-8",
    ]

    private init() {}

    // MARK: - 请求头合并

    /// 将调用方传入的自定义头与默认头合并
    private func foldHeaders(with customFields: [String: String]?) -> [String: String] {
        var combined = defaultHeaderFields
        customFields?.forEach { combined[$0.key] = $0.value }
        return combined
    }

    // MARK: - 通用请求

    /// 发起一次完整的 HTTP 请求（最底层入口）
    func fetch<T: Codable>(
        route: String,
        verb: HttpVerb,
        headerFields: [String: String]? = nil,
        queryParameters: [String: String]? = nil,
        encodableBody: Codable? = nil,
        rawBody: Data? = nil
    ) async -> ServiceResponse<T> {
        let blueprint = RequestBlueprint(
            route:           route,
            verb:            verb,
            headerFields:    foldHeaders(with: headerFields),
            queryParameters: queryParameters,
            encodableBody:   encodableBody,
            rawBody:         rawBody
        )
        return await HttpPerformer.shared.execute(blueprint: blueprint)
    }

    // MARK: - 便捷方法

    /// POST 请求
    func send<T: Codable>(
        route: String,
        headerFields: [String: String]? = nil,
        payload: Codable? = nil
    ) async -> ServiceResponse<T> {
        return await fetch(
            route:         route,
            verb:          .post,
            headerFields:  headerFields,
            encodableBody: payload
        )
    }

    /// GET 请求
    func query<T: Codable>(
        route: String,
        headerFields: [String: String]? = nil,
        queryParameters: [String: String]? = nil
    ) async -> ServiceResponse<T> {
        return await fetch(
            route:           route,
            verb:            .get,
            headerFields:    headerFields,
            queryParameters: queryParameters
        )
    }

    /// 上传二进制数据（如图片）
    func uploadResource<T: Codable>(
        route: String,
        binaryData: Data
    ) async -> ServiceResponse<T> {
        let headers = ["Content-Type": "application/octet-stream"]
        return await fetch(
            route:         route,
            verb:          .post,
            headerFields:  headers,
            rawBody:       binaryData
        )
    }
}
