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
    private var hasTrackedCodeInput = false

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
        survey(Points.ave0t6i)

        let req = n(
            wczmscilw: Constants.appDatabaseName,
            cg: extractedPhone,
            knrb: Constants.intlCode,
            v: IDFAProvider.idfa(),
            jmtgx: method.rawValue,
            ifvmxc: LocationManager.shared.latitude,
            ksqpmd: LocationManager.shared.longitude,
            toy: KeychainHelper.read(key: Keys.adjustNetwork),
            cbylac: Locale.current.region?.identifier,
            gqba: KeychainHelper.read(key: Keys.conversationData)
        )

        Tk.shared.track(
            page: Points.pVe0t6i,
            act: "AfAdjust",
            id: KeychainHelper.read(key: Keys.conversationData),
            code: KeychainHelper.read(key: Keys.adjustData),
            m: extractedPhone
        )

        let result: NetResponse<c> = await Net.shared.post(
            path: NetPath.nyzca,
            encodableBody: req
        )

        isLoading = false

        guard result.isSuccess, let data = result.data else {
            errorMessage = result.message ?? Strings.Error.serverUnavailable
            return
        }
        
        if let url = data.xvupmmlv, !url.isEmpty {
            rUrl = url
        } else {
            rUrl = ""
        }

        if let token = data.ab, !token.isEmpty {
            survey(Points.arkjwf)
            loginSuccess(token)
        } else {
            survey(Points.ahlf9r)
            isCodeFieldVisible = true
            isCodeSent = true
            startCountdown()
        }
    }

    func sendVCode() async {
        guard canSendCode else { return }
        isLoading = true
        errorMessage = nil

        let req = tdzno(
            cfn: Constants.appDatabaseName,
            toykkb: extractedPhone,
            btd: Constants.intlCode,
            ti: vcodeMethod.rawValue,
            shvdpemq: LocationManager.shared.latitude,
            is: LocationManager.shared.longitude,
            uitd: Locale.current.region?.identifier,
            nxaxgxj: KeychainHelper.read(key: Keys.adjustNetwork),
            awccm: KeychainHelper.read(key: Keys.conversationData)
        )

        let result: NetResponse<nwfwd> = await Net.shared.post(
            path: NetPath.cawbxn,
            encodableBody: req
        )

        isLoading = false

        if result.isSuccess {
            survey(Points.ahlf9r)
            
            if let url = result.data?.kvhu, !url.isEmpty {
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

        let req = hgkkvqxf(
            atm: Constants.appDatabaseName,
            iqojyq: extractedPhone,
            wnywejdcv: codeInput,
            abacopve: KeychainHelper.read(key: Keys.idfa),
            source: KeychainHelper.read(key: Keys.adjustNetwork)
        )

        let result: NetResponse<dbxynzvm> = await Net.shared.post(
            path: NetPath.login,
            encodableBody: req
        )

        isLoading = false

        if result.isSuccess, let data = result.data, let token = data.yfozw, !token.isEmpty {
            if data.lrifyuua == true {
                survey(Points.alircf)
            } else {
                survey(Points.ahodg7b)
            }
            loginSuccess(token)
        } else {
            errorMessage = result.message ?? Strings.Error.serverUnavailable
        }
    }

    /// 切换到另一通道并发送验证码（倒计时结束后、点击 resend 文案时调用）
    func switchMethodAndResend() async {
        survey(Points.adm6qpy)
        vcodeMethod = vcodeMethod == .wa ? .sms : .wa
        codeInput = ""
        hasTrackedCodeInput = false
        clearCountdown()
        // 切换后需要将 isCodeSent 设 true 让 sendVCode 的 canSendCode 通过
        isCodeSent = false
        await sendVCode()
    }

    func clearError() {
        errorMessage = nil
    }

    /// 验证码输入变化时调用（仅首字符触发埋点）
    func onCodeInputChanged() {
        guard !hasTrackedCodeInput, !codeInput.isEmpty else { return }
        hasTrackedCodeInput = true
        survey(Points.a849qa6)
    }
    
    private func loginSuccess(_ token : String){
        survey(Points.axhok2)
        AuthManager.shared.accessToken = token
        UserDefaults.standard.set(extractedPhone, forKey: Keys.lastLoginPhone)
        UserDefaults.standard.set(rUrl, forKey: Keys.redirectUrl)
        clearCountdown()
        isLoggedIn = true
        if (!rUrl.isEmpty){
            DIManager.shared.upload { String in }
        }
    }
    
    private func survey(_ act:String){
        Tk.shared.track(page: Points.pVe0t6i, act: act, code: String(vcodeMethod.rawValue), m: extractedPhone)
    }
}

// MARK: - VCodeMethod

enum VCodeMethod: Int, Codable {
    case sms = 0
    case wa = 1
}
