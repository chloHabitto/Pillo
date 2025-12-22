//
//  IntakeLog.swift
//  Pillo
//
//  Created by Chloe Lee on 2025-12-10.
//

import Foundation
import SwiftData

@Model
final class IntakeLog {
    var id: UUID
    var loggedAt: Date
    var scheduledFor: Date
    var notes: String?
    
    var doseConfiguration: DoseConfiguration?
    
    @Relationship(deleteRule: .cascade)
    var stockDeductions: [StockDeduction] = []
    
    init(
        id: UUID = UUID(),
        loggedAt: Date = Date(),
        scheduledFor: Date,
        notes: String? = nil,
        doseConfiguration: DoseConfiguration? = nil
    ) {
        self.id = id
        self.loggedAt = loggedAt
        self.scheduledFor = scheduledFor
        self.notes = notes
        self.doseConfiguration = doseConfiguration
    }
}

