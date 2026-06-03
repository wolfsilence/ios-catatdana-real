import Foundation

/// 网络请求执行引擎（单例）
/// 负责 URLSession 管理、请求构建、加解密、日志追踪、会话过期处理
class HttpPerformer {
    static let shared = HttpPerformer()

    // MARK: - 内部错误

    private enum PerformerError: Error {
        case malformedURL
        case invalidPayload
    }

    // MARK: - 私有属性

    private let urlSession: URLSession
    private let jsonDecoder: JSONDecoder
    private let jsonEncoder: JSONEncoder

    // MARK: - 初始化

    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest  = GatewayConfig.timeoutInterval
        config.timeoutIntervalForResource = GatewayConfig.timeoutInterval
        config.httpAdditionalHeaders = [
            "Accept": "*/*",
        ]
        self.urlSession  = URLSession(configuration: config)
        self.jsonDecoder = JSONDecoder()
        self.jsonEncoder = JSONEncoder()
    }

    // MARK: - 请求构建

    /// 根据 RequestBlueprint 组装 URLRequest
    private func composeURLRequest(blueprint: RequestBlueprint) throws -> URLRequest {
        guard let url = blueprint.fullURL else {
            throw PerformerError.malformedURL
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod       = blueprint.verb.rawValue
        urlRequest.timeoutInterval  = GatewayConfig.timeoutInterval

        // 写入请求头
        for (key, value) in blueprint.headerFields {
            urlRequest.setValue(value, forHTTPHeaderField: key)
        }

        // 认证令牌
        if let token = AuthCredentialStore.shared.accessToken {
            urlRequest.setValue(token, forHTTPHeaderField: "x-auth-pin")
        }

        // 客户端版本（加密模式下附带）
        if GatewayConfig.useEncryption,
           let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            urlRequest.setValue(appVersion, forHTTPHeaderField: "x-client-ver")
        }

        // 处理请求体
        let contentType = blueprint.headerFields["Content-Type"] ?? ""
        let isEncryptedJsonPost = blueprint.verb == .post && contentType.contains("application/json")

        if isEncryptedJsonPost && GatewayConfig.useEncryption {
            // 加密模式：模型 → JSON 字符串 → 加密 → 放入 body
            guard let model = blueprint.encodableBody else {
                throw PerformerError.invalidPayload
            }
            let jsonData = try jsonEncoder.encode(model)
            guard let bodyString = String(data: jsonData, encoding: .utf8) else {
                throw PerformerError.invalidPayload
            }
            LogWriter.trace("📤 请求明文: \(bodyString)")
            let encrypted = try CryptoBox.shared.seal(plainText: bodyString)
            urlRequest.httpBody = encrypted.data(using: .utf8)
        } else {
            // 普通模式：优先使用 rawBody，其次 JSON 编码 encodableBody
            if let rawBody = blueprint.rawBody {
                urlRequest.httpBody = rawBody
            } else if let model = blueprint.encodableBody, blueprint.verb != .get {
                urlRequest.httpBody = try jsonEncoder.encode(model)
            }
        }

        traceOutgoing(urlRequest)
        return urlRequest
    }

    // MARK: - 日志

    /// 记录发出的请求
    private func traceOutgoing(_ request: URLRequest) {
        var entry = "\n📤 请求: "
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
                entry += "   Body: \(body.count) 字节\n"
            }
        }

        LogWriter.trace(entry)
    }

    /// 记录收到的响应
    private func traceIncoming(_ response: URLResponse?, data: Data) {
        var entry = "📥 响应: "
        if let httpResponse = response as? HTTPURLResponse, let url = httpResponse.url {
            entry += "\(httpResponse.statusCode) \(url.absoluteString)"
        }
        entry += "\n"

        if let bodyStr = String(data: data, encoding: .utf8), !bodyStr.isEmpty {
            let cap = 2000
            if bodyStr.count > cap {
                entry += "   Body: \(String(bodyStr.prefix(cap)))... (已截断)\n"
            } else {
                entry += "   Body: \(bodyStr)\n"
            }
        }

        LogWriter.trace(entry)
    }

    // MARK: - 错误消息兜底

    private func resolveMessage(_ msg: String?) -> String {
        if let msg, !msg.isEmpty { return msg }
        return LocalizedText.Error.generalFailure
    }

    // MARK: - 会话过期

    /// 特定错误码触发强制登出
    private func checkSessionExpiry(_ code: Int) {
        if code == 401 {
            if AuthCredentialStore.shared.isAuthenticated {
                AuthCredentialStore.shared.revokeAccess()
                NotificationCenter.default.post(
                    name: NSNotification.Name("SessionTerminated"),
                    object: nil
                )
            }
        }
    }

    // MARK: - 公开方法

    /// 执行一次网络请求
    func execute<T: Codable>(blueprint: RequestBlueprint) async -> ServiceResponse<T> {
        do {
            let urlRequest = try composeURLRequest(blueprint: blueprint)
            let (data, response) = try await urlSession.data(for: urlRequest)
            traceIncoming(response, data: data)

            let envelope = try jsonDecoder.decode(ApiEnvelope<T>.self, from: data)
            let code = envelope.httpCode ?? -1
            let msg  = envelope.serverMessage

            checkSessionExpiry(code)

            if (200...299).contains(code) {
                return ServiceResponse(
                    isSuccess:  true,
                    payload:    envelope.content,
                    statusCode: code,
                    message:    msg
                )
            } else {
                let errorMsg = resolveMessage(msg)
                return ServiceResponse(
                    isSuccess:  false,
                    payload:    nil,
                    statusCode: code,
                    message:    errorMsg
                )
            }
        } catch {
            return ServiceResponse(
                isSuccess:  false,
                payload:    nil,
                statusCode: -1,
                message:    LocalizedText.Error.generalFailure
            )
        }
    }
}
