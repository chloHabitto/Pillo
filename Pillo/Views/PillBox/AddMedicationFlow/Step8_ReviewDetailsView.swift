//
//  Step8_ReviewDetailsView.swift
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
                    .foregroundStyle(Color.primary)
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
                            .frame(width: 80, height: 80)
                    }
                }
                .padding(.top, 20)
                
                // Medication info
                VStack(spacing: 4) {
                    Text(state.medicationName)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(Color.primary)
                    
                    if let form = state.selectedForm, let strength = state.strengths.first {
                        Text("\(form.rawValue.capitalized), \(Int(strength.value))\(strength.unit)")
                            .font(.subheadline)
                            .foregroundStyle(Color.secondary)
                    }
                }
                
                // Schedule card
                VStack(alignment: .leading, spacing: 8) {
                    Text("Schedule")
                        .font(.headline)
                        .foregroundStyle(Color.primary)
                        .padding(.horizontal)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text(state.scheduleOption.rawValue)
                            .foregroundStyle(Color.primary)
                        
                        ForEach(state.times, id: \.self) { time in
                            HStack {
                                Text(time, style: .time)
                                Text("1 capsule")
                                    .foregroundStyle(Color.secondary)
                            }
                        }
                        
                        Text("Starts \(state.startDate, style: .date)")
                            .foregroundStyle(Color.secondary)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding(.horizontal)
                
                // Optional details
                VStack(alignment: .leading, spacing: 12) {
                    Text("Optional Details")
                        .font(.headline)
                        .foregroundStyle(Color.primary)
                        .padding(.horizontal)
                    
                    VStack(spacing: 12) {
                        TextField("Display Name", text: $state.displayName)
                            .textFieldStyle(.plain)
                            .font(.body)
                            .foregroundStyle(Color.primary)
                            .padding()
                            .background(Color(.secondarySystemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        
                        TextField("Notes", text: $state.notes, axis: .vertical)
                            .textFieldStyle(.plain)
                            .font(.body)
                            .foregroundStyle(Color.primary)
                            .lineLimit(3...6)
                            .padding()
                            .background(Color(.secondarySystemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
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
                Text("Review Details")
                    .font(.headline)
                    .foregroundStyle(Color.primary)
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
                onSave(state)
                dismiss()
            } label: {
                Text("Done")
                    .font(.headline)
                    .foregroundStyle(Color.primary)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.cyan)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding()
            .background(Color(.systemBackground))
        }
    }
    
    @ViewBuilder
    private var pillPreview: some View {
        if state.selectedShape == .capsule {
            ZStack {
                Image("Shape-capsule_left")
                    .renderingMode(.template)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundStyle(state.leftColor)
                Image("Shape-capsule_right")
                    .renderingMode(.template)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundStyle(state.rightColor)
                Image("Shape-capsule_shade")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            }
        } else if state.selectedShape == .round {
            ZStack {
                Image("Shape-tablet-round")
                    .renderingMode(.template)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundStyle(state.leftColor)
                Image("Shape-tablet-round_shade")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                if state.showRoundTabletLine {
                    Image("Shape-tablet-round_line")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                }
            }
        } else if state.selectedShape == .oval {
            ZStack {
                Image("Shape-tablet-oval")
                    .renderingMode(.template)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundStyle(state.leftColor)
                Image("Shape-tablet-oval-shade")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                if state.showOvalTabletLine {
                    Image("Shape-tablet-oval-line")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                }
            }
        } else if state.selectedShape == .oblong {
            ZStack {
                Image("Shape-oblong")
                    .renderingMode(.template)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundStyle(state.leftColor)
                Image("Shape-oblong-shade")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                if state.showOblongTabletLine {
                    Image("Shape-oblong-line")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                }
            }
        } else {
            Image(systemName: state.selectedShape.sfSymbolPlaceholder)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundStyle(state.leftColor)
        }
    }
}

#Preview {
    NavigationStack {
        ReviewDetailsView(state: AddMedicationFlowState()) { _ in }
    }
}

