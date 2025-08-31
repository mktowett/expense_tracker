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
                    
                    // Monthly Summary Hero Card
                    CTCard {
                        VStack(alignment: .leading, spacing: CTSpacing.md) {
                            HStack {
                                VStack(alignment: .leading, spacing: CTSpacing.xs) {
                                    CTTextStyle.caption("Total Spent")
                                    Text("KES \(monthlyTotal, specifier: "%.2f")")
                                        .font(.system(size: 36, weight: .bold, design: .rounded))
                                        .foregroundColor(.accentColor)
                                }
                                
                                Spacer()
                                
                                VStack(alignment: .trailing, spacing: CTSpacing.xs) {
                                    CTTextStyle.caption("Income")
                                    Text("KES \(monthlyIncome, specifier: "%.2f")")
                                        .font(.claudeTitleMedium)
                                        .foregroundColor(.successColor)
                                }
                            }
                            
                            CTTextStyle.caption(currentMonth)
                        }
                    }
                    .claudeScreenPadding()
                    
                    // Quick Stats Row
                    HStack(spacing: CTSpacing.md) {
                        // Transaction Count
                        CTCard(hasBorder: false) {
                            VStack(alignment: .leading, spacing: CTSpacing.xs) {
                                Text("\(transactionCount)")
                                    .font(.claudeTitleMedium)
                                    .foregroundColor(.textPrimary)
                                CTTextStyle.caption("Transactions")
                            }
                        }
                        
                        // Top Category
                        CTCard(hasBorder: false) {
                            VStack(alignment: .leading, spacing: CTSpacing.xs) {
                                HStack(spacing: CTSpacing.xs) {
                                    if let category = topCategory {
                                        Image(systemName: category.icon ?? "tag")
                                            .foregroundColor(Color(hex: category.color ?? "#6B7280"))
                                        Text(category.name ?? "Unknown")
                                            .font(.claudeHeadline)
                                            .foregroundColor(.textPrimary)
                                    } else {
                                        Text("None")
                                            .font(.claudeHeadline)
                                            .foregroundColor(.textSecondary)
                                    }
                                }
                                CTTextStyle.caption("Top Category")
                            }
                        }
                        
                        // Average per Day
                        CTCard(hasBorder: false) {
                            VStack(alignment: .leading, spacing: CTSpacing.xs) {
                                Text("KES \(averagePerDay, specifier: "%.0f")")
                                    .font(.claudeTitleMedium)
                                    .foregroundColor(.textPrimary)
                                CTTextStyle.caption("Daily Avg")
                            }
                        }
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
                            CTCard {
                                VStack(spacing: 0) {
                                    ForEach(Array(recentTransactions.enumerated()), id: \.element.id) { index, transaction in
                                        TransactionRow(transaction: transaction)
                                        
                                        if index < recentTransactions.count - 1 {
                                            Divider()
                                                .padding(.horizontal, CTSpacing.md)
                                        }
                                    }
                                }
                            }
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
                .foregroundColor(transaction.category?.swiftUIColor ?? .gray)
                .frame(width: 32, height: 32)
            
            // Transaction Details
            VStack(alignment: .leading, spacing: CTSpacing.xs) {
                Text(transaction.merchant)
                    .font(.headline)
                    .foregroundColor(.textPrimary)
                    .lineLimit(1)
                
                HStack(spacing: CTSpacing.xs) {
                    Text(transaction.date.formatted(date: .abbreviated, time: .omitted))
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                    
                    if let notes = transaction.notes, !notes.isEmpty {
                        Text("•")
                            .font(.caption)
                            .foregroundColor(.textSecondary)
                        
                        Text(notes)
                            .font(.caption)
                            .foregroundColor(.textSecondary)
                            .lineLimit(1)
                    }
                }
            }
            
            Spacer()
            
            // Amount
            VStack(alignment: .trailing, spacing: CTSpacing.xs) {
                Text(transaction.isIncome ? "+\(formatAmount(transaction.amount))" : "-\(formatAmount(transaction.amount))")
                    .font(.headline)
                    .foregroundColor(transaction.isIncome ? .successColor : .textPrimary)
                
                if let category = transaction.category {
                    Text(category.name)
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                }
            }
        }
        .padding(.vertical, CTSpacing.sm)
        .padding(.horizontal, CTSpacing.md)
    }
}

#Preview {
    DashboardView()
}
