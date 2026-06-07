import Foundation

//
//  DatabaseManager.swift
//  CatatDanaKu
//
//  Created by lishen on 2026/6/7.
//

/// 本地数据库管理器 —— JSON 文件持久化，轻量无第三方依赖
class DatabaseManager {
    static let shared = DatabaseManager()

    private let fileManager = FileManager.default
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    private init() {
        encoder.outputFormatting = .prettyPrinted
    }

    // MARK: - File URLs

    private var documentsDir: URL {
        fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }

    private func url(for collection: String) -> URL {
        documentsDir.appendingPathComponent("cdku_\(collection).json")
    }

    // MARK: - Generic CRUD

    private func load<T: Codable>(collection: String) -> [T] {
        let fileURL = url(for: collection)
        guard fileManager.fileExists(atPath: fileURL.path),
              let data = try? Data(contentsOf: fileURL) else {
            return []
        }
        return (try? decoder.decode([T].self, from: data)) ?? []
    }

    private func save<T: Codable>(_ items: [T], collection: String) {
        let fileURL = url(for: collection)
        guard let data = try? encoder.encode(items) else { return }
        try? data.write(to: fileURL, options: .atomic)
    }

    // MARK: - Transactions

    func loadTransactions() -> [Transaction] {
        load(collection: "transactions")
    }

    func saveTransaction(_ tx: Transaction) {
        var items: [Transaction] = load(collection: "transactions")
        if let idx = items.firstIndex(where: { $0.id == tx.id }) {
            items[idx] = tx
        } else {
            items.append(tx)
        }
        save(items, collection: "transactions")
    }

    func deleteTransaction(id: String) {
        var items: [Transaction] = load(collection: "transactions")
        items.removeAll { $0.id == id }
        save(items, collection: "transactions")
    }

    // MARK: - Reminders

    func loadReminders() -> [Reminder] {
        load(collection: "reminders")
    }

    func saveReminder(_ r: Reminder) {
        var items: [Reminder] = load(collection: "reminders")
        if let idx = items.firstIndex(where: { $0.id == r.id }) {
            items[idx] = r
        } else {
            items.append(r)
        }
        save(items, collection: "reminders")
    }

    func deleteReminder(id: String) {
        var items: [Reminder] = load(collection: "reminders")
        items.removeAll { $0.id == id }
        save(items, collection: "reminders")
    }

    // MARK: - Credit Cards

    func loadCreditCards() -> [CreditCard] {
        load(collection: "creditcards")
    }

    func saveCreditCard(_ c: CreditCard) {
        var items: [CreditCard] = load(collection: "creditcards")
        if let idx = items.firstIndex(where: { $0.id == c.id }) {
            items[idx] = c
        } else {
            items.append(c)
        }
        save(items, collection: "creditcards")
    }

    func deleteCreditCard(id: String) {
        var items: [CreditCard] = load(collection: "creditcards")
        items.removeAll { $0.id == id }
        save(items, collection: "creditcards")
    }

    // MARK: - Clear All (for account deletion)

    func clearAll() {
        ["transactions", "reminders", "creditcards"].forEach { collection in
            let fileURL = url(for: collection)
            try? fileManager.removeItem(at: fileURL)
        }
    }
}
