//
//  CatatDanaKuApp.swift
//  CatatDanaKu
//
//  Created by lishen on 2026/6/3.
//

import SwiftUI
import AdjustSdk
import FirebaseCore
import FirebaseMessaging
import AppsFlyerLib
import FirebaseAnalytics

@main
struct CdApp : App {
    // 🔑 关键：桥接 AppDelegate
     @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            CDRootView()
        }
    }
}


class AppDelegate: UIResponder, UIApplicationDelegate, AdjustDelegate, AppsFlyerLibDelegate{
    
    private var idfaEverRequest = false
    private var appsFlyerSdkReady = false
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        // 监听 CDFirstProtocolView 权限申请完成通知
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(onIDFAPermissionResolved),
            name: Notification.Name(NotiName.RequestedIDFA),
            object: nil
        )
        initAdjust()
        initAppsflyer()
        FirebaseApp.configure()
        saveAppInstanceID()
        // FCM
        PushManager.shared.initSelf()
        
        // 检查是否是由远程推送唤醒的
        if let remoteNotification = launchOptions?[.remoteNotification] as? [String: AnyObject] {
            if let jsonData = try? JSONSerialization.data(withJSONObject: remoteNotification, options: []),
               let json = String(data: jsonData, encoding: .utf8) {
                Logger.log("👉 App launcher by push, push = \(json)")
                UserDefaults.standard.set(json, forKey: K.pushDataStrK)
            }
        }
        return true
    }
    
    // 同步获取 appInstanceID
    private func saveAppInstanceID(){
        guard let instanceId = Analytics.appInstanceID(), !instanceId.isEmpty else {
            return
        }
        KeychainHelper.write(key: K.appInstanceIDK, value: instanceId)
    }
    
    func adjustAttributionChanged(_ attribution: ADJAttribution?) {
        saveAdjustAttr(attribution)
    }
    
    
    private func initAdjust(){
        let adjustConfig = ADJConfig(
            appToken: Consts.adjToken,
            environment: ADJEnvironmentProduction,
            suppressLogLevel: false
        )
        adjustConfig?.logLevel = ADJLogLevel.verbose
        adjustConfig?.enableFirstSessionDelay()
        Adjust.initSdk(adjustConfig)
        Adjust.adid(withTimeout: 30_000) { adid in
            guard let adid, !adid.isEmpty else { return }
            Logger.log("Adjust adid: \(adid)")
            KeychainHelper.write(key: K.adjustIdK, value: adid)
        }
        Adjust.attribution(withTimeout: 30_000) { attribution in
            self.saveAdjustAttr(attribution)
        }
    }
    
    private func saveAdjustAttr(_ attribution: ADJAttribution?){
        guard let attribution else { return }
        // 转为 JSON 并存储
        if let dict = attribution.dictionary(),
           let jsonData = try? JSONSerialization.data(withJSONObject: dict, options: []),
           let json = String(data: jsonData, encoding: .utf8) {
            Logger.log("Adjust attribution: \(json)")
            KeychainHelper.write(key: K.adjustDataK, value: json)
        }
        // network 单独存储
        if let network = attribution.network, !network.isEmpty {
            KeychainHelper.write(key: K.adjustNetworkK, value: network)
        }
    }
    
    /// 供 CDFirstProtocolView 权限申请完成后调用，持久化标记并尝试 start
    @objc func onIDFAPermissionResolved() {
        // af start
        UserDefaults.standard.set(true, forKey: K.idfaEverRequestK)
        idfaEverRequest = true
        appsflyerStartIfReady()
        // adjust
        Adjust.endFirstSessionDelay()
    }

    private func initAppsflyer(){
        // 恢复本地标记：上次启动已申请过权限
        if UserDefaults.standard.bool(forKey: K.idfaEverRequestK) {
            idfaEverRequest = true
        }
        AppsFlyerLib.shared().initialize(devKey: Consts.afDevKey, appId: Consts.appStoreId)
        AppsFlyerLib.shared().registerSessionReadyListener {
            AppsFlyerLib.shared().unregisterSessionReadyListener()
            self.appsFlyerSdkReady = true
            self.appsflyerStartIfReady()
        }
        AppsFlyerLib.shared().delegate = self
//        #if DEBUG
//        AppsFlyerLib.shared().isDebug = true
//        #endif
    }
    
    private func appsflyerStartIfReady() {
        guard idfaEverRequest, appsFlyerSdkReady else { return }
        appsFlyerSdkReady = false
        AppsFlyerLib.shared().start()
        let afId = AppsFlyerLib.shared().getAppsFlyerUID()
        if !afId.isEmpty {
            Logger.log("AppsFlyer id: \(afId)")
            KeychainHelper.write(key: K.afIdK, value: afId)
        }
     }
    
    func onConversionDataSuccess(_ installData: [AnyHashable: Any]) {
        if let jsonData = try? JSONSerialization.data(withJSONObject: installData, options: []),
           let json = String(data: jsonData, encoding: .utf8) {
            Logger.log("AppsFlyer conversion data: \(json)")
            KeychainHelper.write(key: K.conversationDataK, value: json)
            let mediaSource = installData["media_source"] as? String ?? ""
            KeychainHelper.write(key: K.afSourceK, value: mediaSource)
        }
    }

    func onConversionDataFail(_ error: Error) {
        // Invoked when conversion data resolution fails
        Logger.log("AppsFlyer conversion data Fail")
    }
    
    // 3. APNs Token 桥接（仅此一处需要留在 AppDelegate）
    func application(
            _ application: UIApplication,
            didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        // 如果开启了 Swizzling（默认开启），Firebase 会自动拦截此回调
        // 如果关闭了 Swizzling，则必须手动设置：
        // Messaging.messaging().apnsToken = deviceToken
        Logger.log("✅ APNs Device Token: (\(deviceToken.count) bytes)")
    }
        
    func application(
            _ application: UIApplication,
            didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        Logger.log("❌ APNs Register: \(error.localizedDescription)")
    }
}
