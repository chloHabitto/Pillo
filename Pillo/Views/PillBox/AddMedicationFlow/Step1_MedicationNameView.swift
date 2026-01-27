//
//  Step1_MedicationNameView.swift
//  Pillo
//
//  Created by Chloe Lee on 2025-12-10.
//

import SwiftUI

struct MedicationNameView: View {
    @Bindable var state: AddMedicationFlowState
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            // Pill icons illustration
            pillIconsIllustration
            
            // Title
            Text("Medication Name")
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(Color.primary)
            
            // Text field
            TextField("Add Medication Name", text: $state.medicationName)
                .textFieldStyle(.plain)
                .font(.system(size: 16))
                .foregroundStyle(Color.primary)
                .padding()
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal, 20)
            
            Spacer()
            
            // Next button
            Button {
                state.nextStep()
            } label: {
                Text("Next")
                    .font(.headline)
                    .foregroundStyle(state.canProceedFromStep(1) ? Color.white : Color.secondary)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(state.canProceedFromStep(1) ? Color.cyan : Color(.tertiarySystemFill))
                    .clipShape(Capsule())
            }
            .disabled(!state.canProceedFromStep(1))
            .padding(.horizontal, 20)
            .padding(.bottom, 32)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color("appSurface01"))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(Color.secondary)
                }
            }
        }
    }
    
    private var pillIconsIllustration: some View {
        Image("pills")
            .resizable()
            .scaledToFit()
            .frame(width: 120, height: 80)
    }
}

#Preview {
    NavigationStack {
        MedicationNameView(state: AddMedicationFlowState())
    }
}

