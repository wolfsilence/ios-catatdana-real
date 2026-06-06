import Foundation
import UIKit
import CoreLocation
import CoreTelephony
import Network

//
//  DeviceInfoManager.swift
//  CatatDanaKu
//
//  Created by lishen on 2026/6/5.
//

/// 设备信息管理（单例），负责采集 + 上传 RuntimeReq
/// 全程子线程、非重入
final class DeviceInfoManager {
    static let shared = DeviceInfoManager()

    private let encoder = JSONEncoder()
    private nonisolated let lock = NSLock()
    private nonisolated(unsafe) var isUploading = false

    private init() {}

    // MARK: - Public

    /// 上传设备信息，完成后回调 value（供 JSMessageHandler respond 用）
    func upload(completion: @escaping (String) -> Void) {
        let canProceed = lock.withLock {
            if isUploading { return false }
            isUploading = true
            return true
        }
        guard canProceed else {
            completion("-1")
            return
        }

        // 在主线程一次性收集所有 UIKit 依赖值
        let ui = collectUIKitValues()

        Task.detached(priority: .utility) { [weak self] in
            guard let self else { return }
            defer {
                self.lock.withLock { self.isUploading = false }
            }

            let req = await self.collect(ui: ui)
            let result = await self.uploadEncrypted(req)
            await MainActor.run { completion(result) }
        }
    }

    // MARK: - UIKit 值收集（主线程调用）

    private struct UIData {
        let machine: String
        let systemVersion: String
        let screenDiagonal: String
        let batteryPct: String
        let batteryCharging: Int
        let buildId: String?
        let buildName: String?
        let packageName: String?
    }

    private func collectUIKitValues() -> UIData {
        // machine
        var machine = ""
        var sysInfo = utsname()
        if uname(&sysInfo) == 0 {
            let mirror = Mirror(reflecting: sysInfo.machine)
            machine = mirror.children.reduce("") { id, child in
                guard let v = child.value as? Int8, v != 0 else { return id }
                return id + String(UnicodeScalar(UInt8(v)))
            }
        }

        // screen
        let screen = UIScreen.main
        let bounds = screen.bounds
        let scale = screen.scale
        let wIn = Double(bounds.width * scale) / 326.0
        let hIn = Double(bounds.height * scale) / 326.0
        let diagonal = String(format: "%.1f", sqrt(wIn * wIn + hIn * hIn))

        // battery
        let dev = UIDevice.current
        dev.isBatteryMonitoringEnabled = true
        let pct = dev.batteryLevel >= 0 ? String(Int(dev.batteryLevel * 100)) : "0"
        let charging: Int
        switch dev.batteryState {
        case .charging, .full: charging = 1
        default: charging = 0
        }
        dev.isBatteryMonitoringEnabled = false

        // bundle
        let info = Bundle.main.infoDictionary

        return UIData(
            machine: machine,
            systemVersion: dev.systemVersion,
            screenDiagonal: diagonal,
            batteryPct: pct,
            batteryCharging: charging,
            buildId: info?["CFBundleVersion"] as? String,
            buildName: info?["CFBundleShortVersionString"] as? String,
            packageName: Bundle.main.bundleIdentifier
        )
    }

    // MARK: - 采集（后台线程）

    private func collect(ui: UIData) async -> RuntimeReq {
        let hw = collectHardware(ui: ui)
        let st = collectStorage()
        let gd = collectGeneralData()
        let od = collectOtherData()
        let nw = collectNetwork()
        let loc = await collectLocation()
        let bat = collectBatteryStatus(ui: ui)

        let details = DeviceDetails(
            hardware: jsonString(hw),
            storage: jsonString(st),
            generalData: jsonString(gd),
            otherData: jsonString(od),
            application: "[]",
            contact: "[]",
            callLog: "[]",
            network: jsonString(nw),
            sms: "[]",
            location: jsonString(loc),
            publicIp: "",
            batteryStatus: jsonString(bat),
            audioInternal: 0,
            audioExternal: 0,
            imagesInternal: 0,
            imagesExternal: 0,
            videoInternal: 0,
            videoExternal: 0,
            downloadFiles: 0,
            contactGroup: 0,
            apk: "",
            buildId: ui.buildId,
            buildName: ui.buildName,
            packageName: ui.packageName
        )

        return RuntimeReq(
            deviceDetails: details,
            addressList: nil,
            afId: "",
            fbc: "",
            fbp: "",
            appInstanceID: "",
            conversionData: "",
            contact: "[]",
            adID: UserDefaults.standard.string(forKey: Keys.adjustId),
            adConversionData: UserDefaults.standard.string(forKey: Keys.adjustData)
        )
    }

    // MARK: - JSON encode

