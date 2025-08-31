import XCTest
@testable import ExpenseLogger

class SMSParserTests: XCTestCase {
    
    var parser: SimpleSMSParser!
    
    override func setUp() {
        super.setUp()
        parser = SimpleSMSParser()
    }
    
    override func tearDown() {
        parser = nil
        super.tearDown()
    }
    
    // MARK: - M-PESA Send Money Tests
    
    func testMpesaSendMoneyParsing() {
        let message = "THU3LTRGTL Confirmed. Ksh2,000.00 sent to PENUEL NTHENYA 0748322517 on 30/8/25 at 1:47 PM. New M-PESA balance is Ksh98,966.58. Transaction cost, Ksh33.00..."
        
        let result = parser.parseMessage(message)
        
        switch result {
        case .success(let transaction):
        
        XCTAssertEqual(transaction.amount, Decimal(2000.00))
        XCTAssertEqual(transaction.currency, .kes)
        XCTAssertEqual(transaction.transactionType, .send)
        XCTAssertEqual(transaction.merchant, "PENUEL NTHENYA")
        XCTAssertEqual(transaction.reference, "THU3LTRGTL")
        XCTAssertEqual(transaction.source, .mpesa)
        XCTAssertEqual(transaction.fees, Decimal(33.00))
        XCTAssertEqual(transaction.phoneNumber, "0748322517")
            XCTAssertFalse(transaction.isIncome)
        case .failure(let error, _):
            XCTFail("Parsing failed with error: \(error)")
        }
    }
    
    func testMpesaPayBillParsing() {
        let message = "THU2P01TU2 Confirmed. Ksh870.00 paid to TAMASHA LIQUOR STORE. on 30/8/25 at 10:58 PM.New M-PESA balance is Ksh97,997.58. Transaction cost, Ksh0.00..."
        
        let result = parser.parseMessage(message)
        
        switch result {
        case .success(let transaction):
        
        XCTAssertEqual(transaction.amount, Decimal(870.00))
        XCTAssertEqual(transaction.currency, .kes)
        XCTAssertEqual(transaction.transactionType, .payBill)
        XCTAssertEqual(transaction.merchant, "TAMASHA LIQUOR STORE")
        XCTAssertEqual(transaction.reference, "THU2P01TU2")
        XCTAssertEqual(transaction.source, .mpesa)
        XCTAssertEqual(transaction.fees, Decimal(0.00))
            XCTAssertFalse(transaction.isIncome)
        case .failure(let error, _):
            XCTFail("Parsing failed with error: \(error)")
        }
    }
    
    func testMpesaReceiveMoneyParsing() {
        let message = "THT1G29V03 Confirmed. You have received Ksh120,000.00 from IM BANK LIMITED- APP on 29/8/25 at 12:06 PM. New M-PESA balance is Ksh214,699.58..."
        
        let result = parser.parseMessage(message)
        
        switch result {
        case .success(let transaction):
        
        XCTAssertEqual(transaction.amount, Decimal(120000.00))
        XCTAssertEqual(transaction.currency, .kes)
        XCTAssertEqual(transaction.transactionType, .receive)
        XCTAssertEqual(transaction.merchant, "IM BANK LIMITED- APP")
        XCTAssertEqual(transaction.reference, "THT1G29V03")
        XCTAssertEqual(transaction.source, .mpesa)
        XCTAssertTrue(transaction.isIncome)
        case .failure(let error, _):
            XCTFail("Parsing failed with error: \(error)")
        }
    }
    
    // MARK: - LOOP Bank Tests
    
    func testLoopBankCardTransactionParsing() {
        let message = "MARVIN, Online transaction of USD.23.20 has been approved on your card ending **3732 at OPENAI *CHATGPT SUBSCR on 30/08/2025 11:58:08..."
        
        let result = parser.parseMessage(message)
        
        switch result {
        case .success(let transaction):
        
        XCTAssertEqual(transaction.amount, Decimal(23.20))
        XCTAssertEqual(transaction.currency, .usd)
        XCTAssertEqual(transaction.transactionType, .cardPayment)
        XCTAssertEqual(transaction.merchant, "OPENAI *CHATGPT SUBSCR")
        XCTAssertEqual(transaction.source, .loop)
            XCTAssertFalse(transaction.isIncome)
        case .failure(let error, _):
            XCTFail("Parsing failed with error: \(error)")
        }
    }
    
