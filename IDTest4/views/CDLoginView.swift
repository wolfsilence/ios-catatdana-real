import SwiftUI
import WebKit
import UIKit

//
//  CDLoginView.swift
//  CatatDanaKu
//
//  Created by lishen on 2026/6/3.
//

/// 登录页 —— 沉浸式三层布局
struct CDLoginView: View {
    let onLoginSuccess: () -> Void

    @State private var vm = LoginViewModel()
    @State private var showPrivacy = false
    @State private var showToast = false
    @State private var toastMessage = ""

    private var topSafeInset: CGFloat {
        (UIApplication.shared.connectedScenes.first as? UIWindowScene)?
            .windows.first?.safeAreaInsets.top ?? 0
    }

    private var phoneBinding: Binding<String> {
        Binding(
            get: { vm.phoneInput },
            set: { newValue in
                let filtered = newValue.filter { $0.isNumber }
                vm.phoneInput = String(filtered.prefix(15))
            }
        )
    }

    var body: some View {
        GeometryReader { geo in
            let contentTop = geo.size.height * 0.25
            let bgHeight = geo.size.width * 350 / 375

            ZStack {
                // ── Layer 0: 白色打底 ──
                Color.white

                // ── Layer 1: 顶部大图 ──
                VStack(spacing: 0) {
                    Image("p_login_bg")
                        .resizable()
                        .scaledToFill()
                        .frame(width: geo.size.width, height: bgHeight)
                        .clipped()
                    Spacer()
                }

                // ── Layer 2: 内容区 #F3F6F3 ──
                VStack(spacing: 0) {
                    Color.clear.frame(height: contentTop)

                    ZStack {
                        AppColors.launchBackground
                            .clipShape(.rect(topLeadingRadius: 10, topTrailingRadius: 10))

                        contentBody
                    }
                    .frame(maxHeight: .infinity)
                }

                // ── Layer 3: 覆盖图片 183×197 ──
                Image("p_login_top")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 183, height: 197)
                    .position(x: geo.size.width / 2,
                              y: contentTop - 49.25)
            }
            .overlay(alignment: .topLeading) {
                Button {
                    exit(0)
                } label: {
                    Image("icon_bw")
                        .resizable()
                        .frame(width: 24, height: 24)
                }
                .padding(.leading, 20)
                .padding(.top, topSafeInset + 11)
            }
            .contentShape(Rectangle())
            .onTapGesture { hideKeyboard() }
        }
        .ignoresSafeArea()
        .loading(isPresented: $vm.isLoading)
        .toast(isPresented: $showToast, message: toastMessage)
        .onChange(of: vm.errorMessage) { _, msg in
            if let msg {
                toastMessage = msg
                showToast = true
                vm.clearError()
            }
        }
        .onChange(of: vm.isLoggedIn) { _, loggedIn in
            if loggedIn { onLoginSuccess() }
        }
        .sheet(isPresented: $showPrivacy) {
            privacySheet
        }
        .onAppear {
            Tk.shared.track(page: Points.pVe0t6i, act: Points.a89gkqm)
        }
        .onChange(of: vm.codeInput) { _, _ in
            vm.onCodeInputChanged()
        }
    }

    // MARK: - Content Body

    private var contentBody: some View {
        VStack(spacing: 0) {
            // 登录title
            Text(AllStr.lgT)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(AppColors.primary)
                .padding(.top, 36)

            // 手机号输入区
            phoneField
                .padding(.top, 30)

            // 验证码输入区（一键登录失败后显示）
            if vm.isCodeFieldVisible {
                codeField
                    .padding(.top, 5)

                Button {
                    Task { await vm.login() }
                } label: {
                    Text(AllStr.lgLb)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.white)
                        .frame(height: 48)
                        .frame(maxWidth: .infinity)
                        .background(vm.canLogin ? AppColors.primary : Color.gray)
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                        .shadow(color: .black.opacity(0.08), radius: 2, x: 0, y: 1)
                }
                .disabled(!vm.canLogin)
                .padding(.horizontal, 30)
                .padding(.top, 25)
            }

            // 一键登录区（初始状态）
            if !vm.isCodeFieldVisible {
                oneClickSection
                    .padding(.top, 50)
            }

            Spacer()

            // 底部隐私文案
            privacyText
                .padding(.bottom, 30)
        }
    }

    // MARK: - Phone Field

    private var phoneField: some View {
        HStack(spacing: 0) {
            Text(AllStr.lgCc)
                .font(.system(size: 16))
                .foregroundColor(vm.phoneInput.isEmpty ? AppColors.strHint : AppColors.strPrimary)

            ZStack(alignment: .leading) {
                if vm.phoneInput.isEmpty {
                    Text(AllStr.lgPh)
                        .font(.system(size: 16))
                        .foregroundColor(AppColors.strHint)
                        .allowsHitTesting(false)
                }
                TextField("", text: phoneBinding)
                    .font(.system(size: 16))
                    .foregroundColor(AppColors.strPrimary)
                    .keyboardType(.numberPad)
            }.padding(.leading, 6)
        }
        .padding(.horizontal, 16)
        .frame(height: 60)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 15))
        .padding(.horizontal, 30)
    }

    // MARK: - Code Field

    private var codeField: some View {
        VStack(spacing: 4) {
            HStack(spacing: 8) {
                CodeTextField(
                    text: $vm.codeInput,
                    maxLength: 4,
                    placeholder: AllStr.lgCh
                )
                .frame(height: 22)

                Button {
                    Task { await vm.sendVCode() }
                } label: {
                    Text(vm.countdownText)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 15)
                        .frame(height: 30)
                        .background(AppColors.primary)
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                }
                .disabled(!vm.canSendCode)
            }
            .padding(.leading, 16)
            .padding(.trailing, 8)
            .frame(height: 60)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 15))
            .padding(.horizontal, 30)

            // 状态文字
            if let status = vm.statusText {
                HStack {
                    if vm.isStatusTextTappable {
                        Button {
                            Task { await vm.switchMethodAndResend() }
                        } label: {
                            Text(status)
                                .font(.system(size: 12))
                                .foregroundColor(AppColors.primary)
                        }
                    } else {
                        Text(status)
                            .font(.system(size: 12))
                            .foregroundColor(AppColors.strPrimary)
                    }
                    Spacer()
                }
                .padding(.horizontal, 36)
                .padding(.top, 4)
            }
        }
    }

    // MARK: - One-Click Section

    private var oneClickSection: some View {
        VStack(spacing: 0) {
            // WA 一键登录按钮
            oneClickButton(
                title: AllStr.lgWl,
                color: AppColors.loginWaBg,
                method: .wa
            )

            Text(AllStr.lgWh)
                .font(.system(size: 11))
                .foregroundColor(AppColors.strPrimary)
                .padding(.top, 5)

            // SMS 一键登录按钮
            oneClickButton(
                title: AllStr.lgSl,
                color: AppColors.primary,
                method: .sms
            )
            .padding(.top, 15)
        }
    }

    private func oneClickButton(title: String, color: Color, method: VCodeMethod) -> some View {
        Button {
            Task { await vm.oneClickLogin(method: method) }
        } label: {
            Text(title)
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.white)
                .frame(height: 48)
                .frame(maxWidth: .infinity)
                .background(vm.isPhoneValid ? color : Color.gray)
                .clipShape(RoundedRectangle(cornerRadius: 24))
                .shadow(color: .black.opacity(0.08), radius: 2, x: 0, y: 1)
        }
        .disabled(!vm.isPhoneValid || vm.isLoading)
        .padding(.horizontal, 30)
    }

    // MARK: - Privacy Text

    private var privacyText: some View {
        HStack(spacing: 0) {
            Text(AllStr.lgPp)
                .font(.system(size: 14))
                .foregroundColor(AppColors.strPrimary)
            Button {
                showPrivacy = true
            } label: {
                Text(AllStr.lgPl)
                    .font(.system(size: 14))
                    .foregroundColor(AppColors.primary)
            }
            Text(AllStr.lgPs)
                .font(.system(size: 14))
                .foregroundColor(AppColors.strPrimary)
        }
    }

    // MARK: - Privacy Sheet

    private var privacySheet: some View {
        NavigationStack {
            PrivacyWebView()
                .navigationTitle(AllStr.lgPst)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button(AllStr.lgC) { showPrivacy = false }
                    }
                }
        }
    }
}

