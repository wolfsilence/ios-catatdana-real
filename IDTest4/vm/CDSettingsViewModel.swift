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
final class CDSettingsViewModel {
    var showLogoutConfirm: Bool = false
    var showDeleteConfirm: Bool = false
    var showDeleteSecondConfirm: Bool = false
    var showVersionToast: Bool = false

    // MARK: - Logout

    func logout() async {
        let req = Entity20(pclb: "account", qkipkeyov: ["action": "logout"])
        let result: NetResp<EmptyResp> = await Net.shared.post(
            path: Paths.halkm,
            encodableBody: req
        )
        guard result.isSuccess else { return }
        AuthHelper.shared.clearToken()
        UserDefaults.standard.removeObject(forKey: K.lastLoginPhoneK)
        UserDefaults.standard.removeObject(forKey: K.sentenceK)
        NotificationCenter.default.post(name: NSNotification.Name(NotiName.Logout), object: nil)
    }

    // MARK: - Delete Account

    func deleteAccount() async {
        let req = Entity20(pclb: "account", qkipkeyov: ["action": "delete"])
        let result: NetResp<EmptyResp> = await Net.shared.post(
            path: Paths.halkm,
            encodableBody: req
        )
        guard result.isSuccess else { return }
        DatabaseHelper.shared.clearAll()
        AuthHelper.shared.clearToken()
        UserDefaults.standard.removeObject(forKey: K.profileNicknameK)
        UserDefaults.standard.removeObject(forKey: K.profileAvatarURLK)
        UserDefaults.standard.removeObject(forKey: K.lastLoginPhoneK)
        UserDefaults.standard.removeObject(forKey: K.sentenceK)
        NotificationCenter.default.post(name: NSNotification.Name(NotiName.Logout), object: nil)
    }

    // MARK: - Version Check

    func checkVersion() async {
        let req = Entity20(pclb: "app", qkipkeyov: ["action": "check_version"])
        let _: NetResp<EmptyResp> = await Net.shared.post(
            path: Paths.halkm,
            encodableBody: req
        )
        showVersionToast = true
    }
}
