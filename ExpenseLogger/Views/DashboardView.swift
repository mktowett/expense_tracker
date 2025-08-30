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
    @Query private var transactions: [Transaction]
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
            .filter { $0.date >= startOfMonth && $0.type == .expense }
            .reduce(0) { $0 + $1.amount }
    }
    
    private var monthlyIncome: Double {
        let calendar = Calendar.current
        let now = Date()
        let startOfMonth = calendar.dateInterval(of: .month, for: now)?.start ?? now
        
        return transactions
            .filter { $0.date >= startOfMonth && $0.type == .income }
            .reduce(0) { $0 + $1.amount }
    }
    
    private var transactionCount: Int {
        let calendar = Calendar.current
        let now = Date()
        let startOfMonth = calendar.dateInterval(of: .month, for: now)?.start ?? now
        
        return transactions.filter { $0.date >= startOfMonth }.count
    }
    
    private var topCategory: TransactionCategory? {
        let calendar = Calendar.current
        let now = Date()
        let startOfMonth = calendar.dateInterval(of: .month, for: now)?.start ?? now
        
        let monthlyTransactions = transactions.filter { $0.date >= startOfMonth && $0.type == .expense }
        
        let categoryTotals = Dictionary(grouping: monthlyTransactions, by: { $0.category })
            .mapValues { $0.reduce(0) { $0 + $1.amount } }
        
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
        Array(transactions.sorted(by: { $0.date > $1.date }).prefix(5))
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
                                        Image(systemName: category.icon)
                                            .foregroundColor(category.color)
                                        Text(category.rawValue)
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
            // Add mock data if no transactions exist
            if transactions.isEmpty {
                addMockData()
            }
        }
    }
    
    private func addMockData() {
        let mockTransactions = MockData.createMockTransactions()
        for transaction in mockTransactions {
            modelContext.insert(transaction)
        }
        
        do {
            try modelContext.save()
        } catch {
            print("Failed to save mock data: \(error)")
        }
    }
}

struct TransactionRow: View {
    let transaction: Transaction
    
    var body: some View {
        HStack(spacing: CTSpacing.md) {
            // Category Icon
            Image(systemName: transaction.category.icon)
                .font(.title3)
                .foregroundColor(transaction.category.color)
                .frame(width: 24, height: 24)
            
            // Transaction Details
            VStack(alignment: .leading, spacing: CTSpacing.xs) {
                Text(transaction.merchant)
                    .font(.headline)
                    .foregroundColor(.textPrimary)
                    .lineLimit(1)
                
                HStack(spacing: CTSpacing.xs) {
                    Text(transaction.shortDate)
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                    
                    Text("•")
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                    
                    Text(transaction.timeOnly)
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                }
            }
            
            Spacer()
            
            // Amount
            VStack(alignment: .trailing, spacing: CTSpacing.xs) {
                Text(transaction.type == .income ? "+\(transaction.formattedAmount)" : "-\(transaction.formattedAmount)")
                    .font(.headline)
                    .foregroundColor(transaction.type == .income ? .successColor : .textPrimary)
                
                Text(transaction.category.rawValue)
                    .font(.caption)
                    .foregroundColor(.textSecondary)
            }
        }
        .padding(.vertical, CTSpacing.sm)
        .padding(.horizontal, CTSpacing.md)
    }
}

#Preview {
    DashboardView()
        .modelContainer(for: Transaction.self, inMemory: true)
}
