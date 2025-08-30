//
//  SettingsView.swift
//  ExpenseLogger
//
//  Created by marvin towett on 30/08/2025.
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: CTSpacing.lg) {
                    // Header
                    VStack(alignment: .leading, spacing: CTSpacing.sm) {
                        CTTextStyle.titleLarge("Settings")
                        CTTextStyle.caption("Customize your expense tracking experience")
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .ctHorizontalPadding()
                    
                    // Settings sections
                    VStack(spacing: CTSpacing.md) {
                        CTCard {
                            VStack(alignment: .leading, spacing: CTSpacing.md) {
                                CTTextStyle.headline("General")
                                
                                VStack(spacing: CTSpacing.sm) {
                                    SettingsRow(title: "Currency", value: "USD")
                                    SettingsRow(title: "Default Category", value: "General")
                                    SettingsRow(title: "Budget Alerts", value: "On")
                                }
                            }
                        }
                        
                        CTCard {
                            VStack(alignment: .leading, spacing: CTSpacing.md) {
                                CTTextStyle.headline("Data & Privacy")
                                
                                VStack(spacing: CTSpacing.sm) {
                                    SettingsRow(title: "Export Data", value: "")
                                    SettingsRow(title: "Clear All Data", value: "")
                                }
                            }
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

struct SettingsRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            CTTextStyle.body(title)
            Spacer()
            if !value.isEmpty {
                CTTextStyle.caption(value)
            }
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.textSecondary)
        }
        .padding(.vertical, CTSpacing.xs)
    }
}

#Preview {
    SettingsView()
}
