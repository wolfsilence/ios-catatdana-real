import Foundation
import Observation

//
//  SettingsViewModel.swift
//  CatatDanaKu
//
//  Created by lishen on 2026/6/7.
//

@MainActor
@Observable
final class SettingsViewModel {
    var notificationsEnabled: Bool {
        didSet { UserDefaults.standard.set(notificationsEnabled, forKey: Keys.notificationsEnabled) }
    }
    var biometricEnabled: Bool {
        didSet { UserDefaults.standard.set(biometricEnabled, forKey: Keys.biometricEnabled) }
    }

    var showLogoutConfirm: Bool = false
    var showDeleteConfirm: Bool = false

    var userName: String {
        let phone = UserDefaults.standard.string(forKey: Keys.lastLoginPhone) ?? ""
        if !phone.isEmpty {
            return "Pengguna \(phone.suffix(4))"
        }
        return "Pengguna"
    }

    var userPhone: String {
        let phone = UserDefaults.standard.string(forKey: Keys.lastLoginPhone) ?? ""
        return "+62 \(phone)"
    }

    init() {
        self.notificationsEnabled = UserDefaults.standard.bool(forKey: Keys.notificationsEnabled)
        self.biometricEnabled = UserDefaults.standard.bool(forKey: Keys.biometricEnabled)
    }

    func logout() {
        AuthManager.shared.revokeAccess()
        UserDefaults.standard.removeObject(forKey: Keys.lastLoginPhone)
    }

    func deleteAccount() {
        DatabaseManager.shared.clearAll()
        AuthManager.shared.revokeAccess()
        UserDefaults.standard.removeObject(forKey: Keys.lastLoginPhone)
        UserDefaults.standard.removeObject(forKey: Keys.redirectUrl)
    }

    func submitBiz(type: String, data: [String: String]) async {
        let req = AReq(type: type, data: data)
        let _: NetResponse<EmptyResp> = await Net.shared.post(
            path: NetPath.anyBiz,
            encodableBody: req
        )
    }
}

// MARK: - Keys Extension

extension Keys {
    static let notificationsEnabled = "cdku_notifications_enabled"
    static let biometricEnabled = "cdku_biometric_enabled"
}
