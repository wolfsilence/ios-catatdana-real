import SwiftUI
import WebKit
import AVFoundation

//
//  CDLiveView.swift
//  CatatDanaKu
//
//  Created by lishen on 2026/6/5.
//

/// 活体认证页面 —— 顶栏 + 进度条 + WebView（JS 桥接 → accRecgFace）
struct CDLiveView: View {
    let url: URL
    let onResult: (String?) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var cameraGranted: Bool?
    @State private var showSettingsAlert = false
    @State private var didReportResult = false

    var body: some View {
        VStack(spacing: 0) {
            barView

            if cameraGranted == true {
                LiveDetectionWebView(url: url) { conclusion in
                    didReportResult = true
                    onResult(conclusion)
                    dismiss()
                }
            } else {
                Color.white
            }
        }
        .ignoresSafeArea(edges: .bottom)
        .alert(Strings.Permission.cameraTitle, isPresented: $showSettingsAlert) {
            Button(Strings.Permission.cancel) {
                didReportResult = true
                onResult(nil)
                dismiss()
            }
            Button(Strings.Permission.go) {
                if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingsURL)
                }
                didReportResult = true
                onResult(nil)
                dismiss()
            }
        } message: {
            Text(Strings.Permission.cameraMessage)
        }
        .onDisappear {
            if !didReportResult {
                onResult(nil)
            }
        }
        .task {
            await requestCameraPermission()
        }
    }

    // MARK: - Bar

    private var barView: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Image("ic_back_black")
                    .resizable()
                    .frame(width: 24, height: 24)
            }
            .padding(.leading, 20)
            Spacer()
        }
        .frame(height: 44)
        .background(Color.white)
    }

    // MARK: - Camera

    private func requestCameraPermission() async {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        switch status {
        case .authorized:
            cameraGranted = true
        case .notDetermined:
            let granted = await AVCaptureDevice.requestAccess(for: .video)
            if granted {
                cameraGranted = true
            } else {
                didReportResult = true
                onResult(nil)
                dismiss()
            }
        case .denied:
            showSettingsAlert = true
        case .restricted:
            didReportResult = true
            onResult(nil)
            dismiss()
        @unknown default:
            didReportResult = true
            onResult(nil)
            dismiss()
        }
    }
}

// MARK: - Weak Script Handler

private final class WeakScriptMessageHandler: NSObject, WKScriptMessageHandler {
    weak var delegate: WKScriptMessageHandler?

    init(delegate: WKScriptMessageHandler) {
        self.delegate = delegate
        super.init()
    }

    func userContentController(
        _ userContentController: WKUserContentController,
        didReceive message: WKScriptMessage
    ) {
        delegate?.userContentController(userContentController, didReceive: message)
    }
}

// MARK: - Live Detection WebView

private let liveHandlerName = "callbackObj_onMessage"

