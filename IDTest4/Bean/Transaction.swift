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
        .init(id: "food",           label: AllStr.Category.food,           icon: "🍔"),
        .init(id: "groceries",      label: AllStr.Category.groceries,      icon: "🛒"),
        .init(id: "transport",      label: AllStr.Category.transport,      icon: "🚗"),
        .init(id: "housing",        label: AllStr.Category.housing,        icon: "🏠"),
        .init(id: "communication",  label: AllStr.Category.communication,  icon: "📱"),
        .init(id: "utilities",      label: AllStr.Category.utilities,      icon: "⚡"),
        .init(id: "shopping",       label: AllStr.Category.shopping,       icon: "🛍️"),
        .init(id: "health",         label: AllStr.Category.health,         icon: "🏥"),
        .init(id: "insurance",      label: AllStr.Category.insurance,      icon: "🛡️"),
        .init(id: "family",         label: AllStr.Category.family,         icon: "👶"),
        .init(id: "education",      label: AllStr.Category.education,      icon: "📚"),
        .init(id: "entertainment",  label: AllStr.Category.entertainment,  icon: "🎬"),
        .init(id: "travel",         label: AllStr.Category.travel,         icon: "✈️"),
        .init(id: "subscriptions",  label: AllStr.Category.subscriptions,  icon: "💳"),
        .init(id: "personalCare",   label: AllStr.Category.personalCare,   icon: "💇‍♀️"),
        .init(id: "pets",           label: AllStr.Category.pets,           icon: "🐾"),
        .init(id: "gifts",          label: AllStr.Category.gifts,          icon: "🎁"),
        .init(id: "other_expense",  label: AllStr.Category.otherExpense,   icon: "📦"),
    ]

    static let incomeCategories: [TransactionCategory] = [
        .init(id: "salary",         label: AllStr.Category.salary,         icon: "💼"),
        .init(id: "investment",     label: AllStr.Category.investment,     icon: "📈"),
        .init(id: "rental",         label: AllStr.Category.rental,         icon: "🏠"),
        .init(id: "prize",          label: AllStr.Category.prize,          icon: "🎁"),
        .init(id: "project",        label: AllStr.Category.project,        icon: "📋"),
        .init(id: "business",       label: AllStr.Category.business,       icon: "🏪"),
        .init(id: "sale",           label: AllStr.Category.sale,           icon: "🏷️"),
        .init(id: "gift",           label: AllStr.Category.gift,           icon: "🎊"),
        .init(id: "other_income",   label: AllStr.Category.otherIncome,    icon: "📦"),
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
