//
//  EditMedicationView.swift
//  Pillo
//
//  Created by Chloe Lee on 2025-12-10.
//

import SwiftUI
import SwiftData

struct EditMedicationView: View {
    let medication: Medication
    @Bindable var viewModel: PillBoxViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @State private var name: String
    @State private var form: MedicationForm
    @State private var strengths: [(value: Double, unit: String)] = []
    @State private var newStrengthValue: String = ""
    @State private var newStrengthUnit: String = "mg"
    @State private var stockSources: [StockSource]
    @State private var showingAddStockSource = false
    
    init(medication: Medication, viewModel: PillBoxViewModel) {
        self.medication = medication
        self.viewModel = viewModel
        _name = State(initialValue: medication.name)
        _form = State(initialValue: medication.form)
        _stockSources = State(initialValue: medication.stockSources)
        
        // Load ALL strengths for medications with the same name
        let relatedMedications = viewModel.medications.filter { $0.name == medication.name }
        let allStrengths = relatedMedications.map { (value: $0.strength, unit: $0.strengthUnit) }
        _strengths = State(initialValue: allStrengths.isEmpty ? [(value: medication.strength, unit: medication.strengthUnit)] : allStrengths)
        
        _newStrengthValue = State(initialValue: "")
        _newStrengthUnit = State(initialValue: "mg")
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Basic Information Section
                    basicInfoSection
                    
                    // Stock Sources Section
                    stockSourcesSection
                }
                .padding()
            }
            .navigationTitle("Edit Medication")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveChanges()
                    }
                    .foregroundStyle(Color.cyan)
                    .disabled(name.isEmpty || strengths.isEmpty)
                }
            }
            .sheet(isPresented: $showingAddStockSource) {
                AddStockSourceView(medication: medication, viewModel: viewModel) {
                    loadStockSources()
                }
            }
        }
    }
    
    // MARK: - Basic Information Section
    
    private var basicInfoSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Basic Information")
                .font(.headline)
                .foregroundStyle(Color.primary)
            
            // Name
            VStack(alignment: .leading, spacing: 8) {
                Text("Medication Name")
                    .font(.subheadline)
                    .foregroundStyle(Color.secondary)
                TextField("Enter name", text: $name)
                    .textFieldStyle(.plain)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(.tertiarySystemBackground))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color(.systemGray4), lineWidth: 1)
                    )
                    .foregroundStyle(Color.primary)
            }
            
            // Form
            VStack(alignment: .leading, spacing: 8) {
                Text("Form")
                    .font(.subheadline)
                    .foregroundStyle(Color.secondary)
                Picker("Form", selection: $form) {
                    ForEach(MedicationForm.allCases, id: \.self) { formOption in
                        Text(formOption.rawValue.capitalized).tag(formOption)
                    }
                }
                .pickerStyle(.menu)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(.tertiarySystemBackground))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color(.systemGray4), lineWidth: 1)
                )
            }
            
            // Strengths
            strengthsSection
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.secondarySystemBackground))
        )
    }
    
    // MARK: - Stock Sources Section
    
    private var stockSourcesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Stock Sources")
                    .font(.headline)
                    .foregroundStyle(Color.primary)
                Spacer()
                Button {
                    showingAddStockSource = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .foregroundStyle(Color.cyan)
                        .font(.title3)
                }
            }
            
            if stockSources.isEmpty {
                Text("No stock sources added")
                    .font(.subheadline)
                    .foregroundStyle(Color.secondary)
            } else {
                ForEach(stockSources) { source in
                    EditStockSourceRow(source: source, viewModel: viewModel) {
                        loadStockSources()
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.secondarySystemBackground))
        )
    }
    
    // MARK: - Strengths Section
    
    private var strengthsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Strengths")
                .font(.headline)
                .foregroundStyle(Color.primary)
            
            // List of existing strengths as chips
            if !strengths.isEmpty {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 8) {
                    ForEach(Array(strengths.enumerated()), id: \.offset) { index, strength in
                        HStack(spacing: 4) {
                            Text("\(Int(strength.value))\(strength.unit)")
                                .font(.subheadline)
                            
                            Button {
                                removeStrength(at: index)
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.caption)
                                    .foregroundStyle(Color.secondary)
                            }
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.cyan.opacity(0.2))
                        .clipShape(Capsule())
                    }
                }
            }
            
            // Add new strength row
            HStack(spacing: 12) {
                TextField("Strength", text: $newStrengthValue)
                    .keyboardType(.decimalPad)
                    .textFieldStyle(.plain)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(.tertiarySystemBackground))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color(.systemGray4), lineWidth: 1)
                    )
                
                Picker("Unit", selection: $newStrengthUnit) {
                    Text("mg").tag("mg")
                    Text("mcg").tag("mcg")
                    Text("g").tag("g")
                    Text("ml").tag("ml")
                    Text("%").tag("%")
                }
                .pickerStyle(.menu)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(.tertiarySystemBackground))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color(.systemGray4), lineWidth: 1)
                )
                
                Button {
                    addStrength()
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundStyle(Color.cyan)
                }
                .disabled(newStrengthValue.isEmpty)
            }
        }
    }
    
    // MARK: - Methods
    
    private func loadStockSources() {
        stockSources = medication.stockSources
    }
    
    private func addStrength() {
        guard let value = Double(newStrengthValue), value > 0 else { return }
        let newStrength = (value: value, unit: newStrengthUnit)
        if !strengths.contains(where: { $0.value == newStrength.value && $0.unit == newStrength.unit }) {
            strengths.append(newStrength)
            newStrengthValue = ""
        }
    }
    
    private func removeStrength(at index: Int) {
        guard strengths.count > 1 else { return } // Keep at least one
        
        let strengthToRemove = strengths[index]
        
        // Check if this strength belongs to a different medication (for future deletion handling)
        let hasSeparateMedication = viewModel.medications.contains { med in
            med.name == name &&
            med.strength == strengthToRemove.value &&
            med.strengthUnit == strengthToRemove.unit &&
            med.id != medication.id
        }
        
        if hasSeparateMedication {
            // TODO: Add confirmation dialog before deleting medications with dose configs
            // For now, just remove from the UI list
        }
        
        strengths.remove(at: index)
    }
    
    private func saveChanges() {
        // 1. Update the original medication with the first strength
        medication.name = name
        medication.form = form
        
        if let firstStrength = strengths.first {
            medication.strength = firstStrength.value
            medication.strengthUnit = firstStrength.unit
        }
        
        // 2. Find existing DoseConfigurations for this medication to copy settings from
        let existingDoseConfigs = medication.doseComponents.compactMap { $0.doseConfiguration }
        let existingGroup = existingDoseConfigs.first?.group
        let existingScheduleType = existingDoseConfigs.first?.scheduleType ?? .everyday
        let existingStartDate = existingDoseConfigs.first?.startDate ?? Date()
        let existingEndDate = existingDoseConfigs.first?.endDate
        
        // 3. For additional strengths, create Medication and optionally DoseConfiguration
        for i in 1..<strengths.count {
            let strength = strengths[i]
            
            // Check if a medication with this name and strength already exists
            let existingMedication = viewModel.medications.first { med in
                med.name == name &&
                med.strength == strength.value &&
                med.strengthUnit == strength.unit
            }
            
            if existingMedication == nil {
                // Create new Medication for this strength
                let newMed = viewModel.addMedication(
                    name: name,
                    form: form,
                    strength: strength.value,
                    strengthUnit: strength.unit
                )
                
                // If original medication has dose configurations, create one for the new strength too
                if let group = existingGroup {
                    let displayName = "\(Int(strength.value))\(strength.unit)"
                    _ = viewModel.addDoseConfiguration(
                        displayName: displayName,
                        components: [(medication: newMed, quantity: 1)],
                        group: group,
                        scheduleType: existingScheduleType,
                        startDate: existingStartDate,
                        endDate: existingEndDate
                    )
                }
            }
        }
        
        // 4. Save and reload
        try? modelContext.save()
        viewModel.loadData()
        dismiss()
    }
}

