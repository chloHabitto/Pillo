//
//  Step4_ScheduleView.swift
//  Pillo
//
//  Created by Chloe Lee on 2025-12-10.
//

import SwiftUI

struct ScheduleView: View {
    @Bindable var state: AddMedicationFlowState
    @Environment(\.dismiss) private var dismiss
    @State private var showingTimePicker = false
    @State private var showingEndDatePicker = false
    @State private var showingCustomTimeFramePicker = false
    @State private var editingTimeFrameIndex: Int? = nil
    
    private var formDisplayName: String {
        guard let form = state.selectedForm else { return "" }
        if form == .other, let customName = state.customFormName, !customName.isEmpty {
            return customName.capitalized
        }
        return form.rawValue.capitalized
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Calendar icon
                Image("calendar")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 48, height: 48)
                    .foregroundStyle(.cyan)
                    .padding(.top, 20)
                
                // Title
                Text("Set a Schedule")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(Color.primary)
                    .padding(.horizontal)
                
                // When will you take this?
                VStack(alignment: .leading, spacing: 12) {
                    Text("When will you take this?")
                        .font(.headline)
                        .foregroundStyle(Color.primary)
                        .padding(.horizontal)
                    
                    VStack(spacing: 0) {
                        ForEach(ScheduleOption.allCases, id: \.self) { option in
                            Button {
                                state.scheduleOption = option
                            } label: {
                                HStack {
                                    Text(option.rawValue)
                                        .font(.body)
                                        .foregroundStyle(Color.primary)
                                    
                                    Spacer()
                                    
                                    if state.scheduleOption == option {
                                        Image(systemName: "checkmark")
                                            .foregroundStyle(.cyan)
                                    }
                                }
                                .padding()
                                .contentShape(Rectangle())
                                .background(state.scheduleOption == option ? Color.cyan.opacity(0.1) : Color.clear)
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            if option != ScheduleOption.allCases.last {
                                Divider()
                                    .background(Color(.separator))
                            }
                        }
                    }
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal)
                }
                
