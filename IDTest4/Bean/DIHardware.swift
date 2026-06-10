import Foundation

struct DIHardware: Codable {
    var device_name: String? //  设备名称，用Build.DEVICE赋值
    var release: String?   // 系统版本，用Build.VERSION.RELEASE赋值
    var sdk_version: String? // SDK版本，用Build.VERSION.SDK_INT.toString()赋值
    var model: String?  // 设备型号，用Build.MODEL赋值
    var serial_number: String? // 写“”
    var brand: String? // 写 Apple
    var physical_size: String? //
}
