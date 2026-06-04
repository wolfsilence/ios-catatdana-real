import Foundation

/// 文案
enum Strings {
    enum Error {
        static let serverUnavailable = NSLocalizedString(
            "error.serverUnavailable",
            value: "Server sedang sibuk, silakan coba lagi nanti",
            comment: ""
        )
    }

    enum Launch {
        static let appName = NSLocalizedString(
            "launch.appName",
            value: "Catat DanaKu",
            comment: ""
        )
        static let tagline = NSLocalizedString(
            "launch.tagline",
            value: "Catat pengeluaran dengan mudah",
            comment: ""
        )
    }

    enum Privacy {
        static let agree = NSLocalizedString(
            "privacy.agree",
            value: "Setuju",
            comment: ""
        )
        static let disagree = NSLocalizedString(
            "privacy.disagree",
            value: "Tidak Setuju",
            comment: ""
        )
        static let alertMessage = NSLocalizedString(
            "privacy.alert",
            value: "Anda harus menyetujui kebijakan privasi untuk melanjutkan",
            comment: ""
        )
        static let alertOK = NSLocalizedString(
            "privacy.alertOK",
            value: "OK",
            comment: ""
        )
        static let description = NSLocalizedString(
            "privacy.description",
            value: "Harap baca dan setujui kebijakan privasi berikut dengan saksama.",
            comment: ""
        )
        static let toastWait = NSLocalizedString(
            "privacy.toastWait",
            value: "Harap tunggu hingga perjanjian privasi selesai dimuat.",
            comment: ""
        )
    }

    enum Login {
        static let phoneHint = NSLocalizedString(
            "login.phoneHint",
            value: "Masukkan no. ponsel",
            comment: ""
        )
        static let codeHint = NSLocalizedString(
            "login.codeHint",
            value: "Kode verifikasi",
            comment: ""
        )
        static let sendCode = NSLocalizedString(
            "login.sendCode",
            value: "Kirim Kode",
            comment: ""
        )
        static let waLogin = NSLocalizedString(
            "login.waLogin",
            value: "Kirim kode via WhatsApp",
            comment: ""
        )
        static let smsLogin = NSLocalizedString(
            "login.smsLogin",
            value: "Kirim kode via SMS",
            comment: ""
        )
        static let waHint = NSLocalizedString(
            "login.waHint",
            value: "*Kode verifikasi akan dikirim via WhatsApp.",
            comment: ""
        )
        static let sentToSms = NSLocalizedString(
            "login.sentToSms",
            value: "Kode verifikasi telah dikirim ke SMS Anda.",
            comment: ""
        )
        static let sentToWa = NSLocalizedString(
            "login.sentToWa",
            value: "Kode verifikasi telah dikirim ke WhatsApp Anda.",
            comment: ""
        )
        static let resendViaWa = NSLocalizedString(
            "login.resendViaWa",
            value: "Tidak menerima kode? Kirim via WhatsApp.",
            comment: ""
        )
        static let resendViaSms = NSLocalizedString(
            "login.resendViaSms",
            value: "Tidak menerima kode? Kirim via SMS.",
            comment: ""
        )
        static let privacyPrefix = NSLocalizedString(
            "login.privacyPrefix",
            value: "Pastikan Anda menyetujui ",
            comment: ""
        )
        static let privacyLink = NSLocalizedString(
            "login.privacyLink",
            value: "kebijakan privasi",
            comment: ""
        )
        static let privacySuffix = NSLocalizedString(
            "login.privacySuffix",
            value: " kami",
            comment: ""
        )
        static let invalidPhone = NSLocalizedString(
            "login.invalidPhone",
            value: "Silakan masukkan nomor ponsel yang valid.",
            comment: ""
        )
        static let invalidCode = NSLocalizedString(
            "login.invalidCode",
            value: "Silakan masukkan kode verifikasi 4 digit.",
            comment: ""
        )
        static let loginButton = NSLocalizedString(
            "login.loginButton",
            value: "Masuk",
            comment: ""
        )
        static let title = NSLocalizedString(
            "login.title",
            value: "Masuk atau Daftar",
            comment: ""
        )
        static let countryCode = NSLocalizedString(
            "login.countryCode",
            value: "+62",
            comment: ""
        )
        static let privacySheetTitle = NSLocalizedString(
            "login.privacySheetTitle",
            value: "Kebijakan Privasi",
            comment: ""
        )
        static let close = NSLocalizedString(
            "login.close",
            value: "Tutup",
            comment: ""
        )
    }

    enum Permission {
        static let cameraTitle = NSLocalizedString(
            "permission.cameraTitle",
            value: "Camera Permission",
            comment: ""
        )
        static let cameraMessage = NSLocalizedString(
            "permission.cameraMessage",
            value: "To provide better service, please go to Settings to enable all permissions. Thank you!",
            comment: ""
        )
        static let go = NSLocalizedString(
            "permission.go",
            value: "Go",
            comment: ""
        )
        static let cancel = NSLocalizedString(
            "permission.cancel",
            value: "Cancel",
            comment: ""
        )
    }
}
