//
//  Category.swift
//  ExpenseLogger
//
//  Created by marvin towett on 30/08/2025.
//

import SwiftUI

enum TransactionCategory: String, CaseIterable, Identifiable {
    case food = "Food"
    case transport = "Transport"
    case shopping = "Shopping"
    case bills = "Bills"
    case healthcare = "Healthcare"
    case entertainment = "Entertainment"
    case other = "Other"
    case uncategorized = "Uncategorized"
    
    var id: String { self.rawValue }
    
    var color: Color {
        switch self {
        case .food:
            return Color.orange
        case .transport:
            return Color.blue
        case .shopping:
            return Color.purple
        case .bills:
            return Color.red
        case .healthcare:
            return Color.green
        case .entertainment:
            return Color.pink
        case .other:
            return Color.gray
        case .uncategorized:
            return Color.textSecondary
        }
    }
    
    var icon: String {
        switch self {
        case .food:
            return "fork.knife"
        case .transport:
            return "car.fill"
        case .shopping:
            return "bag.fill"
        case .bills:
            return "doc.text.fill"
        case .healthcare:
            return "cross.fill"
        case .entertainment:
            return "tv.fill"
        case .other:
            return "ellipsis.circle.fill"
        case .uncategorized:
            return "questionmark.circle.fill"
        }
    }
}
