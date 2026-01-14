//
//  Step6_ShapeSelectionView.swift
//  Pillo
//
//  Created by Chloe Lee on 2025-12-10.
//

import SwiftUI

struct ShapeSelectionView: View {
    @Bindable var state: AddMedicationFlowState
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Preview
                ZStack {
                    Circle()
                        .fill(state.backgroundColor)
                        .frame(width: 120, height: 120)
                    
                    shapePreview(state.selectedShape)
                        .frame(width: 80, height: 80)
                }
                .padding(.top, 20)
                
                // Header
                Text("Choose the Shape")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(Color.primary)
                    .padding(.horizontal)
                
                // Common shapes grid
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 16) {
                    ForEach(PillShape.commonShapes, id: \.self) { shape in
                        shapeButton(shape)
                    }
                }
                .padding(.horizontal)
                
                // More section header
                Text("More")
                    .font(.headline)
                    .foregroundStyle(Color.primary)
                    .padding(.horizontal)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                // More shapes grid
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 16) {
                    ForEach(PillShape.moreShapes, id: \.self) { shape in
                        shapeButton(shape)
                    }
                }
                .padding(.horizontal)
                
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
                    if let form = state.selectedForm, let strength = state.strengths.first {
                        Text("\(form.rawValue.capitalized), \(Int(strength.value))\(strength.unit)")
                            .font(.caption)
                            .foregroundStyle(Color.secondary)
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
                        .foregroundStyle(Color.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.cyan)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
            .padding()
            .background(Color(.systemBackground))
        }
    }
    
    private func shapeButton(_ shape: PillShape) -> some View {
        Button {
            state.selectedShape = shape
            // Default colors are automatically set via didSet
            let impact = UIImpactFeedbackGenerator(style: .light)
            impact.impactOccurred()
        } label: {
            ZStack {
                // Use BackgroundColor-Aqua as default background
                Circle()
                    .fill(Color("BackgroundColor-Aqua"))
                    .frame(width: 70, height: 70)
                
                shapeIcon(shape, isSelected: state.selectedShape == shape)
                    .frame(width: 50, height: 50)
                
                if state.selectedShape == shape {
                    // Outer ring for selected state
                    Circle()
                        .stroke(Color.primary, lineWidth: 4)
                        .frame(width: 78, height: 78)
                    // Inner stroke for better visibility
                    Circle()
                        .stroke(Color.white, lineWidth: 3)
                        .frame(width: 70, height: 70)
                }
            }
        }
    }
    
    @ViewBuilder
    private func shapeIcon(_ shape: PillShape, isSelected: Bool) -> some View {
        if shape == .capsule {
            ZStack {
                Image("Shape-capsule_left")
                    .renderingMode(.template)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundStyle(isSelected ? Color("PillColor-White") : Color("PillColor-White"))
                Image("Shape-capsule_right")
                    .renderingMode(.template)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundStyle(isSelected ? Color("PillColor-LightGray") : Color("PillColor-LightGray"))
                Image("Shape-capsule_shade")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            }
        } else {
            Image(systemName: shape.sfSymbolPlaceholder)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundStyle(isSelected ? Color("PillColor-White") : Color("PillColor-White"))
        }
    }
    
    @ViewBuilder
    private func shapePreview(_ shape: PillShape) -> some View {
        if shape == .capsule {
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
        } else {
            Image(systemName: shape.sfSymbolPlaceholder)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundStyle(state.leftColor)
        }
    }
}

#Preview {
    NavigationStack {
        ShapeSelectionView(state: AddMedicationFlowState())
    }
}
