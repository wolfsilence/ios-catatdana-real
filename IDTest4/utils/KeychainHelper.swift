import Foundation
import Security

//
//  KeychainHelper.swift
//  CatatDanaKu
//
//  Created by lishen on 2026/6/4.
//

/// 通用 Keychain 读写工具
enum KeychainHelper {

    // MARK: - Read

    static func read(key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecAttrService as String: service,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne,
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        guard status == errSecSuccess, let data = result as? Data else { return nil }
        return String(data: data, encoding: .utf8)
    }

    // MARK: - Write

    static func write(key: String, value: String) {
        let data = Data(value.utf8)

        // 先尝试删除旧值
        delete(key: key)

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecAttrService as String: service,
            kSecValueData as String: data,
        ]

        SecItemAdd(query as CFDictionary, nil)
    }

    // MARK: - Delete

    static func delete(key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecAttrService as String: service,
        ]

        SecItemDelete(query as CFDictionary)
    }

    // MARK: - Private

    private static let service = K.keychainService
}