private struct LiveDetectionWebView: UIViewRepresentable {
    let url: URL
    let onResult: (String?) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(onResult: onResult)
    }

    func makeUIView(context: Context) -> WKWebView {
        let userContent = WKUserContentController()
        userContent.add(
            WeakScriptMessageHandler(delegate: context.coordinator),
            name: liveHandlerName
        )
        userContent.addUserScript(WKUserScript(
            source: makeBridgeJS(),
            injectionTime: .atDocumentStart,
            forMainFrameOnly: false
        ))

        let config = WKWebViewConfiguration()
        config.userContentController = userContent
        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = []

        let webView = WKWebView(frame: .zero, configuration: config)
        webView.backgroundColor = .white
        webView.scrollView.backgroundColor = .white
        webView.navigationDelegate = context.coordinator
        webView.uiDelegate = context.coordinator

        let progressView = UIProgressView(progressViewStyle: .bar)
        progressView.trackTintColor = .clear
        progressView.progressTintColor = UIColor(Colors.primary)
        progressView.tag = 100
        webView.addSubview(progressView)
        progressView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            progressView.topAnchor.constraint(equalTo: webView.topAnchor),
            progressView.leadingAnchor.constraint(equalTo: webView.leadingAnchor),
            progressView.trailingAnchor.constraint(equalTo: webView.trailingAnchor),
            progressView.heightAnchor.constraint(equalToConstant: 2)
        ])

        webView.addObserver(
            context.coordinator,
            forKeyPath: #keyPath(WKWebView.estimatedProgress),
            options: .new,
            context: nil
        )

        webView.load(URLRequest(url: url))
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}

    static func dismantleUIView(_ uiView: WKWebView, coordinator: Coordinator) {
        uiView.stopLoading()
        uiView.uiDelegate = nil
        uiView.navigationDelegate = nil
        uiView.configuration.userContentController.removeScriptMessageHandler(forName: liveHandlerName)
        uiView.configuration.userContentController.removeAllUserScripts()
        uiView.loadHTMLString("", baseURL: nil)
        uiView.removeFromSuperview()
    }

    private func makeBridgeJS() -> String {
        """
        (function() {
          window.callbackObj = window.callbackObj || {};
          window.callbackObj.onMessage = function(imageId, base64Image, length) {
            window.webkit.messageHandlers.\(liveHandlerName).postMessage({
              imageId: imageId || "",
              base64Image: base64Image || "",
              length: Number(length) || 0
            });
          };
        })();
        """
    }

    // MARK: - Coordinator

    final class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler {
        let onResult: (String?) -> Void
        private var hasReported = false

        init(onResult: @escaping (String?) -> Void) {
            self.onResult = onResult
        }

        // MARK: - WKScriptMessageHandler

        func userContentController(
            _ userContentController: WKUserContentController,
            didReceive message: WKScriptMessage
        ) {
            guard !hasReported,
                  message.name == liveHandlerName,
                  let dict = message.body as? [String: Any],
                  let imageId = dict["imageId"] as? String,
                  var base64Image = dict["base64Image"] as? String
            else { return }

            if let commaIndex = base64Image.firstIndex(of: ",") {
                base64Image = String(base64Image[base64Image.index(after: commaIndex)...])
            }

            hasReported = true

            var req = RecgFaceReq()
            req.imageID = imageId
            req.livenessId = imageId
            req.livenessImg = base64Image

            Task { [weak self] in
                let result: NetResponse<RecgFaceResp> = await Net.shared.post(
                    path: NetPath.accRecgFace,
                    encodableBody: req
                )
                await MainActor.run {
                    if result.isSuccess, let conclusion = result.data?.conclusion {
                        self?.onResult(conclusion)
                    } else {
                        self?.onResult(nil)
                    }
                }
            }
        }

        // MARK: - WKNavigationDelegate

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            let params: [String: String] = ["language": "id", "region": "indonesia"]
            guard let data = try? JSONSerialization.data(withJSONObject: params),
                  let json = String(data: data, encoding: .utf8) else { return }
            let escaped = json
                .replacingOccurrences(of: "\\", with: "\\\\")
                .replacingOccurrences(of: "'", with: "\\'")
            webView.evaluateJavaScript("set_param('\(escaped)')", completionHandler: nil)
        }

        // MARK: - WKUIDelegate

        func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String,
                     initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
            completionHandler()
        }

        func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String,
                     initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
            completionHandler(true)
        }

        func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String,
                     defaultText: String?, initiatedByFrame frame: WKFrameInfo,
                     completionHandler: @escaping (String?) -> Void) {
            completionHandler(defaultText ?? "")
        }

        func webView(_ webView: WKWebView, requestMediaCapturePermissionFor origin: WKSecurityOrigin,
                     initiatedByFrame frame: WKFrameInfo, type: WKMediaCaptureType,
                     decisionHandler: @escaping (WKPermissionDecision) -> Void) {
            decisionHandler(.grant)
        }

        // MARK: - KVO

        override func observeValue(forKeyPath keyPath: String?, of object: Any?,
                                   change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
            if keyPath == #keyPath(WKWebView.estimatedProgress),
               let webView = object as? WKWebView,
               let progressView = webView.viewWithTag(100) as? UIProgressView {
                let progress = Float(webView.estimatedProgress)
                progressView.isHidden = progress >= 1.0
                progressView.setProgress(progress, animated: true)
            }
        }
    }
}
