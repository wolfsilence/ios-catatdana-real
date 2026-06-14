import SwiftUI

//
//  CDCreditCardBindingView.swift
//  CatatDanaKu
//
//  Created by lishen on 2026/6/7.
//

struct CDBankCardBindView: View {
    let onBack: () -> Void

    @State private var vm = CDBankCardBindViewModel()

    var body: some View {
        VStack(spacing: 0) {
            headerWithAddCdk
            ScrollView {
                VStack(spacing: 16) {
                    cardsListCdk
                    if vm.cards.isEmpty && !vm.showForm {
                        emptyStateCdk
                    }
                    if vm.showForm { addFormCdk }
                }
                .padding(20)
            }
        }
        .background(AppColors.launchBackground)
    }

    // MARK: - Empty

    private var emptyStateCdk: some View {
        VStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color(hex: "#E8F0FE"))
                    .frame(width: 64, height: 64)
                Image(systemName: "creditcard.fill")
                    .font(.system(size: 28))
                    .foregroundColor(Color(hex: "#3B82F6"))
            }
            Text(AllStr.ccEm)
                .font(.system(size: 14))
                .foregroundColor(AppColors.strSecondary)
        }
        .padding(.vertical, 32)
    }

    // MARK: - Card List

    private var cardsListCdk: some View {
        ForEach(vm.cards) { card in
            visualCardCdk(card)
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
            Text(AllStr.ccT)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(AppColors.strPrimary)
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

    private func visualCardCdk(_ card: EntityBankCard) -> some View {
        CdkDICleaner.shared.cdkClean()
        let colors = card.bgGradientColors
        return ZStack(alignment: .topTrailing) {
            VStack(alignment: .leading, spacing: 0) {
                // Chip
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.white.opacity(0.3))
                    .frame(width: 36, height: 24)
                    .padding(.bottom, 16)

                // Number
                Text(card.no)
                    .font(.system(size: 17, weight: .semibold, design: .monospaced))
                    .foregroundColor(.white)
                    .padding(.bottom, 16)

                // Date + Bank
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(AllStr.ccDue)
                            .font(.system(size: 10))
                            .foregroundColor(.white.opacity(0.6))
                        Text(String(format: AllStr.ccDf, card.repayDate))
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    Spacer()
                    Text(card.bankName)
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

    // MARK: - Add Form

    private var addFormCdk: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(AllStr.ccAt)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(AppColors.strPrimary)

            // Card number
            VStack(alignment: .leading, spacing: 5) {
                Text(AllStr.ccNl)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(AppColors.strSecondary)
                TextField(AllStr.ccNp, text: $vm.cardNumber)
                    .keyboardType(.numberPad)
                    .font(.system(size: 16, design: .monospaced))
                    .padding(12)
                    .background(AppColors.launchBackground)
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
                Text(AllStr.ccBl)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(AppColors.strSecondary)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(EntityBankCard.bankList, id: \.self) { b in
                            Button {
                                vm.bank = b
                            } label: {
                                Text(b)
                                    .font(.system(size: 13, weight: vm.bank == b ? .semibold : .regular))
                                    .padding(.horizontal, 12).padding(.vertical, 6)
                                    .background(vm.bank == b ? Color(hex: "#3B82F6") : AppColors.launchBackground)
                                    .foregroundColor(vm.bank == b ? .white : AppColors.strPrimary)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                        }
                    }
                }
                TextField(AllStr.ccBp, text: $vm.bank)
                    .font(.system(size: 14))
                    .padding(12)
                    .background(AppColors.launchBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.black.opacity(0.06), lineWidth: 1.5))
            }

            // Payment date
            VStack(alignment: .leading, spacing: 5) {
                Text(AllStr.ccDl)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(AppColors.strSecondary)
                HStack(spacing: 8) {
                    TextField(AllStr.ccDp, text: $vm.paymentDate)
                        .keyboardType(.numberPad)
                        .font(.system(size: 14))
                        .padding(12)
                        .background(AppColors.launchBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.black.opacity(0.06), lineWidth: 1.5))
                    Text(AllStr.ccPm)
                        .font(.system(size: 14))
                        .foregroundColor(AppColors.strHint)
                }
            }

            // Buttons
            HStack(spacing: 12) {
                Button { vm.resetForm() } label: {
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
                    Text(vm.saved ? "✓ \(AllStr.cmSd)" : AllStr.ccS)
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
