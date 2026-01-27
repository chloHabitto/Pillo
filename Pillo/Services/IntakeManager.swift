//
//  IntakeManager.swift
//  Pillo
//
//  Created by Chloe Lee on 2025-12-10.
//

import Foundation
import SwiftData

enum IntakeError: Error {
    case stockDeductionFailed(medication: Medication, error: StockError)
    case noComponents
    case contextError
}

class IntakeManager {
    private var modelContext: ModelContext
    private var stockManager: StockManager
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        self.stockManager = StockManager(modelContext: modelContext)
    }
    
    // Log an intake - this is the core function
    func logIntake(
        doseConfig: DoseConfiguration,
        deductStock: Bool = true,
        date: Date = Date(),
        notes: String? = nil
    ) -> Result<IntakeLog, IntakeError> {
        // 1. Get all components from the DoseConfiguration
        let components = doseConfig.components
        
        guard !components.isEmpty else {
            return .failure(.noComponents)
        }
        
        // 2. Create the IntakeLog entry first
        let intakeLog = IntakeLog(
            loggedAt: Date(),
            scheduledFor: date,
            notes: notes,
            doseConfiguration: doseConfig
        )
        modelContext.insert(intakeLog)
        
        // 3. For each component, deduct stock and create StockDeduction records
        var allDeductions: [StockDeduction] = []
        var failedDeduction: (component: DoseComponent, error: StockError)?
        
        for component in components {
            // Extract medication early to avoid accessing invalidated objects
            guard let medication = component.medication else {
                continue
            }
            
            if deductStock {
                // Try to deduct stock
                let result = stockManager.deductStock(
                    medication: medication,
                    quantity: component.quantity
                )
                
                switch result {
                case .success(let deductions):
                    // Link all deductions to the intake log
                    // (may be multiple if quantity was split across multiple sources)
                    for deduction in deductions {
                        deduction.intakeLog = intakeLog
                        allDeductions.append(deduction)
                    }
                    
                case .failure(let error):
                    // Store the failure for later handling
                    failedDeduction = (component, error)
                    break
                }
            } else {
                // Don't deduct stock, but still create a deduction record marked as not deducted
                let deduction = StockDeduction(
                    quantityDeducted: component.quantity,
                    wasDeducted: false,
                    intakeLog: intakeLog,
                    medication: medication
                )
                modelContext.insert(deduction)
                allDeductions.append(deduction)
            }
        }
        
        // 4. Handle partial failures
        if let failure = failedDeduction {
            // Roll back all successful deductions
            for deduction in allDeductions {
                if deduction.wasDeducted {
                    stockManager.restoreStock(deduction: deduction)
                } else {
                    modelContext.delete(deduction)
                }
            }
            
            // Delete the intake log
            modelContext.delete(intakeLog)
            
            // Try to save context to ensure rollback
            do {
                try modelContext.save()
            } catch {
                // Context save failed, but we've already deleted the objects
            }
            
            return .failure(.stockDeductionFailed(
                medication: failure.component.medication ?? Medication(
                    name: "Unknown",
                    form: .tablet,
                    strength: 0,
                    strengthUnit: "mg"
                ),
                error: failure.error
            ))
        }
        
        // 5. Save context and return the complete log
        do {
            try modelContext.save()
        } catch {
            return .failure(.contextError)
        }
        
        return .success(intakeLog)
    }
    
    // Undo by ID to avoid stale reference issues
    func undoIntake(logId: UUID) -> Bool {
        // 1. Fetch fresh IntakeLog by ID
        let predicate = #Predicate<IntakeLog> { $0.id == logId }
        let descriptor = FetchDescriptor<IntakeLog>(predicate: predicate)

        guard let log = try? modelContext.fetch(descriptor).first else {
            print("DEBUG: Could not find IntakeLog with id \(logId)")
            return false
        }

        // 2. Restore all stock deductions (iterate a copy to avoid modifying while iterating)
        let deductions = Array(log.stockDeductions)
        for deduction in deductions {
            if deduction.wasDeducted {
                stockManager.restoreStock(deduction: deduction)
            } else {
                modelContext.delete(deduction)
            }
        }

        // 3. Delete the IntakeLog
        modelContext.delete(log)

        // 4. Save context with proper error handling
        do {
            try modelContext.save()
            print("DEBUG: Successfully undid intake log \(logId)")
            return true
        } catch {
            print("ERROR: Failed to save after undo: \(error)")
            return false
        }
    }

    // Undo an intake (kept for compatibility; delegates to ID-based undo)
    func undoIntake(log: IntakeLog) {
        _ = undoIntake(logId: log.id)
    }
    
    // Get intakes for a specific date
    func getIntakes(for date: Date) -> [IntakeLog] {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let predicate = #Predicate<IntakeLog> { log in
            log.scheduledFor >= startOfDay && log.scheduledFor < endOfDay
        }
        
        let descriptor = FetchDescriptor<IntakeLog>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.scheduledFor, order: .forward)]
        )
        
        return (try? modelContext.fetch(descriptor)) ?? []
    }
    
    // Check if a dose was taken today
    func wasTakenToday(doseConfig: DoseConfiguration) -> Bool {
        let today = Date()
        let intakes = getIntakes(for: today)
        
        return intakes.contains { log in
            log.doseConfiguration?.id == doseConfig.id
        }
    }
}

