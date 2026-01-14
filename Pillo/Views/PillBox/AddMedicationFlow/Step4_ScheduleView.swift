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
    @State private var showingDatePicker = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Calendar icon
                Image(systemName: "calendar")
                    .font(.system(size: 48))
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
                }
                
                // Duration
                VStack(alignment: .leading, spacing: 12) {
                    Text("Duration")
                        .font(.headline)
                        .foregroundStyle(Color.primary)
                        .padding(.horizontal)
                    
                    VStack(spacing: 12) {
                        HStack {
                            Text("START DATE")
                                .font(.caption)
                                .foregroundStyle(Color.secondary)
                            Spacer()
                            Text(state.startDate, style: .date)
                                .foregroundStyle(Color.primary)
                        }
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        
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
                        }
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        
                        Button {
                            showingDatePicker = true
                        } label: {
                            Text("Edit")
                                .foregroundStyle(.cyan)
                                .frame(maxWidth: .infinity)
                                .padding()
                        }
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
                    if let form = state.selectedForm, let strength = state.strengths.first {
                        Text("\(form.rawValue.capitalized), \(Int(strength.value))\(strength.unit)")
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
        .sheet(isPresented: $showingDatePicker) {
            NavigationStack {
                Form {
                    DatePicker("Start Date", selection: $state.startDate, displayedComponents: .date)
                    DatePicker("End Date", selection: Binding(
                        get: { state.endDate ?? Date() },
                        set: { state.endDate = $0 }
                    ), displayedComponents: .date)
                }
                .navigationTitle("Edit Duration")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Done") {
                            showingDatePicker = false
                        }
                    }
                }
            }
            .presentationDetents([.medium])
        }
        .safeAreaInset(edge: .bottom) {
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
            .padding()
            .background(Color(.systemBackground))
        }
        .onAppear {
            if state.times.isEmpty {
                state.addTime()
            }
        }
    }
}

#Preview {
    NavigationStack {
        ScheduleView(state: AddMedicationFlowState())
    }
}

