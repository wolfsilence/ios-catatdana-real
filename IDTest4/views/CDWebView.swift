import SwiftUI
import WebKit

//
//  CDWebView.swift
//  CatatDanaKu
//
//  Created by lishen on 2026/6/5.
//

/// 简洁 WebView —— 顶部 bar（返回 + 标题）+ 进度条 + WKWebView
struct CDWebView: View {
    let url: URL
    let title: String
    var onBack: (() -> Void)? = nil

    @Environment(\.dismiss) private var dismiss
    @State private var progress: Double = 0

    var body: some View {
        VStack(spacing: 0) {
            barViewCdk
            progressBarCdk
            WebViewWithProgress(url: url, progress: $progress)
        }
    }

    // MARK: - Progress Bar

    @ViewBuilder
    private var progressBarCdk: some View {
        if progress > 0, progress < 1.0 {
            GeometryReader { geo in
                Rectangle()
                    .fill(AppColors.primary)
                    .frame(width: geo.size.width * progress, height: 2)
            }
            .frame(height: 2)
            .animation(.linear(duration: 0.15), value: progress)
        }
    }

    // MARK: - Bar

    private var barViewCdk: some View {
        HStack(spacing: 0) {
            Button {
                CdkDICleaner.shared.cdkObj()
                if let onBack {
                    onBack()
                } else {
                    dismiss()
                }
            } label: {
                Image("icon_bb")
                    .resizable()
                    .frame(width: 24, height: 24)
            }
            Spacer()
            Text(title)
                .font(.system(size: 18))
                .fontWeight(.semibold)
                .foregroundColor(AppColors.strPrimary)
                .lineLimit(1)
            Spacer()
            Color.clear.frame(width: 24, height: 24)
        }
        .frame(height: 48)
        .padding(.horizontal, 16)
        .background(Color.white)
    }
}

// MARK: - WKWebView Wrapper

private struct WebViewWithProgress: UIViewRepresentable {
    let url: URL
    @Binding var progress: Double

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        context.coordinator.observeProgressCdk(webView)
        webView.load(URLRequest(url: url))
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(progress: $progress)
    }

    final class Coordinator: NSObject, WKNavigationDelegate {
        @Binding private var progress: Double
        private var progressObservation: NSKeyValueObservation?

        init(progress: Binding<Double>) {
            self._progress = progress
        }

        func observeProgressCdk(_ webView: WKWebView) {
            CdkDICleaner.shared.cdkStack()
            progressObservation = webView.observe(\.estimatedProgress, options: .new) { [weak self] _, change in
                guard let self, let p = change.newValue else { return }
                DispatchQueue.main.async {
                    self.progress = p
                }
            }
        }

        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            Logger.log("CDWebView didFailProvisionalNavigation: \(error.localizedDescription)")
        }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            Logger.log("CDWebView didFail: \(error.localizedDescription)")
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            progress = 1.0
        }
    }
}
