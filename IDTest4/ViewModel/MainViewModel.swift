import Foundation
import SwiftUI
import Observation

//
//  MainViewModel.swift
//  CatatDanaKu
//
//  Created by lishen on 2026/6/7.
//

@MainActor
@Observable
final class MainViewModel {
    // MARK: - User Info

    var userName: String = ""
    var userPhone: String = ""
    var avatarURL: String = ""
    var userInitial: String { userName.first.map(String.init) ?? "U" }

    var displayName: String {
        if let nick = UserDefaults.standard.string(forKey: Keys.profileNickname), !nick.isEmpty {
            return nick
        }
        return userName
    }

    func updateNickname(_ name: String) {
        UserDefaults.standard.set(name, forKey: Keys.profileNickname)
    }

    func updateAvatarURL(_ url: String) {
        avatarURL = url
        UserDefaults.standard.set(url, forKey: Keys.profileAvatarURL)
    }

    // MARK: - Financial Summary

    var balance: Double = 0
    var totalIncome: Double = 0
    var totalExpense: Double = 0
    var savingsRate: Double = 0

    // MARK: - Data

    var transactions: [Transaction] = []
    var reminders: [Reminder] = []
    var creditCards: [CreditCard] = []

    // MARK: - Tab

    var selectedTab: MainTab = .home

    var recentTransactions: [Transaction] {
        Array(transactions.sorted(by: { $0.date > $1.date }).prefix(3))
    }

    // MARK: - Init

    init() {
        loadUserInfo()
        refreshData()
    }

    // MARK: - Load

    func refreshData() {
        avatarURL = UserDefaults.standard.string(forKey: Keys.profileAvatarURL) ?? ""
        transactions = DatabaseManager.shared.loadTransactions()
        reminders = DatabaseManager.shared.loadReminders()
        creditCards = DatabaseManager.shared.loadCreditCards()
        calculateSummary()
    }

    private func loadUserInfo() {
        let phone = UserDefaults.standard.string(forKey: Keys.lastLoginPhone) ?? ""
        userPhone = phone
        avatarURL = UserDefaults.standard.string(forKey: Keys.profileAvatarURL) ?? ""
        if !phone.isEmpty {
            let suffix = String(phone.suffix(4))
            userName = "Pengguna \(suffix)"
        } else {
            userName = "Pengguna"
        }
    }

    // MARK: - Calculate

    private func calculateSummary() {
        let now = Date()
        let calendar = Calendar.current
        guard let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: now)) else {
            return
        }

        let monthTx = transactions.filter { $0.date >= startOfMonth }
        totalIncome = monthTx.filter { $0.type == .income }.reduce(0) { $0 + $1.amount }
        totalExpense = monthTx.filter { $0.type == .expense }.reduce(0) { $0 + $1.amount }
        balance = totalIncome - totalExpense
        savingsRate = totalIncome > 0 ? (balance / totalIncome) * 100 : 0
    }

    // MARK: - anyBiz

    func submitBiz(type: String, data: [String: String]) async {
        let req = AReq(type: type, data: data)
        let _: NetResponse<EmptyResp> = await Net.shared.post(
            path: NetPath.anyBiz,
            encodableBody: req
        )
    }
}

// MARK: - Enums

enum MainTab: String, CaseIterable {
    case home = "home"
    case profile = "profile"

    var label: String {
        switch self {
        case .home: return Strings.Home.tabHome
        case .profile: return Strings.Home.tabProfile
        }
    }

    var icon: String {
        switch self {
        case .home: return "house.fill"
        case .profile: return "person.fill"
        }
    }
}

enum MainFeature: String, Identifiable, CaseIterable {
    case record = "record"
    case reminder = "reminder"
    case creditcard = "creditcard"
    case emi = "emi"
    case maxloan = "maxloan"
    case exchange = "exchange"
    case analysis = "analysis"
    case settings = "settings"
    case privacyView = "privacy_view"
    case contact = "contact"

    var id: String { rawValue }

    var label: String {
        switch self {
        case .record:       return Strings.Home.featureRecord
        case .reminder:     return Strings.Home.featureReminder
        case .creditcard:   return Strings.Home.featureCreditCard
        case .emi:          return Strings.Home.featureEMI
        case .maxloan:      return Strings.Home.featureMaxLoan
        case .exchange:     return Strings.Home.featureExchange
        case .analysis:     return Strings.Home.featureAnalysis
        case .settings:     return Strings.Profile.settings
        case .privacyView:  return Strings.Profile.privacy
        case .contact:      return Strings.Profile.contactUs
        }
    }

    var iconName: String {
        switch self {
        case .record:       return "pencil.line"
        case .reminder:     return "clock.fill"
        case .creditcard:   return "creditcard.fill"
        case .emi:          return "doc.text.fill"
        case .maxloan:      return "chart.line.uptrend.xyaxis"
        case .exchange:     return "globe"
        case .analysis:     return "chart.pie.fill"
        case .settings:     return "gearshape.fill"
        case .privacyView:  return "lock.shield.fill"
        case .contact:      return "envelope.fill"
        }
    }

    var bgColor: Color {
        switch self {
        case .record:       return Color(hex: "#FF9500")
        case .reminder:     return Color(hex: "#8B5CF6")
        case .creditcard:   return Color(hex: "#3B82F6")
        case .emi:          return Color(hex: "#1BC459")
        case .maxloan:      return Color(hex: "#F59E0B")
        case .exchange:     return Color(hex: "#14B8A6")
        case .analysis:     return Color(hex: "#1BC459")
        case .settings:     return Color(hex: "#8B5CF6")
        case .privacyView:  return Color(hex: "#3B82F6")
        case .contact:      return Color(hex: "#3B82F6")
        }
    }

    /// 首页 6 宫格展示的功能入口
    static let homeGrid: [MainFeature] = [.record, .reminder, .creditcard, .emi, .maxloan, .exchange]
}
