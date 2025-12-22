//
//  AccountView.swift
//  Pillo
//
//  Created by Chloe Lee on 2025-12-10.
//

import SwiftUI

struct AccountView: View {
    var body: some View {
        NavigationStack {
            List {
                Section("Profile") {
                    Text("Profile settings coming soon")
                        .foregroundStyle(.secondary)
                }
                
                Section("App Settings") {
                    Text("App settings coming soon")
                        .foregroundStyle(.secondary)
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
}

