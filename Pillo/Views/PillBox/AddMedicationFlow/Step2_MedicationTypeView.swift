//
//  Step2_MedicationTypeView.swift
//  Pillo
//
//  Created by Chloe Lee on 2025-12-10.
//

import SwiftUI

struct MedicationTypeView: View {
    @Bindable var state: AddMedicationFlowState
    @Environment(\.dismiss) private var dismiss
    
    private var commonForms: [MedicationForm] {
        [.capsule, .tablet, .liquid, .topical]
    }
    
    private var moreForms: [MedicationForm] {
        MedicationForm.allCases.filter { ![MedicationForm.capsule, .tablet, .liquid, .topical].contains($0) }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Colorful pill icons illustration
                pillIconsIllustration
                    .padding(.top, 20)
                
                // Title
                Text("Choose the Medication Type")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(.white)
                    .padding(.horizontal)
                
                // Common Forms
                VStack(alignment: .leading, spacing: 12) {
                    Text("Common Forms")
                        .font(.headline)
                        .foregroundStyle(.white.opacity(0.7))
                        .padding(.horizontal)
                    
                    VStack(spacing: 0) {
                        ForEach(commonForms, id: \.self) { form in
                            formRow(form)
                        }
                    }
                    .background(Color(red: 0.17, green: 0.17, blue: 0.18))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal)
                }
                
                // More Forms
                VStack(alignment: .leading, spacing: 12) {
                    Text("More Forms")
                        .font(.headline)
                        .foregroundStyle(.white.opacity(0.7))
                        .padding(.horizontal)
                    
                    VStack(spacing: 0) {
                        ForEach(moreForms, id: \.self) { form in
                            formRow(form)
                        }
                    }
                    .background(Color(red: 0.17, green: 0.17, blue: 0.18))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal)
                }
                
                Spacer(minLength: 100)
            }
        }
        .background(Color(red: 0.11, green: 0.11, blue: 0.12))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    state.previousStep()
                } label: {
                    Image(systemName: "chevron.left")
                        .foregroundStyle(.white)
                }
            }
            
            ToolbarItem(placement: .principal) {
                VStack {
                    Text(state.medicationName)
                        .font(.headline)
                        .foregroundStyle(.white)
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.white.opacity(0.6))
                }
            }
        }
        .safeAreaInset(edge: .bottom) {
            Button {
                state.nextStep()
            } label: {
                Text("Next")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(state.canProceedFromStep(2) ? Color.cyan : Color.gray.opacity(0.3))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .disabled(!state.canProceedFromStep(2))
            .padding()
            .background(Color(red: 0.11, green: 0.11, blue: 0.12))
        }
    }
    
    private var pillIconsIllustration: some View {
        HStack(spacing: 16) {
            // Blue capsule
            Capsule()
                .fill(Color.blue)
                .frame(width: 50, height: 25)
            
            // Cyan hexagon
            HexagonShape()
                .fill(Color.cyan)
                .frame(width: 35, height: 35)
            
            // Pink circle
            Circle()
                .fill(Color.pink)
                .frame(width: 30, height: 30)
            
            // Yellow circle
            Circle()
                .fill(Color.yellow)
                .frame(width: 25, height: 25)
        }
        .padding()
    }
    
    private func formRow(_ form: MedicationForm) -> some View {
        Button {
            state.selectedForm = form
        } label: {
            HStack {
                Text(form.rawValue.capitalized)
                    .font(.body)
                    .foregroundStyle(.white)
                
                Spacer()
                
                if state.selectedForm == form {
                    Image(systemName: "checkmark")
                        .foregroundStyle(.cyan)
                }
            }
            .padding()
            .contentShape(Rectangle())
            .background(state.selectedForm == form ? Color.cyan.opacity(0.1) : Color.clear)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    NavigationStack {
        MedicationTypeView(state: AddMedicationFlowState())
    }
}

