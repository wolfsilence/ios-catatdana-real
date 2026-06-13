import Foundation

//
//  Transaction.swift
//  CatatDanaKu
//
//  Created by lishen on 2026/6/7.
//

struct Transaction: Codable, Identifiable {
    var id: String = UUID().uuidString
    var type: TransactionType
    var amount: Double
    var category: String
    var location: String = ""
    var note: String = ""
    var photoPath: String = ""
    var date: Date = Date()
}

enum TransactionType: String, Codable, CaseIterable {
    case expense = "expense"
    case income = "income"
}

// MARK: - Category

struct TransactionCategory: Identifiable {
    let id: String
    let label: String
    let icon: String

    static let expenseCategories: [TransactionCategory] = [
        .init(id: "food",           label: AllStr.ctFo,           icon: "🍔"),
        .init(id: "groceries",      label: AllStr.ctGr,      icon: "🛒"),
        .init(id: "transport",      label: AllStr.ctTr,      icon: "🚗"),
        .init(id: "housing",        label: AllStr.ctHo,        icon: "🏠"),
        .init(id: "communication",  label: AllStr.ctCo,  icon: "📱"),
        .init(id: "utilities",      label: AllStr.ctUt,      icon: "⚡"),
        .init(id: "shopping",       label: AllStr.ctSh,       icon: "🛍️"),
        .init(id: "health",         label: AllStr.ctHe,         icon: "🏥"),
        .init(id: "insurance",      label: AllStr.ctIn,      icon: "🛡️"),
        .init(id: "family",         label: AllStr.ctFa,         icon: "👶"),
        .init(id: "education",      label: AllStr.ctEd,      icon: "📚"),
        .init(id: "entertainment",  label: AllStr.ctEn,  icon: "🎬"),
        .init(id: "travel",         label: AllStr.ctTv,         icon: "✈️"),
        .init(id: "subscriptions",  label: AllStr.ctSu,  icon: "💳"),
        .init(id: "personalCare",   label: AllStr.ctPc,   icon: "💇‍♀️"),
        .init(id: "pets",           label: AllStr.ctPe,           icon: "🐾"),
        .init(id: "gifts",          label: AllStr.ctGi,          icon: "🎁"),
        .init(id: "other_expense",  label: AllStr.ctOe,   icon: "📦"),
    ]

    static let incomeCategories: [TransactionCategory] = [
        .init(id: "salary",         label: AllStr.ctSa,         icon: "💼"),
        .init(id: "investment",     label: AllStr.ctIv,     icon: "📈"),
        .init(id: "rental",         label: AllStr.ctRe,         icon: "🏠"),
        .init(id: "prize",          label: AllStr.ctPr,          icon: "🎁"),
        .init(id: "project",        label: AllStr.ctPj,        icon: "📋"),
        .init(id: "business",       label: AllStr.ctBu,       icon: "🏪"),
        .init(id: "sale",           label: AllStr.ctSl,           icon: "🏷️"),
        .init(id: "gift",           label: AllStr.ctGf,           icon: "🎊"),
        .init(id: "other_income",   label: AllStr.ctOi,    icon: "📦"),
    ]

    /// 根据交易类型返回对应分类列表
    static func categories(for type: TransactionType) -> [TransactionCategory] {
        type == .expense ? expenseCategories : incomeCategories
    }

    /// 所有分类（用于财务分析等聚合场景）
    static var all: [TransactionCategory] {
        expenseCategories + incomeCategories
    }
}
