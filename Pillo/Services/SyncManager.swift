//
//  SyncManager.swift
//  Pillo
//
//  Created by Chloe Lee on 2025-12-10.
//

import Foundation
import SwiftData

@Observable
class SyncManager {
    private let firestoreService = FirestoreService()
    private weak var authManager: AuthManager?
    
    var isSyncing: Bool = false
    var lastSyncError: String?
    
    init(authManager: AuthManager? = nil) {
        self.authManager = authManager
    }
    
    func setAuthManager(_ authManager: AuthManager) {
        self.authManager = authManager
    }
    
    private var userId: String? {
        authManager?.userId
    }
    
    // MARK: - Medication Sync
    
    func syncMedication(_ medication: Medication) {
        guard let userId = userId else { return }
        
        Task {
            do {
                let fsMedication = medication.toFirestore()
                try await firestoreService.saveMedication(fsMedication, userId: userId)
                print("DEBUG: Synced medication \(medication.name) to Firestore")
            } catch {
                print("ERROR: Failed to sync medication: \(error.localizedDescription)")
                await MainActor.run {
                    self.lastSyncError = error.localizedDescription
                }
            }
        }
    }
    
    func deleteMedicationFromCloud(id: UUID) {
        guard let userId = userId else { return }
        
        Task {
            do {
                try await firestoreService.deleteMedication(id: id.uuidString, userId: userId)
                print("DEBUG: Deleted medication \(id) from Firestore")
            } catch {
                print("ERROR: Failed to delete medication from cloud: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Group Sync
    
    func syncGroup(_ group: MedicationGroup) {
        guard let userId = userId else { return }
        
        Task {
            do {
                let fsGroup = group.toFirestore()
                try await firestoreService.saveGroup(fsGroup, userId: userId)
                print("DEBUG: Synced group \(group.name) to Firestore")
            } catch {
                print("ERROR: Failed to sync group: \(error.localizedDescription)")
                await MainActor.run {
                    self.lastSyncError = error.localizedDescription
                }
            }
        }
    }
    
    func deleteGroupFromCloud(id: UUID) {
        guard let userId = userId else { return }
        
        Task {
            do {
                try await firestoreService.deleteGroup(id: id.uuidString, userId: userId)
                print("DEBUG: Deleted group \(id) from Firestore")
            } catch {
                print("ERROR: Failed to delete group from cloud: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Dose Configuration Sync
    
    func syncDoseConfiguration(_ config: DoseConfiguration) {
        guard let userId = userId else { return }
        
        Task {
            do {
                let fsConfig = config.toFirestore()
                try await firestoreService.saveDoseConfiguration(fsConfig, userId: userId)
                print("DEBUG: Synced dose config \(config.displayName) to Firestore")
            } catch {
                print("ERROR: Failed to sync dose config: \(error.localizedDescription)")
                await MainActor.run {
                    self.lastSyncError = error.localizedDescription
                }
            }
        }
    }
    
    func deleteDoseConfigurationFromCloud(id: UUID) {
        guard let userId = userId else { return }
        
        Task {
            do {
                try await firestoreService.deleteDoseConfiguration(id: id.uuidString, userId: userId)
                print("DEBUG: Deleted dose config \(id) from Firestore")
            } catch {
                print("ERROR: Failed to delete dose config from cloud: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Intake Log Sync
    
    func syncIntakeLog(_ log: IntakeLog) {
        guard let userId = userId else { return }
        
        Task {
            do {
                let fsLog = log.toFirestore()
                try await firestoreService.saveIntakeLog(fsLog, userId: userId)
                print("DEBUG: Synced intake log to Firestore")
            } catch {
                print("ERROR: Failed to sync intake log: \(error.localizedDescription)")
                await MainActor.run {
                    self.lastSyncError = error.localizedDescription
                }
            }
        }
    }
    
    func deleteIntakeLogFromCloud(id: UUID) {
        guard let userId = userId else { return }
        
        Task {
            do {
                try await firestoreService.deleteIntakeLog(id: id.uuidString, userId: userId)
                print("DEBUG: Deleted intake log \(id) from Firestore")
            } catch {
                print("ERROR: Failed to delete intake log from cloud: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Full Sync
    
    func performFullSync(modelContext: ModelContext) async {
        guard let userId = userId else {
            print("DEBUG: Skipping full sync - no user logged in")
            return
        }
        
        await MainActor.run {
            self.isSyncing = true
            self.lastSyncError = nil
        }
        
        do {
            // Fetch all local data
            let medications = (try? modelContext.fetch(FetchDescriptor<Medication>())) ?? []
            let groups = (try? modelContext.fetch(FetchDescriptor<MedicationGroup>())) ?? []
            let doseConfigs = (try? modelContext.fetch(FetchDescriptor<DoseConfiguration>())) ?? []
            let intakeLogs = (try? modelContext.fetch(FetchDescriptor<IntakeLog>())) ?? []
            
            // Convert to Firestore models
            let fsMedications = medications.map { $0.toFirestore() }
            let fsGroups = groups.map { $0.toFirestore() }
            let fsDoseConfigs = doseConfigs.map { $0.toFirestore() }
            let fsIntakeLogs = intakeLogs.map { $0.toFirestore() }
            
            // Sync all
            try await firestoreService.syncAllData(
                medications: fsMedications,
                groups: fsGroups,
                doseConfigs: fsDoseConfigs,
                intakeLogs: fsIntakeLogs,
                userId: userId
            )
            
            print("DEBUG: Full sync completed successfully")
        } catch {
            print("ERROR: Full sync failed: \(error.localizedDescription)")
            await MainActor.run {
                self.lastSyncError = error.localizedDescription
            }
        }
        
        await MainActor.run {
            self.isSyncing = false
        }
    }
}
