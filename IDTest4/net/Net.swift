import Foundation
import Gzip

/// 对外暴露的 Web 请求门户（单例）
/// 提供便捷的 GET / POST / UPLOAD 方法，内部委托 HttpPerformer 执行
class Net {
    static let shared = Net()

    private init() {}
    
    private let core = NetCore()

 
    // MARK: - 通用请求
    
    /// 发起一次完整的 HTTP 请求（最底层入口）
    func request<T: Codable>(
        path: String,
        method: HttpMethods,
        headerFields: [String: String]? = nil,
        queryParameters: [String: String]? = nil,
        encodableBody: Codable? = nil,
        rawBody: Data? = nil
    ) async -> NetResp<T> {
        return await core.execute(
            path: path,
            method: method,
            headerFields: headerFields,
            queryParameters: queryParameters,
            encodableBody: encodableBody,
            rawBody: rawBody
        )
    }

    // MARK: - 便捷方法

    /// POST 请求
    func post<T: Codable>(
        path: String,
        encodableBody: Codable,
        headerFields: [String: String]? = nil
    ) async -> NetResp<T> {
        return await request(
            path: path,
            method: .post,
            headerFields: headerFields,
            encodableBody: encodableBody
        )
    }

    /// GET 请求
    func get<T: Codable>(
        path: String,
        queryParameters: [String: String]? = nil,
        headerFields: [String: String]? = nil
    ) async -> NetResp<T> {
        return await request(
            path: path,
            method: .get,
            headerFields: headerFields,
            queryParameters: queryParameters
        )
    }

    /// 上传二进制数据（如图片）
    func uploadImage<T: Codable>(
        path: String,
        rawBody: Data
    ) async -> NetResp<T> {
        let headers = ["Content-Type": "application/octet-stream"]
        return await request(
            path: path,
            method: .post,
            headerFields: headers,
            rawBody: rawBody
        )
    }
    
    /// 上传二进制数据（如图片）
    func postGzip<T: Codable>(
        path: String,
        gzipedBody: Data
    ) async -> NetResp<T> {
        let headers = ["Content-Encoding":"gzip","Content-Type":"application/octet-stream"]
        return await request(
            path: path,
            method: .post,
            headerFields: headers,
            rawBody: gzipedBody
        )
    }
}


