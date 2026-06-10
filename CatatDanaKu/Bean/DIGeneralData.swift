import Foundation

struct DIGeneralData: Codable {
    
    var and_id: String? // idfa
    var phone_type: String? // “”
    var gaid: String? // idfa

    var language: String? //

    var locale_iso_3_language: String?

    var locale_display_language: String?
   
    var locale_iso_3_country: String?
    
    // mac地址
    var mac: String?
    
    var imei: String? // “”
    var phone_number: String? // sim卡的手机号码 拿不到就“”
    
    // 网络运营商名称，
    var network_operator_name: String? //
    
    // 取值范围
    // "none" 表示 没有网络链接
    // "wifi" 表示 wifi链接
    // "2g" 表示 2G
    // "3g" 表示 3G
    // "4g" 表示 4G
    // "5g" 表示 5G
    // "other" 表示 其它
    var network_type: String?
    
    
    var time_zone_id: String?
   
}
