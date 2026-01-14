//
//  Step7_ColorSelectionView.swift
//  Pillo
//
//  Created by Chloe Lee on 2025-12-10.
//

import SwiftUI

struct ColorSelectionView: View {
    @Bindable var state: AddMedicationFlowState
    @Environment(\.dismiss) private var dismiss
    
    private let pillColors: [Color] = [
        Color("PillColor-White"),
        Color("PillColor-LightGray"),
        Color("PillColor-Cream"),
        Color("PillColor-Peach"),
        Color("PillColor-YellowGreen"),
        Color("PillColor-Mint"),
        Color("PillColor-SkyBlue"),
        Color("PillColor-Blue"),
        Color("PillColor-Lavender"),
        Color("PillColor-Pink"),
        Color("PillColor-Red"),
        Color("PillColor-Orange"),
    ]
    
    private let backgroundColors: [Color] = [
        Color("BackgroundColor-Teal"),
        Color("BackgroundColor-DarkGray"),
        Color("BackgroundColor-OliveGold"),
        Color("BackgroundColor-Coral"),
        Color("BackgroundColor-Sage"),
        Color("BackgroundColor-Aqua"),
        Color("BackgroundColor-DarkTeal"),
        Color("BackgroundColor-Purple"),
        Color("BackgroundColor-MutedPurple"),
        Color("BackgroundColor-Salmon"),
        Color("BackgroundColor-DarkerRed"),
        Color("BackgroundColor-BrownCopper"),
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Preview
                ZStack {
                    Circle()
                        .fill(state.backgroundColor)
                        .frame(width: 120, height: 120)
                    
                    pillPreview
                        .frame(width: 80, height: 80)
                }
                .padding(.top, 20)
                
                // Header
                Text("Choose Colors")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(Color.primary)
                    .padding(.horizontal)
                
                if state.selectedShape.isTwoTone {
                    // Capsule: two-tone selection
                    VStack(alignment: .leading, spacing: 12) {
                        colorSection(title: "Left Side", selectedColor: $state.leftColor, colors: pillColors)
                        colorSection(title: "Right Side", selectedColor: $state.rightColor, colors: pillColors)
                        colorSection(title: "Background", selectedColor: $state.backgroundColor, colors: backgroundColors)
                    }
                } else {
                    // Single color for other shapes
                    VStack(alignment: .leading, spacing: 12) {
                        colorSection(title: "Color", selectedColor: $state.leftColor, colors: pillColors)
                        colorSection(title: "Background", selectedColor: $state.backgroundColor, colors: backgroundColors)
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
        } else {
            Image(systemName: state.selectedShape.sfSymbolPlaceholder)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundStyle(state.leftColor)
        }
    }
    
    private func colorSection(title: String, selectedColor: Binding<Color>, colors: [Color]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .foregroundStyle(Color.secondary)
                .padding(.horizontal)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 12) {
                ForEach(colors, id: \.self) { color in
                    Button {
                        selectedColor.wrappedValue = color
                        let impact = UIImpactFeedbackGenerator(style: .light)
                        impact.impactOccurred()
                    } label: {
                        ZStack {
                            Circle()
                                .fill(color)
                                .frame(width: 44, height: 44)
                            
                            // Light stroke for all colors to make them visible
                            Circle()
                                .stroke(Color(.separator), lineWidth: 0.5)
                                .frame(width: 44, height: 44)
                            
                            if selectedColor.wrappedValue == color {
                                // Outer ring for selected state
                                Circle()
                                    .stroke(Color.primary, lineWidth: 3)
                                    .frame(width: 50, height: 50)
                                // Inner stroke for better visibility
                                Circle()
                                    .stroke(Color.white, lineWidth: 2)
                                    .frame(width: 44, height: 44)
                            }
                        }
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}

#Preview {
    NavigationStack {
        ColorSelectionView(state: AddMedicationFlowState())
    }
}
