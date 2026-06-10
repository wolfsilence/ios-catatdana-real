import CoreLocation

//
//  LocationManager.swift
//  CatatDanaKu
//
//  Created by lishen on 2026/6/5.
//

/// 定位管理（单例）—— 请求权限、获取坐标、持久化
final class LocationManager: NSObject, CLLocationManagerDelegate {
    static let shared = LocationManager()

    private let manager = CLLocationManager()
    private var completion: ((CLLocation?) -> Void)?

    private override init() {
        super.init()
        manager.delegate = self
    }

    // MARK: - Public

    /// 已存储的纬度（字符串，与后端字段一致）
    var latitude: String? {
        UserDefaults.standard.string(forKey: Keys.locationLat)
    }

    /// 已存储的经度（字符串，与后端字段一致）
    var longitude: String? {
        UserDefaults.standard.string(forKey: Keys.locationLng)
    }

    /// 请求定位权限并获取坐标，完成后回调
    func requestLocation(completion: @escaping (CLLocation?) -> Void) {
        self.completion = completion

        let status = manager.authorizationStatus
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            manager.requestLocation()
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .denied, .restricted:
            completion(nil)
        @unknown default:
            completion(nil)
        }
    }

    // MARK: - CLLocationManagerDelegate

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            manager.requestLocation()
        case .denied, .restricted:
            completion?(nil)
            completion = nil
        default:
            break
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else {
            completion?(nil)
            completion = nil
            return
        }
        UserDefaults.standard.set(String(location.coordinate.latitude), forKey: Keys.locationLat)
        UserDefaults.standard.set(String(location.coordinate.longitude), forKey: Keys.locationLng)
        completion?(location)
        completion = nil
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Logger.log("LocationManager error: \(error.localizedDescription)")
        completion?(nil)
        completion = nil
    }
}
