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
                    .foregroundStyle(.white)
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
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(state.canProceedFromStep(4) ? Color.cyan : Color.gray.opacity(0.3))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .disabled(!state.canProceedFromStep(4))
            .padding()
            .background(Color(red: 0.11, green: 0.11, blue: 0.12))
        }
    }
    
    private var fixedDosingView: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Dose builder for each strength
            ForEach(Array(state.strengths.enumerated()), id: \.offset) { index, strength in
                HStack {
                    Text("\(Int(strength.value))\(strength.unit)")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(width: 80, alignment: .leading)
                    
                    Spacer()
                    
                    Stepper("", value: Binding(
                        get: { state.getFixedDoseQuantity(for: index) },
                        set: { state.updateFixedDoseComponent(strengthIndex: index, quantity: $0) }
                    ), in: 0...10)
                    .labelsHidden()
                    
                    Text("\(state.getFixedDoseQuantity(for: index))")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(width: 30)
                }
                .padding()
                .background(Color(red: 0.17, green: 0.17, blue: 0.18))
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
                        .foregroundStyle(.white)
                    
                    Spacer()
                    
                    Text("\(Int(state.getFixedDoseTotal()))\(state.strengths.first?.unit ?? "mg")")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(.cyan)
                }
                .padding()
                .background(Color(red: 0.17, green: 0.17, blue: 0.18))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal)
            }
        }
    }
    
    private var flexibleDosingView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Dose Options")
                .font(.headline)
                .foregroundStyle(.white)
                .padding(.horizontal)
            
            if state.doseOptions.isEmpty {
                Text("Add dose options to choose from each day")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.6))
                    .padding(.horizontal)
            } else {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 12) {
                    ForEach(Array(state.doseOptions.enumerated()), id: \.element.id) { index, option in
                        HStack(spacing: 4) {
                            Text(option.displayName(strengths: state.strengths))
                                .font(.subheadline)
                                .foregroundStyle(.white)
                            
                            Button {
                                editingDoseOptionIndex = index
                                showingAddDoseSheet = true
                            } label: {
                                Image(systemName: "pencil.circle.fill")
                                    .foregroundStyle(.white.opacity(0.6))
                                    .font(.caption)
                            }
                            
                            Button {
                                state.removeDoseOption(at: index)
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
                        .foregroundStyle(.white)
                        .padding(.top, 20)
                    
                    // Dose builder for each strength
                    ForEach(Array(state.strengths.enumerated()), id: \.offset) { index, strength in
                        HStack {
                            Text("\(Int(strength.value))\(strength.unit)")
                                .font(.headline)
                                .foregroundStyle(.white)
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
                                .foregroundStyle(.white)
                                .frame(width: 30)
                        }
                        .padding()
                        .background(Color(red: 0.17, green: 0.17, blue: 0.18))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .padding(.horizontal)
                    
                    // Total
                    if !tempComponents.isEmpty {
                        Divider()
                            .background(Color.white.opacity(0.1))
                            .padding(.horizontal)
                        
                        HStack {
                            Text("Total:")
                                .font(.headline)
                                .foregroundStyle(.white)
                            
                            Spacer()
                            
                            let total = tempComponents.reduce(0) { total, comp in
                                guard comp.strengthIndex < state.strengths.count else { return total }
                                return total + (state.strengths[comp.strengthIndex].value * Double(comp.quantity))
                            }
                            let unit = state.strengths.first?.unit ?? "mg"
                            
                            Text("\(Int(total))\(unit)")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundStyle(.cyan)
                        }
                        .padding()
                        .background(Color(red: 0.17, green: 0.17, blue: 0.18))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .padding(.horizontal)
                    }
                }
            }
            .background(Color(red: 0.11, green: 0.11, blue: 0.12))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        onCancel()
                    }
                    .foregroundStyle(.white)
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
