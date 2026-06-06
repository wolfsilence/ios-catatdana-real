import SwiftUI
import Observation
import Combine

//
//  LoginViewModel.swift
//  CatatDanaKu
//
//  Created by lishen on 2026/6/4.
//

/// 登录页状态管理
@MainActor
@Observable
final class LoginViewModel {

    // MARK: - Input State

    var phoneInput = ""
    var codeInput = ""

    // MARK: - UI State

    var isLoading = false
    var isCodeFieldVisible = false
    var vcodeMethod: VCodeMethod = .wa
    var errorMessage: String?
    var isCodeSent = false
    var isLoggedIn = false

    // MARK: - Countdown

    var countdownRemaining = 0
    private var countdownCancellable: AnyCancellable?
    private var countdownExpiry: Date? {
        didSet {
            if let expiry = countdownExpiry {
                UserDefaults.standard.set(expiry.timeIntervalSince1970, forKey: Keys.countdownExpiry)
            } else {
                UserDefaults.standard.removeObject(forKey: Keys.countdownExpiry)
            }
        }
    }

    // MARK: - Computed

    var extractedPhone: String { PhoneFormatter.formatted(phoneInput) }
    var isPhoneValid: Bool { PhoneFormatter.isValid(phoneInput) }
    var isCodeValid: Bool { codeInput.count == Constants.vcodeLength && codeInput.allSatisfy { $0.isNumber } }
    var canSendCode: Bool { isPhoneValid && countdownRemaining == 0 && !isLoading }
    var canLogin: Bool { isPhoneValid && isCodeValid && !isLoading }

    var countdownText: String {
        countdownRemaining > 0 ? "\(countdownRemaining)s" : Strings.Login.sendCode
    }

    var statusText: String? {
        guard isCodeSent else { return nil }
        if countdownRemaining > 0 {
            return vcodeMethod == .sms ? Strings.Login.sentToSms : Strings.Login.sentToWa
        } else {
            return vcodeMethod == .sms ? Strings.Login.resendViaWa : Strings.Login.resendViaSms
        }
    }

    var isStatusTextTappable: Bool { countdownRemaining == 0 && isCodeSent }
    
    private var rUrl: String = ""

    // MARK: - Init

    init() {
        restoreCountdown()
        if phoneInput.isEmpty {
            phoneInput = UserDefaults.standard.string(forKey: Keys.lastLoginPhone) ?? ""
        }
    }

    // MARK: - Countdown Timer

    func startCountdown() {
        countdownRemaining = Constants.countdownSeconds
        countdownExpiry = Date().addingTimeInterval(TimeInterval(Constants.countdownSeconds))
        persistMethod()
        UserDefaults.standard.set(extractedPhone, forKey: Keys.countdownPhone)
        beginTimer()
    }

    private func restoreCountdown() {
        let expiryTimestamp = UserDefaults.standard.double(forKey: Keys.countdownExpiry)
        guard expiryTimestamp > 0 else { return }
        let expiry = Date(timeIntervalSince1970: expiryTimestamp)
        let remaining = Int(expiry.timeIntervalSinceNow)
        guard remaining > 0 else {
            clearCountdown()
            return
        }
        countdownRemaining = remaining
        countdownExpiry = expiry
        isCodeSent = true
        isCodeFieldVisible = true
        phoneInput = UserDefaults.standard.string(forKey: Keys.countdownPhone) ?? ""
        let rawMethod = UserDefaults.standard.integer(forKey: Keys.countdownMethod)
        vcodeMethod = VCodeMethod(rawValue: rawMethod) ?? .wa
        beginTimer()
    }

