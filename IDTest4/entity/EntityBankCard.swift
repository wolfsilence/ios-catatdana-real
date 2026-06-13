import Foundation

//
//  CreditCard.swift
//  CatatDanaKu
//
//  Created by lishen on 2026/6/7.
//

struct EntityBankCard: Codable, Identifiable {
    var id: String = UUID().uuidString
    var no: String          // 卡号（掩码后的格式: 4532 •••• •••• 1234）
    var rawNo: String = ""  // 原始卡号（仅用于新增时传输）
    var bankName: String
    var repayDate: Int        // 每月还款日 (1-31)
    var imagePath: String = ""
    var bgColor: String = ""
    var createDate: Date = Date()

    /// 卡片渐变色
    var bgGradientColors: [String] {
        EntityBankCard.bankBgColors[bankName] ?? EntityBankCard.bankBgColors["Default"] ?? ["#374151", "#6B7280"]
    }
    
    /// 银行列表
    static let bankList = ["BCA", "BRI",  "BNI",  "BTN", "Mandiri","CIMB", "Danamon", "BSI"]

    /// 银行预设颜色
    static let bankBgColors: [String: [String]] = [
        "Default":  ["#374151", "#6B7280"],
        "BCA":      ["#003f8a", "#0065cc"],
        "BRI":      ["#003087", "#1e4db7"],
        "BSI":     ["#002855", "#004aad"],
        "BNI":      ["#e95c0b", "#f47421"],
        "CIMB":     ["#be0000", "#e60000"],
        "BTN":     ["#003f8a", "#0065cc"],
        "Danamon":  ["#002855", "#004aad"],
        "Mandiri":  ["#002855", "#004aad"],
    ]


}
