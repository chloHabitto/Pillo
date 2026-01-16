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
         powder, spray, suppository, other
}

@Model
final class Medication {
    var id: UUID
    var name: String
    var form: MedicationForm
    var strength: Double
    var strengthUnit: String
    var customFormName: String?
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
        customFormName: String? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.form = form
        self.strength = strength
        self.strengthUnit = strengthUnit
        self.customFormName = customFormName
        self.createdAt = createdAt
    }
    
    var formDisplayName: String {
        if form == .other, let customName = customFormName, !customName.isEmpty {
            return customName.capitalized
        }
        return form.rawValue.capitalized
    }
}

