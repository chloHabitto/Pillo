//
//  TodayViewModel.swift
//  Pillo
//
//  Created by Chloe Lee on 2025-12-10.
//

import Foundation
import SwiftData
import Observation

@Observable
class TodayViewModel {
    private var modelContext: ModelContext
    private var dailyPlanManager: DailyPlanManager
    private var intakeManager: IntakeManager
    private var syncManager: SyncManager?
    
    var selectedDate: Date = Date()
    var dailyPlan: DailyPlan = .empty
    var selectedDoses: [UUID: DoseConfiguration] = [:]  // groupId -> selected dose
    var isLoading: Bool = false
    var errorMessage: String?
    var showUndoSuccessToast: Bool = false
    var showChangeDoseConfirmation: Bool = false
    var pendingDoseChange: (groupId: UUID, oldDose: DoseConfiguration, newDose: DoseConfiguration)?
    
    init(modelContext: ModelContext, syncManager: SyncManager? = nil) {
        self.modelContext = modelContext
        self.dailyPlanManager = DailyPlanManager(modelContext: modelContext)
        self.intakeManager = IntakeManager(modelContext: modelContext)
        self.syncManager = syncManager
        loadPlan()
    }
    
    // Load or reload the daily plan
    func loadPlan() {
        isLoading = true
        modelContext.processPendingChanges()
        dailyPlan = dailyPlanManager.getPlan(for: selectedDate)
        isLoading = false
    }
    
    // Select a dose option for a group (radio button behavior)
    func selectDose(_ dose: DoseConfiguration, for group: MedicationGroup) {
        // Allow selecting any dose, including completed ones (so they can be unlogged)
        // Reassign to trigger SwiftUI observation
        var updated = selectedDoses
        updated[group.id] = dose
        selectedDoses = updated
    }
    
    // Toggle selection for a dose (select if not selected, deselect if selected)
    func toggleDoseSelection(_ dose: DoseConfiguration, for group: MedicationGroup) {
        var updated = selectedDoses
        if updated[group.id]?.id == dose.id {
            // Already selected, deselect it
            updated.removeValue(forKey: group.id)
        } else {
            // Not selected, select it
            updated[group.id] = dose
        }
        selectedDoses = updated
    }
    
    // Deselect a group
    func deselectGroup(_ group: MedicationGroup) {
        var updated = selectedDoses
        updated.removeValue(forKey: group.id)
        selectedDoses = updated
    }
    
    // Deselect all groups
    func deselectAll() {
        selectedDoses = [:]
    }
    
    // Select the first available dose for a group (used when tapping card with multiple options)
    func selectFirstAvailableDose(for group: MedicationGroup) {
        // Find the group plan
        let groupPlan = dailyPlan.timeFrames
            .flatMap { $0.groups }
            .first { $0.group.id == group.id }
        
        guard let groupPlan = groupPlan else { return }
        
        // If already has a selection, toggle it off
        if let currentSelection = selectedDoses[group.id] {
            // Check if the current selection is still valid (exists in dose options)
            if groupPlan.doseOptions.contains(where: { $0.doseConfig.id == currentSelection.id }) {
                deselectGroup(group)
                return
            } else {
                // Current selection is invalid, remove it
                deselectGroup(group)
            }
        }
        
        // Select the first available dose option
        if let firstOption = groupPlan.doseOptions.first {
            selectDose(firstOption.doseConfig, for: group)
        }
    }
    
    // Check if a dose is the selected one for its group
    func isSelected(_ dose: DoseConfiguration, in group: MedicationGroup) -> Bool {
        selectedDoses[group.id]?.id == dose.id
    }
    
    // Check if a dose was already taken today
    func isDoseCompleted(_ dose: DoseConfiguration) -> Bool {
        dailyPlan.timeFrames
            .flatMap { $0.groups }
            .first { $0.group.id == dose.group?.id }?
            .completedDose?.id == dose.id
    }
    
    // Check if we can log intake (all required groups have selection)
    var canLogIntake: Bool {
        for timeFrame in dailyPlan.timeFrames {
            for group in timeFrame.groups {
                if group.completedDose != nil {
                    continue  // Already done
                }
                if group.group.selectionRule == .optional {
                    continue  // Optional, skip
                }
                if selectedDoses[group.group.id] == nil {
                    return false  // Required but not selected
                }
            }
        }
        return !selectedDoses.isEmpty
    }
    
    // Check if all selected doses are already completed
    var areAllSelectedDosesCompleted: Bool {
        guard !selectedDoses.isEmpty else { return false }
        
        for (groupId, selectedDose) in selectedDoses {
            // Find the group plan for this group
            let groupPlan = dailyPlan.timeFrames
                .flatMap { $0.groups }
                .first { $0.group.id == groupId }
            
            // Check if the selected dose matches the completed dose
            if let completedDose = groupPlan?.completedDose {
                if completedDose.id != selectedDose.id {
                    return false  // Selected dose doesn't match completed dose
                }
            } else {
                return false  // No completed dose for this group
            }
        }
        
        return true
    }
    
    // Get the intake logs for selected completed doses
    func getSelectedIntakeLogs() -> [IntakeLog] {
        var logs: [IntakeLog] = []
        
        for (groupId, selectedDose) in selectedDoses {
            let groupPlan = dailyPlan.timeFrames
                .flatMap { $0.groups }
                .first { $0.group.id == groupId }
            
            if let completedIntakeLog = groupPlan?.completedIntakeLog,
               let completedDose = groupPlan?.completedDose,
               completedDose.id == selectedDose.id {
                logs.append(completedIntakeLog)
            }
        }
        
        return logs
    }
    
