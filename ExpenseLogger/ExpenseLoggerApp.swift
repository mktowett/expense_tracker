//
//  ExpenseLoggerApp.swift
//  ExpenseLogger
//
//  Created by marvin towett on 30/08/2025.
//

import SwiftUI
import SwiftData

@main
struct ExpenseLoggerApp: App {
    var body: some Scene {
        WindowGroup {
            MainTabView()
        }
        .modelContainer(for: [Transaction.self, Category.self])
    }
}
