import Foundation
//
//  Response.swift
//  CatatDanaKu
//
//  Created by lishen on 2026/6/4.
//

// 通用的响应包装类
struct qxiucygf<T: Decodable>: Decodable {
    let code: Int // code ->
    let msg: String // msg ->
    let data: T? // data ->

    enum CodingKeys: String, CodingKey {
        case code, msg, data
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        code = try container.decode(Int.self, forKey: .code)
        msg = try container.decode(String.self, forKey: .msg)
        
        // 核心容错：尝试正常解码，如果失败（比如遇到了空字符串 ""）则置为 nil
        do {
            data = try container.decode(T.self, forKey: .data)
        } catch {
            Logger.log("⚠️ Exception parsing 'data' field (possibly an empty string or null); automatically downgraded to nil.")
            data = nil
        }
    }
    var scapb: Bool? // scapb ->
    var vsqoal: Bool? // vsqoal ->
    var mnacqo: Bool? // mnacqo ->
    var x: Double? // x ->
    var w: Int64? // w ->
    var j: Int64? // j ->
}
