//
//  Transaction.swift
//  ExpenseLogger
//
//  Created by marvin towett on 31/08/2025.
//

import Foundation
import SwiftData

@Model
final class Transaction {
    var id: UUID
    var amount: Decimal
    var currency: String
    var transactionType: TransactionType
    var merchant: String
    var date: Date
    var reference: String?
    var source: SMSSource?
    var rawMessage: String?
    var fees: Decimal
    var isIncome: Bool
    var notes: String?
    var createdAt: Date
    var updatedAt: Date
    
    // Balance tracking fields
    var mpesaBalanceAfter: Decimal?
    var mpesaBalanceBefore: Decimal?
    var totalCost: Decimal {
        return isIncome ? amount : amount + fees
    }
    
    // Relationship
    var category: Category?
    
    init(
        amount: Decimal,
        currency: String = "KES",
        transactionType: TransactionType,
        merchant: String,
        date: Date,
        reference: String? = nil,
        source: SMSSource? = nil,
        rawMessage: String? = nil,
        fees: Decimal = 0.0,
        isIncome: Bool = false,
        notes: String? = nil,
        category: Category? = nil,
        mpesaBalanceAfter: Decimal? = nil,
        mpesaBalanceBefore: Decimal? = nil
    ) {
        self.id = UUID()
        self.amount = amount
        self.currency = currency
        self.transactionType = transactionType
        self.merchant = merchant
        self.date = date
        self.reference = reference
        self.source = source
        self.rawMessage = rawMessage
        self.fees = fees
        self.isIncome = isIncome
        self.notes = notes
        self.category = category
        self.mpesaBalanceAfter = mpesaBalanceAfter
        self.mpesaBalanceBefore = mpesaBalanceBefore
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}

// MARK: - Enums
enum TransactionType: String, Codable, CaseIterable {
    case income = "income"
    case expense = "expense"
}

enum SMSSource: String, Codable, CaseIterable {
    case mpesa = "mpesa"
    case loop = "loop"
    case imBank = "imBank"
    case pesaLink = "pesaLink"
}
