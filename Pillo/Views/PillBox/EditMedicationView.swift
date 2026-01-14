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
    @State private var strength: String
    @State private var strengthUnit: String
    @State private var stockSources: [StockSource]
    @State private var showingAddStockSource = false
    
    init(medication: Medication, viewModel: PillBoxViewModel) {
        self.medication = medication
        self.viewModel = viewModel
        _name = State(initialValue: medication.name)
        _form = State(initialValue: medication.form)
        _strength = State(initialValue: medication.strength == Double(Int(medication.strength)) ? String(Int(medication.strength)) : String(medication.strength))
        _strengthUnit = State(initialValue: medication.strengthUnit)
        _stockSources = State(initialValue: medication.stockSources)
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
            .background(Color(red: 0.11, green: 0.11, blue: 0.12))
            .navigationTitle("Edit Medication")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundStyle(.white)
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveChanges()
                    }
                    .foregroundStyle(.cyan)
                    .disabled(name.isEmpty || strength.isEmpty)
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
                .foregroundStyle(.white)
            
            // Name
            VStack(alignment: .leading, spacing: 8) {
                Text("Medication Name")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.7))
                TextField("Enter name", text: $name)
                    .textFieldStyle(.plain)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(red: 0.17, green: 0.17, blue: 0.18))
                    )
                    .foregroundStyle(.white)
            }
            
            // Form
            VStack(alignment: .leading, spacing: 8) {
                Text("Form")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.7))
                Picker("Form", selection: $form) {
                    ForEach(MedicationForm.allCases, id: \.self) { formOption in
                        Text(formOption.rawValue.capitalized).tag(formOption)
                    }
                }
                .pickerStyle(.menu)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(red: 0.17, green: 0.17, blue: 0.18))
                )
                .foregroundStyle(.white)
            }
            
            // Strength
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Strength")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.7))
                    TextField("Enter strength", text: $strength)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(.plain)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color(red: 0.17, green: 0.17, blue: 0.18))
                        )
                        .foregroundStyle(.white)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Unit")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.7))
                    Picker("Unit", selection: $strengthUnit) {
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
                            .fill(Color(red: 0.17, green: 0.17, blue: 0.18))
                    )
                    .foregroundStyle(.white)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(red: 0.17, green: 0.17, blue: 0.18))
        )
    }
    
    // MARK: - Stock Sources Section
    
    private var stockSourcesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Stock Sources")
                    .font(.headline)
                    .foregroundStyle(.white)
                Spacer()
                Button {
                    showingAddStockSource = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .foregroundStyle(.cyan)
                        .font(.title3)
                }
            }
            
            if stockSources.isEmpty {
                Text("No stock sources added")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.7))
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
                .fill(Color(red: 0.17, green: 0.17, blue: 0.18))
        )
    }
    
    // MARK: - Methods
    
    private func loadStockSources() {
        stockSources = medication.stockSources
    }
    
    private func saveChanges() {
        // Update medication properties
        medication.name = name
        medication.form = form
        if let strengthValue = Double(strength) {
            medication.strength = strengthValue
        }
        medication.strengthUnit = strengthUnit
        
        // Save to model context
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
                    .foregroundStyle(.white)
                    .onChange(of: label) { oldValue, newValue in
                        source.label = newValue
                        saveChanges()
                    }
                
                Spacer()
                
                Button {
                    showingDeleteAlert = true
                } label: {
                    Image(systemName: "trash")
                        .foregroundStyle(.red)
                }
            }
            
            // Counting Toggle
            Toggle("Enable Counting", isOn: $countingEnabled)
                .foregroundStyle(.white)
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
                        .foregroundStyle(.white.opacity(0.7))
                    TextField("Enter quantity", text: $currentQuantity)
                        .keyboardType(.numberPad)
                        .textFieldStyle(.plain)
                        .padding(8)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color(red: 0.11, green: 0.11, blue: 0.12))
                        )
                        .foregroundStyle(.white)
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
                        .foregroundStyle(.white.opacity(0.7))
                    TextField("Enter threshold", text: $lowStockThreshold)
                        .keyboardType(.numberPad)
                        .textFieldStyle(.plain)
                        .padding(8)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color(red: 0.11, green: 0.11, blue: 0.12))
                        )
                        .foregroundStyle(.white)
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
                .foregroundStyle(.white)
                .onChange(of: expiryDate) { oldValue, newValue in
                    source.expiryDate = newValue
                    saveChanges()
                }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(red: 0.11, green: 0.11, blue: 0.12))
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
                            .foregroundStyle(.white.opacity(0.7))
                        TextField("e.g., Bottle 1, Refill", text: $label)
                            .textFieldStyle(.plain)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color(red: 0.17, green: 0.17, blue: 0.18))
                            )
                            .foregroundStyle(.white)
                    }
                    
                    // Counting Toggle
                    Toggle("Enable Counting", isOn: $countingEnabled)
                        .foregroundStyle(.white)
                    
                    if countingEnabled {
                        // Quantity
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Current Quantity")
                                .font(.subheadline)
                                .foregroundStyle(.white.opacity(0.7))
                            TextField("Enter quantity", text: $quantity)
                                .keyboardType(.numberPad)
                                .textFieldStyle(.plain)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color(red: 0.17, green: 0.17, blue: 0.18))
                                )
                                .foregroundStyle(.white)
                        }
                        
                        // Low Stock Threshold
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Low Stock Threshold")
                                .font(.subheadline)
                                .foregroundStyle(.white.opacity(0.7))
                            TextField("Enter threshold", text: $lowStockThreshold)
                                .keyboardType(.numberPad)
                                .textFieldStyle(.plain)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color(red: 0.17, green: 0.17, blue: 0.18))
                                )
                                .foregroundStyle(.white)
                        }
                    }
                    
                    // Expiry Date
                    Toggle("Set Expiry Date", isOn: $hasExpiryDate)
                        .foregroundStyle(.white)
                    
                    if hasExpiryDate {
                        DatePicker("Expiry Date", selection: Binding(
                            get: { expiryDate ?? Date() },
                            set: { expiryDate = $0 }
                        ), displayedComponents: .date)
                            .foregroundStyle(.white)
                    }
                }
                .padding()
            }
            .background(Color(red: 0.11, green: 0.11, blue: 0.12))
            .navigationTitle("Add Stock Source")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundStyle(.white)
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        addStockSource()
                    }
                    .foregroundStyle(.cyan)
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
