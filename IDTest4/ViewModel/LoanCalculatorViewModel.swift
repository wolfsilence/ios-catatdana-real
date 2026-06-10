import Foundation
import Observation

//
//  LoanCalculatorViewModel.swift
//  CatatDanaKu
//
//  Created by lishen on 2026/6/7.
//

@MainActor
@Observable
final class LoanCalculatorViewModel {
    var monthlyPayment: String = ""
    var annualRate: String = ""
    var months: String = ""
    var maxLoan: Double? = nil

    var parsedPayment: Double { Double(monthlyPayment) ?? 0 }
    var parsedMonths: Double { Double(months) ?? 0 }
    var parsedRate: Double { (Double(annualRate) ?? 0) / 100 / 12 }

    var canCalculate: Bool {
        parsedPayment > 0 && parsedMonths > 0 && (Double(annualRate) ?? 0) > 0
    }

    func calculate() async {
        guard canCalculate else { return }
        let emi = parsedPayment
        let n = parsedMonths
        let r = parsedRate

        let loan = (emi * (1 - pow(1 + r, -n))) / r
        maxLoan = loan

        let req = uoz(pclb: "maxloan_calc", qkipkeyov: [
            "action": "calculate",
            "monthlyPayment": String(emi),
            "months": String(Int(n)),
            "annualRate": annualRate,
            "result": String(format: "%.0f", loan),
        ])
        let _: NetResponse<EmptyResp> = await Net.shared.post(
            path: NetPath.halkm,
            encodableBody: req
        )
    }
}
