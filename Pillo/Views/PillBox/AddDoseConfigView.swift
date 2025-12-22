//
//  AddDoseConfigView.swift
//  Pillo
//
//  Created by Chloe Lee on 2025-12-10.
//

import SwiftUI
import SwiftData

struct AddDoseConfigView: View {
    let viewModel: PillBoxViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var displayName = ""
    @State private var selectedGroup: MedicationGroup?
    @State private var components: [DoseComponentInput] = []
    @State private var showingAddComponent = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Dose Name") {
                    TextField("e.g., 72mg or Morning dose", text: $displayName)
                }
                
                Section("Assign to Group") {
                    if viewModel.groups.isEmpty {
                        Text("Create a group first in Pill Box")
                            .foregroundStyle(.secondary)
                    } else {
                        Picker("Group", selection: $selectedGroup) {
                            Text("None").tag(nil as MedicationGroup?)
                            ForEach(viewModel.groups) { group in
                                Text("\(group.name) (\(group.timeFrame.rawValue.capitalized))")
                                    .tag(group as MedicationGroup?)
                            }
                        }
                    }
                }
                
                Section {
                    if components.isEmpty {
                        Text("Add at least one medication")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(Array(components.enumerated()), id: \.element.id) { index, component in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(component.medication.name)
                                        .font(.body)
                                    Text("\(Int(component.medication.strength))\(component.medication.strengthUnit)")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                
                                Spacer()
                                
                                HStack {
                                    Button {
                                        if components[index].quantity > 1 {
                                            components[index].quantity -= 1
                                        }
                                    } label: {
                                        Image(systemName: "minus.circle")
                                    }
                                    .buttonStyle(.borderless)
                                    
                                    Text("×\(components[index].quantity)")
                                        .frame(minWidth: 30)
                                    
                                    Button {
                                        components[index].quantity += 1
                                    } label: {
                                        Image(systemName: "plus.circle")
                                    }
                                    .buttonStyle(.borderless)
                                }
                            }
                        }
                        .onDelete { indexSet in
                            components.remove(atOffsets: indexSet)
                        }
                    }
                    
                    Button {
                        showingAddComponent = true
                    } label: {
                        Label("Add Medication", systemImage: "plus")
                    }
                    .disabled(viewModel.medications.isEmpty)
                } header: {
                    Text("Medications in this Dose")
                } footer: {
                    if !components.isEmpty {
                        let total = components.map { "\(Int($0.medication.strength))\($0.medication.strengthUnit) ×\($0.quantity)" }.joined(separator: " + ")
                        Text("Total: \(total)")
                    }
                }
            }
            .navigationTitle("Add Dose")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        saveDoseConfig()
                        dismiss()
                    }
                    .disabled(!canSave)
                }
            }
            .sheet(isPresented: $showingAddComponent) {
                SelectMedicationSheet(
                    medications: viewModel.medications,
                    existingComponents: components,
                    onSelect: { medication in
                        components.append(DoseComponentInput(medication: medication, quantity: 1))
                    }
                )
            }
        }
    }
    
    private var canSave: Bool {
        !displayName.isEmpty && !components.isEmpty
    }
    
    private func saveDoseConfig() {
        let componentTuples = components.map { (medication: $0.medication, quantity: $0.quantity) }
        _ = viewModel.addDoseConfiguration(
            displayName: displayName,
            components: componentTuples,
            group: selectedGroup
        )
    }
}

struct DoseComponentInput: Identifiable {
    let id = UUID()
    var medication: Medication
    var quantity: Int
}

struct SelectMedicationSheet: View {
    let medications: [Medication]
    let existingComponents: [DoseComponentInput]
    let onSelect: (Medication) -> Void
    @Environment(\.dismiss) private var dismiss
    
    private var availableMedications: [Medication] {
        let existingIds = Set(existingComponents.map { $0.medication.id })
        return medications.filter { !existingIds.contains($0.id) }
    }
    
    var body: some View {
        NavigationStack {
            List {
                if availableMedications.isEmpty {
                    Text("All medications already added")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(Array(availableMedications.enumerated()), id: \.element.id) { index, medication in
                        Button {
                            onSelect(medication)
                            dismiss()
                        } label: {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(medication.name)
                                        .font(.body)
                                        .foregroundStyle(.primary)
                                    Text("\(Int(medication.strength))\(medication.strengthUnit) • \(medication.form.rawValue.capitalized)")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                Image(systemName: "plus.circle")
                                    .foregroundStyle(.accentColor)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Select Medication")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}
