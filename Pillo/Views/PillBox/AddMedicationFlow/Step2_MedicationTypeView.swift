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
    
    private var commonForms: [MedicationForm] {
        [.capsule, .tablet, .liquid, .topical]
    }
    
    private var moreForms: [MedicationForm] {
        MedicationForm.allCases.filter { ![MedicationForm.capsule, .tablet, .liquid, .topical].contains($0) }
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
                // Colorful pill icons illustration
                pillIconsIllustration
                    .padding(.top, 0)
                
                // Title
                Text("Choose the Medication Type")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(Color.primary)
                    .padding(.horizontal)
                
                // Search bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(Color.secondary)
                    
                    TextField("Search medication forms", text: $searchText)
                        .textFieldStyle(.plain)
                    
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
                .padding(.horizontal)
                
                // Show "No forms found" if search is active and both arrays are empty
                if !searchText.isEmpty && filteredCommonForms.isEmpty && filteredMoreForms.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 48))
                            .foregroundStyle(Color.secondary)
                        Text("No forms found")
                            .font(.body)
                            .foregroundStyle(Color.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 60)
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
                    .foregroundStyle(state.canProceedFromStep(2) ? Color.white : Color.secondary)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(state.canProceedFromStep(2) ? Color.cyan : Color(.tertiarySystemFill))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .disabled(!state.canProceedFromStep(2))
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

