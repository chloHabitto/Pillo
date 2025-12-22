import SwiftUI

struct WeeklyCalendarView: View {
    @Binding var selectedDate: Date
    @State private var currentWeekOffset: Int = 0
    
    private let calendar = Calendar.current
    
    var body: some View {
        VStack(spacing: 8) {
            // Header with month/year and Today button
            headerView
            
            // Weekly calendar strip
            weeklyCalendarView
        }
        .padding(.horizontal)
        .onChange(of: selectedDate) { oldValue, newValue in
            // Sync week offset when selectedDate changes externally
            let today = Date()
            guard let todayWeekStart = calendar.dateInterval(of: .weekOfYear, for: today)?.start,
                  let selectedWeekStart = calendar.dateInterval(of: .weekOfYear, for: newValue)?.start else {
                return
            }
            
            let weeksDifference = calendar.dateComponents([.weekOfYear], from: todayWeekStart, to: selectedWeekStart).weekOfYear ?? 0
            if currentWeekOffset != weeksDifference {
                currentWeekOffset = weeksDifference
            }
        }
        .onAppear {
            // Initialize week offset on appear
            let today = Date()
            guard let todayWeekStart = calendar.dateInterval(of: .weekOfYear, for: today)?.start,
                  let selectedWeekStart = calendar.dateInterval(of: .weekOfYear, for: selectedDate)?.start else {
                return
            }
            
            let weeksDifference = calendar.dateComponents([.weekOfYear], from: todayWeekStart, to: selectedWeekStart).weekOfYear ?? 0
            currentWeekOffset = weeksDifference
        }
    }
    
    // MARK: - Header
    
    private var headerView: some View {
        HStack {
            Text(monthYearString(for: selectedDate))
                .font(.headline)
            
            Spacer()
            
            // Show "Today" button when not viewing today
            if !calendar.isDateInToday(selectedDate) {
                Button {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        selectedDate = Date()
                        currentWeekOffset = 0
                    }
                } label: {
                    Text("Today")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(Color.accentColor)
                }
            }
        }
    }
    
    // MARK: - Weekly Calendar
    
    private var weeklyCalendarView: some View {
        TabView(selection: $currentWeekOffset) {
            ForEach(-52...52, id: \.self) { weekOffset in
                weekView(for: weekOffset)
                    .tag(weekOffset)
            }
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        .frame(height: 70)
        .onChange(of: currentWeekOffset) { oldValue, newValue in
            // Add haptic feedback when scrolling between weeks
            if oldValue != newValue {
                let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                impactFeedback.impactOccurred()
            }
        }
    }
    
    // MARK: - Week View
    
    private func weekView(for weekOffset: Int) -> some View {
        HStack(spacing: 4) {
            ForEach(daysOfWeek(for: weekOffset), id: \.timeIntervalSince1970) { date in
                dayButton(for: date)
            }
        }
    }
    
    private func dayButton(for date: Date) -> some View {
        let isSelected = calendar.isDate(date, inSameDayAs: selectedDate)
        let isToday = calendar.isDateInToday(date)
        
        return Button {
            selectDate(date)
        } label: {
            VStack(spacing: 4) {
                // Day abbreviation (Mon, Tue, etc.)
                Text(dayAbbreviation(for: date))
                    .font(.caption2)
                    .foregroundStyle(isSelected ? .white.opacity(0.8) : .secondary)
                
                // Day number
                Text("\(calendar.component(.day, from: date))")
                    .font(.body)
                    .fontWeight(isToday ? .bold : .regular)
                    .foregroundStyle(isSelected ? .white : (isToday ? Color.accentColor : .primary))
            }
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.accentColor : (isToday ? Color.accentColor.opacity(0.1) : Color.clear))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isToday && !isSelected ? Color.accentColor : Color.clear, lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - Helper Functions
    
    private func daysOfWeek(for weekOffset: Int) -> [Date] {
        let today = Date()
        guard let weekStart = calendar.dateInterval(of: .weekOfYear, for: today)?.start,
              let adjustedWeekStart = calendar.date(byAdding: .weekOfYear, value: weekOffset, to: weekStart) else {
            return []
        }
        
        var days: [Date] = []
        for i in 0..<7 {
            if let day = calendar.date(byAdding: .day, value: i, to: adjustedWeekStart) {
                days.append(day)
            }
        }
        return days
    }
    
    private func selectDate(_ date: Date) {
        withAnimation(.easeInOut(duration: 0.2)) {
            selectedDate = date
        }
        
        // Update week offset to match selected date
        let today = Date()
        guard let todayWeekStart = calendar.dateInterval(of: .weekOfYear, for: today)?.start,
              let selectedWeekStart = calendar.dateInterval(of: .weekOfYear, for: date)?.start else {
            return
        }
        
        let weeksDifference = calendar.dateComponents([.weekOfYear], from: todayWeekStart, to: selectedWeekStart).weekOfYear ?? 0
        currentWeekOffset = weeksDifference
    }
    
    private func dayAbbreviation(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: date).uppercased()
    }
    
    private func monthYearString(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date)
    }
}

#Preview {
    WeeklyCalendarView(selectedDate: .constant(Date()))
}

