//
//  DailyPlanManager.swift
//  Pillo
//
//  Created by Chloe Lee on 2025-12-10.
//

import Foundation
import SwiftData

class DailyPlanManager {
    private var modelContext: ModelContext
    private var intakeManager: IntakeManager
    private var stockManager: StockManager
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        self.stockManager = StockManager(modelContext: modelContext)
        self.intakeManager = IntakeManager(modelContext: modelContext)
    }
    
    /// Generate the medication plan for a specific date, grouped by time frame
    func getPlan(for date: Date = Date()) -> DailyPlan {
        // 1. Fetch all MedicationGroups
        let allGroups = fetchAllGroups()
        
        // 2. Group them by timeFrame (morning, afternoon, evening, night)
        let groupsByTimeFrame = Dictionary(grouping: allGroups) { $0.timeFrame }
        
        // 3. Get all intakes for the date
        let intakes = intakeManager.getIntakes(for: date)
        
        // 4. Build time frame plans
        var timeFramePlans: [TimeFramePlan] = []
        
        for timeFrame in TimeFrame.allCases {
            guard let groups = groupsByTimeFrame[timeFrame] else {
                continue
            }
            
            var groupPlans: [GroupPlan] = []
            
            for group in groups {
                // Get dose configurations for this group
                let doseConfigs = group.doseConfigurations.filter { $0.isActive }
                
                // Find which dose was completed (if any)
                let completedIntake = intakes.first { intake in
                    intake.doseConfiguration?.group?.id == group.id
                }
                let completedDose = completedIntake?.doseConfiguration
                
                // Build dose options
                var doseOptions: [DoseOption] = []
                
                for doseConfig in doseConfigs {
                    // Check if this dose was taken
                    let isCompleted = doseConfig.id == completedDose?.id
                    
                    // Build component info
                    var components: [ComponentInfo] = []
                    
                    for component in doseConfig.components {
                        guard let medication = component.medication else {
                            continue
                        }
                        
                        let availableStock = stockManager.getCurrentStock(for: medication)
                        
                        // Get low stock threshold from any source, or default to 10
                        let lowStockThreshold = medication.stockSources
                            .first(where: { $0.countingEnabled })?.lowStockThreshold ?? 10
                        
                        // Check if counting is enabled for this medication
                        let isCountingEnabled = medication.stockSources.contains { $0.countingEnabled }
                        
                        let componentInfo = ComponentInfo(
                            medication: medication,
                            quantityNeeded: component.quantity,
                            availableStock: availableStock,
                            lowStockThreshold: lowStockThreshold,
                            isCountingEnabled: isCountingEnabled
                        )
                        
                        components.append(componentInfo)
                    }
                    
                    let doseOption = DoseOption(
                        doseConfig: doseConfig,
                        components: components,
                        isCompleted: isCompleted
                    )
                    
                    doseOptions.append(doseOption)
                }
                
                // Get reminder time from group (or use default based on time frame)
                let reminderTime = group.reminderTime ?? defaultReminderTime(for: timeFrame)
                
                let groupPlan = GroupPlan(
                    group: group,
                    doseOptions: doseOptions,
                    completedDose: completedDose
                )
                
                groupPlans.append(groupPlan)
            }
            
            // Get reminder time from first group in time frame, or use default
            let reminderTime = groups.first?.reminderTime ?? defaultReminderTime(for: timeFrame)
            
            let timeFramePlan = TimeFramePlan(
                timeFrame: timeFrame,
                reminderTime: reminderTime,
                groups: groupPlans
            )
            
            timeFramePlans.append(timeFramePlan)
        }
        
        // Sort time frames in order: morning, afternoon, evening, night
        timeFramePlans.sort { timeFrame1, timeFrame2 in
            let order: [TimeFrame] = [.morning, .afternoon, .evening, .night]
            let index1 = order.firstIndex(of: timeFrame1.timeFrame) ?? Int.max
            let index2 = order.firstIndex(of: timeFrame2.timeFrame) ?? Int.max
            return index1 < index2
        }
        
        // Calculate overall status
        let overallStatus = getCompletionStatus(for: date)
        
        return DailyPlan(
            timeFrames: timeFramePlans,
            overallStatus: overallStatus
        )
    }
    
    /// Get completion status for a date
    func getCompletionStatus(for date: Date) -> CompletionStatus {
        let allGroups = fetchAllGroups()
        let intakes = intakeManager.getIntakes(for: date)
        
        // Group intakes by group ID
        let intakesByGroup = Dictionary(grouping: intakes) { intake in
            intake.doseConfiguration?.group?.id
        }
        
        var hasAnyCompletion = false
        var allRequiredComplete = true
        
        for group in allGroups {
            // Skip optional groups
            if group.selectionRule == .optional {
                continue
            }
            
            let groupIntakes = intakesByGroup[group.id] ?? []
            let count = groupIntakes.count
            
            switch group.selectionRule {
            case .exactlyOne:
                if count == 1 {
                    hasAnyCompletion = true
                } else {
                    allRequiredComplete = false
                }
                
            case .atLeastOne:
                if count >= 1 {
                    hasAnyCompletion = true
                } else {
                    allRequiredComplete = false
                }
                
            case .optional:
                // Already skipped
                break
            }
        }
        
        if allRequiredComplete && hasAnyCompletion {
            return .complete
        } else if hasAnyCompletion {
            return .partial
        } else {
            return .none
        }
    }
    
    /// Check if a specific group's requirements are met for a date
    func isGroupSatisfied(group: MedicationGroup, on date: Date) -> Bool {
        let intakes = intakeManager.getIntakes(for: date)
        let groupIntakes = intakes.filter { $0.doseConfiguration?.group?.id == group.id }
        
        switch group.selectionRule {
        case .exactlyOne:
            return groupIntakes.count == 1
        case .atLeastOne:
            return groupIntakes.count >= 1
        case .optional:
            return true
        }
    }
    
    /// Fetch all medication groups from the database
    private func fetchAllGroups() -> [MedicationGroup] {
        let descriptor = FetchDescriptor<MedicationGroup>(
            sortBy: [SortDescriptor(\.createdAt, order: .forward)]
        )
        return (try? modelContext.fetch(descriptor)) ?? []
    }
    
    /// Get default reminder time for a time frame
    private func defaultReminderTime(for timeFrame: TimeFrame) -> Date? {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day], from: Date())
        
        switch timeFrame {
        case .morning:
            components.hour = 8
            components.minute = 0
        case .afternoon:
            components.hour = 13
            components.minute = 0
        case .evening:
            components.hour = 18
            components.minute = 0
        case .night:
            components.hour = 21
            components.minute = 0
        }
        
        return calendar.date(from: components)
    }
}

