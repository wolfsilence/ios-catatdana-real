import SwiftUI

//
//  CDExchangeRateView.swift
//  CatatDanaKu
//
//  Created by lishen on 2026/6/7.
//

struct CDExchangeRateView: View {
    let onBack: () -> Void

    @State private var vm = ExchangeRateViewModel()

    var body: some View {
        VStack(spacing: 0) {
            pageHeader(AllStr.ExchangeRate.title)
            ScrollView {
                VStack(spacing: 16) {
                    idrInput
                    if vm.parsedAmount > 0 { resultsList }
                    currencySelector
                    disclaimer
                }
                .padding(20)
            }
        }
        .background(Colors.launchBackground)
        .onAppear { Task { await vm.submitBiz() } }
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

    // MARK: - IDR Input

    private var idrInput: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(AllStr.ExchangeRate.idrLabel).font(.system(size: 13)).foregroundColor(Colors.textSecondary)
            HStack(spacing: 8) {
                HStack(spacing: 4) {
                    Text("🇮🇩").font(.system(size: 18))
                    Text("IDR").font(.system(size: 13, weight: .semibold)).foregroundColor(Colors.primary)
                }
                .padding(.horizontal, 10).padding(.vertical, 4)
                .background(Color(hex: "#E8F8EE"))
                .clipShape(RoundedRectangle(cornerRadius: 8))

                TextField("0", text: $vm.amount)
                    .keyboardType(.numberPad)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(Colors.textPrimary)
            }
            .padding(12)
            .frame(height: 60)
            .background(Colors.launchBackground)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .padding(20)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.06), radius: 2, y: 1)
    }

    // MARK: - Results

    private var resultsList: some View {
        VStack(spacing: 0) {
            Text(AllStr.ExchangeRate.resultTitle)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(Colors.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16).padding(.vertical, 12)
            Divider()

            ForEach(Array(vm.selectedCurrencyList.enumerated()), id: \.element.id) { idx, cur in
                let converted = vm.convert(cur)
                HStack(spacing: 12) {
                    Text(cur.flag).font(.system(size: 24))
                    VStack(alignment: .leading, spacing: 2) {
                        Text(formattedResult(converted)).font(.system(size: 15, weight: .semibold)).foregroundColor(Colors.textPrimary)
                            + Text(" \(cur.code)").font(.system(size: 13)).foregroundColor(Colors.textSecondary)
                        Text("1 \(cur.code) = Rp \(Int(cur.rate).formatted())")
                            .font(.system(size: 11))
                            .foregroundColor(Colors.textHint)
                    }
                    Spacer()
                    Text(cur.name.components(separatedBy: " ").first ?? "")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(Colors.primary)
                        .padding(.horizontal, 10).padding(.vertical, 4)
                        .background(Color(hex: "#E8F8EE"))
                        .clipShape(Capsule())
                }
                .padding(.horizontal, 16).padding(.vertical, 14)
                if idx < vm.selectedCurrencyList.count - 1 {
                    Divider().padding(.leading, 52)
                }
            }
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.06), radius: 2, y: 1)
    }

    // MARK: - Currency Selector

    private var currencySelector: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(AllStr.ExchangeRate.selectCurrency)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(Colors.textPrimary)

            ForEach(vm.currencies) { cur in
                let isSelected = vm.selectedCurrencies.contains(cur.code)
                Button {
                    vm.toggle(cur.code)
                } label: {
                    HStack(spacing: 12) {
                        Text(cur.flag).font(.system(size: 22))
                        VStack(alignment: .leading, spacing: 1) {
                            Text(cur.code).font(.system(size: 14, weight: .medium)).foregroundColor(Colors.textPrimary)
                            Text(cur.name).font(.system(size: 11)).foregroundColor(Colors.textHint)
                        }
                        Spacer()
                        ZStack {
                            Circle()
                                .fill(isSelected ? Colors.primary : Colors.launchBackground)
                                .frame(width: 22, height: 22)
                                .overlay(
                                    Circle().stroke(Color.black.opacity(0.1), lineWidth: isSelected ? 0 : 1.5)
                                )
                            if isSelected {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(.white)
                            }
                        }
                    }
                    .padding(12)
                    .background(isSelected ? Color(hex: "#E8F8EE") : Color.clear)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.06), radius: 2, y: 1)
    }

    private var disclaimer: some View {
        Text(AllStr.ExchangeRate.disclaimer)
            .font(.system(size: 11))
            .foregroundColor(Colors.textHint)
            .multilineTextAlignment(.center)
            .padding(.vertical, 4)
    }

    private func formattedResult(_ value: Double) -> String {
        if value < 1 { return String(format: "%.4f", value) }
        if value < 100 { return String(format: "%.2f", value) }
        return Int(value).formatted()
    }

}
