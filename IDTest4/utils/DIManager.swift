import Foundation
import UIKit
import CoreLocation
import CoreTelephony
import Network
import Gzip

/// Actor-based device info manager (thread-safe, no locks)
final class DIManager {

    static let shared = DIManager()

    private let encoder = JSONEncoder()
    private let queue = DispatchQueue(label: "device.info.manager")
    private var isUploading = false

    private init() {
        CdkDICleaner.shared.cdkSafeClean("DIManager")
    }

    // MARK: - Public

    func upload(completion: @escaping (String) -> Void) {
        CdkDICleaner.shared.cdkPrint(0xD1)
        queue.async { [weak self] in
            guard let self = self else { return }

            if self.isUploading {
                DispatchQueue.main.async { completion("-1") }
                return
            }

            self.isUploading = true

            Task {
                defer {
                    self.queue.async {
                        self.isUploading = false
                    }
                }

                let ui = await MainActor.run { self.collectUIKitValues() }
                let req = await self.collect(ui: ui)
                let result = await self.uploadEnc(req)

                completion(result)
            }
        }
    }
    
    // MARK: - JSON

    private func jsonString<T: Codable>(_ value: T?) -> String? {
        guard let value,
              let data = try? encoder.encode(value) else { return nil }
        return String(data: data, encoding: .utf8)
    }

    // MARK: - UIKit

    private struct UIData {
        let machine: String
        let systemVersion: String
        let resolution: String
        let batteryPct: String
        let batteryCharging: Int
        let buildId: String?
        let buildName: String?
        let packageName: String?
    }

    private func collectUIKitValues() -> UIData {
        var machine = ""
        var sysInfo = utsname()
        if uname(&sysInfo) == 0 {
            let mirror = Mirror(reflecting: sysInfo.machine)
            machine = mirror.children.reduce("") {
                guard let v = $1.value as? Int8, v != 0 else { return $0 }
                return $0 + String(UnicodeScalar(UInt8(v)))
            }
        }

        let screen = UIScreen.main
        let bounds = screen.nativeBounds

        // iOS does not expose xdpi/ydpi, approximate using nativeScale * 163 (base iPhone DPI)
        let approxPPI = screen.nativeScale * 163.0

        let widthInches = bounds.width / approxPPI
        let heightInches = bounds.height / approxPPI
        let diagonal = sqrt(widthInches * widthInches + heightInches * heightInches)

        // keep 2 decimal places, align with Android format
        let resolution = String(format: "%.2f", diagonal)

        let dev = UIDevice.current
//        dev.isBatteryMonitoringEnabled = true

        let pct = dev.batteryLevel >= 0 ? String(Int(dev.batteryLevel * 100)) : "0"
        let charging = (dev.batteryState == .charging || dev.batteryState == .full) ? 1 : 0
        
        Logger.log("phone charging = \(charging) pct = \(pct)%")

//        dev.isBatteryMonitoringEnabled = false

        let info = Bundle.main.infoDictionary

        return UIData(
            machine: machine,
            systemVersion: dev.systemVersion,
            resolution: resolution,
            batteryPct: pct,
            batteryCharging: charging,
            buildId: info?["CFBundleVersion"] as? String,
            buildName: info?["CFBundleShortVersionString"] as? String,
            packageName: Bundle.main.bundleIdentifier
        )
    }

    // MARK: - Collect

    private func collect(ui: UIData) async -> Entity5 {
        CdkDICleaner.shared.cdkTag()
        let details = Entity22(
            hg: jsonString(collect16(ui: ui)),
            ixpv: jsonString(collect14()),
            xiwj: jsonString(await collect21()),
            gvome: jsonString(collectOtherData()),
            zepmzjl: "[]",
            gssgtffor: "[]",
            cghopuai: "[]",
            jma: jsonString(collectNetwork()),
            dljul: "[]",
            rxzmyr: jsonString(await collect19()),
            l: "",
            dtumpj: jsonString(collect23(ui: ui)),
            mbulh: 0,
            zfckmwrbm: 0,
            qpseh: 0,
            xslhjsjr: 0,
            amr: 0,
            elxyqb: 0,
            ttwj: 0,
            lnebfqb: 0,
            oqwntrdq: "",
            pm: ui.buildId,
            vebic: ui.buildName,
            qdi: ui.packageName
        )

        return Entity5(
            sxc: details,
            nksosmr: nil,
            jnvl: KeychainHelper.read(key: K.afIdK),
            dpvgvkzck: "",
            ip: "",
            irzouy: KeychainHelper.read(key: K.appInstanceIDK),
            rwbh: KeychainHelper.read(key: K.conversationDataK),
            puuje: "[]",
            vipoqc: KeychainHelper.read(key: K.adjustIdK),
            hbhxt: KeychainHelper.read(key: K.adjustDataK)
        )
    }
  