    // MARK: - I&M Bank Tests
    
    func testIMBankTransferParsing() {
        let message = "Bank to M-PESA transfer of KES 4,750.00 to 254704701916 - ALEX MWANGI WANJOHI successfully processed. Transaction Ref ID: 631215603436..."
        
        let result = parser.parseMessage(message)
        
        switch result {
        case .success(let transaction):
        
        XCTAssertEqual(transaction.amount, Decimal(4750.00))
        XCTAssertEqual(transaction.currency, .kes)
        XCTAssertEqual(transaction.transactionType, .bankTransfer)
        XCTAssertEqual(transaction.merchant, "ALEX MWANGI WANJOHI")
        XCTAssertEqual(transaction.reference, "631215603436")
        XCTAssertEqual(transaction.source, .imBank)
        XCTAssertEqual(transaction.phoneNumber, "254704701916")
            XCTAssertFalse(transaction.isIncome)
        case .failure(let error, _):
            XCTFail("Parsing failed with error: \(error)")
        }
    }
    
    // MARK: - PesaLink Tests
    
    func testPesaLinkReceiveParsing() {
        let message = "KES 175,000 received from NATHAN CLAIRE (K) LI into A/C ****3450. Pesalink is available 24/7..."
        
        let result = parser.parseMessage(message)
        
        switch result {
        case .success(let transaction):
        
        XCTAssertEqual(transaction.amount, Decimal(175000))
        XCTAssertEqual(transaction.currency, .kes)
        XCTAssertEqual(transaction.transactionType, .receive)
        XCTAssertEqual(transaction.merchant, "NATHAN CLAIRE (K) LI")
        XCTAssertEqual(transaction.source, .pesaLink)
        XCTAssertEqual(transaction.accountNumber, "3450")
        XCTAssertTrue(transaction.isIncome)
        case .failure(let error, _):
            XCTFail("Parsing failed with error: \(error)")
        }
    }
    
    // MARK: - Edge Cases and Error Handling Tests
    
    func testUnrecognizedMessageFormat() {
        let message = "This is not a valid SMS transaction message"
        
        let result = parser.parseMessage(message)
        
        XCTAssertNil(result.transaction)
        XCTAssertEqual(result.error, .unrecognizedFormat)
    }
    
    func testEmptyMessage() {
        let message = ""
        
        let result = parser.parseMessage(message)
        
        XCTAssertNil(result.transaction)
        XCTAssertEqual(result.error, .unrecognizedFormat)
    }
    
    func testMalformedMpesaMessage() {
        let message = "Confirmed. sent to JOHN DOE on 30/8/25 at 1:47 PM." // Missing amount and reference
        
        let result = parser.parseMessage(message)
        
        XCTAssertNil(result.transaction)
        XCTAssertNotNil(result.error)
    }
    
    // MARK: - Amount Parsing Tests
    
    func testVariousAmountFormats() {
        let testCases = [
            ("Ksh1,000.00", Decimal(1000.00)),
            ("KES 500.50", Decimal(500.50)),
            ("USD.25.99", Decimal(25.99)),
            ("Ksh10", Decimal(10)),
            ("KES 1,234,567.89", Decimal(1234567.89))
        ]
        
        for (amountString, expectedAmount) in testCases {
            let message = "THU3LTRGTL Confirmed. \(amountString) sent to JOHN DOE 0712345678 on 30/8/25 at 1:47 PM. New M-PESA balance is Ksh98,966.58."
            
            let result = parser.parseMessage(message)
            
            XCTAssertNotNil(result.transaction, "Failed to parse amount: \(amountString)")
            XCTAssertEqual(result.transaction?.amount, expectedAmount, "Incorrect amount parsed for: \(amountString)")
        }
    }
    
    // MARK: - Date Parsing Tests
    
