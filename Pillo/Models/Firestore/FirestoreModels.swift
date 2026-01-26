//
//  FirestoreModels.swift
//  Pillo
//
//  Created by Chloe Lee on 2025-12-10.
//

import Foundation
import FirebaseFirestore

// MARK: - Medication

struct FSMedication: Codable, Identifiable {
    @DocumentID var documentId: String?
    var id: String
    var name: String
    var form: String
    var strength: Double
    var strengthUnit: String
    var customFormName: String?
    var createdAt: Date
    var stockSources: [FSStockSource]
    
    var firestoreId: String { documentId ?? id }
}

struct FSStockSource: Codable, Identifiable {
    var id: String
    var label: String
    var initialQuantity: Int?
    var currentQuantity: Int?
    var countingEnabled: Bool
    var lowStockThreshold: Int
    var startedCountingAt: Date?
    var expiryDate: Date?
    var createdAt: Date
}

// MARK: - Medication Group

struct FSMedicationGroup: Codable, Identifiable {
    @DocumentID var documentId: String?
    var id: String
    var name: String
    var selectionRule: String
    var timeFrame: String
    var reminderTime: Date?
    var createdAt: Date
    
    var firestoreId: String { documentId ?? id }
}

// MARK: - Dose Configuration

struct FSDoseConfiguration: Codable, Identifiable {
    @DocumentID var documentId: String?
    var id: String
    var displayName: String
    var groupId: String?
    var scheduleType: String
    var scheduleData: Data?
    var isActive: Bool
    var createdAt: Date
    var startDate: Date
    var endDate: Date?
    var components: [FSDoseComponent]
    
    var firestoreId: String { documentId ?? id }
}

struct FSDoseComponent: Codable, Identifiable {
    var id: String
    var quantity: Int
    var medicationId: String
}

// MARK: - Intake Log

struct FSIntakeLog: Codable, Identifiable {
    @DocumentID var documentId: String?
    var id: String
    var doseConfigurationId: String?
    var loggedAt: Date
    var scheduledFor: Date
    var notes: String?
    var stockDeductions: [FSStockDeduction]
    
    var firestoreId: String { documentId ?? id }
}

struct FSStockDeduction: Codable, Identifiable {
    var id: String
    var quantityDeducted: Int
    var wasDeducted: Bool
    var medicationId: String?
    var stockSourceId: String?
}

// MARK: - Conversion Extensions

extension Medication {
    func toFirestore() -> FSMedication {
        FSMedication(
            id: id.uuidString,
            name: name,
            form: form.rawValue,
            strength: strength,
            strengthUnit: strengthUnit,
            customFormName: customFormName,
            createdAt: createdAt,
            stockSources: stockSources.map { $0.toFirestore() }
        )
    }
}

extension StockSource {
    func toFirestore() -> FSStockSource {
        FSStockSource(
            id: id.uuidString,
            label: label,
            initialQuantity: initialQuantity,
            currentQuantity: currentQuantity,
            countingEnabled: countingEnabled,
            lowStockThreshold: lowStockThreshold,
            startedCountingAt: startedCountingAt,
            expiryDate: expiryDate,
            createdAt: createdAt
        )
    }
}

extension MedicationGroup {
    func toFirestore() -> FSMedicationGroup {
        FSMedicationGroup(
            id: id.uuidString,
            name: name,
            selectionRule: selectionRule.rawValue,
            timeFrame: timeFrame.rawValue,
            reminderTime: reminderTime,
            createdAt: createdAt
        )
    }
}

extension DoseConfiguration {
    func toFirestore() -> FSDoseConfiguration {
        FSDoseConfiguration(
            id: id.uuidString,
            displayName: displayName,
            groupId: group?.id.uuidString,
            scheduleType: scheduleType.rawValue,
            scheduleData: scheduleData,
            isActive: isActive,
            createdAt: createdAt,
            startDate: startDate,
            endDate: endDate,
            components: components.map { $0.toFirestore() }
        )
    }
}

extension DoseComponent {
    func toFirestore() -> FSDoseComponent {
        FSDoseComponent(
            id: id.uuidString,
            quantity: quantity,
            medicationId: medication?.id.uuidString ?? ""
        )
    }
}

extension IntakeLog {
    func toFirestore() -> FSIntakeLog {
        FSIntakeLog(
            id: id.uuidString,
            doseConfigurationId: doseConfiguration?.id.uuidString,
            loggedAt: loggedAt,
            scheduledFor: scheduledFor,
            notes: notes,
            stockDeductions: stockDeductions.map { $0.toFirestore() }
        )
    }
}

extension StockDeduction {
    func toFirestore() -> FSStockDeduction {
        FSStockDeduction(
            id: id.uuidString,
            quantityDeducted: quantityDeducted,
            wasDeducted: wasDeducted,
            medicationId: medication?.id.uuidString,
            stockSourceId: stockSource?.id.uuidString
        )
    }
}
