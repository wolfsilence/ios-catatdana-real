import SwiftUI

//
//  CDEMICalculatorView.swift
//  CatatDanaKu
//
//  Created by lishen on 2026/6/7.
//

struct CDEMICalcView: View {
    let onBack: () -> Void

    @State private var vm = CDEMICalcViewModel()

    var body: some View {
        VStack(spacing: 0) {
            pageHeader(AllStr.emT)
            ScrollView {
                VStack(spacing: 16) {
                    inputCard
                    if vm.monthlyEMI != nil { resultCard }
                    formulaCard
                }
                .padding(20)
            }
        }
        .background(AppColors.launchBackground)
    }

    // MARK: - Header

    private func pageHeader(_ title: String) -> some View {
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

    // MARK: - Input

    private var inputCard: some View {
        VStack(spacing: 16) {
            inputField(AllStr.emLl, text: $vm.loanAmount, placeholder: AllStr.emLp, prefix: "Rp", keyboard: .numberPad)
            inputField(AllStr.emTl, text: $vm.months, placeholder: AllStr.emTenp, suffix: AllStr.emTs, keyboard: .numberPad)
            inputField(AllStr.emRl, text: $vm.annualRate, placeholder: AllStr.emRp, suffix: AllStr.emRs, keyboard: .decimalPad)

            Button {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                Task { await vm.calculate() }
            } label: {
                Text(AllStr.emCa)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity).frame(height: 52)
                    .background(AppColors.primary)
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

    // MARK: - Result

    private var resultCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(AllStr.emMe)
                .font(.system(size: 13))
                .foregroundColor(.white.opacity(0.8))
            Text(formatIDR(vm.monthlyEMI ?? 0))
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.white)
                .padding(.bottom, 20)

            HStack(spacing: 12) {
                miniStat(AllStr.emTp, formatIDR(vm.totalPayment))
                miniStat(AllStr.emTi, formatIDR(vm.totalInterest))
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
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color(hex: "#1BC459").opacity(0.3), radius: 8, y: 4)
    }

    private func miniStat(_ label: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label).font(.system(size: 11)).foregroundColor(.white.opacity(0.75))
            Text(value).font(.system(size: 14, weight: .semibold)).foregroundColor(.white)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(Color.white.opacity(0.15))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Formula

    private var formulaCard: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(AllStr.emFo)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(AppColors.primary)
            Text("EMI = [P × r × (1+r)ⁿ] / [(1+r)ⁿ - 1]\nP = Pokok pinjaman, r = Suku bunga per bulan, n = Tenor")
                .font(.system(size: 12))
                .foregroundColor(AppColors.strSecondary)
                .lineSpacing(4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.04), radius: 2, y: 1)
    }

    private func inputField(_ label: String, text: Binding<String>, placeholder: String, prefix: String? = nil, suffix: String? = nil, keyboard: UIKeyboardType = .default) -> some View {
        VStack(alignment: .leading, spacing: 6) {
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

}
