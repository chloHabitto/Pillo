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
                
                Section {
                    AppearanceCardView(appearanceMode: Binding(
                        get: { appSettings.appearanceMode },
                        set: { appSettings.appearanceMode = $0 }
                    ))
                    .listRowInsets(EdgeInsets(top: 6, leading: 0, bottom: 6, trailing: 0))
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                }
                
                Section {
                    NotificationsCardView()
                        .listRowInsets(EdgeInsets(top: 6, leading: 0, bottom: 6, trailing: 0))
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                }
                
                Section {
                    DataCardView()
                        .listRowInsets(EdgeInsets(top: 6, leading: 0, bottom: 6, trailing: 0))
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
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
            .listSectionSpacing(.compact)
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

// MARK: - Appearance Card (Light / Dark / Auto)
private struct AppearanceCardView: View {
    @Binding var appearanceMode: AppearanceMode
    
    private var displayOrder: [AppearanceMode] { [.light, .dark, .auto] }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Appearance")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundStyle(Color("appText01"))
            
            HStack(spacing: 10) {
                ForEach(displayOrder, id: \.self) { mode in
                    AppearanceOptionButton(
                        mode: mode,
                        isSelected: appearanceMode == mode
                    ) {
                        appearanceMode = mode
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color("appCardBG01"))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

private struct AppearanceOptionButton: View {
    let mode: AppearanceMode
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: mode.icon)
                    .font(.system(size: 20, weight: .medium))
                Text(mode.displayName)
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(isSelected ? Color("appPrimary") : Color("appCardBG01"))
            .foregroundStyle(isSelected ? Color("appOnPrimary") : Color("appText01"))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .strokeBorder(isSelected ? Color.clear : Color("appText06").opacity(0.4), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Notifications Card
private struct NotificationsCardView: View {
    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            Image(systemName: "bell")
                .font(.system(size: 22, weight: .medium))
                .foregroundStyle(Color("appPrimary"))
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Notifications")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color("appText01"))
                Text("Notification settings coming soon")
                    .font(.subheadline)
                    .foregroundStyle(Color("appText05"))
            }
            Spacer(minLength: 0)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color("appCardBG01"))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

// MARK: - Data Card
private struct DataCardView: View {
    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            Image(systemName: "square.and.arrow.down")
                .font(.system(size: 22, weight: .medium))
                .foregroundStyle(Color("appPrimary"))
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Data")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color("appText01"))
                Text("Export and backup coming soon")
                    .font(.subheadline)
                    .foregroundStyle(Color("appText05"))
            }
            Spacer(minLength: 0)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color("appCardBG01"))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

#Preview {
    AccountView()
        .environment(AppSettings())
        .environment(AuthManager())
}