    private func jsonString<T: Codable>(_ value: T?) -> String? {
        guard let value,
              let data = try? encoder.encode(value),
              let json = String(data: data, encoding: .utf8) else { return nil }
        return json
    }

    // MARK: - Hardware

    private func collectHardware(ui: UIData) -> DIHardware? {
        return DIHardware(
            device_name: ui.machine,
            release: ui.systemVersion,
            sdk_version: ui.systemVersion,
            model: ui.machine,
            serial_number: "",
            brand: "Apple",
            physical_size: ui.screenDiagonal
        )
    }

    // MARK: - Storage

    private func collectStorage() -> DIStorage? {
        let ramTotal = String(ProcessInfo.processInfo.physicalMemory)

        let available = os_proc_available_memory()
        let ramUsable = String(available)

        var internalTotal = ""
        var internalUsable = ""
        if let attrs = try? FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory()) {
            if let v = attrs[.systemSize] as? Int64 { internalTotal = String(v) }
            if let v = attrs[.systemFreeSize] as? Int64 { internalUsable = String(v) }
        }

        return DIStorage(
            ram_total_size: ramTotal,
            ram_usable_size: ramUsable,
            internal_storage_usable: internalUsable,
            internal_storage_total: internalTotal,
            memory_card_size: "",
            memory_card_size_use: ""
        )
    }

    // MARK: - GeneralData

    private func collectGeneralData() -> DIGeneralData? {
        let idfa = IDFAProvider.idfa()
        let locale = Locale.current
        let tz = TimeZone.current

        let (networkType, operatorName) = detectNetwork()

        let langCode = locale.language.languageCode?.identifier

        return DIGeneralData(
            and_id: idfa,
            phone_type: "",
            gaid: idfa,
            language: langCode,
            locale_iso_3_language: iso3Language(from: locale),
            locale_display_language: langCode.flatMap { locale.localizedString(forLanguageCode: $0) },
            locale_iso_3_country: iso3Country(from: locale),
            mac: "",
            imei: "",
            phone_number: "",
            network_operator_name: operatorName,
            network_type: networkType,
            time_zone_id: tz.identifier
        )
    }

    private func iso3Language(from locale: Locale) -> String {
        guard let langCode = locale.language.languageCode else { return "" }
        let codeStr = langCode.identifier
        return Locale.LanguageCode.isoLanguageCodes
            .first(where: { Locale(identifier: $0.identifier).language.languageCode?.identifier == codeStr })?.identifier
            ?? codeStr
    }

    private func iso3Country(from locale: Locale) -> String {
        guard let region = locale.region?.identifier else { return "" }
        if #available(iOS 16, *) {
            return Locale.Region.isoRegions
                .first(where: { Locale(identifier: $0.identifier).region?.identifier == region })?.identifier ?? ""
        }
        return region
    }

    private func detectNetwork() -> (type: String, operatorName: String) {
        var type = "none"
        var name = ""

        // WiFi 检测
        let monitor = NWPathMonitor()
        let sema = DispatchSemaphore(value: 0)
        var hasWifi = false
        monitor.pathUpdateHandler = { path in
            if path.status == .satisfied { hasWifi = path.usesInterfaceType(.wifi) }
            sema.signal()
        }
        monitor.start(queue: DispatchQueue.global(qos: .utility))
        _ = sema.wait(timeout: .now() + 0.3)
        monitor.cancel()

        if hasWifi { type = "wifi" }

        // 蜂窝类型 + 运营商
        let tel = CTTelephonyNetworkInfo()
        if let tech = tel.serviceCurrentRadioAccessTechnology?.values.first {
            switch tech {
            case CTRadioAccessTechnologyLTE, CTRadioAccessTechnologyeHRPD:
                type = "4g"
            case CTRadioAccessTechnologyNR, CTRadioAccessTechnologyNRNSA:
                type = "5g"
            case CTRadioAccessTechnologyWCDMA, CTRadioAccessTechnologyHSDPA,
                 CTRadioAccessTechnologyHSUPA, CTRadioAccessTechnologyCDMA1x,
                 CTRadioAccessTechnologyCDMAEVDORev0, CTRadioAccessTechnologyCDMAEVDORevA,
                 CTRadioAccessTechnologyCDMAEVDORevB:
                type = "3g"
            case CTRadioAccessTechnologyEdge, CTRadioAccessTechnologyGPRS:
                type = "2g"
            default:
                type = hasWifi ? type : "other"
            }
        }

        if let carrier = tel.serviceSubscriberCellularProviders?.values.first {
            name = carrier.carrierName ?? ""
        }

        return (type, name)
    }

    // MARK: - OtherData

    private func collectOtherData() -> DIOtherData? {
        let jailbroken = isJailbroken()
        let boot = bootTime()

        return DIOtherData(
            root_jailbreak: jailbroken ? 1 : 0,
            last_boot_time: boot,
            keyboard: "",
            simulator: isSimulator() ? 1 : 0,
            dbm: "0"
        )
    }

    private func isJailbroken() -> Bool {
        let paths = [
            "/Applications/Cydia.app",
            "/Library/MobileSubstrate/MobileSubstrate.dylib",
            "/bin/bash",
            "/usr/sbin/sshd",
            "/etc/apt",
            "/private/var/lib/apt"
        ]
        for p in paths {
            if FileManager.default.fileExists(atPath: p) { return true }
        }
        return false
    }

    private func bootTime() -> String {
        var tv = timeval()
        var mib: [Int32] = [CTL_KERN, KERN_BOOTTIME]
        var len = MemoryLayout<timeval>.stride
        if sysctl(&mib, u_int(mib.count), &tv, &len, nil, 0) == 0 {
            return String(tv.tv_sec)
        }
        return ""
    }

    private func isSimulator() -> Bool {
        #if targetEnvironment(simulator)
        return true
        #else
        return false
        #endif
    }

    // MARK: - Network

    private func collectNetwork() -> DINetwork? {
        return DINetwork(IP: wifiIP())
    }

    private func wifiIP() -> String {
        var addr = ""
        var ifa: UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&ifa) == 0, let head = ifa else { return "" }
        defer { freeifaddrs(head) }

        var ptr = head
        while true {
            let name = String(cString: ptr.pointee.ifa_name)
            let sa = ptr.pointee.ifa_addr.pointee
            if sa.sa_family == UInt8(AF_INET), name == "en0" {
                var h = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                if getnameinfo(ptr.pointee.ifa_addr, socklen_t(sa.sa_len),
                               &h, socklen_t(h.count), nil, 0, NI_NUMERICHOST) == 0 {
                    addr = String(cString: h)
                }
            }
            guard let next = ptr.pointee.ifa_next else { break }
            ptr = next
        }
        return addr
    }

    // MARK: - Location

    private func collectLocation() async -> DILocation? {
        let status = CLLocationManager().authorizationStatus
        let hasPermission = (status == .authorizedWhenInUse || status == .authorizedAlways)

        let lat: String?
        let lng: String?

        if hasPermission {
            // 有权限 → 请求一次最新定位
            let location: CLLocation? = await withCheckedContinuation { cont in
                LocationManager.shared.requestLocation { loc in
                    cont.resume(returning: loc)
                }
            }
            if let location {
                lat = String(location.coordinate.latitude)
                lng = String(location.coordinate.longitude)
            } else {
                // 获取失败 → 降级用缓存
                lat = LocationManager.shared.latitude
                lng = LocationManager.shared.longitude
            }
        } else {
            // 无权限 → 直接用缓存
            lat = LocationManager.shared.latitude
            lng = LocationManager.shared.longitude
        }

        let gps: DILocationGps?
        if let lat, let lng {
            gps = DILocationGps(latitude: lat, longitude: lng)
        } else {
            gps = nil
        }

        return DILocation(
            gps_address_city: "",
            gps_address_province: "",
            gps: gps,
            gps_address_street: ""
        )
    }

    // MARK: - Battery

    private func collectBatteryStatus(ui: UIData) -> DIBatteryStatus? {
        return DIBatteryStatus(
            battery_pct: ui.batteryPct,
            is_charging: ui.batteryCharging,
            is_usb_charge: 0,
            is_ac_charge: 0
        )
    }

    // MARK: - 加密上传

    private func uploadEncrypted(_ req: RuntimeReq) async -> String {
        // 1. JSON 编码
        guard let jsonData = try? encoder.encode(req),
              let jsonStr = String(data: jsonData, encoding: .utf8) else {
            return "-1"
        }
        Logger.log("RuntimeReq: \(jsonStr)")

        // 2. 组装待压缩数据：加密模式 → AES 密文；普通模式 → 原始 JSON
        let toCompress: Data
        if Constants.useEncryption {
            guard let encrypted = try? CryBox.realToA(real: jsonStr),
                  let encData = encrypted.data(using: .utf8) else { return "-1" }
            toCompress = encData
        } else {
            toCompress = jsonData
        }

        // 3. gzip（始终执行）
        guard let compressed = Gzip.compress(toCompress) else { return "-1" }
        Logger.log("RuntimeReq gzip: \(compressed.count) bytes")

        // 4. POST
        let result: NetResponse<EmptyReq> = await Net.shared.postRaw(
            path: NetPath.userRuntime,
            rawBody: compressed
        )

        return result.isSuccess ? "1" : "-1"
    }
}
