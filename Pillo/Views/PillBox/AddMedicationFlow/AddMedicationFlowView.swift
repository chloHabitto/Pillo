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
        
        // TODO: Save additional data like schedule, appearance, display name, notes
        // This would require extending the Medication model or creating related models
        // For now, we're just creating the basic medication
        
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

