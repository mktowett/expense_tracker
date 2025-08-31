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
    @Query(sort: \Transaction.date, order: .reverse) private var transactions: [Transaction]
    
    @State private var selectedCurrency = "KES"
    @State private var defaultCategory: String = "Uncategorized"
    @State private var budgetAlertsEnabled = true
    @State private var notificationsEnabled = true
    @State private var showingClearDataAlert = false
    @State private var showingExportSheet = false
    @State private var showingCategoriesSheet = false
    
    private let currencies = ["KES", "USD", "EUR", "GBP", "JPY"]
    
    var headerSection: some View {
        VStack(alignment: .leading, spacing: CTSpacing.sm) {
            CTTextStyle.titleLarge("Settings")
            CTTextStyle.caption("Customize your expense tracking experience")
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .claudeScreenPadding()
    }
    
    var appInfoSection: some View {
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
        .claudeScreenPadding()
    }
    
    var categoriesSection: some View {
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
                }
            }
        }
        .claudeScreenPadding()
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: CTSpacing.lg) {
                    headerSection
                    appInfoSection
                    categoriesSection
                    
                    Text("Settings functionality will be implemented in future updates")
                        .foregroundColor(.textSecondary)
                        .padding()
                    
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
                    .claudeScreenPadding()
                    
                    Spacer()
                }
                .claudeSectionSpacing()
            }
            .claudeScreenBackground()
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
            // Delete all transactions using SwiftData
            for transaction in transactions {
                modelContext.delete(transaction)
            }
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
                .claudeScreenPadding()
                
                Spacer()
            }
            .claudeScreenBackground()
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
                    categoryDescriptionSection
                    categoriesGridSection
                }
                .claudeScreenPadding()
            }
            .claudeScreenBackground()
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
    
    private var categoryDescriptionSection: some View {
        CTTextStyle.caption("Manage your expense categories")
    }
    
    private var categoriesGridSection: some View {
        CTCard {
            VStack(alignment: .leading, spacing: CTSpacing.md) {
                CTTextStyle.headline("Available Categories")
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: CTSpacing.md) {
                    ForEach(Category.createDefaultCategories(), id: \.id) { category in
                        HStack(spacing: CTSpacing.sm) {
                            Image(systemName: category.icon)
                                .foregroundColor(.iconPrimary)
                            
                            Text(category.name)
                                .font(.body)
                                .foregroundColor(.textPrimary)
                            
                            Spacer()
                        }
                        .padding(CTSpacing.sm)
                        .background(Color.secondaryBackground)
                        .cornerRadius(CTCornerRadius.input)
                    }
                }
            }
        }
    }
}

#Preview {
    SettingsView()
}
