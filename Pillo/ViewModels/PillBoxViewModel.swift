//
//  PillBoxViewModel.swift
//  Pillo
//
//  Created by Chloe Lee on 2025-12-10.
//

import Foundation
import SwiftData
import Observation

@Observable
class PillBoxViewModel {
    private var modelContext: ModelContext
    private var stockManager: StockManager
    
    var medications: [Medication] = []
    var groups: [MedicationGroup] = []
    var isLoading: Bool = false
    var errorMessage: String?
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        self.stockManager = StockManager(modelContext: modelContext)
        loadData()
    }
    
    func loadData() {
        isLoading = true
        loadMedications()
        loadGroups()
        isLoading = false
    }
    
    private func loadMedications() {
        let descriptor = FetchDescriptor<Medication>(
            sortBy: [SortDescriptor(\.name, order: .forward)]
        )
        medications = (try? modelContext.fetch(descriptor)) ?? []
    }
    
    private func loadGroups() {
        let descriptor = FetchDescriptor<MedicationGroup>(
            sortBy: [SortDescriptor(\.createdAt, order: .forward)]
        )
        groups = (try? modelContext.fetch(descriptor)) ?? []
    }
    
    // MARK: - Medication CRUD
    
    func addMedication(
        name: String,
        form: MedicationForm,
        strength: Double,
        strengthUnit: String
    ) -> Medication {
        let medication = Medication(
            name: name,
            form: form,
            strength: strength,
            strengthUnit: strengthUnit
        )
        modelContext.insert(medication)
        try? modelContext.save()
        loadMedications()
        return medication
    }
    
    func deleteMedication(_ medication: Medication) {
        modelContext.delete(medication)
        try? modelContext.save()
        loadMedications()
    }
    
    // MARK: - Stock Source Management
    
    func addStockSource(
        to medication: Medication,
        label: String,
        quantity: Int?,
        countingEnabled: Bool,
        lowStockThreshold: Int = 10,
        expiryDate: Date? = nil
    ) {
        let source = StockSource(
            label: label,
            initialQuantity: quantity,
            currentQuantity: quantity,
            countingEnabled: countingEnabled,
            lowStockThreshold: lowStockThreshold,
            expiryDate: expiryDate,
            medication: medication
        )
        modelContext.insert(source)
        try? modelContext.save()
        loadMedications()
    }
    
    func deleteStockSource(_ source: StockSource) {
        modelContext.delete(source)
        try? modelContext.save()
        loadMedications()
    }
    
    func enableCounting(for source: StockSource, currentQuantity: Int?) {
        stockManager.enableCounting(source: source, currentQuantity: currentQuantity)
        try? modelContext.save()
        loadMedications()
    }
    
    func getCurrentStock(for medication: Medication) -> Int {
        stockManager.getCurrentStock(for: medication)
    }
    
    func getLowStockMedications() -> [Medication] {
        stockManager.getLowStockMedications()
    }
    
    // MARK: - Group Management
    
    func addGroup(
        name: String,
        selectionRule: SelectionRule,
        timeFrame: TimeFrame,
        reminderTime: Date? = nil
    ) -> MedicationGroup {
        let group = MedicationGroup(
            name: name,
            selectionRule: selectionRule,
            timeFrame: timeFrame,
            reminderTime: reminderTime
        )
        modelContext.insert(group)
        try? modelContext.save()
        loadGroups()
        return group
    }
    
    func deleteGroup(_ group: MedicationGroup) {
        modelContext.delete(group)
        try? modelContext.save()
        loadGroups()
    }
    
    // MARK: - Dose Configuration
    
    func addDoseConfiguration(
        displayName: String,
        components: [(medication: Medication, quantity: Int)],
        group: MedicationGroup?,
        scheduleType: ScheduleType = .everyday,
        startDate: Date = Date(),
        endDate: Date? = nil
    ) -> DoseConfiguration {
        let doseConfig = DoseConfiguration(
            displayName: displayName,
            scheduleType: scheduleType,
            startDate: startDate,
            endDate: endDate,
            group: group
        )
        modelContext.insert(doseConfig)
        
        for component in components {
            let doseComponent = DoseComponent(
                quantity: component.quantity,
                doseConfiguration: doseConfig,
                medication: component.medication
            )
            modelContext.insert(doseComponent)
        }
        
        try? modelContext.save()
        loadGroups()
        return doseConfig
    }
    
    func deleteDoseConfiguration(_ config: DoseConfiguration) {
        modelContext.delete(config)
        try? modelContext.save()
        loadGroups()
    }
    
    // MARK: - Schedule Information
    
    /// Get schedule information for a medication (times and time frames)
    func getScheduleInfo(for medication: Medication) -> (times: [Date], timeFrames: [TimeFrame]) {
        var times: [Date] = []
        var timeFrames: Set<TimeFrame> = []
        
        // Fetch all and filter in memory - SwiftData #Predicate has limitations with optional relationships
        let descriptor = FetchDescriptor<DoseComponent>()
        
        guard let allComponents = try? modelContext.fetch(descriptor) else {
            return (times: [], timeFrames: [])
        }
        
        let components = allComponents.filter { $0.medication?.id == medication.id }
        
        for component in components {
            guard let doseConfig = component.doseConfiguration,
                  let group = doseConfig.group else {
                continue
            }
            
            timeFrames.insert(group.timeFrame)
            
            if let reminderTime = group.reminderTime {
                times.append(reminderTime)
            }
        }
        
        return (times: times.sorted(), timeFrames: Array(timeFrames).sorted { $0.rawValue < $1.rawValue })
    }
    
    /// Format schedule as a readable string
    func formatSchedule(for medication: Medication) -> String {
        let scheduleInfo = getScheduleInfo(for: medication)
        
        if scheduleInfo.times.isEmpty && scheduleInfo.timeFrames.isEmpty {
            return "No schedule"
        }
        
        var parts: [String] = []
        
        // Add time frames
        if !scheduleInfo.timeFrames.isEmpty {
            let frameNames = scheduleInfo.timeFrames.map { $0.rawValue.capitalized }
            parts.append(frameNames.joined(separator: ", "))
        }
        
        // Add times
        if !scheduleInfo.times.isEmpty {
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            let timeStrings = scheduleInfo.times.map { formatter.string(from: $0) }
            parts.append(timeStrings.joined(separator: ", "))
        }
        
        return parts.joined(separator: " • ")
    }
}

