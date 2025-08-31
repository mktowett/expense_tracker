//
//  DashboardView.swift
//  ExpenseLogger
//
//  Created by marvin towett on 30/08/2025.
//

import SwiftUI
import SwiftData

struct DashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Transaction.date, order: .reverse) private var transactions: [Transaction]
    
    private func formatAmount(_ amount: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "KES"
        return formatter.string(from: amount as NSDecimalNumber) ?? "0"
    }
    @State private var showingAddTransaction = false
    
    private var currentMonth: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: Date())
    }
    
    private var monthlyTotal: Double {
        let calendar = Calendar.current
        let now = Date()
        let startOfMonth = calendar.dateInterval(of: .month, for: now)?.start ?? now
        
        return transactions
            .filter { $0.date >= startOfMonth && !$0.isIncome }
            .reduce(0) { $0 + NSDecimalNumber(decimal: $1.amount).doubleValue }
    }
    
    private var monthlyIncome: Double {
        let calendar = Calendar.current
        let now = Date()
        let startOfMonth = calendar.dateInterval(of: .month, for: now)?.start ?? now
        
        return transactions
            .filter { $0.date >= startOfMonth && $0.isIncome }
            .reduce(0) { $0 + NSDecimalNumber(decimal: $1.amount).doubleValue }
    }
    
    private var transactionCount: Int {
        let calendar = Calendar.current
        let now = Date()
        let startOfMonth = calendar.dateInterval(of: .month, for: now)?.start ?? now
        
        return transactions.filter { $0.date >= startOfMonth }.count
    }
    
    private var topCategory: Category? {
        let calendar = Calendar.current
        let now = Date()
        let startOfMonth = calendar.dateInterval(of: .month, for: now)?.start ?? now
        
        let monthlyTransactions = transactions.filter { $0.date >= startOfMonth && !$0.isIncome }
        
        let categoryTotals = Dictionary(grouping: monthlyTransactions, by: { $0.category })
            .compactMapValues { transactions in
                transactions.reduce(0) { $0 + NSDecimalNumber(decimal: $1.amount).doubleValue }
            }
        
        return categoryTotals.max(by: { $0.value < $1.value })?.key
    }
    
    private var averagePerDay: Double {
        let calendar = Calendar.current
        let now = Date()
        let startOfMonth = calendar.dateInterval(of: .month, for: now)?.start ?? now
        let daysInMonth = calendar.dateComponents([.day], from: startOfMonth, to: now).day ?? 1
        
        return daysInMonth > 0 ? monthlyTotal / Double(max(daysInMonth, 1)) : 0
    }
    
    private var currentMpesaBalance: Decimal? {
        return BalanceCalculator.getCurrentMpesaBalance(from: transactions)
    }
    
    private var monthlyFees: Decimal {
        return BalanceCalculator.getMonthlyFees(from: transactions)
    }
    
    private var netCashFlow: Decimal {
        return BalanceCalculator.getNetCashFlow(from: transactions)
    }
    
    private var recentTransactions: [Transaction] {
        Array(transactions.prefix(5))
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: CTSpacing.lg) {
                    // Header
                    VStack(alignment: .leading, spacing: CTSpacing.sm) {
                        CTTextStyle.titleLarge("Dashboard")
                        CTTextStyle.caption("Welcome back! Here's your spending overview")
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .claudeScreenPadding()
                    
                    // M-Pesa Balance Hero Card
                    VStack(alignment: .leading, spacing: CTSpacing.md) {
                        HStack {
                            VStack(alignment: .leading, spacing: CTSpacing.sm) {
                                Text("M-Pesa Balance")
                                    .font(.balanceLabel)
                                    .foregroundColor(.textSecondary)
                                if let balance = currentMpesaBalance {
                                    HStack(spacing: 6) {
                                        Text("KES")
                                            .font(.balanceLabel)
                                            .foregroundColor(.textSecondary)
                                        Text("\(NSDecimalNumber(decimal: balance).doubleValue, specifier: "%.2f")")
                                            .font(.balanceAmount)
                                            .foregroundColor(balance >= 0 ? .successColor : .errorColor)
                                    }
                                } else {
                                    Text("No Balance Data")
                                        .font(.system(size: 24, weight: .medium, design: .rounded))
                                        .foregroundColor(.textSecondary)
                                }
                                
                                Spacer()
                                
                                VStack(alignment: .trailing, spacing: CTSpacing.xs) {
                                    Text("Net Cash Flow")
                                        .font(.statsLabel)
                                        .foregroundColor(.textSecondary)
                                    Text("KES \(NSDecimalNumber(decimal: netCashFlow).doubleValue, specifier: "%.2f")")
                                        .font(.statsAmount)
                                        .foregroundColor(netCashFlow >= 0 ? .successColor : .errorColor)
                                }
                            }
                            
                            HStack {
                                Text(currentMonth)
                                    .font(.transactionDate)
                                    .foregroundColor(.textTertiary)
                                Spacer()
                                if monthlyFees > 0 {
                                    Text("Fees: KES \(NSDecimalNumber(decimal: monthlyFees).doubleValue, specifier: "%.2f")")
                                        .font(.transactionDate)
                                        .foregroundColor(.textTertiary)
                                }
                            }
                        }
                    }
                    .claudeCard()
                    .claudeScreenPadding()
                    
                    // Balance Stats Row
                    HStack(spacing: CTSpacing.sm) {
                        // Monthly Expenses
                        VStack(alignment: .leading, spacing: CTSpacing.xs) {
                            Text("KES \(monthlyTotal, specifier: "%.0f")")
                                .font(.statsAmount)
                                .foregroundColor(.errorColor)
                            Text("Expenses")
                                .font(.statsLabel)
                                .foregroundColor(.textSecondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(CTSpacing.md)
                        .background(Color.cardBackground)
                        .cornerRadius(CTCornerRadius.card)
                        .overlay(
                            RoundedRectangle(cornerRadius: CTCornerRadius.card)
                                .stroke(Color.cardBorder, lineWidth: 1)
                        )
                        
                        // Monthly Income
                        VStack(alignment: .leading, spacing: CTSpacing.xs) {
                            Text("KES \(monthlyIncome, specifier: "%.0f")")
                                .font(.statsAmount)
                                .foregroundColor(.successColor)
                            Text("Income")
                                .font(.statsLabel)
                                .foregroundColor(.textSecondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(CTSpacing.md)
                        .background(Color.cardBackground)
                        .cornerRadius(CTCornerRadius.card)
                        .overlay(
                            RoundedRectangle(cornerRadius: CTCornerRadius.card)
                                .stroke(Color.cardBorder, lineWidth: 1)
                        )
                        
                        // Monthly Fees
                        VStack(alignment: .leading, spacing: CTSpacing.xs) {
                            Text("KES \(NSDecimalNumber(decimal: monthlyFees).doubleValue, specifier: "%.0f")")
                                .font(.statsAmount)
                                .foregroundColor(.warningColor)
                            Text("M-Pesa Fees")
                                .font(.statsLabel)
                                .foregroundColor(.textSecondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(CTSpacing.md)
                        .background(Color.cardBackground)
                        .cornerRadius(CTCornerRadius.card)
                        .overlay(
                            RoundedRectangle(cornerRadius: CTCornerRadius.card)
                                .stroke(Color.cardBorder, lineWidth: 1)
                        )
                    }
                    .claudeScreenPadding()
                    
                    // Recent Transactions Section
                    VStack(alignment: .leading, spacing: CTSpacing.md) {
                        HStack {
                            CTTextStyle.headline("Recent Transactions")
                            Spacer()
                            if !recentTransactions.isEmpty {
                                Button("View All") {
                                    // Navigate to transactions tab
                                }
                                .font(.caption)
                                .foregroundColor(.accentColor)
                            }
                        }
                        
                        if recentTransactions.isEmpty {
                            CTCard {
                                VStack(spacing: CTSpacing.md) {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.system(size: 48))
                                        .foregroundColor(.accentColor)
                                    
                                    CTTextStyle.headline("No Transactions Yet")
                                    CTTextStyle.body("Start by adding your first transaction")
                                    
                                    CTButton(title: "Add Transaction", action: {
                                        showingAddTransaction = true
                                    })
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, CTSpacing.lg)
                            }
                        } else {
                            VStack(spacing: 0) {
                                ForEach(Array(recentTransactions.enumerated()), id: \.element.id) { index, transaction in
                                    TransactionRow(transaction: transaction)
                                        .padding(.vertical, CTSpacing.lg)
                                    
                                    if index < recentTransactions.count - 1 {
                                        Divider()
                                            .background(Color.cardBorder)
                                    }
                                }
                            }
                            .claudeCard()
                        }
                    }
                    .claudeScreenPadding()
                    
                    Spacer()
                }
                .claudeSectionSpacing()
            }
            .claudeScreenBackground()
            .refreshable {
                // Refresh data
            }
        }
        .sheet(isPresented: $showingAddTransaction) {
            AddTransactionView()
        }
        .onAppear {
            // Initialize default categories if needed
            if transactions.isEmpty {
                let defaultCategories = Category.createDefaultCategories()
                for category in defaultCategories {
                    modelContext.insert(category)
                }
            }
        }
    }
}

struct TransactionRow: View {
    let transaction: Transaction
    
    private func formatAmount(_ amount: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "KES"
        return formatter.string(from: amount as NSDecimalNumber) ?? "0"
    }
    
    var body: some View {
        HStack(spacing: CTSpacing.md) {
            // Category Icon
            Image(systemName: transaction.category?.icon ?? "questionmark.circle")
                .font(.title2)
                .foregroundColor(.iconPrimary)
                .frame(width: 32, height: 32)
            
            // Transaction Details
            VStack(alignment: .leading, spacing: CTSpacing.xs) {
                Text(transaction.merchant)
                    .font(.merchantName)
                    .foregroundColor(.textPrimary)
                    .lineLimit(1)
                
                HStack(spacing: CTSpacing.xs) {
                    Text(transaction.date.formatted(date: .abbreviated, time: .omitted))
                        .font(.transactionDate)
                        .foregroundColor(.textSecondary)
                    
                    Text("•")
                        .font(.transactionDate)
                        .foregroundColor(.textTertiary)
                    
                    Text(transaction.transactionType.rawValue.capitalized)
                        .font(.transactionType)
                        .foregroundColor(.textTertiary)
                    
                    if let category = transaction.category {
                        Text("•")
                            .font(.transactionDate)
                            .foregroundColor(.textTertiary)
                        
                        Text(category.name)
                            .font(.transactionType)
                            .foregroundColor(.textTertiary)
                    }
                }
            }
            
            Spacer()
            
            // Amount and Balance Info
            VStack(alignment: .trailing, spacing: CTSpacing.xs) {
                Text(transaction.isIncome ? "+\(formatAmount(transaction.amount))" : "-\(formatAmount(transaction.amount))")
                    .font(.statsAmount)
                    .foregroundColor(transaction.isIncome ? .successColor : .errorColor)
                
                if transaction.fees > 0 {
                    Text("Fee: \(formatAmount(transaction.fees))")
                        .font(.transactionType)
                        .foregroundColor(.textTertiary)
                }
            }
        }
    }
}

#Preview {
    DashboardView()
}
