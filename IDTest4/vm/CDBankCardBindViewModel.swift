import Foundation
import Observation

//
//  CreditCardViewModel.swift
//  CatatDanaKu
//
//  Created by lishen on 2026/6/7.
//

@MainActor
@Observable
final class CDBankCardBindViewModel {
    var cards: [EntityBankCard] = []
    var showForm: Bool = false

    // Form fields
    var cardNumber: String = ""
    var bank: String = ""
    var paymentDate: String = ""
    var photoPath: String = ""
    var saved: Bool = false

    var parsedPaymentDate: Int {
        Int(paymentDate) ?? 1
    }

    var formValid: Bool {
        cardNumber.count >= 13 && !bank.isEmpty && parsedPaymentDate >= 1 && parsedPaymentDate <= 31
    }

    /// 掩码格式化
    var maskedNumber: String {
        let clean = cardNumber.filter { $0.isNumber }
        var result = ""
        for (i, ch) in clean.enumerated() {
            if i > 0 && i % 4 == 0 { result.append(" ") }
            result.append(ch)
        }
        return String(result.prefix(19))
    }

    init() {
        load()
    }

    func load() {
        cards = DatabaseHelper.shared.loadCreditCards()
    }

    func save() async {
        guard formValid else { return }

        let raw = cardNumber.filter { $0.isNumber }
        let masked = "\(raw.prefix(4)) •••• •••• \(raw.suffix(4))"
        let card = EntityBankCard(
            no: masked,
            rawNo: raw,
            bankName: bank,
            repayDate: parsedPaymentDate,
            imagePath: photoPath,
            bgColor: ""
        )
        DatabaseHelper.shared.saveCreditCard(card)
        load()

        let req = Entity20(pclb: "creditcard", qkipkeyov: [
            "action": "save",
            "bank": bank,
            "paymentDate": String(parsedPaymentDate),
        ])
        let _: NetResp<EmptyResp> = await Net.shared.post(
            path: Paths.halkm,
            encodableBody: req
        )

        saved = true
        try? await Task.sleep(nanoseconds: 600_000_000)
        resetForm()
    }

    func delete(_ card: EntityBankCard) {
        DatabaseHelper.shared.deleteCreditCard(id: card.id)
        load()
    }

    func resetForm() {
        cardNumber = ""
        bank = ""
        paymentDate = ""
        photoPath = ""
        saved = false
        showForm = false
    }
}
