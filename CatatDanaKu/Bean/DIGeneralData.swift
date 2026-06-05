import Foundation

struct DIGeneralData: Codable {
    
    var and_id: String? // idfa
    var phone_type: String? // “”
    var gaid: String? // idfa
    
    /* 从Local获取
       * Locale locale = Locale.getDefault();
       */
      // Locale.getLanguage
    var language: String? //
    // Locale.getISO3Language
    var locale_iso_3_language: String?
    // Locale.getDisplayLanguage
    var locale_display_language: String?
    // Locale.getISO3Country
    var locale_iso_3_country: String?
    
    // mac地址
    var mac: String?
    
    var imei: String? // “”
    var phone_number: String? // sim卡的手机号码 拿不到就“”
    
    // 网络运营商名称，TelephonyManager.getNetworkOperatorName，不要用READ_PHONE_STATE权限
    var network_operator_name: String? //
    
    // 使用ConnectivityManager.activeNetworkInfo，不要用READ_PHONE_STATE权限
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
