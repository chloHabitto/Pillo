//
//  StockDeduction.swift
//  Pillo
//
//  Created by Chloe Lee on 2025-12-10.
//

import Foundation
import SwiftData

@Model
final class StockDeduction {
    var id: UUID
    var quantityDeducted: Int
    var wasDeducted: Bool
    
    var intakeLog: IntakeLog?
    var medication: Medication?
    var stockSource: StockSource?
    
    init(
        id: UUID = UUID(),
        quantityDeducted: Int,
        wasDeducted: Bool,
        intakeLog: IntakeLog? = nil,
        medication: Medication? = nil,
        stockSource: StockSource? = nil
    ) {
        self.id = id
        self.quantityDeducted = quantityDeducted
        self.wasDeducted = wasDeducted
        self.intakeLog = intakeLog
        self.medication = medication
        self.stockSource = stockSource
    }
}

