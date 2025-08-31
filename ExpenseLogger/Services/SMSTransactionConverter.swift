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
            category: category
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
        
        switch transactionType {
        case .cardPayment:
            if merchant.contains("OPENAI") || merchant.contains("CHATGPT") {
                categoryName = "Other"
            } else if merchant.contains("RESTAURANT") || merchant.contains("CAFE") || merchant.contains("FOOD") {
                categoryName = "Food & Dining"
            } else if merchant.contains("FUEL") || merchant.contains("PETROL") || merchant.contains("GAS") {
                categoryName = "Transportation"
            } else {
                categoryName = "Shopping"
            }
            
        case .payBill:
            if merchant.contains("LIQUOR") || merchant.contains("BAR") || merchant.contains("CLUB") {
                categoryName = "Entertainment"
            } else if merchant.contains("SUPERMARKET") || merchant.contains("STORE") || merchant.contains("SHOP") {
                categoryName = "Shopping"
            } else if merchant.contains("HOSPITAL") || merchant.contains("CLINIC") || merchant.contains("PHARMACY") {
                categoryName = "Healthcare"
            } else {
                categoryName = "Bills & Utilities"
            }
            
        case .send:
            if merchant.contains("RENT") || merchant.contains("LANDLORD") {
                categoryName = "Bills & Utilities"
            } else if merchant.contains("SCHOOL") || merchant.contains("UNIVERSITY") || merchant.contains("EDUCATION") {
                categoryName = "Education"
            } else {
                categoryName = "Other"
            }
            
        case .receive:
            categoryName = "Other"
            
        case .bankTransfer:
            categoryName = "Other"
            
        case .unknown:
            categoryName = "Other"
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
        
        return notes.joined(separator: " | ")
    }
}
