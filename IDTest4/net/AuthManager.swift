import Foundation

/// 认证凭据存储（单例）
class AuthManager {
    static let shared = AuthManager()

    private let tokenKey = K.accessTokenK

    private init() {}

    /// 当前缓存的访问令牌
    var accessToken: String? {
        get { UserDefaults.standard.string(forKey: tokenKey) }
        set { UserDefaults.standard.set(newValue, forKey: tokenKey) }
    }

    /// 是否有有效令牌
    var isAuthenticated: Bool {
        guard let token = accessToken, !token.isEmpty else { return false }
        return true
    }

    /// 清除令牌（登出时调用）
    func revokeAccess() {
        accessToken = nil
    }
}
