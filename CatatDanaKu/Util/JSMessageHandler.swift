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

/// H5 ↔ iOS 消息分发器
@MainActor
final class JSMessageHandler {

    var sendToJs: ((String) -> Void)?
    var requestCamera: (() -> Void)?
    var requestGallery: (() -> Void)?
    var requestContact: (() -> Void)?
    var requestInAppBrowser: ((URL, String) -> Void)?

    private var pendingMsg: AndroidJsMsg?
    private var locationManager: CLLocationManager?

    func handle(msg: AndroidJsMsg) {
        switch msg.key {
        case 1:  handleKey1(msg: msg)
        case 2:  handleKey2(msg: msg)
        case 3:  handleKey3(msg: msg)
        case 4:  handleKey4(msg: msg)
        case 5:  handleKey5()
        case 7:  handleKey7()
        case 10: handleKey10()
        case 13: handleKey13()
        default: break
        }
    }

    // MARK: - Key 1: 拍照

    private func handleKey1(msg: AndroidJsMsg) {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        switch status {
        case .authorized:
            pendingMsg = msg
            requestCamera?()
        case .notDetermined:
            Task {
                let granted = await AVCaptureDevice.requestAccess(for: .video)
                await MainActor.run {
                    if granted {
                        self.pendingMsg = msg
                        self.requestCamera?()
                    } else {
                        self.respond(key: 1, value: "-1")
                    }
                }
            }
        case .denied, .restricted:
            showPermissionDeniedAlert()
        @unknown default:
            respond(key: 1, value: "-1")
        }
    }

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
            self?.respond(key: 1, value: "-1")
        })
        alert.addAction(UIAlertAction(title: Strings.Permission.go, style: .default) { _ in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url)
            }
        })
        rootVC.present(alert, animated: true)
    }

    func onPhotoCaptured(image: UIImage) async {
        guard let msg = pendingMsg else { return }
        pendingMsg = nil
        let imgType = msg.imgType

        let result: (url: String?, base64: String?) = await Task.detached(priority: .userInitiated) {
            guard let raw = image.jpegData(compressionQuality: 1.0) else { return (nil, nil) }
            let compressed = ImageCompressor.compress(raw)
            let base64 = ImageCompressor.dataToBase64(compressed)
            let upload: NetResponse<OssUploadResp> = await Net.shared.upload(path: NetPath.ossUpload, rawBody: compressed)
            if upload.isSuccess, let url = upload.data?.url, !url.isEmpty {
                return (url, base64)
            }
            return (nil, nil)
        }.value

        guard let url = result.url, let base64 = result.base64 else {
            respond(key: 1, value: "-1"); return
        }
        var resp = AndroidJsMsg()
        resp.key = 1
        resp.value = "1"
        resp.imgUrl = url
        resp.imgBase64 = base64
        resp.imgType = imgType
        postResponse(resp)
    }

    // MARK: - Key 2: 相册

    private func handleKey2(msg: AndroidJsMsg) {
        pendingMsg = msg
        requestGallery?()
    }

    func onGalleryPicked(image: UIImage) async {
        guard let msg = pendingMsg else { return }
        pendingMsg = nil
        let imgType = msg.imgType

        let result: (url: String?, base64: String?) = await Task.detached(priority: .userInitiated) {
            guard let raw = image.jpegData(compressionQuality: 1.0) else { return (nil, nil) }
            let compressed = ImageCompressor.compress(raw)
            let base64 = ImageCompressor.dataToBase64(compressed)
            let upload: NetResponse<OssUploadResp> = await Net.shared.upload(path: NetPath.ossUpload, rawBody: compressed)
            if upload.isSuccess, let url = upload.data?.url, !url.isEmpty {
                return (url, base64)
            }
            return (nil, nil)
        }.value

        guard let url = result.url, let base64 = result.base64 else {
            respond(key: 2, value: "-1"); return
        }
        var resp = AndroidJsMsg()
        resp.key = 2
        resp.value = "1"
        resp.imgUrl = url
        resp.imgBase64 = base64
        resp.imgType = imgType
        postResponse(resp)
    }

    // MARK: - Key 3: 联系人

    private func handleKey3(msg: AndroidJsMsg) {
        pendingMsg = msg
        requestContact?()
    }

    func onContactPicked(name: String?, phone: String?) {
        guard let name, let phone, !phone.isEmpty else {
            respond(key: 3, value: "-1"); return
        }
        var resp = AndroidJsMsg()
        resp.key = 3
        resp.value = "1"
        resp.cName = name
        resp.cPhone = phone
        postResponse(resp)
    }

    // MARK: - Key 4: 打开链接

    private func handleKey4(msg: AndroidJsMsg) {
        guard let link = msg.link, !link.isEmpty, let url = URL(string: link) else {
            respond(key: 4, value: "-1"); return
        }
        respond(key: 4, value: "1")  // 先通知成功
        if msg.out == true {
            UIApplication.shared.open(url)
        } else {
            requestInAppBrowser?(url, msg.linkTitle ?? "")
        }
    }

    // MARK: - Key 5: 评分

    private func handleKey5() {
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: scene)
        }
        respond(key: 5, value: "1")
    }

    // MARK: - Key 7: APP 信息

    private func handleKey7() {
        var resp = AndroidJsMsg()
        resp.key = 7
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
        resp.key = 10
        resp.value = "1"
        resp.token = AuthCredentialStore.shared.accessToken
        resp.phone = UserDefaults.standard.string(forKey: Keys.lastLoginPhone)
        postResponse(resp)
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
            respond(key: 13, value: "1")
            return
        }

        let idfaPermanent = (idfaStatus == .denied)
        let locPermanent = (locStatus == .denied || locStatus == .restricted)

        if idfaPermanent || locPermanent {
            respond(key: 13, value: "-2")
        } else {
            respond(key: 13, value: "-1")
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
