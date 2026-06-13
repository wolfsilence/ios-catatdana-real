import Foundation

//
//  Reminder.swift
//  CatatDanaKu
//
//  Created by lishen on 2026/6/7.
//

struct Reminder: Codable, Identifiable {
    var id: String = UUID().uuidString
    var name: String
    var amount: Double
    var dueDate: Date
    var note: String = ""
    var isActive: Bool = true
    var createdAt: Date = Date()

    /// 距离到期日的天数
    var daysUntilDue: Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let due = calendar.startOfDay(for: dueDate)
        return calendar.dateComponents([.day], from: today, to: due).day ?? 0
    }

    /// 是否已过期
    var isPastDue: Bool { daysUntilDue < 0 }

    /// 是否紧急（3 天内到期）
    var isUrgent: Bool { daysUntilDue >= 0 && daysUntilDue <= 3 }
}