    // Get summary of what will be logged (for confirmation)
    func getIntakeSummary() -> [(dose: DoseConfiguration, components: [ComponentInfo])] {
        var summary: [(dose: DoseConfiguration, components: [ComponentInfo])] = []
        
        for (groupId, dose) in selectedDoses {
            // Skip if already completed
            if isDoseCompleted(dose) { continue }
            
            // Find the DoseOption to get component info
            let doseOption = dailyPlan.timeFrames
                .flatMap { $0.groups }
                .first { $0.group.id == groupId }?
                .doseOptions
                .first { $0.doseConfig.id == dose.id }
            
            if let option = doseOption {
                summary.append((dose: dose, components: option.components))
            }
        }
        
        return summary
    }
    
    // Log a single dose
    func logSingleIntake(dose: DoseConfiguration, deductStock: Bool = true) {
        errorMessage = nil
        
        // Skip if already completed
        guard !isDoseCompleted(dose) else { return }
        
        let result = intakeManager.logIntake(
            doseConfig: dose,
            deductStock: deductStock,
            date: selectedDate
        )
        
        switch result {
        case .success(let intakeLog):
            syncManager?.syncIntakeLog(intakeLog)
            loadPlan()
        case .failure(let error):
            errorMessage = "Failed to log intake: \(error)"
        }
    }
    
    // Log all selected doses
    func logSelectedIntakes(deductStock: Bool = true) {
        errorMessage = nil
        
        for (_, dose) in selectedDoses {
            // Skip already completed
            if isDoseCompleted(dose) { continue }
            
            let result = intakeManager.logIntake(
                doseConfig: dose,
                deductStock: deductStock,
                date: selectedDate
            )
            
            switch result {
            case .success(let intakeLog):
                syncManager?.syncIntakeLog(intakeLog)
                continue
            case .failure(let error):
                errorMessage = "Failed to log intake: \(error)"
                break
            }
        }
        
        // Reload to reflect changes
        loadPlan()
        // Keep selections so user can immediately unlog if needed
        // The selected doses are now completed, so button will show "Unlog Selected"
    }
    
    // Change selected date
    func changeDate(to date: Date) {
        selectedDate = date
        selectedDoses.removeAll()
        loadPlan()
    }
    
    // Go to today
    func goToToday() {
        changeDate(to: Date())
    }
    
    // Check if viewing today
    var isToday: Bool {
        Calendar.current.isDateInToday(selectedDate)
    }
    
    // Undo an intake log by ID (avoids stale reference)
    func undoIntake(logId: UUID) {
        errorMessage = nil
        let success = intakeManager.undoIntake(logId: logId)

        if success {
            syncManager?.deleteIntakeLogFromCloud(id: logId)
            modelContext.processPendingChanges()
            loadPlan()
            showUndoSuccessToast = true

            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) { [weak self] in
                self?.showUndoSuccessToast = false
            }
        } else {
            errorMessage = "Failed to undo intake"
        }
    }

    // Undo an intake log (kept for compatibility; delegates to ID-based undo)
    func undoIntake(log: IntakeLog) {
        undoIntake(logId: log.id)
    }
    
    // Unlog all selected completed doses
    func unlogSelectedIntakes() {
        errorMessage = nil
        let logs = getSelectedIntakeLogs()
        var anySuccess = false

        for log in logs {
            let logId = log.id
            if intakeManager.undoIntake(logId: logId) {
                syncManager?.deleteIntakeLogFromCloud(id: logId)
                anySuccess = true
            }
        }

        loadPlan()
        selectedDoses.removeAll()
        if anySuccess {
            showUndoSuccessToast = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
                self?.showUndoSuccessToast = false
            }
        }
    }

    // Change from one logged dose to another (undo old, log new)
    func changeDose(for groupId: UUID, from oldDose: DoseConfiguration, to newDose: DoseConfiguration) {
        let groupPlan = dailyPlan.timeFrames
            .flatMap { $0.groups }
            .first { $0.group.id == groupId }

        guard let existingLogId = groupPlan?.completedIntakeLog?.id else { return }

        let undoSuccess = intakeManager.undoIntake(logId: existingLogId)
        if undoSuccess {
            syncManager?.deleteIntakeLogFromCloud(id: existingLogId)
        }

        let result = intakeManager.logIntake(
            doseConfig: newDose,
            deductStock: true,
            date: selectedDate
        )

        switch result {
        case .success(let intakeLog):
            syncManager?.syncIntakeLog(intakeLog)
        case .failure(let error):
            errorMessage = "Failed to log new intake: \(error)"
        }

        loadPlan()
        selectedDoses.removeAll()
    }

    // Whether selecting this dose should show "change dose" confirmation (another dose already logged)
    func shouldShowChangeDoseConfirmation(for group: MedicationGroup, newDose: DoseConfiguration) -> Bool {
        let groupPlan = dailyPlan.timeFrames
            .flatMap { $0.groups }
            .first { $0.group.id == group.id }

        if let completedDose = groupPlan?.completedDose,
           completedDose.id != newDose.id {
            return true
        }
        return false
    }
}

