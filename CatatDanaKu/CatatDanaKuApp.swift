//
//  CatatDanaKuApp.swift
//  CatatDanaKu
//
//  Created by lishen on 2026/6/3.
//

import SwiftUI
import AdjustSdk

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


class AppDelegate: NSObject, UIApplicationDelegate, AdjustDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        initAdjust()
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
}
