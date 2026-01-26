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
    // Common shapes (row 1 & 2)
    case capsule, round, oval, oblong
    case bottle, bottle02, cream01, roundSquare, pillBottle, measuringCup, tube
    
    // More shapes
    case diamond, square, triangle, pentagon
    case hexagon, heart, rectangle, halfCircle
    case trapezoid, blisterPack, bowtie, disc, cylinder
    
    var sfSymbolPlaceholder: String {
        switch self {
        case .capsule: return "" // Uses actual images
        case .round: return "circle.fill"
        case .oval: return "oval.fill"
        case .oblong: return "capsule.fill"
        case .bottle: return "waterbottle.fill"
        case .bottle02: return "waterbottle.fill"
        case .cream01: return "capsule.fill"
        case .roundSquare: return "square.fill"
        case .pillBottle: return "pills.fill"
        case .measuringCup: return "cup.and.saucer.fill"
        case .tube: return "cylinder.fill"
        case .diamond: return "diamond.fill"
        case .square: return "square.fill"
        case .triangle: return "triangle.fill"
        case .pentagon: return "pentagon.fill"
        case .hexagon: return "hexagon.fill"
        case .heart: return "heart.fill"
        case .rectangle: return "rectangle.fill"
        case .halfCircle: return "semicircle.fill"
        case .trapezoid: return "trapezoid.and.line.vertical.fill"
        case .blisterPack: return "rectangle.split.2x2.fill"
        case .bowtie: return "bowtie.fill"
        case .disc: return "circle.fill"
        case .cylinder: return "cylinder.fill"
        }
    }
    
    var isTwoTone: Bool {
        self == .capsule || self == .bottle || self == .bottle02 || self == .cream01
    }
    
    static var commonShapes: [PillShape] {
        [.capsule, .round, .oval, .oblong, .triangle, .square, .bottle, .bottle02, .cream01, .roundSquare]
    }
    
    static var moreShapes: [PillShape] {
        [.diamond, .pentagon, .hexagon]
    }
}

enum ScheduleOption: String, CaseIterable {
    case everyDay = "Every Day"
    case cyclical = "On a Cyclical Schedule"
    case specificDays = "On Specific Days of the Week"
    case everyFewDays = "Every Few Days"
    case asNeeded = "As Needed"
}

enum DosingType: String, CaseIterable {
    case fixed = "Fixed"
    case flexible = "Flexible"
}

enum TimeSelectionMode: String, CaseIterable {
    case specificTime = "Specific Time"
    case timeFrame = "Time Frame"
}

struct TimeFrameSelection: Identifiable, Equatable {
    var id: UUID
    var type: TimeFrameType
    var startTime: Date?
    var endTime: Date?
    
    init(id: UUID = UUID(), type: TimeFrameType, startTime: Date? = nil, endTime: Date? = nil) {
        self.id = id
        self.type = type
        self.startTime = startTime
        self.endTime = endTime
    }
}

enum TimeFrameType: String, CaseIterable {
    case morning = "Morning"
    case afternoon = "Afternoon"
    case evening = "Evening"
    case night = "Night"
    case custom = "Custom"
    
    var defaultStartHour: Int {
        switch self {
        case .morning: return 5
        case .afternoon: return 12
        case .evening: return 17
        case .night: return 21
        case .custom: return 0
        }
    }
    
    var defaultEndHour: Int {
        switch self {
        case .morning: return 12
        case .afternoon: return 17
        case .evening: return 21
        case .night: return 5
        case .custom: return 8
        }
    }
    
    var displayRange: String {
        switch self {
        case .morning: return "5:00 AM - 12:00 PM"
        case .afternoon: return "12:00 PM - 5:00 PM"
        case .evening: return "5:00 PM - 9:00 PM"
        case .night: return "9:00 PM - 5:00 AM"
        case .custom: return "Custom Range"
        }
    }
    
    var menuDisplayTitle: String {
        switch self {
        case .custom:
            return "Custom"
        default:
            return "\(rawValue) (\(displayRange))"
        }
    }
}

struct DoseOptionInput: Identifiable {
    var id: UUID
    var components: [(strengthIndex: Int, quantity: Int)] // Index into strengths array
    
    init(id: UUID = UUID(), components: [(strengthIndex: Int, quantity: Int)]) {
        self.id = id
        self.components = components
    }
    
    func totalDose(strengths: [(value: Double, unit: String)]) -> Double {
        components.reduce(0) { total, comp in
            guard comp.strengthIndex < strengths.count else { return total }
            return total + (strengths[comp.strengthIndex].value * Double(comp.quantity))
        }
    }
    
    func displayName(strengths: [(value: Double, unit: String)]) -> String {
        let total = totalDose(strengths: strengths)
        let unit = strengths.first?.unit ?? "mg"
        return "\(Int(total))\(unit)"
    }
}

@Observable
class AddMedicationFlowState {
    // Step tracking
    var currentStep: Int = 1
    let totalSteps: Int = 8
    
    // Step 1: Medication Name
    var medicationName: String = ""
    
    // Step 2: Medication Strength
    var strengths: [(value: Double, unit: String)] = []
    var currentStrengthValue: String = ""
    var currentStrengthUnit: String = "mg"
    var customStrengthUnit: String? = nil
    
    // Step 3: Dosing Type
    var dosingType: DosingType = .fixed
    var doseOptions: [DoseOptionInput] = []
    var fixedDoseComponents: [(strengthIndex: Int, quantity: Int)] = [] // For fixed dosing
    
