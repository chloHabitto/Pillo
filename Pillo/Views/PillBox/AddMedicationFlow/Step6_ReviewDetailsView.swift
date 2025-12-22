//
//  Step6_ReviewDetailsView.swift
//  Pillo
//
//  Created by Chloe Lee on 2025-12-10.
//

import SwiftUI

struct ReviewDetailsView: View {
    @Bindable var state: AddMedicationFlowState
    @Environment(\.dismiss) private var dismiss
    let onSave: (AddMedicationFlowState) -> Void
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Title
                Text("Review Details")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(.white)
                    .padding(.top, 20)
                
                // Pill preview
                ZStack {
                    Circle()
                        .fill(state.backgroundColor)
                        .frame(width: 120, height: 120)
                    
                    if let photo = state.selectedPhoto {
                        Image(uiImage: photo)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                    } else {
                        pillPreview
                    }
                }
                .padding()
                
                // Medication info
                VStack(spacing: 4) {
                    Text(state.medicationName)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(.white)
                    
                    if let form = state.selectedForm, let strength = state.strengths.first {
                        Text("\(form.rawValue.capitalized), \(Int(strength.value))\(strength.unit)")
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.7))
                    }
                }
                
                // Schedule card
                VStack(alignment: .leading, spacing: 8) {
                    Text("Schedule")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .padding(.horizontal)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text(state.scheduleOption.rawValue)
                            .foregroundStyle(.white)
                        
                        ForEach(state.times, id: \.self) { time in
                            HStack {
                                Text(time, style: .time)
                                Text("1 capsule")
                                    .foregroundStyle(.white.opacity(0.7))
                            }
                        }
                        
                        Text("Starts \(state.startDate, style: .date)")
                            .foregroundStyle(.white.opacity(0.7))
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(red: 0.17, green: 0.17, blue: 0.18))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding(.horizontal)
                
                // Optional details
                VStack(alignment: .leading, spacing: 12) {
                    Text("Optional Details")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .padding(.horizontal)
                    
                    VStack(spacing: 12) {
                        TextField("Display Name", text: $state.displayName)
                            .textFieldStyle(.plain)
                            .font(.body)
                            .foregroundStyle(.white)
                            .padding()
                            .background(Color(red: 0.17, green: 0.17, blue: 0.18))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        
                        TextField("Notes", text: $state.notes, axis: .vertical)
                            .textFieldStyle(.plain)
                            .font(.body)
                            .foregroundStyle(.white)
                            .lineLimit(3...6)
                            .padding()
                            .background(Color(red: 0.17, green: 0.17, blue: 0.18))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .padding(.horizontal)
                }
                
                Spacer(minLength: 100)
            }
        }
        .background(Color(red: 0.11, green: 0.11, blue: 0.12))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    state.previousStep()
                } label: {
                    Image(systemName: "chevron.left")
                        .foregroundStyle(.white)
                }
            }
            
            ToolbarItem(placement: .principal) {
                Text("Review Details")
                    .font(.headline)
                    .foregroundStyle(.white)
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.white.opacity(0.6))
                }
            }
        }
        .safeAreaInset(edge: .bottom) {
            Button {
                onSave(state)
                dismiss()
            } label: {
                Text("Done")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.cyan)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding()
            .background(Color(red: 0.11, green: 0.11, blue: 0.12))
        }
    }
    
    @ViewBuilder
    private var pillPreview: some View {
        if state.selectedShape == .capsule {
            Capsule()
                .fill(
                    LinearGradient(
                        colors: [state.leftColor, state.rightColor],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: 60, height: 30)
        } else {
            Circle()
                .fill(state.leftColor)
                .frame(width: 50, height: 50)
        }
    }
}

#Preview {
    NavigationStack {
        ReviewDetailsView(state: AddMedicationFlowState()) { _ in }
    }
}

