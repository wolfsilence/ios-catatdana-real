import Foundation

//
//  DeviceInfoManager.swift
//  CatatDanaKu
//
//  Created by lishen on 2026/6/5.
//

/// 设备信息管理（单例），负责采集并上传设备指纹等信息
final class DeviceInfoManager {
    static let shared = DeviceInfoManager()

    private init() {}

    /// 上传设备信息，完成后回调 value（供 JSMessageHandler respond 用）
    func upload(completion: @escaping (String) -> Void) {
        // TODO: 实现设备信息采集 + 上传
        completion("1")
    }
}
