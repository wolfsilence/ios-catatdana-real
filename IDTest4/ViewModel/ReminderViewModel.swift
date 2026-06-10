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
final class ReminderViewModel {
    var reminders: [Reminder] = []
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

    var sortedReminders: [Reminder] {
        reminders.sorted { $0.dueDate < $1.dueDate }
    }

    init() {
        load()
    }

    func load() {
        reminders = DatabaseManager.shared.loadReminders()
    }

    func save() async {
        guard formValid else { return }

        let reminder = Reminder(
            name: name,
            amount: parsedAmount,
            dueDate: dueDate,
            note: note
        )
        DatabaseManager.shared.saveReminder(reminder)
        load()

        // 安排本地推送通知
        scheduleNotification(for: reminder)

        let req = uoz(pclb: "reminder", qkipkeyov: [
            "action": "save",
            "name": name,
            "amount": String(parsedAmount),
            "dueDate": ISO8601DateFormatter().string(from: dueDate),
            "note": note,
        ])
        let _: NetResponse<EmptyResp> = await Net.shared.post(
            path: NetPath.halkm,
            encodableBody: req
        )

        saved = true
        try? await Task.sleep(nanoseconds: 600_000_000)
        resetForm()
    }

    func delete(_ reminder: Reminder) {
        DatabaseManager.shared.deleteReminder(id: reminder.id)
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

    private func scheduleNotification(for reminder: Reminder) {
        let content = UNMutableNotificationContent()
        content.title = reminder.name
        content.body = "Rp \(formatIDR(reminder.amount)) — \(Strings.Reminder.dueDateLabel)"
        content.sound = .default

        var components = Calendar.current.dateComponents([.year, .month, .day], from: reminder.dueDate)
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

    private func cancelNotification(for reminder: Reminder) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["reminder_\(reminder.id)"])
    }
}
