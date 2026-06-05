import Foundation
import OSLog

//
//  Logger.swift
//  CatatDanaKu
//
//  Created by lishen on 2026/6/3.
//

class Logger{
    private static let logger = os.Logger(subsystem: "com.catatdanaku.ios", category: "general")

    static func log(_ message: String?) {
        // ✅ 空值或空字符串直接返回，不执行任何打印
        guard let message, !message.isEmpty else { return }
        
        #if DEBUG
        logger.debug("\(message)")
        #endif
    }
}
