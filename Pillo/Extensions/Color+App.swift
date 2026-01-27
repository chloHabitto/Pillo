//
//  Color+App.swift
//  Pillo
//

import SwiftUI
import UIKit

extension Color {
    // Primary - Soft Blue
    static let appPrimary = Color(light: .init(red: 0.23, green: 0.51, blue: 0.96),
                                   dark: .init(red: 0.38, green: 0.65, blue: 0.98))
    static let appPrimaryLight = Color(light: .init(red: 0.94, green: 0.97, blue: 1.0),
                                        dark: .init(red: 0.12, green: 0.23, blue: 0.36))
    
    // Success - Green
    static let appSuccess = Color(light: .init(red: 0.13, green: 0.77, blue: 0.37),
                                   dark: .init(red: 0.29, green: 0.87, blue: 0.50))
    static let appSuccessLight = Color(light: .init(red: 0.86, green: 0.99, blue: 0.91),
                                        dark: .init(red: 0.08, green: 0.33, blue: 0.18))
    
    // Chip colors
    static let appChip = Color(light: .init(red: 0.95, green: 0.96, blue: 0.97),
                                dark: .init(red: 0.22, green: 0.25, blue: 0.32))
    
    // Helper initializer for light/dark variants
    init(light: Color, dark: Color) {
        self.init(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark ? UIColor(dark) : UIColor(light)
        })
    }
}
