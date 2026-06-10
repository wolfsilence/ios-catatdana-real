import Foundation

// RecgFaceResp
struct RecgFaceResp: Codable {
    var conclusion: String?
    var similarity: Double?
    var livenessScore: Double?
}
