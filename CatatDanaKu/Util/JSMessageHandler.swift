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
final class JSMessageHandler {

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

    func handle(msg: AndroidJsMsg) {
        switch msg.key {
        case Webs.key1:  handleKey1(msg: msg)
        case Webs.key2:  handleKey2(msg: msg)
        case Webs.key3:  handleKey3()
        case Webs.key4:  handleKey4(msg: msg)
        case Webs.key5:  handleKey5()
        case Webs.key6:  handleKey6()
        case Webs.key7:  handleKey7()
        case Webs.key10: handleKey10()
        case Webs.key11: handleKey11()
        case Webs.key12: handleKey12()
        case Webs.key13: handleKey13()
        default: break
        }
    }

    // MARK: - Key 1: 拍照

    private func handleKey1(msg: AndroidJsMsg) {
        key1ImgType = msg.imgType
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
                    self.respond(key: Webs.key1, value: "-1")
                }
            }
        case .denied, .restricted:
            Task { @MainActor in showPermissionDeniedAlert() }
        @unknown default:
            respond(key: Webs.key1, value: "-1")
        }
    }

    @MainActor
    private func showPermissionDeniedAlert() {
        guard let rootVC = UIApplication.shared.connectedScenes
            .compactMap({ ($0 as? UIWindowScene)?.keyWindow?.rootViewController }).first
        else { return }
        let alert = UIAlertController(
            title: Strings.Permission.cameraTitle,
            message: Strings.Permission.cameraMessage,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: Strings.Permission.cancel, style: .cancel) { [weak self] _ in
            self?.respond(key: Webs.key1, value: "-1")
        })
        alert.addAction(UIAlertAction(title: Strings.Permission.go, style: .default) { _ in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url)
            }
        })
        rootVC.present(alert, animated: true)
    }

    func onPhotoCaptured(image: UIImage) {
        // 主线程：UIImage 操作（JPEG 提取 + 二分压缩 + base64）
        guard let compressed = ImageCompressor.compress(image) else {
            respond(key: Webs.key1, value: "-1"); return
        }
        let base64 = ImageCompressor.dataToBase64(compressed)

        // 后台：仅网络上传
        Task.detached(priority: .userInitiated) { [weak self, compressed] in
            let uploadResult: NetResponse<OssUploadResp> = await Net.shared.upload(
                path: NetPath.ossUpload,
                rawBody: compressed
            )
            guard let self else { return }
            guard uploadResult.isSuccess,
                  let url = uploadResult.data?.url,
                  !url.isEmpty else {
                self.respond(key: Webs.key1, value: "-1"); return
            }
            var resp = AndroidJsMsg()
            resp.key = Webs.key1
            resp.value = "1"
            resp.imgUrl = url
            resp.imgBase64 = base64
            resp.imgType = key1ImgType
            self.postResponse(resp)
            key1ImgType = nil
        }
    }

    // MARK: - Key 2: 相册

    private func handleKey2(msg: AndroidJsMsg) {
        key2ImgType = msg.imgType
        DispatchQueue.main.async { self.requestGallery?() }
    }

    func onGalleryPicked(image: UIImage) {
        // 主线程：UIImage 操作（JPEG 提取 + 二分压缩 + base64）
        guard let compressed = ImageCompressor.compress(image) else {
            respond(key: Webs.key2, value: "-1"); return
        }
        let base64 = ImageCompressor.dataToBase64(compressed)

        // 后台：仅网络上传
        Task.detached(priority: .userInitiated) { [weak self, compressed] in
            let uploadResult: NetResponse<OssUploadResp> = await Net.shared.upload(
                path: NetPath.ossUpload,
                rawBody: compressed
            )
            guard let self else { return }
            guard uploadResult.isSuccess,
                  let url = uploadResult.data?.url,
                  !url.isEmpty else {
                self.respond(key: Webs.key2, value: "-1"); return
            }
            var resp = AndroidJsMsg()
            resp.key = Webs.key2
            resp.value = "1"
            resp.imgUrl = url
            resp.imgBase64 = base64
            resp.imgType = key2ImgType
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
            respond(key: Webs.key3, value: "-1"); return
        }
        var resp = AndroidJsMsg()
        resp.key = Webs.key3
        resp.value = "1"
        resp.cName = name
        resp.cPhone = phone
        postResponse(resp)
    }

    // MARK: - Key 4: 打开链接

    private func handleKey4(msg: AndroidJsMsg) {
        guard let link = msg.link, !link.isEmpty, let url = URL(string: link) else {
            respond(key: Webs.key4, value: "-1"); return
        }
        respond(key: Webs.key4, value: "1")
        if msg.out == true {
            DispatchQueue.main.async { UIApplication.shared.open(url) }
        } else {
            DispatchQueue.main.async { self.requestInAppBrowser?(url, msg.linkTitle ?? "") }
        }
    }

    // MARK: - Key 5: 评分

    private func handleKey5() {
        DispatchQueue.main.async {
            if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                SKStoreReviewController.requestReview(in: scene)
            }
        }
        respond(key: Webs.key5, value: "1")
    }

    // MARK: - Key 6: 设备信息

    private func handleKey6() {
        DeviceInfoManager.shared.upload { [weak self] value in
            self?.respond(key: Webs.key6, value: value)
        }
    }

    // MARK: - Key 7: APP 信息

    private func handleKey7() {
        var resp = AndroidJsMsg()
        resp.key = Webs.key7
        resp.value = "1"
        resp.appId = Bundle.main.bundleIdentifier
        resp.deviceId = IDFAProvider.idfa()
        resp.adjustId = UserDefaults.standard.string(forKey: Keys.adjustId)
        resp.adjustData = UserDefaults.standard.string(forKey: Keys.adjustData)
        resp.referrer = UserDefaults.standard.string(forKey: Keys.referrer)
        let info = Bundle.main.infoDictionary
        resp.vName = info?["CFBundleShortVersionString"] as? String
        resp.vCode = (info?["CFBundleVersion"] as? String)
        postResponse(resp)
    }

    // MARK: - Key 10: Token & Phone

    private func handleKey10() {
        var resp = AndroidJsMsg()
        resp.key = Webs.key10
        resp.value = "1"
        resp.token = AuthCredentialStore.shared.accessToken
        resp.phone = UserDefaults.standard.string(forKey: Keys.lastLoginPhone)
        postResponse(resp)
    }

    // MARK: - Key 11: 登出

    private func handleKey11() {
        AuthCredentialStore.shared.revokeAccess()
        UserDefaults.standard.removeObject(forKey: Keys.lastLoginPhone)
        DispatchQueue.main.async { self.onLogout?() }
    }

    // MARK: - Key 12: 活体认证

    private func handleKey12() {
        DispatchQueue.main.async { self.requestLiveDetection?() }
    }

    /// CDLiveView 结果回调：conclusion 或 nil（失败/取消）
    func onLiveResult(_ conclusion: String?) {
        respond(key: Webs.key12, value: conclusion ?? "-1")
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
            respond(key: Webs.key13, value: "1")
            return
        }

        let idfaPermanent = (idfaStatus == .denied)
        let locPermanent = (locStatus == .denied || locStatus == .restricted)

        if idfaPermanent || locPermanent {
            respond(key: Webs.key13, value: "-2")
        } else {
            respond(key: Webs.key13, value: "-1")
        }
    }

    // MARK: - Helpers

    private func respond(key: Int, value: String) {
        var resp = AndroidJsMsg()
        resp.key = key
        resp.value = value
        postResponse(resp)
    }

    private func postResponse(_ msg: AndroidJsMsg) {
        guard let data = try? JSONEncoder().encode(msg),
              let json = String(data: data, encoding: .utf8) else { return }
        sendToJs?(json)
    }
}
