import Foundation
import CryptoKit

/// 请求体加解密工具（单例）
class CryptoBox {
    static let shared = CryptoBox()

    private let cipherKey: SymmetricKey

    private init() {
        // 生产环境应从安全存储中派生此密钥
        let rawKey = "01234567890123456789012345678901" // 32 字节 → AES-256
        cipherKey = SymmetricKey(data: rawKey.data(using: .utf8)!)
    }

    /// 对明文字符串执行 AES-GCM 加密，返回 Base64 密文
    func seal(plainText: String) throws -> String {
        guard let inputData = plainText.data(using: .utf8) else {
            throw CryptoError.encodeFailure
        }
        let sealedBox = try AES.GCM.seal(inputData, using: cipherKey)
        guard let combined = sealedBox.combined else {
            throw CryptoError.sealFailure
        }
        return combined.base64EncodedString()
    }

    enum CryptoError: Error {
        case encodeFailure
        case sealFailure
    }
}
