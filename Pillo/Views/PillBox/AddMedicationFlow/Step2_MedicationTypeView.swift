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
    
    private var commonForms: [MedicationForm] {
        [.capsule, .tablet, .liquid, .topical]
    }
    
    private var moreForms: [MedicationForm] {
        MedicationForm.allCases.filter { ![MedicationForm.capsule, .tablet, .liquid, .topical].contains($0) }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Colorful pill icons illustration
                pillIconsIllustration
                    .padding(.top, 20)
                
                // Title
                Text("Choose the Medication Type")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(Color.primary)
                    .padding(.horizontal)
                
                // Common Forms
                VStack(alignment: .leading, spacing: 12) {
                    Text("Common Forms")
                        .font(.headline)
                        .foregroundStyle(Color.secondary)
                        .padding(.horizontal)
                    
                    VStack(spacing: 0) {
                        ForEach(commonForms, id: \.self) { form in
                            formRow(form)
                        }
                    }
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal)
                }
                
                // More Forms
                VStack(alignment: .leading, spacing: 12) {
                    Text("More Forms")
                        .font(.headline)
                        .foregroundStyle(Color.secondary)
                        .padding(.horizontal)
                    
                    VStack(spacing: 0) {
                        ForEach(moreForms, id: \.self) { form in
                            formRow(form)
                        }
                    }
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal)
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
        HStack(spacing: 16) {
            // Blue capsule
            Capsule()
                .fill(Color.blue)
                .frame(width: 50, height: 25)
            
            // Cyan hexagon
            HexagonShape()
                .fill(Color.cyan)
                .frame(width: 35, height: 35)
            
            // Pink circle
            Circle()
                .fill(Color.pink)
                .frame(width: 30, height: 30)
            
            // Yellow circle
            Circle()
                .fill(Color.yellow)
                .frame(width: 25, height: 25)
        }
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

