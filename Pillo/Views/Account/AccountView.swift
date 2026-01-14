//
//  AccountView.swift
//  Pillo
//
//  Created by Chloe Lee on 2025-12-10.
//

import SwiftUI

struct AccountView: View {
    @Environment(AppSettings.self) private var appSettings
    
    var body: some View {
        NavigationStack {
            List {
                Section("Profile") {
                    Text("Profile settings coming soon")
                        .foregroundStyle(.secondary)
                }
                
                Section("App Settings") {
                    Picker("Appearance", selection: Binding(
                        get: { appSettings.appearanceMode },
                        set: { newValue in
                            appSettings.appearanceMode = newValue
                        }
                    )) {
                        ForEach(AppearanceMode.allCases) { mode in
                            Label(mode.displayName, systemImage: mode.icon)
                                .tag(mode)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                Section("Notifications") {
                    Text("Notification settings coming soon")
                        .foregroundStyle(.secondary)
                }
                
                Section("Data") {
                    Text("Export and backup coming soon")
                        .foregroundStyle(.secondary)
                }
                
                Section {
                    Text("Pillo v1.0")
                        .foregroundStyle(.secondary)
                } footer: {
                    Text("This app is not a substitute for professional medical advice.")
                }
            }
            .navigationTitle("Account")
        }
    }
}

#Preview {
    AccountView()
        .environment(AppSettings())
}

