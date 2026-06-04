import Foundation

// ConfigKycResp
struct ConfigKycResp: Codable {
    var e: [KItem]      // 学历 (e)
    var g: [KItem]         // 性别 (g)
    var l: [KItem]    // 贷款用途 (l)
    var m: [KItem]  // 婚姻状况 (m)
    var no: [KItem]    // 职业 (no)
    var r: [KItem]       // 宗教 (r)
    var rt: [KItem]  // 关系 (rt)
}
