import Foundation

// OneClickReq
struct OneClickReq: Codable {
    var app: String?
    var phone: String?
    var intlCode: String?
    var deviceId: String?
    var vcodeMethod: Int?
    var latitude: String?
    var longitude: String?
    var referrer: String?
    var country: String?
    var sign: String?
    var conversionData: String?
}
