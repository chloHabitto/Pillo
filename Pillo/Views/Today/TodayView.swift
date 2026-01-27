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
            .toolbar(.hidden, for: .navigationBar)
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
    
    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        if hour < 12 { return "Good Morning" }
        if hour < 17 { return "Good Afternoon" }
        return "Good Evening"
    }
    
    private var isViewingToday: Bool {
        Calendar.current.isDateInToday(viewModel.selectedDate)
    }
    
    private var completionPercentage: Double {
        let total = viewModel.dailyPlan.timeFrames.flatMap { $0.groups }.count
        guard total > 0 else { return 0 }
        let completed = viewModel.dailyPlan.timeFrames.flatMap { $0.groups }.filter { $0.completedDose != nil }.count
        return Double(completed) / Double(total) * 100
    }
    
    private var allMedicationsTaken: Bool {
        let groups = viewModel.dailyPlan.timeFrames.flatMap { $0.groups }
        return !groups.isEmpty && groups.allSatisfy { $0.completedDose != nil }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Custom header instead of .navigationTitle
            VStack(alignment: .leading, spacing: 4) {
                Text(greeting)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                HStack {
                    Text(isViewingToday ? "Today" : viewModel.selectedDate.formatted(.dateTime.weekday(.wide)))
                        .font(.system(size: 28, weight: .heavy))
                    
                    Spacer()
                    
                    ProgressRingView(progress: completionPercentage)
                }
            }
            .padding(.horizontal)
            .padding(.top, 12)
            
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
                        // Celebration banner when all medications taken
                        if allMedicationsTaken {
                            HStack(spacing: 12) {
                                Image(systemName: "sparkles")
                                    .font(.title2)
                                    .foregroundStyle(Color.appSuccess)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Amazing job!")
                                        .font(.headline)
                                        .foregroundStyle(Color.appSuccess)
                                    Text("You've taken all your medicines today")
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }
                                
                                Spacer()
                            }
                            .padding()
                            .background(
                                LinearGradient(
                                    colors: [Color.appSuccessLight, Color.appPrimaryLight],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.appSuccess.opacity(0.2), lineWidth: 1)
                            )
                            .transition(.opacity.combined(with: .move(edge: .top)))
                            .animation(.easeInOut, value: allMedicationsTaken)
                        }
                        
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
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(viewModel.areAllSelectedDosesCompleted ? Color.orange : Color.appPrimary)
                        )
                        .shadow(color: Color.appPrimary.opacity(0.3), radius: 8, x: 0, y: 4)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 8)
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
        .overlay(alignment: .bottom) {
            if viewModel.showUndoSuccessToast {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(Color.appSuccess)
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
    
    private var displayName: String {
        timeFrame.timeFrame.rawValue.capitalized
    }
    
    private var completedCount: Int {
        timeFrame.groups.filter { $0.completedDose != nil }.count
    }
    
    private var totalCount: Int {
        timeFrame.groups.count
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Text(displayName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                HStack(spacing: 8) {
                    Text("\(completedCount)/\(totalCount)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    if completedCount == totalCount && totalCount > 0 {
                        Text("Done!")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundStyle(Color.appSuccess)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(Color.appSuccessLight)
                            .clipShape(Capsule())
                    }
                }
            }
            .padding(.bottom, 8)
            
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
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Pill icon or checkmark on the left
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(group.completedDose != nil ? Color.appSuccess.opacity(0.2) : Color.appPrimaryLight)
                    .frame(width: 50, height: 50)
                
                if group.completedDose != nil {
                    Image(systemName: "checkmark")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(Color.appSuccess)
                } else if let medication = medication {
                    PillIconView(medication: medication, size: 24)
                } else {
                    Image(systemName: "pills.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(Color.appPrimary)
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
                            if let completedDose = group.completedDose,
                               completedDose.id != dose.id {
                                pendingNewDose = dose
                                showingChangeDoseConfirmation = true
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
        .background(cardBackgroundColor(for: group))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(cardBorderColor(for: group), lineWidth: isSelected(group) || group.completedDose != nil ? 2 : 0)
        )
        .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 2)
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
            Button("Undo Intake", role: .destructive) {
                if let logId = group.completedIntakeLog?.id {
                    viewModel.undoIntake(logId: logId)
                }
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
    }
    
    // Helper to check if this group has a selected dose
    private func isSelected(_ group: GroupPlan) -> Bool {
        viewModel.selectedDoses[group.group.id] != nil
    }
    
    // Helper to get card background color based on completion and selection state
    private func cardBackgroundColor(for group: GroupPlan) -> Color {
        if group.completedDose != nil {
            return Color.appSuccessLight
        } else if isSelected(group) {
            return Color.appPrimaryLight
        }
        return Color(.systemBackground)
    }
    
    // Helper to get card border color based on completion and selection state
    private func cardBorderColor(for group: GroupPlan) -> Color {
        if group.completedDose != nil {
            return Color.appSuccess.opacity(0.3)
        } else if isSelected(group) {
            return Color.appPrimary
        }
        return Color.clear
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
                        let isSelected = selectedId == option.doseConfig.id
                        let isCompleted = completedId == option.doseConfig.id
                        Button {
                            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                            impactFeedback.impactOccurred()
                            onSelect(option.doseConfig)
                        } label: {
                            HStack(spacing: 4) {
                                if isCompleted {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 10, weight: .semibold))
                                }
                                Text(option.doseConfig.displayName)
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .lineLimit(1)
                                    .fixedSize(horizontal: true, vertical: false)
                                if option.hasLowStock {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .font(.system(size: 10))
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(chipBackground(isSelected: isSelected, isCompleted: isCompleted))
                            .foregroundStyle(chipForeground(isSelected: isSelected, isCompleted: isCompleted))
                            .clipShape(Capsule())
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
    
    private func chipBackground(isSelected: Bool, isCompleted: Bool) -> Color {
        if isCompleted { return Color.appSuccess }
        if isSelected { return Color.appPrimary }
        return Color.appChip
    }
    
    private func chipForeground(isSelected: Bool, isCompleted: Bool) -> Color {
        if isCompleted || isSelected { return .white }
        return .secondary
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

