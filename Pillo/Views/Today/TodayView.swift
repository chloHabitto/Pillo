//
//  TodayView.swift
//  Pillo
//
//  Created by Chloe Lee on 2025-12-10.
//

import SwiftUI
import SwiftData
import UIKit

struct TodayView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(SyncManager.self) private var syncManager
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
                    viewModel = TodayViewModel(modelContext: modelContext, syncManager: syncManager)
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
                .frame(maxWidth: .infinity)
                .contentShape(Rectangle())
                .onTapGesture {
                    // Deselect all when tapping empty space
                    // Child views' tap gestures take priority, so this only fires when tapping empty space (not on cards)
                    viewModel.deselectAll()
                }
            }
        }
        .overlay(alignment: .bottom) {
            if !viewModel.selectedDoses.isEmpty {
                Button {
                    if viewModel.areAllSelectedDosesCompleted {
                        viewModel.unlogSelectedIntakes()
                    } else {
                        viewModel.logSelectedIntakes(deductStock: true)
                    }
                } label: {
                    Text(viewModel.areAllSelectedDosesCompleted ? "Unlog Selected" : "Log Selected as Taken")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(viewModel.areAllSelectedDosesCompleted ? Color.orange : Color.accentColor)
                        .foregroundStyle(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding()
                .background(.ultraThinMaterial)
            }
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
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(Color.secondary)
                
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
    @Environment(\.modelContext) private var modelContext
    @State private var showingUndoConfirmation = false
    @State private var medication: Medication?
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Pill icon on the left
            if let medication = medication {
                PillIconView(medication: medication, size: 50)
            } else {
                // Default icon while loading
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color(.systemGray5))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: "pills.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(Color.secondary)
                }
            }
            
            // Content on the right
            VStack(alignment: .leading, spacing: 8) {
                // Show medication name (extract from first option's first component)
                if let firstComponent = group.doseOptions.first?.components.first {
                    Text(firstComponent.medicationName)
                        .font(.headline)
                }
                
                if !group.doseOptions.isEmpty {
                    // Show all doses (single or multiple) as pill buttons for consistency
                    CompactDoseSelector(
                        options: group.doseOptions,
                        selectedId: viewModel.selectedDoses[group.group.id]?.id,
                        completedId: group.completedDose?.id,
                        onSelect: { dose in
                            // Toggle selection when tapping a chip
                            viewModel.toggleDoseSelection(dose, for: group.group)
                        }
                    )
                } else {
                    // No dose options - medication exists but not configured for dosing
                    Text("Not scheduled")
                        .font(.caption)
                        .foregroundStyle(Color.secondary)
                }
            }
        }
        .padding()
        .background(backgroundColor(for: group))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(borderColor(for: group), lineWidth: isSelected(group) ? 2 : 0)
        )
        .contentShape(Rectangle()) // Make entire area tappable
        .onAppear {
            // Fetch medication when view appears
            if medication == nil, let firstComponent = group.doseOptions.first?.components.first {
                let medicationId = firstComponent.medicationId
                let descriptor = FetchDescriptor<Medication>(
                    predicate: #Predicate<Medication> { $0.id == medicationId }
                )
                medication = try? modelContext.fetch(descriptor).first
            }
        }
        .onTapGesture {
            // Make all cards tappable to toggle selection
            if group.doseOptions.count == 1,
               let singleOption = group.doseOptions.first {
                // Single dose: toggle selection
                viewModel.toggleDoseSelection(singleOption.doseConfig, for: group.group)
            } else if group.doseOptions.count > 1 {
                // Multiple doses: select first available or toggle off if already selected
                viewModel.selectFirstAvailableDose(for: group.group)
            }
        }
        .overlay(alignment: .topTrailing) {
            // Undo button on the top right (only shown when completed and not selected)
            if group.completedDose != nil && !isSelected(group) {
                Button {
                    showingUndoConfirmation = true
                } label: {
                    Image(systemName: "arrow.uturn.backward")
                        .font(.subheadline)
                        .foregroundStyle(Color.orange)
                        .padding(8)
                        .background(Color.orange.opacity(0.15))
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
                .padding(.top, 8)
                .padding(.trailing, 8)
            }
        }
        .confirmationDialog("Undo Intake", isPresented: $showingUndoConfirmation) {
            Button("Undo", role: .destructive) {
                if let intakeLog = group.completedIntakeLog {
                    viewModel.undoIntake(log: intakeLog)
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will restore the stock and remove the intake log. Are you sure?")
        }
    }
    
    // Helper to check if this group has a selected dose
    private func isSelected(_ group: GroupPlan) -> Bool {
        viewModel.selectedDoses[group.group.id] != nil
    }
    
    // Helper to get background color based on selection and completion state
    private func backgroundColor(for group: GroupPlan) -> Color {
        if isSelected(group) {
            return Color.accentColor.opacity(0.1)
        } else {
            return Color(.systemGray6)
        }
    }
    
    // Helper to get border color based on selection state
    private func borderColor(for group: GroupPlan) -> Color {
        if isSelected(group) {
            return Color.accentColor
        } else {
            return Color.clear
        }
    }
}

struct CompactDoseSelector: View {
    let options: [DoseOption]
    let selectedId: UUID?
    let completedId: UUID?
    let onSelect: (DoseConfiguration) -> Void
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(options) { option in
                    Button {
                        // Haptic feedback on tap
                        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                        impactFeedback.impactOccurred()
                        onSelect(option.doseConfig)
                    } label: {
                        HStack(spacing: 4) {
                            // Show checkmark if this dose is selected or completed
                            if selectedId == option.doseConfig.id || completedId == option.doseConfig.id {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundStyle(Color.white)
                            }
                            
                            Text(option.doseConfig.displayName)
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .lineLimit(1)
                                .fixedSize(horizontal: true, vertical: false)
                            
                            if option.hasLowStock {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .font(.system(size: 10))
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(
                            Capsule()
                                .fill(backgroundColor(for: option.doseConfig.id))
                        )
                        .foregroundStyle(foregroundColor(for: option.doseConfig.id))
                    }
                    // Allow selecting completed doses so they can be unlogged
                    .disabled(false)
                }
            }
            .padding(.horizontal, 4) // Breathing room at edges
            .scrollTargetLayout()
        }
        .scrollTargetBehavior(.viewAligned) // Snap to buttons
    }
    
    private func backgroundColor(for doseId: UUID) -> Color {
        if completedId == doseId {
            return Color.green
        } else if selectedId == doseId {
            return Color.accentColor
        } else {
            return Color(.systemGray5)
        }
    }
    
    private func foregroundColor(for doseId: UUID) -> Color {
        if completedId == doseId || selectedId == doseId {
            return Color.white
        } else {
            return Color.primary
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
                        Text(option.components.map { "\($0.medicationName) \(Int($0.medicationStrength))\($0.medicationStrengthUnit) ×\($0.quantityNeeded)" }.joined(separator: " + "))
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

