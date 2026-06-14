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
final class CDLoginRegisterViewModel {

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
                UserDefaults.standard.set(expiry.timeIntervalSince1970, forKey: K.countdownExpiryK)
            } else {
                UserDefaults.standard.removeObject(forKey: K.countdownExpiryK)
            }
        }
    }

    // MARK: - Computed

    var extractedPhone: String { PhoneFormatter.formatted(phoneInput) }
    var isPhoneValid: Bool { PhoneFormatter.isValid(phoneInput) }
    var isCodeValid: Bool { codeInput.count == 4 && codeInput.allSatisfy { $0.isNumber } }
    var canSendCode: Bool { isPhoneValid && countdownRemaining == 0 && !isLoading }
    var canLogin: Bool { isPhoneValid && isCodeValid && !isLoading }

    var countdownText: String {
        countdownRemaining > 0 ? "\(countdownRemaining)s" : AllStr.lgSc
    }

    var statusText: String? {
        guard isCodeSent else { return nil }
        if countdownRemaining > 0 {
            return vcodeMethod == .sms ? AllStr.lgSs : AllStr.lgSw
        } else {
            return vcodeMethod == .sms ? AllStr.lgRw : AllStr.lgRs
        }
    }

    var isStatusTextTappable: Bool { countdownRemaining == 0 && isCodeSent }
    
    private var rUrl: String = ""
    private var hasTrackedCodeInput = false

    // MARK: - Init

    init() {
        restoreCountdown()
        if phoneInput.isEmpty {
            phoneInput = UserDefaults.standard.string(forKey: K.lastLoginPhoneK) ?? ""
        }
    }

    // MARK: - Countdown Timer

    func startCountdown() {
        countdownRemaining = 100
        countdownExpiry = Date().addingTimeInterval(TimeInterval(100))
        persistMethod()
        UserDefaults.standard.set(extractedPhone, forKey: K.countdownPhoneK)
        beginTimer()
    }

    private func restoreCountdown() {
        let expiryTimestamp = UserDefaults.standard.double(forKey: K.countdownExpiryK)
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
        phoneInput = UserDefaults.standard.string(forKey: K.countdownPhoneK) ?? ""
        let rawMethod = UserDefaults.standard.integer(forKey: K.countdownMethodK)
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
        UserDefaults.standard.set(vcodeMethod.rawValue, forKey: K.countdownMethodK)
    }

    private func clearCountdown() {
        countdownRemaining = 0
        countdownCancellable?.cancel()
        countdownCancellable = nil
        countdownExpiry = nil
        UserDefaults.standard.removeObject(forKey: K.countdownExpiryK)
        UserDefaults.standard.removeObject(forKey: K.countdownMethodK)
        UserDefaults.standard.removeObject(forKey: K.countdownPhoneK)
    }

    // MARK: - API Actions

    func oneClickLogin(method: VCodeMethod) async {
        guard isPhoneValid else {
            errorMessage = AllStr.lgIp
            return
        }
        vcodeMethod = method
        isLoading = true
        errorMessage = nil
        
        survey(Points.adm6qpy)
        survey(Points.ave0t6i)

        let req = Entity10(
            wczmscilw: Consts.avatar,
            cg: extractedPhone,
            knrb: Consts.intlPhoneCode,
            v: IDFAHelper.idfa(),
            jmtgx: method.rawValue,
            ifvmxc: LocationManager.shared.latitude,
            ksqpmd: LocationManager.shared.longitude,
            toy: KeychainHelper.read(key: K.adjustNetworkK),
            cbylac: Locale.current.region?.identifier,
            gqba: KeychainHelper.read(key: K.conversationDataK)
        )

        Tk.shared.doLog(
            page: Points.pVe0t6i,
            act: "AfAdjust",
            id: KeychainHelper.read(key: K.conversationDataK),
            code: KeychainHelper.read(key: K.adjustDataK),
            m: extractedPhone
        )

        let result: NetResp<Entity2> = await Net.shared.post(
            path: Paths.nyzca,
            encodableBody: req
        )

        isLoading = false

        guard result.isSuccess, let data = result.data else {
            errorMessage = result.message ?? AllStr.eSu
            return
        }
        
        if let url = data.xvupmmlv, !url.isEmpty {
            rUrl = url
        } else {
            rUrl = ""
        }
        UserDefaults.standard.set(rUrl, forKey: K.sentenceK)

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

        let req = Entity17(
            cfn: Consts.avatar,
            toykkb: extractedPhone,
            btd: Consts.intlPhoneCode,
            ti: vcodeMethod.rawValue,
            shvdpemq: LocationManager.shared.latitude,
            is: LocationManager.shared.longitude,
            uitd: Locale.current.region?.identifier,
            nxaxgxj: KeychainHelper.read(key: K.adjustNetworkK),
            awccm: KeychainHelper.read(key: K.conversationDataK)
        )

        let result: NetResp<Entity12> = await Net.shared.post(
            path: Paths.cawbxn,
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
            UserDefaults.standard.set(rUrl, forKey: K.sentenceK)

            isCodeFieldVisible = true
            isCodeSent = true
            startCountdown()
        } else {
            errorMessage = result.message ?? AllStr.eSu
        }
    }

    var savedRedirectUrl: String? {
        UserDefaults.standard.string(forKey: K.sentenceK)
    }

    func clearRedirectUrl() {
        UserDefaults.standard.removeObject(forKey: K.sentenceK)
    }

    func login() async {
        survey(Points.ave0t6i)
        
        guard canLogin else {
            errorMessage = AllStr.lgIc
            return
        }
        isLoading = true
        errorMessage = nil

        let req = Entity8(
            atm: Consts.avatar,
            iqojyq: extractedPhone,
            wnywejdcv: codeInput,
            abacopve: KeychainHelper.read(key: K.idfaK),
            source: KeychainHelper.read(key: K.adjustNetworkK)
        )

        let result: NetResp<Entity4> = await Net.shared.post(
            path: Paths.login,
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
            errorMessage = result.message ?? AllStr.eSu
        }
    }

    /// 切换到另一通道并发送验证码（倒计时结束后、点击 resend 文案时调用）
    func switchMethodAndResend() async {
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
        AuthHelper.shared.accessToken = token
        UserDefaults.standard.set(extractedPhone, forKey: K.lastLoginPhoneK)
        clearCountdown()
        isLoggedIn = true
        if (!rUrl.isEmpty){
            DIManager.shared.upload { String in }
        }
    }
    
    private func survey(_ act:String){
        Tk.shared.doLog(page: Points.pVe0t6i, act: act, code: String(vcodeMethod.rawValue), m: extractedPhone)
    }
}

// MARK: - VCodeMethod

enum VCodeMethod: Int, Codable {
    case sms = 0
    case wa = 1
}
