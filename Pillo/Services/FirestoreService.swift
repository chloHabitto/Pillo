//
//  FirestoreService.swift
//  Pillo
//
//  Created by Chloe Lee on 2025-12-10.
//

import Foundation
import FirebaseFirestore

class FirestoreService {
    private lazy var db = Firestore.firestore()
    
    // MARK: - Collection References
    
    private func medicationsCollection(userId: String) -> CollectionReference {
        db.collection("users").document(userId).collection("medications")
    }
    
    private func groupsCollection(userId: String) -> CollectionReference {
        db.collection("users").document(userId).collection("medicationGroups")
    }
    
    private func doseConfigsCollection(userId: String) -> CollectionReference {
        db.collection("users").document(userId).collection("doseConfigurations")
    }
    
    private func intakeLogsCollection(userId: String) -> CollectionReference {
        db.collection("users").document(userId).collection("intakeLogs")
    }
    
    // MARK: - Medications
    
    func saveMedication(_ medication: FSMedication, userId: String) async throws {
        try medicationsCollection(userId: userId)
            .document(medication.id)
            .setData(from: medication, merge: true)
    }
    
    func deleteMedication(id: String, userId: String) async throws {
        try await medicationsCollection(userId: userId)
            .document(id)
            .delete()
    }
    
    func fetchMedications(userId: String) async throws -> [FSMedication] {
        let snapshot = try await medicationsCollection(userId: userId).getDocuments()
        return snapshot.documents.compactMap { doc in
            try? doc.data(as: FSMedication.self)
        }
    }
    
    // MARK: - Medication Groups
    
    func saveGroup(_ group: FSMedicationGroup, userId: String) async throws {
        try groupsCollection(userId: userId)
            .document(group.id)
            .setData(from: group, merge: true)
    }
    
    func deleteGroup(id: String, userId: String) async throws {
        try await groupsCollection(userId: userId)
            .document(id)
            .delete()
    }
    
    func fetchGroups(userId: String) async throws -> [FSMedicationGroup] {
        let snapshot = try await groupsCollection(userId: userId).getDocuments()
        return snapshot.documents.compactMap { doc in
            try? doc.data(as: FSMedicationGroup.self)
        }
    }
    
    // MARK: - Dose Configurations
    
    func saveDoseConfiguration(_ config: FSDoseConfiguration, userId: String) async throws {
        try doseConfigsCollection(userId: userId)
            .document(config.id)
            .setData(from: config, merge: true)
    }
    
    func deleteDoseConfiguration(id: String, userId: String) async throws {
        try await doseConfigsCollection(userId: userId)
            .document(id)
            .delete()
    }
    
    func fetchDoseConfigurations(userId: String) async throws -> [FSDoseConfiguration] {
        let snapshot = try await doseConfigsCollection(userId: userId).getDocuments()
        return snapshot.documents.compactMap { doc in
            try? doc.data(as: FSDoseConfiguration.self)
        }
    }
    
    // MARK: - Intake Logs
    
    func saveIntakeLog(_ log: FSIntakeLog, userId: String) async throws {
        try intakeLogsCollection(userId: userId)
            .document(log.id)
            .setData(from: log, merge: true)
    }
    
    func deleteIntakeLog(id: String, userId: String) async throws {
        try await intakeLogsCollection(userId: userId)
            .document(id)
            .delete()
    }
    
    func fetchIntakeLogs(userId: String, limit: Int = 100) async throws -> [FSIntakeLog] {
        let snapshot = try await intakeLogsCollection(userId: userId)
            .order(by: "loggedAt", descending: true)
            .limit(to: limit)
            .getDocuments()
        return snapshot.documents.compactMap { doc in
            try? doc.data(as: FSIntakeLog.self)
        }
    }
    
    func fetchIntakeLogs(userId: String, for date: Date) async throws -> [FSIntakeLog] {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let snapshot = try await intakeLogsCollection(userId: userId)
            .whereField("scheduledFor", isGreaterThanOrEqualTo: startOfDay)
            .whereField("scheduledFor", isLessThan: endOfDay)
            .getDocuments()
        return snapshot.documents.compactMap { doc in
            try? doc.data(as: FSIntakeLog.self)
        }
    }
    
    // MARK: - Bulk Operations
    
    func syncAllData(
        medications: [FSMedication],
        groups: [FSMedicationGroup],
        doseConfigs: [FSDoseConfiguration],
        intakeLogs: [FSIntakeLog],
        userId: String
    ) async throws {
        let batch = db.batch()
        
        for medication in medications {
            let ref = medicationsCollection(userId: userId).document(medication.id)
            try batch.setData(from: medication, forDocument: ref, merge: true)
        }
        
        for group in groups {
            let ref = groupsCollection(userId: userId).document(group.id)
            try batch.setData(from: group, forDocument: ref, merge: true)
        }
        
        for config in doseConfigs {
            let ref = doseConfigsCollection(userId: userId).document(config.id)
            try batch.setData(from: config, forDocument: ref, merge: true)
        }
        
        for log in intakeLogs {
            let ref = intakeLogsCollection(userId: userId).document(log.id)
            try batch.setData(from: log, forDocument: ref, merge: true)
        }
        
        try await batch.commit()
    }
}
