//
//  MockData.swift
//  ExpenseLogger
//
//  Created by marvin towett on 30/08/2025.
//

import Foundation

class MockData {
    static let shared = MockData()
    
    private init() {}
    
    // MARK: - Sample SMS Messages for Testing
    static let sampleSMSMessages = [
        "Confirmed. Ksh1,200.00 paid to NAIVAS SUPERMARKET on 30/08/25 at 2:15 PM. M-PESA balance is Ksh15,450.00",
        "You have received Ksh500.00 from JOHN DOE on 30/08/25 at 1:30 PM. M-PESA balance is Ksh16,650.00",
        "Bill payment of Ksh2,500.00 to KENYA POWER on 29/08/25 at 10:45 AM. M-PESA balance is Ksh14,150.00",
        "Confirmed. KES 850.00 paid to UBER KENYA on 29/08/25 at 8:20 PM. Available balance: KES 13,300.00",
        "You have paid KES 3,200.00 to JAVA HOUSE on 28/08/25 at 12:30 PM. M-PESA balance: KES 10,100.00"
    ]
    
    // MARK: - Mock Transactions
    static func createMockTransactions() -> [Transaction] {
        let calendar = Calendar.current
        let now = Date()
        
        return [
            Transaction(
                amount: 1200.00,
                merchant: "NAIVAS SUPERMARKET",
                category: .food,
                date: calendar.date(byAdding: .hour, value: -2, to: now) ?? now,
                notes: "Weekly groceries",
                type: .expense,
                originalSMS: sampleSMSMessages[0]
            ),
            Transaction(
                amount: 500.00,
                merchant: "JOHN DOE",
                category: .other,
                date: calendar.date(byAdding: .hour, value: -3, to: now) ?? now,
                notes: "Payment received",
                type: .income,
                originalSMS: sampleSMSMessages[1]
            ),
            Transaction(
                amount: 2500.00,
                merchant: "KENYA POWER",
                category: .bills,
                date: calendar.date(byAdding: .day, value: -1, to: now) ?? now,
                notes: "Electricity bill",
                type: .expense,
                originalSMS: sampleSMSMessages[2]
            ),
            Transaction(
                amount: 850.00,
                merchant: "UBER KENYA",
                category: .transport,
                date: calendar.date(byAdding: .day, value: -1, to: now) ?? now,
                notes: "Ride to office",
                type: .expense,
                originalSMS: sampleSMSMessages[3]
            ),
            Transaction(
                amount: 3200.00,
                merchant: "JAVA HOUSE",
                category: .food,
                date: calendar.date(byAdding: .day, value: -2, to: now) ?? now,
                notes: "Lunch meeting",
                type: .expense,
                originalSMS: sampleSMSMessages[4]
            ),
            Transaction(
                amount: 750.00,
                merchant: "NAKUMATT",
                category: .shopping,
                date: calendar.date(byAdding: .day, value: -3, to: now) ?? now,
                notes: "Household items",
                type: .expense
            ),
            Transaction(
                amount: 1500.00,
                merchant: "AGA KHAN HOSPITAL",
                category: .healthcare,
                date: calendar.date(byAdding: .day, value: -5, to: now) ?? now,
                notes: "Medical checkup",
                type: .expense
            ),
            Transaction(
                amount: 2000.00,
                merchant: "CENTURY CINEMAX",
                category: .entertainment,
                date: calendar.date(byAdding: .day, value: -7, to: now) ?? now,
                notes: "Movie tickets",
                type: .expense
            )
        ]
    }
    
    // MARK: - SMS Parsing Logic
    static func parseTransactionFromSMS(_ smsText: String) -> (amount: Double, merchant: String, type: TransactionType)? {
        let text = smsText.uppercased()
        
        // Patterns for amount detection
        let amountPatterns = [
            #"KSH\s*([0-9,]+\.?[0-9]*)"#,
            #"KES\s*([0-9,]+\.?[0-9]*)"#,
            #"([0-9,]+\.?[0-9]*)\s*PAID"#
        ]
        
        var detectedAmount: Double?
        
        for pattern in amountPatterns {
            if let regex = try? NSRegularExpression(pattern: pattern, options: []),
               let match = regex.firstMatch(in: text, options: [], range: NSRange(text.startIndex..., in: text)) {
                if let range = Range(match.range(at: 1), in: text) {
                    let amountString = String(text[range]).replacingOccurrences(of: ",", with: "")
                    detectedAmount = Double(amountString)
                    break
                }
            }
        }
        
        guard let amount = detectedAmount else { return nil }
        
        // Determine transaction type
        let isIncome = text.contains("RECEIVED") || text.contains("RECEIVED FROM")
        let type: TransactionType = isIncome ? .income : .expense
        
        // Extract merchant name
        var merchant = "Unknown Merchant"
        
        if isIncome {
            // For income, look for "FROM [NAME]"
            if let regex = try? NSRegularExpression(pattern: #"FROM\s+([A-Z\s]+)"#, options: []),
               let match = regex.firstMatch(in: text, options: [], range: NSRange(text.startIndex..., in: text)) {
                if let range = Range(match.range(at: 1), in: text) {
                    merchant = String(text[range]).trimmingCharacters(in: .whitespaces)
                }
            }
        } else {
            // For expenses, look for "TO [MERCHANT]"
            if let regex = try? NSRegularExpression(pattern: #"TO\s+([A-Z\s]+)"#, options: []),
               let match = regex.firstMatch(in: text, options: [], range: NSRange(text.startIndex..., in: text)) {
                if let range = Range(match.range(at: 1), in: text) {
                    merchant = String(text[range]).trimmingCharacters(in: .whitespaces)
                }
            } else if let regex = try? NSRegularExpression(pattern: #"PAID TO\s+([A-Z\s]+)"#, options: []),
                      let match = regex.firstMatch(in: text, options: [], range: NSRange(text.startIndex..., in: text)) {
                if let range = Range(match.range(at: 1), in: text) {
                    merchant = String(text[range]).trimmingCharacters(in: .whitespaces)
                }
            }
        }
        
        // Clean up merchant name
        merchant = merchant.replacingOccurrences(of: " ON ", with: "")
            .replacingOccurrences(of: " AT ", with: "")
            .components(separatedBy: " ")[0...2].joined(separator: " ")
            .trimmingCharacters(in: .whitespaces)
        
        return (amount: amount, merchant: merchant, type: type)
    }
}
