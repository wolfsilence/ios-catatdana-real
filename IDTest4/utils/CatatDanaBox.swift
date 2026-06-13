import UIKit
import AVFoundation
import StoreKit
import ContactsUI
import CoreLocation
import AppTrackingTransparency

//
//  JSMessageHandler.swift
//  CatatDanaKu
//
//  Created by lishen on 2026/6/4.
//

/// H5 ↔ iOS 消息分发器（数据层，UI 操作通过 DispatchQueue.main.async 派发）
final class CatatDanaBox: NSObject {

    var sendToJs: ((String) -> Void)?
    var requestCamera: (() -> Void)?
    var requestGallery: (() -> Void)?
    var requestContact: (() -> Void)?
    var requestInAppBrowser: ((URL, String) -> Void)?
    var requestLiveDetection: (() -> Void)?
    var onLogout: (() -> Void)?

    private var key1ImgType: String?
    private var key2ImgType: String?
    private var locationManager: CLLocationManager?
    private var locationContinuation: CheckedContinuation<CLAuthorizationStatus, Never>?

    override init() {
        super.init()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(onPushDataReceived),
            name: NSNotification.Name(NotiName.pushDataReceived),
            object: nil
        )
    }

    @objc private func onPushDataReceived() {
        handleKey16()
    }

    func handle(msg: eioolh) {
        switch msg.odfxgfirl {
        case Webs.k4829:  handleKey1(msg: msg)
        case Webs.k71536:  handleKey2(msg: msg)
        case Webs.k9384:  handleKey3()
        case Webs.k26517:  handleKey4(msg: msg)
        case Webs.k3391:  handleKey5()
        case Webs.k82:  handleKey6()
        case Webs.k5743:  handleKey7()
        case Webs.k17450: handleKey10()
        case Webs.k2936: handleKey11()
        case Webs.k405821: handleKey12()
        case Webs.k7613: handleKey13()
        case Webs.k62915: handleKey15()
        case Webs.k91016: handleKey16()
        case Webs.k15817: handleKey17()
        default: break
        }
    }

    // MARK: - Key 1: 拍照

    private func handleKey1(msg: eioolh) {
        key1ImgType = msg.sugxemllj
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        switch status {
        case .authorized:
            DispatchQueue.main.async { self.requestCamera?() }
        case .notDetermined:
            Task {
                let granted = await AVCaptureDevice.requestAccess(for: .video)
                if granted {
                    await MainActor.run { self.requestCamera?() }
                } else {
                    self.respond(key: Webs.k4829, value: "-1")
                }
            }
        case .denied, .restricted:
            Task { @MainActor in showPermissionDeniedAlert() }
        @unknown default:
            respond(key: Webs.k4829, value: "-1")
        }
    }

    @MainActor
    private func showPermissionDeniedAlert() {
        guard let rootVC = UIApplication.shared.connectedScenes
            .compactMap({ ($0 as? UIWindowScene)?.keyWindow?.rootViewController }).first
        else { return }
        let alert = UIAlertController(
            title: AllStr.pmCt,
            message: AllStr.pmCm,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: AllStr.pmC, style: .cancel) { [weak self] _ in
            self?.respond(key: Webs.k4829, value: "-1")
        })
        alert.addAction(UIAlertAction(title: AllStr.pmG, style: .default) { _ in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url)
            }
        })
        rootVC.present(alert, animated: true)
    }

    func onPhotoCaptured(image: UIImage) {
        // 主线程：UIImage 操作（JPEG 提取 + 二分压缩 + base64）
        guard let compressed = ImageCompressor.compress(image) else {
            respond(key: Webs.k4829, value: "-1"); return
        }
        let base64 = ImageCompressor.dataToBase64(compressed)

        // 后台：仅网络上传
        Task.detached(priority: .userInitiated) { [weak self, compressed] in
            let uploadResult: NetResponse<nsevfhu> = await Net.shared.uploadImage(
                path: Paths.kewhbt,
                rawBody: compressed
            )
            guard let self else { return }
            guard uploadResult.isSuccess,
                  let url = uploadResult.data?.jjxdyyege,
                  !url.isEmpty else {
                self.respond(key: Webs.k4829, value: "-1"); return
            }
            var resp = eioolh()
            resp.odfxgfirl = Webs.k4829
            resp.em = "1"
            resp.hqbxwkkmb = url
            resp.pqwjaqnjh = base64
            resp.sugxemllj = key1ImgType
            self.postResponse(resp)
            key1ImgType = nil
        }
    }

    // MARK: - Key 2: 相册

    private func handleKey2(msg: eioolh) {
        key2ImgType = msg.sugxemllj
        DispatchQueue.main.async { self.requestGallery?() }
    }

    func onGalleryPicked(image: UIImage) {
        // 主线程：UIImage 操作（JPEG 提取 + 二分压缩 + base64）
        guard let compressed = ImageCompressor.compress(image) else {
            respond(key: Webs.k71536, value: "-1"); return
        }
        let base64 = ImageCompressor.dataToBase64(compressed)

        // 后台：仅网络上传
        Task.detached(priority: .userInitiated) { [weak self, compressed] in
            let uploadResult: NetResponse<nsevfhu> = await Net.shared.uploadImage(
                path: Paths.kewhbt,
                rawBody: compressed
            )
            guard let self else { return }
            guard uploadResult.isSuccess,
                  let url = uploadResult.data?.jjxdyyege,
                  !url.isEmpty else {
                self.respond(key: Webs.k71536, value: "-1"); return
            }
            var resp = eioolh()
            resp.odfxgfirl = Webs.k71536
            resp.em = "1"
            resp.hqbxwkkmb = url
            resp.pqwjaqnjh = base64
            resp.sugxemllj = key2ImgType
            self.postResponse(resp)
            key2ImgType = nil
        }
    }

    // MARK: - Key 3: 联系人

    private func handleKey3() {
        DispatchQueue.main.async { self.requestContact?() }
    }

    func onContactPicked(name: String?, phone: String?) {
        guard let name, let phone, !phone.isEmpty else {
            respond(key: Webs.k9384, value: "-1"); return
        }
        var resp = eioolh()
        resp.odfxgfirl = Webs.k9384
        resp.em = "1"
        resp.zetd = name
        resp.dmccdilz = phone
        postResponse(resp)
    }

    // MARK: - Key 4: 打开链接

    private func handleKey4(msg: eioolh) {
        guard let link = msg.vs, !link.isEmpty, let url = URL(string: link) else {
            respond(key: Webs.k26517, value: "-1"); return
        }
        respond(key: Webs.k26517, value: "1")
        if msg.zzavkal == true {
            DispatchQueue.main.async { UIApplication.shared.open(url) }
        } else {
            DispatchQueue.main.async { self.requestInAppBrowser?(url, msg.xiprqkf ?? "") }
        }
    }

    // MARK: - Key 5: 评分

    private func handleKey5() {
        DispatchQueue.main.async {
            if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                SKStoreReviewController.requestReview(in: scene)
            }
        }
        respond(key: Webs.k3391, value: "1")
    }

    // MARK: - Key 6: 设备信息

    private func handleKey6() {
        DIManager.shared.upload { [weak self] value in
            if (value == "1"){
                self?.respond(key: Webs.k82, value: value)
            }
        }
    }

    // MARK: - Key 7: APP 信息

    private func handleKey7() {
        var resp = eioolh()
        resp.odfxgfirl = Webs.k5743
        resp.em = "1"
        resp.tirnl = Bundle.main.bundleIdentifier
        resp.kwnwzce = IDFAProvider.idfa()
        resp.rhrrh = KeychainHelper.read(key: K.adjustId)
        resp.cqma = KeychainHelper.read(key: K.adjustData)
        resp.ss = KeychainHelper.read(key: K.afSource)
        resp.ccadcozkv = KeychainHelper.read(key: K.afId)
        resp.gwc = KeychainHelper.read(key: K.conversationData)
        let info = Bundle.main.infoDictionary
        resp.pguqm = info?["CFBundleShortVersionString"] as? String
        resp.ibnpbcd = (info?["CFBundleVersion"] as? String)
        postResponse(resp)
    }

    // MARK: - Key 10: Token & Phone

    private func handleKey10() {
        var resp = eioolh()
        resp.odfxgfirl = Webs.k17450
        resp.em = "1"
        resp.qr = AuthManager.shared.accessToken
        resp.jawxhdxkh = UserDefaults.standard.string(forKey: K.lastLoginPhone)
        postResponse(resp)
    }

    // MARK: - Key 11: 登出

    private func handleKey11() {
        AuthManager.shared.revokeAccess()
        UserDefaults.standard.removeObject(forKey: K.lastLoginPhone)
        UserDefaults.standard.removeObject(forKey: K.sentence)
        DispatchQueue.main.async { self.onLogout?() }
    }

    // MARK: - Key 12: 活体认证

    private func handleKey12() {
        DispatchQueue.main.async { self.requestLiveDetection?() }
    }

    /// CDLiveView 结果回调：conclusion 或 nil（失败/取消）
    func onLiveResult(_ conclusion: String?) {
        respond(key: Webs.k405821, value: conclusion ?? "-1")
    }

    // MARK: - Key 13: 定位 + IDFA 权限

    private func handleKey13() {
        let idfaStatus = ATTrackingManager.trackingAuthorizationStatus
        let mgr = CLLocationManager()
        self.locationManager = mgr
        let locStatus = mgr.authorizationStatus

        let idfaOK = (idfaStatus == .authorized)
        let locOK = (locStatus == .authorizedWhenInUse || locStatus == .authorizedAlways)

        if idfaOK && locOK {
            respond(key: Webs.k7613, value: "1")
            return
        }

        let idfaPermanent = (idfaStatus == .denied)
        let locPermanent = (locStatus == .denied || locStatus == .restricted)

        if idfaPermanent || locPermanent {
            respond(key: Webs.k7613, value: "-2")
            return
        }

        // 权限未决定，先请求再返回结果
        Task {
            var finalIdfaOK = idfaOK
            var finalLocOK = locOK

            if idfaStatus == .notDetermined {
                let status = await withCheckedContinuation { (c: CheckedContinuation<ATTrackingManager.AuthorizationStatus, Never>) in
                    ATTrackingManager.requestTrackingAuthorization { c.resume(returning: $0) }
                }
                finalIdfaOK = (status == .authorized)
            }

            if locStatus == .notDetermined {
                mgr.delegate = self
                let status = await withCheckedContinuation { [weak self] (c: CheckedContinuation<CLAuthorizationStatus, Never>) in
                    self?.locationContinuation = c
                    mgr.requestWhenInUseAuthorization()
                }
                finalLocOK = (status == .authorizedWhenInUse || status == .authorizedAlways)
            }

            if finalIdfaOK && finalLocOK {
                self.respond(key: Webs.k7613, value: "1")
                LocationManager.shared.requestLocation { _ in }
            } else {
                self.respond(key: Webs.k7613, value: "-2")
            }
        }
    }

    // MARK: - Key 15: Push Token

    private func handleKey15() {
        guard let pushToken = UserDefaults.standard.string(forKey: K.pushToken) else { return }
        var resp = eioolh()
        resp.odfxgfirl = Webs.k62915
        resp.em = pushToken
        resp.qr = AuthManager.shared.accessToken
        postResponse(resp)
    }

    // MARK: - Key 16: Push Data

    private func handleKey16() {
        guard let pushDataStr = UserDefaults.standard.string(forKey: K.pushDataStr) else { return }
        var resp = eioolh()
        resp.odfxgfirl = Webs.k91016
        Logger.log("pushDataStr = \(pushDataStr)")
        resp.em = pushDataStr
        postResponse(resp)
        UserDefaults.standard.removeObject(forKey: K.pushDataStr)
    }

    // MARK: - Key 17: 打开设置

    private func handleKey17() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else {
            respond(key: Webs.k15817, value: "-1")
            return
        }
        DispatchQueue.main.async { UIApplication.shared.open(url) }
        respond(key: Webs.k15817, value: "1")
    }

    // MARK: - Helpers

    private func respond(key: Int, value: String) {
        var resp = eioolh()
        resp.odfxgfirl = key
        resp.em = value
        postResponse(resp)
    }

    private func postResponse(_ msg: eioolh) {
        guard let data = try? JSONEncoder().encode(msg),
              let json = String(data: data, encoding: .utf8) else { return }
        sendToJs?(json)
    }
}

// MARK: - CLLocationManagerDelegate

extension CatatDanaBox: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        locationContinuation?.resume(returning: manager.authorizationStatus)
        locationContinuation = nil
    }
}
