import Foundation
import SwiftData

// MARK: - SMS Transaction Converter

class SMSTransactionConverter {
    
    /// Converts an SMSTransaction to SwiftData Transaction
    func convertToTransaction(_ smsTransaction: SMSTransaction, categories: [Category]) -> Transaction {
        let category = mapToCategory(smsTransaction, categories: categories)
        
        let transaction = Transaction(
            amount: smsTransaction.amount,
            currency: smsTransaction.currency.rawValue,
            transactionType: mapToTransactionType(smsTransaction),
            merchant: smsTransaction.merchant,
            date: smsTransaction.date,
            reference: smsTransaction.reference,
            source: mapSMSProviderToSource(smsTransaction.source),
            rawMessage: smsTransaction.rawMessage,
            fees: smsTransaction.fees ?? 0,
            isIncome: smsTransaction.transactionType == .receive,
            notes: generateNotesFromSMS(smsTransaction),
            category: category,
            mpesaBalanceAfter: smsTransaction.mpesaBalanceAfter,
            mpesaBalanceBefore: smsTransaction.mpesaBalanceBefore
        )
        
        return transaction
    }
    
    /// Maps SMS transaction type to SwiftData TransactionType
    private func mapToTransactionType(_ smsTransaction: SMSTransaction) -> TransactionType {
        return smsTransaction.isIncome ? .income : .expense
    }
    
    /// Maps SMS service provider to SwiftData SMSSource
    private func mapSMSProviderToSource(_ provider: SMSServiceProvider) -> SMSSource {
        switch provider {
        case .mpesa:
            return .mpesa
        case .loop:
            return .loop
        case .imBank:
            return .imBank
        case .pesaLink:
            return .pesaLink
        case .unknown:
            return .mpesa // Default to mpesa for unknown providers
        }
    }
    
    /// Maps SMS transaction to appropriate category
    private func mapToCategory(_ smsTransaction: SMSTransaction, categories: [Category]) -> Category? {
        let merchant = smsTransaction.merchant.uppercased()
        let transactionType = smsTransaction.transactionType
        
        var categoryName: String
        
        // Map to your specific categories
        if merchant.contains("UBER") {
            categoryName = "Uber"
        } else if merchant.contains("NAIVAS") || merchant.contains("CARREFOUR") || merchant.contains("SUPERMARKET") {
            categoryName = "Groceries"
        } else if merchant.contains("KFC") || merchant.contains("JAVA") || merchant.contains("TAKEOUT") || merchant.contains("RESTAURANT") {
            categoryName = "Takeout"
        } else if merchant.contains("NETFLIX") || merchant.contains("SPOTIFY") || merchant.contains("SUBSCRIPTION") {
            categoryName = "Subscriptions"
        } else if merchant.contains("RENT") || merchant.contains("LANDLORD") {
            categoryName = "Rent"
        } else if merchant.contains("KENYA POWER") || merchant.contains("WATER") || merchant.contains("UTILITIES") {
            categoryName = "Utilities"
        } else if merchant.contains("CREDIT") || merchant.contains("BANK") || merchant.contains("LOAN") {
            categoryName = "Credit"
        } else if transactionType == .receive {
            // PesaLink and other income
            categoryName = "Credit" // Income goes to Credit for tracking
        } else {
            categoryName = "Shopping" // Default fallback
        }
        
        // Find matching category from provided categories
        return categories.first { $0.name == categoryName }
    }
    
    /// Generates notes from SMS transaction details
    private func generateNotesFromSMS(_ smsTransaction: SMSTransaction) -> String {
        var notes: [String] = []
        
        // Add transaction type
        notes.append("Type: \(smsTransaction.transactionType.rawValue)")
        
        // Add source
        notes.append("Source: \(smsTransaction.source.rawValue)")
        
        // Add fees if present
        if let fees = smsTransaction.fees, fees > 0 {
            notes.append("Fees: KES \(fees)")
        }
        
        // Add balance info if available
        if let balanceAfter = smsTransaction.mpesaBalanceAfter {
            notes.append("Balance: KES \(balanceAfter)")
        }
        
        return notes.joined(separator: " | ")
    }
}
