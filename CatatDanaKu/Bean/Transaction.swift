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
        .init(id: "food",           label: Strings.Category.food,           icon: "🍔"),
        .init(id: "transport",      label: Strings.Category.transport,      icon: "🚗"),
        .init(id: "shopping",       label: Strings.Category.shopping,       icon: "🛍️"),
        .init(id: "health",         label: Strings.Category.health,         icon: "🏥"),
        .init(id: "entertainment",  label: Strings.Category.entertainment,  icon: "🎬"),
        .init(id: "education",      label: Strings.Category.education,      icon: "📚"),
        .init(id: "utilities",      label: Strings.Category.utilities,      icon: "⚡"),
        .init(id: "other_expense",  label: Strings.Category.otherExpense,   icon: "📦"),
    ]

    static let incomeCategories: [TransactionCategory] = [
        .init(id: "salary",         label: Strings.Category.salary,         icon: "💼"),
        .init(id: "investment",     label: Strings.Category.investment,     icon: "📈"),
        .init(id: "rental",         label: Strings.Category.rental,         icon: "🏠"),
        .init(id: "prize",          label: Strings.Category.prize,          icon: "🎁"),
        .init(id: "project",        label: Strings.Category.project,        icon: "📋"),
        .init(id: "business",       label: Strings.Category.business,       icon: "🏪"),
        .init(id: "sale",           label: Strings.Category.sale,           icon: "🏷️"),
        .init(id: "gift",           label: Strings.Category.gift,           icon: "🎊"),
        .init(id: "other_income",   label: Strings.Category.otherIncome,    icon: "📦"),
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
