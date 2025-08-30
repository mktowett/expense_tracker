//
//  DashboardView.swift
//  ExpenseLogger
//
//  Created by marvin towett on 30/08/2025.
//

import SwiftUI

struct DashboardView: View {
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: CTSpacing.lg) {
                    // Header
                    VStack(alignment: .leading, spacing: CTSpacing.sm) {
                        CTTextStyle.titleLarge("Dashboard")
                        CTTextStyle.caption("Track your expenses at a glance")
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .ctHorizontalPadding()
                    
                    // Summary Cards
                    VStack(spacing: CTSpacing.md) {
                        CTCard {
                            VStack(alignment: .leading, spacing: CTSpacing.sm) {
                                CTTextStyle.headline("Total Expenses")
                                CTTextStyle.titleMedium("$0.00")
                                CTTextStyle.caption("This month")
                            }
                        }
                        
                        CTCard {
                            VStack(alignment: .leading, spacing: CTSpacing.sm) {
                                CTTextStyle.headline("Recent Activity")
                                CTTextStyle.body("No transactions yet")
                                CTTextStyle.caption("Add your first expense to get started")
                            }
                        }
                    }
                    .ctHorizontalPadding()
                    
                    Spacer()
                }
                .ctVerticalSpacing(CTSpacing.lg)
            }
            .ctScreenBackground()
        }
    }
}

#Preview {
    DashboardView()
}
