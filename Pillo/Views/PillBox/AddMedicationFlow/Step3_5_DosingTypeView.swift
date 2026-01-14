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
    @State private var showingAddDoseSheet = false
    @State private var editingDoseOptionIndex: Int?
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Title
                Text("How do you dose?")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(Color.primary)
                    .padding(.top, 20)
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
                    } else {
                        state.fixedDoseComponents.removeAll()
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
                        Text(form.rawValue.capitalized)
                            .font(.caption)
                            .foregroundStyle(Color.secondary)
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
        .sheet(isPresented: $showingAddDoseSheet) {
            AddDoseSheet(
                state: state,
                editingOption: editingDoseOptionIndex != nil ? state.doseOptions[editingDoseOptionIndex!] : nil,
                onSave: { option in
                    if let index = editingDoseOptionIndex {
                        state.doseOptions[index] = option
                    } else {
                        state.addDoseOption(option)
                    }
                    editingDoseOptionIndex = nil
                    showingAddDoseSheet = false
                },
                onCancel: {
                    editingDoseOptionIndex = nil
                    showingAddDoseSheet = false
                }
            )
        }
        .safeAreaInset(edge: .bottom) {
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
            .padding()
            .background(Color(.systemBackground))
        }
    }
    
    private var fixedDosingView: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Dose builder for each strength
            ForEach(Array(state.strengths.enumerated()), id: \.offset) { index, strength in
                HStack {
                    Text("\(Int(strength.value))\(strength.unit)")
                        .font(.headline)
                        .foregroundStyle(Color.primary)
                        .frame(width: 80, alignment: .leading)
                    
                    Spacer()
                    
                    Stepper("", value: Binding(
                        get: { state.getFixedDoseQuantity(for: index) },
                        set: { state.updateFixedDoseComponent(strengthIndex: index, quantity: $0) }
                    ), in: 0...10)
                    .labelsHidden()
                    
                    Text("\(state.getFixedDoseQuantity(for: index))")
                        .font(.headline)
                        .foregroundStyle(Color.primary)
                        .frame(width: 30)
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(.horizontal)
            
            // Total
            if !state.fixedDoseComponents.isEmpty {
                Divider()
                    .background(Color.white.opacity(0.1))
                    .padding(.horizontal)
                
                HStack {
                    Text("Total:")
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
            Text("Dose Options")
                .font(.headline)
                .foregroundStyle(Color.primary)
                .padding(.horizontal)
            
            if state.doseOptions.isEmpty {
                Text("Add dose options to choose from each day")
                    .font(.subheadline)
                    .foregroundStyle(Color.secondary)
                    .padding(.horizontal)
            } else {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 12) {
                    ForEach(Array(state.doseOptions.enumerated()), id: \.element.id) { index, option in
                        HStack(spacing: 4) {
                            Text(option.displayName(strengths: state.strengths))
                                .font(.subheadline)
                                .foregroundStyle(Color.primary)
                            
                            Button {
                                editingDoseOptionIndex = index
                                showingAddDoseSheet = true
                            } label: {
                                Image(systemName: "pencil.circle.fill")
                                    .foregroundStyle(Color.secondary)
                                    .font(.caption)
                            }
                            
                            Button {
                                state.removeDoseOption(at: index)
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
            
            Button {
                editingDoseOptionIndex = nil
                showingAddDoseSheet = true
            } label: {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Add Dose Option")
                }
                .font(.headline)
                .foregroundStyle(.cyan)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.cyan.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(.horizontal)
        }
    }
}

struct AddDoseSheet: View {
    @Bindable var state: AddMedicationFlowState
    let editingOption: DoseOptionInput?
    let onSave: (DoseOptionInput) -> Void
    let onCancel: () -> Void
    
    @State private var tempComponents: [(strengthIndex: Int, quantity: Int)] = []
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    Text(editingOption == nil ? "Add Dose Option" : "Edit Dose Option")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(Color.primary)
                        .padding(.top, 20)
                    
                    // Dose builder for each strength
                    ForEach(Array(state.strengths.enumerated()), id: \.offset) { index, strength in
                        HStack {
                            Text("\(Int(strength.value))\(strength.unit)")
                                .font(.headline)
                                .foregroundStyle(Color.primary)
                                .frame(width: 80, alignment: .leading)
                            
                            Spacer()
                            
                            Stepper("", value: Binding(
                                get: { tempComponents.first(where: { $0.strengthIndex == index })?.quantity ?? 0 },
                                set: { newValue in
                                    if let existingIndex = tempComponents.firstIndex(where: { $0.strengthIndex == index }) {
                                        if newValue > 0 {
                                            tempComponents[existingIndex] = (strengthIndex: index, quantity: newValue)
                                        } else {
                                            tempComponents.remove(at: existingIndex)
                                        }
                                    } else if newValue > 0 {
                                        tempComponents.append((strengthIndex: index, quantity: newValue))
                                    }
                                }
                            ), in: 0...10)
                            .labelsHidden()
                            
                            Text("\(tempComponents.first(where: { $0.strengthIndex == index })?.quantity ?? 0)")
                                .font(.headline)
                                .foregroundStyle(Color.primary)
                                .frame(width: 30)
                        }
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .padding(.horizontal)
                    
                    // Total
                    if !tempComponents.isEmpty {
                        Divider()
                            .background(Color(.separator))
                            .padding(.horizontal)
                        
                        HStack {
                            Text("Total:")
                                .font(.headline)
                                .foregroundStyle(Color.primary)
                            
                            Spacer()
                            
                            let total = tempComponents.reduce(0) { total, comp in
                                guard comp.strengthIndex < state.strengths.count else { return total }
                                return total + (state.strengths[comp.strengthIndex].value * Double(comp.quantity))
                            }
                            let unit = state.strengths.first?.unit ?? "mg"
                            
                            Text("\(Int(total))\(unit)")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundStyle(Color.cyan)
                        }
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .padding(.horizontal)
                    }
                }
            }
            .background(Color(.systemBackground))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        onCancel()
                    }
                    .foregroundStyle(Color.primary)
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        let existingId = editingOption?.id ?? UUID()
                        let option = DoseOptionInput(id: existingId, components: tempComponents.filter { $0.quantity > 0 })
                        onSave(option)
                    }
                    .foregroundStyle(.cyan)
                    .disabled(tempComponents.isEmpty || !tempComponents.contains { $0.quantity > 0 })
                }
            }
        }
        .presentationDetents([.medium, .large])
        .onAppear {
            if let editing = editingOption {
                tempComponents = editing.components
            } else {
                tempComponents = []
            }
        }
    }
}

#Preview {
    NavigationStack {
        DosingTypeView(state: AddMedicationFlowState())
    }
}
