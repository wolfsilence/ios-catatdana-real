import SwiftUI
import WebKit
import PhotosUI
import ContactsUI
import AppsFlyerLib

//
//  CDRedView.swift
//  CatatDanaKu
//
//  Created by lishen on 2026/6/4.
//

/// 全屏 WebView，H5 ↔ iOS 双向通信（从本地 Keys.redirectUrl 读取 URL）
struct CDRedView: View {
    var onLogout: (() -> Void)?
    
    @State private var showCamera = false
    @State private var showGallery = false
    @State private var showContact = false
    @State private var showLiveDetection = false
    @State private var browserConfig: BrowserConfig?
    @State private var isFirstLoading = true
    private let handler = CatatDanaBox()
    
    private var redirectURL: URL? {
        guard let str = UserDefaults.standard.string(forKey: K.sentence),
              !str.isEmpty, let url = URL(string: str) else { return nil }
        return url
    }
    
    var body: some View {
        Group {
            if let url = redirectURL {
                RedWebViewWrapper(
                    url: url,
                    handler: handler,
                    showCamera: $showCamera,
                    showGallery: $showGallery,
                    showContact: $showContact,
                    isFirstLoading: $isFirstLoading,
                    onLogout: onLogout,
                    onInAppBrowser: { url, title in
                        browserConfig = BrowserConfig(url: url, title: title)
                    },
                    onLiveDetection: { showLiveDetection = true }
                )
                .overlay {
                    if isFirstLoading {
                        Color.black.opacity(0.15)
                            .ignoresSafeArea()
                        ProgressView()
                    }
                }
                .ignoresSafeArea()
            }
        }
        .onAppear {
            LocationManager.shared.requestLocation { _ in }
        }
        .fullScreenCover(isPresented: $showCamera) {
            CameraPicker { image in
                handler.onPhotoCaptured(image: image)
            }
        }
        .fullScreenCover(isPresented: $showGallery) {
            GalleryPicker { image in
                handler.onGalleryPicked(image: image)
            }
        }
        .sheet(isPresented: $showContact) {
            ContactPicker { name, phone in
                handler.onContactPicked(name: name, phone: phone)
            }
        }
        .fullScreenCover(item: $browserConfig) { config in
            CDWebView(url: config.url, title: config.title)
        }
        .fullScreenCover(isPresented: $showLiveDetection) {
            if let url = URL(string: Consts.slUrl) {
                CDLiveView(url: url) { conclusion in
                    handler.onLiveResult(conclusion)
                }
            }
        }
    }
    
    // MARK: - RedWebView Wrapper
    
    private struct RedWebViewWrapper: UIViewRepresentable {
        let url: URL
        let handler: CatatDanaBox
        @Binding var showCamera: Bool
        @Binding var showGallery: Bool
        @Binding var showContact: Bool
        @Binding var isFirstLoading: Bool
        var onLogout: (() -> Void)?
        var onInAppBrowser: ((URL, String) -> Void)?
        var onLiveDetection: (() -> Void)?
        
        func makeCoordinator() -> Coordinator {
            Coordinator(parent: self)
        }
        
        func makeUIView(context: Context) -> WKWebView {
            let config = WKWebViewConfiguration()
            let controller = WKUserContentController()
            
            // 注入 JS 桥接：H5 调用 window.Android.callAndroid(json) → WKWebView
            let userScript = WKUserScript(source: Red.bridgeScript,
                                          injectionTime: .atDocumentStart,
                                          forMainFrameOnly: false)
            controller.addUserScript(userScript)
            controller.add(context.coordinator, name: Red.bridgeName)
            controller.add(context.coordinator, name: Red.consoleLog)
            config.userContentController = controller
            
            let webView = WKWebView(frame: .zero, configuration: config)
            webView.navigationDelegate = context.coordinator
            context.coordinator.setupBridge(webView: webView)
            webView.load(URLRequest(url: url))
            return webView
        }
        
        func updateUIView(_ uiView: WKWebView, context: Context) {}
        
        final class Coordinator: NSObject, WKNavigationDelegate, WKScriptMessageHandler {
            let parent: RedWebViewWrapper
            
            init(parent: RedWebViewWrapper) {
                self.parent = parent
            }
            
            func setupBridge(webView: WKWebView) {
                let h = parent.handler
                h.sendToJs = { [weak webView] json in
                    let escaped = json
                        .replacingOccurrences(of: "\\", with: "\\\\")
                        .replacingOccurrences(of: "\"", with: "\\\"")
                        .replacingOccurrences(of: "\n", with: "\\n")
                    let script = "\(Red.bridgeEnd)(\"\(escaped)\")"
                    DispatchQueue.main.async {
                        Logger.log(script)
                        webView?.evaluateJavaScript(script)
                    }
                }
                h.requestCamera = { [weak self] in self?.parent.showCamera = true }
                h.requestGallery = { [weak self] in self?.parent.showGallery = true }
                h.requestContact = { [weak self] in self?.parent.showContact = true }
                h.requestInAppBrowser = { [weak self] url, title in self?.parent.onInAppBrowser?(url, title) }
                h.requestLiveDetection = { [weak self] in self?.parent.onLiveDetection?() }
                h.onLogout = { [weak self] in self?.parent.onLogout?() }
            }
            
