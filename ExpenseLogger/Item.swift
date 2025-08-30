//
//  Item.swift
//  ExpenseLogger
//
//  Created by marvin towett on 30/08/2025.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
