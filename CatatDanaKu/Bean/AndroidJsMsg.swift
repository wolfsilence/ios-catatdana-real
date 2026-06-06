import Foundation

// AndroidJsMsg
struct AndroidJsMsg: Codable {
    var key: Int?
    var token: String?
    var imgType: String?
    var uploadUrl: String?
    var link: String?
    var linkTitle: String?
    var permissionsGuide: Int?
    var out: Bool?
    var vName: String?
    var vCode: String?
    var deviceId: String?
    var adjustId: String?
    var adjustData: String?
    var conversionData: String?
    var afid: String?
    var appId: String?
    var referrer: String?
    var phone: String?
    var imgUrl: String?
    var imgBase64: String?
    var cName: String?
    var cPhone: String?
    var value: String?
    var logs: [String]?
    var livenessId: String?
    var livenessImg: String?
}
