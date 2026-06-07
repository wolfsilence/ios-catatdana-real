import Foundation
import Observation

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

        let req = AReq(type: "reminder", data: [
            "action": "save",
            "name": name,
            "amount": String(parsedAmount),
            "dueDate": ISO8601DateFormatter().string(from: dueDate),
            "note": note,
        ])
        let _: NetResponse<EmptyResp> = await Net.shared.post(
            path: NetPath.anyBiz,
            encodableBody: req
        )

        saved = true
        try? await Task.sleep(nanoseconds: 600_000_000)
        resetForm()
    }

    func delete(_ reminder: Reminder) {
        DatabaseManager.shared.deleteReminder(id: reminder.id)
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
}
