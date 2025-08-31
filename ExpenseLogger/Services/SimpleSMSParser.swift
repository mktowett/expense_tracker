import Foundation

// MARK: - Simplified SMS Parser

class SimpleSMSParser {
    
    // MARK: - Simple Patterns
    
    private struct Patterns {
        // Amount patterns - matches Ksh1,200.00, KES 500, USD.23.20
        static let amount = #"(?:Ksh|KES|USD\.?)\s*([0-9,]+\.?[0-9]*)"#
        
        // Transaction type patterns
        static let sent = #"sent to"#
        static let paid = #"paid to"#
        static let received = #"received"#
        
        // Transaction cost pattern
        static let cost = #"(?:Transaction cost|cost)[,\s]*(?:Ksh|KES)\s*([0-9,]+\.?[0-9]*)"#
        
        // Balance patterns - matches various M-Pesa balance formats
        static let balance = #"(?:M-PESA balance|Available balance|balance)[:\s]*(?:is\s*)?(?:Ksh|KES)\s*([0-9,-]+\.?[0-9]*)"#
        
        // Merchant extraction patterns
        static let merchantPaid = #"(?:paid to|sent to)\s+([A-Z0-9\s&.-]+?)(?:\s+on|\s+for|\.|$)"#
        static let merchantReceived = #"from\s+([A-Z0-9\s&.-]+?)(?:\s+on|\s+for|\.|$)"#
        
        // Reference pattern
        static let reference = #"([A-Z0-9]{8,12})\s+Confirmed"#
    }
    
    // MARK: - Main Parsing Method
    
    func parseMessage(_ message: String) -> SMSParsingResult {
        let cleanMessage = message.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Extract amount
        guard let amount = extractAmount(cleanMessage) else {
            return .failure(.missingAmount, partialData: ["rawMessage": cleanMessage])
        }
        
        // Determine transaction type
        let transactionType = determineTransactionType(cleanMessage)
        
        // Extract merchant
        let merchant = extractMerchant(cleanMessage, transactionType: transactionType)
        
        // Extract transaction cost/fees if present
        let fees = extractTransactionCost(cleanMessage)
        
        // Extract M-Pesa balance
        let mpesaBalance = extractMpesaBalance(cleanMessage)
        
        // Calculate previous balance if we have current balance
        let previousBalance = calculatePreviousBalance(
            currentBalance: mpesaBalance,
            amount: amount,
            fees: fees ?? 0,
            isIncome: transactionType.isIncome
        )
        
        // Extract reference
        let reference = extractReference(cleanMessage) ?? "SMS-\(Int(Date().timeIntervalSince1970))"
        
        // Determine service provider
        let source = determineServiceProvider(cleanMessage)
        
        // Create transaction
        let transaction = SMSTransaction(
            amount: amount,
            currency: .kes,
            transactionType: transactionType,
            merchant: merchant,
            date: Date(),
            reference: reference,
            source: source,
            rawMessage: cleanMessage,
            fees: fees,
            mpesaBalanceAfter: mpesaBalance,
            mpesaBalanceBefore: previousBalance
        )
        
        return .success(transaction)
    }
    
    // MARK: - Helper Methods
    
    private func extractAmount(_ message: String) -> Decimal? {
        guard let regex = try? NSRegularExpression(pattern: Patterns.amount, options: [.caseInsensitive]) else {
            return nil
        }
        
        let range = NSRange(message.startIndex..., in: message)
        guard let match = regex.firstMatch(in: message, options: [], range: range),
              match.numberOfRanges > 1 else {
            return nil
        }
        
        let matchRange = match.range(at: 1)
        guard matchRange.location != NSNotFound,
              let range = Range(matchRange, in: message) else {
            return nil
        }
        
        let amountString = String(message[range]).replacingOccurrences(of: ",", with: "")
        return Decimal(string: amountString)
    }
    
