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
                    .foregroundStyle(.white)
                    .padding(.horizontal)
                
                // When will you take this?
                VStack(alignment: .leading, spacing: 12) {
                    Text("When will you take this?")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .padding(.horizontal)
                    
                    VStack(spacing: 0) {
                        ForEach(ScheduleOption.allCases, id: \.self) { option in
                            Button {
                                state.scheduleOption = option
                            } label: {
                                HStack {
                                    Text(option.rawValue)
                                        .font(.body)
                                        .foregroundStyle(.white)
                                    
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
                                    .background(Color.white.opacity(0.1))
                            }
                        }
                    }
                    .background(Color(red: 0.17, green: 0.17, blue: 0.18))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal)
                }
                
                // At what time?
                VStack(alignment: .leading, spacing: 12) {
                    Text("At what time?")
                        .font(.headline)
                        .foregroundStyle(.white)
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
                                .colorScheme(.dark)
                                
                                Text("1 capsule")
                                    .font(.subheadline)
                                    .foregroundStyle(.white.opacity(0.7))
                                
                                Spacer()
                            }
                            .padding()
                            .background(Color(red: 0.17, green: 0.17, blue: 0.18))
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
                            .background(Color(red: 0.17, green: 0.17, blue: 0.18))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                    .padding(.horizontal)
                }
                
                // Duration
                VStack(alignment: .leading, spacing: 12) {
                    Text("Duration")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .padding(.horizontal)
                    
                    VStack(spacing: 12) {
                        HStack {
                            Text("START DATE")
                                .font(.caption)
                                .foregroundStyle(.white.opacity(0.6))
                            Spacer()
                            Text(state.startDate, style: .date)
                                .foregroundStyle(.white)
                        }
                        .padding()
                        .background(Color(red: 0.17, green: 0.17, blue: 0.18))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        
                        HStack {
                            Text("END DATE")
                                .font(.caption)
                                .foregroundStyle(.white.opacity(0.6))
                            Spacer()
                            if let endDate = state.endDate {
                                Text(endDate, style: .date)
                                    .foregroundStyle(.white)
                            } else {
                                Text("None")
                                    .foregroundStyle(.white.opacity(0.6))
                            }
                        }
                        .padding()
                        .background(Color(red: 0.17, green: 0.17, blue: 0.18))
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
        .background(Color(red: 0.11, green: 0.11, blue: 0.12))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    state.previousStep()
                } label: {
                    Image(systemName: "chevron.left")
                        .foregroundStyle(.white)
                }
            }
            
            ToolbarItem(placement: .principal) {
                VStack {
                    Text(state.medicationName)
                        .font(.headline)
                        .foregroundStyle(.white)
                    if let form = state.selectedForm, let strength = state.strengths.first {
                        Text("\(form.rawValue.capitalized), \(Int(strength.value))\(strength.unit)")
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.6))
                    }
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.white.opacity(0.6))
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
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(state.canProceedFromStep(5) ? Color.cyan : Color.gray.opacity(0.3))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .disabled(!state.canProceedFromStep(5))
            .padding()
            .background(Color(red: 0.11, green: 0.11, blue: 0.12))
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

