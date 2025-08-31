import Foundation

// MARK: - SMS Transaction Models

enum SMSTransactionType: String, CaseIterable {
    case send = "SEND"
    case receive = "RECEIVE"
    case payBill = "PAY_BILL"
    case cardPayment = "CARD_PAYMENT"
    case bankTransfer = "BANK_TRANSFER"
    case unknown = "UNKNOWN"
    
    var isIncome: Bool {
        return self == .receive
    }
}

enum SMSServiceProvider: String, CaseIterable {
    case mpesa = "MPESA"
    case loop = "LOOP"
    case imBank = "I&M_BANK"
    case pesaLink = "PESALINK"
    case unknown = "UNKNOWN"
}

enum SMSCurrency: String, CaseIterable {
    case kes = "KES"
    case usd = "USD"
    case eur = "EUR"
    case gbp = "GBP"
    case unknown = "UNKNOWN"
}

struct SMSTransaction {
    let id: String
    let amount: Decimal
    let currency: SMSCurrency
    let transactionType: SMSTransactionType
    let merchant: String
    let date: Date
    let reference: String
    let source: SMSServiceProvider
    let rawMessage: String
    let fees: Decimal?
    let accountNumber: String?
    let phoneNumber: String?
    let mpesaBalanceAfter: Decimal?
    let mpesaBalanceBefore: Decimal?
    
    var isIncome: Bool {
        return transactionType.isIncome
    }
    
    init(
        amount: Decimal,
        currency: SMSCurrency = .kes,
        transactionType: SMSTransactionType,
        merchant: String,
        date: Date,
        reference: String,
        source: SMSServiceProvider,
        rawMessage: String,
        fees: Decimal? = nil,
        accountNumber: String? = nil,
        phoneNumber: String? = nil,
        mpesaBalanceAfter: Decimal? = nil,
        mpesaBalanceBefore: Decimal? = nil
    ) {
        self.id = UUID().uuidString
        self.amount = amount
        self.currency = currency
        self.transactionType = transactionType
        self.merchant = merchant
        self.date = date
        self.reference = reference
        self.source = source
        self.rawMessage = rawMessage
        self.fees = fees
        self.accountNumber = accountNumber
        self.phoneNumber = phoneNumber
        self.mpesaBalanceAfter = mpesaBalanceAfter
        self.mpesaBalanceBefore = mpesaBalanceBefore
    }
}

// MARK: - SMS Parsing Error

enum SMSParsingError: Error, LocalizedError {
    case unrecognizedFormat
    case missingAmount
    case missingMerchant
    case missingDate
    case invalidAmount
    case invalidDate
    case unsupportedProvider
    
    var errorDescription: String? {
        switch self {
        case .unrecognizedFormat:
            return "SMS format not recognized"
        case .missingAmount:
            return "Could not extract transaction amount"
        case .missingMerchant:
            return "Could not identify merchant or recipient"
        case .missingDate:
            return "Could not extract transaction date"
        case .invalidAmount:
            return "Invalid amount format"
        case .invalidDate:
            return "Invalid date format"
        case .unsupportedProvider:
            return "Service provider not supported"
        }
    }
}

// MARK: - SMS Parsing Result

enum SMSParsingResult {
    case success(SMSTransaction)
    case failure(SMSParsingError, partialData: [String: Any]?)
    
    var transaction: SMSTransaction? {
        if case .success(let transaction) = self {
            return transaction
        }
        return nil
    }
    
    var error: SMSParsingError? {
        if case .failure(let error, _) = self {
            return error
        }
        return nil
    }
}
