import SwiftUI

//
//  CDMaxLoanCalculatorView.swift
//  CatatDanaKu
//
//  Created by lishen on 2026/6/7.
//

struct CDMaxCanCalcView: View {
    let onBack: () -> Void

    @State private var vm = CDMaxCanCalcViewModel()

    var body: some View {
        VStack(spacing: 0) {
            pageHeaderCdk(AllStr.mlT)
            ScrollView {
                VStack(spacing: 16) {
                    infoTipCdk
                    inputCardCdk
                    if vm.maxLoan != nil { resultCardCdk }
                    noteCardCdk
                }
                .padding(20)
            }
        }
        .background(AppColors.launchBackground)
    }

    // MARK: - Info Tip

    private var infoTipCdk: some View {
        HStack(spacing: 8) {
            Text("💡")
            Text(AllStr.mlIt)
                .font(.system(size: 12))
                .foregroundColor(AppColors.primary)
        }
        .padding(12)
        .background(Color(hex: "#E8F8EE"))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func inputFieldCdk(_ label: String, text: Binding<String>, placeholder: String, prefix: String? = nil, suffix: String? = nil, keyboard: UIKeyboardType = .default) -> some View {
        CdkDICleaner.shared.cdkDeviceCheck()
        return VStack(alignment: .leading, spacing: 6) {
            Text(label).font(.system(size: 13, weight: .medium)).foregroundColor(AppColors.strSecondary)
            HStack(spacing: 6) {
                if let p = prefix {
                    Text(p).font(.system(size: 14)).foregroundColor(AppColors.strHint)
                }
                TextField(placeholder, text: text)
                    .keyboardType(keyboard)
                    .font(.system(size: 15))
                if let s = suffix {
                    Text(s).font(.system(size: 14)).foregroundColor(AppColors.strHint)
                }
            }
            .padding(12)
            .frame(height: 52)
            .background(AppColors.launchBackground)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.black.opacity(0.06), lineWidth: 1.5))
        }
    }

    // MARK: - Note

    private var noteCardCdk: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(AllStr.mlNo)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(Color(hex: "#F59E0B"))
            Text(AllStr.mlDi)
                .font(.system(size: 12))
                .foregroundColor(AppColors.strSecondary)
                .lineSpacing(3)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.04), radius: 2, y: 1)
    }

    private func pageHeaderCdk(_ title: String) -> some View {
        HStack(spacing: 12) {
            Button(action: onBack) {
                ZStack {
                    Circle().fill(AppColors.launchBackground).frame(width: 36, height: 36)
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(AppColors.strPrimary)
                }
            }
            Text(title).font(.system(size: 18, weight: .bold)).foregroundColor(AppColors.strPrimary)
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
        .padding(.bottom, 12)
        .background(Color.white)
    }

    // MARK: - Result

    private var resultCardCdk: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(AllStr.mlRla)
                .font(.system(size: 13))
                .foregroundColor(.white.opacity(0.85))
            Text(formatIDR(vm.maxLoan ?? 0))
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.white)
                .padding(.bottom, 16)

            VStack(alignment: .leading, spacing: 4) {
                Text(String(format: AllStr.mlRs, formatIDR(vm.parsedPayment), "\(Int(vm.parsedMonths))", vm.annualRate))
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.85))
                    .lineSpacing(3)
            }
            .padding(12)
            .background(Color.white.opacity(0.2))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .padding(20)
        .background(
            LinearGradient(
                colors: [Color(hex: "#F59E0B"), Color(hex: "#D97706")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color(hex: "#F59E0B").opacity(0.3), radius: 8, y: 4)
    }

    // MARK: - Input

    private var inputCardCdk: some View {
        VStack(spacing: 16) {
            inputFieldCdk(AllStr.mlPl, text: $vm.monthlyPayment, placeholder: AllStr.mlPp, prefix: "Rp", keyboard: .numberPad)
            inputFieldCdk(AllStr.mlRl, text: $vm.annualRate, placeholder: AllStr.mlRp, suffix: AllStr.mlRsu, keyboard: .decimalPad)
            inputFieldCdk(AllStr.mlTl, text: $vm.months, placeholder: AllStr.mlTp, suffix: AllStr.mlTs, keyboard: .numberPad)

            Button {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                Task { await vm.calculate() }
            } label: {
                Text(AllStr.mlCa)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity).frame(height: 52)
                    .background(Color(hex: "#F59E0B"))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .disabled(!vm.canCalculate)
            .opacity(vm.canCalculate ? 1 : 0.6)
        }
        .padding(20)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.06), radius: 2, y: 1)
    }

}
