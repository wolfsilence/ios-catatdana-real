import Foundation

//
//  SurveyTracker.swift
//  CatatDanaKu
//
//  Created by lishen on 2026/6/7.
//

/// 埋点工具类 —— 调用 /v1/survey 接口上报行为
final class Tk {
    static let shared = Tk()
    private init() {}

    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        f.locale = Locale(identifier: "en_US_POSIX")
        return f
    }()

    private static let timeFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "HH:mm:ss"
        f.locale = Locale(identifier: "en_US_POSIX")
        return f
    }()

    /// 发送埋点
    /// - Parameters:
    ///   - page: 页面名称（必填）
    ///   - act: 行为名称（必填）
    ///   - id: 可选 ID
    ///   - code: 可选 code
    ///   - m: 手机号（传了非空值则优先使用，否则取本地存储）
    func track(page: String, act: String, id: String? = nil, code: String? = nil, m: String? = nil) {
        Logger.log("track: page=\(page) act=\(act) id=\(id ?? "") code=\(code ?? "") m=\(m ?? "")")
        
        var log = enfpzts()
        let now = Date()
        log.uzekwal = String(Int64(now.timeIntervalSince1970 * 1000))
        log.nlzyjsr = Self.dateFormatter.string(from: now)
        log.yilaltn = Self.timeFormatter.string(from: now)
        log.yjg = "Production"
        log.bmytdbexp = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        log.gcuvthapc = (m?.isEmpty == false) ? m! : UserDefaults.standard.string(forKey: Keys.lastLoginPhone) ?? ""
        log.vh = page
        log.lljletl = act
        log.httfxskg = id
        log.vuuuda = code
        log.hxj = IDFAProvider.idfa()
        log.zsjkam = KeychainHelper.read(key: Keys.adjustNetwork) ?? ""
        log.yty = Constants.appDatabaseName
        log.pnft = Constants.appDatabaseName
        log.ru = KeychainHelper.read(key: Keys.conversationData)

        var req = okak()
        req.gkykpehpn = KeychainHelper.read(key: Keys.adjustId) ?? ""
        req.sxe = KeychainHelper.read(key: Keys.afId) ?? ""
        req.nvoclmw = [log]
        
        Task.detached {
            let _: NetResponse<EmptyResp> = await Net.shared.post(
                path: NetPath.survey,
                encodableBody: req
            )
        }
    }
}