    // Step 4: Schedule
    var scheduleOption: ScheduleOption = .everyDay
    var timeSelectionMode: TimeSelectionMode = .specificTime
    var times: [Date] = [] // For specific time mode
    var timeFrames: [TimeFrameSelection] = [] // For time frame mode
    var startDate: Date = Date()
    var endDate: Date? = nil
    var specificDaysOfWeek: Set<Int> = [] // 1 = Sunday, 2 = Monday, etc.
    var daysInterval: Int = 1 // For "Every Few Days"
    
    // Step 5: Medication Type
    var selectedForm: MedicationForm?
    var customFormName: String? = nil
    
    // Step 6: Shape Selection
    var selectedShape: PillShape = .capsule {
        didSet {
            // Set default colors when shape changes
            setDefaultColors(for: selectedShape)
        }
    }
    var showRoundTabletLine: Bool = false
    var showOvalTabletLine: Bool = false
    var showOblongTabletLine: Bool = false
    
    // Step 7: Color Selection
    var leftColor: Color = Color("PillColor-White")
    var rightColor: Color = Color("PillColor-LightGray")
    var backgroundColor: Color = Color("BackgroundColor-Aqua")
    var selectedPhoto: UIImage? = nil
    
    // Step 8: Review
    var displayName: String = ""
    var notes: String = ""
    
    init() {
        // Initialize with default colors for the default shape (capsule)
        setDefaultColors(for: selectedShape)
    }
    
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
        case 1: // Name
            return !medicationName.trimmingCharacters(in: .whitespaces).isEmpty
        case 2: // Strength (was step 3)
            return !strengths.isEmpty
        case 3: // Dosing Type (was step 4)
            if dosingType == .fixed {
                return !fixedDoseComponents.isEmpty && fixedDoseComponents.contains { $0.quantity > 0 }
            } else {
                return !doseOptions.isEmpty
            }
        case 4: // Schedule (was step 5)
            if timeSelectionMode == .specificTime {
                return !times.isEmpty
            } else {
                return !timeFrames.isEmpty
            }
        case 5: // Type (was step 2)
            return selectedForm != nil
        case 6: // Shape
            return true
        case 7: // Color
            return true
        case 8: // Review
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
            strengths.sort { $0.value < $1.value }  // Sort lowest to highest
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
    
    func addTimeFrame(_ timeFrame: TimeFrameSelection) {
        timeFrames.append(timeFrame)
    }
    
    func removeTimeFrame(at index: Int) {
        guard index < timeFrames.count else { return }
        timeFrames.remove(at: index)
    }
    
    func updateTimeFrame(at index: Int, with timeFrame: TimeFrameSelection) {
        guard index < timeFrames.count else { return }
        timeFrames[index] = timeFrame
    }
    
    // Helper to get all times from both modes (for compatibility)
    func getAllTimes() -> [Date] {
        if timeSelectionMode == .specificTime {
            return times
        } else {
            // Convert time frames to representative times
            let calendar = Calendar.current
            var result: [Date] = []
            
            for timeFrame in timeFrames {
                switch timeFrame.type {
                case .custom:
                    if let startTime = timeFrame.startTime {
                        result.append(startTime)
                    }
                default:
                    // Use the default start hour for predefined time frames
                    let hour = timeFrame.type.defaultStartHour
                    if let date = calendar.date(bySettingHour: hour, minute: 0, second: 0, of: Date()) {
                        result.append(date)
                    }
                }
            }
            return result
        }
    }
    
    // Dosing type helpers
    func addDoseOption(_ option: DoseOptionInput) {
        doseOptions.append(option)
    }
    
    func removeDoseOption(at index: Int) {
        guard index < doseOptions.count else { return }
        doseOptions.remove(at: index)
    }
    
    func updateFixedDoseComponent(strengthIndex: Int, quantity: Int) {
        if let index = fixedDoseComponents.firstIndex(where: { $0.strengthIndex == strengthIndex }) {
            if quantity > 0 {
                fixedDoseComponents[index] = (strengthIndex: strengthIndex, quantity: quantity)
            } else {
                fixedDoseComponents.remove(at: index)
            }
        } else if quantity > 0 {
            fixedDoseComponents.append((strengthIndex: strengthIndex, quantity: quantity))
        }
    }
    
    func getFixedDoseQuantity(for strengthIndex: Int) -> Int {
        fixedDoseComponents.first(where: { $0.strengthIndex == strengthIndex })?.quantity ?? 0
    }
    
    func getFixedDoseTotal() -> Double {
        fixedDoseComponents.reduce(0) { total, comp in
            guard comp.strengthIndex < strengths.count else { return total }
            return total + (strengths[comp.strengthIndex].value * Double(comp.quantity))
        }
    }
    
    // Set default colors based on selected shape
    func setDefaultColors(for shape: PillShape) {
        backgroundColor = Color("BackgroundColor-Aqua")
        
        if shape == .capsule {
            // Capsule: left side white, right side light gray
            leftColor = Color("PillColor-White")
            rightColor = Color("PillColor-LightGray")
        } else if shape == .bottle {
            // Bottle: cap white, body light gray
            leftColor = Color("PillColor-White")  // Cap color
            rightColor = Color("PillColor-LightGray")  // Bottle body color
        } else if shape == .bottle02 {
            // Bottle02: cap white, body light gray
            leftColor = Color("PillColor-White")  // Cap color
            rightColor = Color("PillColor-LightGray")  // Bottle body color
        } else if shape == .cream01 {
            // Cream01: cap white, body white
            leftColor = Color("PillColor-White")  // Cap color
            rightColor = Color("PillColor-White")  // Body color
        } else {
            // Single color shapes: white
            leftColor = Color("PillColor-White")
            rightColor = Color("PillColor-White")
        }
    }
}

