//
//  Step1_MedicationNameView.swift
//  Pillo
//
//  Created by Chloe Lee on 2025-12-10.
//

import SwiftUI

struct MedicationNameView: View {
    @Bindable var state: AddMedicationFlowState
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            // Pill icons illustration
            pillIconsIllustration
            
            // Title
            Text("Medication Name")
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(Color.primary)
            
            // Text field
            TextField("Add Medication Name", text: $state.medicationName)
                .textFieldStyle(.plain)
                .font(.system(size: 16))
                .foregroundStyle(Color.primary)
                .padding()
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal, 20)
            
            Spacer()
            
            // Next button
            Button {
                state.nextStep()
            } label: {
                Text("Next")
                    .font(.headline)
                    .foregroundStyle(state.canProceedFromStep(1) ? Color.white : Color.secondary)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(state.canProceedFromStep(1) ? Color.cyan : Color(.tertiarySystemFill))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .disabled(!state.canProceedFromStep(1))
            .padding(.horizontal, 20)
            .padding(.bottom, 32)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(Color.secondary)
                }
            }
        }
    }
    
    private var pillIconsIllustration: some View {
        ZStack {
            // Blue capsule
            Capsule()
                .fill(Color.blue)
                .frame(width: 60, height: 30)
                .offset(x: -30, y: 0)
            
            // Light blue hexagon
            HexagonShape()
                .fill(Color.cyan)
                .frame(width: 40, height: 40)
                .offset(x: 0, y: -10)
            
            // Pink circle
            Circle()
                .fill(Color.pink)
                .frame(width: 35, height: 35)
                .offset(x: 25, y: 5)
            
            // Yellow circles
            Circle()
                .fill(Color.yellow)
                .frame(width: 20, height: 20)
                .offset(x: -15, y: 20)
            
            Circle()
                .fill(Color.yellow.opacity(0.7))
                .frame(width: 15, height: 15)
                .offset(x: 20, y: 25)
        }
        .frame(width: 120, height: 80)
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
        MedicationNameView(state: AddMedicationFlowState())
    }
}