// MARK: - Keyboard

private func hideKeyboard() {
    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
}

// MARK: - Code TextField（UIKit 层限制输入，无截断闪现）

private struct CodeTextField: UIViewRepresentable {
    @Binding var text: String
    let maxLength: Int
    let placeholder: String

    func makeUIView(context: Context) -> UITextField {
        let tf = UITextField()
        tf.delegate = context.coordinator
        tf.keyboardType = .numberPad
        tf.font = .systemFont(ofSize: 16)
        // #222222
        tf.textColor = UIColor(red: 0x22 / 255, green: 0x22 / 255, blue: 0x22 / 255, alpha: 1)
        // #8F8FA1
        tf.attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [
                .font: UIFont.systemFont(ofSize: 16),
                .foregroundColor: UIColor(red: 0x8F / 255, green: 0x8F / 255, blue: 0xA1 / 255, alpha: 1)
            ]
        )
        return tf
    }

    func updateUIView(_ uiView: UITextField, context: Context) {
        if uiView.text != text {
            uiView.text = text
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    final class Coordinator: NSObject, UITextFieldDelegate {
        let parent: CodeTextField

        init(_ parent: CodeTextField) {
            self.parent = parent
        }

        func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            let current = textField.text ?? ""
            let filtered = string.filter { $0.isNumber }
            let newText = (current as NSString).replacingCharacters(in: range, with: filtered)
            guard newText.count <= parent.maxLength else { return false }
            // 手动设置 text 并同步 SwiftUI，阻止 UIKit 默认行为
            textField.text = newText
            parent.text = newText
            // 发送 textFieldDidChange 让 SwiftUI 感知变化
            textField.sendActions(for: .editingChanged)
            return false
        }
    }
}

// MARK: - Privacy WebView

private struct PrivacyWebView: UIViewRepresentable {
    func makeUIView(context: Context) -> WKWebView { WKWebView() }
    func updateUIView(_ uiView: WKWebView, context: Context) {
        guard let url = URL(string: Consts.ppUrl) else { return }
        uiView.load(URLRequest(url: url))
    }
}
