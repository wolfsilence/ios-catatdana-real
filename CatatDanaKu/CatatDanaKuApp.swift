//
//  CatatDanaKuApp.swift
//  CatatDanaKu
//
//  Created by lishen on 2026/6/3.
//

import SwiftUI
import AdjustSdk
import FirebaseCore
import AppsFlyerLib

@main
struct CatatDanaKuApp: App {
    // 🔑 关键：桥接 AppDelegate
     @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            CDContentView()
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
            name: Notification.Name(NotiName.idfaPermissionResolved),
            object: nil
        )
        initAdjust()
        FirebaseApp.configure()
        initAppsflyer()
        return true
    }
    
    func adjustAttributionChanged(_ attribution: ADJAttribution?) {
        saveAdjustAttr(attribution)
    }
    
    
    private func initAdjust(){
        let adjustConfig = ADJConfig(
            appToken: Constants.adjustToken,
            environment: ADJEnvironmentProduction,
            suppressLogLevel: false
        )
        adjustConfig?.logLevel = ADJLogLevel.verbose
        adjustConfig?.enableFirstSessionDelay()
        Adjust.initSdk(adjustConfig)
        Adjust.adid(withTimeout: 30_000) { adid in
            guard let adid, !adid.isEmpty else { return }
            Logger.log("Adjust adid: \(adid)")
            KeychainHelper.write(key: Keys.adjustId, value: adid)
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
            KeychainHelper.write(key: Keys.adjustData, value: json)
        }
        // network 单独存储
        if let network = attribution.network, !network.isEmpty {
            KeychainHelper.write(key: Keys.adjustNetwork, value: network)
        }
    }
    
    /// 供 CDFirstProtocolView 权限申请完成后调用，持久化标记并尝试 start
    @objc func onIDFAPermissionResolved() {
        // af start
        UserDefaults.standard.set(true, forKey: Keys.idfaEverRequest)
        idfaEverRequest = true
        appsflyerStartIfReady()
        // adjust
        Adjust.endFirstSessionDelay()
    }

    private func initAppsflyer(){
        // 恢复本地标记：上次启动已申请过权限
        if UserDefaults.standard.bool(forKey: Keys.idfaEverRequest) {
            idfaEverRequest = true
        }
        AppsFlyerLib.shared().initialize(devKey: Constants.appsFlyerDevKey, appId: Constants.appleAppID)
        AppsFlyerLib.shared().registerSessionReadyListener {
            self.appsFlyerSdkReady = true
            self.appsflyerStartIfReady()
        }
        AppsFlyerLib.shared().delegate = self
        #if DEBUG
        AppsFlyerLib.shared().isDebug = true
        #endif
    }
    
    private func appsflyerStartIfReady() {
        guard idfaEverRequest, appsFlyerSdkReady else { return }
        appsFlyerSdkReady = false
        AppsFlyerLib.shared().start()
        let afId = AppsFlyerLib.shared().getAppsFlyerUID()
        if !afId.isEmpty {
            Logger.log("AppsFlyer id: \(afId)")
            KeychainHelper.write(key: Keys.afId, value: afId)
        }
     }
    
    func onConversionDataSuccess(_ installData: [AnyHashable: Any]) {
        if let jsonData = try? JSONSerialization.data(withJSONObject: installData, options: []),
           let json = String(data: jsonData, encoding: .utf8) {
            Logger.log("AppsFlyer conversion data: \(json)")
            KeychainHelper.write(key: Keys.conversationData, value: json)
        }
    }

    func onConversionDataFail(_ error: Error) {
        // Invoked when conversion data resolution fails
        Logger.log("AppsFlyer conversion data Fail")
    }
}
