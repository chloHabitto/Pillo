//
//  Step3_MedicationStrengthView.swift
//  Pillo
//
//  Created by Chloe Lee on 2025-12-10.
//

import SwiftUI

struct MedicationStrengthView: View {
    @Bindable var state: AddMedicationFlowState
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isStrengthFieldFocused: Bool
    @State private var showingUnitPicker = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Medication strength image
                Image("medstrength")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 28)
                    .padding(.top, 12)
                
                // Title
                Text("Add the Medication Strength")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(Color.primary)
                    .padding(.horizontal)
                
                // Strength input with inline unit picker
                VStack(alignment: .leading, spacing: 8) {
                    Text("Strength")
                        .font(.headline)
                        .foregroundStyle(Color.primary)
                        .padding(.horizontal)
                    
                    HStack(spacing: 12) {
                        // Strength value input
                        TextField("0", text: $state.currentStrengthValue)
                            .textFieldStyle(.plain)
                            .font(.system(size: 18, weight: .medium))
                            .foregroundStyle(Color.primary)
                            .keyboardType(.decimalPad)
                            .focused($isStrengthFieldFocused)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color(.tertiarySystemFill))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        
                        // Unit picker button
                        Button {
                            showingUnitPicker = true
                        } label: {
                            HStack(spacing: 4) {
                                Text(state.currentStrengthUnit)
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundStyle(Color.primary)
                                Image(systemName: "chevron.down")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundStyle(Color.secondary)
                            }
                            .padding()
                            .frame(minWidth: 80)
                            .background(Color(.tertiarySystemFill))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                    .padding(.horizontal)
                }
                
                // Added strengths
                if !state.strengths.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Added Strengths")
                            .font(.headline)
                            .foregroundStyle(Color.primary)
                            .padding(.horizontal)
                        
                        FlowLayout(spacing: 8) {
                            ForEach(Array(state.strengths.enumerated()), id: \.offset) { index, strength in
                                HStack(spacing: 4) {
                                    Text("\(Int(strength.value))\(strength.unit)")
                                        .font(.subheadline)
                                        .foregroundStyle(Color.primary)
                                    
                                    Button {
                                        state.removeStrength(at: index)
                                    } label: {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundStyle(Color.secondary)
                                    }
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(Color.cyan.opacity(0.2))
                                .clipShape(Capsule())
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                
                Spacer(minLength: 100)
            }
        }
        .background(Color(.systemBackground))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    state.previousStep()
                } label: {
                    Image(systemName: "chevron.left")
                        .foregroundStyle(Color.primary)
                }
            }
            
            ToolbarItem(placement: .principal) {
                VStack {
                    Text(state.medicationName)
                        .font(.headline)
                        .foregroundStyle(Color.primary)
                    if let form = state.selectedForm {
                        if form == .other, let customName = state.customFormName, !customName.isEmpty {
                            Text(customName.capitalized)
                                .font(.caption)
                                .foregroundStyle(Color.secondary)
                        } else {
                            Text(form.rawValue.capitalized)
                                .font(.caption)
                                .foregroundStyle(Color.secondary)
                        }
                    }
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(Color.secondary)
                }
            }
        }
        .safeAreaInset(edge: .bottom) {
            if isStrengthFieldFocused {
                // Add Strength and Done buttons when TextField is focused
                HStack(spacing: 12) {
                    Button {
                        state.addStrength()
                        // Keep focus after adding so user can add more strengths
                    } label: {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("Add Strength")
                        }
                        .font(.headline)
                        .foregroundStyle(state.currentStrengthValue.isEmpty ? Color.secondary : Color.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(state.currentStrengthValue.isEmpty ? Color(.tertiarySystemFill) : Color.cyan)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .disabled(state.currentStrengthValue.isEmpty)
                    
                    Button {
                        isStrengthFieldFocused = false
                    } label: {
                        Image(systemName: "checkmark")
                            .font(.headline)
                            .foregroundStyle(Color.white)
                            .frame(width: 50, height: 50)
                            .background(Color.cyan)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
                .padding()
                .background(Color(.systemBackground))
            } else {
                // Existing Next/Skip buttons when TextField is not focused
                HStack(spacing: 12) {
                    Button {
                        state.nextStep()
                    } label: {
                        Text("Skip")
                            .font(.headline)
                            .foregroundStyle(Color.secondary)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(.secondarySystemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    
                    Button {
                        state.nextStep()
                    } label: {
                        Text("Next")
                            .font(.headline)
                            .foregroundStyle(state.canProceedFromStep(3) ? Color.white : Color.secondary)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(state.canProceedFromStep(3) ? Color.cyan : Color(.tertiarySystemFill))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .disabled(!state.canProceedFromStep(3))
                }
                .padding()
                .background(Color(.systemBackground))
            }
        }
        .sheet(isPresented: $showingUnitPicker) {
            UnitPickerSheet(
                selectedUnit: $state.currentStrengthUnit,
                customUnit: $state.customStrengthUnit,
                isPresented: $showingUnitPicker
            )
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
        }
    }
    
}

struct UnitPickerSheet: View {
    @Binding var selectedUnit: String
    @Binding var customUnit: String?
    @Binding var isPresented: Bool
    
    @State private var searchText: String = ""
    @FocusState private var isSearchFocused: Bool
    
    private let commonUnits = ["mg", "mcg", "g", "mL", "%", "IU"]
    private let moreUnits = ["μg", "mm", "unit", "piece", "portion", "capsule", "pill", "drop", "patch", "spray", "puff", "injection", "application", "ampoule", "packet", "suppository", "pessary", "vaginal tablet", "vaginal capsule", "vaginal suppository"]
    
    private var allUnits: [String] {
        commonUnits + moreUnits
    }
    
    private var filteredCommonUnits: [String] {
        if searchText.isEmpty {
            return commonUnits
        }
        return commonUnits.filter { $0.localizedCaseInsensitiveContains(searchText) }
    }
    
    private var filteredMoreUnits: [String] {
        if searchText.isEmpty {
            return moreUnits
        }
        return moreUnits.filter { $0.localizedCaseInsensitiveContains(searchText) }
    }
    
    private var isCustomUnitActive: Bool {
        if let custom = customUnit, !custom.isEmpty {
            return selectedUnit == custom
        }
        return false
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Search bar
                    HStack {
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundStyle(Color.secondary)
                            
                            TextField("Search units", text: $searchText)
                                .textFieldStyle(.plain)
                                .focused($isSearchFocused)
                            
                            if !searchText.isEmpty {
                                Button {
                                    searchText = ""
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundStyle(Color.secondary)
                                }
                            }
                        }
                        .padding(10)
                        .background(Color(.tertiarySystemFill))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        
                        if isSearchFocused {
                            Button("Cancel") {
                                searchText = ""
                                isSearchFocused = false
                            }
                            .foregroundStyle(Color.cyan)
                            .transition(.move(edge: .trailing).combined(with: .opacity))
                        }
                    }
                    .padding(.horizontal)
                    .animation(.easeInOut(duration: 0.2), value: isSearchFocused)
                    
                    // Custom Unit section (if exists)
                    if let custom = customUnit, !custom.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Custom Unit")
                                .font(.headline)
                                .foregroundStyle(Color.secondary)
                                .padding(.horizontal)
                            
                            VStack(spacing: 0) {
                                unitRow(custom, isSelected: selectedUnit == custom)
                            }
                            .background(Color(.secondarySystemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .padding(.horizontal)
                        }
                    }
                    
                    // Empty state with Add button
                    if !searchText.isEmpty && filteredCommonUnits.isEmpty && filteredMoreUnits.isEmpty {
                        // Check if search doesn't match existing custom unit
                        let matchesCustom = customUnit?.localizedCaseInsensitiveContains(searchText) == true
                        
                        if !matchesCustom {
                            VStack(spacing: 16) {
                                Image(systemName: "magnifyingglass")
                                    .font(.system(size: 40))
                                    .foregroundStyle(Color.secondary)
                                
                                Text("No units found")
                                    .font(.headline)
                                    .foregroundStyle(Color.secondary)
                                
                                Button {
                                    let trimmed = searchText.trimmingCharacters(in: .whitespaces)
                                    customUnit = trimmed
                                    selectedUnit = trimmed
                                    searchText = ""
                                    isSearchFocused = false
                                } label: {
                                    HStack {
                                        Image(systemName: "plus.circle.fill")
                                        Text("Add \"\(searchText)\"")
                                    }
                                    .font(.subheadline.weight(.medium))
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 10)
                                    .background(Color.cyan)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                }
                                
                                Text("as a custom unit")
                                    .font(.caption)
                                    .foregroundStyle(Color.secondary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 40)
                        }
                    } else {
                        // Common Units
                        if !filteredCommonUnits.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Common")
                                    .font(.headline)
                                    .foregroundStyle(Color.secondary)
                                    .padding(.horizontal)
                                
                                VStack(spacing: 0) {
                                    ForEach(filteredCommonUnits, id: \.self) { unit in
                                        unitRow(unit, isSelected: selectedUnit == unit && !isCustomUnitActive)
                                        
                                        if unit != filteredCommonUnits.last {
                                            Divider()
                                                .padding(.leading)
                                        }
                                    }
                                }
                                .background(Color(.secondarySystemBackground))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .padding(.horizontal)
                            }
                        }
                        
                        // More Units
                        if !filteredMoreUnits.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("More")
                                    .font(.headline)
                                    .foregroundStyle(Color.secondary)
                                    .padding(.horizontal)
                                
                                VStack(spacing: 0) {
                                    ForEach(filteredMoreUnits, id: \.self) { unit in
                                        unitRow(unit, isSelected: selectedUnit == unit && !isCustomUnitActive)
                                        
                                        if unit != filteredMoreUnits.last {
                                            Divider()
                                                .padding(.leading)
                                        }
                                    }
                                }
                                .background(Color(.secondarySystemBackground))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .padding(.horizontal)
                            }
                        }
                    }
                    
                    Spacer(minLength: 40)
                }
                .padding(.top, 16)
            }
            .background(Color(.systemBackground))
            .navigationTitle("Select Unit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        isPresented = false
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(Color.secondary)
                    }
                }
            }
        }
    }
    
    private func unitRow(_ unit: String, isSelected: Bool) -> some View {
        Button {
            selectedUnit = unit
            // Clear custom unit if selecting a predefined unit
            if commonUnits.contains(unit) || moreUnits.contains(unit) {
                // Keep customUnit but just select the predefined one
            }
            isPresented = false
        } label: {
            HStack {
                Text(unit)
                    .font(.body)
                    .foregroundStyle(Color.primary)
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundStyle(Color.cyan)
                }
            }
            .padding()
            .contentShape(Rectangle())
            .background(isSelected ? Color.cyan.opacity(0.1) : Color.clear)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// Simple wrapping layout for chips with controlled horizontal spacing
struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(
            in: proposal.replacingUnspecifiedDimensions().width,
            subviews: subviews,
            spacing: spacing
        )
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(
            in: bounds.width,
            subviews: subviews,
            spacing: spacing
        )
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.frames[index].minX, y: bounds.minY + result.frames[index].minY), proposal: .unspecified)
        }
    }
    
    struct FlowResult {
        var size: CGSize = .zero
        var frames: [CGRect] = []
        
        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var currentX: CGFloat = 0
            var currentY: CGFloat = 0
            var lineHeight: CGFloat = 0
            var calculatedWidth: CGFloat = 0
            
            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)
                
                if currentX + size.width > maxWidth && currentX > 0 {
                    // Move to next line
                    currentX = 0
                    currentY += lineHeight + spacing
                    lineHeight = 0
                }
                
                frames.append(CGRect(x: currentX, y: currentY, width: size.width, height: size.height))
                currentX += size.width + spacing
                lineHeight = max(lineHeight, size.height)
                calculatedWidth = max(calculatedWidth, currentX - spacing)
            }
            
            self.size = CGSize(width: calculatedWidth, height: currentY + lineHeight)
        }
    }
}

#Preview {
    NavigationStack {
        MedicationStrengthView(state: AddMedicationFlowState())
    }
}

