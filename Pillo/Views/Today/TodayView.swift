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
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color("appSurface01"))
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
    
    private var bottomButtonBackgroundColor: Color {
        if viewModel.areAllSelectedDosesCompleted {
            return Color.orange
        }
        return Color.accentColor
    }
    
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
                    viewModel.performBottomAction()
                } label: {
                    Text(viewModel.bottomActionButtonLabel)
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(bottomButtonBackgroundColor)
                        .foregroundStyle(Color.white)
                        .clipShape(Capsule())
                }
                .padding()
            }
        }
        .refreshable {
            viewModel.loadPlan()
        }
        .onAppear {
            // Reload plan when content view appears to ensure fresh data
            viewModel.loadPlan()
        }
        .overlay(alignment: .bottom) {
            if viewModel.showUndoSuccessToast {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                    Text("Intake undone")
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 14)
                .background(
                    Capsule()
                        .fill(.ultraThinMaterial)
                        .shadow(color: .black.opacity(0.15), radius: 8, y: 4)
                )
                .padding(.bottom, viewModel.selectedDoses.isEmpty ? 40 : 100)
                .transition(.asymmetric(
                    insertion: .move(edge: .bottom).combined(with: .opacity),
                    removal: .opacity
                ))
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: viewModel.showUndoSuccessToast)
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
                    .id("\(group.group.id)-\(group.completedDose?.id.uuidString ?? "none")") // Force re-render when completion changes
            }
        }
    }
}

