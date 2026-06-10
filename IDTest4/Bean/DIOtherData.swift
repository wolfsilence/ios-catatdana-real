import Foundation

struct DIOtherData: Codable {
    var root_jailbreak: Int? // 是否越狱
    var last_boot_time: String? // 上次手机启动时间
    var keyboard: String? // 传“”
    var simulator: Int? // 是否是模拟器
    var dbm: String? // 传 “0”
}
