//
//  SettingsView.swift
//  ExpenseLogger
//
//  Created by marvin towett on 30/08/2025.
//

import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var transactions: [Transaction]
    
    @State private var selectedCurrency = "KES"
    @State private var defaultCategory: TransactionCategory = .uncategorized
    @State private var budgetAlertsEnabled = true
    @State private var notificationsEnabled = true
    @State private var showingClearDataAlert = false
    @State private var showingExportSheet = false
    @State private var showingCategoriesSheet = false
    
    private let currencies = ["KES", "USD", "EUR", "GBP", "JPY"]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: CTSpacing.lg) {
                    // Header
                    VStack(alignment: .leading, spacing: CTSpacing.sm) {
                        CTTextStyle.titleLarge("Settings")
                        CTTextStyle.caption("Customize your expense tracking experience")
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .ctHorizontalPadding()
                    
                    // App Info Section
                    CTCard {
                        VStack(alignment: .leading, spacing: CTSpacing.md) {
                            HStack(spacing: CTSpacing.md) {
                                Image(systemName: "dollarsign.circle.fill")
                                    .font(.system(size: 48))
                                    .foregroundColor(.accentColor)
                                
                                VStack(alignment: .leading, spacing: CTSpacing.xs) {
                                    CTTextStyle.headline("ExpenseLogger")
                                    CTTextStyle.caption("Version 1.0.0")
                                    CTTextStyle.caption("\(transactions.count) transactions tracked")
                                }
                                
                                Spacer()
                            }
                        }
                    }
                    .ctHorizontalPadding()
                    
                    // Categories Management
                    CTCard {
                        VStack(alignment: .leading, spacing: CTSpacing.md) {
                            CTTextStyle.headline("Categories")
                            
                            VStack(spacing: 0) {
                                SettingsRow(
                                    title: "Manage Categories",
                                    value: "",
                                    hasChevron: true
                                ) {
                                    showingCategoriesSheet = true
                                }
                                
                                Divider()
                                    .padding(.vertical, CTSpacing.xs)
                                
                                HStack {
                                    Text("Default Category")
                                        .font(.body)
                                        .foregroundColor(.textPrimary)
                                    
                                    Spacer()
                                    
                                    Menu {
                                        ForEach(TransactionCategory.allCases) { category in
                                            Button(action: { defaultCategory = category }) {
                                                HStack {
                                                    Image(systemName: category.icon)
                                                    Text(category.rawValue)
                                                    if defaultCategory == category {
                                                        Image(systemName: "checkmark")
                                                    }
                                                }
                                            }
                                        }
                                    } label: {
                                        HStack(spacing: CTSpacing.xs) {
                                            Image(systemName: defaultCategory.icon)
                                                .foregroundColor(defaultCategory.color)
                                            Text(defaultCategory.rawValue)
                                                .foregroundColor(.textSecondary)
                                            Image(systemName: "chevron.down")
                                                .font(.caption)
                                                .foregroundColor(.textSecondary)
                                        }
                                    }
                                }
                                .padding(.vertical, CTSpacing.xs)
                            }
                        }
                    }
                    .ctHorizontalPadding()
                    
                    // Preferences Section
                    CTCard {
                        VStack(alignment: .leading, spacing: CTSpacing.md) {
                            CTTextStyle.headline("Preferences")
                            
                            VStack(spacing: 0) {
                                HStack {
                                    Text("Currency")
                                        .font(.body)
                                        .foregroundColor(.textPrimary)
                                    
                                    Spacer()
                                    
                                    Menu {
                                        ForEach(currencies, id: \.self) { currency in
                                            Button(action: { selectedCurrency = currency }) {
                                                HStack {
                                                    Text(currency)
                                                    if selectedCurrency == currency {
                                                        Image(systemName: "checkmark")
                                                    }
                                                }
                                            }
                                        }
                                    } label: {
                                        HStack(spacing: CTSpacing.xs) {
                                            Text(selectedCurrency)
                                                .foregroundColor(.textSecondary)
                                            Image(systemName: "chevron.down")
                                                .font(.caption)
                                                .foregroundColor(.textSecondary)
                                        }
                                    }
                                }
                                .padding(.vertical, CTSpacing.xs)
                                
                                Divider()
                                    .padding(.vertical, CTSpacing.xs)
                                
                                HStack {
                                    Text("Budget Alerts")
                                        .font(.body)
                                        .foregroundColor(.textPrimary)
                                    
                                    Spacer()
                                    
                                    Toggle("", isOn: $budgetAlertsEnabled)
                                        .labelsHidden()
                                }
                                .padding(.vertical, CTSpacing.xs)
                                
                                Divider()
                                    .padding(.vertical, CTSpacing.xs)
                                
                                HStack {
                                    Text("Notifications")
                                        .font(.body)
                                        .foregroundColor(.textPrimary)
                                    
                                    Spacer()
                                    
                                    Toggle("", isOn: $notificationsEnabled)
                                        .labelsHidden()
                                }
                                .padding(.vertical, CTSpacing.xs)
                            }
                        }
                    }
                    .ctHorizontalPadding()
                    
                    // Data Management Section
                    CTCard {
                        VStack(alignment: .leading, spacing: CTSpacing.md) {
                            CTTextStyle.headline("Data & Privacy")
                            
                            VStack(spacing: 0) {
                                SettingsRow(
                                    title: "Export Data",
                                    value: "CSV, JSON",
                                    hasChevron: true
                                ) {
                                    showingExportSheet = true
                                }
                                
                                Divider()
                                    .padding(.vertical, CTSpacing.xs)
                                
                                SettingsRow(
                                    title: "Clear All Data",
                                    value: "",
                                    hasChevron: true,
                                    isDestructive: true
                                ) {
                                    showingClearDataAlert = true
                                }
                            }
                        }
                    }
                    .ctHorizontalPadding()
                    
                    // About Section
                    CTCard {
                        VStack(alignment: .leading, spacing: CTSpacing.md) {
                            CTTextStyle.headline("About")
                            
                            VStack(spacing: 0) {
                                SettingsRow(
                                    title: "Privacy Policy",
                                    value: "",
                                    hasChevron: true
                                ) {
                                    // Open privacy policy
                                }
                                
                                Divider()
                                    .padding(.vertical, CTSpacing.xs)
                                
                                SettingsRow(
                                    title: "Terms of Service",
                                    value: "",
                                    hasChevron: true
                                ) {
                                    // Open terms of service
                                }
                                
                                Divider()
                                    .padding(.vertical, CTSpacing.xs)
                                
                                SettingsRow(
                                    title: "Contact Support",
                                    value: "",
                                    hasChevron: true
                                ) {
                                    // Open contact support
                                }
                            }
                        }
                    }
                    .ctHorizontalPadding()
                    
                    Spacer()
                }
                .ctVerticalSpacing(CTSpacing.lg)
            }
            .ctScreenBackground()
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
        }
        .alert("Clear All Data", isPresented: $showingClearDataAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Clear All", role: .destructive) {
                clearAllData()
            }
        } message: {
            Text("This will permanently delete all your transactions. This action cannot be undone.")
        }
        .sheet(isPresented: $showingExportSheet) {
            ExportDataView()
        }
        .sheet(isPresented: $showingCategoriesSheet) {
            CategoriesManagementView()
        }
    }
    
    private func clearAllData() {
        do {
            try modelContext.delete(model: Transaction.self)
            try modelContext.save()
        } catch {
            print("Failed to clear data: \(error)")
        }
    }
}

