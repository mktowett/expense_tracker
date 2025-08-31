//
//  BalanceReconciler.swift
//  ExpenseLogger
//
//  Created by marvin towett on 31/08/2025.
//

import Foundation
import SwiftData

// MARK: - Balance Reconciler Service

class BalanceReconciler {
    
    // MARK: - Core Methods
    
    /// Inserts a transaction chronologically and recalculates affected balances
    static func insertTransactionChronologically(
        _ transaction: Transaction,
        into transactions: [Transaction],
        modelContext: ModelContext
    ) -> BalanceReconciliationResult {
        
        // Sort existing transactions by date
        let sortedTransactions = transactions.sorted { $0.date < $1.date }
        
        // Find insertion point
        let insertionIndex = findInsertionPoint(for: transaction, in: sortedTransactions)
        
        // Check if this affects existing balances
        let affectedTransactions = Array(sortedTransactions.dropFirst(insertionIndex))
        
        // Insert the new transaction
        modelContext.insert(transaction)
        
        // Recalculate balances for affected transactions
        if !affectedTransactions.isEmpty {
            recalculateBalances(starting: insertionIndex, transactions: sortedTransactions + [transaction], modelContext: modelContext)
        }
        
        return BalanceReconciliationResult(
            insertedTransaction: transaction,
            affectedCount: affectedTransactions.count,
            balanceConsistent: true
        )
    }
    
    /// Finds the correct chronological position for a new transaction
    private static func findInsertionPoint(for transaction: Transaction, in sortedTransactions: [Transaction]) -> Int {
        for (index, existingTransaction) in sortedTransactions.enumerated() {
            if transaction.date < existingTransaction.date {
                return index
            }
        }
        return sortedTransactions.count
    }
    
    /// Recalculates balances for transactions starting from a specific index
    private static func recalculateBalances(
        starting startIndex: Int,
        transactions: [Transaction],
        modelContext: ModelContext
    ) {
        let sortedTransactions = transactions.sorted { $0.date < $1.date }
        
        // Start from the insertion point
        for i in startIndex..<sortedTransactions.count {
            let currentTransaction = sortedTransactions[i]
            
            // Skip if this transaction doesn't have balance data
            guard currentTransaction.mpesaBalanceAfter != nil else { continue }
            
            // Calculate previous balance based on current balance and transaction
            if let balanceAfter = currentTransaction.mpesaBalanceAfter {
                let calculatedBalanceBefore = calculatePreviousBalance(
                    currentBalance: balanceAfter,
                    amount: currentTransaction.amount,
                    fees: currentTransaction.fees,
                    isIncome: currentTransaction.isIncome
                )
                
                currentTransaction.mpesaBalanceBefore = calculatedBalanceBefore
                currentTransaction.updatedAt = Date()
            }
            
            // Update next transaction's balance before if it exists
            if i + 1 < sortedTransactions.count {
                let nextTransaction = sortedTransactions[i + 1]
                if nextTransaction.mpesaBalanceBefore == nil {
                    nextTransaction.mpesaBalanceBefore = currentTransaction.mpesaBalanceAfter
                    nextTransaction.updatedAt = Date()
                }
            }
        }
        
        // Save changes
        do {
            try modelContext.save()
        } catch {
            print("Error saving balance recalculation: \(error)")
        }
    }
    
    /// Calculates the previous balance based on current balance and transaction details
    private static func calculatePreviousBalance(
        currentBalance: Decimal,
        amount: Decimal,
        fees: Decimal,
        isIncome: Bool
    ) -> Decimal {
        if isIncome {
            // For income: previousBalance = currentBalance - amount
            return currentBalance - amount
        } else {
            // For expenses: previousBalance = currentBalance + amount + fees
            return currentBalance + amount + fees
        }
    }
    
    // MARK: - Validation Methods
    
    /// Validates balance consistency across all transactions
    static func validateBalanceConsistency(for transactions: [Transaction]) -> [BalanceInconsistency] {
        var inconsistencies: [BalanceInconsistency] = []
        let sortedTransactions = transactions
            .filter { $0.mpesaBalanceAfter != nil }
            .sorted { $0.date < $1.date }
        
        for i in 0..<sortedTransactions.count - 1 {
            let current = sortedTransactions[i]
            let next = sortedTransactions[i + 1]
            
            guard let currentBalanceAfter = current.mpesaBalanceAfter,
                  let nextBalanceBefore = next.mpesaBalanceBefore else { continue }
            
            // Check if balances match (allowing for small rounding differences)
            let difference = abs(currentBalanceAfter - nextBalanceBefore)
            if difference > 0.01 {
                inconsistencies.append(
                    BalanceInconsistency(
                        transaction1: current,
                        transaction2: next,
                        expectedBalance: currentBalanceAfter,
                        actualBalance: nextBalanceBefore,
                        difference: difference
                    )
                )
            }
        }
        
        return inconsistencies
    }
    
    /// Detects potential missing transactions based on balance gaps
    static func detectMissingTransactions(for transactions: [Transaction]) -> [MissingTransactionAlert] {
        var alerts: [MissingTransactionAlert] = []
        let sortedTransactions = transactions
            .filter { $0.mpesaBalanceAfter != nil && $0.mpesaBalanceBefore != nil }
            .sorted { $0.date < $1.date }
        
        for i in 0..<sortedTransactions.count - 1 {
            let current = sortedTransactions[i]
            let next = sortedTransactions[i + 1]
            
            // Check for large time gaps (more than 24 hours)
            let timeGap = next.date.timeIntervalSince(current.date)
            if timeGap > 24 * 60 * 60 { // 24 hours
                
                // Check if balance change is unexpectedly large
                if let currentBalance = current.mpesaBalanceAfter,
                   let nextBalance = next.mpesaBalanceBefore {
                    let balanceChange = abs(nextBalance - currentBalance)
                    
                    // If balance changed by more than 1000 KES, flag as potential missing transaction
                    if balanceChange > 1000 {
                        alerts.append(
                            MissingTransactionAlert(
                                afterTransaction: current,
                                beforeTransaction: next,
                                timeGap: timeGap,
                                balanceGap: balanceChange
                            )
                        )
                    }
                }
            }
        }
        
        return alerts
    }
}

// MARK: - Result Types

struct BalanceReconciliationResult {
    let insertedTransaction: Transaction
    let affectedCount: Int
    let balanceConsistent: Bool
}

struct BalanceInconsistency {
    let transaction1: Transaction
    let transaction2: Transaction
    let expectedBalance: Decimal
    let actualBalance: Decimal
    let difference: Decimal
}

struct MissingTransactionAlert {
    let afterTransaction: Transaction
    let beforeTransaction: Transaction
    let timeGap: TimeInterval
    let balanceGap: Decimal
}
