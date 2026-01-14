//
//  TodayView.swift
//  Pillo
//
//  Created by Chloe Lee on 2025-12-10.
//

import SwiftUI
import SwiftData

struct TodayView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: TodayViewModel?
    
    var body: some View {
        NavigationStack {
            Group {
                if let viewModel = viewModel {
                    TodayContentView(viewModel: viewModel)
                } else {
                    ProgressView("Loading...")
                }
            }
            .navigationTitle("Today")
            .onAppear {
                if viewModel == nil {
                    viewModel = TodayViewModel(modelContext: modelContext)
                } else {
                    // Reload plan when view appears to catch newly added medications
                    viewModel?.loadPlan()
                }
            }
        }
    }
}

struct TodayContentView: View {
    @Bindable var viewModel: TodayViewModel
    @State private var showingConfirmation = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Weekly calendar at the top
            WeeklyCalendarView(selectedDate: Binding(
                get: { viewModel.selectedDate },
                set: { viewModel.changeDate(to: $0) }
            ))
            .padding(.top, 8)
            .padding(.bottom, 16)
            
            // Main content
            ScrollView {
                VStack(spacing: 20) {
                    if viewModel.dailyPlan.timeFrames.isEmpty {
                        // Empty state
                        ContentUnavailableView(
                            "No Medications",
                            systemImage: "pills",
                            description: Text("Add medications in the Pill Box tab to get started.")
                        )
                    } else {
                        // Time frame sections
                        ForEach(viewModel.dailyPlan.timeFrames) { timeFrame in
                            TimeFrameSection(
                                timeFrame: timeFrame,
                                viewModel: viewModel
                            )
                        }
                    }
                    
                    Spacer(minLength: 80)
                }
                .padding(.horizontal)
            }
        }
        .overlay(alignment: .bottom) {
            if !viewModel.selectedDoses.isEmpty {
                Button {
                    showingConfirmation = true
                } label: {
                    Text("Log Selected as Taken")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor)
                        .foregroundStyle(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding()
                .background(.ultraThinMaterial)
            }
        }
        .confirmationDialog("Confirm Intake", isPresented: $showingConfirmation) {
            Button("Log & Deduct Stock") {
                viewModel.logSelectedIntakes(deductStock: true)
            }
            Button("Log Without Deducting") {
                viewModel.logSelectedIntakes(deductStock: false)
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("How would you like to log this intake?")
        }
        .refreshable {
            viewModel.loadPlan()
        }
        .onAppear {
            // Reload plan when content view appears to ensure fresh data
            viewModel.loadPlan()
        }
    }
}

struct TimeFrameSection: View {
    let timeFrame: TimeFramePlan
    @Bindable var viewModel: TodayViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Text(timeFrame.timeFrame.rawValue.capitalized)
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Spacer()
                
                if timeFrame.isComplete {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(Color.green)
                }
            }
            
            // Groups
            ForEach(timeFrame.groups) { group in
                GroupCard(group: group, viewModel: viewModel)
            }
        }
    }
}

struct GroupCard: View {
    let group: GroupPlan
    @Bindable var viewModel: TodayViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Show medication name (extract from first option's first component)
            if let firstMed = group.doseOptions.first?.components.first?.medication {
                Text(firstMed.name)
                    .font(.headline)
            }
            
            if group.doseOptions.count > 1 {
                // Multiple options: show compact chips
                CompactDoseSelector(
                    options: group.doseOptions,
                    selectedId: viewModel.selectedDoses[group.group.id]?.id,
                    isCompleted: group.completedDose != nil,
                    onSelect: { dose in
                        viewModel.selectDose(dose, for: group.group)
                    }
                )
            } else if let singleOption = group.doseOptions.first {
                // Single option: just show the dose
                HStack {
                    Text(singleOption.doseConfig.displayName)
                        .font(.subheadline)
                        .foregroundStyle(Color.secondary)
                    
                    Spacer()
                    
                    if singleOption.hasLowStock {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundStyle(Color.orange)
                            .font(.caption)
                    }
                }
            }
            
            // Checkbox on the right
            HStack {
                Spacer()
                
                if let completed = group.completedDose {
                    // Already logged
                    Label(completed.displayName, systemImage: "checkmark.circle.fill")
                        .foregroundStyle(Color.green)
                        .font(.caption)
                } else {
                    // Checkbox to log
                    Button {
                        // Log the selected dose (or first option if single)
                        if let selectedDose = viewModel.selectedDoses[group.group.id] {
                            viewModel.logSingleIntake(dose: selectedDose, deductStock: true)
                        } else if group.doseOptions.count == 1, let singleDose = group.doseOptions.first {
                            viewModel.logSingleIntake(dose: singleDose.doseConfig, deductStock: true)
                        }
                    } label: {
                        Image(systemName: viewModel.selectedDoses[group.group.id] != nil ? "checkmark.square.fill" : "square")
                            .font(.title2)
                            .foregroundStyle(viewModel.selectedDoses[group.group.id] != nil ? Color.accentColor : Color.secondary)
                    }
                    .disabled(viewModel.selectedDoses[group.group.id] == nil && group.doseOptions.count > 1)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct CompactDoseSelector: View {
    let options: [DoseOption]
    let selectedId: UUID?
    let isCompleted: Bool
    let onSelect: (DoseConfiguration) -> Void
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(options) { option in
                Button {
                    onSelect(option.doseConfig)
                } label: {
                    HStack(spacing: 4) {
                        Text(option.doseConfig.displayName)
                            .font(.caption)
                            .fontWeight(.medium)
                        
                        if option.hasLowStock {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.system(size: 8))
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(selectedId == option.doseConfig.id ? Color.accentColor : Color(.systemGray5))
                    )
                    .foregroundStyle(selectedId == option.doseConfig.id ? Color.white : Color.primary)
                }
                .disabled(isCompleted || option.isCompleted)
            }
            Spacer()
        }
    }
}

struct DoseOptionRow: View {
    let option: DoseOption
    let isSelected: Bool
    let isCompleted: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                // Radio button
                Image(systemName: isCompleted ? "checkmark.circle.fill" : (isSelected ? "circle.inset.filled" : "circle"))
                    .foregroundStyle(isCompleted ? Color.green : (isSelected ? Color.accentColor : Color.secondary))
                
                // Dose info
                VStack(alignment: .leading) {
                    Text(option.doseConfig.displayName)
                        .font(.body)
                        .foregroundStyle(isCompleted ? Color.secondary : Color.primary)
                    
                    // Component breakdown
                    if option.components.count > 1 {
                        Text(option.components.map { "\($0.medication.name) \(Int($0.medication.strength))\($0.medication.strengthUnit) ×\($0.quantityNeeded)" }.joined(separator: " + "))
                            .font(.caption)
                            .foregroundStyle(Color.secondary)
                    }
                }
                
                Spacer()
                
                // Low stock warning
                if option.hasLowStock {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundStyle(Color.orange)
                        .font(.caption)
                }
            }
            .padding(.vertical, 4)
        }
        .disabled(isCompleted)
    }
}

#Preview {
    TodayView()
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

