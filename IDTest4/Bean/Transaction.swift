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
        .init(id: "food",           label: AllStr.categoryFood,           icon: "🍔"),
        .init(id: "groceries",      label: AllStr.categoryGroceries,      icon: "🛒"),
        .init(id: "transport",      label: AllStr.categoryTransport,      icon: "🚗"),
        .init(id: "housing",        label: AllStr.categoryHousing,        icon: "🏠"),
        .init(id: "communication",  label: AllStr.categoryCommunication,  icon: "📱"),
        .init(id: "utilities",      label: AllStr.categoryUtilities,      icon: "⚡"),
        .init(id: "shopping",       label: AllStr.categoryShopping,       icon: "🛍️"),
        .init(id: "health",         label: AllStr.categoryHealth,         icon: "🏥"),
        .init(id: "insurance",      label: AllStr.categoryInsurance,      icon: "🛡️"),
        .init(id: "family",         label: AllStr.categoryFamily,         icon: "👶"),
        .init(id: "education",      label: AllStr.categoryEducation,      icon: "📚"),
        .init(id: "entertainment",  label: AllStr.categoryEntertainment,  icon: "🎬"),
        .init(id: "travel",         label: AllStr.categoryTravel,         icon: "✈️"),
        .init(id: "subscriptions",  label: AllStr.categorySubscriptions,  icon: "💳"),
        .init(id: "personalCare",   label: AllStr.categoryPersonalCare,   icon: "💇‍♀️"),
        .init(id: "pets",           label: AllStr.categoryPets,           icon: "🐾"),
        .init(id: "gifts",          label: AllStr.categoryGifts,          icon: "🎁"),
        .init(id: "other_expense",  label: AllStr.categoryOtherExpense,   icon: "📦"),
    ]

    static let incomeCategories: [TransactionCategory] = [
        .init(id: "salary",         label: AllStr.categorySalary,         icon: "💼"),
        .init(id: "investment",     label: AllStr.categoryInvestment,     icon: "📈"),
        .init(id: "rental",         label: AllStr.categoryRental,         icon: "🏠"),
        .init(id: "prize",          label: AllStr.categoryPrize,          icon: "🎁"),
        .init(id: "project",        label: AllStr.categoryProject,        icon: "📋"),
        .init(id: "business",       label: AllStr.categoryBusiness,       icon: "🏪"),
        .init(id: "sale",           label: AllStr.categorySale,           icon: "🏷️"),
        .init(id: "gift",           label: AllStr.categoryGift,           icon: "🎊"),
        .init(id: "other_income",   label: AllStr.categoryOtherIncome,    icon: "📦"),
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
