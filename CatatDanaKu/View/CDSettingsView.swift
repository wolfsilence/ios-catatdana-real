import SwiftUI

//
//  CDSettingsView.swift
//  CatatDanaKu
//
//  Created by lishen on 2026/6/7.
//

struct CDSettingsView: View {
    let onBack: () -> Void
    let onLogout: () -> Void

    @State private var vm = SettingsViewModel()

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                pageHeader
                ScrollView {
                    VStack(spacing: 20) {
                        accountSection
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
        }
        .animation(.easeInOut(duration: 0.2), value: vm.showLogoutConfirm)
        .animation(.easeInOut(duration: 0.2), value: vm.showDeleteConfirm)
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
            Text(Strings.Settings.title)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(Colors.textPrimary)
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
        .padding(.bottom, 12)
        .background(Color.white)
    }

    // MARK: - Account Section

    private var accountSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            sectionHeader(Strings.Settings.account)

            VStack(spacing: 0) {
                // Profile info row
                HStack(spacing: 16) {
                    Circle()
                        .fill(LinearGradient(colors: [Color(hex: "#1BC459"), Color(hex: "#13A048")], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 48, height: 48)
                        .overlay(
                            Text(vm.userName.first.map(String.init) ?? "U")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)
                        )
                    VStack(alignment: .leading, spacing: 2) {
                        Text(vm.userName)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(Colors.textPrimary)
                        Text(vm.userPhone)
                            .font(.system(size: 13))
                            .foregroundColor(Colors.textSecondary)
                    }
                    Spacer()
                }
                .padding(16)

                Divider().padding(.leading, 16)

                // Notifications toggle
                toggleRow(
                    icon: "bell.fill",
                    iconBg: Color(hex: "#FEF3C7"),
                    iconColor: Color(hex: "#F59E0B"),
                    label: Strings.Settings.notifications,
                    isOn: $vm.notificationsEnabled
                )

                Divider().padding(.leading, 56)

                // Biometric toggle
                toggleRow(
                    icon: "touchid",
                    iconBg: Color(hex: "#EDE9FE"),
                    iconColor: Color(hex: "#8B5CF6"),
                    label: Strings.Settings.biometric,
                    isOn: $vm.biometricEnabled
                )
            }
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.06), radius: 2, y: 1)
        }
    }

    private func toggleRow(icon: String, iconBg: Color, iconColor: Color, label: String, isOn: Binding<Bool>) -> some View {
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
                .font(.system(size: 15))
                .foregroundColor(Colors.textPrimary)
            Spacer()
            Toggle("", isOn: isOn)
                .tint(Colors.primary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    // MARK: - App Info

    private var appInfoSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            sectionHeader(Strings.Settings.appInfo)

            VStack(spacing: 0) {
                infoRow(Strings.Settings.version, "1.0.0")
                Divider().padding(.leading, 16)
                infoRow(Strings.Settings.lastUpdated, "Juni 2026")
                Divider().padding(.leading, 16)
                infoRow(Strings.Settings.platform, "iOS")
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
            sectionHeader(Strings.Settings.dangerZone)

            VStack(spacing: 0) {
                dangerButton(
                    icon: "arrow.right.square.fill",
                    iconBg: Color(hex: "#FFF3E0"),
                    iconColor: Color(hex: "#FF9500"),
                    label: Strings.Settings.logout,
                    labelColor: Color(hex: "#FF9500")
                ) {
                    vm.showLogoutConfirm = true
                }

                Divider().padding(.leading, 56)

                dangerButton(
                    icon: "trash.fill",
                    iconBg: Color(hex: "#FFE8E8"),
                    iconColor: Color(hex: "#FF4444"),
                    label: Strings.Settings.deleteData,
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
                    Text(Strings.Settings.logoutTitle)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(Colors.textPrimary)
                        .padding(.bottom, 8)
                    Text(Strings.Settings.logoutMessage)
                        .font(.system(size: 14))
                        .foregroundColor(Colors.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.bottom, 24)

                    HStack(spacing: 12) {
                        Button { vm.showLogoutConfirm = false } label: {
                            Text(Strings.Common.cancel)
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(Colors.textSecondary)
                                .frame(maxWidth: .infinity).frame(height: 48)
                                .background(Colors.launchBackground)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                        Button {
                            vm.showLogoutConfirm = false
                            onLogout()
                            onBack()
                        } label: {
                            Text(Strings.Settings.logoutConfirm)
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity).frame(height: 48)
                                .background(Color(hex: "#FF9500"))
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

    // MARK: - Delete Overlay

    private var deleteOverlay: some View {
        ZStack {
            Color.black.opacity(0.4).ignoresSafeArea()
                .onTapGesture { vm.showDeleteConfirm = false }

            VStack(spacing: 0) {
                Spacer()
                VStack(spacing: 0) {
                    Text(Strings.Settings.deleteTitle)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(Color(hex: "#FF4444"))
                        .padding(.bottom, 8)
                    Text(Strings.Settings.deleteMessage)
                        .font(.system(size: 14))
                        .foregroundColor(Colors.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.bottom, 24)

                    HStack(spacing: 12) {
                        Button { vm.showDeleteConfirm = false } label: {
                            Text(Strings.Common.cancel)
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(Colors.textSecondary)
                                .frame(maxWidth: .infinity).frame(height: 48)
                                .background(Colors.launchBackground)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                        Button {
                            vm.showDeleteConfirm = false
                            vm.deleteAccount()
                            onLogout()
                            onBack()
                        } label: {
                            Text(Strings.Settings.deleteConfirm)
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity).frame(height: 48)
                                .background(Color(hex: "#FF4444"))
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
