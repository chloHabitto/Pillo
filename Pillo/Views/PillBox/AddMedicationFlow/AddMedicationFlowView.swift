//
//  AddMedicationFlowView.swift
//  Pillo
//
//  Created by Chloe Lee on 2025-12-10.
//

import SwiftUI
import SwiftData

struct AddMedicationFlowView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var flowState = AddMedicationFlowState()
    let viewModel: PillBoxViewModel
    
    var body: some View {
        NavigationStack {
            Group {
                switch flowState.currentStep {
                case 1:
                    MedicationNameView(state: flowState)
                case 2:
                    MedicationTypeView(state: flowState)
                case 3:
                    MedicationStrengthView(state: flowState)
                case 4:
                    DosingTypeView(state: flowState)
                case 5:
                    ScheduleView(state: flowState)
                case 6:
                    ShapeSelectionView(state: flowState)
                case 7:
                    ColorSelectionView(state: flowState)
                case 8:
                    ReviewDetailsView(state: flowState) { state in
                        saveMedication(from: state)
                    }
                default:
                    MedicationNameView(state: flowState)
                }
            }
            .transition(.asymmetric(
                insertion: .move(edge: .trailing).combined(with: .opacity),
                removal: .move(edge: .leading).combined(with: .opacity)
            ))
            .animation(.easeInOut(duration: 0.3), value: flowState.currentStep)
        }
    }
    
    private func saveMedication(from state: AddMedicationFlowState) {
        guard let form = state.selectedForm,
              !state.strengths.isEmpty else {
            return
        }
        
        // Convert appearance data
        let shapeString = state.selectedShape.rawValue
        let leftColorString = state.leftColor.colorName()
        let rightColorString = state.rightColor.colorName()
        let backgroundColorString = state.backgroundColor.colorName()
        let photoData = state.selectedPhoto?.jpegData(compressionQuality: 0.8)
        
        // Create medications for each strength
        var medicationsForStrengths: [Medication] = []
        for strength in state.strengths {
            let med = viewModel.addMedication(
                name: state.medicationName,
                form: form,
                strength: strength.value,
                strengthUnit: strength.unit,
                customFormName: form == .other ? state.customFormName : nil,
                appearanceShape: shapeString,
                appearanceLeftColor: leftColorString,
                appearanceRightColor: rightColorString,
                appearanceBackgroundColor: backgroundColorString,
                appearanceShowRoundTabletLine: state.showRoundTabletLine,
                appearanceShowOvalTabletLine: state.showOvalTabletLine,
                appearanceShowOblongTabletLine: state.showOblongTabletLine,
                appearancePhotoData: photoData
            )
            medicationsForStrengths.append(med)
        }
        
        // Map ScheduleOption to ScheduleType
        let scheduleType: ScheduleType = {
            switch state.scheduleOption {
            case .everyDay:
                return .everyday
            case .specificDays:
                return .specificDays
            case .cyclical:
                return .cyclical
            case .asNeeded:
                return .asNeeded
            case .everyFewDays:
                return .everyday // Treat "Every Few Days" as everyday for now
            }
        }()
        
        // Group times by TimeFrame and create groups/dose configurations
        let calendar = Calendar.current
        var timeFrameGroups: [TimeFrame: MedicationGroup] = [:]
        var timeFrameTimes: [TimeFrame: [Date]] = [:]
        
        // Helper to convert TimeFrameType to TimeFrame enum
        func mapToTimeFrame(_ type: TimeFrameType, startTime: Date?) -> TimeFrame {
            switch type {
            case .morning:
                return .morning
            case .afternoon:
                return .afternoon
            case .evening:
                return .evening
            case .night:
                return .night
            case .custom:
                // For custom, determine based on start time hour
                if let startTime = startTime {
                    let hour = calendar.component(.hour, from: startTime)
                    if hour >= 5 && hour < 12 {
                        return .morning
                    } else if hour >= 12 && hour < 17 {
                        return .afternoon
                    } else if hour >= 17 && hour < 21 {
                        return .evening
                    } else {
                        return .night
                    }
                }
                return .morning // Default
            }
        }
        
        // Process times based on selection mode
        if state.timeSelectionMode == .specificTime {
            // Original logic: group specific times by their TimeFrame
            for time in state.times {
                // Determine TimeFrame based on hour
                let hour = calendar.component(.hour, from: time)
                let timeFrame: TimeFrame = {
                    if hour >= 5 && hour < 12 {
                        return .morning
                    } else if hour >= 12 && hour < 17 {
                        return .afternoon
                    } else if hour >= 17 && hour < 21 {
                        return .evening
                    } else {
                        return .night
                    }
                }()
                
                if timeFrameTimes[timeFrame] == nil {
                    timeFrameTimes[timeFrame] = []
                }
                timeFrameTimes[timeFrame]?.append(time)
            }
        } else {
            // Time frame mode: group by the selected time frames
            for timeFrameSelection in state.timeFrames {
                let timeFrame = mapToTimeFrame(timeFrameSelection.type, startTime: timeFrameSelection.startTime)
                
                // Use start time if available, otherwise use a representative time
                let representativeTime: Date
                if let startTime = timeFrameSelection.startTime {
                    representativeTime = startTime
                } else {
                    // Use default hour for the time frame type
                    let hour = timeFrameSelection.type.defaultStartHour
                    representativeTime = calendar.date(bySettingHour: hour, minute: 0, second: 0, of: Date()) ?? Date()
                }
                
                if timeFrameTimes[timeFrame] == nil {
                    timeFrameTimes[timeFrame] = []
                }
                timeFrameTimes[timeFrame]?.append(representativeTime)
            }
        }
        
        // For each TimeFrame, find or create group and create dose configurations
        // Each medication should have its own group per timeFrame to avoid mixing medications
        for (timeFrame, times) in timeFrameTimes {
            // Find or create MedicationGroup for this medication and TimeFrame
            // Check if any existing group for this timeFrame already contains this medication
            let medicationName = state.medicationName
            let group: MedicationGroup
            
            // Look for an existing group that:
            // 1. Has the same timeFrame
            // 2. Contains dose configurations with the same medication name
            let existingGroup = viewModel.groups.first(where: { group in
                guard group.timeFrame == timeFrame else { return false }
                // Check if any dose config in this group contains the same medication
                return group.doseConfigurations.contains { doseConfig in
                    doseConfig.components.contains { component in
                        component.medication?.name == medicationName
                    }
                }
            })
            
            if let existingGroup = existingGroup {
                group = existingGroup
                timeFrameGroups[timeFrame] = existingGroup
            } else {
                // Create new group for this medication and TimeFrame
                // Use the earliest time as the reminder time
                let earliestTime = times.min() ?? times.first ?? Date()
                let groupName = medicationName
                group = viewModel.addGroup(
                    name: groupName,
                    selectionRule: .exactlyOne,
                    timeFrame: timeFrame,
                    reminderTime: earliestTime
                )
                timeFrameGroups[timeFrame] = group
            }
            
            // Create dose configurations based on dosing type
            if state.dosingType == .flexible {
                // Create multiple DoseConfigurations for flexible dosing
                for doseOption in state.doseOptions {
                    let components: [(medication: Medication, quantity: Int)] = doseOption.components.compactMap { comp in
                        guard comp.strengthIndex < medicationsForStrengths.count, comp.quantity > 0 else { return nil }
                        return (medication: medicationsForStrengths[comp.strengthIndex], quantity: comp.quantity)
                    }
                    
                    guard !components.isEmpty else { continue }
                    
                    let displayName = doseOption.displayName(strengths: state.strengths)
                    
                    _ = viewModel.addDoseConfiguration(
                        displayName: displayName,
                        components: components,
                        group: group,
                        scheduleType: scheduleType,
                        startDate: state.startDate,
                        endDate: state.endDate
                    )
                }
            } else {
                // Fixed: Create single DoseConfiguration
                let components: [(medication: Medication, quantity: Int)] = state.fixedDoseComponents.compactMap { comp in
                    guard comp.strengthIndex < medicationsForStrengths.count, comp.quantity > 0 else { return nil }
                    return (medication: medicationsForStrengths[comp.strengthIndex], quantity: comp.quantity)
                }
                
                guard !components.isEmpty else { continue }
                
                let total = state.getFixedDoseTotal()
                let unit = state.strengths.first?.unit ?? "mg"
                let displayName = state.displayName.isEmpty ? "\(Int(total))\(unit)" : state.displayName
                
                _ = viewModel.addDoseConfiguration(
                    displayName: displayName,
                    components: components,
                    group: group,
                    scheduleType: scheduleType,
                    startDate: state.startDate,
                    endDate: state.endDate
                )
            }
        }
        
        // Reload data to ensure everything is up to date
        viewModel.loadData()
        
        // DEBUG: Print medication and group information
        print("DEBUG: Created \(medicationsForStrengths.count) medications")
        for med in medicationsForStrengths {
            print("DEBUG: Medication: \(med.name) \(Int(med.strength))\(med.strengthUnit)")
        }
        print("DEBUG: viewModel.groups count: \(viewModel.groups.count)")
        for group in viewModel.groups {
            print("DEBUG: Group '\(group.name)' has \(group.doseConfigurations.count) dose configs")
            for dc in group.doseConfigurations {
                print("DEBUG:   - DoseConfig '\(dc.displayName)' isActive=\(dc.isActive) startDate=\(dc.startDate) components=\(dc.components.count)")
            }
        }
        
        dismiss()
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Medication.self, configurations: config)
    let context = container.mainContext
    let viewModel = PillBoxViewModel(modelContext: context)
    
    return AddMedicationFlowView(viewModel: viewModel)
}

