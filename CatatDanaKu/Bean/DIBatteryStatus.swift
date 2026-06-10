import Foundation

struct DIBatteryStatus: Codable {
    // 电池电量百分⽐(0-100)
    var battery_pct: String?
    
    // 是否正在充电（1：是，0:否）
    var is_charging: Int?
    
    // 是否usb充电（1：是，0:否）
    var is_usb_charge: Int?
    
    // 是否充电器充电（1：是，0:否）
    var is_ac_charge: Int?
}
