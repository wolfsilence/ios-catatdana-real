import Foundation

// SurveyReq -> em
struct SurveyReq: Codable {
    var afid: String?
    var adid: String?
    var appInstanceID: String?
    var __logs__: [SurveyLog]?
}
