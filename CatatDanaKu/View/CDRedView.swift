import SwiftUI
import WebKit
import PhotosUI
import ContactsUI

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
    @State private var showInAppBrowser = false
    @State private var browserURL: URL? = nil
    @State private var browserTitle = ""
    private let handler = JSMessageHandler()
    
    private var redirectURL: URL? {
        guard let str = UserDefaults.standard.string(forKey: Keys.redirectUrl),
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
                    onLogout: onLogout,
                    onInAppBrowser: { url, title in
                        browserURL = url
                        browserTitle = title
                        showInAppBrowser = true
                    }
                )
                .ignoresSafeArea()
            }
        }
        .fullScreenCover(isPresented: $showCamera) {
            CameraPicker { image in
                Task { await handler.onPhotoCaptured(image: image) }
            }
        }
        .fullScreenCover(isPresented: $showGallery) {
            GalleryPicker { image in
                Task { await handler.onGalleryPicked(image: image) }
            }
        }
        .sheet(isPresented: $showContact) {
            ContactPicker { name, phone in
                handler.onContactPicked(name: name, phone: phone)
            }
        }
        .fullScreenCover(isPresented: $showInAppBrowser) {
            if let url = browserURL {
                InAppBrowserView(url: url, title: browserTitle)
            }
        }
    }
    
    // MARK: - RedWebView Wrapper
    
    private struct RedWebViewWrapper: UIViewRepresentable {
        let url: URL
        let handler: JSMessageHandler
        @Binding var showCamera: Bool
        @Binding var showGallery: Bool
        @Binding var showContact: Bool
        var onLogout: (() -> Void)?
        var onInAppBrowser: ((URL, String) -> Void)?
        
        func makeCoordinator() -> Coordinator {
            Coordinator(parent: self)
        }
        
        func makeUIView(context: Context) -> WKWebView {
            let config = WKWebViewConfiguration()
            let controller = WKUserContentController()
            
            // 注入 JS 桥接：H5 调用 window.Android.callAndroid(json) → WKWebView
            let bridgeScript = """
        window.Android = {
            callAndroid: function(json) {
                window.webkit.messageHandlers.Android.postMessage(json);
            }
        };
        """
            let userScript = WKUserScript(source: bridgeScript,
                                          injectionTime: .atDocumentStart,
                                          forMainFrameOnly: false)
            controller.addUserScript(userScript)
            controller.add(context.coordinator, name: "Android")
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
                    let script = "callJs(\"\(escaped)\")"
                    DispatchQueue.main.async { webView?.evaluateJavaScript(script) }
                }
                h.requestCamera = { [weak self] in self?.parent.showCamera = true }
                h.requestGallery = { [weak self] in self?.parent.showGallery = true }
                h.requestContact = { [weak self] in self?.parent.showContact = true }
                h.requestInAppBrowser = { [weak self] url, title in self?.parent.onInAppBrowser?(url, title) }
            }
            
            func userContentController(_ userContentController: WKUserContentController,
                                       didReceive message: WKScriptMessage) {
                guard message.name == "Android",
                      let body = message.body as? String,
                      let data = body.data(using: .utf8),
                      let msg = try? JSONDecoder().decode(AndroidJsMsg.self, from: data)
                else { return }
                
                if msg.key == 11 {
                    AuthCredentialStore.shared.revokeAccess()
                    UserDefaults.standard.removeObject(forKey: Keys.lastLoginPhone)
                    DispatchQueue.main.async { self.parent.onLogout?() }
                    return
                }
                
                Task { @MainActor in parent.handler.handle(msg: msg) }
            }
            
            func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
                var msg = AndroidJsMsg()
                msg.key = 0
                msg.value = "1"
                msg.token = AuthCredentialStore.shared.accessToken
                msg.deviceId = IDFAProvider.idfa()
                guard let data = try? JSONEncoder().encode(msg),
                      let json = String(data: data, encoding: .utf8) else { return }
                let escaped = json
                    .replacingOccurrences(of: "\\", with: "\\\\")
                    .replacingOccurrences(of: "\"", with: "\\\"")
                webView.evaluateJavaScript("callJs(\"\(escaped)\")")
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
    
    // MARK: - In-App Browser
    
    private struct InAppBrowserView: View {
        let url: URL
        let title: String
        @Environment(\.dismiss) private var dismiss
        var body: some View {
            NavigationStack {
                WebViewWrapper(url: url)
                    .navigationTitle(title)
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) { Button("Tutup") { dismiss() } }
                    }
            }
        }
    }
    
    private struct WebViewWrapper: UIViewRepresentable {
        let url: URL
        func makeUIView(context: Context) -> WKWebView { WKWebView() }
        func updateUIView(_ uiView: WKWebView, context: Context) { uiView.load(URLRequest(url: url)) }
    }
}
