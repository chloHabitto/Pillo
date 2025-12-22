//
//  PilloApp.swift
//  Pillo
//
//  Created by Chloe Lee on 2025-12-10.
//

import SwiftUI
import SwiftData

@main
struct PilloApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [
            Medication.self,
            StockSource.self,
            MedicationGroup.self,
            DoseConfiguration.self,
            DoseComponent.self,
            IntakeLog.self,
            StockDeduction.self
        ])
    }
}
