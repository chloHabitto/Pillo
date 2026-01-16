//
//  MedicationGroupDetailView.swift
//  Pillo
//
//  Created by Chloe Lee on 2025-12-10.
//

import SwiftUI
import SwiftData

struct MedicationGroupDetailView: View {
    let medicationGroup: MedicationGroup_Display
    @Bindable var viewModel: PillBoxViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var showingEditSheet = false
    @State private var showingDeleteAlert = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                headerSection
                
                // Strengths Section
                strengthsSection
                
                // Stock Section
                stockSection
                
                // Dose Configurations Section
                doseConfigurationsSection
                
                // Delete Button
                deleteButton
            }
            .padding()
        }
        .navigationTitle(medicationGroup.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Edit") {
                    showingEditSheet = true
                }
                .foregroundStyle(Color.cyan)
            }
        }
        .sheet(isPresented: $showingEditSheet) {
            // Edit the first medication (name/form), with all strengths
            if let firstMed = medicationGroup.medications.first {
                EditMedicationView(medication: firstMed, viewModel: viewModel)
            }
        }
        .alert("Delete Medication", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                for medication in medicationGroup.medications {
                    viewModel.deleteMedication(medication)
                }
                dismiss()
            }
        } message: {
            Text("Are you sure you want to delete \(medicationGroup.name) and all its strengths? This action cannot be undone.")
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 16) {
            Image(systemName: "pills.fill")
                .font(.system(size: 60))
                .foregroundStyle(Color.cyan)
            
            Text(medicationGroup.name)
                .font(.system(size: 28, weight: .bold))
            
            Text(medicationGroup.medications.first?.formDisplayName ?? medicationGroup.form.rawValue.capitalized)
                .font(.subheadline)
                .foregroundStyle(Color.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.secondarySystemBackground))
        )
    }
    
    // MARK: - Strengths Section
    private var strengthsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "chart.bar.fill")
                    .foregroundStyle(Color.cyan)
                Text("Strengths")
                    .font(.headline)
            }
            
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))], spacing: 8) {
                ForEach(medicationGroup.medications, id: \.id) { medication in
                    VStack(spacing: 4) {
                        Text("\(Int(medication.strength))\(medication.strengthUnit)")
                            .font(.headline)
                            .foregroundStyle(Color.cyan)
                        
                        // Stock for this strength
                        let stock = medication.stockSources
                            .filter { $0.countingEnabled }
                            .reduce(0) { $0 + ($1.currentQuantity ?? 0) }
                        
                        if stock > 0 {
                            Text("\(stock) pills")
                                .font(.caption)
                                .foregroundStyle(Color.secondary)
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(.tertiarySystemBackground))
                    )
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
    
    // MARK: - Stock Section
    private var stockSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "archivebox.fill")
                    .foregroundStyle(Color.cyan)
                Text("Stock Sources")
                    .font(.headline)
            }
            
            let allSources = medicationGroup.medications.flatMap { med in
                med.stockSources.map { (medication: med, source: $0) }
            }
            
            if allSources.isEmpty {
                Text("No stock sources added")
                    .font(.subheadline)
                    .foregroundStyle(Color.secondary)
            } else {
                ForEach(allSources, id: \.source.id) { item in
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("\(Int(item.medication.strength))\(item.medication.strengthUnit) - \(item.source.label)")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            if item.source.countingEnabled, let qty = item.source.currentQuantity {
                                Text("\(qty) pills")
                                    .font(.caption)
                                    .foregroundStyle(Color.secondary)
                            }
                        }
                        
                        Spacer()
                        
                        if item.source.countingEnabled,
                           let qty = item.source.currentQuantity,
                           qty <= item.source.lowStockThreshold {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundStyle(Color.orange)
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(.tertiarySystemBackground))
                    )
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
    
    // MARK: - Dose Configurations Section
    
    private var uniqueDoseConfigurations: [DoseConfiguration] {
        var seenIDs: Set<UUID> = []
        var uniqueConfigs: [DoseConfiguration] = []
        
        for med in medicationGroup.medications {
            for component in med.doseComponents {
                if let config = component.doseConfiguration,
                   !seenIDs.contains(config.id) {
                    seenIDs.insert(config.id)
                    uniqueConfigs.append(config)
                }
            }
        }
        
        return uniqueConfigs
    }
    
    private var doseConfigurationsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "list.bullet.rectangle.fill")
                    .foregroundStyle(Color.cyan)
                Text("Dose Configurations")
                    .font(.headline)
            }
            
            let doseConfigs = uniqueDoseConfigurations
            
            if doseConfigs.isEmpty {
                Text("Not used in any dose configurations")
                    .font(.subheadline)
                    .foregroundStyle(Color.secondary)
            } else {
                ForEach(doseConfigs, id: \.id) { config in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(config.displayName)
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        if let group = config.group {
                            Text(group.name)
                                .font(.caption)
                                .foregroundStyle(Color.secondary)
                        }
                        
                        // Show component breakdown
                        let breakdown = config.components.compactMap { comp -> String? in
                            guard let med = comp.medication else { return nil }
                            return "\(Int(med.strength))\(med.strengthUnit) × \(comp.quantity)"
                        }.joined(separator: " + ")
                        
                        if !breakdown.isEmpty {
                            Text(breakdown)
                                .font(.caption)
                                .foregroundStyle(Color.secondary)
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(.tertiarySystemBackground))
                    )
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
    
    // MARK: - Delete Button
    private var deleteButton: some View {
        Button {
            showingDeleteAlert = true
        } label: {
            HStack {
                Image(systemName: "trash.fill")
                Text("Delete Medication")
            }
            .font(.headline)
            .foregroundStyle(Color.red)
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.red.opacity(0.1))
            )
        }
    }
}
