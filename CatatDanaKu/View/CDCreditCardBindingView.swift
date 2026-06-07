import SwiftUI

//
//  CDCreditCardBindingView.swift
//  CatatDanaKu
//
//  Created by lishen on 2026/6/7.
//

struct CDCreditCardBindingView: View {
    let onBack: () -> Void

    @State private var vm = CreditCardViewModel()

    var body: some View {
        VStack(spacing: 0) {
            headerWithAdd
            ScrollView {
                VStack(spacing: 16) {
                    cardsList
                    if vm.cards.isEmpty && !vm.showForm {
                        emptyState
                    }
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
            Text(Strings.CreditCard.title)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(Colors.textPrimary)
            Spacer()
            Button { vm.showForm = true } label: {
                ZStack {
                    Circle().fill(Color(hex: "#3B82F6")).frame(width: 36, height: 36)
                    Image(systemName: "plus").font(.system(size: 16, weight: .semibold)).foregroundColor(.white)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
        .padding(.bottom, 12)
        .background(Color.white)
    }

    // MARK: - Card List

    private var cardsList: some View {
        ForEach(vm.cards) { card in
            visualCard(card)
        }
    }

    private func visualCard(_ card: CreditCard) -> some View {
        let colors = card.gradientColors
        return ZStack(alignment: .topTrailing) {
            VStack(alignment: .leading, spacing: 0) {
                // Chip
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.white.opacity(0.3))
                    .frame(width: 36, height: 24)
                    .padding(.bottom, 16)

                // Number
                Text(card.number)
                    .font(.system(size: 17, weight: .semibold, design: .monospaced))
                    .foregroundColor(.white)
                    .padding(.bottom, 16)

                // Date + Bank
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(Strings.CreditCard.dueLabel)
                            .font(.system(size: 10))
                            .foregroundColor(.white.opacity(0.6))
                        Text(String(format: Strings.CreditCard.dateFormat, card.paymentDate))
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    Spacer()
                    Text(card.bank)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                }
            }
            .padding(20)
            .frame(height: 160)
            .background(
                LinearGradient(
                    colors: colors.map { Color(hex: $0) },
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.2), radius: 8, y: 4)

            // Delete
            Button { vm.delete(card) } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 24, height: 24)
                    .background(Color.black.opacity(0.3))
                    .clipShape(Circle())
            }
            .padding(12)

            // Mastercard circles
            HStack(spacing: -12) {
                Circle().fill(Color(hex: "#FF6430").opacity(0.7)).frame(width: 28, height: 28)
                Circle().fill(Color(hex: "#FFC832").opacity(0.6)).frame(width: 28, height: 28)
            }
            .padding(.top, 16)
            .padding(.trailing, 56)
        }
    }

    // MARK: - Empty

    private var emptyState: some View {
        VStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color(hex: "#E8F0FE"))
                    .frame(width: 64, height: 64)
                Image(systemName: "creditcard.fill")
                    .font(.system(size: 28))
                    .foregroundColor(Color(hex: "#3B82F6"))
            }
            Text(Strings.CreditCard.empty)
                .font(.system(size: 14))
                .foregroundColor(Colors.textSecondary)
        }
        .padding(.vertical, 32)
    }

    // MARK: - Add Form

    private var addForm: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(Strings.CreditCard.addTitle)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(Colors.textPrimary)

            // Card number
            VStack(alignment: .leading, spacing: 5) {
                Text(Strings.CreditCard.numberLabel)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(Colors.textSecondary)
                TextField(Strings.CreditCard.numberPlaceholder, text: $vm.cardNumber)
                    .keyboardType(.numberPad)
                    .font(.system(size: 16, design: .monospaced))
                    .padding(12)
                    .background(Colors.launchBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.black.opacity(0.06), lineWidth: 1.5))
                    .onChange(of: vm.cardNumber) { _, _ in
                        // 限制 16 位
                        let cleaned = vm.cardNumber.filter { $0.isNumber }
                        if cleaned.count > 16 {
                            vm.cardNumber = String(cleaned.prefix(16))
                        }
                    }
            }

            // Bank selector
            VStack(alignment: .leading, spacing: 5) {
                Text(Strings.CreditCard.bankLabel)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(Colors.textSecondary)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(CreditCard.bankList, id: \.self) { b in
                            Button {
                                vm.bank = b
                            } label: {
                                Text(b)
                                    .font(.system(size: 13, weight: vm.bank == b ? .semibold : .regular))
                                    .padding(.horizontal, 12).padding(.vertical, 6)
                                    .background(vm.bank == b ? Color(hex: "#3B82F6") : Colors.launchBackground)
                                    .foregroundColor(vm.bank == b ? .white : Colors.textPrimary)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                        }
                    }
                }
                TextField(Strings.CreditCard.bankPlaceholder, text: $vm.bank)
                    .font(.system(size: 14))
                    .padding(12)
                    .background(Colors.launchBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.black.opacity(0.06), lineWidth: 1.5))
            }

            // Payment date
            VStack(alignment: .leading, spacing: 5) {
                Text(Strings.CreditCard.dueDateLabel)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(Colors.textSecondary)
                HStack(spacing: 8) {
                    TextField(Strings.CreditCard.datePlaceholder, text: $vm.paymentDate)
                        .keyboardType(.numberPad)
                        .font(.system(size: 14))
                        .padding(12)
                        .background(Colors.launchBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.black.opacity(0.06), lineWidth: 1.5))
                    Text(Strings.CreditCard.perMonth)
                        .font(.system(size: 14))
                        .foregroundColor(Colors.textHint)
                }
            }

            // Buttons
            HStack(spacing: 12) {
                Button { vm.resetForm() } label: {
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
                    Text(vm.saved ? "✓ \(Strings.Common.saved)" : Strings.CreditCard.save)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity).frame(height: 44)
                        .background(vm.saved ? Color(hex: "#13A048") : Color(hex: "#3B82F6"))
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
