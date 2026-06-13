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

    static let CatatDana      = "CatatDana" // Android -> CatatDana
    static let cdandr  = "cdandr" // callAndroid -> cdandr
    static let cdexec       = "cdexec" // callJs -> cdexec
    static let consoleLog   = "consoleLog"

    // MARK: - Message Keys
    static let k4829  = 4829   // 1 -> 4829 拍照
    static let k71536  = 71536  // 2 -> 71536 相册
    static let k9384  = 9384   // 3 -> 9384 联系人
    static let k26517  = 26517  // 4 -> 26517 打开链接
    static let k3391  = 3391   // 5 -> 3391 评分
    static let k82  = 82     // 6 -> 82 设备信息
    static let k5743  = 5743   // 7 -> 5743 APP 信息
    static let k17450 = 17450  // 10 -> 17450 Token & Phone
    static let k2936 = 2936   // 11 -> 2936 登出
    static let k405821 = 405821 // 12 -> 405821 活体认证
    static let k7613 = 7613   // 13 -> 7613 定位 + IDFA 权限
    static let k62915 = 62915  // 15 -> 62915
    static let k91016 = 91016  // 16 -> 91016
    static let k15817 = 15817  // 17 -> 15817 打开设置

    // MARK: - JS Bridge Script

    static let bridgeScript = """
window.\(CatatDana) = {
    \(cdandr): function(json) {
        window.webkit.messageHandlers.\(CatatDana).postMessage(json);
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
