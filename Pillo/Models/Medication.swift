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
    
    // Appearance properties
    var appearanceShape: String? // PillShape rawValue
    var appearanceLeftColor: String? // Color name (e.g., "PillColor-White")
    var appearanceRightColor: String? // Color name for two-tone shapes
    var appearanceBackgroundColor: String? // Background color name
    var appearanceShowRoundTabletLine: Bool = false
    var appearanceShowOvalTabletLine: Bool = false
    var appearanceShowOblongTabletLine: Bool = false
    var appearancePhotoData: Data? // UIImage as Data
    
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
        createdAt: Date = Date(),
        appearanceShape: String? = nil,
        appearanceLeftColor: String? = nil,
        appearanceRightColor: String? = nil,
        appearanceBackgroundColor: String? = nil,
        appearanceShowRoundTabletLine: Bool = false,
        appearanceShowOvalTabletLine: Bool = false,
        appearanceShowOblongTabletLine: Bool = false,
        appearancePhotoData: Data? = nil
    ) {
        self.id = id
        self.name = name
        self.form = form
        self.strength = strength
        self.strengthUnit = strengthUnit
        self.customFormName = customFormName
        self.createdAt = createdAt
        self.appearanceShape = appearanceShape
        self.appearanceLeftColor = appearanceLeftColor
        self.appearanceRightColor = appearanceRightColor
        self.appearanceBackgroundColor = appearanceBackgroundColor
        self.appearanceShowRoundTabletLine = appearanceShowRoundTabletLine
        self.appearanceShowOvalTabletLine = appearanceShowOvalTabletLine
        self.appearanceShowOblongTabletLine = appearanceShowOblongTabletLine
        self.appearancePhotoData = appearancePhotoData
    }
    
    var formDisplayName: String {
        if form == .other, let customName = customFormName, !customName.isEmpty {
            return customName.capitalized
        }
        return form.rawValue.capitalized
    }
}

