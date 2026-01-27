//
//  AppSettings.swift
//  Pillo
//
//  Created by Chloe Lee on 2025-12-10.
//

import SwiftUI

enum AppearanceMode: String, CaseIterable, Identifiable {
    case auto, light, dark
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .auto:
            return "Auto"
        case .light:
            return "Light"
        case .dark:
            return "Dark"
        }
    }
    
    var icon: String {
        switch self {
        case .auto:
            return "circle.lefthalf.filled"
        case .light:
            return "sun.max.fill"
        case .dark:
            return "moon.fill"
        }
    }
}

@Observable
class AppSettings {
    @ObservationIgnored
    @AppStorage("appearanceMode") var appearanceModeRaw: String = AppearanceMode.auto.rawValue

    /// Observable trigger so UI updates when appearance changes (AppStorage is observation-ignored).
    private var appearanceVersion: Int = 0

    var appearanceMode: AppearanceMode {
        get {
            _ = appearanceVersion
            return AppearanceMode(rawValue: appearanceModeRaw) ?? .auto
        }
        set {
            guard newValue != appearanceMode else { return }
            appearanceModeRaw = newValue.rawValue
            appearanceVersion += 1
        }
    }

    var colorScheme: ColorScheme? {
        _ = appearanceVersion
        switch appearanceMode {
        case .auto:
            return nil
        case .light:
            return .light
        case .dark:
            return .dark
        }
    }
}
