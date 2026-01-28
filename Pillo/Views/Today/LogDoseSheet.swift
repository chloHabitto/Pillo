//
//  LogDoseSheet.swift
//  Pillo
//

import SwiftUI

struct LogDoseSheet: View {
    let group: GroupPlan
    let medication: Medication?
    let onDoseSelected: (DoseConfiguration) -> Void
    let onSkip: () -> Void
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedDoseId: UUID?
    
    var body: some View {
        VStack(spacing: 0) {
            // Drag indicator
            Capsule()
                .fill(Color("appOutline02"))
                .frame(width: 36, height: 5)
                .padding(.top, 8)
                .padding(.bottom, 16)
            
            // Header with medication info
            HStack(spacing: 12) {
                // Pill icon
                if let medication = medication {
                    PillIconView(medication: medication, size: 44)
                } else {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.systemGray5))
                            .frame(width: 44, height: 44)
                        Image(systemName: "pills.fill")
                            .font(.system(size: 20))
                            .foregroundStyle(Color.secondary)
                    }
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    if let firstComponent = group.doseOptions.first?.components.first {
                        Text(firstComponent.medicationName)
                            .font(.appTitleLarge)
                            .foregroundStyle(Color("appText01"))
                    }
                    
                    Text(group.group.timeFrame.rawValue.capitalized)
                        .font(.appLabelMedium)
                        .foregroundStyle(Color("appText05"))
                }
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
            
            Divider()
            
            // Scrollable dose options section
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    Text("SELECT DOSAGE")
                        .font(.appLabelSmall)
                        .foregroundStyle(Color("appText06"))
                        .padding(.horizontal, 20)
                        .padding(.top, 16)
                    
                    // Dose options list
                    VStack(spacing: 0) {
                        ForEach(sortedDoseOptions) { option in
                            LogDoseOptionRow(
                                option: option,
                                isSelected: selectedDoseId == option.doseConfig.id,
                                onTap: {
                                    selectedDoseId = option.doseConfig.id
                                }
                            )
                            
                            if option.id != sortedDoseOptions.last?.id {
                                Divider()
                                    .padding(.leading, 20)
                            }
                        }
                    }
                    .background(Color("appCardBG01"))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal, 16)
                }
                .padding(.bottom, 24)
            }
            
            // Bottom buttons - pinned to bottom, no Spacer needed
            VStack(spacing: 12) {
                // Log as Taken button (primary)
                Button {
                    if let selectedId = selectedDoseId,
                       let selectedDose = group.doseOptions.first(where: { $0.doseConfig.id == selectedId })?.doseConfig {
                        onDoseSelected(selectedDose)
                        dismiss()
                    }
                } label: {
                    Text("Log as Taken")
                        .font(.appButtonText1)
                        .foregroundStyle(selectedDoseId != nil ? .white : Color("appText06"))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(selectedDoseId != nil ? Color.accentColor : Color("appCardBG01"))
                        .clipShape(Capsule())
                }
                .disabled(selectedDoseId == nil)
                
                // Skip button (secondary)
                Button {
                    onSkip()
                    dismiss()
                } label: {
                    Text("Skip for Today")
                        .font(.appButtonText2)
                        .foregroundStyle(Color("appText06"))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                }
            }
            .padding(.top, 8)
            .padding(.horizontal, 20)
            .padding(.bottom, 34)
            .background(Color("appSurface01"))
        }
        .background(Color("appSurface01"))
        .onAppear {
            // Pre-select first option if only one exists
            if group.doseOptions.count == 1 {
                selectedDoseId = group.doseOptions.first?.doseConfig.id
            }
        }
    }
    
    // Sort options by dose strength
    private var sortedDoseOptions: [DoseOption] {
        group.doseOptions.sorted { option1, option2 in
            let value1 = extractNumericValue(from: option1.doseConfig.displayName)
            let value2 = extractNumericValue(from: option2.doseConfig.displayName)
            return value1 < value2
        }
    }
    
    private func extractNumericValue(from displayName: String) -> Double {
        let numericString = displayName.filter { $0.isNumber || $0 == "." }
        return Double(numericString) ?? 0
    }
}

// MARK: - Dose Option Row (for sheet only)
private struct LogDoseOptionRow: View {
    let option: DoseOption
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Radio button
                ZStack {
                    Circle()
                        .strokeBorder(isSelected ? Color.accentColor : Color("appOutline02"), lineWidth: 2)
                        .frame(width: 22, height: 22)
                    
                    if isSelected {
                        Circle()
                            .fill(Color.accentColor)
                            .frame(width: 12, height: 12)
                    }
                }
                
                // Dose name
                Text(option.doseConfig.displayName)
                    .font(.appBodyLarge)
                    .foregroundStyle(Color("appText01"))
                
                Spacer()
                
                // Low stock warning
                if option.hasLowStock {
                    HStack(spacing: 4) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 12))
                        Text("Low")
                            .font(.appLabelSmall)
                    }
                    .foregroundStyle(.orange)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    Text("Sheet Preview")
        .sheet(isPresented: .constant(true)) {
            LogDoseSheet(
                group: GroupPlan(
                    group: MedicationGroup(name: "Morning Meds", selectionRule: .exactlyOne, timeFrame: .morning),
                    doseOptions: [],
                    completedDose: nil,
                    completedIntakeLog: nil
                ),
                medication: nil,
                onDoseSelected: { _ in },
                onSkip: { }
            )
            .presentationDetents([.medium])
            .presentationDragIndicator(.hidden)
        }
}
