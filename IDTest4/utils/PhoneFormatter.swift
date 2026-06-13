import Foundation

//
//  PhoneFormatter.swift
//  CatatDanaKu
//
//  Created by lishen on 2026/6/4.
//

/// 手机号格式化工具 —— 印尼手机号规则：8开头，9-13位数字
enum PhoneFormatter {

    /// 从原始输入提取合法手机号（8开头，去除非数字，截取9-13位）
    /// 返回 nil 表示格式不合法
    static func extract(_ raw: String) -> String? {
        let digits = raw.filter { $0.isNumber }
        guard let eightIndex = digits.firstIndex(of: "8") else { return nil }
        let afterEight = String(digits[eightIndex...])
        guard afterEight.count >= Consts.phoneMinDigits,
              afterEight.count <= Consts.phoneMaxDigits else { return nil }
        return afterEight
    }

    /// 判断手机号是否合法
    static func isValid(_ raw: String) -> Bool {
        extract(raw) != nil
    }

    /// 格式化后的手机号（用于提交和存储）
    static func formatted(_ raw: String) -> String {
        extract(raw) ?? raw
    }
}
