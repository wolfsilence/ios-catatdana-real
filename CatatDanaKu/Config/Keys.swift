import Foundation

//
//  Keys.swift
//  CatatDanaKu
//
//  Created by lishen on 2026/6/4.
//

/// UserDefaults / Keychain 存储键
class Keys {
    // MARK: 通用
    static let firstLaunch = "hasLaunchedBefore"

    // MARK: 登录
    static let countdownExpiry = "com.catatdanaku.login.countdownExpiry"
    static let countdownMethod = "com.catatdanaku.login.countdownMethod"
    static let countdownPhone  = "com.catatdanaku.login.countdownPhone"
    static let lastLoginPhone  = "com.catatdanaku.login.lastPhone"

    // MARK: Token
    static let accessToken = "com.catatdanaku.access-token"

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

    // MARK: Location
    static let locationLat = "com.catatdanaku.location.lat"
    static let locationLng = "com.catatdanaku.location.lng"

    // MARK: Redirect URL
    static let redirectUrl = "com.catatdanaku.login.redirectUrl"

    // MARK: Profile
    static let profileNickname  = "com.catatdanaku.profile.nickname"
    static let profileAvatarURL = "com.catatdanaku.profile.avatarURL"

    // MARK: Keychain Service
    static let keychainService = "com.catatdanaku.keychain"
    
    // MARK: Push
    static let pushToken = "com.catatdanaku.pushToken"
    static let pushDataStr = "com.catatdanaku.pushDataStr"
}
