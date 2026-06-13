//
//  PushNotificationManager.swift
//  CatatDanaKu
//
//  Created by lishen on 2026/6/9.
//


import Foundation
import FirebaseMessaging
import UserNotifications
import UIKit

final class PushNotificationManager: NSObject {
    
    static let shared = PushNotificationManager()
    
    // MARK: - 初始化与配置
    func configure() {
        UNUserNotificationCenter.current().delegate = self
        Messaging.messaging().delegate = self
        requestPermission()
    }
    
    // MARK: - 请求权限
    private func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if let error {
                Logger.log("❌ Permission Failed: \(error.localizedDescription)")
                return
            }
            Logger.log(granted ? "✅ Push Permission Granted" : "⚠️ Push Permission Not Granted")
            
            // 必须在主线程注册远程推送
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }
}

// MARK: - UNUserNotificationCenterDelegate (消息接收)
extension PushNotificationManager: UNUserNotificationCenterDelegate {
    
    /// 前台收到消息
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        let userInfo = notification.request.content.userInfo
        Logger.log("📩 Front Receive Push: \(userInfo)")
        completionHandler([.banner, .sound, .badge])
    }
    
    /// 用户点击通知 / 后台消息响应
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        Logger.log("👆 Backend or Click Push: \(userInfo)")
        // 将推送数据转 JSON 存本地，通知 JS 处理
        if let jsonData = try? JSONSerialization.data(withJSONObject: userInfo, options: []),
           let jsonStr = String(data: jsonData, encoding: .utf8) {
            UserDefaults.standard.set(jsonStr, forKey: K.pushDataStr)
            NotificationCenter.default.post(name: NSNotification.Name(NotiName.ReceivedPush), object: nil)
        }
        completionHandler()
    }
}

// MARK: - MessagingDelegate (FCM Token)
extension PushNotificationManager: MessagingDelegate {
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let token = fcmToken else { return }
        Logger.log("✅ FCM Token refresh: \(token)")
        UserDefaults.standard.set(token, forKey: K.pushToken)
    }
}
