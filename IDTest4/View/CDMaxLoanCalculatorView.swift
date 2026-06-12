import SwiftUI

//
//  CDMaxLoanCalculatorView.swift
//  CatatDanaKu
//
//  Created by lishen on 2026/6/7.
//

struct CDMaxLoanCalculatorView: View {
    let onBack: () -> Void

    @State private var vm = LoanCalculatorViewModel()

    var body: some View {
        VStack(spacing: 0) {
            pageHeader(Strings.MaxLoan.title)
            ScrollView {
                VStack(spacing: 16) {
                    infoTip
                    inputCard
                    if vm.maxLoan != nil { resultCard }
                    noteCard
                }
                .padding(20)
            }
        }
        .background(Colors.launchBackground)
    }

    private func pageHeader(_ title: String) -> some View {
        HStack(spacing: 12) {
            Button(action: onBack) {
                ZStack {
                    Circle().fill(Colors.launchBackground).frame(width: 36, height: 36)
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Colors.textPrimary)
                }
            }
            Text(title).font(.system(size: 18, weight: .bold)).foregroundColor(Colors.textPrimary)
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
        .padding(.bottom, 12)
        .background(Color.white)
    }

    private var infoTip: some View {
        HStack(spacing: 8) {
            Text("💡")
            Text(Strings.MaxLoan.infoTip)
                .font(.system(size: 12))
                .foregroundColor(Colors.primary)
        }
        .padding(12)
        .background(Color(hex: "#E8F8EE"))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var inputCard: some View {
        VStack(spacing: 16) {
            inputField(Strings.MaxLoan.paymentLabel, text: $vm.monthlyPayment, placeholder: Strings.MaxLoan.paymentPlaceholder, prefix: "Rp", keyboard: .numberPad)
            inputField(Strings.MaxLoan.rateLabel, text: $vm.annualRate, placeholder: Strings.MaxLoan.ratePlaceholder, suffix: Strings.MaxLoan.rateSuffix, keyboard: .decimalPad)
            inputField(Strings.MaxLoan.tenorLabel, text: $vm.months, placeholder: Strings.MaxLoan.tenorPlaceholder, suffix: Strings.MaxLoan.tenorSuffix, keyboard: .numberPad)

            Button {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                Task { await vm.calculate() }
            } label: {
                Text(Strings.MaxLoan.calculate)
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

    private var resultCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(Strings.MaxLoan.resultLabel)
                .font(.system(size: 13))
                .foregroundColor(.white.opacity(0.85))
            Text(formatIDR(vm.maxLoan ?? 0))
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.white)
                .padding(.bottom, 16)

            VStack(alignment: .leading, spacing: 4) {
                Text(String(format: Strings.MaxLoan.resultSummary, formatIDR(vm.parsedPayment), "\(Int(vm.parsedMonths))", vm.annualRate))
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

    private var noteCard: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(Strings.MaxLoan.note)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(Color(hex: "#F59E0B"))
            Text(Strings.MaxLoan.disclaimer)
                .font(.system(size: 12))
                .foregroundColor(Colors.textSecondary)
                .lineSpacing(3)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.04), radius: 2, y: 1)
    }

    private func inputField(_ label: String, text: Binding<String>, placeholder: String, prefix: String? = nil, suffix: String? = nil, keyboard: UIKeyboardType = .default) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label).font(.system(size: 13, weight: .medium)).foregroundColor(Colors.textSecondary)
            HStack(spacing: 6) {
                if let p = prefix {
                    Text(p).font(.system(size: 14)).foregroundColor(Colors.textHint)
                }
                TextField(placeholder, text: text)
                    .keyboardType(keyboard)
                    .font(.system(size: 15))
                if let s = suffix {
                    Text(s).font(.system(size: 14)).foregroundColor(Colors.textHint)
                }
            }
            .padding(12)
            .frame(height: 52)
            .background(Colors.launchBackground)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.black.opacity(0.06), lineWidth: 1.5))
        }
    }

}
