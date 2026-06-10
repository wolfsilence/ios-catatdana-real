import Foundation

struct RuntimeReq: Codable {
    var deviceDetails: DeviceDetails?
    var addressList: [EmptyReq]? // 不传
    var afId: String? // 本地存的 AF 的id
    var fbc: String? // 不传
    var fbp: String? // 不传
    var appInstanceID: String? // firebase instanceid
    var conversionData: String? // af conversionData
    var contact: String? // 传 []
    var adID: String? // adjustId
    var adConversionData: String? // adjust attr 的json
}
