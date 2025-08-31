//
//  AddTransactionView.swift
//  ExpenseLogger
//
//  Created by marvin towett on 30/08/2025.
//

import SwiftUI
import SwiftData

struct AddTransactionView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @State private var smsText = ""
    @State private var parsedTransaction: (amount: Double, merchant: String, type: String)?
    @State private var showingPreview = false
    @State private var parsingError: String?
    
    @State private var selectedCategory: Category?
    @State private var notes: String = ""
    @State private var showingSaveAlert: Bool = false
    
    @Query(sort: \Category.name) private var categories: [Category]
    
    private let smsConverter = SMSTransactionConverter()
    
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
                parseSMSText()
            }
            
            // Show parsing error if any
            if let error = parsingError {
                HStack(spacing: CTSpacing.xs) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.errorColor)
                        .font(.caption)
                    
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.errorColor)
                }
                .padding(.top, CTSpacing.xs)
            }
        }
        .claudeScreenPadding()
    }
    
    private func transactionPreviewSection(transaction: (amount: Double, merchant: String, type: String)) -> some View {
        VStack(alignment: .leading, spacing: CTSpacing.md) {
            CTTextStyle.headline("Transaction Preview")
            
            CTCard {
                VStack(alignment: .leading, spacing: CTSpacing.md) {
                    HStack {
                        VStack(alignment: .leading, spacing: CTSpacing.xs) {
                            CTTextStyle.caption("Amount")
                            Text("KES \(transaction.amount, specifier: "%.2f")")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(transaction.type == "income" ? .successColor : .textPrimary)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: CTSpacing.xs) {
                            CTTextStyle.caption("Type")
                            Text(transaction.type)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(transaction.type == "income" ? .successColor : .errorColor)
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
                    ForEach(categories, id: \.id) { category in
                        CategoryTag(
                            category: category,
                            isSelected: selectedCategory?.id == category.id
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
    
    private func parseSMSText() {
        guard !smsText.isEmpty else {
            showingPreview = false
            parsedTransaction = nil
            parsingError = nil
            return
        }
        
        let parser = SimpleSMSParser()
        let result = parser.parseMessage(smsText)
        
        switch result {
        case .success(let smsTransaction):
            parsedTransaction = (
                amount: Double(truncating: smsTransaction.amount as NSNumber),
                merchant: smsTransaction.merchant,
                type: smsTransaction.isIncome ? "income" : "expense"
            )
            parsingError = nil
            
            withAnimation(.easeInOut(duration: 0.3)) {
                showingPreview = true
            }
            
        case .failure(let error, let partialData):
            parsedTransaction = nil
            parsingError = error.localizedDescription
            
            withAnimation(.easeInOut(duration: 0.3)) {
                showingPreview = false
            }
            
            // Log partial data for debugging
            if let partialData = partialData {
                print("SMS Parsing failed with partial data: \(partialData)")
            }
        }
    }
    
    private func saveTransaction() {
        guard let parsed = parsedTransaction else { return }
        
        // Parse the SMS again to get full transaction details
        let parser = SimpleSMSParser()
        let result = parser.parseMessage(smsText)
        
        switch result {
        case .success(let smsTransaction):
            let transaction = smsConverter.convertToTransaction(smsTransaction, categories: categories)
            
            // Override with user selections
            if let selectedCategory = selectedCategory {
                transaction.category = selectedCategory
            }
            if !notes.isEmpty {
                transaction.notes = notes
            }
            
            do {
                modelContext.insert(transaction)
                try modelContext.save()
                showingSaveAlert = true
            } catch {
                parsingError = "Failed to save transaction: \(error.localizedDescription)"
            }
            
        case .failure(let error, _):
            print("Failed to save transaction: \(error)")
        }
    }
}

struct CategoryTag: View {
    let category: Category
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: CTSpacing.xs) {
                Image(systemName: category.icon)
                    .font(.caption)
                Text(category.name)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, CTSpacing.md)
            .padding(.vertical, CTSpacing.sm)
            .background(isSelected ? category.swiftUIColor : Color.secondaryBackground)
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
}
