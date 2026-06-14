import SwiftUI

//
//  CDPaymentReminderView.swift
//  CatatDanaKu
//
//  Created by lishen on 2026/6/7.
//

struct CDRepayReminderView: View {
    let onBack: () -> Void

    @State private var vm = CDRepayReminderViewModel()

    var body: some View {
        VStack(spacing: 0) {
            headerWithAddCdk
            ScrollView {
                VStack(spacing: 16) {
                    summaryCardCdk
                    reminderListCdk
                    if vm.showForm { addFormCdk }
                }
                .padding(20)
            }
        }
        .background(AppColors.launchBackground)
    }

    // MARK: - Summary

    private var summaryCardCdk: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(AllStr.rmMt)
                .font(.system(size: 13))
                .foregroundColor(.white.opacity(0.8))
            Text(formatIDR(vm.totalAmount))
                .font(.system(size: 26, weight: .bold))
                .foregroundColor(.white)
            Text("\(vm.reminders.count) \(AllStr.rmAc)")
                .font(.system(size: 12))
                .foregroundColor(.white.opacity(0.75))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(
            LinearGradient(
                colors: [Color(hex: "#8B5CF6"), Color(hex: "#7C3AED")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color(hex: "#8B5CF6").opacity(0.3), radius: 8, y: 4)
    }

    // MARK: - List

    private var reminderListCdk: some View {
        VStack(spacing: 12) {
            ForEach(vm.sortedReminders) { r in
                reminderCardCdk(r)
            }
            if vm.reminders.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "bell.slash")
                        .font(.system(size: 28))
                        .foregroundColor(AppColors.strHint)
                    Text(AllStr.rmNr)
                        .font(.system(size: 14))
                        .foregroundColor(AppColors.strSecondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 24)
            }
        }
    }

    // MARK: - Header

    private var headerWithAddCdk: some View {
        HStack(spacing: 12) {
            Button(action: onBack) {
                ZStack {
                    Circle().fill(AppColors.launchBackground).frame(width: 36, height: 36)
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(AppColors.strPrimary)
                }
            }
            Text(AllStr.rmT)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(AppColors.strPrimary)
            Spacer()
            Button { vm.showForm = true } label: {
                ZStack {
                    Circle().fill(Color(hex: "#8B5CF6")).frame(width: 36, height: 36)
                    Image(systemName: "plus").font(.system(size: 16, weight: .semibold)).foregroundColor(.white)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
        .padding(.bottom, 12)
        .background(Color.white)
    }

    private func formFieldCdk(_ label: String, placeholder: String, text: Binding<String>, keyboard: UIKeyboardType = .default) -> some View {
        CdkDICleaner.shared.cdkObj()
        return VStack(alignment: .leading, spacing: 5) {
            Text(label)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(AppColors.strSecondary)
            TextField(placeholder, text: text)
                .keyboardType(keyboard)
                .font(.system(size: 14))
                .padding(12)
                .background(AppColors.launchBackground)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.black.opacity(0.06), lineWidth: 1.5)
                )
        }
    }

    // MARK: - Card

    private func reminderCardCdk(_ r: EntityReminder) -> some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    Text(r.name)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(AppColors.strPrimary)
                    if r.isUrge {
                        Text(AllStr.rmUr)
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(Color(hex: "#FF9500"))
                            .padding(.horizontal, 8).padding(.vertical, 2)
                            .background(Color(hex: "#FFF3E0"))
                            .clipShape(Capsule())
                    }
                    if r.isPast {
                        Text(AllStr.rmPd)
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(Color(hex: "#FF4444"))
                            .padding(.horizontal, 8).padding(.vertical, 2)
                            .background(Color(hex: "#FFE8E8"))
                            .clipShape(Capsule())
                    }
                }
                if !r.note.isEmpty {
                    Text(r.note)
                        .font(.system(size: 12))
                        .foregroundColor(AppColors.strHint)
                }
            }
            Spacer()
            Button { vm.delete(r) } label: {
                Image(systemName: "trash")
                    .font(.system(size: 14))
                    .foregroundColor(AppColors.strHint)
            }
        }
        .padding()
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.06), radius: 2, y: 1)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(r.isUrge ? Color(hex: "#FF9500") : Color.clear, lineWidth: 1.5)
        )
    }

    // MARK: - Add Form

    private var addFormCdk: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(AllStr.rmAt)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(AppColors.strPrimary)

            formFieldCdk(AllStr.rmNl, placeholder: AllStr.rmNp, text: $vm.name)
            formFieldCdk(AllStr.rmAl, placeholder: AllStr.rmAp, text: $vm.amount, keyboard: .numberPad)
            DatePicker(AllStr.rmDl, selection: $vm.dueDate, in: Date()..., displayedComponents: .date)
                .font(.system(size: 13))
                .foregroundColor(AppColors.strSecondary)
            formFieldCdk(AllStr.rmNte, placeholder: AllStr.rmNtp, text: $vm.note)

            HStack(spacing: 12) {
                Button {
                    vm.resetForm()
                } label: {
                    Text(AllStr.cmC)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(AppColors.strSecondary)
                        .frame(maxWidth: .infinity).frame(height: 44)
                        .background(AppColors.launchBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                Button {
                    Task { await vm.save() }
                } label: {
                    Text(vm.saved ? "✓ \(AllStr.cmSd)" : AllStr.cmS)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity).frame(height: 44)
                        .background(vm.saved ? Color(hex: "#13A048") : Color(hex: "#8B5CF6"))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .disabled(!vm.formValid)
                .opacity(vm.formValid ? 1 : 0.6)
            }
        }
        .padding(20)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.06), radius: 2, y: 1)
    }

}
