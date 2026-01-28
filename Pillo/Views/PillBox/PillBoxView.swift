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
    @Environment(SyncManager.self) private var syncManager
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
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color("appSurface01"))
            .toolbar(.hidden, for: .navigationBar)
            .onAppear {
                if viewModel == nil {
                    viewModel = PillBoxViewModel(modelContext: modelContext, syncManager: syncManager)
                }
            }
        }
    }
}

struct PillBoxContentView: View {
    @Bindable var viewModel: PillBoxViewModel
    @State private var showingAddMedication = false

    var body: some View {
        VStack(spacing: 0) {
            ScreenHeader(title: "Pill Box") {
                Button {
                    showingAddMedication = true
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 20, weight: .heavy))
                        .foregroundStyle(Color("appOnPrimary"))
                        .frame(width: 40, height: 40)
                        .background(Color("appPrimary"))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(.plain)
            }
            Text("My Medications")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(Color.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, AppSpacing.screenHorizontal)
                .padding(.top, 8)
                .padding(.bottom, 12)
            List {
                Section(header: EmptyView()) {
                    if viewModel.groupedMedications.isEmpty {
                        Text("No medications added yet")
                            .foregroundStyle(Color.secondary)
                            .listRowBackground(Color("appCardBG01"))
                    } else {
                        ForEach(viewModel.groupedMedications) { group in
                            NavigationLink(destination: MedicationGroupDetailView(
                                medicationGroup: group,
                                viewModel: viewModel
                            )) {
                                MedicationGroupRow(group: group, viewModel: viewModel)
                            }
                            .listRowBackground(Color("appCardBG01"))
                        }
                        .onDelete { indexSet in
                            for index in indexSet {
                                let group = viewModel.groupedMedications[index]
                                for medication in group.medications {
                                    viewModel.deleteMedication(medication)
                                }
                            }
                        }
                    }
                }

                let lowStockGroups = viewModel.groupedMedications.filter { $0.hasLowStock }
                if !lowStockGroups.isEmpty {
                    Section {
                        ForEach(lowStockGroups) { group in
                            HStack {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundStyle(Color.orange)
                                Text("\(group.name) is running low")
                            }
                            .listRowBackground(Color("appCardBG01"))
                        }
                    } header: {
                        Text("Low Stock Warnings")
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color("appSurface01"))
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
                    .foregroundStyle(Color.secondary)
            }
            
            // Schedule information
            let schedule = viewModel.formatSchedule(for: medication)
            if !schedule.isEmpty && schedule != "No schedule" {
                HStack(spacing: 4) {
                    Image(systemName: "clock")
                        .font(.caption2)
                        .foregroundStyle(Color.secondary)
                    Text(schedule)
                        .font(.caption)
                        .foregroundStyle(Color.secondary)
                }
            }
            
            // Stock information
            let stock = viewModel.getCurrentStock(for: medication)
            let unknownSources = medication.stockSources.filter { !$0.countingEnabled }.count
            
            HStack {
                if stock > 0 || unknownSources > 0 {
                    Text("\(stock) pills")
                        .font(.caption)
                        .foregroundStyle(Color.secondary)
                    
                    if unknownSources > 0 {
                        Text("•")
                            .font(.caption)
                            .foregroundStyle(Color.secondary)
                        Text("+ \(unknownSources) unknown")
                            .font(.caption)
                            .foregroundStyle(Color.orange)
                    }
                }
            }
        }
        .padding(.vertical, 4)
    }
}

struct MedicationGroupRow: View {
    let group: MedicationGroup_Display
    let viewModel: PillBoxViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            // Medication name
            Text(group.name)
                .font(.headline)
            
            // Strengths as chips
            HStack(spacing: 6) {
                ForEach(group.strengths, id: \.self) { strength in
                    Text(strength)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.cyan.opacity(0.15))
                        .clipShape(Capsule())
                }
            }
            
            // Schedule and stock info
            HStack {
                // Form
                Text(group.medications.first?.formDisplayName ?? group.form.rawValue.capitalized)
                    .font(.caption)
                    .foregroundStyle(Color.secondary)
                
                if group.totalStock > 0 {
                    Text("•")
                        .foregroundStyle(Color.secondary)
                    Text("\(group.totalStock) pills total")
                        .font(.caption)
                        .foregroundStyle(Color.secondary)
                }
                
                if group.hasLowStock {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.caption)
                        .foregroundStyle(Color.orange)
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
                    ForEach(MedicationForm.allCases.filter { $0 != .other }, id: \.self) { form in
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