// MARK: - Edit Stock Source Row

struct EditStockSourceRow: View {
    let source: StockSource
    let viewModel: PillBoxViewModel
    let onUpdate: () -> Void
    @Environment(\.modelContext) private var modelContext
    
    @State private var label: String
    @State private var currentQuantity: String
    @State private var countingEnabled: Bool
    @State private var lowStockThreshold: String
    @State private var expiryDate: Date?
    @State private var showingDeleteAlert = false
    
    init(source: StockSource, viewModel: PillBoxViewModel, onUpdate: @escaping () -> Void) {
        self.source = source
        self.viewModel = viewModel
        self.onUpdate = onUpdate
        _label = State(initialValue: source.label)
        _currentQuantity = State(initialValue: source.currentQuantity.map { String($0) } ?? "")
        _countingEnabled = State(initialValue: source.countingEnabled)
        _lowStockThreshold = State(initialValue: String(source.lowStockThreshold))
        _expiryDate = State(initialValue: source.expiryDate)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                TextField("Label", text: $label)
                    .textFieldStyle(.plain)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.primary)
                    .onChange(of: label) { oldValue, newValue in
                        source.label = newValue
                        saveChanges()
                    }
                
                Spacer()
                
                Button {
                    showingDeleteAlert = true
                } label: {
                    Image(systemName: "trash")
                        .foregroundStyle(Color.red)
                }
            }
            
            // Counting Toggle
            Toggle("Enable Counting", isOn: $countingEnabled)
                .onChange(of: countingEnabled) { oldValue, newValue in
                    source.countingEnabled = newValue
                    if newValue && source.currentQuantity == nil {
                        source.currentQuantity = 0
                    }
                    saveChanges()
                }
            
            if countingEnabled {
                // Current Quantity
                VStack(alignment: .leading, spacing: 4) {
                    Text("Current Quantity")
                        .font(.caption)
                        .foregroundStyle(Color.secondary)
                    TextField("Enter quantity", text: $currentQuantity)
                        .keyboardType(.numberPad)
                        .textFieldStyle(.plain)
                        .padding(8)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color(.tertiarySystemBackground))
                        )
                        .foregroundStyle(Color.primary)
                        .onChange(of: currentQuantity) { oldValue, newValue in
                            if let qty = Int(newValue) {
                                source.currentQuantity = qty
                                saveChanges()
                            }
                        }
                }
                
                // Low Stock Threshold
                VStack(alignment: .leading, spacing: 4) {
                    Text("Low Stock Threshold")
                        .font(.caption)
                        .foregroundStyle(Color.secondary)
                    TextField("Enter threshold", text: $lowStockThreshold)
                        .keyboardType(.numberPad)
                        .textFieldStyle(.plain)
                        .padding(8)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color(.tertiarySystemBackground))
                        )
                        .foregroundStyle(Color.primary)
                        .onChange(of: lowStockThreshold) { oldValue, newValue in
                            if let threshold = Int(newValue) {
                                source.lowStockThreshold = threshold
                                saveChanges()
                            }
                        }
                }
            }
            
            // Expiry Date
            DatePicker("Expiry Date", selection: Binding(
                get: { expiryDate ?? Date() },
                set: { expiryDate = $0; source.expiryDate = $0; saveChanges() }
            ), displayedComponents: .date)
                .onChange(of: expiryDate) { oldValue, newValue in
                    source.expiryDate = newValue
                    saveChanges()
                }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(.tertiarySystemBackground))
        )
        .alert("Delete Stock Source", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                viewModel.deleteStockSource(source)
                onUpdate()
            }
        } message: {
            Text("Are you sure you want to delete this stock source?")
        }
    }
    
    private func saveChanges() {
        try? modelContext.save()
    }
}