    private func determineTransactionType(_ message: String) -> SMSTransactionType {
        let upperMessage = message.uppercased()
        
        if upperMessage.contains("SENT TO") {
            return .send
        } else if upperMessage.contains("PAID TO") {
            return .payBill
        } else if upperMessage.contains("RECEIVED") {
            return .receive
        }
        
        return .unknown
    }
    
    private func extractTransactionCost(_ message: String) -> Decimal? {
        guard let regex = try? NSRegularExpression(pattern: Patterns.cost, options: [.caseInsensitive]) else {
            return nil
        }
        
        let range = NSRange(message.startIndex..., in: message)
        guard let match = regex.firstMatch(in: message, options: [], range: range),
              match.numberOfRanges > 1 else {
            return nil
        }
        
        let matchRange = match.range(at: 1)
        guard matchRange.location != NSNotFound,
              let range = Range(matchRange, in: message) else {
            return nil
        }
        
        let costString = String(message[range]).replacingOccurrences(of: ",", with: "")
        return Decimal(string: costString)
    }
    
    private func extractReference(_ message: String) -> String? {
        guard let regex = try? NSRegularExpression(pattern: Patterns.reference, options: [.caseInsensitive]) else {
            return nil
        }
        
        let range = NSRange(message.startIndex..., in: message)
        guard let match = regex.firstMatch(in: message, options: [], range: range),
              match.numberOfRanges > 1 else {
            return nil
        }
        
        let matchRange = match.range(at: 1)
        guard matchRange.location != NSNotFound,
              let range = Range(matchRange, in: message) else {
            return nil
        }
        
        return String(message[range])
    }
    
    private func extractMpesaBalance(_ message: String) -> Decimal? {
        guard let regex = try? NSRegularExpression(pattern: Patterns.balance, options: [.caseInsensitive]) else {
            return nil
        }
        
        let range = NSRange(message.startIndex..., in: message)
        guard let match = regex.firstMatch(in: message, options: [], range: range),
              match.numberOfRanges > 1 else {
            return nil
        }
        
        let matchRange = match.range(at: 1)
        guard matchRange.location != NSNotFound,
              let range = Range(matchRange, in: message) else {
            return nil
        }
        
        let balanceString = String(message[range])
            .replacingOccurrences(of: ",", with: "")
            .replacingOccurrences(of: "-", with: "-") // Handle negative balances
        return Decimal(string: balanceString)
    }
    
    private func extractMerchant(_ message: String, transactionType: SMSTransactionType) -> String {
        let pattern = transactionType.isIncome ? Patterns.merchantReceived : Patterns.merchantPaid
        
        guard let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive]) else {
            return "Unknown Merchant"
        }
        
        let range = NSRange(message.startIndex..., in: message)
        guard let match = regex.firstMatch(in: message, options: [], range: range),
              match.numberOfRanges > 1 else {
            return "Unknown Merchant"
        }
        
        let matchRange = match.range(at: 1)
        guard matchRange.location != NSNotFound,
              let range = Range(matchRange, in: message) else {
            return "Unknown Merchant"
        }
        
        return String(message[range]).trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    private func determineServiceProvider(_ message: String) -> SMSServiceProvider {
        let upperMessage = message.uppercased()
        
        if upperMessage.contains("M-PESA") || upperMessage.contains("MPESA") {
            return .mpesa
        } else if upperMessage.contains("PESALINK") {
            return .pesaLink
        } else if upperMessage.contains("LOOP") {
            return .loop
        } else if upperMessage.contains("I&M") {
            return .imBank
        }
        
        return .mpesa // Default to M-Pesa for Kenyan context
    }
    
    private func calculatePreviousBalance(
        currentBalance: Decimal?,
        amount: Decimal,
        fees: Decimal,
        isIncome: Bool
    ) -> Decimal? {
        guard let currentBalance = currentBalance else { return nil }
        
        if isIncome {
            // For income: previousBalance = currentBalance - amount
            return currentBalance - amount
        } else {
            // For expenses: previousBalance = currentBalance + amount + fees
            return currentBalance + amount + fees
        }
    }
}
