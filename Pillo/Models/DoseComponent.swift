//
//  DoseComponent.swift
//  Pillo
//
//  Created by Chloe Lee on 2025-12-10.
//

import Foundation
import SwiftData

@Model
final class DoseComponent {
    var id: UUID
    var quantity: Int
    
    var doseConfiguration: DoseConfiguration?
    var medication: Medication?
    
    init(
        id: UUID = UUID(),
        quantity: Int,
        doseConfiguration: DoseConfiguration? = nil,
        medication: Medication? = nil
    ) {
        self.id = id
        self.quantity = quantity
        self.doseConfiguration = doseConfiguration
        self.medication = medication
    }
}

