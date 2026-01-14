//
//  MedicationDetailView.swift
//  Pillo
//
//  Created by Chloe Lee on 2025-12-10.
//

import SwiftUI
import SwiftData

struct MedicationDetailView: View {
    let medication: Medication
    @Bindable var viewModel: PillBoxViewModel
    @State private var showingEditSheet = false
    @State private var showingDeleteAlert = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header Section
                headerSection
                
                // Schedule Section
                scheduleSection
                
                // Stock Section
                stockSection
                
                // Dose Configurations Section
                doseConfigurationsSection
                
                // Delete Button
                deleteButton
            }
            .padding()
        }
        .background(Color(red: 0.11, green: 0.11, blue: 0.12))
        .navigationTitle(medication.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showingEditSheet = true
                } label: {
                    Text("Edit")
                        .foregroundStyle(.cyan)
                }
            }
        }
        .sheet(isPresented: $showingEditSheet) {
            EditMedicationView(medication: medication, viewModel: viewModel)
        }
        .alert("Delete Medication", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                viewModel.deleteMedication(medication)
                dismiss()
            }
        } message: {
            Text("Are you sure you want to delete \(medication.name)? This action cannot be undone.")
        }
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            // Pill Icon/Preview
            pillIcon
                .frame(width: 120, height: 120)
            
            // Medication Name
            Text(medication.name)
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(.white)
            
            // Form and Strength
            Text("\(medication.form.rawValue.capitalized), \(Int(medication.strength))\(medication.strengthUnit)")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(red: 0.17, green: 0.17, blue: 0.18))
        )
    }
    
    private var pillIcon: some View {
        Image(systemName: "pills.fill")
            .font(.system(size: 60))
            .foregroundStyle(.cyan)
    }
    
    // MARK: - Schedule Section
    
    private var scheduleSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "clock.fill")
                    .foregroundStyle(.cyan)
                Text("Schedule")
                    .font(.headline)
                    .foregroundStyle(.white)
            }
            
            let scheduleInfo = viewModel.getScheduleInfo(for: medication)
            
            if scheduleInfo.timeFrames.isEmpty && scheduleInfo.times.isEmpty {
                Text("No schedule set")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.7))
            } else {
                // Time Frames
                if !scheduleInfo.timeFrames.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Time Frames")
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.7))
                        
                        HStack(spacing: 8) {
                            ForEach(scheduleInfo.timeFrames, id: \.self) { timeFrame in
                                Text(timeFrame.rawValue.capitalized)
                                    .font(.caption)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(
                                        Capsule()
                                            .fill(Color.cyan.opacity(0.2))
                                    )
                                    .foregroundStyle(.cyan)
                            }
                        }
                    }
                }
                
                // Reminder Times
                if !scheduleInfo.times.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Reminder Times")
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.7))
                        
                        ForEach(scheduleInfo.times, id: \.self) { time in
                            HStack {
                                Image(systemName: "bell.fill")
                                    .font(.caption)
                                    .foregroundStyle(.cyan)
                                Text(formatTime(time))
                                    .font(.subheadline)
                                    .foregroundStyle(.white)
                            }
                        }
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
    
    // MARK: - Stock Section
    
    private var stockSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "archivebox.fill")
                    .foregroundStyle(.cyan)
                Text("Stock")
                    .font(.headline)
                    .foregroundStyle(.white)
            }
            
            if medication.stockSources.isEmpty {
                Text("No stock sources added")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.7))
            } else {
                // Total Countable Stock
                let totalStock = viewModel.getCurrentStock(for: medication)
                if totalStock > 0 {
                    HStack {
                        Text("Total Stock:")
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.7))
                        Text("\(totalStock) pills")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(.white)
                    }
                    .padding(.bottom, 8)
                }
                
                // Stock Sources List
                ForEach(medication.stockSources) { source in
                    stockSourceRow(source)
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
    
    private func stockSourceRow(_ source: StockSource) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(source.label)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                
                Spacer()
                
                // Low Stock Warning
                if source.countingEnabled,
                   let currentQty = source.currentQuantity,
                   currentQty <= source.lowStockThreshold {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundStyle(.orange)
                        .font(.caption)
                }
            }
            
            // Quantity
            if source.countingEnabled, let currentQty = source.currentQuantity {
                HStack {
                    Text("Quantity:")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.7))
                    Text("\(currentQty) pills")
                        .font(.caption)
                        .foregroundStyle(.white)
                }
            } else {
                Text("Counting not enabled")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.7))
            }
            
            // Low Stock Threshold
            if source.countingEnabled {
                HStack {
                    Text("Low Stock Threshold:")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.7))
                    Text("\(source.lowStockThreshold) pills")
                        .font(.caption)
                        .foregroundStyle(.white)
                }
            }
            
            // Expiry Date
            if let expiryDate = source.expiryDate {
                HStack {
                    Text("Expiry Date:")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.7))
                    Text(formatDate(expiryDate))
                        .font(.caption)
                        .foregroundStyle(expiryDate < Date() ? .red : .white)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(red: 0.11, green: 0.11, blue: 0.12))
        )
    }
    
    // MARK: - Dose Configurations Section
    
    private var doseConfigurationsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "list.bullet.rectangle.fill")
                    .foregroundStyle(.cyan)
                Text("Dose Configurations")
                    .font(.headline)
                    .foregroundStyle(.white)
            }
            
            // Get unique dose configurations (a medication can appear multiple times in the same config)
            var seenIDs: Set<UUID> = []
            let doseConfigs = medication.doseComponents.compactMap { component -> DoseConfiguration? in
                guard let config = component.doseConfiguration,
                      !seenIDs.contains(config.id) else {
                    return nil
                }
                seenIDs.insert(config.id)
                return config
            }
            
            if doseConfigs.isEmpty {
                Text("Not used in any dose configurations")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.7))
            } else {
                ForEach(doseConfigs) { config in
                    doseConfigurationRow(config)
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
    
    private func doseConfigurationRow(_ config: DoseConfiguration) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(config.displayName)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(.white)
            
            if let group = config.group {
                Text(group.name)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.7))
            }
            
            // Find the quantity for this medication in this dose config
            if let component = config.components.first(where: { $0.medication?.id == medication.id }) {
                Text("Quantity: \(component.quantity)")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.7))
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(red: 0.11, green: 0.11, blue: 0.12))
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
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.red.opacity(0.3))
            )
        }
        .padding(.bottom, 20)
    }
    
    // MARK: - Helper Methods
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
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
    
    return NavigationStack {
        MedicationDetailView(medication: medication, viewModel: viewModel)
    }
}
