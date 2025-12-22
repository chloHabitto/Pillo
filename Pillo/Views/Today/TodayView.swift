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
                        .foregroundStyle(.white)
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
                        .foregroundStyle(.green)
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
            // Group name
            Text(group.group.name)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            // Dose options
            ForEach(group.doseOptions) { option in
                DoseOptionRow(
                    option: option,
                    isSelected: viewModel.isSelected(option.doseConfig, in: group.group),
                    isCompleted: option.isCompleted
                ) {
                    viewModel.selectDose(option.doseConfig, for: group.group)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
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
                    .foregroundStyle(isCompleted ? .green : (isSelected ? .accentColor : .secondary))
                
                // Dose info
                VStack(alignment: .leading) {
                    Text(option.doseConfig.displayName)
                        .font(.body)
                        .foregroundStyle(isCompleted ? .secondary : .primary)
                    
                    // Component breakdown
                    if option.components.count > 1 {
                        Text(option.components.map { "\($0.medication.name) \(Int($0.medication.strength))\($0.medication.strengthUnit) ×\($0.quantityNeeded)" }.joined(separator: " + "))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                
                Spacer()
                
                // Low stock warning
                if option.hasLowStock {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundStyle(.orange)
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

