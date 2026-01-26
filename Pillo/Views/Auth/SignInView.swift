//
//  SignInView.swift
//  Pillo
//
//  Created by Chloe Lee on 2025-12-10.
//

import SwiftUI
import AuthenticationServices

struct SignInView: View {
    @Environment(AuthManager.self) private var authManager
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            // App branding
            VStack(spacing: 16) {
                Image(systemName: "pill.fill")
                    .font(.system(size: 72))
                    .foregroundStyle(.cyan)
                
                Text("Pillo")
                    .font(.largeTitle.bold())
                
                Text("Track your medications with ease")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
            
            // Sign in section
            VStack(spacing: 16) {
                SignInWithAppleButton(.signIn) { request in
                    let appleRequest = authManager.signInWithApple()
                    request.requestedScopes = appleRequest.requestedScopes
                    request.nonce = appleRequest.nonce
                } onCompletion: { result in
                    authManager.handleAppleSignIn(result: result)
                }
                .signInWithAppleButtonStyle(.white)
                .frame(height: 50)
                
                if authManager.isLoading {
                    ProgressView()
                        .tint(.cyan)
                }
                
                if let error = authManager.errorMessage {
                    Text(error)
                        .font(.caption)
                        .foregroundStyle(.red)
                        .multilineTextAlignment(.center)
                }
            }
            .padding(.horizontal, 32)
            
            Spacer()
                .frame(height: 60)
        }
        .padding()
    }
}

#Preview {
    SignInView()
        .environment(AuthManager())
}
