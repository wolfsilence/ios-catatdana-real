import SwiftUI
import WebKit
import AdjustSdk

//
//  CDFirstProtocolView.swift
//  CatatDanaKu
//
//  Created by lishen on 2026/6/3.
//

/// 首次启动隐私协议页
struct CDFirstPrivacyView: View {
    private let url = URL(string: Consts.ppUrl)!
    let onDecision: (Bool) -> Void

    @State private var isWebViewLoaded = false
    @State private var loadingProgress = 0.0
    @State private var showToast = false

    var body: some View {
        ZStack {
            // 渐变背景：accentColor → #F3F6F3 → white
            LinearGradient(
                stops: [
                    .init(color: Color.accentColor, location: 0.0),
                    .init(color: AppColors.launchBackground, location: 0.5),
                    .init(color: .white, location: 1.0),
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                // 标题 + 说明文字
                VStack(alignment: .leading, spacing: 5) {
                    Text(AllStr.laAn)
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)

                    Text(AllStr.pvDe)
                        .font(.system(size: 16))
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 20)
                .padding(.top, 9)

                // WebView
                WebViewRepresentable(url: url, onProgress: { p in
                    loadingProgress = p
                }, onLoadFinished: {
                    isWebViewLoaded = true
                })
                .overlay(alignment: .top) {
                    if !isWebViewLoaded {
                        ProgressView(value: loadingProgress)
                            .progressViewStyle(.linear)
                            .tint(AppColors.primary)
                            .frame(height: 2)
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .padding(.horizontal, 20)
                .padding(.top, 10)
                .padding(.bottom, 15)
                .frame(maxHeight: .infinity)

                // 底部按钮组
                VStack(spacing: 0) {
                    Button {
                        if isWebViewLoaded {
                            LocationManager.shared.requestLocation { _ in }
                            IDFAHelper.requestPermission {
                                NotificationCenter.default.post(name: Notification.Name(NotiName.RequestedIDFA), object: nil)
                            }
                            onDecision(true)
                        } else {
                            showToast = true
                        }
                    } label: {
                        Text(AllStr.pvA)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(AppColors.strOnPrimary)
                            .frame(height: 48)
                            .frame(maxWidth: .infinity)
                            .background(AppColors.primary)
                            .clipShape(RoundedRectangle(cornerRadius: 24))
                    }
                    .padding(.horizontal, 35)
                    .padding(.top, 15)

                    Button {
                        exit(0)
                    } label: {
                        Text(AllStr.pvDi)
                            .font(.system(size: 13))
                            .foregroundColor(AppColors.strSecondary)
                    }
                    .padding(.top, 10)
                    .padding(.bottom, 15)
                }
                .background(AppColors.whiteBg)
                .shadow(color: .black.opacity(0.04), radius: 1, x: 0, y: -1)
            }
        }
        .toast(isPresented: $showToast,
               message: AllStr.pvTw)
    }
}

// MARK: - WebView Representable

private struct WebViewRepresentable: UIViewRepresentable {
    let url: URL
    let onProgress: (Double) -> Void
    let onLoadFinished: () -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(onProgress: onProgress, onLoadFinished: onLoadFinished)
    }

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        context.coordinator.observeProgress(for: webView)
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        uiView.load(URLRequest(url: url))
    }

    final class Coordinator: NSObject, WKNavigationDelegate {
        let onProgress: (Double) -> Void
        let onLoadFinished: () -> Void
        private var didFinish = false
        private var progressObservation: NSKeyValueObservation?

        init(onProgress: @escaping (Double) -> Void,
             onLoadFinished: @escaping () -> Void) {
            self.onProgress = onProgress
            self.onLoadFinished = onLoadFinished
        }

        func observeProgress(for webView: WKWebView) {
            progressObservation = webView.observe(\.estimatedProgress, options: [.new]) { [weak self] _, change in
                guard let self, let p = change.newValue else { return }
                self.onProgress(p)
            }
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            guard !didFinish else { return }
            didFinish = true
            onLoadFinished()
        }
    }
}
