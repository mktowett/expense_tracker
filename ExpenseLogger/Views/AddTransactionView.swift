//
//  AddTransactionView.swift
//  ExpenseLogger
//
//  Created by marvin towett on 30/08/2025.
//

import SwiftUI
import SwiftData

struct AddTransactionView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var smsText: String = ""
    @State private var parsedTransaction: (amount: Double, merchant: String, type: TransactionType)?
    @State private var selectedCategory: TransactionCategory = .uncategorized
    @State private var notes: String = ""
    @State private var showingPreview: Bool = false
    @State private var showingSaveAlert: Bool = false
    
    @FocusState private var isTextViewFocused: Bool
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: CTSpacing.lg) {
                    headerSection
                    smsInputSection
                    
                    if showingPreview, let transaction = parsedTransaction {
                        transactionPreviewSection(transaction: transaction)
                    }
                    
                    if showingPreview {
                        categorySelectionSection
                        notesSection
                    }
                    
                    Spacer()
                }
                .claudeSectionSpacing()
            }
            .claudeScreenBackground()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.textSecondary)
                }
                
                if showingPreview {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Save") {
                            saveTransaction()
                        }
                        .foregroundColor(.accentColor)
                        .fontWeight(.semibold)
                    }
                }
            }
            .onAppear {
                isTextViewFocused = true
            }
        }
        .alert("Transaction Saved", isPresented: $showingSaveAlert) {
            Button("OK") {
                dismiss()
            }
        } message: {
            Text("Your transaction has been saved successfully.")
        }
    }
    
    // MARK: - View Components
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: CTSpacing.sm) {
            CTTextStyle.titleLarge("Add Transaction")
            CTTextStyle.caption("Paste your M-Pesa or bank SMS here...")
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .claudeScreenPadding()
    }
    
    private var smsInputSection: some View {
        VStack(alignment: .leading, spacing: CTSpacing.md) {
            CTTextStyle.headline("SMS Message")
            
            CTTextView(
                placeholder: "Paste your M-Pesa or bank SMS here...",
                text: $smsText,
                minHeight: 150
            )
            .focused($isTextViewFocused)
            .onChange(of: smsText) { _, newValue in
                parseSMSText(newValue)
            }
        }
        .claudeScreenPadding()
    }
    
    private func transactionPreviewSection(transaction: (amount: Double, merchant: String, type: TransactionType)) -> some View {
        VStack(alignment: .leading, spacing: CTSpacing.md) {
            CTTextStyle.headline("Transaction Preview")
            
            CTCard {
                VStack(alignment: .leading, spacing: CTSpacing.md) {
                    HStack {
                        VStack(alignment: .leading, spacing: CTSpacing.xs) {
                            CTTextStyle.caption("Amount")
                            Text("KES \(transaction.amount, specifier: "%.2f")")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(transaction.type == .income ? .successColor : .textPrimary)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: CTSpacing.xs) {
                            CTTextStyle.caption("Type")
                            Text(transaction.type.rawValue)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(transaction.type == .income ? .successColor : .errorColor)
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: CTSpacing.xs) {
                        CTTextStyle.caption("Merchant")
                        CTTextStyle.body(transaction.merchant)
                    }
                    
                    VStack(alignment: .leading, spacing: CTSpacing.xs) {
                        CTTextStyle.caption("Date & Time")
                        CTTextStyle.body(Date().formatted(date: .abbreviated, time: .shortened))
                    }
                }
            }
        }
        .claudeScreenPadding()
        .transition(.move(edge: .top).combined(with: .opacity))
    }
    
    private var categorySelectionSection: some View {
        VStack(alignment: .leading, spacing: CTSpacing.md) {
            CTTextStyle.headline("Category")
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: CTSpacing.sm) {
                    ForEach(TransactionCategory.allCases) { category in
                        CategoryTag(
                            category: category,
                            isSelected: selectedCategory == category
                        ) {
                            selectedCategory = category
                        }
                    }
                }
                .padding(.horizontal, CTSpacing.screenPadding)
            }
        }
        .claudeScreenPadding()
    }
    
    private var notesSection: some View {
        VStack(alignment: .leading, spacing: CTSpacing.md) {
            CTTextStyle.headline("Notes (Optional)")
            
            CTTextField(
                placeholder: "Add any additional notes...",
                text: $notes
            )
        }
        .claudeScreenPadding()
    }
    
    private func parseSMSText(_ text: String) {
        if text.isEmpty {
            parsedTransaction = nil
            showingPreview = false
            return
        }
        
        if let parsed = MockData.parseTransactionFromSMS(text) {
            parsedTransaction = parsed
            withAnimation(.easeInOut(duration: 0.3)) {
                showingPreview = true
            }
        } else {
            parsedTransaction = nil
            withAnimation(.easeInOut(duration: 0.3)) {
                showingPreview = false
            }
        }
    }
    
    private func saveTransaction() {
        guard let parsed = parsedTransaction else { return }
        
        let transaction = Transaction(
            amount: parsed.amount,
            merchant: parsed.merchant,
            category: selectedCategory,
            date: Date(),
            notes: notes,
            type: parsed.type,
            originalSMS: smsText
        )
        
        modelContext.insert(transaction)
        
        do {
            try modelContext.save()
            showingSaveAlert = true
        } catch {
            print("Failed to save transaction: \(error)")
        }
    }
}

struct CategoryTag: View {
    let category: TransactionCategory
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: CTSpacing.xs) {
                Image(systemName: category.icon)
                    .font(.caption)
                Text(category.rawValue)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, CTSpacing.md)
            .padding(.vertical, CTSpacing.sm)
            .background(isSelected ? category.color : Color.secondaryBackground)
            .foregroundColor(isSelected ? .white : .textPrimary)
            .cornerRadius(CTCornerRadius.input)
            .overlay(
                RoundedRectangle(cornerRadius: CTCornerRadius.input)
                    .stroke(isSelected ? Color.clear : Color.borderColor, lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    AddTransactionView()
        .modelContainer(for: Transaction.self, inMemory: true)
}
