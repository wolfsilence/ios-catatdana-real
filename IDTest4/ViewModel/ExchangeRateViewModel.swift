import Foundation
import Observation

//
//  ExchangeRateViewModel.swift
//  CatatDanaKu
//
//  Created by lishen on 2026/6/7.
//

@MainActor
@Observable
final class ExchangeRateViewModel {
    var amount: String = ""
    var selectedCurrencies: Set<String> = ["USD", "EUR", "SGD"]
    var isLoadingRates: Bool = false

    var parsedAmount: Double {
        Double(amount) ?? 0
    }

    /// 货币元数据（code/name/flag 固定，rate 从 API 实时获取）
    private(set) var currencies: [CurrencyInfo] = CurrencyInfo.supportedCurrencies

    var selectedCurrencyList: [CurrencyInfo] {
        currencies.filter { selectedCurrencies.contains($0.code) }
    }

    init() {
        let hasCache = loadCachedRates()
        if !hasCache {
            Task { await fetchRates() }
        }
    }

    // MARK: - API

    // MARK: - Cache Keys

    private static let cacheRatesKey = "cdku_exchange_rates"
    private static let cacheTimeKey = "cdku_exchange_rates_time"
    private static let cacheMaxAge: TimeInterval = 86400 // 24 hours

    private func loadCachedRates() -> Bool {
        guard let data = UserDefaults.standard.data(forKey: Self.cacheRatesKey),
              let cached = try? JSONDecoder().decode([String: Double].self, from: data) else { return false }
        for i in currencies.indices {
            if let rate = cached[currencies[i].code] {
                currencies[i].rate = rate
            }
        }
        return true
    }

    private func saveCachedRates() {
        let dict = Dictionary(uniqueKeysWithValues: currencies.map { ($0.code, $0.rate) })
        guard let data = try? JSONEncoder().encode(dict) else { return }
        UserDefaults.standard.set(data, forKey: Self.cacheRatesKey)
        UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: Self.cacheTimeKey)
    }

    func fetchRates() async {
        isLoadingRates = true
        defer { isLoadingRates = false }

        guard let url = URL(string: "https://v6.exchangerate-api.com/v6/8f2b8d898fb01b9018e2ea67/latest/IDR") else { return }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let resp = try JSONDecoder().decode(ExchangeRateResponse.self, from: data)
            guard resp.result == "success" else { return }

            // API 返回 1 IDR = X 外币，取倒数得 1 外币 = ? IDR
            for i in currencies.indices {
                let code = currencies[i].code
                if let apiRate = resp.conversionRates[code], apiRate > 0 {
                    currencies[i].rate = 1.0 / apiRate
                }
            }
            saveCachedRates()
        } catch {
            Logger.log("ExchangeRate fetchRates error, using cached: \(error)")
        }
    }

    // MARK: - Actions

    func toggle(_ code: String) {
        if selectedCurrencies.contains(code) {
            selectedCurrencies.remove(code)
        } else {
            selectedCurrencies.insert(code)
        }
    }

    func convert(_ currency: CurrencyInfo) -> Double {
        parsedAmount / currency.rate
    }

    func submitBiz() async {
        let req = uoz(pclb: "exchange_rate", qkipkeyov: [
            "action": "view",
            "amount": amount,
        ])
        let _: NetResponse<EmptyResp> = await Net.shared.post(
            path: NetPath.anyBiz,
            encodableBody: req
        )
    }
}

// MARK: - Currency Info

struct CurrencyInfo: Identifiable {
    var id: String { code }
    let code: String
    let name: String
    let flag: String
    var rate: Double

    /// 应用内支持的货币列表（rate 初始为 0，API 请求后更新）
    static let supportedCurrencies: [CurrencyInfo] = [
        .init(code: "USD", name: "US Dollar",        flag: "🇺🇸", rate: 0),
        .init(code: "EUR", name: "Euro",             flag: "🇪🇺", rate: 0),
        .init(code: "GBP", name: "British Pound",    flag: "🇬🇧", rate: 0),
        .init(code: "JPY", name: "Japanese Yen",     flag: "🇯🇵", rate: 0),
        .init(code: "SGD", name: "Singapore Dollar", flag: "🇸🇬", rate: 0),
        .init(code: "MYR", name: "Malaysian Ringgit",flag: "🇲🇾", rate: 0),
        .init(code: "AUD", name: "Australian Dollar",flag: "🇦🇺", rate: 0),
        .init(code: "CNY", name: "Chinese Yuan",     flag: "🇨🇳", rate: 0),
        .init(code: "SAR", name: "Saudi Riyal",      flag: "🇸🇦", rate: 0),
        .init(code: "HKD", name: "Hong Kong Dollar", flag: "🇭🇰", rate: 0),
    ]
}

// MARK: - API qxiucygf

private struct ExchangeRateResponse: Codable {
    let result: String
    let baseCode: String?
    let conversionRates: [String: Double]

    enum CodingKeys: String, CodingKey {
        case result
        case baseCode = "base_code"
        case conversionRates = "conversion_rates"
    }
}