            func userContentController(_ userContentController: WKUserContentController,
                                       didReceive message: WKScriptMessage) {
                switch message.name {
                case Red.bridgeName:
                    guard let body = message.body as? String,
                          let data = body.data(using: .utf8),
                          let msg = try? JSONDecoder().decode(eioolh.self, from: data)
                    else { return }
                    Logger.log(body)
                    Task { parent.handler.handle(msg: msg) }

//                case Webs.consoleLog:
//                    guard let dict = message.body as? [String: Any],
//                          let level = dict["level"] as? String,
//                          let text = dict["message"] as? String
//                    else { return }
//                    Logger.log("[Web] [\(level)] \(text)")

                default:
                    break
                }
            }
            
            func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
                if parent.isFirstLoading {
                    parent.isFirstLoading = false
                }
                [Red.mk7, Red.mk10, Red.mk13, Red.mk14, Red.mk15].forEach { key in
                    var msg = eioolh()
                    msg.odfxgfirl = key
                    parent.handler.handle(msg: msg)
                }
            }
        }
    }
    
    // MARK: - Camera Picker
    
    private struct CameraPicker: UIViewControllerRepresentable {
        let onCapture: (UIImage) -> Void
        func makeCoordinator() -> Coordinator { Coordinator(onCapture: onCapture) }
        func makeUIViewController(context: Context) -> UIImagePickerController {
            let picker = UIImagePickerController()
            picker.sourceType = .camera
            picker.delegate = context.coordinator
            return picker
        }
        func updateUIViewController(_ uiVC: UIImagePickerController, context: Context) {}
        final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
            let onCapture: (UIImage) -> Void
            init(onCapture: @escaping (UIImage) -> Void) { self.onCapture = onCapture }
            func imagePickerController(_ picker: UIImagePickerController,
                                       didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
                picker.dismiss(animated: true)
                if let img = info[.originalImage] as? UIImage { onCapture(img) }
            }
            func imagePickerControllerDidCancel(_ picker: UIImagePickerController) { picker.dismiss(animated: true) }
        }
    }
    
    // MARK: - Gallery Picker
    
    private struct GalleryPicker: UIViewControllerRepresentable {
        let onPick: (UIImage) -> Void
        func makeCoordinator() -> Coordinator { Coordinator(onPick: onPick) }
        func makeUIViewController(context: Context) -> PHPickerViewController {
            var config = PHPickerConfiguration()
            config.selectionLimit = 1
            config.filter = .images
            let picker = PHPickerViewController(configuration: config)
            picker.delegate = context.coordinator
            return picker
        }
        func updateUIViewController(_ uiVC: PHPickerViewController, context: Context) {}
        final class Coordinator: NSObject, PHPickerViewControllerDelegate {
            let onPick: (UIImage) -> Void
            init(onPick: @escaping (UIImage) -> Void) { self.onPick = onPick }
            func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
                picker.dismiss(animated: true)
                guard let result = results.first else { return }
                result.itemProvider.loadObject(ofClass: UIImage.self) { obj, _ in
                    if let img = obj as? UIImage { DispatchQueue.main.async { self.onPick(img) } }
                }
            }
        }
    }
    
    // MARK: - Contact Picker
    
    private struct ContactPicker: UIViewControllerRepresentable {
        let onPick: (String?, String?) -> Void
        func makeCoordinator() -> Coordinator { Coordinator(onPick: onPick) }
        func makeUIViewController(context: Context) -> CNContactPickerViewController {
            let picker = CNContactPickerViewController()
            picker.delegate = context.coordinator
            picker.displayedPropertyKeys = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey]
            return picker
        }
        func updateUIViewController(_ uiVC: CNContactPickerViewController, context: Context) {}
        final class Coordinator: NSObject, CNContactPickerDelegate {
            let onPick: (String?, String?) -> Void
            init(onPick: @escaping (String?, String?) -> Void) { self.onPick = onPick }
            func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
                let name = "\(contact.givenName) \(contact.familyName)".trimmingCharacters(in: .whitespaces)
                let phone = contact.phoneNumbers.first?.value.stringValue
                onPick(name.isEmpty ? nil : name, phone)
            }
            func contactPickerDidCancel(_ picker: CNContactPickerViewController) { onPick(nil, nil) }
        }
    }

    // MARK: - Browser Config

    private struct BrowserConfig: Identifiable {
        let id = UUID()
        let url: URL
        let title: String
    }
}
