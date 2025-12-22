//
//  HistoryViewModel.swift
//  Pillo
//
//  Created by Chloe Lee on 2025-12-10.
//

import Foundation
import SwiftData
import Observation

@Observable
class HistoryViewModel {
    private var modelContext: ModelContext
    private var intakeManager: IntakeManager
    private var stockManager: StockManager
    
    var selectedDate: Date = Date()
    var intakeLogs: [IntakeLog] = []
    var isLoading: Bool = false
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        self.intakeManager = IntakeManager(modelContext: modelContext)
        self.stockManager = StockManager(modelContext: modelContext)
        loadIntakes()
    }
    
    func loadIntakes() {
        isLoading = true
        intakeLogs = intakeManager.getIntakes(for: selectedDate)
        isLoading = false
    }
    
    func changeDate(to date: Date) {
        selectedDate = date
        loadIntakes()
    }
    
    func undoIntake(_ log: IntakeLog) {
        intakeManager.undoIntake(log: log)
        loadIntakes()
    }
    
    // Get intakes grouped by time frame
    var intakesByTimeFrame: [TimeFrame: [IntakeLog]] {
        Dictionary(grouping: intakeLogs) { log in
            log.doseConfiguration?.group?.timeFrame ?? .morning
        }
    }
    
    // Get all intakes for a date range (for calendar view)
    func getIntakeHistory(from startDate: Date, to endDate: Date) -> [Date: [IntakeLog]] {
        let descriptor = FetchDescriptor<IntakeLog>(
            predicate: #Predicate<IntakeLog> { log in
                log.scheduledFor >= startDate && log.scheduledFor <= endDate
            },
            sortBy: [SortDescriptor(\.scheduledFor, order: .forward)]
        )
        
        guard let logs = try? modelContext.fetch(descriptor) else {
            return [:]
        }
        
        let calendar = Calendar.current
        return Dictionary(grouping: logs) { log in
            calendar.startOfDay(for: log.scheduledFor)
        }
    }
    
    // Get dates with intakes in a month (for calendar indicators)
    func getDatesWithIntakes(in month: Date) -> Set<Date> {
        let calendar = Calendar.current
        guard let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: month)),
              let endOfMonth = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: startOfMonth) else {
            return []
        }
        
        let history = getIntakeHistory(from: startOfMonth, to: endOfMonth)
        return Set(history.keys)
    }
}