    // MARK: - Hardware

    private func collect16(ui: UIData) -> Entity16 {
        Entity16(
            sfelobdp: ui.machine,
            pefymokx: ui.systemVersion,
            ozpwp: ui.systemVersion,
            fyogvz: ui.machine,
            kgwwmkvyd: "",
            ooif: "Apple",
            ghkw: ui.resolution
        )
    }

    // MARK: - Storage

    private func collect14() -> Entity14 {
        let ramTotal = String(ProcessInfo.processInfo.physicalMemory)
        var internalUsable = ""
        var internalTotal = ""
        

        if let attrs = try? FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory()) {
            if let v = attrs[.systemSize] as? Int64 { internalTotal = String(v) }
            if let v = attrs[.systemFreeSize] as? Int64 { internalUsable = String(v) }
        }

        return Entity14(
            jwmqweqj: ramTotal,
            nqsmx: "",
            jqquuib: internalUsable,
            prsgy: internalTotal,
            hwiyud: "",
            cvetgv: ""
        )
    }

    // MARK: - General

    private func collect21() async -> Entity21 {
        let tz = TimeZone.current
        
        // 【核心修改】使用 preferredLanguages 获取系统真实的语言列表
        // first 即为当前设备优先级最高的原始语言设置
        let systemLangIdentifier = Locale.preferredLanguages.first ?? ""
        
        // 从完整的标识符中提取纯语言代码（如 "en-US" -> "en", "zh-Hans-CN" -> "zh"）
        let langCode = systemLangIdentifier.components(separatedBy: "-").first ?? ""
        
        // 创建一个基于该原始语言的 Locale 对象，用于后续的地区和名称解析
        let originalLocale = Locale(identifier: systemLangIdentifier)
        
        let (type, name) = await detectNetwork()

        return Entity21(
            kqsaexaai: IDFAHelper.idfa(),
            pcgckooi: "",
            yadaul: IDFAHelper.idfa(),
            gr: langCode,
            wtitb: iso3Language(from: originalLocale),
            eyhpout: originalLocale.localizedString(forLanguageCode: langCode) ?? "",
            rd: iso3Country(from: originalLocale),
            cydyjdj: "",
            cipvbmyt: "",
            kdoo: "",
            kmrkp: name,
            aitvzgb: type,
            eqr: tz.identifier
        )
    }
    
    private func iso3Country(from locale: Locale) -> String {
        guard let regionCode = locale.region?.identifier else { return "" }
        return Locale.Region.isoRegions
            .first(where: { Locale(identifier: $0.identifier).region?.identifier == regionCode })?.identifier
            ?? regionCode
    }

    private func iso3Language(from locale: Locale) -> String {
        guard let langCode = locale.language.languageCode else { return "" }
        let id = langCode.identifier
        return Locale.LanguageCode.isoLanguageCodes
            .first(where: { Locale(identifier: $0.identifier).language.languageCode?.identifier == id })?.identifier
            ?? id
    }

    
    private nonisolated let networkMonitor: NWPathMonitor = {
        let m = NWPathMonitor()
        m.start(queue: DispatchQueue(label: "net.monitor", qos: .utility))
        return m
    }()

    private func detectNetwork() async -> (String, String) {
        let path = networkMonitor.currentPath

        var type = "none"

        if path.usesInterfaceType(.wifi) {
            type = "wifi"
        } else if path.usesInterfaceType(.cellular) {
            let tel = CTTelephonyNetworkInfo()
            if let tech = tel.serviceCurrentRadioAccessTechnology?.values.first {
                switch tech {
                case CTRadioAccessTechnologyEdge, CTRadioAccessTechnologyGPRS:
                    type = "2g"
                case CTRadioAccessTechnologyWCDMA, CTRadioAccessTechnologyHSDPA,
                     CTRadioAccessTechnologyHSUPA, CTRadioAccessTechnologyCDMA1x,
                     CTRadioAccessTechnologyCDMAEVDORev0, CTRadioAccessTechnologyCDMAEVDORevA,
                     CTRadioAccessTechnologyCDMAEVDORevB:
                    type = "3g"
                case CTRadioAccessTechnologyLTE, CTRadioAccessTechnologyeHRPD:
                    type = "4g"
                case CTRadioAccessTechnologyNR, CTRadioAccessTechnologyNRNSA:
                    type = "5g"
                default:
                    type = "other"
                }
            }
        }

        let tel = CTTelephonyNetworkInfo()
        
        var carrierName = ""
//        if let carriers = tel.serviceSubscriberCellularProviders {
//            // 取第一个可用的 SIM 卡信息（主卡）
//            if let firstCarrier = carriers.values.first {
//                // 注意：即便使用新接口，在用户未授权“精准位置”或处于飞行模式时仍可能为空
//                carrierName = firstCarrier.carrierName ?? ""
//            }
//        }
        return (type, carrierName)
    }

    // MARK: - Other

    private func collectOtherData() -> Entity9 {
        Entity9(
            vx: isJailbroken() ? 1 : 0,
            bslvhynor: bootTime(),
            cgichrgbd: "",
            qqyyhtg: isSimulator() ? 1 : 0,
            yqnral: "0"
        )
    }

    private func isJailbroken() -> Bool {
        // 1. Simulator → never jailbreak
        #if targetEnvironment(simulator)
        return false
        #endif

        // 2. Common jailbreak file paths
        let suspiciousPaths = [
            "/Applications/Cydia.app",
            "/Library/MobileSubstrate/MobileSubstrate.dylib",
            "/etc/apt",
            "/private/var/lib/apt",
            "/bin/bash",
            "/usr/sbin/sshd",
            "/private/var/tmp/cydia.log"
        ]

        if suspiciousPaths.contains(where: { FileManager.default.fileExists(atPath: $0) }) {
            return true
        }

        // 3. Try writing outside sandbox
        let testPath = "/private/jb_test_\(UUID().uuidString)"
        do {
            try "test".write(toFile: testPath, atomically: true, encoding: .utf8)
            try FileManager.default.removeItem(atPath: testPath)
            return true
        } catch {
            // expected on non-jailbroken devices
        }

        return false
    }

    private func bootTime() -> String {
        var tv = timeval()
        var mib: [Int32] = [CTL_KERN, KERN_BOOTTIME]
        var len = MemoryLayout<timeval>.stride
        guard sysctl(&mib, u_int(mib.count), &tv, &len, nil, 0) == 0 else { return "" }
        return String(tv.tv_sec)
    }

    private func isSimulator() -> Bool {
        #if targetEnvironment(simulator)
        return true
        #else
        return false
        #endif
    }

    // MARK: - Network

    private func collectNetwork() -> Entity15 {
        Entity15(vdbrlk: wifiIP())
    }

    private func wifiIP() -> String {
        var ifa: UnsafeMutablePointer<ifaddrs>?
        var addr = ""

        guard getifaddrs(&ifa) == 0 else { return "" }
        defer { freeifaddrs(ifa) }

        var ptr = ifa
        while ptr != nil {
            let name = String(cString: ptr!.pointee.ifa_name)
            let sa = ptr!.pointee.ifa_addr.pointee

            if sa.sa_family == UInt8(AF_INET), name == "en0" {
                var host = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                getnameinfo(ptr!.pointee.ifa_addr,
                            socklen_t(sa.sa_len),
                            &host,
                            socklen_t(host.count),
                            nil,
                            0,
                            NI_NUMERICHOST)
                addr = String(cString: host)
            }

            ptr = ptr!.pointee.ifa_next
        }

        return addr
    }

    // MARK: - Location

    private func collect19() async -> Entity19 {
        let lat = LocationManager.shared.latitude
        let lng = LocationManager.shared.longitude

        let gps: Entity3?
        if let lat, let lng {
            gps = Entity3(ln: lat, lajisra: lng)
        } else {
            gps = Entity3()
        }

        return Entity19(
            atucchr: "",
            qqe: "",
            qzjhd: gps,
            efjao: ""
        )
    }

    // MARK: - Battery

    private func collect23(ui: UIData) -> Entity23 {
        Entity23(
            olkhcofke: ui.batteryPct,
            fkvrwg: ui.batteryCharging,
            jwebay: 0,
            kewbxfxyj: 0
        )
    }

    // MARK: - Upload

    private func uploadEnc(_ req: Entity5) async -> String {
        CdkDICleaner.shared.cdkCleanAll()
        guard let jsonData = try? encoder.encode(req) else { return "-1" }
        Logger.log("DI-INFO: \(String(data: jsonData, encoding: .utf8) ?? "nil")")
        let toCompress: Data
        if Consts.encry {
            guard let jsonStr = String(data: jsonData, encoding: .utf8),
                  let encrypted = try? CdBox.stA(real: jsonStr),
                  let data = encrypted.data(using: .utf8) else { return "-1" }
            toCompress = data
        } else {
            toCompress = jsonData
        }
        let compressed = try! toCompress.gzipped()
        let result: NetResp<EmptyResp> = await Net.shared.postGzip(
            path: Paths.dvtiwmm,
            gzipedBody: compressed
        )
        return result.isSuccess ? "1" : "-1"
    }
}
