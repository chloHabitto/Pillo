//
//  MedicationActionButtons.swift
//  Pillo
//
//  Action buttons for the Today screen medicine card: Log as Taken, Skip, Logged, Skipped.
//

import SwiftUI

enum MedicationActionState: Equatable {
    case defaultState
    case logged(dosage: String)
    case skipped
}

struct MedicationActionButtons: View {
    let state: MedicationActionState
    let onLogTapped: () -> Void
    let onSkipTapped: () -> Void
    let onLoggedTapped: () -> Void
    let onSkippedTapped: () -> Void

    private func triggerHaptic() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }

    var body: some View {
        HStack(spacing: 8) {
            switch state {
            case .defaultState:
                // Log as Taken
                Button {
                    triggerHaptic()
                    onLogTapped()
                } label: {
                    Text("Log as Taken")
                        .font(.appLabelLarge)
                        .foregroundStyle(Color("appOnPrimaryContainer"))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 6)
                        .background(Capsule().fill(Color("appPrimaryContainer")))
                }
                .buttonStyle(.plain)

                // Skip
                Button {
                    triggerHaptic()
                    onSkipTapped()
                } label: {
                    Text("Skip")
                        .font(.appLabelLarge)
                        .foregroundStyle(Color("appText06"))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 6)
                        .overlay(Capsule().stroke(Color("appOutline02"), lineWidth: 1.5))
                }
                .buttonStyle(.plain)

            case .logged(let dosage):
                // Logged: checkmark + "Logged: [dosage]"
                Button {
                    triggerHaptic()
                    onLoggedTapped()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .semibold))
                        Text("Logged: \(dosage)")
                            .font(.appLabelLarge)
                    }
                    .foregroundStyle(Color.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 6)
                    .background(Capsule().fill(Color.accentColor))
                }
                .buttonStyle(.plain)

            case .skipped:
                // Skipped: forward.fill + "Skipped"
                Button {
                    triggerHaptic()
                    onSkippedTapped()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "forward.fill")
                            .font(.system(size: 12))
                        Text("Skipped")
                            .font(.appLabelLarge)
                    }
                    .foregroundStyle(Color("appText06"))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 6)
                    .overlay(Capsule().stroke(Color("appOutline02"), lineWidth: 1.5))
                }
                .buttonStyle(.plain)
            }
        }
    }
}

#Preview("Default") {
    MedicationActionButtons(
        state: .defaultState,
        onLogTapped: {},
        onSkipTapped: {},
        onLoggedTapped: {},
        onSkippedTapped: {}
    )
    .padding()
}

#Preview("Logged") {
    MedicationActionButtons(
        state: .logged(dosage: "50mg"),
        onLogTapped: {},
        onSkipTapped: {},
        onLoggedTapped: {},
        onSkippedTapped: {}
    )
    .padding()
}

#Preview("Skipped") {
    MedicationActionButtons(
        state: .skipped,
        onLogTapped: {},
        onSkipTapped: {},
        onLoggedTapped: {},
        onSkippedTapped: {}
    )
    .padding()
}
