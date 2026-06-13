import Foundation
import CommonCrypto

//
//  CryBox.swift
//  CatatDanaKu
//
//  Created by lishen on 2026/6/3.
//

class CdBox {

    // MARK: - 密钥 & 初始向量

    private static var aesKey: Data {
        "2857461309987612".data(using: .utf8)!
    }

    private static var aesIV: Data {
        "7391564820012345".data(using: .utf8)!
    }

    // MARK: - 核心加解密

    private static func aesCrypto(_ operation: CCOperation, data: Data) throws -> Data {
        let outLength = data.count + kCCBlockSizeAES128
        var outData = Data(count: outLength)
        var numBytes: size_t = 0

        let status = outData.withUnsafeMutableBytes { outPtr in
            data.withUnsafeBytes { dataPtr in
                aesIV.withUnsafeBytes { ivPtr in
                    aesKey.withUnsafeBytes { keyPtr in
                        CCCrypt(
                            operation,
                            CCAlgorithm(kCCAlgorithmAES),
                            CCOptions(kCCOptionPKCS7Padding),
                            keyPtr.baseAddress,
                            kCCKeySizeAES128,
                            ivPtr.baseAddress,
                            dataPtr.baseAddress,
                            data.count,
                            outPtr.baseAddress,
                            outLength,
                            &numBytes
                        )
                    }
                }
            }
        }

        guard status == kCCSuccess else {
            throw AppErrors.Encrypt
        }

        outData.removeSubrange(numBytes..<outLength)
        return outData
    }

    // MARK: - 对外方法

    /// 加密：明文字符串 → AES-CBC 加密 → Base64 密文
    static func stA(real: String?) throws -> String {
        guard let real else {
            throw AppErrors.Encrypt
        }
        guard let inputData = real.data(using: .utf8) else {
            throw AppErrors.Encrypt
        }
        let encrypted = try aesCrypto(CCOperation(kCCEncrypt), data: inputData)
        return encrypted.base64EncodedString()
    }

    /// 解密：Base64 密文 → AES-CBC 解密 → 明文字符串
    static func atS(encrypted: String?) throws -> String {
        guard let encrypted else {
            throw AppErrors.Encrypt
        }
        guard let cipherData = Data(base64Encoded: encrypted) else {
            throw AppErrors.Encrypt
        }
        let decrypted = try aesCrypto(CCOperation(kCCDecrypt), data: cipherData)
        guard let result = String(data: decrypted, encoding: .utf8) else {
            throw AppErrors.Encrypt
        }
        return result
    }
}
