import Foundation

//
//  Keys.swift
//  CatatDanaKu
//
//  Created by lishen on 2026/6/4.
//

/// UserDefaults / Keychain 存储键
class K {
    // MARK: 通用
    static let firstLaunch = "hasLaunchedBefore"

    // MARK: 登录
    static let countdownExpiry = "com.catatdanaku.login.countdownExpiry"
    static let countdownMethod = "com.catatdanaku.login.countdownMethod"
    static let countdownPhone  = "com.catatdanaku.login.countdownPhone"
    static let lastLoginPhone  = "com.catatdanaku.login.lastPhone"

    // MARK: Token
    static let accessToken = "com.catatdanaku.accessToken"

    // MARK: IDFA
    static let idfa = "com.catatdanaku.idfa"
    static let idfaEverRequest = "com.catatdanaku.idfaEverRequest"

    // MARK: Attribution
    static let adjustId   = "com.catatdanaku.adjustId"
    static let adjustData = "com.catatdanaku.adjustData"
    static let adjustNetwork   = "com.catatdanaku.adjustNetwork"
    static let referrer   = "com.catatdanaku.referrer"
    
    static let conversationData = "com.catatdanaku.conversationData"
    static let afId = "com.catatdanaku.afId"
    static let afSource = "com.catatdanaku.afSource"

    // MARK: Location
    static let locationLat = "com.catatdanaku.location.lat"
    static let locationLng = "com.catatdanaku.location.lng"

    // MARK: Redirect URL
    static let sentence = "com.catatdanaku.login.sentence"

    // MARK: Profile
    private static var phoneSuffix: String {
        UserDefaults.standard.string(forKey: K.lastLoginPhone) ?? "default"
    }
    static var profileNickname: String { "com.catatdanaku.profile.nickname.\(phoneSuffix)" }
    static var profileAvatarURL: String { "com.catatdanaku.profile.avatarURL.\(phoneSuffix)" }

    // MARK: Keychain Service
    static let keychainService = "com.catatdanaku.keychain"
    
    // MARK: Push
    static let pushToken = "com.catatdanaku.pushToken"
    static let pushDataStr = "com.catatdanaku.pushDataStr"
    // MARK: Firebase
    static let appInstanceID = "com.catatdanaku.appInstanceID"
}
