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

    private init() {}

    // MARK: - Public

    func upload(completion: @escaping (String) -> Void) {
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
                let result = await self.uploadEncrypted(req)

                completion(result)
            }
        }
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
        dev.isBatteryMonitoringEnabled = true

        let pct = dev.batteryLevel >= 0 ? String(Int(dev.batteryLevel * 100)) : "0"
        let charging = (dev.batteryState == .charging || dev.batteryState == .full) ? 1 : 0

        dev.isBatteryMonitoringEnabled = false

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

    private func collect(ui: UIData) async -> RuntimeReq {
        let details = DeviceDetails(
            hardware: jsonString(collectHardware(ui: ui)),
            storage: jsonString(collectStorage()),
            generalData: jsonString(await collectGeneralData()),
            otherData: jsonString(collectOtherData()),
            application: "[]",
            contact: "[]",
            callLog: "[]",
            network: jsonString(collectNetwork()),
            sms: "[]",
            location: jsonString(await collectLocation()),
            publicIp: "",
            batteryStatus: jsonString(collectBatteryStatus(ui: ui)),
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

    // MARK: - JSON

    private func jsonString<T: Codable>(_ value: T?) -> String? {
        guard let value,
              let data = try? encoder.encode(value) else { return nil }
        return String(data: data, encoding: .utf8)
    }

    // MARK: - Hardware

    private func collectHardware(ui: UIData) -> DIHardware {
        DIHardware(
            device_name: ui.machine,
            release: ui.systemVersion,
            sdk_version: ui.systemVersion,
            model: ui.machine,
            serial_number: "",
            brand: "Apple",
            physical_size: ui.resolution
        )
    }

    // MARK: - Storage

    private func collectStorage() -> DIStorage {
        let ramTotal = String(ProcessInfo.processInfo.physicalMemory)

        var internalTotal = ""
        var internalUsable = ""

        if let attrs = try? FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory()) {
            if let v = attrs[.systemSize] as? Int64 { internalTotal = String(v) }
            if let v = attrs[.systemFreeSize] as? Int64 { internalUsable = String(v) }
        }

        return DIStorage(
            ram_total_size: ramTotal,
            ram_usable_size: "",
            internal_storage_usable: internalUsable,
            internal_storage_total: internalTotal,
            memory_card_size: "",
            memory_card_size_use: ""
        )
    }

    // MARK: - General

    private func collectGeneralData() async -> DIGeneralData {
        let locale = Locale.current
        let tz = TimeZone.current
        let langCode = locale.language.languageCode?.identifier

        let (type, name) = await detectNetwork()

        return DIGeneralData(
            and_id: IDFAProvider.idfa(),
            phone_type: "",
            gaid: IDFAProvider.idfa(),
            language: langCode,
            locale_iso_3_language: iso3Language(from: locale),
            locale_display_language: langCode.flatMap { locale.localizedString(forLanguageCode: $0) },
            locale_iso_3_country: iso3Country(from: locale),
            mac: "",
            imei: "",
            phone_number: "",
            network_operator_name: name,
            network_type: type,
            time_zone_id: tz.identifier
        )
    }

    private func iso3Language(from locale: Locale) -> String {
        guard let langCode = locale.language.languageCode else { return "" }
        let id = langCode.identifier
        return Locale.LanguageCode.isoLanguageCodes
            .first(where: { Locale(identifier: $0.identifier).language.languageCode?.identifier == id })?.identifier
            ?? id
    }

    private func iso3Country(from locale: Locale) -> String {
        guard let regionCode = locale.region?.identifier else { return "" }
        return Locale.Region.isoRegions
            .first(where: { Locale(identifier: $0.identifier).region?.identifier == regionCode })?.identifier
            ?? regionCode
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
                    type = "other"
                }
            }
        }

        let tel = CTTelephonyNetworkInfo()
        let carrier = tel.serviceSubscriberCellularProviders?.values.first?.carrierName ?? ""

        return (type, carrier)
    }

    // MARK: - Other

    private func collectOtherData() -> DIOtherData {
        DIOtherData(
            root_jailbreak: isJailbroken() ? 1 : 0,
            last_boot_time: bootTime(),
            keyboard: "",
            simulator: isSimulator() ? 1 : 0,
            dbm: "0"
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
            "/bin/bash",
            "/usr/sbin/sshd",
            "/etc/apt",
            "/private/var/lib/apt",
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

    private func collectNetwork() -> DINetwork {
        DINetwork(IP: wifiIP())
    }

    private func wifiIP() -> String {
        var addr = ""
        var ifa: UnsafeMutablePointer<ifaddrs>?

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

    private func collectLocation() async -> DILocation {
        let lat = LocationManager.shared.latitude
        let lng = LocationManager.shared.longitude

        let gps: DILocationGps?
        if let lat, let lng {
            gps = DILocationGps(latitude: lat, longitude: lng)
        } else {
            gps = DILocationGps()
        }

        return DILocation(
            gps_address_city: "",
            gps_address_province: "",
            gps: gps,
            gps_address_street: ""
        )
    }

    // MARK: - Battery

    private func collectBatteryStatus(ui: UIData) -> DIBatteryStatus {
        DIBatteryStatus(
            battery_pct: ui.batteryPct,
            is_charging: ui.batteryCharging,
            is_usb_charge: 0,
            is_ac_charge: 0
        )
    }

    // MARK: - Upload

    private func uploadEncrypted(_ req: RuntimeReq) async -> String {
        guard let jsonData = try? encoder.encode(req) else { return "-1" }
//        Logger.log("DI-INFO: \(String(data: jsonData, encoding: .utf8) ?? "nil")")
        let toCompress: Data
        if Constants.useEncryption {
            guard let jsonStr = String(data: jsonData, encoding: .utf8),
                  let encrypted = try? CryBox.realToA(real: jsonStr),
                  let data = encrypted.data(using: .utf8) else { return "-1" }
            toCompress = data
        } else {
            toCompress = jsonData
        }
        let compressed = try! toCompress.gzipped()
        let result: NetResponse<EmptyResp> = await Net.shared.postGzip(
            path: NetPath.userRuntime,
            gzipedBody: compressed
        )
        return result.isSuccess ? "1" : "-1"
    }
}
