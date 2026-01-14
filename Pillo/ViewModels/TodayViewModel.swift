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
    
    var selectedDate: Date = Date()
    var dailyPlan: DailyPlan = .empty
    var selectedDoses: [UUID: DoseConfiguration] = [:]  // groupId -> selected dose
    var isLoading: Bool = false
    var errorMessage: String?
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        self.dailyPlanManager = DailyPlanManager(modelContext: modelContext)
        self.intakeManager = IntakeManager(modelContext: modelContext)
        loadPlan()
    }
    
    // Load or reload the daily plan
    func loadPlan() {
        isLoading = true
        dailyPlan = dailyPlanManager.getPlan(for: selectedDate)
        
        // Pre-populate selectedDoses with any already-completed doses
        for timeFrame in dailyPlan.timeFrames {
            for group in timeFrame.groups {
                if let completedDose = group.completedDose {
                    selectedDoses[group.group.id] = completedDose
                }
            }
        }
        isLoading = false
    }
    
    // Select a dose option for a group (radio button behavior)
    func selectDose(_ dose: DoseConfiguration, for group: MedicationGroup) {
        // If already completed, don't allow change
        guard !isDoseCompleted(dose) else { return }
        selectedDoses[group.id] = dose
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
        case .success:
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
            case .success:
                continue
            case .failure(let error):
                errorMessage = "Failed to log intake: \(error)"
                break
            }
        }
        
        // Reload to reflect changes
        loadPlan()
        selectedDoses.removeAll()
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
    
    // Undo an intake log
    func undoIntake(log: IntakeLog) {
        errorMessage = nil
        intakeManager.undoIntake(log: log)
        loadPlan()
    }
}

