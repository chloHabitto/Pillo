//
//  Step3_MedicationStrengthView.swift
//  Pillo
//
//  Created by Chloe Lee on 2025-12-10.
//

import SwiftUI

struct MedicationStrengthView: View {
    @Bindable var state: AddMedicationFlowState
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isStrengthFieldFocused: Bool
    
    private let units = ["mg", "mcg", "μg", "g", "mL", "%", "mm", "IU", "unit", "piece", "portion", "capsule", "pill", "suppository", "pessary", "vaginal tablet", "vaginal capsule", "vaginal suppository", "application", "ampoule", "packet", "drop", "patch", "injection", "spray", "puff"]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Medication strength image
                Image("medstrength")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 28)
                    .padding(.top, 12)
                
                // Title
                Text("Add the Medication Strength")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(Color.primary)
                    .padding(.horizontal)
                
                // Strength input
                VStack(alignment: .leading, spacing: 8) {
                    Text("Strength")
                        .font(.headline)
                        .foregroundStyle(Color.primary)
                        .padding(.horizontal)
                    
                    TextField("Add Strength", text: $state.currentStrengthValue)
                        .textFieldStyle(.plain)
                        .font(.system(size: 16))
                        .foregroundStyle(Color.primary)
                        .keyboardType(.decimalPad)
                        .focused($isStrengthFieldFocused)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .padding(.horizontal)
                }
                
                // Added strengths
                if !state.strengths.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Added Strengths")
                            .font(.headline)
                            .foregroundStyle(Color.primary)
                            .padding(.horizontal)
                        
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 12) {
                            ForEach(Array(state.strengths.enumerated()), id: \.offset) { index, strength in
                                HStack(spacing: 4) {
                                    Text("\(Int(strength.value))\(strength.unit)")
                                        .font(.subheadline)
                                        .foregroundStyle(Color.primary)
                                    
                                    Button {
                                        state.removeStrength(at: index)
                                    } label: {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundStyle(Color.secondary)
                                    }
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(Color.cyan.opacity(0.2))
                                .clipShape(Capsule())
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                
                // Unit selection
                VStack(alignment: .leading, spacing: 8) {
                    Text("Choose Unit")
                        .font(.headline)
                        .foregroundStyle(Color.primary)
                        .padding(.horizontal)
                    
                    VStack(spacing: 0) {
                        ForEach(units, id: \.self) { unit in
                            Button {
                                state.currentStrengthUnit = unit
                            } label: {
                                HStack {
                                    Text(unit)
                                        .font(.body)
                                        .foregroundStyle(Color.primary)
                                    
                                    Spacer()
                                    
                                    if state.currentStrengthUnit == unit {
                                        Image(systemName: "checkmark")
                                            .foregroundStyle(Color.cyan)
                                    }
                                }
                                .padding()
                                .contentShape(Rectangle())
                                .background(state.currentStrengthUnit == unit ? Color.cyan.opacity(0.1) : Color.clear)
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            if unit != units.last {
                                Divider()
                                    .background(Color(.separator))
                            }
                        }
                    }
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal)
                }
                
                Spacer(minLength: 100)
            }
        }
        .background(Color(.systemBackground))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    state.previousStep()
                } label: {
                    Image(systemName: "chevron.left")
                        .foregroundStyle(Color.primary)
                }
            }
            
            ToolbarItem(placement: .principal) {
                VStack {
                    Text(state.medicationName)
                        .font(.headline)
                        .foregroundStyle(Color.primary)
                    if let form = state.selectedForm {
                        if form == .other, let customName = state.customFormName, !customName.isEmpty {
                            Text(customName.capitalized)
                                .font(.caption)
                                .foregroundStyle(Color.secondary)
                        } else {
                            Text(form.rawValue.capitalized)
                                .font(.caption)
                                .foregroundStyle(Color.secondary)
                        }
                    }
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(Color.secondary)
                }
            }
        }
        .safeAreaInset(edge: .bottom) {
            if isStrengthFieldFocused {
                // Add Strength and Done buttons when TextField is focused
                HStack(spacing: 12) {
                    Button {
                        state.addStrength()
                        // Keep focus after adding so user can add more strengths
                    } label: {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("Add Strength")
                        }
                        .font(.headline)
                        .foregroundStyle(state.currentStrengthValue.isEmpty ? Color.secondary : Color.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(state.currentStrengthValue.isEmpty ? Color(.tertiarySystemFill) : Color.cyan)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .disabled(state.currentStrengthValue.isEmpty)
                    
                    Button {
                        isStrengthFieldFocused = false
                    } label: {
                        Image(systemName: "checkmark")
                            .font(.headline)
                            .foregroundStyle(Color.white)
                            .frame(width: 50, height: 50)
                            .background(Color.cyan)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
                .padding()
                .background(Color(.systemBackground))
            } else {
                // Existing Next/Skip buttons when TextField is not focused
                HStack(spacing: 12) {
                    Button {
                        state.nextStep()
                    } label: {
                        Text("Skip")
                            .font(.headline)
                            .foregroundStyle(Color.secondary)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(.secondarySystemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    
                    Button {
                        state.nextStep()
                    } label: {
                        Text("Next")
                            .font(.headline)
                            .foregroundStyle(state.canProceedFromStep(3) ? Color.white : Color.secondary)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(state.canProceedFromStep(3) ? Color.cyan : Color(.tertiarySystemFill))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .disabled(!state.canProceedFromStep(3))
                }
                .padding()
                .background(Color(.systemBackground))
            }
        }
    }
    
}

#Preview {
    NavigationStack {
        MedicationStrengthView(state: AddMedicationFlowState())
    }
}

