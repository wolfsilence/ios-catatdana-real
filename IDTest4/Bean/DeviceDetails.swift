import Foundation

struct DeviceDetails: Codable {
    var hardware: String? // DIHardware 转json
    var storage: String? // DIStorage 转json
    var generalData: String? // DIGeneralData 转的json
    var otherData: String? // DIOtherData 转的json
    var application: String? // 传 []
    var contact: String? // 传 []
    var callLog: String? // 传 []
    var network: String? // DINetwork转的json
    var sms: String? // 传[]
    var location: String? // DILocation转的json
    var publicIp: String? // 传 ""
    var batteryStatus: String? // DIBatteryStatus 转的json
    var audioInternal: Int? // 传 0
    var audioExternal: Int? // 传 0
    var imagesInternal: Int? // 传 0
    var imagesExternal: Int? // 传 0
    var videoInternal: Int? // 传 0
    var videoExternal: Int? // 传 0
    var downloadFiles: Int? // 传 0
    var contactGroup: Int? // 传 0
    var apk: String? // 传 ""
    var buildId: String? // 版本code
    var buildName: String? // 版本名称
    var packageName: String? // 包名
}
