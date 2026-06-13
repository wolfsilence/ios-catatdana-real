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
    static let firstLaunchK = "hasLaunchedBeforeK"

    // MARK: 登录
    static let countdownExpiryK = "com.cdk.login.countdownExpiryK"
    static let countdownMethodK = "com.cdk.login.countdownMethodK"
    static let countdownPhoneK  = "com.cdk.login.countdownPhoneK"
    static let lastLoginPhoneK  = "com.cdk.login.lastPhoneK"

    // MARK: Token
    static let accessTokenK = "com.cdk.accessTokenK"

    // MARK: IDFA
    static let idfaK = "com.cdk.idfaK"
    static let idfaEverRequestK = "com.cdk.idfaEverRequestK"

    // MARK: Attribution
    static let adjustIdK   = "com.cdk.adjustIdK"
    static let adjustDataK = "com.cdk.adjustDataK"
    static let adjustNetworkK   = "com.cdk.adjustNetworkK"
    static let referrerK   = "com.cdk.referrerK"

    static let conversationDataK = "com.cdk.conversationDataK"
    static let afIdK = "com.cdk.afIdK"
    static let afSourceK = "com.cdk.afSourceK"

    // MARK: Location
    static let locationLatK = "com.cdk.location.latK"
    static let locationLngK = "com.cdk.location.lngK"

    // MARK: Redirect URL
    static let sentenceK = "com.cdk.login.sentenceK"

    // MARK: Profile
    private static var phoneSuffixK: String {
        UserDefaults.standard.string(forKey: K.lastLoginPhoneK) ?? "default"
    }
    static var profileNicknameK: String { "com.cdk.profile.nickname.\(phoneSuffixK)K" }
    static var profileAvatarURLK: String { "com.cdk.profile.avatarURL.\(phoneSuffixK)K" }

    // MARK: Keychain Service
    static let keychainServiceK = "com.cdk.keychainK"

    // MARK: Push
    static let pushTokenK = "com.cdk.pushTokenK"
    static let pushDataStrK = "com.cdk.pushDataStrK"
    // MARK: Firebase
    static let appInstanceIDK = "com.cdk.appInstanceIDK"
}
