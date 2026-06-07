import Foundation

//
//  CreditCard.swift
//  CatatDanaKu
//
//  Created by lishen on 2026/6/7.
//

struct CreditCard: Codable, Identifiable {
    var id: String = UUID().uuidString
    var number: String          // 卡号（掩码后的格式: 4532 •••• •••• 1234）
    var rawNumber: String = ""  // 原始卡号（仅用于新增时传输）
    var bank: String
    var paymentDate: Int        // 每月还款日 (1-31)
    var photoPath: String = ""
    var colorHex: String = ""
    var createdAt: Date = Date()

    /// 卡片渐变色
    var gradientColors: [String] {
        CreditCard.bankColors[bank] ?? CreditCard.bankColors["Default"] ?? ["#374151", "#6B7280"]
    }

    /// 银行预设颜色
    static let bankColors: [String: [String]] = [
        "BCA":      ["#003f8a", "#0065cc"],
        "BRI":      ["#003087", "#1e4db7"],
        "Mandiri":  ["#002855", "#004aad"],
        "BNI":      ["#e95c0b", "#f47421"],
        "CIMB":     ["#be0000", "#e60000"],
        "Default":  ["#374151", "#6B7280"],
    ]

    /// 银行列表
    static let bankList = ["BCA", "BRI", "Mandiri", "BNI", "CIMB"]
}
