//
//  MainTabView.swift
//  ExpenseLogger
//
//  Created by marvin towett on 30/08/2025.
//

import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            DashboardView()
                .tabItem {
                    Image(systemName: "chart.pie.fill")
                    Text("Dashboard")
                }
            
            AddTransactionView()
                .tabItem {
                    Image(systemName: "plus.circle.fill")
                    Text("Add")
                }
            
            TransactionsView()
                .tabItem {
                    Image(systemName: "list.bullet")
                    Text("Transactions")
                }
            
            SettingsView()
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
                }
        }
        .accentColor(.accentColor)
        .background(Color.primaryBackground)
    }
}

#Preview {
    MainTabView()
}