/// 网络请求执行引擎（单例）
/// 负责 URLSession 管理、请求构建、加解密、日志追踪、会话过期处理
fileprivate class NetCore {
    // MARK: - 私有属性

    private let urlSession: URLSession
    private let jsonEncoder: JSONEncoder
    private let jsonDecoder: JSONDecoder
    
    // MARK: - 请求头合并
    private let defaultHeaderFields: [String: String] = [
        "Content-Type": "application/json; charset=UTF-8",
    ]

    // MARK: - 初始化

    init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForResource = 45
        config.timeoutIntervalForRequest  = 10
        config.httpAdditionalHeaders = [
            "Accept": "*/*",
        ]
      
        self.jsonDecoder = JSONDecoder()
        self.jsonEncoder = JSONEncoder()
        self.urlSession  = URLSession(configuration: config)
    }

    // MARK: - 请求构建

    /// 根据 NetRequestPack 组装 URLRequest
    private func composeURLRequest(
        path: String,
        method: HttpMethods,
        headerFields: [String: String]?,
        queryParameters: [String: String]?,
        encodableBody: Codable?,
        rawBody: Data?
    ) throws -> URLRequest {
        // url
        guard let url = fullURL(path: path, queryParameters: queryParameters) else {
            throw AppErrors.URL
        }
        var urlRequest = URLRequest(url: url)
        urlRequest.timeoutInterval  = 15
        urlRequest.httpMethod       = method.rawValue
        let headers = combineHeaders(with: headerFields)
        // 写入请求头
        for (key, value) in headers {
            urlRequest.setValue(value, forHTTPHeaderField: key)
        }
        // 认证令牌
        if let token = AuthHelper.shared.accessToken {
            urlRequest.setValue(token, forHTTPHeaderField: "x-k")
        }
        // 客户端版本（加密模式下附带）
        if Consts.encry,
           let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            urlRequest.setValue(appVersion, forHTTPHeaderField: "x-klxob")
        }
        // 处理请求体
        let contentType = headers["Content-Type"] ?? ""
        let isEncryptedJsonPost = method == .post && contentType.contains("application/json")
        if isEncryptedJsonPost && Consts.encry{
            // 加密模式：模型 → JSON 字符串 → 加密 → 放入 body
            guard let body = encodableBody else {
                throw AppErrors.NoBody
            }
            let jsonData = try jsonEncoder.encode(body)
            guard let bodyStr = String(data: jsonData, encoding: .utf8) else {
                throw AppErrors.JsonParse
            }
            Logger.log("Real Request: \(bodyStr)")
            let encryptedString = try CdBox.stA(real: bodyStr)
            urlRequest.httpBody = encryptedString.data(using: .utf8)
        } else {
            // 普通模式：优先使用 rawBody，其次 JSON 编码 encodableBody
            if let rawBody = rawBody {
                urlRequest.httpBody = rawBody
            } else if let model = encodableBody, method != .get {
                urlRequest.httpBody = try jsonEncoder.encode(model)
            }
        }

        logOutgoing(urlRequest)
        return urlRequest
    }
    
    /// 将调用方传入的自定义头与默认头合并
    private func combineHeaders(with customFields: [String: String]?) -> [String: String] {
        var combined = defaultHeaderFields
        customFields?.forEach { combined[$0.key] = $0.value }
        return combined
    }
    
    private func fullURL(path : String, queryParameters: [String: String]? = nil) -> URL?{
        guard var components = URLComponents(string: Consts.bURL + path) else {
            return nil
        }
        if let params = queryParameters, !params.isEmpty {
            components.queryItems = params.map { URLQueryItem(name: $0.key, value: $0.value) }
        }
        return components.url
    }
    

    // MARK: - 公开方法

    /// 执行一次网络请求
    func execute<T: Codable>(
        path: String,
        method: HttpMethods,
        headerFields: [String: String]?,
        queryParameters: [String: String]?,
        encodableBody: Codable?,
        rawBody: Data?
    ) async -> NetResp<T> {
        do {
            let urlRequest = try composeURLRequest(
                path: path,
                method: method,
                headerFields: headerFields,
                queryParameters: queryParameters,
                encodableBody: encodableBody,
                rawBody: rawBody
            )
            let (data, response) = try await urlSession.data(for: urlRequest)
            logIncoming(response, data: data)

            let resp = try jsonDecoder.decode(Resp<T>.self, from: data)
            let msg  = resp.msg
            let code = resp.code

            checkSessionExpiry(code)

            if (code == 200) {
                return NetResp(
                    isSuccess:  true,
                    data:       resp.data,
                    statusCode: code,
                    message:    msg
                )
            } else {
                let errorMsg = resolveMessage(msg)
                return NetResp(
                    isSuccess:  false,
                    data:    nil,
                    statusCode: code,
                    message:    errorMsg
                )
            }
        } catch {
            Logger.log("Error: \(error.localizedDescription)")
            return NetResp(
                isSuccess:  false,
                data:    nil,
                statusCode: 502,
                message:    AllStr.eSu
            )
        }
    }

    // MARK: - 错误消息兜底

    private func resolveMessage(_ msg: String?) -> String {
        if let msg, !msg.isEmpty { return msg }
        return AllStr.eSu
    }

    // MARK: - 会话过期

    /// 特定错误码触发强制登出
    private func checkSessionExpiry(_ code: Int) {
        if code == 701 {
            if AuthHelper.shared.isAuthenticated {
                AuthHelper.shared.clearToken()
                NotificationCenter.default.post(
                    name: NSNotification.Name(NotiName.OverToken),
                    object: nil
                )
            }
        }
    }
    
    // MARK: - 日志

    /// 记录发出的请求
    private func logOutgoing(_ request: URLRequest) {
        var entry = "Request: "
        if let method = request.httpMethod, let url = request.url {
            entry += "\(method) \(url.absoluteString)"
        }
        entry += "\n"

        if let headers = request.allHTTPHeaderFields, !headers.isEmpty {
            entry += "   Headers: \(headers)\n"
        }

        if let body = request.httpBody {
            if let bodyStr = String(data: body, encoding: .utf8) {
                entry += "   Body: \(bodyStr)\n"
            } else {
                entry += "   RawBody: \(body.count) bytes\n"
            }
        }

        Logger.log(entry)
    }

    /// 记录收到的响应
    private func logIncoming(_ response: URLResponse?, data: Data) {
        var entry = "Response: "
        if let httpResponse = response as? HTTPURLResponse, let url = httpResponse.url {
            entry += "\(httpResponse.statusCode) \(url.absoluteString)"
        }
        entry += "\n"

        if let bodyStr = String(data: data, encoding: .utf8), !bodyStr.isEmpty {
            let cap = 2000
            if bodyStr.count > cap {
                entry += "   Body: \(String(bodyStr.prefix(cap)))... (Already Cut)\n"
            } else {
                entry += "   Body: \(bodyStr)\n"
            }
        }

        Logger.log(entry)
    }
}
