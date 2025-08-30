//
//  TransactionsView.swift
//  ExpenseLogger
//
//  Created by marvin towett on 30/08/2025.
//

import SwiftUI

struct TransactionsView: View {
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: CTSpacing.lg) {
                    // Header
                    VStack(alignment: .leading, spacing: CTSpacing.sm) {
                        CTTextStyle.titleLarge("Transactions")
                        CTTextStyle.caption("View and manage your transaction history")
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .ctHorizontalPadding()
                    
                    // Transaction list placeholder
                    CTCard {
                        VStack(spacing: CTSpacing.md) {
                            Image(systemName: "list.bullet.clipboard")
                                .font(.system(size: 48))
                                .foregroundColor(.textSecondary)
                            
                            CTTextStyle.headline("No Transactions Yet")
                            CTTextStyle.body("Your transaction history will appear here")
                            CTTextStyle.caption("Start by adding your first expense")
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, CTSpacing.xl)
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
    TransactionsView()
}