    func testMpesaDateParsing() {
        let message = "THU3LTRGTL Confirmed. Ksh1,000.00 sent to JOHN DOE 0712345678 on 30/8/25 at 1:47 PM. New M-PESA balance is Ksh98,966.58."
        
        let result = parser.parseMessage(message)
        
        switch result {
        case .success(let transaction):
        
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.day, .month, .year, .hour, .minute], from: transaction.date)
        
        XCTAssertEqual(dateComponents.day, 30)
        XCTAssertEqual(dateComponents.month, 8)
        XCTAssertEqual(dateComponents.year, 2025)
        XCTAssertEqual(dateComponents.hour, 13) // 1:47 PM = 13:47
        XCTAssertEqual(dateComponents.minute, 47)
        case .failure(let error, _):
            XCTFail("Parsing failed with error: \(error)")
        }
    }
    
    // MARK: - Merchant Name Cleaning Tests
    
    func testMerchantNameCleaning() {
        let testCases = [
            ("  JOHN DOE  ", "JOHN DOE"),
            ("TAMASHA LIQUOR STORE.", "TAMASHA LIQUOR STORE"),
            ("IM BANK LIMITED- APP", "IM BANK LIMITED- APP"),
            ("OPENAI *CHATGPT SUBSCR", "OPENAI *CHATGPT SUBSCR")
        ]
        
        for (input, expected) in testCases {
            let message = "THU3LTRGTL Confirmed. Ksh1,000.00 sent to \(input) 0712345678 on 30/8/25 at 1:47 PM. New M-PESA balance is Ksh98,966.58."
            
            let result = parser.parseMessage(message)
            
            switch result {
            case .success(let transaction):
                XCTAssertEqual(transaction.merchant, expected, "Merchant name not cleaned properly: \(input)")
            case .failure(let error, _):
                XCTFail("Parsing failed with error: \(error)")
            }
        }
    }
    
    // MARK: - Performance Tests
    
    func testParsingPerformance() {
        let message = "THU3LTRGTL Confirmed. Ksh2,000.00 sent to PENUEL NTHENYA 0748322517 on 30/8/25 at 1:47 PM. New M-PESA balance is Ksh98,966.58. Transaction cost, Ksh33.00..."
        
        measure {
            for _ in 0..<1000 {
                _ = parser.parseMessage(message)
            }
        }
    }
    
    // MARK: - Integration Tests
    
    func testAllSampleMessages() {
        let sampleMessages = [
            "THU3LTRGTL Confirmed. Ksh2,000.00 sent to PENUEL NTHENYA 0748322517 on 30/8/25 at 1:47 PM. New M-PESA balance is Ksh98,966.58. Transaction cost, Ksh33.00...",
            "THU2P01TU2 Confirmed. Ksh870.00 paid to TAMASHA LIQUOR STORE. on 30/8/25 at 10:58 PM.New M-PESA balance is Ksh97,997.58. Transaction cost, Ksh0.00...",
            "THT1G29V03 Confirmed. You have received Ksh120,000.00 from IM BANK LIMITED- APP on 29/8/25 at 12:06 PM. New M-PESA balance is Ksh214,699.58...",
            "MARVIN, Online transaction of USD.23.20 has been approved on your card ending **3732 at OPENAI *CHATGPT SUBSCR on 30/08/2025 11:58:08...",
            "Bank to M-PESA transfer of KES 4,750.00 to 254704701916 - ALEX MWANGI WANJOHI successfully processed. Transaction Ref ID: 631215603436...",
            "KES 175,000 received from NATHAN CLAIRE (K) LI into A/C ****3450. Pesalink is available 24/7..."
        ]
        
        var successCount = 0
        
        for message in sampleMessages {
            let result = parser.parseMessage(message)
            switch result {
            case .success(_):
                successCount += 1
            case .failure(_, _):
                break
            }
        }
        
        // Should successfully parse all sample messages
        XCTAssertEqual(successCount, sampleMessages.count, "Not all sample messages were parsed successfully")
        
        // Calculate accuracy percentage
        let accuracy = Double(successCount) / Double(sampleMessages.count) * 100
        XCTAssertGreaterThanOrEqual(accuracy, 95.0, "Parsing accuracy should be at least 95%")
    }
}
