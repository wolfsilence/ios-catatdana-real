import Foundation
import AdSupport
import AppTrackingTransparency

//
//  IDFAProvider.swift
//  CatatDanaKu
//
//  Created by lishen on 2026/6/4.
//

/// IDFA 获取工具 —— 优先取 Keychain 缓存，无授权时返回全零 UUID（不存 Keychain）
enum IDFAProvider {

    private static let keychainKey = K.idfa

    /// 全零 UUID（未授权兜底）
    static let zeroUUID = "00000000-0000-0000-0000-000000000000"

    /// 请求 ATT 授权（弹出系统弹窗），completion 在授权结果返回后调用
    static func requestPermission(completion: (() -> Void)? = nil) {
        ATTrackingManager.requestTrackingAuthorization { status in
            if status == .authorized {
                let idfa = ASIdentifierManager.shared().advertisingIdentifier.uuidString
                if idfa != zeroUUID, !idfa.isEmpty {
                    KeychainHelper.write(key: keychainKey, value: idfa)
                }
            }
            completion?()
        }
    }

    /// 获取 IDFA：
    /// 1. 优先从 Keychain 读取已缓存的 IDFA
    /// 2. Keychain 无值 → 检查 ATT 授权状态
    ///    - 已授权 → 获取系统 IDFA → 写入 Keychain → 返回
    ///    - 未授权/未决定 → 返回全零 UUID（不存 Keychain）
    static func idfa() -> String {
        // 优先取 Keychain 缓存
        if let cached = KeychainHelper.read(key: keychainKey), !cached.isEmpty {
            return cached
        }

        // 检查 ATT 授权状态
        let status = ATTrackingManager.trackingAuthorizationStatus
        guard status == .authorized else {
            return zeroUUID
        }

        let idfa = ASIdentifierManager.shared().advertisingIdentifier.uuidString

        // 如果是全零也不存
        guard idfa != zeroUUID, !idfa.isEmpty else {
            return zeroUUID
        }

        KeychainHelper.write(key: keychainKey, value: idfa)
        return idfa
    }
}
