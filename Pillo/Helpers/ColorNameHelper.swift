//
//  ColorNameHelper.swift
//  Pillo
//
//  Created by Chloe Lee on 2025-12-10.
//

import SwiftUI

extension Color {
    /// Attempts to get the color name from asset catalog colors
    /// Returns nil if the color is not from the asset catalog
    func colorName() -> String? {
        // Known color names used in the app
        let knownColors: [String: Color] = [
            "PillColor-White": Color("PillColor-White"),
            "PillColor-LightGray": Color("PillColor-LightGray"),
            "PillColor-Cream": Color("PillColor-Cream"),
            "PillColor-Peach": Color("PillColor-Peach"),
            "PillColor-YellowGreen": Color("PillColor-YellowGreen"),
            "PillColor-Mint": Color("PillColor-Mint"),
            "PillColor-SkyBlue": Color("PillColor-SkyBlue"),
            "PillColor-Blue": Color("PillColor-Blue"),
            "PillColor-Lavender": Color("PillColor-Lavender"),
            "PillColor-Pink": Color("PillColor-Pink"),
            "PillColor-Red": Color("PillColor-Red"),
            "PillColor-Orange": Color("PillColor-Orange"),
            "BackgroundColor-Teal": Color("BackgroundColor-Teal"),
            "BackgroundColor-DarkGray": Color("BackgroundColor-DarkGray"),
            "BackgroundColor-OliveGold": Color("BackgroundColor-OliveGold"),
            "BackgroundColor-Coral": Color("BackgroundColor-Coral"),
            "BackgroundColor-Sage": Color("BackgroundColor-Sage"),
            "BackgroundColor-Aqua": Color("BackgroundColor-Aqua"),
            "BackgroundColor-DarkTeal": Color("BackgroundColor-DarkTeal"),
            "BackgroundColor-Purple": Color("BackgroundColor-Purple"),
            "BackgroundColor-MutedPurple": Color("BackgroundColor-MutedPurple"),
            "BackgroundColor-Salmon": Color("BackgroundColor-Salmon"),
            "BackgroundColor-DarkerRed": Color("BackgroundColor-DarkerRed"),
            "BackgroundColor-BrownCopper": Color("BackgroundColor-BrownCopper"),
        ]
        
        // Compare colors by converting to UIColor and comparing components
        let uiColor = UIColor(self)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        for (name, knownColor) in knownColors {
            let knownUIColor = UIColor(knownColor)
            var knownRed: CGFloat = 0
            var knownGreen: CGFloat = 0
            var knownBlue: CGFloat = 0
            var knownAlpha: CGFloat = 0
            knownUIColor.getRed(&knownRed, green: &knownGreen, blue: &knownBlue, alpha: &knownAlpha)
            
            // Compare with small tolerance for floating point comparison
            if abs(red - knownRed) < 0.01 &&
               abs(green - knownGreen) < 0.01 &&
               abs(blue - knownBlue) < 0.01 &&
               abs(alpha - knownAlpha) < 0.01 {
                return name
            }
        }
        
        return nil
    }
}
