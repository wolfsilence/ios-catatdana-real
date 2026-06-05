import Foundation

//
//  Webs.swift
//  CatatDanaKu
//
//  Created by lishen on 2026/6/5.
//

/// H5 ↔ iOS 桥接常量
enum Webs {

    // MARK: - JS Bridge Names

    static let android      = "Android"
    static let callAndroid  = "callAndroid"
    static let callJs       = "callJs"
    static let consoleLog   = "consoleLog"

    // MARK: - Message Keys
    static let key1  = 1   // 拍照
    static let key2  = 2   // 相册
    static let key3  = 3   // 联系人
    static let key4  = 4   // 打开链接
    static let key5  = 5   // 评分
    static let key6  = 6   // 设备信息
    static let key7  = 7   // APP 信息
    static let key10 = 10  // Token & Phone
    static let key11 = 11  // 登出
    static let key12 = 12  // 活体认证
    static let key13 = 13  // 定位 + IDFA 权限

    // MARK: - JS Bridge Script

    static let bridgeScript = """
window.\(android) = {
    \(callAndroid): function(json) {
        window.webkit.messageHandlers.\(android).postMessage(json);
    }
};
(function() {
    var con = window.webkit.messageHandlers.\(consoleLog);
    var fn = function(level) {
        return function() {
            var args = Array.prototype.slice.call(arguments);
            var msg = args.map(function(a) {
                try { return typeof a === 'object' ? JSON.stringify(a) : String(a); } catch(e) { return String(a); }
            }).join(' ');
            con.postMessage({level: level, message: msg});
        };
    };
    console.log = fn('log');
    console.warn = fn('warn');
    console.error = fn('error');
    console.info = fn('info');
})();
"""
}
