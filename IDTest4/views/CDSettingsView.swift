import SwiftUI

//
//  CDSettingsView.swift
//  CatatDanaKu
//
//  Created by lishen on 2026/6/7.
//

struct CDSettingsView: View {
    let onBack: () -> Void

    @State private var vm = CDSettingsViewModel()

    private var appVersion: String {
        let info = Bundle.main.infoDictionary
        return info?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    }

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                pageHeader
                ScrollView {
                    VStack(spacing: 20) {
                        appInfoSection
                        dangerZone
                    }
                    .padding(20)
                }
            }
            .background(AppColors.launchBackground)

            // 确认弹窗
            if vm.showLogoutConfirm { logoutOverlay }
            if vm.showDeleteConfirm { deleteOverlay }
            if vm.showDeleteSecondConfirm { deleteSecondOverlay }
        }
        .animation(.easeInOut(duration: 0.2), value: vm.showLogoutConfirm)
        .animation(.easeInOut(duration: 0.2), value: vm.showDeleteConfirm)
        .animation(.easeInOut(duration: 0.2), value: vm.showDeleteSecondConfirm)
        .toast(isPresented: $vm.showVersionToast, message: AllStr.stAl)
    }

    // MARK: - Header

    private var pageHeader: some View {
        HStack(spacing: 12) {
            Button(action: onBack) {
                ZStack {
                    Circle().fill(AppColors.launchBackground).frame(width: 36, height: 36)
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(AppColors.strPrimary)
                }
            }
            Text(AllStr.stT)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(AppColors.strPrimary)
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
        .padding(.bottom, 12)
        .background(Color.white)
    }

    // MARK: - App Info (INFORMASI)

    private var appInfoSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            sectionHeader(AllStr.stAi)

            VStack(spacing: 0) {
                Button {
                    Task { await vm.checkVersion() }
                } label: {
                    infoRow(AllStr.stV, appVersion)
                }
                .buttonStyle(.plain)
            }
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.06), radius: 2, y: 1)
        }
    }

    private func infoRow(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 14))
                .foregroundColor(AppColors.strSecondary)
            Spacer()
            Text(value)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(AppColors.strPrimary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }

    // MARK: - Danger Zone

    private var dangerZone: some View {
        VStack(alignment: .leading, spacing: 0) {
            sectionHeader(AllStr.stDz)

            VStack(spacing: 0) {
                dangerButton(
                    icon: "arrow.right.square.fill",
                    iconBg: Color(hex: "#FFF3E0"),
                    iconColor: Color(hex: "#FF9500"),
                    label: AllStr.stLo,
                    labelColor: Color(hex: "#FF9500")
                ) {
                    vm.showLogoutConfirm = true
                }

                Divider().padding(.leading, 56)

                dangerButton(
                    icon: "trash.fill",
                    iconBg: Color(hex: "#FFE8E8"),
                    iconColor: Color(hex: "#FF4444"),
                    label: AllStr.stDd,
                    labelColor: Color(hex: "#FF4444")
                ) {
                    vm.showDeleteConfirm = true
                }
            }
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.06), radius: 2, y: 1)
        }
    }

    private func dangerButton(icon: String, iconBg: Color, iconColor: Color, label: String, labelColor: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(iconBg)
                        .frame(width: 36, height: 36)
                    Image(systemName: icon)
                        .font(.system(size: 16))
                        .foregroundColor(iconColor)
                }
                Text(label)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(labelColor)
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
        }
    }

    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.system(size: 12, weight: .semibold))
            .foregroundColor(AppColors.strHint)
            .textCase(.uppercase)
            .padding(.leading, 4)
            .padding(.bottom, 8)
    }

    // MARK: - Logout Overlay

    private var logoutOverlay: some View {
        ZStack {
            Color.black.opacity(0.4).ignoresSafeArea()
                .onTapGesture { vm.showLogoutConfirm = false }

            VStack(spacing: 0) {
                Spacer()
                VStack(spacing: 0) {
                    Text(AllStr.stLt)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(AppColors.strPrimary)
                        .padding(.bottom, 8)
                    Text(AllStr.stLm)
                        .font(.system(size: 14))
                        .foregroundColor(AppColors.strSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.bottom, 24)

                    HStack(spacing: 12) {
                        Button { vm.showLogoutConfirm = false } label: {
                            Text(AllStr.cmC)
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(AppColors.strPrimary)
                                .frame(maxWidth: .infinity).frame(height: 48)
                                .background(AppColors.launchBackground)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                        Button {
                            vm.showLogoutConfirm = false
                            Task {
                                await vm.logout()
                                onBack()
                            }
                        } label: {
                            Text(AllStr.stLc)
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(AppColors.strPrimary)
                                .frame(maxWidth: .infinity).frame(height: 48)
                                .background(AppColors.launchBackground)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                    }
                }
                .padding(24)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 24))
                .padding(.horizontal, 20)
                .padding(.bottom, 32)
            }
        }
    }

    // MARK: - Delete Overlay (first confirmation)

    private var deleteOverlay: some View {
        ZStack {
            Color.black.opacity(0.4).ignoresSafeArea()
                .onTapGesture { vm.showDeleteConfirm = false }

            VStack(spacing: 0) {
                Spacer()
                VStack(spacing: 0) {
                    Text(AllStr.stDt)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(Color(hex: "#FF4444"))
                        .padding(.bottom, 8)
                    Text(AllStr.stDm)
                        .font(.system(size: 14))
                        .foregroundColor(AppColors.strSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.bottom, 24)

                    HStack(spacing: 12) {
                        Button { vm.showDeleteConfirm = false } label: {
                            Text(AllStr.cmC)
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(AppColors.strPrimary)
                                .frame(maxWidth: .infinity).frame(height: 48)
                                .background(AppColors.launchBackground)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                        Button {
                            vm.showDeleteConfirm = false
                            vm.showDeleteSecondConfirm = true
                        } label: {
                            Text(AllStr.stDc)
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(AppColors.strPrimary)
                                .frame(maxWidth: .infinity).frame(height: 48)
                                .background(AppColors.launchBackground)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                    }
                }
                .padding(24)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 24))
                .padding(.horizontal, 20)
                .padding(.bottom, 32)
            }
        }
    }

    // MARK: - Delete Second Overlay

    private var deleteSecondOverlay: some View {
        ZStack {
            Color.black.opacity(0.4).ignoresSafeArea()
                .onTapGesture { vm.showDeleteSecondConfirm = false }

            VStack(spacing: 0) {
                Spacer()
                VStack(spacing: 0) {
                    Text(AllStr.stDs)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(Color(hex: "#FF4444"))
                        .padding(.bottom, 8)
                    Text(AllStr.stDsm)
                        .font(.system(size: 14))
                        .foregroundColor(AppColors.strPrimary)
                        .multilineTextAlignment(.center)
                        .padding(.bottom, 24)

                    HStack(spacing: 12) {
                        Button { vm.showDeleteSecondConfirm = false } label: {
                            Text(AllStr.cmC)
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(AppColors.strPrimary)
                                .frame(maxWidth: .infinity).frame(height: 48)
                                .background(AppColors.launchBackground)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                        Button {
                            vm.showDeleteSecondConfirm = false
                            Task {
                                await vm.deleteAccount()
                                onBack()
                            }
                        } label: {
                            Text(AllStr.stDsc)
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(AppColors.strPrimary)
                                .frame(maxWidth: .infinity).frame(height: 48)
                                .background(AppColors.launchBackground)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                    }
                }
                .padding(24)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 24))
                .padding(.horizontal, 20)
                .padding(.bottom, 32)
            }
        }
    }

}
