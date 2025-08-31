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
        
        // Extract transaction cost if present
        let fees = extractTransactionCost(cleanMessage)
        
        // Extract reference
        let reference = extractReference(cleanMessage) ?? "SMS-\(Int(Date().timeIntervalSince1970))"
        
        // Create transaction
        let transaction = SMSTransaction(
            amount: amount,
            currency: .kes, // Default to KES for simplicity
            transactionType: transactionType,
            merchant: "SMS Transaction",
            date: Date(),
            reference: reference,
            source: .mpesa,
            rawMessage: cleanMessage,
            fees: fees
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
}
