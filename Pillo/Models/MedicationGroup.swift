//
//  MedicationGroup.swift
//  Pillo
//
//  Created by Chloe Lee on 2025-12-10.
//

import Foundation
import SwiftData

enum SelectionRule: String, Codable, CaseIterable {
    case exactlyOne = "exactly_one"
    case atLeastOne = "at_least_one"
    case optional = "optional"
}

enum TimeFrame: String, Codable, CaseIterable {
    case morning, afternoon, evening, night
}

@Model
final class MedicationGroup {
    var id: UUID
    var name: String
    var selectionRule: SelectionRule
    var timeFrame: TimeFrame
    var reminderTime: Date?
    var createdAt: Date
    
    @Relationship(deleteRule: .cascade)
    var doseConfigurations: [DoseConfiguration] = []
    
    init(
        id: UUID = UUID(),
        name: String,
        selectionRule: SelectionRule,
        timeFrame: TimeFrame,
        reminderTime: Date? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.selectionRule = selectionRule
        self.timeFrame = timeFrame
        self.reminderTime = reminderTime
        self.createdAt = createdAt
    }
}

