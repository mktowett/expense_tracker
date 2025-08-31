//
//  BalanceCalculator.swift
//  ExpenseLogger
//
//  Created by marvin towett on 31/08/2025.
//

import Foundation
import SwiftData

// MARK: - Balance Calculator Service

class BalanceCalculator {
    
    /// Calculates the current M-Pesa balance from the most recent transaction
    static func getCurrentMpesaBalance(from transactions: [Transaction]) -> Decimal? {
        // Get the most recent transaction with a balance
        let sortedTransactions = transactions
            .filter { $0.mpesaBalanceAfter != nil }
            .sorted { $0.date > $1.date }
        
        return sortedTransactions.first?.mpesaBalanceAfter
    }
    
    /// Calculates total fees paid this month
    static func getMonthlyFees(from transactions: [Transaction]) -> Decimal {
        let calendar = Calendar.current
        let now = Date()
        let startOfMonth = calendar.dateInterval(of: .month, for: now)?.start ?? now
        
        return transactions
            .filter { $0.date >= startOfMonth }
            .reduce(0) { $0 + $1.fees }
    }
    
    /// Calculates net cash flow (income - expenses - fees)
    static func getNetCashFlow(from transactions: [Transaction]) -> Decimal {
        let calendar = Calendar.current
        let now = Date()
        let startOfMonth = calendar.dateInterval(of: .month, for: now)?.start ?? now
        
        let monthlyTransactions = transactions.filter { $0.date >= startOfMonth }
        
        let income = monthlyTransactions
            .filter { $0.isIncome }
            .reduce(0) { $0 + $1.amount }
        
        let expenses = monthlyTransactions
            .filter { !$0.isIncome }
            .reduce(0) { $0 + $1.amount }
        
        let fees = monthlyTransactions
            .reduce(0) { $0 + $1.fees }
        
        return income - expenses - fees
    }
    
    /// Calculates balance trend (increase/decrease from previous month)
    static func getBalanceTrend(from transactions: [Transaction]) -> (amount: Decimal, isPositive: Bool)? {
        let calendar = Calendar.current
        let now = Date()
        
        guard let currentMonthStart = calendar.dateInterval(of: .month, for: now)?.start,
              let previousMonthStart = calendar.date(byAdding: .month, value: -1, to: currentMonthStart),
              let previousMonthEnd = calendar.date(byAdding: .day, value: -1, to: currentMonthStart) else {
            return nil
        }
        
        // Get balances from end of each month
        let currentMonthBalance = getCurrentMpesaBalance(from: transactions.filter { $0.date >= currentMonthStart }) ?? 0
        let previousMonthBalance = getCurrentMpesaBalance(from: transactions.filter { $0.date >= previousMonthStart && $0.date <= previousMonthEnd }) ?? 0
        
        let difference = currentMonthBalance - previousMonthBalance
        return (amount: abs(difference), isPositive: difference >= 0)
    }
    
    /// Validates balance consistency across transactions
    static func validateBalanceConsistency(for transactions: [Transaction]) -> [String] {
        var issues: [String] = []
        let sortedTransactions = transactions
            .filter { $0.mpesaBalanceAfter != nil && $0.mpesaBalanceBefore != nil }
            .sorted { $0.date < $1.date }
        
        for i in 0..<sortedTransactions.count - 1 {
            let current = sortedTransactions[i]
            let next = sortedTransactions[i + 1]
            
            // Check if current transaction's balance after matches next transaction's balance before
            if let currentBalanceAfter = current.mpesaBalanceAfter,
               let nextBalanceBefore = next.mpesaBalanceBefore,
               abs(currentBalanceAfter - nextBalanceBefore) > 0.01 { // Allow for small rounding differences
                issues.append("Balance mismatch between \(current.merchant) and \(next.merchant)")
            }
        }
        
        return issues
    }
    
    /// Fills in missing balance data using chronological calculation
    static func fillMissingBalances(for transactions: inout [Transaction]) {
        let sortedTransactions = transactions.sorted { $0.date < $1.date }
        
        for i in 0..<sortedTransactions.count {
            let transaction = sortedTransactions[i]
            
            // If we have balance after but not before, calculate it
            if transaction.mpesaBalanceAfter != nil && transaction.mpesaBalanceBefore == nil {
                let balanceAfter = transaction.mpesaBalanceAfter!
                let amount = transaction.amount
                let fees = transaction.fees
                
                if transaction.isIncome {
                    transaction.mpesaBalanceBefore = balanceAfter - amount
                } else {
                    transaction.mpesaBalanceBefore = balanceAfter + amount + fees
                }
            }
            
            // If we have balance before but not after, calculate it
            if transaction.mpesaBalanceBefore != nil && transaction.mpesaBalanceAfter == nil {
                let balanceBefore = transaction.mpesaBalanceBefore!
                let amount = transaction.amount
                let fees = transaction.fees
                
                if transaction.isIncome {
                    transaction.mpesaBalanceAfter = balanceBefore + amount
                } else {
                    transaction.mpesaBalanceAfter = balanceBefore - amount - fees
                }
            }
        }
    }
}
