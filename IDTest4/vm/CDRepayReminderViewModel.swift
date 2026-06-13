import Foundation
import Observation
import UserNotifications

//
//  ReminderViewModel.swift
//  CatatDanaKu
//
//  Created by lishen on 2026/6/7.
//

@MainActor
@Observable
final class CDRepayReminderViewModel {
    var reminders: [EntityReminder] = []
    var showForm: Bool = false

    // Form fields
    var name: String = ""
    var amount: String = ""
    var dueDate: Date = Date()
    var note: String = ""
    var saved: Bool = false

    var parsedAmount: Double {
        Double(amount) ?? 0
    }

    var totalAmount: Double {
        reminders.filter(\.isActive).reduce(0) { $0 + $1.amount }
    }

    var formValid: Bool {
        !name.isEmpty && parsedAmount > 0
    }

    var sortedReminders: [EntityReminder] {
        reminders.sorted { $0.date < $1.date }
    }

    init() {
        load()
    }

    func load() {
        reminders = DatabaseHelper.shared.loadReminders()
    }

    func save() async {
        guard formValid else { return }

        let reminder = EntityReminder(
            name: name,
            amount: parsedAmount,
            date: dueDate,
            note: note
        )
        DatabaseHelper.shared.saveReminder(reminder)
        load()

        // 安排本地推送通知
        scheduleNotification(for: reminder)

        let req = Entity20(pclb: "reminder", qkipkeyov: [
            "action": "save",
            "name": name,
            "amount": String(parsedAmount),
            "dueDate": ISO8601DateFormatter().string(from: dueDate),
            "note": note,
        ])
        let _: NetResp<EmptyResp> = await Net.shared.post(
            path: Paths.halkm,
            encodableBody: req
        )

        saved = true
        try? await Task.sleep(nanoseconds: 600_000_000)
        resetForm()
    }

    func delete(_ reminder: EntityReminder) {
        DatabaseHelper.shared.deleteReminder(id: reminder.id)
        cancelNotification(for: reminder)
        load()
    }

    func resetForm() {
        name = ""
        amount = ""
        dueDate = Date()
        note = ""
        saved = false
        showForm = false
    }

    // MARK: - Local Notifications

    private func scheduleNotification(for reminder: EntityReminder) {
        let content = UNMutableNotificationContent()
        content.title = reminder.name
        content.body = "Rp \(formatIDR(reminder.amount)) — \(AllStr.rmDl)"
        content.sound = .default

        var components = Calendar.current.dateComponents([.year, .month, .day], from: reminder.date)
        components.hour = 12
        components.minute = 0
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)

        let request = UNNotificationRequest(
            identifier: "reminder_\(reminder.id)",
            content: content,
            trigger: trigger
        )
        UNUserNotificationCenter.current().add(request) { error in
            if let error { Logger.log("❌ Reminder notification error: \(error.localizedDescription)") }
        }
    }

    private func cancelNotification(for reminder: EntityReminder) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["reminder_\(reminder.id)"])
    }
}
