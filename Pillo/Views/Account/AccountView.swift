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
                            .listRowBackground(Color("appCardBG01"))
                    } else {
                        LabeledContent("Signed in with", value: "Apple ID")
                            .listRowBackground(Color("appCardBG01"))
                    }
                    
                    if let userId = authManager.userId {
                        LabeledContent("User ID", value: String(userId.prefix(8)) + "...")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .listRowBackground(Color("appCardBG01"))
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
                    .listRowBackground(Color("appCardBG01"))
                }
                
                Section("Notifications") {
                    Text("Notification settings coming soon")
                        .foregroundStyle(.secondary)
                        .listRowBackground(Color("appCardBG01"))
                }
                
                Section("Data") {
                    Text("Export and backup coming soon")
                        .foregroundStyle(.secondary)
                        .listRowBackground(Color("appCardBG01"))
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
                    .listRowBackground(Color("appCardBG01"))
                }
                
                Section {
                    Text("Pillo v1.0")
                        .foregroundStyle(.secondary)
                        .listRowBackground(Color("appCardBG01"))
                } footer: {
                    Text("This app is not a substitute for professional medical advice.")
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color("appSurface01"))
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

