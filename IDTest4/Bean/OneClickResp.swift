import Foundation

// OneClickResp
struct OneClickResp: Codable {
    var token: String?
    var sendVcode: Bool?
    var redirectUrl: String?
    var loginGuide: Int?
    var isPlatformNew: Bool?
}
