//
//  HistoryView.swift
//  Pillo
//
//  Created by Chloe Lee on 2025-12-10.
//

import SwiftUI
import SwiftData

struct HistoryView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: HistoryViewModel?
    
    var body: some View {
        NavigationStack {
            Group {
                if let viewModel = viewModel {
                    HistoryContentView(viewModel: viewModel)
                } else {
                    ProgressView("Loading...")
                }
            }
            .navigationTitle("History")
            .onAppear {
                if viewModel == nil {
                    viewModel = HistoryViewModel(modelContext: modelContext)
                }
            }
        }
    }
}

struct HistoryContentView: View {
    @Bindable var viewModel: HistoryViewModel
    
    var body: some View {
        List {
            // Date picker
            Section {
                DatePicker(
                    "Select Date",
                    selection: Binding(
                        get: { viewModel.selectedDate },
                        set: { viewModel.changeDate(to: $0) }
                    ),
                    displayedComponents: .date
                )
            }
            
            // Intake logs
            Section("Intakes") {
                if viewModel.intakeLogs.isEmpty {
                    Text("No intakes logged for this date")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(viewModel.intakeLogs) { log in
                        IntakeLogRow(log: log)
                    }
                    .onDelete { indexSet in
                        for index in indexSet {
                            viewModel.undoIntake(viewModel.intakeLogs[index])
                        }
                    }
                }
            }
        }
        .refreshable {
            viewModel.loadIntakes()
        }
    }
}

struct IntakeLogRow: View {
    let log: IntakeLog
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            if let doseConfig = log.doseConfiguration {
                Text(doseConfig.displayName)
                    .font(.headline)
                
                if let group = doseConfig.group {
                    Text(group.name)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            HStack {
                Text(log.loggedAt, style: .time)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                if !log.stockDeductions.isEmpty {
                    let deducted = log.stockDeductions.filter { $0.wasDeducted }
                    if !deducted.isEmpty {
                        Text("• Stock deducted")
                            .font(.caption)
                            .foregroundStyle(.green)
                    }
                }
            }
            
            if let notes = log.notes, !notes.isEmpty {
                Text(notes)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    HistoryView()
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