struct SettingsRow: View {
    let title: String
    let value: String
    let hasChevron: Bool
    let isDestructive: Bool
    let action: () -> Void
    
    init(
        title: String,
        value: String,
        hasChevron: Bool = false,
        isDestructive: Bool = false,
        action: @escaping () -> Void = {}
    ) {
        self.title = title
        self.value = value
        self.hasChevron = hasChevron
        self.isDestructive = isDestructive
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .font(.body)
                    .foregroundColor(isDestructive ? .errorColor : .textPrimary)
                
                Spacer()
                
                if !value.isEmpty {
                    Text(value)
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                }
                
                if hasChevron {
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                }
            }
            .padding(.vertical, CTSpacing.xs)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ExportDataView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: CTSpacing.lg) {
                VStack(spacing: CTSpacing.md) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 64))
                        .foregroundColor(.accentColor)
                    
                    CTTextStyle.headline("Export Your Data")
                    CTTextStyle.body("Choose a format to export your transaction data")
                }
                .padding(.top, CTSpacing.xl)
                
                VStack(spacing: CTSpacing.md) {
                    CTButton(title: "Export as CSV", action: {
                        // Export as CSV
                        dismiss()
                    })
                    
                    CTButton(title: "Export as JSON", action: {
                        // Export as JSON
                        dismiss()
                    }, style: .secondary)
                }
                .ctHorizontalPadding()
                
                Spacer()
            }
            .ctScreenBackground()
            .navigationTitle("Export Data")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct CategoriesManagementView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: CTSpacing.lg) {
                    CTTextStyle.caption("Manage your expense categories")
                        .ctHorizontalPadding()
                    
                    CTCard {
                        VStack(alignment: .leading, spacing: CTSpacing.md) {
                            CTTextStyle.headline("Available Categories")
                            
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: CTSpacing.md) {
                                ForEach(TransactionCategory.allCases) { category in
                                    HStack(spacing: CTSpacing.sm) {
                                        Image(systemName: category.icon)
                                            .foregroundColor(category.color)
                                        
                                        Text(category.rawValue)
                                            .font(.body)
                                            .foregroundColor(.textPrimary)
                                        
                                        Spacer()
                                    }
                                    .padding(CTSpacing.sm)
                                    .background(Color.secondaryBackground)
                                    .cornerRadius(CTCornerRadius.button)
                                }
                            }
                        }
                    }
                    .ctHorizontalPadding()
                    
                    Spacer()
                }
                .ctVerticalSpacing(CTSpacing.lg)
            }
            .ctScreenBackground()
            .navigationTitle("Categories")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    SettingsView()
        .modelContainer(for: Transaction.self, inMemory: true)
}
