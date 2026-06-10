import Foundation

struct DILocation: Codable {
    var gps_address_city: String? // 写 ”“
    var gps_address_province: String? // 写 ”“
    var gps: DILocationGps?
    var gps_address_street: String? // 写”“
}
