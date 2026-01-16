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
    
    private var formDisplayName: String {
        guard let form = state.selectedForm else { return "" }
        if form == .other, let customName = state.customFormName, !customName.isEmpty {
            return customName.capitalized
        }
        return form.rawValue.capitalized
    }
    
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
                    
                    if state.selectedForm != nil, let strength = state.strengths.first {
                        Text("\(formDisplayName), \(Int(strength.value))\(strength.unit)")
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
                    .renderingMode(.original)
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
                    .renderingMode(.original)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                if state.showRoundTabletLine {
                    Image("Shape-tablet-round_line")
                        .renderingMode(.original)
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
                    .renderingMode(.original)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                if state.showOvalTabletLine {
                    Image("Shape-tablet-oval-line")
                        .renderingMode(.original)
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
                    .renderingMode(.original)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                if state.showOblongTabletLine {
                    Image("Shape-oblong-line")
                        .renderingMode(.original)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                }
            }
        } else if state.selectedShape == .triangle {
            ZStack {
                Image("Shape-triangle")
                    .renderingMode(.template)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundStyle(state.leftColor)
                Image("Shape-triangle-shade")
                    .renderingMode(.original)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            }
        } else if state.selectedShape == .square {
            ZStack {
                Image("Shape-square")
                    .renderingMode(.template)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundStyle(state.leftColor)
                Image("Shape-square-shade")
                    .renderingMode(.original)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            }
        } else if state.selectedShape == .roundSquare {
            ZStack {
                Image("Shape-RoundSquare")
                    .renderingMode(.template)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundStyle(state.leftColor)
                Image("Shape-RoundSquare-Shade")
                    .renderingMode(.original)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            }
        } else if state.selectedShape == .hexagon {
            ZStack {
                Image("Shape-Hexagon")
                    .renderingMode(.template)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundStyle(state.leftColor)
                Image("Shape-Hexagon-Shade")
                    .renderingMode(.original)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            }
        } else if state.selectedShape == .diamond {
            ZStack {
                Image("Shape-Diamond")
                    .renderingMode(.template)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundStyle(state.leftColor)
                Image("Shape-Diamond-Shade")
                    .renderingMode(.original)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            }
        } else if state.selectedShape == .pentagon {
            ZStack {
                Image("Shape-Pentagon")
                    .renderingMode(.template)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundStyle(state.leftColor)
                Image("Shape-Pentagon-Shade")
                    .renderingMode(.original)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            }
        } else if state.selectedShape == .bottle {
            ZStack {
                Image("Shape-bottle01-body")
                    .renderingMode(.template)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundStyle(state.rightColor)  // Bottle body color
                Image("Shape-bottle01-cap")
                    .renderingMode(.template)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundStyle(state.leftColor)  // Cap color
                Image("Shape-bottle01-shade")
                    .renderingMode(.original)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            }
        } else if state.selectedShape == .bottle02 {
            ZStack {
                // Bottom layer: Neck (light grey)
                Image("Shape-bottle02-Neck")
                    .renderingMode(.template)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundStyle(state.rightColor)  // Neck color (uses rightColor for body/neck)
                // Neck shade
                Image("Shape-bottle02-NeckShade")
                    .renderingMode(.original)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                // Cap (white)
                Image("Shape-bottle02-cap")
                    .renderingMode(.template)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundStyle(state.leftColor)  // Cap color
                // Body (light grey)
                Image("Shape-bottle02-Body")
                    .renderingMode(.template)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundStyle(state.rightColor)  // Body color
                // Top layer: Shade
                Image("Shape-bottle02-Shade")
                    .renderingMode(.original)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            }
        } else if state.selectedShape == .cream01 {
            ZStack {
                // Bottom layer: Body (light grey)
                Image("Shape-Cream01-body")
                    .renderingMode(.template)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundStyle(state.rightColor)  // Body color
                // Cap (white)
                Image("Shape-Cream01-cap")
                    .renderingMode(.template)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundStyle(state.leftColor)  // Cap color
                // Top layer: Shade
                Image("Shape-Cream01-Shade")
                    .renderingMode(.original)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
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

