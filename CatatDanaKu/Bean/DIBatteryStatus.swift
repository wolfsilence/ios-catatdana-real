import Foundation

struct DIBatteryStatus: Codable {
    
    // 获取方法
    // 获取方法
    //   Intent batteryBroadcast = mContext.getApplicationContext()
    //    .registerReceiver(null,new IntentFilter(Intent.ACTION_BATTERY_CHANGED));
    //   int chargePlug = batteryBroadcast.getIntExtra(BatteryManager.EXTRA_PLUGGED, -1);
    //   BatteryManager batteryManager = (BatteryManager) mContext.getApplicationContext()
    //    .getSystemService(BATTERY_SERVICE);
    
    // 电池电量百分⽐(0-100)
    // batteryManager.getIntProperty(BatteryManager.BATTERY_PROPERTY_CAPACITY)
    var battery_pct: String?
    
    // 是否正在充电（1：是，0:否）
    var is_charging: Int?
    
    // 是否usb充电（1：是，0:否）
    var is_usb_charge: Int?
    
    // 是否充电器充电（1：是，0:否）
    var is_ac_charge: Int?
}
