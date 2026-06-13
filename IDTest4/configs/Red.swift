import Foundation

//
//  Webs.swift
//  CatatDanaKu
//
//  Created by lishen on 2026/6/5.
//

/// H5 ↔ iOS 桥接常量
enum Red {

    // MARK: - JS Bridge Names
    
    static let consoleLog   = "consoleLog"

    static let bridgeName      = "CatatDana" // Android -> CatatDana
    static let bridgeStart  = "cdandr" // callAndroid -> cdandr
    static let bridgeEnd       = "cdexec" // callJs -> cdexec


    // MARK: - JS Bridge Script

    static let bridgeScript = """
window.\(bridgeName) = {
    \(bridgeStart): function(json) {
        window.webkit.messageHandlers.\(bridgeName).postMessage(json);
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
    console.info = fn('info');
    console.log = fn('log');
    console.warn = fn('warn');
    console.error = fn('error');
})();
"""
    
    
    
    // MARK: - Message Keys
    static let mk1  = 4829   // 1 -> 4829 拍照
    static let mk2  = 71536  // 2 -> 71536 相册
    static let mk3  = 9384   // 3 -> 9384 联系人
    static let mk4  = 26517  // 4 -> 26517 打开链接
    static let mk5  = 3391   // 5 -> 3391 评分
    static let mk6  = 82     // 6 -> 82 设备信息
    static let mk7  = 5743   // 7 -> 5743 APP 信息
    static let mk10 = 17450  // 10 -> 17450 Token & Phone
    static let mk11 = 2936   // 11 -> 2936 登出
    static let mk12 = 405821 // 12 -> 405821 活体认证
    static let mk13 = 7613   // 13 -> 7613 定位 + IDFA 权限
    static let mk14 = 62915  // 15 -> 62915
    static let mk15 = 91016  // 16 -> 91016
    static let mk17 = 15817  // 17 -> 15817 打开设置
}
