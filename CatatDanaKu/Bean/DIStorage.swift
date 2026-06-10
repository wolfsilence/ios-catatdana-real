import Foundation

struct DIStorage: Codable {
    var ram_total_size: String? //
    var ram_usable_size: String? //
    

    var internal_storage_usable: String?    // 内部存储可用空间(单位byte)
    var internal_storage_total: String? // 内部存储总空间(单位byte)
    
    
    
    var memory_card_size: String? // 外部存储总空间(单位byte)
    var memory_card_size_use: String? //外部存储已用空间(单位byte)
}
