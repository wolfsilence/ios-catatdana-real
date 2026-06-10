import Foundation
import Observation

//
//  TransactionViewModel.swift
//  CatatDanaKu
//
//  Created by lishen on 2026/6/7.
//

@MainActor
@Observable
final class TransactionViewModel {
    var type: TransactionType = .expense {
        didSet {
            // 切换类型时重置为对应分类的第一个
            if let first = TransactionCategory.categories(for: type).first {
                category = first.id
            }
        }
    }
    var amount: String = ""
    var category: String = TransactionCategory.expenseCategories.first?.id ?? "food"
    var location: String = ""
    var note: String = ""
    var photoPath: String = ""
    var isSaving: Bool = false
    var saved: Bool = false

    var parsedAmount: Double {
        Double(amount) ?? 0
    }

    var isValid: Bool {
        parsedAmount > 0
    }

    func save() async {
        guard isValid else { return }
        isSaving = true

        let tx = Transaction(
            type: type,
            amount: parsedAmount,
            category: category,
            location: location,
            note: note,
            photoPath: photoPath
        )
        DatabaseManager.shared.saveTransaction(tx)

        // 提交 anyBiz
        var data: [String: String] = [
            "action": "save",
            "category": category,
            "amount": String(parsedAmount),
            "type": type.rawValue,
        ]
        if !location.isEmpty { data["location"] = location }
        if !note.isEmpty { data["note"] = note }

        let req = uoz(pclb: "transaction", qkipkeyov: data)
        let _: NetResponse<EmptyResp> = await Net.shared.post(
            path: NetPath.anyBiz,
            encodableBody: req
        )

        isSaving = false
        saved = true

        try? await Task.sleep(nanoseconds: 800_000_000)
        reset()
    }

    func reset() {
        type = .expense
        amount = ""
        category = "food"
        location = ""
        note = ""
        photoPath = ""
        isSaving = false
        saved = false
    }
}
