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
    
    private let units = ["mg", "mcg", "g", "mL", "%"]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Animated pill icons
                animatedPillIcons
                    .padding(.top, 20)
                
                // Title
                Text("Add the Medication Strength")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(.white)
                    .padding(.horizontal)
                
                // Strength input
                VStack(alignment: .leading, spacing: 8) {
                    Text("Strength")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .padding(.horizontal)
                    
                    TextField("Add Strength", text: $state.currentStrengthValue)
                        .textFieldStyle(.plain)
                        .font(.system(size: 16))
                        .foregroundStyle(.white)
                        .keyboardType(.decimalPad)
                        .padding()
                        .background(Color(red: 0.17, green: 0.17, blue: 0.18))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .padding(.horizontal)
                }
                
                // Unit selection
                VStack(alignment: .leading, spacing: 8) {
                    Text("Choose Unit")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .padding(.horizontal)
                    
                    VStack(spacing: 0) {
                        ForEach(units, id: \.self) { unit in
                            Button {
                                state.currentStrengthUnit = unit
                            } label: {
                                HStack {
                                    Text(unit)
                                        .font(.body)
                                        .foregroundStyle(.white)
                                    
                                    Spacer()
                                    
                                    if state.currentStrengthUnit == unit {
                                        Image(systemName: "checkmark")
                                            .foregroundStyle(.cyan)
                                    }
                                }
                                .padding()
                                .contentShape(Rectangle())
                                .background(state.currentStrengthUnit == unit ? Color.cyan.opacity(0.1) : Color.clear)
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            if unit != units.last {
                                Divider()
                                    .background(Color.white.opacity(0.1))
                            }
                        }
                    }
                    .background(Color(red: 0.17, green: 0.17, blue: 0.18))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal)
                }
                
                // Add strength button
                Button {
                    state.addStrength()
                } label: {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Add Strength")
                    }
                    .font(.headline)
                    .foregroundStyle(.cyan)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.cyan.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .disabled(state.currentStrengthValue.isEmpty)
                .padding(.horizontal)
                
                // Added strengths
                if !state.strengths.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Added Strengths")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .padding(.horizontal)
                        
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 12) {
                            ForEach(Array(state.strengths.enumerated()), id: \.offset) { index, strength in
                                HStack(spacing: 4) {
                                    Text("\(Int(strength.value))\(strength.unit)")
                                        .font(.subheadline)
                                        .foregroundStyle(.white)
                                    
                                    Button {
                                        state.removeStrength(at: index)
                                    } label: {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundStyle(.white.opacity(0.6))
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
                    if let form = state.selectedForm {
                        Text(form.rawValue.capitalized)
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.6))
                    }
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
            HStack(spacing: 12) {
                Button {
                    state.nextStep()
                } label: {
                    Text("Next")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(state.canProceedFromStep(3) ? Color.cyan : Color.gray.opacity(0.3))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .disabled(!state.canProceedFromStep(3))
                
                Button {
                    state.nextStep()
                } label: {
                    Text("Skip")
                        .font(.headline)
                        .foregroundStyle(.white.opacity(0.7))
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(red: 0.17, green: 0.17, blue: 0.18))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
            .padding()
            .background(Color(red: 0.11, green: 0.11, blue: 0.12))
        }
    }
    
    private var animatedPillIcons: some View {
        HStack(spacing: 20) {
            // Yellow outlined capsule
            Capsule()
                .stroke(Color.yellow, style: StrokeStyle(lineWidth: 2, dash: [5]))
                .frame(width: 50, height: 25)
            
            // Light blue filled capsule
            Capsule()
                .fill(Color.cyan)
                .frame(width: 50, height: 25)
                .overlay(
                    Capsule()
                        .stroke(Color.white, style: StrokeStyle(lineWidth: 1, dash: [3]))
                )
            
            // Dark blue filled capsule
            Capsule()
                .fill(Color.blue)
                .frame(width: 50, height: 25)
                .overlay(
                    Capsule()
                        .stroke(Color.white, style: StrokeStyle(lineWidth: 1, dash: [3]))
                )
        }
        .padding()
    }
}

#Preview {
    NavigationStack {
        MedicationStrengthView(state: AddMedicationFlowState())
    }
}

