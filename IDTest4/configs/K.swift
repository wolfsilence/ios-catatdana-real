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
    static let countdownExpiry = "com.cdk.login.countdownExpiry"
    static let countdownMethod = "com.cdk.login.countdownMethod"
    static let countdownPhone  = "com.cdk.login.countdownPhone"
    static let lastLoginPhone  = "com.cdk.login.lastPhone"

    // MARK: Token
    static let accessToken = "com.cdk.accessToken"

    // MARK: IDFA
    static let idfa = "com.cdk.idfa"
    static let idfaEverRequest = "com.cdk.idfaEverRequest"

    // MARK: Attribution
    static let adjustId   = "com.cdk.adjustId"
    static let adjustData = "com.cdk.adjustData"
    static let adjustNetwork   = "com.cdk.adjustNetwork"
    static let referrer   = "com.cdk.referrer"
    
    static let conversationData = "com.cdk.conversationData"
    static let afId = "com.cdk.afId"
    static let afSource = "com.cdk.afSource"

    // MARK: Location
    static let locationLat = "com.cdk.location.lat"
    static let locationLng = "com.cdk.location.lng"

    // MARK: Redirect URL
    static let sentence = "com.cdk.login.sentence"

    // MARK: Profile
    private static var phoneSuffix: String {
        UserDefaults.standard.string(forKey: K.lastLoginPhone) ?? "default"
    }
    static var profileNickname: String { "com.cdk.profile.nickname.\(phoneSuffix)" }
    static var profileAvatarURL: String { "com.cdk.profile.avatarURL.\(phoneSuffix)" }

    // MARK: Keychain Service
    static let keychainService = "com.cdk.keychain"
    
    // MARK: Push
    static let pushToken = "com.cdk.pushToken"
    static let pushDataStr = "com.cdk.pushDataStr"
    // MARK: Firebase
    static let appInstanceID = "com.cdk.appInstanceID"
}
