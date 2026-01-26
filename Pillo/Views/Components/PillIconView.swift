//
//  PillIconView.swift
//  Pillo
//
//  Created by Chloe Lee on 2025-12-10.
//

import SwiftUI
import UIKit

struct PillIconView: View {
    let medication: Medication
    let size: CGFloat
    
    init(medication: Medication, size: CGFloat = 50) {
        self.medication = medication
        self.size = size
    }
    
    var body: some View {
        Group {
            if let photoData = medication.appearancePhotoData,
               let uiImage = UIImage(data: photoData) {
                // Show custom photo if available
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: size, height: size)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
            } else if let shapeString = medication.appearanceShape,
                      let shape = PillShape(rawValue: shapeString) {
                // Show custom appearance
                ZStack {
                    if let bgColorName = medication.appearanceBackgroundColor {
                        Circle()
                            .fill(Color(bgColorName))
                            .frame(width: size, height: size)
                    }
                    
                    pillShapeView(shape: shape)
                        .frame(width: size * 0.7, height: size * 0.7)
                }
            } else {
                // Default: circle with pill icon
                ZStack {
                    Circle()
                        .fill(Color(.systemGray5))
                        .frame(width: size, height: size)
                    
                    Image(systemName: "pills.fill")
                        .font(.system(size: size * 0.4))
                        .foregroundStyle(Color.secondary)
                }
            }
        }
    }
    
    @ViewBuilder
    private func pillShapeView(shape: PillShape) -> some View {
        let leftColor = medication.appearanceLeftColor.map { Color($0) } ?? Color("PillColor-White")
        let rightColor = medication.appearanceRightColor.map { Color($0) } ?? Color("PillColor-LightGray")
        
        if shape == .capsule {
            ZStack {
                Image("Shape-capsule_left")
                    .renderingMode(.template)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundStyle(leftColor)
                Image("Shape-capsule_right")
                    .renderingMode(.template)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundStyle(rightColor)
                Image("Shape-capsule_shade")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            }
        } else if shape == .round {
            ZStack {
                Image("Shape-tablet-round")
                    .renderingMode(.template)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundStyle(leftColor)
                Image("Shape-tablet-round_shade")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                if medication.appearanceShowRoundTabletLine {
                    Image("Shape-tablet-round_line")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                }
            }
        } else if shape == .oval {
            ZStack {
                Image("Shape-tablet-oval")
                    .renderingMode(.template)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundStyle(leftColor)
                Image("Shape-tablet-oval-shade")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                if medication.appearanceShowOvalTabletLine {
                    Image("Shape-tablet-oval-line")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                }
            }
        } else if shape == .oblong {
            ZStack {
                Image("Shape-oblong")
                    .renderingMode(.template)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundStyle(leftColor)
                Image("Shape-oblong-shade")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                if medication.appearanceShowOblongTabletLine {
                    Image("Shape-oblong-line")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                }
            }
        } else if shape == .triangle {
            ZStack {
                Image("Shape-triangle")
                    .renderingMode(.template)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundStyle(leftColor)
                Image("Shape-triangle-shade")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            }
        } else if shape == .square {
            ZStack {
                Image("Shape-square")
                    .renderingMode(.template)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundStyle(leftColor)
                Image("Shape-square-shade")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            }
        } else if shape == .roundSquare {
            ZStack {
                Image("Shape-RoundSquare")
                    .renderingMode(.template)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundStyle(leftColor)
                Image("Shape-RoundSquare-Shade")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            }
        } else if shape == .hexagon {
            ZStack {
                Image("Shape-Hexagon")
                    .renderingMode(.template)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundStyle(leftColor)
                Image("Shape-Hexagon-Shade")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            }
        } else if shape == .diamond {
            ZStack {
                Image("Shape-Diamond")
                    .renderingMode(.template)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundStyle(leftColor)
                Image("Shape-Diamond-Shade")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            }
        } else if shape == .pentagon {
            ZStack {
                Image("Shape-Pentagon")
                    .renderingMode(.template)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundStyle(leftColor)
                Image("Shape-Pentagon-Shade")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            }
        } else if shape == .bottle {
            ZStack {
                Image("Shape-bottle01-body")
                    .renderingMode(.template)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundStyle(rightColor)
                Image("Shape-bottle01-cap")
                    .renderingMode(.template)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundStyle(leftColor)
                Image("Shape-bottle01-shade")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            }
        } else if shape == .bottle02 {
            ZStack {
                Image("Shape-bottle02-Neck")
                    .renderingMode(.template)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundStyle(rightColor)
                Image("Shape-bottle02-NeckShade")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                Image("Shape-bottle02-cap")
                    .renderingMode(.template)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundStyle(leftColor)
                Image("Shape-bottle02-Body")
                    .renderingMode(.template)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundStyle(rightColor)
                Image("Shape-bottle02-Shade")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            }
        } else if shape == .cream01 {
            ZStack {
                Image("Shape-Cream01-body")
                    .renderingMode(.template)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundStyle(rightColor)
                Image("Shape-Cream01-cap")
                    .renderingMode(.template)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundStyle(leftColor)
                Image("Shape-Cream01-Shade")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            }
        } else {
            Image(systemName: shape.sfSymbolPlaceholder)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundStyle(leftColor)
        }
    }
}

#Preview {
    HStack {
        // Default pill icon
        PillIconView(medication: Medication(name: "Test", form: .tablet, strength: 100, strengthUnit: "mg"))
        
        // Custom appearance
        PillIconView(medication: {
            let med = Medication(name: "Test", form: .tablet, strength: 100, strengthUnit: "mg")
            med.appearanceShape = "capsule"
            med.appearanceLeftColor = "PillColor-White"
            med.appearanceRightColor = "PillColor-LightGray"
            med.appearanceBackgroundColor = "BackgroundColor-Aqua"
            return med
        }())
    }
    .padding()
}