// MARK: - Supporting Types

struct DailyPlan {
    var timeFrames: [TimeFramePlan]
    var overallStatus: CompletionStatus
    
    static var empty: DailyPlan {
        DailyPlan(timeFrames: [], overallStatus: .none)
    }
}

struct TimeFramePlan: Identifiable {
    var id: TimeFrame { timeFrame }
    var timeFrame: TimeFrame
    var reminderTime: Date?
    var groups: [GroupPlan]
    
    var isComplete: Bool {
        groups.allSatisfy { $0.isSatisfied }
    }
}

struct GroupPlan: Identifiable {
    var id: UUID { group.id }
    var group: MedicationGroup
    var doseOptions: [DoseOption]
    var completedDose: DoseConfiguration?
    
    var isSatisfied: Bool {
        switch group.selectionRule {
        case .exactlyOne:
            return completedDose != nil
        case .atLeastOne:
            return completedDose != nil
        case .optional:
            return true
        }
    }
}

struct DoseOption: Identifiable {
    var id: UUID { doseConfig.id }
    var doseConfig: DoseConfiguration
    var components: [ComponentInfo]
    var isCompleted: Bool
    
    var hasLowStock: Bool {
        components.contains { $0.isLowStock }
    }
    
    var hasSufficientStock: Bool {
        components.allSatisfy { $0.hasSufficientStock }
    }
}

struct ComponentInfo: Identifiable {
    var id: UUID { medication.id }
    var medication: Medication
    var quantityNeeded: Int
    var availableStock: Int
    var lowStockThreshold: Int
    var isCountingEnabled: Bool
    
    var hasSufficientStock: Bool {
        !isCountingEnabled || availableStock >= quantityNeeded
    }
    
    var isLowStock: Bool {
        isCountingEnabled && availableStock <= lowStockThreshold
    }
}

enum CompletionStatus {
    case complete
    case partial
    case none
    
    var icon: String {
        switch self {
        case .complete: return "checkmark.circle.fill"
        case .partial: return "circle.lefthalf.filled"
        case .none: return "circle"
        }
    }
    
    var color: String {
        switch self {
        case .complete: return "green"
        case .partial: return "orange"
        case .none: return "gray"
        }
    }
}

