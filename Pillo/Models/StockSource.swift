//
//  StockSource.swift
//  Pillo
//
//  Created by Chloe Lee on 2025-12-10.
//

import Foundation
import SwiftData

@Model
final class StockSource {
    var id: UUID
    var label: String
    var initialQuantity: Int?
    var currentQuantity: Int?
    var countingEnabled: Bool
    var lowStockThreshold: Int
    var startedCountingAt: Date?
    var expiryDate: Date?
    var createdAt: Date
    
    var medication: Medication?
    
    init(
        id: UUID = UUID(),
        label: String,
        initialQuantity: Int? = nil,
        currentQuantity: Int? = nil,
        countingEnabled: Bool = false,
        lowStockThreshold: Int = 10,
        startedCountingAt: Date? = nil,
        expiryDate: Date? = nil,
        createdAt: Date = Date(),
        medication: Medication? = nil
    ) {
        self.id = id
        self.label = label
        self.initialQuantity = initialQuantity
        self.currentQuantity = currentQuantity
        self.countingEnabled = countingEnabled
        self.lowStockThreshold = lowStockThreshold
        self.startedCountingAt = startedCountingAt
        self.expiryDate = expiryDate
        self.createdAt = createdAt
        self.medication = medication
    }
}

