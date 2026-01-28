import SwiftUI

struct WeeklyCalendarView: View {
    @Binding var selectedDate: Date
    @State private var currentWeekOffset: Int = 0
    
    private let calendar = Calendar.current
    
    var body: some View {
        VStack(spacing: 4) {
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
                .foregroundStyle(Color("appText02"))
            
            Spacer()
            
            // Show "Today" button when not viewing today or when scrolled to a different week; placeholder keeps row height consistent
            if !calendar.isDateInToday(selectedDate) || currentWeekOffset != 0 {
                Button {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        selectedDate = Date()
                        currentWeekOffset = 0
                    }
                } label: {
                    Text("Today")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(Color("appText04"))
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color("appButtonBG01"))
                .clipShape(Capsule())
            } else {
                // Invisible placeholder so header height stays the same when button is hidden
                Text("Today")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(.clear)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
            }
        }
        .frame(height: 40)
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
        .frame(height: 86)
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
        HStack(spacing: 8) {
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
                    .foregroundStyle(isSelected ? Color("appOnPrimary80") : Color("appText06"))
                
                // Day number
                Text("\(calendar.component(.day, from: date))")
                    .font(.body)
                    .fontWeight(isToday ? .bold : .regular)
                    .foregroundStyle(isSelected ? Color("appOnPrimary") : Color("appText03"))
                
                // Dot indicator for today (appOnPrimary when selected, appPrimary when not; placeholder keeps row height consistent)
                if isToday {
                    Circle()
                        .fill(isSelected ? Color("appOnPrimary") : Color("appPrimary"))
                        .frame(width: 6, height: 6)
                } else {
                    Color.clear.frame(width: 6, height: 6)
                }
            }
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity)
            .frame(height: 72)
            .background(
                RoundedRectangle(cornerRadius: 40)
                    .fill(isSelected ? Color("appPrimary") : Color("appCardBG01"))
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

