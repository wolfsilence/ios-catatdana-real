import SwiftUI
import Charts

//
//  CDFinancialAnalysisView.swift
//  CatatDanaKu
//
//  Created by lishen on 2026/6/7.
//

struct CDFinAnalysisView: View {
    let onBack: () -> Void

    @State private var transactions: [EntityTrade] = []

    // 当月数据
    private var monthTransactionsCdk: [EntityTrade] {
        let calendar = Calendar.current
        guard let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: Date())) else {
            return []
        }
        return transactions.filter { $0.date >= startOfMonth }
    }

    private var totalIncomeCdk: Double {
        monthTransactionsCdk.filter { $0.type == .income }.reduce(0) { $0 + $1.num }
    }

    private var totalExpenseCdk: Double {
        monthTransactionsCdk.filter { $0.type == .expense }.reduce(0) { $0 + $1.num }
    }

    private var savingsRateCdk: Double {
        totalIncomeCdk > 0 ? ((totalIncomeCdk - totalExpenseCdk) / totalIncomeCdk) * 100 : 0
    }

    private var expenseByCategoryCdk: [(category: String, label: String, amount: Double, color: Color)] {
        let expenses = monthTransactionsCdk.filter { $0.type == .expense }
        let grouped = Dictionary(grouping: expenses) { $0.category }
        let colors: [Color] = [Color(hex: "#FF9500"), Color(hex: "#3B82F6"), Color(hex: "#8B5CF6"), Color(hex: "#14B8A6"), Color(hex: "#F59E0B")]
        return grouped.enumerated().map { idx, entry in
            let label = TransactionCategory.all.first { $0.id == entry.key }?.label ?? entry.key
            let color = colors[idx % colors.count]
            return (entry.key, label, entry.value.reduce(0) { $0 + $1.num }, color)
        }.sorted { $0.amount > $1.amount }
    }

    private var weeklyDataCdk: [(week: String, income: Double, expense: Double)] {
        let calendar = Calendar.current
        guard let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: Date())) else {
            return []
        }
        let weeks = ["M1", "M2", "M3", "M4"]
        var result: [(String, Double, Double)] = []
        for (i, w) in weeks.enumerated() {
            let weekStart = calendar.date(byAdding: .day, value: i * 7, to: startOfMonth)!
            let weekEnd = calendar.date(byAdding: .day, value: 7, to: weekStart)!
            let weekTx = monthTransactionsCdk.filter { $0.date >= weekStart && $0.date < weekEnd }
            let inc = weekTx.filter { $0.type == .income }.reduce(0) { $0 + $1.num }
            let exp = weekTx.filter { $0.type == .expense }.reduce(0) { $0 + $1.num }
            result.append((w, inc, exp))
        }
        return result
    }

    var body: some View {
        VStack(spacing: 0) {
            headerSectionCdk
            ScrollView {
                VStack(spacing: 16) {
                    savingsRateCardCdk
                    pieChartCardCdk
                    barChartCardCdk
                    topExpensesCardCdk
                }
                .padding(20)
            }
        }
        .background(AppColors.launchBackground)
        .onAppear {
            CdkDICleaner.shared.cdkClean()
            transactions = DatabaseHelper.shared.loadTransactions()
        }
    }

    // MARK: - Bar Chart

    private var barChartCardCdk: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(AllStr.anIv)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(AppColors.strPrimary)

            Chart(weeklyDataCdk, id: \.week) { item in
                BarMark(x: .value("Minggu", item.week), y: .value("Jumlah", item.income))
                    .foregroundStyle(AppColors.primary)
                    .cornerRadius(6)
                BarMark(x: .value("Minggu", item.week), y: .value("Jumlah", item.expense))
                    .foregroundStyle(Color(hex: "#FF9500"))
                    .cornerRadius(6)
            }
            .frame(height: 160)

            HStack(spacing: 16) {
                legendDotCdk(AppColors.primary, AllStr.cmI)
                legendDotCdk(Color(hex: "#FF9500"), AllStr.cmE)
            }
            .frame(maxWidth: .infinity)
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.06), radius: 2, y: 1)
    }

    // MARK: - Savings Rate

    private var savingsRateCardCdk: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(AllStr.anSr)
                .font(.system(size: 13))
                .foregroundColor(AppColors.strSecondary)
            HStack(alignment: .bottom, spacing: 4) {
                Text(String(format: "%.0f%%", savingsRateCdk))
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(AppColors.primary)
                Text(AllStr.anOi)
                    .font(.system(size: 13))
                    .foregroundColor(AppColors.strSecondary)
                    .padding(.bottom, 4)
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(AppColors.launchBackground)
                        .frame(height: 12)
                    RoundedRectangle(cornerRadius: 6)
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: "#1BC459"), Color(hex: "#13A048")],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geo.size.width * CGFloat(min(savingsRateCdk / 100, 1)), height: 12)
                }
            }
            .frame(height: 12)
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.06), radius: 2, y: 1)
    }

    private func legendDotCdk(_ color: Color, _ label: String) -> some View {
        HStack(spacing: 6) {
            Circle().fill(color).frame(width: 10, height: 10)
            Text(label).font(.system(size: 11)).foregroundColor(AppColors.strSecondary)
        }
    }

    // MARK: - Pie Chart

    private var pieChartCardCdk: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(AllStr.anEc)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(AppColors.strPrimary)

            if expenseByCategoryCdk.isEmpty {
                Text(AllStr.anNm)
                    .font(.system(size: 13))
                    .foregroundColor(AppColors.strHint)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 16)
            } else {
                HStack(spacing: 16) {
                    Chart(expenseByCategoryCdk, id: \.category) { item in
                        SectorMark(
                            angle: .value("amount", item.amount),
                            innerRadius: .ratio(0.55),
                            angularInset: 1
                        )
                        .foregroundStyle(item.color)
                    }
                    .frame(width: 130, height: 130)

                    VStack(spacing: 8) {
                        ForEach(expenseByCategoryCdk, id: \.category) { item in
                            HStack {
                                Circle().fill(item.color).frame(width: 10, height: 10)
                                Text(item.label)
                                    .font(.system(size: 12))
                                    .foregroundColor(AppColors.strSecondary)
                                Spacer()
                                Text(formatIDR(item.amount))
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(AppColors.strPrimary)
                            }
                        }
                    }
                }
            }
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.06), radius: 2, y: 1)
    }

    // MARK: - Top Expenses

    private var topExpensesCardCdk: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(AllStr.anTo)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(AppColors.strPrimary)

            ForEach(Array(expenseByCategoryCdk.prefix(3).enumerated()), id: \.element.category) { idx, item in
                VStack(spacing: 6) {
                    HStack {
                        Text(TransactionCategory.all.first { $0.id == item.category }?.icon ?? "📦")
                        Text(item.label)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(AppColors.strPrimary)
                        Spacer()
                        Text(formatIDR(item.amount))
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(AppColors.strPrimary)
                    }
                    GeometryReader { geo in
                        RoundedRectangle(cornerRadius: 3)
                            .fill(AppColors.launchBackground)
                            .frame(height: 6)
                            .overlay(alignment: .leading) {
                                let pct = totalExpenseCdk > 0 ? item.amount / totalExpenseCdk : 0
                                RoundedRectangle(cornerRadius: 3)
                                    .fill(item.color)
                                    .frame(width: geo.size.width * CGFloat(pct), height: 6)
                            }
                    }
                    .frame(height: 6)
                }
            }

            if expenseByCategoryCdk.isEmpty {
                Text(AllStr.anNd)
                    .font(.system(size: 13))
                    .foregroundColor(AppColors.strHint)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 16)
            }
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.06), radius: 2, y: 1)
    }

    // MARK: - Header

    private var headerSectionCdk: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                Button(action: onBack) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(width: 36, height: 36)
                }
                Text(AllStr.anT)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 16)

            HStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(AllStr.anTi)
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.75))
                    Text(formatIDR(totalIncomeCdk))
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text(AllStr.anTe)
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.75))
                    Text(formatIDR(totalExpenseCdk))
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20)
            .padding(.bottom, 24)
        }
        .background(
            LinearGradient(
                colors: [Color(hex: "#1BC459"), Color(hex: "#13A048")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }

}