                // At what time?
                VStack(alignment: .leading, spacing: 12) {
                    Text("At what time?")
                        .font(.headline)
                        .foregroundStyle(Color.primary)
                        .padding(.horizontal)
                    
                    // Time selection mode picker
                    Picker("Mode", selection: $state.timeSelectionMode) {
                        ForEach(TimeSelectionMode.allCases, id: \.self) { mode in
                            Text(mode.rawValue).tag(mode)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                    
                    if state.timeSelectionMode == .specificTime {
                        // Specific Time Mode
                        VStack(spacing: 8) {
                            ForEach(Array(state.times.enumerated()), id: \.offset) { index, time in
                                HStack {
                                    Button {
                                        state.removeTime(at: index)
                                    } label: {
                                        Image(systemName: "minus.circle.fill")
                                            .foregroundStyle(.red)
                                    }
                                    
                                    DatePicker("", selection: Binding(
                                        get: { state.times[index] },
                                        set: { state.times[index] = $0 }
                                    ), displayedComponents: .hourAndMinute)
                                    .labelsHidden()
                                    
                                    Text("1 capsule")
                                        .font(.subheadline)
                                        .foregroundStyle(Color.secondary)
                                    
                                    Spacer()
                                }
                                .padding()
                                .background(Color(.secondarySystemBackground))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                            
                            Button {
                                state.addTime()
                            } label: {
                                HStack {
                                    Image(systemName: "plus.circle.fill")
                                        .foregroundStyle(.green)
                                    Text("Add a Time")
                                        .foregroundStyle(.cyan)
                                }
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color(.secondarySystemBackground))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                        }
                        .padding(.horizontal)
                    } else {
                        // Time Frame Mode
                        VStack(spacing: 8) {
                            ForEach(Array(state.timeFrames.enumerated()), id: \.element.id) { index, timeFrame in
                                HStack {
                                    Button {
                                        state.removeTimeFrame(at: index)
                                    } label: {
                                        Image(systemName: "minus.circle.fill")
                                            .foregroundStyle(.red)
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        if timeFrame.type == .custom {
                                            if let startTime = timeFrame.startTime, let endTime = timeFrame.endTime {
                                                Text(formatTimeRange(start: startTime, end: endTime))
                                                    .font(.body)
                                                    .foregroundStyle(Color.primary)
                                            } else {
                                                Text("Tap to set custom range")
                                                    .font(.body)
                                                    .foregroundStyle(Color.secondary)
                                            }
                                        } else {
                                            Text(timeFrame.type.rawValue)
                                                .font(.body)
                                                .foregroundStyle(Color.primary)
                                            Text(timeFrame.type.displayRange)
                                                .font(.caption)
                                                .foregroundStyle(Color.secondary)
                                        }
                                    }
                                    
                                    Spacer()
                                    
                                    if timeFrame.type == .custom {
                                        Button {
                                            editingTimeFrameIndex = index
                                            showingCustomTimeFramePicker = true
                                        } label: {
                                            Image(systemName: "pencil.circle.fill")
                                                .foregroundStyle(.cyan)
                                        }
                                    }
                                }
                                .padding()
                                .background(Color(.secondarySystemBackground))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                            
                            // Add Time Frame Button
                            Menu {
                                ForEach(TimeFrameType.allCases, id: \.self) { frameType in
                                    Button {
                                        if frameType == .custom {
                                            // For custom, create with nil times and show picker
                                            let customFrame = TimeFrameSelection(type: .custom)
                                            state.addTimeFrame(customFrame)
                                            editingTimeFrameIndex = state.timeFrames.count - 1
                                            showingCustomTimeFramePicker = true
                                        } else {
                                            // For predefined, use default times
                                            let calendar = Calendar.current
                                            let startHour = frameType.defaultStartHour
                                            let endHour = frameType.defaultEndHour
                                            
                                            let startTime = calendar.date(bySettingHour: startHour, minute: 0, second: 0, of: Date()) ?? Date()
                                            let endTime = calendar.date(bySettingHour: endHour, minute: 0, second: 0, of: Date()) ?? Date()
                                            
                                            let timeFrame = TimeFrameSelection(
                                                type: frameType,
                                                startTime: startTime,
                                                endTime: endTime
                                            )
                                            state.addTimeFrame(timeFrame)
                                        }
                                    } label: {
                                        Text(frameType.menuDisplayTitle)
                                    }
                                }
                            } label: {
                                HStack {
                                    Image(systemName: "plus.circle.fill")
                                        .foregroundStyle(.green)
                                    Text("Add a Time Frame")
                                        .foregroundStyle(.cyan)
                                }
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color(.secondarySystemBackground))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                
                // Duration
                VStack(alignment: .leading, spacing: 12) {
                    Text("Duration")
                        .font(.headline)
                        .foregroundStyle(Color.primary)
                        .padding(.horizontal)
                    
                    VStack(spacing: 12) {
                        // Start Date - inline DatePicker
                        HStack {
                            Text("START DATE")
                                .font(.caption)
                                .foregroundStyle(Color.secondary)
                            Spacer()
                            DatePicker("", selection: $state.startDate, displayedComponents: .date)
                                .labelsHidden()
                                .datePickerStyle(.compact)
                        }
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        
                        // End Date - tappable button that opens sheet
                        Button {
                            showingEndDatePicker = true
                        } label: {
                            HStack {
                                Text("END DATE")
                                    .font(.caption)
                                    .foregroundStyle(Color.secondary)
                                Spacer()
                                if let endDate = state.endDate {
                                    Text(endDate, style: .date)
                                        .foregroundStyle(Color.primary)
                                } else {
                                    Text("None")
                                        .foregroundStyle(Color.secondary)
                                }
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundStyle(Color.secondary)
                            }
                            .padding()
                            .background(Color(.secondarySystemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .padding(.horizontal)
                }
                
                Spacer(minLength: 100)
            }
        }
        .background(Color(.systemBackground))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    state.previousStep()
                } label: {
                    Image(systemName: "chevron.left")
                        .foregroundStyle(Color.primary)
                }
            }
            
            ToolbarItem(placement: .principal) {
                VStack {
                    Text(state.medicationName)
                        .font(.headline)
                        .foregroundStyle(Color.primary)
                    if state.selectedForm != nil, let strength = state.strengths.first {
                        Text("\(formDisplayName), \(Int(strength.value))\(strength.unit)")
                            .font(.caption)
                            .foregroundStyle(Color.secondary)
                    }
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(Color.secondary)
                }
            }
        }
        .sheet(isPresented: $showingEndDatePicker) {
            EndDatePickerSheet(
                endDate: $state.endDate,
                startDate: state.startDate,
                isPresented: $showingEndDatePicker
            )
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
        }
        .safeAreaInset(edge: .bottom) {
            HStack(spacing: 12) {
                Button {
                    state.nextStep()
                } label: {
                    Text("Skip")
                        .font(.headline)
                        .foregroundStyle(Color.secondary)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                
                Button {
                    state.nextStep()
                } label: {
                    Text("Next")
                        .font(.headline)
                        .foregroundStyle(state.canProceedFromStep(5) ? Color.white : Color.secondary)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(state.canProceedFromStep(5) ? Color.cyan : Color(.tertiarySystemFill))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .disabled(!state.canProceedFromStep(5))
            }
            .padding()
            .background(Color(.systemBackground))
        }
        .sheet(isPresented: $showingCustomTimeFramePicker) {
            if let index = editingTimeFrameIndex, index < state.timeFrames.count {
                CustomTimeFramePickerView(
                    timeFrame: Binding(
                        get: { state.timeFrames[index] },
                        set: { state.updateTimeFrame(at: index, with: $0) }
                    ),
                    isPresented: $showingCustomTimeFramePicker
                )
            }
        }
        .onAppear {
            if state.timeSelectionMode == .specificTime && state.times.isEmpty {
                state.addTime()
            } else if state.timeSelectionMode == .timeFrame && state.timeFrames.isEmpty {
                // Optionally add a default time frame
            }
        }
        .onChange(of: state.timeSelectionMode) { oldMode, newMode in
            // When switching modes, clear the other mode's data if needed
            if newMode == .specificTime && state.times.isEmpty {
                state.addTime()
            }
        }
    }
    
    private func formatTimeRange(start: Date, end: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        
        let startString = formatter.string(from: start)
        let endString = formatter.string(from: end)
        
        return "\(startString) - \(endString)"
    }
}

// End Date Picker Sheet
struct EndDatePickerSheet: View {
    @Binding var endDate: Date?
    let startDate: Date
    @Binding var isPresented: Bool
    
    @State private var selectedDate: Date
    
    init(endDate: Binding<Date?>, startDate: Date, isPresented: Binding<Bool>) {
        self._endDate = endDate
        self.startDate = startDate
        self._isPresented = isPresented
        _selectedDate = State(initialValue: endDate.wrappedValue ?? Calendar.current.date(byAdding: .day, value: 30, to: startDate) ?? Date())
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    // No End Date option - styled as a card
                    Button {
                        endDate = nil
                        isPresented = false
                    } label: {
                        HStack {
                            Text("No End Date")
                                .font(.body)
                                .foregroundStyle(Color.primary)
                            Spacer()
                            if endDate == nil {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(Color.cyan)
                                    .fontWeight(.semibold)
                            }
                        }
                        .padding()
                        .background(endDate == nil ? Color.cyan.opacity(0.1) : Color(.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.horizontal)
                    
                    // Divider with "or" text
                    HStack {
                        Rectangle()
                            .fill(Color(.separator))
                            .frame(height: 1)
                        Text("or select a date")
                            .font(.caption)
                            .foregroundStyle(Color.secondary)
                        Rectangle()
                            .fill(Color(.separator))
                            .frame(height: 1)
                    }
                    .padding(.horizontal)
                    
                    // Calendar picker - styled as a card
                    VStack {
                        DatePicker(
                            "Select End Date",
                            selection: $selectedDate,
                            in: startDate...,
                            displayedComponents: .date
                        )
                        .datePickerStyle(.graphical)
                        .labelsHidden()
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal)
                    .onChange(of: selectedDate) { _, newDate in
                        endDate = newDate
                        isPresented = false
                    }
                }
                .padding(.top, 8)
            }
            .background(Color(.systemBackground))
            .navigationTitle("End Date")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        isPresented = false
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(Color.secondary)
                    }
                }
            }
        }
    }
}

// Custom Time Frame Picker View
struct CustomTimeFramePickerView: View {
    @Binding var timeFrame: TimeFrameSelection
    @Binding var isPresented: Bool
    @State private var startTime: Date
    @State private var endTime: Date
    
    init(timeFrame: Binding<TimeFrameSelection>, isPresented: Binding<Bool>) {
        self._timeFrame = timeFrame
        self._isPresented = isPresented
        
        let calendar = Calendar.current
        let defaultStart = calendar.date(bySettingHour: 5, minute: 0, second: 0, of: Date()) ?? Date()
        let defaultEnd = calendar.date(bySettingHour: 8, minute: 0, second: 0, of: Date()) ?? Date()
        
        _startTime = State(initialValue: timeFrame.wrappedValue.startTime ?? defaultStart)
        _endTime = State(initialValue: timeFrame.wrappedValue.endTime ?? defaultEnd)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Start Time")) {
                    DatePicker("Start", selection: $startTime, displayedComponents: .hourAndMinute)
                }
                
                Section(header: Text("End Time")) {
                    DatePicker("End", selection: $endTime, displayedComponents: .hourAndMinute)
                }
                
                Section {
                    Text("Select the time range when you can take this medication.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Custom Time Range")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        timeFrame.startTime = startTime
                        timeFrame.endTime = endTime
                        isPresented = false
                    }
                }
            }
        }
        .presentationDetents([.medium])
    }
}

#Preview {
    NavigationStack {
        ScheduleView(state: AddMedicationFlowState())
    }
}

