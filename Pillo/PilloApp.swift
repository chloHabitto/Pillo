//
//  PilloApp.swift
//  Pillo
//
//  Created by Chloe Lee on 2025-12-10.
//

import SwiftUI
import SwiftData
import FirebaseCore

@main
struct PilloApp: App {
    @State private var appSettings = AppSettings()
    @State private var authManager: AuthManager
    @State private var syncManager = SyncManager()
    
    init() {
        // Configure Firebase FIRST, before AuthManager is created
        FirebaseApp.configure()
        
        // Now safe to create AuthManager
        _authManager = State(initialValue: AuthManager())
    }
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Medication.self,
            StockSource.self,
            MedicationGroup.self,
            DoseConfiguration.self,
            DoseComponent.self,
            IntakeLog.self,
            StockDeduction.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            print("Failed to load database, attempting to delete and recreate: \(error)")
            
            // Delete the database files
            let url = URL.applicationSupportDirectory.appending(path: "default.store")
            try? FileManager.default.removeItem(at: url)
            try? FileManager.default.removeItem(at: URL.applicationSupportDirectory.appending(path: "default.store-wal"))
            try? FileManager.default.removeItem(at: URL.applicationSupportDirectory.appending(path: "default.store-shm"))
            
            do {
                return try ModelContainer(for: schema, configurations: [modelConfiguration])
            } catch {
                fatalError("Could not create ModelContainer: \(error)")
            }
        }
    }()

    var body: some Scene {
        WindowGroup {
            Group {
                if authManager.isAuthenticated {
                    ContentView()
                        .preferredColorScheme(appSettings.colorScheme)
                } else {
                    SignInView()
                        .preferredColorScheme(.dark)
                }
            }
            .onAppear {
                syncManager.setAuthManager(authManager)
            }
            .environment(appSettings)
            .environment(authManager)
            .environment(syncManager)
        }
        .modelContainer(sharedModelContainer)
    }
}
