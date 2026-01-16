//
//  Step3_5_DosingTypeView.swift
//  Pillo
//
//  Created by Chloe Lee on 2025-12-10.
//

import SwiftUI

struct DosingTypeView: View {
    @Bindable var state: AddMedicationFlowState
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Take meds icon
                Image("takemeds")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 48, height: 48)
                    .foregroundStyle(.cyan)
                    .padding(.top, 20)
                
                // Title
                Text("Set Your Dosing")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(Color.primary)
                    .padding(.horizontal)
                
                // Description
                Text("Do you take the same dose every time, or does it vary?")
                    .font(.subheadline)
                    .foregroundStyle(Color.secondary)
                    .padding(.horizontal)
                
                // Segmented control
                Picker("Dosing Type", selection: $state.dosingType) {
                    ForEach(DosingType.allCases, id: \.self) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .onChange(of: state.dosingType) { _, _ in
                    // Reset when switching types
                    if state.dosingType == .fixed {
                        state.doseOptions.removeAll()
                        // Initialize with first strength if available
                        if !state.strengths.isEmpty && state.fixedDoseComponents.isEmpty {
                            state.updateFixedDoseComponent(strengthIndex: 0, quantity: 1)
                        }
                    } else {
                        state.fixedDoseComponents.removeAll()
                        // Pre-populate flexible options from strengths
                        if state.doseOptions.isEmpty && !state.strengths.isEmpty {
                            for (index, _) in state.strengths.enumerated() {
                                let option = DoseOptionInput(components: [(strengthIndex: index, quantity: 1)])
                                state.addDoseOption(option)
                            }
                        }
                    }
                }
                
                if state.dosingType == .fixed {
                    fixedDosingView
                } else {
                    flexibleDosingView
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
        .onAppear {
            // Initialize based on current dosing type only if not already set
            if state.dosingType == .fixed {
                if !state.strengths.isEmpty && state.fixedDoseComponents.isEmpty {
                    state.updateFixedDoseComponent(strengthIndex: 0, quantity: 1)
                }
            } else {
                // Pre-populate flexible options from strengths if empty
                if state.doseOptions.isEmpty && !state.strengths.isEmpty {
                    for (index, _) in state.strengths.enumerated() {
                        let option = DoseOptionInput(components: [(strengthIndex: index, quantity: 1)])
                        state.addDoseOption(option)
                    }
                }
            }
        }
        .safeAreaInset(edge: .bottom) {
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
                        .foregroundStyle(state.canProceedFromStep(4) ? Color.white : Color.secondary)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(state.canProceedFromStep(4) ? Color.cyan : Color(.tertiarySystemFill))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .disabled(!state.canProceedFromStep(4))
            }
            .padding()
            .background(Color(.systemBackground))
        }
    }
    
    private var fixedDosingView: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Your Strengths")
                    .font(.headline)
                    .foregroundStyle(Color.primary)
                
                Text("Select the strength you take each time")
                    .font(.caption)
                    .foregroundStyle(Color.secondary)
            }
            .padding(.horizontal)
            
            // Grouped list of strengths
            VStack(spacing: 0) {
                ForEach(Array(state.strengths.enumerated()), id: \.offset) { index, strength in
                    let isSelected = state.getFixedDoseQuantity(for: index) > 0
                    
                    Button {
                        if !isSelected {
                            state.fixedDoseComponents.removeAll()
                            state.updateFixedDoseComponent(strengthIndex: index, quantity: 1)
                        }
                    } label: {
                        HStack {
                            // Radio button indicator
                            ZStack {
                                Circle()
                                    .fill(isSelected ? Color.cyan : Color.clear)
                                    .frame(width: 24, height: 24)
                                    .overlay(
                                        Circle()
                                            .stroke(isSelected ? Color.cyan : Color.secondary, lineWidth: 2)
                                    )
                                
                                if isSelected {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundStyle(Color.white)
                                }
                            }
                            
                            Text("\(Int(strength.value))\(strength.unit)")
                                .font(.body)
                                .foregroundStyle(Color.primary)
                            
                            Spacer()
                        }
                        .padding()
                        .contentShape(Rectangle())
                        .background(isSelected ? Color.cyan.opacity(0.1) : Color.clear)
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    // Add divider between items (not after last item)
                    if index < state.strengths.count - 1 {
                        Divider()
                            .padding(.leading, 56) // Align with text, after the circle indicator
                    }
                }
            }
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding(.horizontal)
            
            // Total summary (keep as separate card)
            if !state.fixedDoseComponents.isEmpty {
                HStack {
                    Text("Current dose:")
                        .font(.headline)
                        .foregroundStyle(Color.primary)
                    
                    Spacer()
                    
                    Text("\(Int(state.getFixedDoseTotal()))\(state.strengths.first?.unit ?? "mg")")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(.cyan)
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal)
            }
        }
    }
    
    private var flexibleDosingView: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Your Strengths")
                    .font(.headline)
                    .foregroundStyle(Color.primary)
                
                Text("Select all strengths you might take (you'll choose one when logging)")
                    .font(.caption)
                    .foregroundStyle(Color.secondary)
            }
            .padding(.horizontal)
            
            // Grouped list of strengths
            VStack(spacing: 0) {
                ForEach(Array(state.strengths.enumerated()), id: \.offset) { index, strength in
                    let isSelected = state.doseOptions.contains { option in
                        option.components.contains { $0.strengthIndex == index && $0.quantity > 0 }
                    }
                    
                    Button {
                        if isSelected {
                            state.doseOptions.removeAll { option in
                                option.components.count == 1 && 
                                option.components.first?.strengthIndex == index
                            }
                        } else {
                            let option = DoseOptionInput(components: [(strengthIndex: index, quantity: 1)])
                            state.addDoseOption(option)
                        }
                    } label: {
                        HStack {
                            // Checkbox indicator
                            ZStack {
                                Circle()
                                    .fill(isSelected ? Color.cyan : Color.clear)
                                    .frame(width: 24, height: 24)
                                    .overlay(
                                        Circle()
                                            .stroke(isSelected ? Color.cyan : Color.secondary, lineWidth: 2)
                                    )
                                
                                if isSelected {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundStyle(Color.white)
                                }
                            }
                            
                            Text("\(Int(strength.value))\(strength.unit)")
                                .font(.body)
                                .foregroundStyle(Color.primary)
                            
                            Spacer()
                        }
                        .padding()
                        .contentShape(Rectangle())
                        .background(isSelected ? Color.cyan.opacity(0.1) : Color.clear)
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    // Add divider between items (not after last item)
                    if index < state.strengths.count - 1 {
                        Divider()
                            .padding(.leading, 56)
                    }
                }
            }
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding(.horizontal)
            
            // Selected options summary
            if !state.doseOptions.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Options when logging:")
                        .font(.headline)
                        .foregroundStyle(Color.primary)
                    
                    FlowLayout(spacing: 8) {
                        ForEach(state.doseOptions, id: \.id) { option in
                            Text(option.displayName(strengths: state.strengths))
                                .font(.subheadline)
                                .foregroundStyle(Color.cyan)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.cyan.opacity(0.15))
                                .clipShape(Capsule())
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal)
            }
        }
    }
}

#Preview {
    NavigationStack {
        DosingTypeView(state: AddMedicationFlowState())
    }
}