struct GroupCard: View {
    let group: GroupPlan
    @Bindable var viewModel: TodayViewModel
    @Environment(\.modelContext) private var modelContext
    @State private var showingUndoConfirmation = false
    @State private var showingChangeDoseConfirmation = false
    @State private var pendingNewDose: DoseConfiguration?
    @State private var medication: Medication?
    @State private var showingLogOptionsSheet = false
    @State private var showingManageIntakeSheet = false
    
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
                            if let completedDose = group.completedDose {
                                if completedDose.id == dose.id {
                                    // Tapped the same (completed) dose → manage intake
                                    showingManageIntakeSheet = true
                                } else {
                                    // Tapped a different dose → select it and show change confirmation
                                    viewModel.selectDose(dose, for: group.group)
                                    pendingNewDose = dose
                                    showingChangeDoseConfirmation = true
                                }
                            } else {
                                viewModel.selectDose(dose, for: group.group)
                            }
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
            // Card body tap: behavior depends on completion and selection state
            if group.completedDose != nil {
                // Dose already logged → show manage intake sheet
                showingManageIntakeSheet = true
            } else {
                // Nothing logged
                if viewModel.selectedDoses[group.group.id] != nil {
                    // Something selected → deselect it
                    viewModel.deselectGroup(group.group)
                } else {
                    // Nothing selected → show log options sheet
                    showingLogOptionsSheet = true
                }
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
            Button("Undo Intake", role: .destructive) {
                viewModel.undoIntakesForGroup(groupId: group.group.id)
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("This will restore the stock and remove the intake log.")
        }
        .confirmationDialog("Change Dose", isPresented: $showingChangeDoseConfirmation) {
            Button("Change Dose", role: .destructive) {
                if let newDose = pendingNewDose,
                   let oldDose = group.completedDose {
                    viewModel.changeDose(for: group.group.id, from: oldDose, to: newDose)
                }
                pendingNewDose = nil
            }
            Button("Cancel", role: .cancel) {
                pendingNewDose = nil
            }
        } message: {
            if let oldDose = group.completedDose,
               let newDose = pendingNewDose {
                Text("Change dose from \(oldDose.displayName) to \(newDose.displayName)?")
            } else {
                Text("Change the logged dose?")
            }
        }
        .confirmationDialog("Log", isPresented: $showingLogOptionsSheet) {
            if let firstOption = group.doseOptions.first {
                Button("Log \(firstOption.doseConfig.displayName)") {
                    viewModel.selectDose(firstOption.doseConfig, for: group.group)
                }
            }
            Button("Skip for today") { }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Choose an option")
        }
        .confirmationDialog("Manage Intake", isPresented: $showingManageIntakeSheet) {
            Button("Undo Intake", role: .destructive) {
                viewModel.undoIntakesForGroup(groupId: group.group.id)
            }
            Button("Change Dose") {
                // Dismiss sheet; user can then tap a different dose button to trigger change confirmation
            }
            Button("Add Memo") {
                print("DEBUG: Add Memo tapped – placeholder")
            }
            Button("Record Symptoms") {
                print("DEBUG: Record Symptoms tapped – placeholder")
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Manage this intake")
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
            return Color("appCardBG01")
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
    
    // Sort options by dose strength (extract numeric value from displayName like "18mg")
    private var sortedOptions: [DoseOption] {
        options.sorted { option1, option2 in
            let value1 = extractNumericValue(from: option1.doseConfig.displayName)
            let value2 = extractNumericValue(from: option2.doseConfig.displayName)
            return value1 < value2
        }
    }
    
    // Extract numeric value from display name like "18mg" -> 18
    private func extractNumericValue(from displayName: String) -> Double {
        let numericString = displayName.filter { $0.isNumber || $0 == "." }
        return Double(numericString) ?? 0
    }
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(sortedOptions) { option in
                        Button {
                            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                            impactFeedback.impactOccurred()
                            onSelect(option.doseConfig)
                        } label: {
                            HStack(spacing: 4) {
                                if selectedId == option.doseConfig.id || completedId == option.doseConfig.id {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundStyle(Color("appOnPrimary"))
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
                            // Apply faded opacity to non-selected buttons when a dose is completed
                            .opacity(opacityForButton(option.doseConfig.id))
                        }
                        .disabled(false)
                        .id(option.doseConfig.id) // For ScrollViewReader
                    }
                }
                .padding(.horizontal, 4)
                .scrollTargetLayout()
            }
            .scrollTargetBehavior(.viewAligned)
            // Gradient fade mask overlay for edge hints
            .mask(
                HStack(spacing: 0) {
                    // Left fade gradient
                    LinearGradient(
                        gradient: Gradient(colors: [.clear, .black]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: 8)
                    
                    // Middle solid area
                    Rectangle()
                        .fill(Color.black)
                    
                    // Right fade gradient
                    LinearGradient(
                        gradient: Gradient(colors: [.black, .clear]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: 8)
                }
            )
            // Auto-scroll to completed or selected dose
            .onAppear {
                scrollToActiveOption(proxy: proxy)
            }
            .onChange(of: completedId) { _, newValue in
                if let id = newValue {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        proxy.scrollTo(id, anchor: .center)
                    }
                }
            }
            .onChange(of: selectedId) { _, newValue in
                if let id = newValue {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        proxy.scrollTo(id, anchor: .center)
                    }
                }
            }
        }
    }
    
    // Scroll to completed or selected dose on appear
    private func scrollToActiveOption(proxy: ScrollViewProxy) {
        if let completedId = completedId {
            proxy.scrollTo(completedId, anchor: .center)
        } else if let selectedId = selectedId {
            proxy.scrollTo(selectedId, anchor: .center)
        }
    }
    
    // Opacity: fade non-selected buttons when a dose is completed
    private func opacityForButton(_ doseId: UUID) -> Double {
        // If nothing is completed, all buttons are full opacity
        guard completedId != nil else { return 1.0 }
        
        // Completed or currently selected button stays full opacity
        if completedId == doseId || selectedId == doseId {
            return 1.0
        }
        
        // Other buttons are slightly faded
        return 0.5
    }
    
    private func backgroundColor(for doseId: UUID) -> Color {
        if completedId == doseId || selectedId == doseId {
            return Color("appPrimary")
        } else {
            return Color("appButtonBG01")
        }
    }
    
    private func foregroundColor(for doseId: UUID) -> Color {
        if completedId == doseId || selectedId == doseId {
            return Color("appOnPrimary")
        } else {
            return Color("appText04")
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
