//
//  AddTransactionView.swift
//  ExpenseLogger
//
//  Created by marvin towett on 30/08/2025.
//

import SwiftUI

struct AddTransactionView: View {
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: CTSpacing.lg) {
                    // Header
                    VStack(alignment: .leading, spacing: CTSpacing.sm) {
                        CTTextStyle.titleLarge("Add Transaction")
                        CTTextStyle.caption("Record a new expense or income")
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .ctHorizontalPadding()
                    
                    // Form placeholder
                    CTCard {
                        VStack(spacing: CTSpacing.lg) {
                            CTTextStyle.headline("Transaction Form")
                            CTTextStyle.body("Form components will be added in the next phase")
                            
                            CTButton(title: "Save Transaction", action: {
                                // Action will be implemented in next phase
                            })
                        }
                    }
                    .ctHorizontalPadding()
                    
                    Spacer()
                }
            }
            .ctScreenBackground()
        }
    }
}

#Preview {
    AddTransactionView()
}
