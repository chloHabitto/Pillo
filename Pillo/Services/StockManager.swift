//
//  StockManager.swift
//  Pillo
//
//  Created by Chloe Lee on 2025-12-10.
//

import Foundation
import SwiftData

enum StockError: Error {
    case insufficientStock
    case noCountableSource
    case sourceNotFound
}

class StockManager {
    private var modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    // Get total countable stock for a medication
    func getCurrentStock(for medication: Medication) -> Int {
        let countableSources = medication.stockSources.filter { source in
            source.countingEnabled && source.currentQuantity != nil
        }
        
        return countableSources.reduce(0) { total, source in
            total + (source.currentQuantity ?? 0)
        }
    }
    
    // Deduct stock (returns success/failure)
    // Note: May create multiple StockDeduction records if quantity spans multiple sources
    // Returns all deductions created; all deductions are inserted into context
    func deductStock(
        medication: Medication,
        quantity: Int,
        preferredSource: StockSource? = nil
    ) -> Result<[StockDeduction], StockError> {
        // Extract medication ID early to avoid accessing invalidated objects
        let medicationId = medication.id
        
        // If preferred source is provided and valid, use it
        if let preferred = preferredSource,
           preferred.medication?.id == medicationId,
           preferred.countingEnabled,
           let currentQty = preferred.currentQuantity,
           currentQty >= quantity {
            preferred.currentQuantity = currentQty - quantity
            modelContext.insert(preferred)
            
            let deduction = StockDeduction(
                quantityDeducted: quantity,
                wasDeducted: true,
                medication: medication,
                stockSource: preferred
            )
            modelContext.insert(deduction)
            
            return .success([deduction])
        }
        
        // Get all countable sources for this medication
        // Access stockSources immediately to avoid invalidation issues
        let stockSources = medication.stockSources
        let countableSources = stockSources
            .filter { source in
                source.countingEnabled &&
                source.currentQuantity != nil &&
                (source.currentQuantity ?? 0) > 0
            }
        
        guard !countableSources.isEmpty else {
            // No countable sources - create deduction record but mark as not deducted
            let deduction = StockDeduction(
                quantityDeducted: quantity,
                wasDeducted: false,
                medication: medication
            )
            modelContext.insert(deduction)
            return .success([deduction])
        }
        
        // Sort sources by priority:
        // 1. Earliest expiry date (nil expiry dates go last)
        // 2. Lowest current quantity
        // 3. Most recently added (latest createdAt)
        let sortedSources = countableSources.sorted { source1, source2 in
            // Compare expiry dates
            switch (source1.expiryDate, source2.expiryDate) {
            case (let date1?, let date2?):
                if date1 != date2 {
                    return date1 < date2
                }
            case (nil, _):
                return false // source1 goes after source2
            case (_, nil):
                return true // source1 goes before source2
            default:
                break
            }
            
            // If expiry dates are equal or both nil, compare quantities
            let qty1 = source1.currentQuantity ?? 0
            let qty2 = source2.currentQuantity ?? 0
            if qty1 != qty2 {
                return qty1 < qty2
            }
            
            // If quantities are equal, compare creation dates (newer first)
            return source1.createdAt > source2.createdAt
        }
        
        // Try to deduct from sources in priority order
        var remainingQuantity = quantity
        var deductions: [StockDeduction] = []
        
        for source in sortedSources {
            guard let currentQty = source.currentQuantity, currentQty > 0 else {
                continue
            }
            
            let deductFromThis = min(remainingQuantity, currentQty)
            source.currentQuantity = currentQty - deductFromThis
            remainingQuantity -= deductFromThis
            
            let deduction = StockDeduction(
                quantityDeducted: deductFromThis,
                wasDeducted: true,
                medication: medication,
                stockSource: source
            )
            modelContext.insert(deduction)
            deductions.append(deduction)
            
            if remainingQuantity <= 0 {
                break
            }
        }
        
        // If we couldn't deduct all, check if we have any countable sources
        if remainingQuantity > 0 {
            // We have countable sources but insufficient stock
            // Restore what we deducted and return error
            for deduction in deductions {
                restoreStock(deduction: deduction)
            }
            return .failure(.insufficientStock)
        }
        
        // Success - return all deductions
        // All deductions are already inserted into context and will be linked in IntakeManager
        return .success(deductions)
    }
    
    // Restore stock (for undo)
    func restoreStock(deduction: StockDeduction) {
        guard deduction.wasDeducted,
              let source = deduction.stockSource,
              source.countingEnabled else {
            // If it wasn't deducted, just delete the deduction record
            modelContext.delete(deduction)
            return
        }
        
        // Restore the quantity
        let currentQty = source.currentQuantity ?? 0
        source.currentQuantity = currentQty + deduction.quantityDeducted
        
        // Delete the deduction record
        modelContext.delete(deduction)
    }
    
    // Enable counting for a source
    func enableCounting(
        source: StockSource,
        currentQuantity: Int?
    ) {
        source.countingEnabled = true
        source.currentQuantity = currentQuantity
        source.startedCountingAt = Date()
        modelContext.insert(source)
    }
    
    // Get all deductions for a medication that don't have an intake log yet
    // Useful for finding deductions created during a transaction
    func getUnlinkedDeductions(for medicationId: UUID) -> [StockDeduction] {
        // Use a predicate to filter by medication ID if possible
        // Since we can't easily filter by relationship in SwiftData predicates,
        // we'll fetch recent deductions and filter in memory
        // Limit to recent deductions to avoid performance issues
        var descriptor = FetchDescriptor<StockDeduction>(
            sortBy: [SortDescriptor(\.id, order: .reverse)]
        )
        descriptor.fetchLimit = 100 // Limit to recent 100 deductions
        
        guard let recentDeductions = try? modelContext.fetch(descriptor) else {
            return []
        }
        
        return recentDeductions.filter { deduction in
            // Check if intake log is nil first (safer check)
            guard deduction.intakeLog == nil else {
                return false
            }
            
            // Try to access medication ID - if medication is invalidated, this will fail
            // but we can't catch it, so we rely on SwiftData's behavior
            // The key is to access it immediately and not hold the reference
            guard let medication = deduction.medication else {
                return false
            }
            // Access ID immediately - if medication is invalidated, this will crash
            // but that's better than silently failing. The real fix is to ensure
            // we call this method before any context operations that might invalidate
            return medication.id == medicationId
        }
    }
    
    // Get medications below threshold
    func getLowStockMedications() -> [Medication] {
        let descriptor = FetchDescriptor<Medication>()
        
        guard let allMedications = try? modelContext.fetch(descriptor) else {
            return []
        }
        
        return allMedications.filter { medication in
            let stock = getCurrentStock(for: medication)
            let hasLowStockSource = medication.stockSources.contains { source in
                source.countingEnabled &&
                source.currentQuantity != nil &&
                (source.currentQuantity ?? 0) < source.lowStockThreshold
            }
            return stock > 0 && stock < (medication.stockSources.first?.lowStockThreshold ?? 10) || hasLowStockSource
        }
    }
}

