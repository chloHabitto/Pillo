//
//  Step5_MedicationAppearanceView.swift
//  Pillo
//
//  Created by Chloe Lee on 2025-12-10.
//

import SwiftUI
import PhotosUI

struct MedicationAppearanceView: View {
    @Bindable var state: AddMedicationFlowState
    @Environment(\.dismiss) private var dismiss
    @State private var showingPhotoPicker = false
    @State private var selectedPhotoItem: PhotosPickerItem?
    
    private let shapeOptions: [PillShape] = [.capsule, .round, .oval, .oblong, .bottle, .pillBottle, .measuringCup, .tube]
    private let moreShapes: [PillShape] = [.diamond, .square, .triangle, .pentagon, .hexagon, .heart, .peanut]
    
    private let colorPalette: [Color] = [
        .white, .gray, Color(red: 1.0, green: 0.98, blue: 0.8), // cream
        Color(red: 1.0, green: 0.85, blue: 0.7), // peach
        Color(red: 0.8, green: 1.0, blue: 0.6), // yellow-green
        Color(red: 0.6, green: 1.0, blue: 0.8), // mint
        Color(red: 0.5, green: 0.8, blue: 1.0), // sky blue
        .blue, Color(red: 0.7, green: 0.6, blue: 1.0), // lavender
        .pink, .red, .orange
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Photo option
                Button {
                    showingPhotoPicker = true
                } label: {
                    HStack {
                        Image(systemName: "camera.fill")
                            .font(.title2)
                        Text("Take or Select Photo")
                            .font(.headline)
                    }
                    .foregroundStyle(.cyan)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.cyan.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding(.horizontal)
                .padding(.top, 20)
                
                Text("OR")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.5))
                
                // Shape selection
                VStack(alignment: .leading, spacing: 12) {
                    Text("Choose the Shape")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .padding(.horizontal)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 16) {
                        ForEach(shapeOptions, id: \.self) { shape in
                            shapeButton(shape)
                        }
                    }
                    .padding(.horizontal)
                    
                    Text("More")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .padding(.horizontal)
                        .padding(.top)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 16) {
                        ForEach(moreShapes, id: \.self) { shape in
                            shapeButton(shape)
                        }
                    }
                    .padding(.horizontal)
                }
                
                // Color selection
                if state.selectedShape == .capsule {
                    // Two-color selection for capsules
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Choose Colors")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .padding(.horizontal)
                        
                        colorSection(title: "Left Side", selectedColor: $state.leftColor)
                        colorSection(title: "Right Side", selectedColor: $state.rightColor)
                        colorSection(title: "Background", selectedColor: $state.backgroundColor)
                    }
                } else {
                    // Single color for other shapes
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Choose Colors")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .padding(.horizontal)
                        
                        colorSection(title: "Color", selectedColor: $state.leftColor)
                        colorSection(title: "Background", selectedColor: $state.backgroundColor)
                    }
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
                VStack {
                    Text(state.medicationName)
                        .font(.headline)
                        .foregroundStyle(.white)
                    if let form = state.selectedForm, let strength = state.strengths.first {
                        Text("\(form.rawValue.capitalized), \(Int(strength.value))\(strength.unit)")
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.6))
                    }
                }
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
        .photosPicker(isPresented: $showingPhotoPicker, selection: $selectedPhotoItem, matching: .images)
        .onChange(of: selectedPhotoItem) { oldValue, newValue in
            Task {
                if let data = try? await newValue?.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data) {
                    state.selectedPhoto = uiImage
                }
            }
        }
        .safeAreaInset(edge: .bottom) {
            Button {
                state.nextStep()
            } label: {
                Text("Next")
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
    
    private func shapeButton(_ shape: PillShape) -> some View {
        Button {
            state.selectedShape = shape
        } label: {
            ZStack {
                Circle()
                    .fill(state.selectedShape == shape ? Color.cyan : Color.blue)
                    .frame(width: 60, height: 60)
                
                shapeIcon(shape)
                    .foregroundStyle(.white)
                    .frame(width: 40, height: 40)
            }
        }
    }
    
    @ViewBuilder
    private func shapeIcon(_ shape: PillShape) -> some View {
        switch shape {
        case .capsule:
            Capsule()
                .frame(width: 30, height: 15)
        case .round:
            Circle()
        case .oval:
            Ellipse()
                .frame(width: 30, height: 20)
        case .oblong:
            RoundedRectangle(cornerRadius: 8)
                .frame(width: 30, height: 15)
        case .diamond:
            DiamondShape()
        case .square:
            RoundedRectangle(cornerRadius: 4)
                .frame(width: 25, height: 25)
        case .triangle:
            TriangleShape()
        case .pentagon:
            PolygonShape(sides: 5)
        case .hexagon:
            HexagonShape()
        case .heart:
            Image(systemName: "heart.fill")
        case .peanut:
            PeanutShape()
        case .bottle:
            Image(systemName: "bottle.fill")
        case .pillBottle:
            Image(systemName: "pills.fill")
        case .measuringCup:
            Image(systemName: "cup.and.saucer.fill")
        case .tube:
            Image(systemName: "tube.fill")
        }
    }
    
    private func colorSection(title: String, selectedColor: Binding<Color>) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.7))
                .padding(.horizontal)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 12) {
                ForEach(colorPalette, id: \.self) { color in
                    Button {
                        selectedColor.wrappedValue = color
                    } label: {
                        Circle()
                            .fill(color)
                            .frame(width: 44, height: 44)
                            .overlay(
                                Circle()
                                    .stroke(selectedColor.wrappedValue == color ? Color.white : Color.clear, lineWidth: 3)
                            )
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}

struct DiamondShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let size = min(rect.width, rect.height) / 2
        
        path.move(to: CGPoint(x: center.x, y: center.y - size))
        path.addLine(to: CGPoint(x: center.x + size, y: center.y))
        path.addLine(to: CGPoint(x: center.x, y: center.y + size))
        path.addLine(to: CGPoint(x: center.x - size, y: center.y))
        path.closeSubpath()
        return path
    }
}

struct TriangleShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let size = min(rect.width, rect.height) / 2
        
        path.move(to: CGPoint(x: center.x, y: center.y - size))
        path.addLine(to: CGPoint(x: center.x + size, y: center.y + size))
        path.addLine(to: CGPoint(x: center.x - size, y: center.y + size))
        path.closeSubpath()
        return path
    }
}

struct PolygonShape: Shape {
    let sides: Int
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        
        for i in 0..<sides {
            let angle = Double(i) * 2 * .pi / Double(sides) - .pi / 2
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

struct PeanutShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 4
        
        // Left circle
        path.addEllipse(in: CGRect(x: center.x - radius * 2, y: center.y - radius, width: radius * 2, height: radius * 2))
        // Right circle
        path.addEllipse(in: CGRect(x: center.x, y: center.y - radius, width: radius * 2, height: radius * 2))
        return path
    }
}

#Preview {
    NavigationStack {
        MedicationAppearanceView(state: AddMedicationFlowState())
    }
}

