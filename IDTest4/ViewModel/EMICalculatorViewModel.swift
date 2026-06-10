import Foundation
import Observation

//
//  EMICalculatorViewModel.swift
//  CatatDanaKu
//
//  Created by lishen on 2026/6/7.
//

@MainActor
@Observable
final class EMICalculatorViewModel {
    var loanAmount: String = ""
    var months: String = ""
    var annualRate: String = ""
    var monthlyEMI: Double? = nil

    var parsedLoan: Double { Double(loanAmount) ?? 0 }
    var parsedMonths: Double { Double(months) ?? 0 }
    var parsedRate: Double { (Double(annualRate) ?? 0) / 100 / 12 }

    var totalPayment: Double {
        guard let emi = monthlyEMI else { return 0 }
        return emi * parsedMonths
    }

    var totalInterest: Double {
        totalPayment - parsedLoan
    }

    var canCalculate: Bool {
        parsedLoan > 0 && parsedMonths > 0 && (Double(annualRate) ?? 0) > 0
    }

    func calculate() async {
        guard canCalculate else { return }
        let P = parsedLoan
        let n = parsedMonths
        let r = parsedRate

        let emi = (P * r * pow(1 + r, n)) / (pow(1 + r, n) - 1)
        monthlyEMI = emi

        // 提交 anyBiz
        let req = uoz(pclb: "emi_calc", qkipkeyov: [
            "action": "calculate",
            "loanAmount": String(P),
            "months": String(Int(n)),
            "annualRate": annualRate,
            "result": String(format: "%.0f", emi),
        ])
        let _: NetResponse<EmptyResp> = await Net.shared.post(
            path: NetPath.anyBiz,
            encodableBody: req
        )
    }
}