// MARK: - Add Stock Source View

struct AddStockSourceView: View {
    let medication: Medication
    let viewModel: PillBoxViewModel
    let onDismiss: () -> Void
    @Environment(\.dismiss) private var dismiss
    
    @State private var label = ""
    @State private var quantity = ""
    @State private var countingEnabled = false
    @State private var lowStockThreshold = "10"
    @State private var expiryDate: Date?
    @State private var hasExpiryDate = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Label
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Label")
                            .font(.subheadline)
                            .foregroundStyle(Color.secondary)
                        TextField("e.g., Bottle 1, Refill", text: $label)
                            .textFieldStyle(.plain)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color(.tertiarySystemBackground))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color(.systemGray4), lineWidth: 1)
                            )
                            .foregroundStyle(Color.primary)
                    }
                    
                    // Counting Toggle
                    Toggle("Enable Counting", isOn: $countingEnabled)
                    
                    if countingEnabled {
                        // Quantity
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Current Quantity")
                                .font(.subheadline)
                                .foregroundStyle(Color.secondary)
                            TextField("Enter quantity", text: $quantity)
                                .keyboardType(.numberPad)
                                .textFieldStyle(.plain)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color(.tertiarySystemBackground))
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color(.systemGray4), lineWidth: 1)
                                )
                                .foregroundStyle(Color.primary)
                        }
                        
                        // Low Stock Threshold
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Low Stock Threshold")
                                .font(.subheadline)
                                .foregroundStyle(Color.secondary)
                            TextField("Enter threshold", text: $lowStockThreshold)
                                .keyboardType(.numberPad)
                                .textFieldStyle(.plain)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color(.tertiarySystemBackground))
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color(.systemGray4), lineWidth: 1)
                                )
                                .foregroundStyle(Color.primary)
                        }
                    }
                    
                    // Expiry Date
                    Toggle("Set Expiry Date", isOn: $hasExpiryDate)
                    
                    if hasExpiryDate {
                        DatePicker("Expiry Date", selection: Binding(
                            get: { expiryDate ?? Date() },
                            set: { expiryDate = $0 }
                        ), displayedComponents: .date)
                    }
                }
                .padding()
            }
            .navigationTitle("Add Stock Source")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        addStockSource()
                    }
                    .foregroundStyle(Color.cyan)
                    .disabled(label.isEmpty)
                }
            }
        }
    }
    
    private func addStockSource() {
        let quantityValue = countingEnabled ? Int(quantity) : nil
        let thresholdValue = Int(lowStockThreshold) ?? 10
        
        viewModel.addStockSource(
            to: medication,
            label: label,
            quantity: quantityValue,
            countingEnabled: countingEnabled,
            lowStockThreshold: thresholdValue,
            expiryDate: hasExpiryDate ? expiryDate : nil
        )
        
        onDismiss()
        dismiss()
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Medication.self, configurations: config)
    let context = container.mainContext
    let viewModel = PillBoxViewModel(modelContext: context)
    
    let medication = Medication(
        name: "Sample Medication",
        form: .tablet,
        strength: 50,
        strengthUnit: "mg"
    )
    
    return EditMedicationView(medication: medication, viewModel: viewModel)
}
