//
//  DoseConfiguration.swift
//  Pillo
//
//  Created by Chloe Lee on 2025-12-10.
//

import Foundation
import SwiftData

enum ScheduleType: String, Codable, CaseIterable {
    case everyday
    case specificDays
    case cyclical
    case asNeeded
}

@Model
final class DoseConfiguration {
    var id: UUID
    var displayName: String
    var scheduleType: ScheduleType
    var scheduleData: Data?
    var isActive: Bool
    var createdAt: Date
    var startDate: Date
    var endDate: Date?
    
    var group: MedicationGroup?
    
    @Relationship(deleteRule: .cascade)
    var components: [DoseComponent] = []
    
    @Relationship(deleteRule: .cascade)
    var intakeLogs: [IntakeLog] = []
    
    init(
        id: UUID = UUID(),
        displayName: String,
        scheduleType: ScheduleType,
        scheduleData: Data? = nil,
        isActive: Bool = true,
        createdAt: Date = Date(),
        startDate: Date = Date(),
        endDate: Date? = nil,
        group: MedicationGroup? = nil
    ) {
        self.id = id
        self.displayName = displayName
        self.scheduleType = scheduleType
        self.scheduleData = scheduleData
        self.isActive = isActive
        self.createdAt = createdAt
        self.startDate = startDate
        self.endDate = endDate
        self.group = group
    }
}

