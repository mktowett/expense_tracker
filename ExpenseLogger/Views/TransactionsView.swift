//
//  TransactionsView.swift
//  ExpenseLogger
//
//  Created by marvin towett on 30/08/2025.
//

import SwiftUI
import SwiftData

struct TransactionsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Transaction.date, order: .reverse) private var transactions: [Transaction]
    
    private func formatAmount(_ amount: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "KES"
        return formatter.string(from: amount as NSDecimalNumber) ?? "0"
    }
    @Query(sort: \Category.name) private var categories: [Category]
    
    @State private var searchText: String = ""
    @State private var selectedSortOption: SortOption = .dateDescending
    @State private var selectedCategoryFilter: Category? = nil
    @State private var showingFilters = false
    
    enum SortOption: String, CaseIterable {
        case dateDescending = "Date (Newest)"
        case dateAscending = "Date (Oldest)"
        case amountDescending = "Amount (High to Low)"
        case amountAscending = "Amount (Low to High)"
        case merchant = "Merchant (A-Z)"
        
        var systemImage: String {
            switch self {
            case .dateDescending, .dateAscending:
                return "calendar"
            case .amountDescending, .amountAscending:
                return "dollarsign.circle"
            case .merchant:
                return "textformat.abc"
            }
        }
    }
    
    private var filteredAndSortedTransactions: [Transaction] {
        var transactions = Array(self.transactions)
        
        // Apply search filter
        if !searchText.isEmpty {
            transactions = transactions.filter { transaction in
                transaction.merchant.localizedCaseInsensitiveContains(searchText) ||
                (transaction.notes?.localizedCaseInsensitiveContains(searchText) ?? false) ||
                (transaction.category?.name.localizedCaseInsensitiveContains(searchText) ?? false)
            }
        }
        
        // Apply category filter
        if let selectedCategory = selectedCategoryFilter {
            transactions = transactions.filter { $0.category == selectedCategory }
        }
        
        // Apply sorting
        switch selectedSortOption {
        case .dateDescending:
            transactions.sort { $0.date > $1.date }
        case .dateAscending:
            transactions.sort { $0.date < $1.date }
        case .amountDescending:
            transactions.sort { $0.amount > $1.amount }
        case .amountAscending:
            transactions.sort { $0.amount < $1.amount }
        case .merchant:
            transactions.sort { $0.merchant < $1.merchant }
        }
        
        return transactions
    }
    
    private var groupedTransactions: [(String, [Transaction])] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: filteredAndSortedTransactions) { transaction in
            let date = transaction.date
            if calendar.isDateInToday(date) {
                return "Today"
            } else if calendar.isDateInYesterday(date) {
                return "Yesterday"
            } else {
                let formatter = DateFormatter()
                formatter.dateFormat = "MMM dd, yyyy"
                return formatter.string(from: date)
            }
        }
        
        return grouped.sorted { first, second in
            if first.key == "Today" { return true }
            if second.key == "Today" { return false }
            if first.key == "Yesterday" { return true }
            if second.key == "Yesterday" { return false }
            return first.key > second.key
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            searchAndFilterSection
            transactionListSection
        }
        .claudeScreenBackground()
        .navigationTitle("Transactions")
        .navigationBarTitleDisplayMode(.large)
        .refreshable {
            // Pull to refresh
        }
    }
    
    private var searchAndFilterSection: some View {
        VStack(spacing: CTSpacing.md) {
            searchBarSection
            
            if showingFilters {
                filterPillsSection
            }
        }
        .padding(.horizontal, CTSpacing.screenPadding)
        .padding(.vertical, CTSpacing.md)
        .background(Color.secondaryBackground)
    }
    
    private var searchBarSection: some View {
        HStack(spacing: CTSpacing.sm) {
            HStack(spacing: CTSpacing.sm) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.iconPrimary)
                
                TextField("Search transactions...", text: $searchText)
                    .textFieldStyle(PlainTextFieldStyle())
            }
            .padding(CTSpacing.md)
            .background(Color.primaryBackground)
            .cornerRadius(CTCornerRadius.input)
            .overlay(
                RoundedRectangle(cornerRadius: CTCornerRadius.input)
                    .stroke(Color.cardBorder, lineWidth: 1)
            )
            
            Button(action: { showingFilters.toggle() }) {
                Image(systemName: "line.3.horizontal.decrease.circle")
                    .font(.title2)
                    .foregroundColor(.iconPrimary)
            }
        }
    }
    
    private var filterPillsSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: CTSpacing.sm) {
                // Sort Options
                Menu {
                    ForEach(SortOption.allCases, id: \.self) { option in
                        Button(action: { selectedSortOption = option }) {
                            HStack {
                                Text(option.rawValue)
                                if selectedSortOption == option {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                } label: {
                    HStack(spacing: CTSpacing.xs) {
                        Image(systemName: selectedSortOption.systemImage)
                            .foregroundColor(.iconPrimary)
                        Text(selectedSortOption.rawValue)
                        Image(systemName: "chevron.down")
                            .foregroundColor(.iconPrimary)
                    }
                    .font(.transactionType)
                    .foregroundColor(.textSecondary)
                    .padding(.horizontal, CTSpacing.md)
                    .padding(.vertical, CTSpacing.sm)
                    .background(Color.cardBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: CTCornerRadius.input)
                            .stroke(Color.cardBorder, lineWidth: 1)
                    )
                    .cornerRadius(CTCornerRadius.input)
                }
                
                // Category Filters
                Button(action: { selectedCategoryFilter = nil }) {
                    Text("All Categories")
                        .font(.transactionType)
                        .foregroundColor(selectedCategoryFilter == nil ? .white : .textSecondary)
                        .padding(.horizontal, CTSpacing.md)
                        .padding(.vertical, CTSpacing.sm)
                        .background(selectedCategoryFilter == nil ? Color.accentColor : Color.cardBackground)
                        .overlay(
                            RoundedRectangle(cornerRadius: CTCornerRadius.input)
                                .stroke(selectedCategoryFilter == nil ? Color.clear : Color.cardBorder, lineWidth: 1)
                        )
                        .cornerRadius(CTCornerRadius.input)
                }
                
                ForEach(categories, id: \.id) { category in
                    Button(action: { selectedCategoryFilter = category }) {
                        HStack(spacing: CTSpacing.xs) {
                            Image(systemName: category.icon ?? "tag")
                                .foregroundColor(.iconPrimary)
                            Text(category.name ?? "Unknown")
                        }
                        .font(.transactionType)
                        .foregroundColor(selectedCategoryFilter == category ? .white : .textSecondary)
                        .padding(.horizontal, CTSpacing.md)
                        .padding(.vertical, CTSpacing.sm)
                        .background(selectedCategoryFilter?.id == category.id ? Color.accentColor : Color.cardBackground)
                        .overlay(
                            RoundedRectangle(cornerRadius: CTCornerRadius.input)
                                .stroke(selectedCategoryFilter?.id == category.id ? Color.clear : Color.cardBorder, lineWidth: 1)
                        )
                        .cornerRadius(CTCornerRadius.input)
                    }
                }
            }
            .padding(.horizontal, CTSpacing.screenPadding)
        }
    }
    
    private var transactionListSection: some View {
        Group {
            // Transaction List
            if filteredAndSortedTransactions.isEmpty {
                Spacer()
                
                VStack(spacing: CTSpacing.lg) {
                    Image(systemName: searchText.isEmpty ? "list.bullet.clipboard" : "magnifyingglass")
                        .font(.system(size: 64))
                        .foregroundColor(.textSecondary)
                    
                    VStack(spacing: CTSpacing.sm) {
                        CTTextStyle.headline(searchText.isEmpty ? "No Transactions Yet" : "No Results Found")
                        CTTextStyle.body(searchText.isEmpty ? "Your transaction history will appear here" : "Try adjusting your search or filters")
                    }
                    
                    if searchText.isEmpty {
                        CTButton(title: "Add Your First Transaction", action: {
                            // Navigate to add transaction
                        })
                    }
                }
                .padding(CTSpacing.xl)
                
                Spacer()
            } else {
                ScrollView {
                    LazyVStack(spacing: CTSpacing.lg, pinnedViews: [.sectionHeaders]) {
                        ForEach(groupedTransactions, id: \.0) { sectionTitle, transactions in
                            Section {
                                VStack(spacing: 0) {
                                    ForEach(Array(transactions.enumerated()), id: \.element.id) { index, transaction in
                                        TransactionListRow(transaction: transaction) {
                                            // Handle transaction tap
                                        }
                                        
                                        if index < transactions.count - 1 {
                                            Divider()
                                                .background(Color.cardBorder)
                                        }
                                    }
                                }
                                .claudeCard()
                            } header: {
                                HStack {
                                    Text(sectionTitle)
                                        .font(.balanceLabel)
                                        .foregroundColor(.textPrimary)
                                    
                                    Spacer()
                                    
                                    Text("\(transactions.count) transaction\(transactions.count == 1 ? "" : "s")")
                                        .font(.transactionType)
                                        .foregroundColor(.textSecondary)
                                }
                                .padding(.horizontal, CTSpacing.screenPadding)
                                .padding(.vertical, CTSpacing.sm)
                                .background(Color.secondaryBackground)
                            }
                        }
                    }
                    .padding(.horizontal, CTSpacing.screenPadding)
                }
            }
        }
    }
}

