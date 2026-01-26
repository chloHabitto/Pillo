//
//  Step2_MedicationTypeView.swift
//  Pillo
//
//  Created by Chloe Lee on 2025-12-10.
//

import SwiftUI

struct MedicationTypeView: View {
    @Bindable var state: AddMedicationFlowState
    @Environment(\.dismiss) private var dismiss
    @State private var searchText: String = ""
    @FocusState private var isSearchFocused: Bool
    
    private var commonForms: [MedicationForm] {
        [.capsule, .tablet, .liquid, .topical]
    }
    
    private var moreForms: [MedicationForm] {
        MedicationForm.allCases.filter { 
            ![MedicationForm.capsule, .tablet, .liquid, .topical, .other].contains($0) 
        }
    }
    
    private var filteredCommonForms: [MedicationForm] {
        if searchText.isEmpty {
            return commonForms
        }
        return commonForms.filter { $0.rawValue.localizedCaseInsensitiveContains(searchText) }
    }
    
    private var filteredMoreForms: [MedicationForm] {
        if searchText.isEmpty {
            return moreForms
        }
        return moreForms.filter { $0.rawValue.localizedCaseInsensitiveContains(searchText) }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                if !isSearchFocused {
                    // Colorful pill icons illustration
                    pillIconsIllustration
                        .padding(.top, 0)
                    
                    // Title
                    Text("Choose the Medication Type")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(Color.primary)
                        .padding(.horizontal)
                }
                
                // Search bar
                HStack {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(Color.secondary)
                        
                        TextField("Search medication forms", text: $searchText)
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
                
                // Custom Form section (shows when a custom form is added)
                if state.selectedForm == .other, let customName = state.customFormName, !customName.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Custom Form")
                            .font(.headline)
                            .foregroundStyle(Color.secondary)
                            .padding(.horizontal)
                        
                        VStack(spacing: 0) {
                            Button {
                                // Already selected, but allow re-selection
                                state.selectedForm = .other
                            } label: {
                                HStack {
                                    Text(customName.capitalized)
                                        .font(.body)
                                        .foregroundStyle(Color.primary)
                                    
                                    Spacer()
                                    
                                    Image(systemName: "checkmark")
                                        .foregroundStyle(Color.cyan)
                                }
                                .padding()
                                .contentShape(Rectangle())
                                .background(Color.cyan.opacity(0.1))
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        .background(Color(.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .padding(.horizontal)
                    }
                }
                
                // Show "No forms found" if search is active and both arrays are empty
                if !searchText.isEmpty && filteredCommonForms.isEmpty && filteredMoreForms.isEmpty && state.selectedForm != .other {
                    VStack(spacing: 16) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 40))
                            .foregroundStyle(Color.secondary)
                        
                        Text("No forms found")
                            .font(.headline)
                            .foregroundStyle(Color.secondary)
                        
                        Button {
                            state.selectedForm = .other
                            state.customFormName = searchText.trimmingCharacters(in: .whitespaces)
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
                        
                        Text("as a custom medication form")
                            .font(.caption)
                            .foregroundStyle(Color.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)
                } else {
                    // Common Forms
                    if !filteredCommonForms.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Common Forms")
                                .font(.headline)
                                .foregroundStyle(Color.secondary)
                                .padding(.horizontal)
                            
                            VStack(spacing: 0) {
                                ForEach(filteredCommonForms, id: \.self) { form in
                                    formRow(form)
                                }
                            }
                            .background(Color(.secondarySystemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .padding(.horizontal)
                        }
                    }
                    
                    // More Forms
                    if !filteredMoreForms.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("More Forms")
                                .font(.headline)
                                .foregroundStyle(Color.secondary)
                                .padding(.horizontal)
                            
                            VStack(spacing: 0) {
                                ForEach(filteredMoreForms, id: \.self) { form in
                                    formRow(form)
                                }
                            }
                            .background(Color(.secondarySystemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .padding(.horizontal)
                        }
                    }
                }
                
                Spacer(minLength: 100)
            }
            .animation(.easeInOut(duration: 0.2), value: isSearchFocused)
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
            Button {
                state.nextStep()
            } label: {
                Text("Next")
                    .font(.headline)
                    .foregroundStyle(state.canProceedFromStep(5) ? Color.white : Color.secondary)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(state.canProceedFromStep(5) ? Color.cyan : Color(.tertiarySystemFill))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .disabled(!state.canProceedFromStep(5))
            .padding()
            .background(Color(.systemBackground))
        }
    }
    
    private var pillIconsIllustration: some View {
        Image("Shapes-horizontal")
            .resizable()
            .scaledToFit()
            .frame(height: 28)
            .padding()
    }
    
    private func formRow(_ form: MedicationForm) -> some View {
        Button {
            state.selectedForm = form
            // Clear custom form when selecting a predefined form
            if form != .other {
                state.customFormName = nil
            }
        } label: {
            HStack {
                Text(form.rawValue.capitalized)
                    .font(.body)
                    .foregroundStyle(Color.primary)
                
                Spacer()
                
                if state.selectedForm == form {
                    Image(systemName: "checkmark")
                        .foregroundStyle(Color.cyan)
                }
            }
            .padding()
            .contentShape(Rectangle())
            .background(state.selectedForm == form ? Color.cyan.opacity(0.1) : Color.clear)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct HexagonShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        
        for i in 0..<6 {
            let angle = Double(i) * .pi / 3 - .pi / 2
            let x = center.x + radius * cos(angle)
            let y = center.y + radius * sin(angle)
            if i == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }
        path.closeSubpath()
        return path
    }
}

#Preview {
    NavigationStack {
        MedicationTypeView(state: AddMedicationFlowState())
    }
}

