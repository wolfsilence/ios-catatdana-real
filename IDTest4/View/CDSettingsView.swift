import SwiftUI

//
//  CDSettingsView.swift
//  CatatDanaKu
//
//  Created by lishen on 2026/6/7.
//

struct CDSettingsView: View {
    let onBack: () -> Void

    @State private var vm = SettingsViewModel()

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
            .background(Colors.launchBackground)

            // 确认弹窗
            if vm.showLogoutConfirm { logoutOverlay }
            if vm.showDeleteConfirm { deleteOverlay }
            if vm.showDeleteSecondConfirm { deleteSecondOverlay }
        }
        .animation(.easeInOut(duration: 0.2), value: vm.showLogoutConfirm)
        .animation(.easeInOut(duration: 0.2), value: vm.showDeleteConfirm)
        .animation(.easeInOut(duration: 0.2), value: vm.showDeleteSecondConfirm)
        .toast(isPresented: $vm.showVersionToast, message: AllStr.Settings.alreadyLatest)
    }

    // MARK: - Header

    private var pageHeader: some View {
        HStack(spacing: 12) {
            Button(action: onBack) {
                ZStack {
                    Circle().fill(Colors.launchBackground).frame(width: 36, height: 36)
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Colors.textPrimary)
                }
            }
            Text(AllStr.Settings.title)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(Colors.textPrimary)
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
            sectionHeader(AllStr.Settings.appInfo)

            VStack(spacing: 0) {
                Button {
                    Task { await vm.checkVersion() }
                } label: {
                    infoRow(AllStr.Settings.version, appVersion)
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
                .foregroundColor(Colors.textSecondary)
            Spacer()
            Text(value)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Colors.textPrimary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }

    // MARK: - Danger Zone

    private var dangerZone: some View {
        VStack(alignment: .leading, spacing: 0) {
            sectionHeader(AllStr.Settings.dangerZone)

            VStack(spacing: 0) {
                dangerButton(
                    icon: "arrow.right.square.fill",
                    iconBg: Color(hex: "#FFF3E0"),
                    iconColor: Color(hex: "#FF9500"),
                    label: AllStr.Settings.logout,
                    labelColor: Color(hex: "#FF9500")
                ) {
                    vm.showLogoutConfirm = true
                }

                Divider().padding(.leading, 56)

                dangerButton(
                    icon: "trash.fill",
                    iconBg: Color(hex: "#FFE8E8"),
                    iconColor: Color(hex: "#FF4444"),
                    label: AllStr.Settings.deleteData,
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
            .foregroundColor(Colors.textHint)
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
                    Text(AllStr.Settings.logoutTitle)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(Colors.textPrimary)
                        .padding(.bottom, 8)
                    Text(AllStr.Settings.logoutMessage)
                        .font(.system(size: 14))
                        .foregroundColor(Colors.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.bottom, 24)

                    HStack(spacing: 12) {
                        Button { vm.showLogoutConfirm = false } label: {
                            Text(AllStr.Common.cancel)
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(Colors.textPrimary)
                                .frame(maxWidth: .infinity).frame(height: 48)
                                .background(Colors.launchBackground)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                        Button {
                            vm.showLogoutConfirm = false
                            Task {
                                await vm.logout()
                                onBack()
                            }
                        } label: {
                            Text(AllStr.Settings.logoutConfirm)
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(Colors.textPrimary)
                                .frame(maxWidth: .infinity).frame(height: 48)
                                .background(Colors.launchBackground)
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
                    Text(AllStr.Settings.deleteTitle)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(Color(hex: "#FF4444"))
                        .padding(.bottom, 8)
                    Text(AllStr.Settings.deleteMessage)
                        .font(.system(size: 14))
                        .foregroundColor(Colors.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.bottom, 24)

                    HStack(spacing: 12) {
                        Button { vm.showDeleteConfirm = false } label: {
                            Text(AllStr.Common.cancel)
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(Colors.textPrimary)
                                .frame(maxWidth: .infinity).frame(height: 48)
                                .background(Colors.launchBackground)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                        Button {
                            vm.showDeleteConfirm = false
                            vm.showDeleteSecondConfirm = true
                        } label: {
                            Text(AllStr.Settings.deleteConfirm)
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(Colors.textPrimary)
                                .frame(maxWidth: .infinity).frame(height: 48)
                                .background(Colors.launchBackground)
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
                    Text(AllStr.Settings.deleteSecondTitle)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(Color(hex: "#FF4444"))
                        .padding(.bottom, 8)
                    Text(AllStr.Settings.deleteSecondMessage)
                        .font(.system(size: 14))
                        .foregroundColor(Colors.textPrimary)
                        .multilineTextAlignment(.center)
                        .padding(.bottom, 24)

                    HStack(spacing: 12) {
                        Button { vm.showDeleteSecondConfirm = false } label: {
                            Text(AllStr.Common.cancel)
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(Colors.textPrimary)
                                .frame(maxWidth: .infinity).frame(height: 48)
                                .background(Colors.launchBackground)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                        Button {
                            vm.showDeleteSecondConfirm = false
                            Task {
                                await vm.deleteAccount()
                                onBack()
                            }
                        } label: {
                            Text(AllStr.Settings.deleteSecondConfirm)
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(Colors.textPrimary)
                                .frame(maxWidth: .infinity).frame(height: 48)
                                .background(Colors.launchBackground)
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
