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
                    ScheduleView(state: flowState)
                case 5:
                    MedicationAppearanceView(state: flowState)
                case 6:
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
              let firstStrength = state.strengths.first else {
            return
        }
        
        // Create medication with first strength (you may want to create multiple medications for multiple strengths)
        let medication = viewModel.addMedication(
            name: state.medicationName,
            form: form,
            strength: firstStrength.value,
            strengthUnit: firstStrength.unit
        )
        
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
        
        // First, group all times by their TimeFrame
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
        
        // For each TimeFrame, find or create group and create dose configurations
        for (timeFrame, times) in timeFrameTimes {
            // Find or create MedicationGroup for this TimeFrame
            let group: MedicationGroup
            if let existingGroup = viewModel.groups.first(where: { $0.timeFrame == timeFrame }) {
                group = existingGroup
                timeFrameGroups[timeFrame] = existingGroup
            } else {
                // Create new group for this TimeFrame
                // Use the earliest time as the reminder time
                let earliestTime = times.min() ?? times.first ?? Date()
                let groupName = "\(timeFrame.rawValue.capitalized) Medications"
                group = viewModel.addGroup(
                    name: groupName,
                    selectionRule: .exactlyOne,
                    timeFrame: timeFrame,
                    reminderTime: earliestTime
                )
                timeFrameGroups[timeFrame] = group
            }
            
            // Create one DoseConfiguration for this TimeFrame (not per time)
            // The times are used to determine the TimeFrame and set reminder time on the group
            let displayName = state.displayName.isEmpty ? state.medicationName : state.displayName
            _ = viewModel.addDoseConfiguration(
                displayName: displayName,
                components: [(medication: medication, quantity: 1)],
                group: group,
                scheduleType: scheduleType
            )
        }
        
        // Reload data to ensure everything is up to date
        viewModel.loadData()
        
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

