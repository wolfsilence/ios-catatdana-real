import SwiftUI

//
//  CDMainView.swift
//  CatatDanaKu
//
//  Created by lishen on 2026/6/3.
//

/// 主页（已登录状态）—— 首页 + 个人中心 + 所有功能子页面
struct CDHostView: View {
    @State private var vm = CDHostViewModel()
    @State private var activeFeature: MainFeature? = nil
    @State private var selectedTransaction: EntityTrade? = nil

    var body: some View {
        ZStack {
            AppColors.launchBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                // 主内容区
                ZStack {
                    if vm.selectedTab == .home {
                        homeContent
                    } else {
                        CDMeView(
                            onSettings: { activeFeature = .settings },
                            onPrivacy: { activeFeature = .privacyView },
                            onContact: { activeFeature = .contact },
                            onLogout: {
                                AuthHelper.shared.clearToken()
                                UserDefaults.standard.removeObject(forKey: K.lastLoginPhoneK)
                                NotificationCenter.default.post(name: NSNotification.Name(NotiName.Logout), object: nil)
                            },
                            transactionsCount: vm.transactions.count,
                            cardsCount: vm.creditCards.count,
                            remindersCount: vm.reminders.count,
                            userName: vm.displayName,
                            userPhone: vm.userPhone,
                            userInitial: vm.userInitial,
                            avatarURL: vm.avatarURL,
                            onAvatarChanged: { vm.updateAvatarURL($0) },
                            onNicknameChanged: { vm.updateNickname($0) }
                        )
                    }

                    // 功能子页面覆盖层
                    if let feature = activeFeature {
                        featureOverlay(for: feature)
                            .transition(.move(edge: .trailing))
                            .zIndex(10)
                    }
                }

                // 底部 Tab 栏 —— 只在无覆盖层时显示
                if activeFeature == nil {
                    bottomTabBar
                }
            }
        }
        .animation(.easeInOut(duration: 0.3), value: activeFeature)
        .fullScreenCover(item: $selectedTransaction) { tx in
            CDRecordDetailView(transaction: tx, onBack: { selectedTransaction = nil })
        }
        .onAppear { vm.refreshData() }
    }

    // MARK: - Home Content

    private var homeContent: some View {
        ScrollView {
            VStack(spacing: 0) {
                welcomeHeader
                balanceCard
                featureGrid
                recentTransactionsSection
            }
            .padding(.bottom, 16)
        }
        .padding(.top, 8)
    }

    // MARK: - Welcome Header

    private var welcomeHeader: some View {
        HStack(spacing: 12) {
            // 头像 —— 最左边
            Group {
                if let url = URL(string: vm.avatarURL), !vm.avatarURL.isEmpty {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let image):
                            image.resizable().scaledToFill()
                        default:
                            avatarInitialView
                        }
                    }
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
                } else {
                    avatarInitialView
                }
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(AllStr.hW)
                    .font(.system(size: 13))
                    .foregroundColor(AppColors.strSecondary)
                Text("\(vm.displayName) 👋")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(AppColors.strPrimary)
            }
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 12)
    }

    private var avatarInitialView: some View {
        Circle()
            .fill(LinearGradient(
                colors: [Color(hex: "#1BC459"), Color(hex: "#13A048")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ))
            .frame(width: 40, height: 40)
            .overlay(
                Text(vm.userInitial)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.white)
            )
    }

    // MARK: - Balance Card

    private var balanceCard: some View {
        Button {
            withAnimation { activeFeature = .analysis }
        } label: {
            VStack(spacing: 0) {
                HStack {
                    Text(AllStr.hMb)
                        .font(.system(size: 13))
                        .foregroundColor(.white.opacity(0.8))
                    Spacer()
                    HStack(spacing: 4) {
                        Text(AllStr.hVa)
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.8))
                        Image(systemName: "chevron.right")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
                .padding(.bottom, 4)

                Text(formatIDR(vm.balance))
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.bottom, 16)

                HStack(spacing: 24) {
                    summaryItem(icon: "arrow.up", label: AllStr.cmI, amount: vm.totalIncome)
                    summaryItem(icon: "arrow.down", label: AllStr.cmE, amount: vm.totalExpense)
                }
                .padding(.bottom, 12)

                HStack {
                    monthLabel
                    Spacer()
                }
            }
            .padding(20)
            .background(
                LinearGradient(
                    colors: [Color(hex: "#1BC459"), Color(hex: "#13A048")],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .shadow(color: Color(hex: "#1BC459").opacity(0.3), radius: 8, y: 4)
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
    }

    private func summaryItem(icon: String, label: String, amount: Double) -> some View {
        HStack(spacing: 6) {
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.2))
                    .frame(width: 20, height: 20)
                Image(systemName: icon)
                    .font(.system(size: 9, weight: .bold))
                    .foregroundColor(.white)
            }
            VStack(alignment: .leading, spacing: 1) {
                Text(label)
                    .font(.system(size: 11))
                    .foregroundColor(.white.opacity(0.8))
                Text(formatIDR(amount))
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
            }
        }
    }

    private var monthLabel: some View {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        formatter.locale = Locale(identifier: "id_ID")
        return Text(formatter.string(from: Date()))
            .font(.system(size: 11, weight: .semibold))
            .foregroundColor(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 4)
            .background(Color.white.opacity(0.2))
            .clipShape(Capsule())
    }

    // MARK: - Feature Grid

    private var featureGrid: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(AllStr.hMf)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(AppColors.strPrimary)
                .padding(.horizontal, 20)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 3), spacing: 12) {
                ForEach(MainFeature.homeGrid) { feature in
                    featureButton(feature)
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(.bottom, 20)
    }

    private func featureButton(_ feature: MainFeature) -> some View {
        Button {
            withAnimation { activeFeature = feature }
        } label: {
            VStack(spacing: 8) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(feature.bgColor)
                        .frame(width: 48, height: 48)
                        .shadow(color: feature.bgColor.opacity(0.3), radius: 4, y: 2)
                    Image(systemName: feature.iconName)
                        .font(.system(size: 18))
                        .foregroundColor(.white)
                }
                Text(feature.label)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(AppColors.strPrimary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .padding(.horizontal, 6)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.06), radius: 2, y: 1)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Recent Transactions

    private var recentTransactionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(AllStr.hRt)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(AppColors.strPrimary)
                Spacer()
                Text(AllStr.hVal)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(AppColors.primary)
            }
            .padding(.horizontal, 20)

            if vm.recentTransactions.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "tray")
                        .font(.system(size: 32))
                        .foregroundColor(AppColors.strHint)
                    Text(AllStr.hNt)
                        .font(.system(size: 14))
                        .foregroundColor(AppColors.strSecondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 32)
            } else {
                VStack(spacing: 0) {
                    ForEach(Array(vm.recentTransactions.enumerated()), id: \.element.id) { idx, tx in
                        transactionRow(tx)
                        if idx < vm.recentTransactions.count - 1 {
                            Divider().padding(.leading, 56)
                        }
                    }
                }
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: .black.opacity(0.06), radius: 2, y: 1)
                .padding(.horizontal, 20)
            }
        }
    }

    private func transactionRow(_ tx: EntityTrade) -> some View {
        Button {
            selectedTransaction = tx
        } label: {
            HStack(spacing: 12) {
                // 分类图标
                RoundedRectangle(cornerRadius: 10)
                    .fill(AppColors.launchBackground)
                    .frame(width: 40, height: 40)
                    .overlay(
                        Text(TransactionCategory.all.first { $0.id == tx.category }?.icon ?? "📦")
                            .font(.system(size: 18))
                    )

                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 4) {
                        Text(categoryLabel(for: tx.category))
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(AppColors.strPrimary)
                        Text(tx.type == .income ? AllStr.cmI : AllStr.cmE)
                            .font(.system(size: 12))
                            .foregroundColor(AppColors.strHint)
                    }
                    Text(relativeDate(tx.date))
                        .font(.system(size: 12))
                        .foregroundColor(AppColors.strHint)
                }
                Spacer()
                Text(tx.type == .income ? "+\(formatIDR(tx.num))" : "-\(formatIDR(tx.num))")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(tx.type == .income ? AppColors.primary : .red)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Bottom Tab Bar

    private var bottomTabBar: some View {
        HStack(spacing: 0) {
            ForEach(MainTab.allCases, id: \.self) { tab in
                Button {
                    withAnimation { vm.selectedTab = tab }
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: tab == vm.selectedTab ? "\(tab.icon)" : tab.icon)
                            .font(.system(size: 20))
                            .foregroundColor(tab == vm.selectedTab ? AppColors.primary : AppColors.strHint)
                        Text(tab.label)
                            .font(.system(size: 11, weight: tab == vm.selectedTab ? .semibold : .regular))
                            .foregroundColor(tab == vm.selectedTab ? AppColors.primary : AppColors.strHint)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                }
            }
        }
        .frame(height: 56)
        .background(Color.white)
        .shadow(color: .black.opacity(0.06), radius: 1, y: -1)
    }

    // MARK: - Feature Overlay

    @ViewBuilder
    private func featureOverlay(for feature: MainFeature) -> some View {
        switch feature {
        case .record:
            CDRecordView(onBack: { activeFeature = nil }, onSaved: { vm.refreshData() })
        case .reminder:
            CDRepayReminderView(onBack: { activeFeature = nil })
        case .creditcard:
            CDBankCardBindView(onBack: { activeFeature = nil })
        case .emi:
            CDEMICalcView(onBack: { activeFeature = nil })
        case .maxloan:
            CDMaxCanCalcView(onBack: { activeFeature = nil })
        case .exchange:
            CDCalcRateView(onBack: { activeFeature = nil })
        case .analysis:
            CDFinAnalysisView(onBack: { activeFeature = nil })
        case .settings:
            CDSettingsView(onBack: { activeFeature = nil })
        case .privacyView:
            CDPrivacySheetView(onBack: { activeFeature = nil })
        case .contact:
            CDContactUsView(onBack: { activeFeature = nil })
        }
    }

    // MARK: - Helpers

    private func categoryLabel(for categoryId: String) -> String {
        TransactionCategory.all.first { $0.id == categoryId }?.label ?? categoryId
    }

    private func relativeDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.locale = Locale(identifier: "id_ID")
        return formatter.localizedString(for: date, relativeTo: Date())
    }

}

// MARK: - IDR Formatter

func formatIDR(_ amount: Double) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.currencyCode = "IDR"
    formatter.maximumFractionDigits = 0
    formatter.locale = Locale(identifier: "id_ID")
    return formatter.string(from: NSNumber(value: amount)) ?? "Rp 0"
}

// MARK: - Privacy Sheet (minimal — just CDWebView)

private struct CDPrivacySheetView: View {
    let onBack: () -> Void

    var body: some View {
        CDWebView(
            url: URL(string: Consts.ppUrl)!,
            title: AllStr.pfPr,
            onBack: onBack
        )
    }
}
