import Foundation

//
//  Reminder.swift
//  CatatDanaKu
//
//  Created by lishen on 2026/6/7.
//

struct EntityReminder: Codable, Identifiable {
    var id: String = UUID().uuidString
    var name: String
    var amount: Double
    var date: Date
    var note: String = ""
    var isActive: Bool = true
    var createdDate: Date = Date()

    /// 距离到期日的天数
    var daysUntilDue: Int {
        let calendar = Calendar.current
        let due = calendar.startOfDay(for: date)
        let today = calendar.startOfDay(for: Date())
        return calendar.dateComponents([.day], from: today, to: due).day ?? 0
    }
    
    /// 是否紧急（3 天内到期）
    var isUrge: Bool { daysUntilDue >= 0 && daysUntilDue <= 3 }

    /// 是否已过期
    var isPast: Bool { daysUntilDue < 0 }


}
