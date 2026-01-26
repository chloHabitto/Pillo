//
//  AccountView.swift
//  Pillo
//
//  Created by Chloe Lee on 2025-12-10.
//

import SwiftUI
import FirebaseAuth

struct AccountView: View {
    @Environment(AppSettings.self) private var appSettings
    @Environment(AuthManager.self) private var authManager
    @State private var showingSignOutAlert = false
    
    var body: some View {
        NavigationStack {
            List {
                Section("Profile") {
                    if let email = authManager.currentUser?.email {
                        LabeledContent("Email", value: email)
                    } else {
                        LabeledContent("Signed in with", value: "Apple ID")
                    }
                    
                    if let userId = authManager.userId {
                        LabeledContent("User ID", value: String(userId.prefix(8)) + "...")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
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
                    Button(role: .destructive) {
                        showingSignOutAlert = true
                    } label: {
                        HStack {
                            Spacer()
                            Text("Sign Out")
                            Spacer()
                        }
                    }
                }
                
                Section {
                    Text("Pillo v1.0")
                        .foregroundStyle(.secondary)
                } footer: {
                    Text("This app is not a substitute for professional medical advice.")
                }
            }
            .navigationTitle("Account")
            .alert("Sign Out", isPresented: $showingSignOutAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Sign Out", role: .destructive) {
                    authManager.signOut()
                }
            } message: {
                Text("Are you sure you want to sign out?")
            }
        }
    }
}

#Preview {
    AccountView()
        .environment(AppSettings())
        .environment(AuthManager())
}

