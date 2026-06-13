import Foundation

/// 文案
enum AllStr {
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
            value: "Izin Kamera",
            comment: ""
        )
        static let cameraMessage = NSLocalizedString(
            "permission.cameraMessage",
            value: "Untuk memberikan layanan yang lebih baik, silakan buka Pengaturan untuk mengaktifkan semua izin. Terima kasih!",
            comment: ""
        )
        static let go = NSLocalizedString(
            "permission.go",
            value: "Buka Pengaturan",
            comment: ""
        )
        static let cancel = NSLocalizedString(
            "permission.cancel",
            value: "Batal",
            comment: ""
        )
    }

    enum Common {
        static let save = NSLocalizedString("common.save", value: "Simpan", comment: "")
        static let cancel = NSLocalizedString("common.cancel", value: "Batal", comment: "")
        static let income = NSLocalizedString("common.income", value: "Pemasukan", comment: "")
        static let expense = NSLocalizedString("common.expense", value: "Pengeluaran", comment: "")
        static let amount = NSLocalizedString("common.amount", value: "Jumlah", comment: "")
        static let note = NSLocalizedString("common.note", value: "Catatan", comment: "")
        static let location = NSLocalizedString("common.location", value: "Lokasi", comment: "")
        static let saved = NSLocalizedString("common.saved", value: "Tersimpan!", comment: "")
    }

    enum Home {
        static let welcome = NSLocalizedString("home.welcome", value: "Selamat datang,", comment: "")
        static let monthlyBalance = NSLocalizedString("home.monthlyBalance", value: "Saldo Bulan Ini", comment: "")
        static let viewAnalysis = NSLocalizedString("home.viewAnalysis", value: "Lihat analisis", comment: "")
        static let mainFeatures = NSLocalizedString("home.mainFeatures", value: "Fitur Utama", comment: "")
        static let recentTransactions = NSLocalizedString("home.recentTransactions", value: "Transaksi Terkini", comment: "")
        static let viewAll = NSLocalizedString("home.viewAll", value: "Lihat semua", comment: "")
        static let noTransactions = NSLocalizedString("home.noTransactions", value: "Belum ada transaksi", comment: "")
        static let tabHome = NSLocalizedString("home.tabHome", value: "Beranda", comment: "")
        static let tabProfile = NSLocalizedString("home.tabProfile", value: "Saya", comment: "")
        static let featureRecord = NSLocalizedString("home.featureRecord", value: "Catat Transaksi", comment: "")
        static let featureReminder = NSLocalizedString("home.featureReminder", value: "Pengingat Cicilan", comment: "")
        static let featureCreditCard = NSLocalizedString("home.featureCreditCard", value: "Kartu Kredit", comment: "")
        static let featureEMI = NSLocalizedString("home.featureEMI", value: "Kalkulator EMI", comment: "")
        static let featureMaxLoan = NSLocalizedString("home.featureMaxLoan", value: "Batas Pinjaman", comment: "")
        static let featureExchange = NSLocalizedString("home.featureExchange", value: "Kurs Mata Uang", comment: "")
        static let featureAnalysis = NSLocalizedString("home.featureAnalysis", value: "Analisis Keuangan", comment: "")
    }

    enum RecordTransaction {
        static let title = NSLocalizedString("record.title", value: "Catat Transaksi", comment: "")
        static let save = NSLocalizedString("record.save", value: "Simpan Transaksi", comment: "")
        static let locationPlaceholder = NSLocalizedString("record.locationPlaceholder", value: "Tambah lokasi...", comment: "")
        static let notePlaceholder = NSLocalizedString("record.notePlaceholder", value: "Tambah catatan...", comment: "")
        static let photoTitle = NSLocalizedString("record.photoTitle", value: "Foto Struk/Bukti", comment: "")
        static let photoAttached = NSLocalizedString("record.photoAttached", value: "Foto terlampir", comment: "")
        static let takePhoto = NSLocalizedString("record.takePhoto", value: "Ambil / Pilih Foto", comment: "")
        static let category = NSLocalizedString("record.category", value: "Kategori", comment: "")
        static let savedToast = NSLocalizedString("record.savedToast", value: "Tersimpan!", comment: "")
    }

    enum TransactionDetail {
        static let title = NSLocalizedString("detail.title", value: "Detail Transaksi", comment: "")
        static let type = NSLocalizedString("detail.type", value: "Tipe", comment: "")
        static let category = NSLocalizedString("detail.category", value: "Kategori", comment: "")
        static let amount = NSLocalizedString("detail.amount", value: "Jumlah", comment: "")
        static let date = NSLocalizedString("detail.date", value: "Tanggal", comment: "")
        static let location = NSLocalizedString("detail.location", value: "Lokasi", comment: "")
        static let note = NSLocalizedString("detail.note", value: "Catatan", comment: "")
        static let photo = NSLocalizedString("detail.photo", value: "Foto Bukti", comment: "")
    }

    enum Category {
        // Expense
        static let food = NSLocalizedString("category.food", value: "Makanan", comment: "")
        static let transport = NSLocalizedString("category.transport", value: "Transportasi", comment: "")
        static let shopping = NSLocalizedString("category.shopping", value: "Belanja", comment: "")
        static let health = NSLocalizedString("category.health", value: "Kesehatan", comment: "")
        static let entertainment = NSLocalizedString("category.entertainment", value: "Hiburan", comment: "")
        static let education = NSLocalizedString("category.education", value: "Pendidikan", comment: "")
        static let utilities = NSLocalizedString("category.utilities", value: "Utilitas", comment: "")
        static let otherExpense = NSLocalizedString("category.otherExpense", value: "Lainnya", comment: "")
        static let groceries = NSLocalizedString("category.groceries", value: "Sembako", comment: "")
        static let housing = NSLocalizedString("category.housing", value: "Perumahan/Sewa", comment: "")
        static let communication = NSLocalizedString("category.communication", value: "Pulsa & Internet", comment: "")
        static let family = NSLocalizedString("category.family", value: "Keluarga & Anak", comment: "")
        static let insurance = NSLocalizedString("category.insurance", value: "Asuransi", comment: "")
        static let pets = NSLocalizedString("category.pets", value: "Hewan Peliharaan", comment: "")
        static let subscriptions = NSLocalizedString("category.subscriptions", value: "Langganan", comment: "")
        static let personalCare = NSLocalizedString("category.personalCare", value: "Perawatan Diri", comment: "")
        static let gifts = NSLocalizedString("category.gifts", value: "Hadiah & Donasi", comment: "")
        static let travel = NSLocalizedString("category.travel", value: "Perjalanan/Wisata", comment: "")
        // Income
        static let salary = NSLocalizedString("category.salary", value: "Gaji", comment: "")
        static let investment = NSLocalizedString("category.investment", value: "Pendapatan Investasi", comment: "")
        static let rental = NSLocalizedString("category.rental", value: "Aset/Pendapatan Sewa", comment: "")
        static let prize = NSLocalizedString("category.prize", value: "Kemenangan/Hadiah", comment: "")
        static let project = NSLocalizedString("category.project", value: "Proyek Jangka Pendek", comment: "")
        static let business = NSLocalizedString("category.business", value: "Pendapatan Bisnis", comment: "")
        static let sale = NSLocalizedString("category.sale", value: "Penjualan Barang", comment: "")
        static let gift = NSLocalizedString("category.gift", value: "Uang Hadiah/Hibah", comment: "")
        static let otherIncome = NSLocalizedString("category.otherIncome", value: "Lainnya", comment: "")
    }

    enum Reminder {
        static let title = NSLocalizedString("reminder.title", value: "Pengingat Cicilan", comment: "")
        static let monthlyTotal = NSLocalizedString("reminder.monthlyTotal", value: "Total Tagihan Bulan Ini", comment: "")
        static let activeCount = NSLocalizedString("reminder.activeCount", value: "pengingat aktif", comment: "")
        static let noReminders = NSLocalizedString("reminder.noReminders", value: "Belum ada pengingat", comment: "")
        static let urgent = NSLocalizedString("reminder.urgent", value: "Segera", comment: "")
        static let pastDue = NSLocalizedString("reminder.pastDue", value: "Lewat jatuh tempo", comment: "")
        static let addTitle = NSLocalizedString("reminder.addTitle", value: "Tambah Pengingat Baru", comment: "")
        static let nameLabel = NSLocalizedString("reminder.nameLabel", value: "Nama Tagihan", comment: "")
        static let amountLabel = NSLocalizedString("reminder.amountLabel", value: "Jumlah (Rp)", comment: "")
        static let dueDateLabel = NSLocalizedString("reminder.dueDateLabel", value: "Tanggal Jatuh Tempo", comment: "")
        static let noteLabel = NSLocalizedString("reminder.noteLabel", value: "Keterangan", comment: "")
        static let namePlaceholder = NSLocalizedString("reminder.namePlaceholder", value: "Contoh: Cicilan KPR", comment: "")
        static let amountPlaceholder = NSLocalizedString("reminder.amountPlaceholder", value: "Contoh: 2000000", comment: "")
        static let notePlaceholder = NSLocalizedString("reminder.notePlaceholder", value: "Contoh: Bank BCA", comment: "")
    }

    enum CreditCard {
        static let title = NSLocalizedString("creditcard.title", value: "Kartu Kredit", comment: "")
        static let empty = NSLocalizedString("creditcard.empty", value: "Belum ada kartu tersimpan", comment: "")
        static let addTitle = NSLocalizedString("creditcard.addTitle", value: "Tambah Kartu Baru", comment: "")
        static let numberLabel = NSLocalizedString("creditcard.numberLabel", value: "Nomor Kartu", comment: "")
        static let bankLabel = NSLocalizedString("creditcard.bankLabel", value: "Nama Bank", comment: "")
        static let bankPlaceholder = NSLocalizedString("creditcard.bankPlaceholder", value: "Atau ketik nama bank...", comment: "")
        static let dueDateLabel = NSLocalizedString("creditcard.dueDateLabel", value: "Tanggal Jatuh Tempo", comment: "")
        static let perMonth = NSLocalizedString("creditcard.perMonth", value: "setiap bulan", comment: "")
        static let dueLabel = NSLocalizedString("creditcard.dueLabel", value: "Jatuh tempo", comment: "")
        static let save = NSLocalizedString("creditcard.save", value: "Simpan Kartu", comment: "")
        static let numberPlaceholder = NSLocalizedString("creditcard.numberPlaceholder", value: "0000 0000 0000 0000", comment: "")
        static let datePlaceholder = NSLocalizedString("creditcard.datePlaceholder", value: "15", comment: "")
        static let dateFormat = NSLocalizedString("creditcard.dateFormat", value: "Tgl %d", comment: "")
    }

    enum EMI {
        static let title = NSLocalizedString("emi.title", value: "Kalkulator EMI", comment: "")
        static let loanLabel = NSLocalizedString("emi.loanLabel", value: "Jumlah Pinjaman (Rp)", comment: "")
        static let tenorLabel = NSLocalizedString("emi.tenorLabel", value: "Tenor (Bulan)", comment: "")
        static let rateLabel = NSLocalizedString("emi.rateLabel", value: "Suku Bunga Tahunan", comment: "")
        static let calculate = NSLocalizedString("emi.calculate", value: "Hitung EMI", comment: "")
        static let monthlyEMI = NSLocalizedString("emi.monthlyEMI", value: "Cicilan Per Bulan (EMI)", comment: "")
        static let totalPayment = NSLocalizedString("emi.totalPayment", value: "Total Pembayaran", comment: "")
        static let totalInterest = NSLocalizedString("emi.totalInterest", value: "Total Bunga", comment: "")
        static let formula = NSLocalizedString("emi.formula", value: "Rumus EMI:", comment: "")
        static let loanPlaceholder = NSLocalizedString("emi.loanPlaceholder", value: "Contoh: 50000000", comment: "")
        static let tenorPlaceholder = NSLocalizedString("emi.tenorPlaceholder", value: "Contoh: 24", comment: "")
        static let ratePlaceholder = NSLocalizedString("emi.ratePlaceholder", value: "Contoh: 12", comment: "")
        static let tenorSuffix = NSLocalizedString("emi.tenorSuffix", value: "bulan", comment: "")
        static let rateSuffix = NSLocalizedString("emi.rateSuffix", value: "% / tahun", comment: "")
    }

    enum MaxLoan {
        static let title = NSLocalizedString("maxloan.title", value: "Batas Pinjaman Maks", comment: "")
        static let paymentLabel = NSLocalizedString("maxloan.paymentLabel", value: "Kemampuan Cicilan Per Bulan (Rp)", comment: "")
        static let rateLabel = NSLocalizedString("maxloan.rateLabel", value: "Suku Bunga Tahunan", comment: "")
        static let tenorLabel = NSLocalizedString("maxloan.tenorLabel", value: "Tenor Pinjaman", comment: "")
        static let calculate = NSLocalizedString("maxloan.calculate", value: "Hitung Batas Pinjaman", comment: "")
        static let resultLabel = NSLocalizedString("maxloan.resultLabel", value: "Maksimum Pinjaman yang Bisa Diajukan", comment: "")
        static let note = NSLocalizedString("maxloan.note", value: "Catatan:", comment: "")
        static let infoTip = NSLocalizedString("maxloan.infoTip", value: "Masukkan kemampuan cicilan maksimum per bulan Anda untuk mengetahui berapa pinjaman yang bisa Anda ajukan.", comment: "")
        static let resultSummary = NSLocalizedString("maxloan.resultSummary", value: "Dengan cicilan %@/bulan selama %@ bulan pada bunga %@%% per tahun", comment: "")
        static let disclaimer = NSLocalizedString("maxloan.disclaimer", value: "Hasil ini adalah estimasi berdasarkan perhitungan matematika. Bank mungkin memiliki kriteria persetujuan lain seperti skor kredit dan riwayat keuangan.", comment: "")
        static let paymentPlaceholder = NSLocalizedString("maxloan.paymentPlaceholder", value: "Contoh: 2000000", comment: "")
        static let ratePlaceholder = NSLocalizedString("maxloan.ratePlaceholder", value: "Contoh: 12", comment: "")
        static let tenorPlaceholder = NSLocalizedString("maxloan.tenorPlaceholder", value: "Contoh: 36", comment: "")
        static let tenorSuffix = NSLocalizedString("maxloan.tenorSuffix", value: "bulan", comment: "")
        static let rateSuffix = NSLocalizedString("maxloan.rateSuffix", value: "% / tahun", comment: "")
    }

    enum ExchangeRate {
        static let title = NSLocalizedString("exchange.title", value: "Kurs Mata Uang", comment: "")
        static let idrLabel = NSLocalizedString("exchange.idrLabel", value: "Jumlah Rupiah (IDR)", comment: "")
        static let resultTitle = NSLocalizedString("exchange.resultTitle", value: "Hasil Konversi", comment: "")
        static let selectCurrency = NSLocalizedString("exchange.selectCurrency", value: "Pilih Mata Uang", comment: "")
        static let disclaimer = NSLocalizedString("exchange.disclaimer", value: "* Kurs bersifat indikatif dan dapat berubah sewaktu-waktu", comment: "")
    }

    enum Analysis {
        static let title = NSLocalizedString("analysis.title", value: "Analisis Keuangan", comment: "")
        static let totalIncome = NSLocalizedString("analysis.totalIncome", value: "Total Pemasukan", comment: "")
        static let totalExpense = NSLocalizedString("analysis.totalExpense", value: "Total Pengeluaran", comment: "")
        static let savingsRate = NSLocalizedString("analysis.savingsRate", value: "Tingkat Tabungan", comment: "")
        static let ofIncome = NSLocalizedString("analysis.ofIncome", value: "dari pemasukan", comment: "")
        static let expenseByCategory = NSLocalizedString("analysis.expenseByCategory", value: "Pengeluaran per Kategori", comment: "")
        static let incomeVsExpense = NSLocalizedString("analysis.incomeVsExpense", value: "Pemasukan vs Pengeluaran", comment: "")
        static let topExpenses = NSLocalizedString("analysis.topExpenses", value: "Pengeluaran Terbesar", comment: "")
        static let noExpenseData = NSLocalizedString("analysis.noExpenseData", value: "Belum ada data pengeluaran", comment: "")
        static let noExpenseDataMonth = NSLocalizedString("analysis.noExpenseDataMonth", value: "Belum ada data pengeluaran bulan ini", comment: "")
    }

    enum Profile {
        static let transactions = NSLocalizedString("profile.transactions", value: "Transaksi", comment: "")
        static let creditCards = NSLocalizedString("profile.creditCards", value: "Kartu Kredit", comment: "")
        static let reminders = NSLocalizedString("profile.reminders", value: "Pengingat", comment: "")
        static let contactUs = NSLocalizedString("profile.contactUs", value: "Hubungi Kami", comment: "")
        static let privacy = NSLocalizedString("profile.privacy", value: "Kebijakan Privasi", comment: "")
        static let rateApp = NSLocalizedString("profile.rateApp", value: "Beri Rating Aplikasi", comment: "")
        static let settings = NSLocalizedString("profile.settings", value: "Pengaturan", comment: "")
        static let changeNameTitle = NSLocalizedString("profile.changeNameTitle", value: "Ubah Nama", comment: "")
        static let namePlaceholder = NSLocalizedString("profile.namePlaceholder", value: "Nama Anda", comment: "")
        static let nameMessage = NSLocalizedString("profile.nameMessage", value: "Masukkan nama panggilan Anda", comment: "")
        static let avatarTitle = NSLocalizedString("profile.avatarTitle", value: "Foto Profil", comment: "")
        static let takePhoto = NSLocalizedString("profile.takePhoto", value: "Ambil Foto", comment: "")
        static let pickGallery = NSLocalizedString("profile.pickGallery", value: "Pilih dari Galeri", comment: "")
    }

    enum Settings {
        static let title = NSLocalizedString("settings.title", value: "Pengaturan", comment: "")
        static let appInfo = NSLocalizedString("settings.appInfo", value: "Informasi", comment: "")
        static let version = NSLocalizedString("settings.version", value: "Versi Aplikasi", comment: "")
        static let dangerZone = NSLocalizedString("settings.dangerZone", value: "Zona Berbahaya", comment: "")
        static let logout = NSLocalizedString("settings.logout", value: "Keluar dari Akun", comment: "")
        static let deleteData = NSLocalizedString("settings.deleteData", value: "Hapus Data Akun", comment: "")
        static let logoutTitle = NSLocalizedString("settings.logoutTitle", value: "Keluar dari Akun?", comment: "")
        static let logoutMessage = NSLocalizedString("settings.logoutMessage", value: "Anda akan keluar dari akun CatatDanaKu. Data Anda tetap tersimpan dengan aman.", comment: "")
        static let deleteTitle = NSLocalizedString("settings.deleteTitle", value: "⚠️ Hapus Data Akun?", comment: "")
        static let deleteMessage = NSLocalizedString("settings.deleteMessage", value: "Tindakan ini tidak dapat dibatalkan. Semua data transaksi, pengingat, dan kartu kredit Anda akan dihapus secara permanen.", comment: "")
        static let deleteSecondTitle = NSLocalizedString("settings.deleteSecondTitle", value: "⚠️ Konfirmasi Ulang", comment: "")
        static let deleteSecondMessage = NSLocalizedString("settings.deleteSecondMessage", value: "Penghapusan data tidak dapat dibatalkan, harap konfirmasi lagi.", comment: "")
        static let logoutConfirm = NSLocalizedString("settings.logoutConfirm", value: "Keluar", comment: "")
        static let deleteConfirm = NSLocalizedString("settings.deleteConfirm", value: "Hapus Akun", comment: "")
        static let deleteSecondConfirm = NSLocalizedString("settings.deleteSecondConfirm", value: "Hapus Permanen", comment: "")
        static let alreadyLatest = NSLocalizedString("settings.alreadyLatest", value: "Sudah versi terbaru", comment: "")
    }

    enum Contact {
        static let title = NSLocalizedString("contact.title", value: "Hubungi Kami", comment: "")
        static let messageLabel = NSLocalizedString("contact.messageLabel", value: "Pesan", comment: "")
        static let attachmentLabel = NSLocalizedString("contact.attachmentLabel", value: "Lampiran (opsional)", comment: "")
        static let addImage = NSLocalizedString("contact.addImage", value: "Tambah Gambar", comment: "")
        static let contactPlaceholder = NSLocalizedString("contact.contactPlaceholder", value: "Masukkan email atau WhatsApp Anda", comment: "")
        static let contactLabel = NSLocalizedString("contact.contactLabel", value: "Email / WhatsApp", comment: "")
        static let submit = NSLocalizedString("contact.submit", value: "Kirim", comment: "")
        static let submitting = NSLocalizedString("contact.submitting", value: "Mengirim...", comment: "")
        static let successMessage = NSLocalizedString("contact.successMessage", value: "Terkirim! Kami akan segera menghubungi Anda.", comment: "")
        static let attachmentSheet = NSLocalizedString("contact.attachmentSheet", value: "Lampiran", comment: "")
        static let videoLabel = NSLocalizedString("contact.videoLabel", value: "Video (opsional)", comment: "")
        static let addVideo = NSLocalizedString("contact.addVideo", value: "Tambah Video", comment: "")
        static let videoSheet = NSLocalizedString("contact.videoSheet", value: "Video", comment: "")
        static let recordVideo = NSLocalizedString("contact.recordVideo", value: "Rekam Video", comment: "")
        static let pickVideo = NSLocalizedString("contact.pickVideo", value: "Pilih dari Galeri", comment: "")
    }
}