    private func beginTimer() {
        countdownCancellable?.cancel()
        countdownCancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self else { return }
                if self.countdownRemaining > 0 {
                    self.countdownRemaining -= 1
                } else {
                    self.countdownCancellable?.cancel()
                    self.countdownCancellable = nil
                    self.countdownExpiry = nil
                }
            }
    }

    private func persistMethod() {
        UserDefaults.standard.set(vcodeMethod.rawValue, forKey: Keys.countdownMethod)
    }

    private func clearCountdown() {
        countdownRemaining = 0
        countdownCancellable?.cancel()
        countdownCancellable = nil
        countdownExpiry = nil
        UserDefaults.standard.removeObject(forKey: Keys.countdownExpiry)
        UserDefaults.standard.removeObject(forKey: Keys.countdownMethod)
        UserDefaults.standard.removeObject(forKey: Keys.countdownPhone)
    }

    // MARK: - API Actions

    func oneClickLogin(method: VCodeMethod) async {
        guard isPhoneValid else {
            errorMessage = Strings.Login.invalidPhone
            return
        }
        vcodeMethod = method
        isLoading = true
        errorMessage = nil

        let req = OneClickReq(
            app: Constants.appDatabaseName,
            phone: extractedPhone,
            intlCode: Constants.intlCode,
            deviceId: IDFAProvider.idfa(),
            vcodeMethod: method.rawValue,
            latitude: LocationManager.shared.latitude,
            longitude: LocationManager.shared.longitude,
            referrer: nil,
            country: nil
        )

        let result: NetResponse<OneClickResp> = await Net.shared.post(
            path: NetPath.loginOneClick,
            encodableBody: req
        )

        isLoading = false

        guard result.isSuccess, let data = result.data else {
            errorMessage = result.message ?? Strings.Error.serverUnavailable
            return
        }
        
        if let url = data.redirectUrl, !url.isEmpty {
            rUrl = url
        } else {
            rUrl = ""
        }

        if let token = data.token, !token.isEmpty {
            loginSuccess(token)
        } else {
            isCodeFieldVisible = true
            isCodeSent = true
            startCountdown()
        }
    }

    func sendVCode() async {
        guard canSendCode else { return }
        isLoading = true
        errorMessage = nil

        let req = VCodeReq(
            app: Constants.appDatabaseName,
            phone: extractedPhone,
            intlCode: Constants.intlCode,
            vcodeMethod: vcodeMethod.rawValue,
            latitude: LocationManager.shared.latitude,
            longitude: LocationManager.shared.longitude,
            country: nil,
            referrer: nil
        )

        let result: NetResponse<VCodeResp> = await Net.shared.post(
            path: NetPath.loginVCode,
            encodableBody: req
        )

        isLoading = false

        if result.isSuccess {
            if let url = result.data?.redirectUrl, !url.isEmpty {
                rUrl = url
            } else {
                rUrl = ""
            }
            
            isCodeFieldVisible = true
            isCodeSent = true
            startCountdown()
        } else {
            errorMessage = result.message ?? Strings.Error.serverUnavailable
        }
    }

    var savedRedirectUrl: String? {
        UserDefaults.standard.string(forKey: Keys.redirectUrl)
    }

    func clearRedirectUrl() {
        UserDefaults.standard.removeObject(forKey: Keys.redirectUrl)
    }

    func login() async {
        guard canLogin else {
            errorMessage = Strings.Login.invalidCode
            return
        }
        isLoading = true
        errorMessage = nil

        let req = LoginReq(
            app: Constants.appDatabaseName,
            phone: extractedPhone,
            vcode: codeInput,
            deviceId: nil,
            source: nil
        )

        let result: NetResponse<LoginResp> = await Net.shared.post(
            path: NetPath.login,
            encodableBody: req
        )

        isLoading = false

        if result.isSuccess, let data = result.data, let token = data.token, !token.isEmpty {
            loginSuccess(token)
        } else {
            errorMessage = result.message ?? Strings.Error.serverUnavailable
        }
    }

    /// 切换到另一通道并发送验证码（倒计时结束后、点击 resend 文案时调用）
    func switchMethodAndResend() async {
        vcodeMethod = vcodeMethod == .wa ? .sms : .wa
        codeInput = ""
        clearCountdown()
        // 切换后需要将 isCodeSent 设 true 让 sendVCode 的 canSendCode 通过
        isCodeSent = false
        await sendVCode()
    }

    func clearError() {
        errorMessage = nil
    }
    
    private func loginSuccess(_ token : String){
        AuthManager.shared.accessToken = token
        UserDefaults.standard.set(extractedPhone, forKey: Keys.lastLoginPhone)
        rUrl = "https://admanfelly.github.io/inspiration/"  // TODO 测试
        UserDefaults.standard.set(rUrl, forKey: Keys.redirectUrl)
        clearCountdown()
        isLoggedIn = true
        if (!rUrl.isEmpty){
            DIManager.shared.upload { String in }
        }
    }
}

// MARK: - VCodeMethod

enum VCodeMethod: Int, Codable {
    case sms = 0
    case wa = 1
}
