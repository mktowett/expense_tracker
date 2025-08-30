//
//  Transaction.swift
//  ExpenseLogger
//
//  Created by marvin towett on 30/08/2025.
//

import Foundation
import SwiftData

enum TransactionType: String, CaseIterable, Codable {
    case expense = "Expense"
    case income = "Income"
}

@Model
final class Transaction {
    var id: UUID
    var amount: Double
    var merchant: String
    private var categoryRawValue: String
    var date: Date
    var notes: String
    private var typeRawValue: String
    var originalSMS: String?
    
    var category: TransactionCategory {
        get { TransactionCategory(rawValue: categoryRawValue) ?? .uncategorized }
        set { categoryRawValue = newValue.rawValue }
    }
    
    var type: TransactionType {
        get { TransactionType(rawValue: typeRawValue) ?? .expense }
        set { typeRawValue = newValue.rawValue }
    }
    
    init(
        id: UUID = UUID(),
        amount: Double,
        merchant: String,
        category: TransactionCategory = .uncategorized,
        date: Date = Date(),
        notes: String = "",
        type: TransactionType,
        originalSMS: String? = nil
    ) {
        self.id = id
        self.amount = amount
        self.merchant = merchant
        self.categoryRawValue = category.rawValue
        self.date = date
        self.notes = notes
        self.typeRawValue = type.rawValue
        self.originalSMS = originalSMS
    }
    
    var formattedAmount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "KES"
        formatter.currencySymbol = "KES "
        return formatter.string(from: NSNumber(value: amount)) ?? "KES 0.00"
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    var shortDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd"
        return formatter.string(from: date)
    }
    
    var timeOnly: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
