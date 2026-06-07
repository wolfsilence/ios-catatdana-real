import SwiftUI

//
//  CDPaymentReminderView.swift
//  CatatDanaKu
//
//  Created by lishen on 2026/6/7.
//

struct CDPaymentReminderView: View {
    let onBack: () -> Void

    @State private var vm = ReminderViewModel()

    var body: some View {
        VStack(spacing: 0) {
            headerWithAdd
            ScrollView {
                VStack(spacing: 16) {
                    summaryCard
                    reminderList
                    if vm.showForm { addForm }
                }
                .padding(20)
            }
        }
        .background(Colors.launchBackground)
    }

    // MARK: - Header

    private var headerWithAdd: some View {
        HStack(spacing: 12) {
            Button(action: onBack) {
                ZStack {
                    Circle().fill(Colors.launchBackground).frame(width: 36, height: 36)
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Colors.textPrimary)
                }
            }
            Text(Strings.Reminder.title)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(Colors.textPrimary)
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

    // MARK: - Summary

    private var summaryCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(Strings.Reminder.monthlyTotal)
                .font(.system(size: 13))
                .foregroundColor(.white.opacity(0.8))
            Text(formatIDR(vm.totalAmount))
                .font(.system(size: 26, weight: .bold))
                .foregroundColor(.white)
            Text("\(vm.reminders.count) \(Strings.Reminder.activeCount)")
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

    private var reminderList: some View {
        VStack(spacing: 12) {
            ForEach(vm.sortedReminders) { r in
                reminderCard(r)
            }
            if vm.reminders.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "bell.slash")
                        .font(.system(size: 28))
                        .foregroundColor(Colors.textHint)
                    Text(Strings.Reminder.noReminders)
                        .font(.system(size: 14))
                        .foregroundColor(Colors.textSecondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 24)
            }
        }
    }

    private func reminderCard(_ r: Reminder) -> some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    Text(r.name)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(Colors.textPrimary)
                    if r.isUrgent {
                        Text(Strings.Reminder.urgent)
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(Color(hex: "#FF9500"))
                            .padding(.horizontal, 8).padding(.vertical, 2)
                            .background(Color(hex: "#FFF3E0"))
                            .clipShape(Capsule())
                    }
                    if r.isPastDue {
                        Text(Strings.Reminder.pastDue)
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
                        .foregroundColor(Colors.textHint)
                }
            }
            Spacer()
            Button { vm.delete(r) } label: {
                Image(systemName: "trash")
                    .font(.system(size: 14))
                    .foregroundColor(Colors.textHint)
            }
        }
        .padding()
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.06), radius: 2, y: 1)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(r.isUrgent ? Color(hex: "#FF9500") : Color.clear, lineWidth: 1.5)
        )
    }

    // MARK: - Add Form

    private var addForm: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(Strings.Reminder.addTitle)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(Colors.textPrimary)

            formField(Strings.Reminder.nameLabel, placeholder: Strings.Reminder.namePlaceholder, text: $vm.name)
            formField(Strings.Reminder.amountLabel, placeholder: Strings.Reminder.amountPlaceholder, text: $vm.amount, keyboard: .numberPad)
            DatePicker(Strings.Reminder.dueDateLabel, selection: $vm.dueDate, displayedComponents: .date)
                .font(.system(size: 13))
                .foregroundColor(Colors.textSecondary)
            formField(Strings.Reminder.noteLabel, placeholder: Strings.Reminder.notePlaceholder, text: $vm.note)

            HStack(spacing: 12) {
                Button {
                    vm.resetForm()
                } label: {
                    Text(Strings.Common.cancel)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Colors.textSecondary)
                        .frame(maxWidth: .infinity).frame(height: 44)
                        .background(Colors.launchBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                Button {
                    Task { await vm.save() }
                } label: {
                    Text(vm.saved ? "✓ \(Strings.Common.saved)" : Strings.Common.save)
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

    private func formField(_ label: String, placeholder: String, text: Binding<String>, keyboard: UIKeyboardType = .default) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(label)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(Colors.textSecondary)
            TextField(placeholder, text: text)
                .keyboardType(keyboard)
                .font(.system(size: 14))
                .padding(12)
                .background(Colors.launchBackground)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.black.opacity(0.06), lineWidth: 1.5)
                )
        }
    }

}
