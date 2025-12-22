//
//  Medication.swift
//  Pillo
//
//  Created by Chloe Lee on 2025-12-10.
//

import Foundation
import SwiftData

enum MedicationForm: String, Codable, CaseIterable {
    case capsule, tablet, liquid, topical, cream, drops,
         foam, gel, inhaler, injection, lotion, patch,
         powder, spray, suppository
}

@Model
final class Medication {
    var id: UUID
    var name: String
    var form: MedicationForm
    var strength: Double
    var strengthUnit: String
    var createdAt: Date
    
    @Relationship(deleteRule: .cascade)
    var stockSources: [StockSource] = []
    
    @Relationship(deleteRule: .cascade)
    var doseComponents: [DoseComponent] = []
    
    init(
        id: UUID = UUID(),
        name: String,
        form: MedicationForm,
        strength: Double,
        strengthUnit: String,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.form = form
        self.strength = strength
        self.strengthUnit = strengthUnit
        self.createdAt = createdAt
    }
}

