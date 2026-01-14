//
//  PillBoxView.swift
//  Pillo
//
//  Created by Chloe Lee on 2025-12-10.
//

import SwiftUI
import SwiftData

struct PillBoxView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: PillBoxViewModel?
    
    var body: some View {
        NavigationStack {
            Group {
                if let viewModel = viewModel {
                    PillBoxContentView(viewModel: viewModel)
                } else {
                    ProgressView("Loading...")
                }
            }
            .navigationTitle("Pill Box")
            .onAppear {
                if viewModel == nil {
                    viewModel = PillBoxViewModel(modelContext: modelContext)
                }
            }
        }
    }
}

struct PillBoxContentView: View {
    @Bindable var viewModel: PillBoxViewModel
    @State private var showingAddMedication = false
    
    var body: some View {
        List {
            // Medications Section
            Section("My Medications") {
                if viewModel.medications.isEmpty {
                    Text("No medications added yet")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(viewModel.medications) { medication in
                        NavigationLink(destination: MedicationDetailView(medication: medication, viewModel: viewModel)) {
                            MedicationRow(medication: medication, viewModel: viewModel)
                        }
                    }
                    .onDelete { indexSet in
                        for index in indexSet {
                            viewModel.deleteMedication(viewModel.medications[index])
                        }
                    }
                }
            }
            
            // Low Stock Warnings
            let lowStockMeds = viewModel.getLowStockMedications()
            if !lowStockMeds.isEmpty {
                Section {
                    ForEach(lowStockMeds) { medication in
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundStyle(.orange)
                            Text("\(medication.name) is running low")
                        }
                    }
                } header: {
                    Text("Low Stock Warnings")
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showingAddMedication = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showingAddMedication) {
            AddMedicationFlowView(viewModel: viewModel)
        }
        .refreshable {
            viewModel.loadData()
        }
    }
}

struct MedicationRow: View {
    let medication: Medication
    let viewModel: PillBoxViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(medication.name)
                    .font(.headline)
                Text("\(Int(medication.strength))\(medication.strengthUnit)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            // Schedule information
            let schedule = viewModel.formatSchedule(for: medication)
            if !schedule.isEmpty && schedule != "No schedule" {
                HStack(spacing: 4) {
                    Image(systemName: "clock")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    Text(schedule)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            // Stock information
            let stock = viewModel.getCurrentStock(for: medication)
            let unknownSources = medication.stockSources.filter { !$0.countingEnabled }.count
            
            HStack {
                if stock > 0 || unknownSources > 0 {
                    Text("\(stock) pills")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    if unknownSources > 0 {
                        Text("•")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text("+ \(unknownSources) unknown")
                            .font(.caption)
                            .foregroundStyle(.orange)
                    }
                }
            }
        }
        .padding(.vertical, 4)
    }
}

struct GroupRow: View {
    let group: MedicationGroup
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(group.name)
                .font(.headline)
            
            HStack {
                Text(group.timeFrame.rawValue.capitalized)
                Text("•")
                Text(group.selectionRule.rawValue.replacingOccurrences(of: "_", with: " ").capitalized)
            }
            .font(.caption)
            .foregroundStyle(.secondary)
            
            Text("\(group.doseConfigurations.count) doses")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }
}

// Placeholder views for adding medications and groups
struct AddMedicationView: View {
    let viewModel: PillBoxViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var name = ""
    @State private var form: MedicationForm = .tablet
    @State private var strength = ""
    @State private var strengthUnit = "mg"
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("Medication Name", text: $name)
                
                Picker("Form", selection: $form) {
                    ForEach(MedicationForm.allCases, id: \.self) { form in
                        Text(form.rawValue.capitalized).tag(form)
                    }
                }
                
                HStack {
                    TextField("Strength", text: $strength)
                        .keyboardType(.decimalPad)
                    
                    Picker("Unit", selection: $strengthUnit) {
                        Text("mg").tag("mg")
                        Text("mcg").tag("mcg")
                        Text("g").tag("g")
                        Text("ml").tag("ml")
                        Text("%").tag("%")
                    }
                }
            }
            .navigationTitle("Add Medication")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        if let strengthValue = Double(strength) {
                            _ = viewModel.addMedication(
                                name: name,
                                form: form,
                                strength: strengthValue,
                                strengthUnit: strengthUnit
                            )
                            dismiss()
                        }
                    }
                    .disabled(name.isEmpty || strength.isEmpty)
                }
            }
        }
    }
}

struct AddGroupView: View {
    let viewModel: PillBoxViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var name = ""
    @State private var selectionRule: SelectionRule = .exactlyOne
    @State private var timeFrame: TimeFrame = .morning
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("Group Name", text: $name)
                
                Picker("Selection Rule", selection: $selectionRule) {
                    Text("Exactly One").tag(SelectionRule.exactlyOne)
                    Text("At Least One").tag(SelectionRule.atLeastOne)
                    Text("Optional").tag(SelectionRule.optional)
                }
                
                Picker("Time Frame", selection: $timeFrame) {
                    ForEach(TimeFrame.allCases, id: \.self) { frame in
                        Text(frame.rawValue.capitalized).tag(frame)
                    }
                }
            }
            .navigationTitle("Add Group")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        _ = viewModel.addGroup(
                            name: name,
                            selectionRule: selectionRule,
                            timeFrame: timeFrame
                        )
                        dismiss()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
}

struct DoseConfigRow: View {
    let dose: DoseConfiguration
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(dose.displayName)
                .font(.headline)
            
            if let group = dose.group {
                Text(group.name)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            if !dose.components.isEmpty {
                let componentText = dose.components.compactMap { component -> String? in
                    guard let med = component.medication else { return nil }
                    return "\(med.name) ×\(component.quantity)"
                }.joined(separator: " + ")
                
                Text(componentText)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    PillBoxView()
        .modelContainer(for: [
            Medication.self,
            StockSource.self,
            MedicationGroup.self,
            DoseConfiguration.self,
            DoseComponent.self,
            IntakeLog.self,
            StockDeduction.self
        ])
}

