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

    static func log(_ message: String) {
        #if DEBUG
        logger.debug("\(message)")
        #endif
    }
}
