//
//  AddMedicationFlowState.swift
//  Pillo
//
//  Created by Chloe Lee on 2025-12-10.
//

import Foundation
import SwiftUI
import UIKit
import Observation

enum PillShape: String, CaseIterable {
    case capsule, round, oval, oblong, diamond, square, triangle, pentagon, hexagon, heart, peanut, bottle, pillBottle, measuringCup, tube
}

enum ScheduleOption: String, CaseIterable {
    case everyDay = "Every Day"
    case cyclical = "On a Cyclical Schedule"
    case specificDays = "On Specific Days of the Week"
    case everyFewDays = "Every Few Days"
    case asNeeded = "As Needed"
}

@Observable
class AddMedicationFlowState {
    // Step tracking
    var currentStep: Int = 1
    let totalSteps: Int = 6
    
    // Step 1: Medication Name
    var medicationName: String = ""
    
    // Step 2: Medication Type
    var selectedForm: MedicationForm?
    
    // Step 3: Medication Strength
    var strengths: [(value: Double, unit: String)] = []
    var currentStrengthValue: String = ""
    var currentStrengthUnit: String = "mg"
    
    // Step 4: Schedule
    var scheduleOption: ScheduleOption = .everyDay
    var times: [Date] = []
    var startDate: Date = Date()
    var endDate: Date? = nil
    var specificDaysOfWeek: Set<Int> = [] // 1 = Sunday, 2 = Monday, etc.
    var daysInterval: Int = 1 // For "Every Few Days"
    
    // Step 5: Appearance
    var selectedShape: PillShape = .capsule
    var leftColor: Color = .white
    var rightColor: Color = .white
    var backgroundColor: Color = .blue
    var selectedPhoto: UIImage? = nil
    
    // Step 6: Review
    var displayName: String = ""
    var notes: String = ""
    
    // Navigation
    func nextStep() {
        if currentStep < totalSteps {
            currentStep += 1
        }
    }
    
    func previousStep() {
        if currentStep > 1 {
            currentStep -= 1
        }
    }
    
    func canProceedFromStep(_ step: Int) -> Bool {
        switch step {
        case 1:
            return !medicationName.trimmingCharacters(in: .whitespaces).isEmpty
        case 2:
            return selectedForm != nil
        case 3:
            return !strengths.isEmpty
        case 4:
            return !times.isEmpty
        case 5:
            return true // Appearance is optional
        case 6:
            return true
        default:
            return false
        }
    }
    
    func addStrength() {
        guard let value = Double(currentStrengthValue), value > 0 else { return }
        let newStrength = (value: value, unit: currentStrengthUnit)
        if !strengths.contains(where: { $0.value == newStrength.value && $0.unit == newStrength.unit }) {
            strengths.append(newStrength)
            currentStrengthValue = ""
        }
    }
    
    func removeStrength(at index: Int) {
        guard index < strengths.count else { return }
        strengths.remove(at: index)
    }
    
    func addTime() {
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents([.hour, .minute], from: now)
        var defaultTime = calendar.date(bySettingHour: 9, minute: 0, second: 0, of: Date()) ?? Date()
        
        if let hour = components.hour, let minute = components.minute {
            defaultTime = calendar.date(bySettingHour: hour, minute: minute, second: 0, of: Date()) ?? defaultTime
        }
        
        times.append(defaultTime)
    }
    
    func removeTime(at index: Int) {
        guard index < times.count else { return }
        times.remove(at: index)
    }
}