struct TransactionListRow: View {
    let transaction: Transaction
    let onTap: () -> Void
    
    private func formatAmount(_ amount: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "KES"
        return formatter.string(from: amount as NSDecimalNumber) ?? "0"
    }
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: CTSpacing.md) {
                // Category Icon
                Image(systemName: transaction.category?.icon ?? "tag")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.iconPrimary)
                    .frame(width: 40, height: 40)
                    .background(Color.iconPrimary.opacity(0.1))
                    .clipShape(Circle())
                
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
                
                // Amount and Fees
                VStack(alignment: .trailing, spacing: CTSpacing.xs) {
                    Text(transaction.isIncome ? "+\(self.formatAmount(transaction.amount))" : "-\(self.formatAmount(transaction.amount))")
                        .font(.transactionAmount)
                        .foregroundColor(transaction.isIncome ? .successColor : .errorColor)
                    
                    if transaction.fees > 0 {
                        Text("Fee: \(formatAmount(transaction.fees))")
                            .font(.transactionType)
                            .foregroundColor(.textTertiary)
                    }
                }
            }
            .padding(.vertical, CTSpacing.md)
        }
        .buttonStyle(PlainButtonStyle())
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button("Delete", role: .destructive) {
                // Delete transaction
            }
            
            Button("Edit") {
                // Edit transaction
            }
            .tint(.accentColor)
        }
    }
}

#Preview {
    TransactionsView()
}
