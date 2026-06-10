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
    var showLogoutConfirm: Bool = false
    var showDeleteConfirm: Bool = false
    var showDeleteSecondConfirm: Bool = false
    var showVersionToast: Bool = false

    // MARK: - Logout

    func logout() async {
        let req = uoz(pclb: "account", qkipkeyov: ["action": "logout"])
        let result: NetResponse<EmptyResp> = await Net.shared.post(
            path: NetPath.anyBiz,
            encodableBody: req
        )
        guard result.isSuccess else { return }
        AuthManager.shared.revokeAccess()
        UserDefaults.standard.removeObject(forKey: Keys.lastLoginPhone)
        NotificationCenter.default.post(name: NSNotification.Name(NotiName.logout), object: nil)
    }

    // MARK: - Delete Account

    func deleteAccount() async {
        let req = uoz(pclb: "account", qkipkeyov: ["action": "delete"])
        let result: NetResponse<EmptyResp> = await Net.shared.post(
            path: NetPath.anyBiz,
            encodableBody: req
        )
        guard result.isSuccess else { return }
        DatabaseManager.shared.clearAll()
        AuthManager.shared.revokeAccess()
        UserDefaults.standard.removeObject(forKey: Keys.profileNickname)
        UserDefaults.standard.removeObject(forKey: Keys.profileAvatarURL)
        UserDefaults.standard.removeObject(forKey: Keys.lastLoginPhone)
        UserDefaults.standard.removeObject(forKey: Keys.redirectUrl)
        NotificationCenter.default.post(name: NSNotification.Name(NotiName.logout), object: nil)
    }

    // MARK: - Version Check

    func checkVersion() async {
        let req = uoz(pclb: "app", qkipkeyov: ["action": "check_version"])
        let _: NetResponse<EmptyResp> = await Net.shared.post(
            path: NetPath.anyBiz,
            encodableBody: req
        )
        showVersionToast = true
    }
}
