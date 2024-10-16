import SwiftUI

struct CalendarView: View {
    @Binding var assignments: [Assignment]
    var subjects: [String: Color]
    @State private var currentDate = Date()
    @State private var isShowingNewAssignmentView = false
    @State private var isWeekView = false

    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack {
                // Month Year Header
                HStack {
                    Button(action: {
                        currentDate = Calendar.current.date(byAdding: .month, value: -1, to: currentDate) ?? currentDate
                    }) {
                        Image(systemName: "chevron.left")
                    }
                    
                    Text(viewTitle)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Button(action: {
                        currentDate = Calendar.current.date(byAdding: .month, value: 1, to: currentDate) ?? currentDate
                    }) {
                        Image(systemName: "chevron.right")
                    }
                }
                .padding()

                // Calendar Grid
                if isWeekView {
                    WeekView(assignments: $assignments, subjects: subjects, currentDate: $currentDate, isShowingNewAssignmentView: $isShowingNewAssignmentView)
                } else {
                    MonthView(assignments: $assignments, subjects: subjects, currentDate: $currentDate, isShowingNewAssignmentView: $isShowingNewAssignmentView)
                }
            }
            .padding()
            
            // Toggle Button in Top Right Corner
            Button(action: {
                isWeekView.toggle()
            }) {
                Text(isWeekView ? "Month" : "Week")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(8)
                    .background(Color.blue)
                    .cornerRadius(10)
                    .shadow(color: Color.black.opacity(0.2), radius: 3, x: 0, y: 2)
            }
            .padding() // Adjust padding as needed
        }
    }

    // Title for month or week view based on current state
    private var viewTitle: String {
        return isWeekView ? "Week of \(currentDate.formattedWeekDescription)" : monthYearString(currentDate)
    }

    private func monthYearString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date)
    }
}

struct MonthView: View {
    @Binding var assignments: [Assignment]
    var subjects: [String: Color]
    @Binding var currentDate: Date
    @Binding var isShowingNewAssignmentView: Bool

    var body: some View {
        let days = Calendar.current.daysInMonth(currentDate)
        let startingDay = Calendar.current.firstWeekday
        let columns = Array(repeating: GridItem(.flexible()), count: 7)

        VStack {
            // Create a grid for day headers and date numbers
            LazyVGrid(columns: columns, spacing: 15) {
                // Day of the week headers
                ForEach(["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"], id: \.self) { day in
                    Text(day)
                        .font(.headline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                }

                // Empty boxes for days before the first
                ForEach(0..<startingDay - 1, id: \.self) { _ in
                    Color.clear.frame(maxWidth: .infinity, maxHeight: 100)
                }

                // Days of the month
                ForEach(days, id: \.self) { day in
                    let date = Calendar.current.date(byAdding: .day, value: day - 1, to: Calendar.current.firstDateOfMonth(currentDate))!
                    let assignmentsForDate = assignments.filter { Calendar.current.isDate($0.dueDate, inSameDayAs: date) }

                    VStack {
                        // Date number
                        Text("\(day)")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(15)
                            .frame(width: 60, height: 60)
                            .background(assignmentsForDate.isEmpty ? Color.clear : Color.blue.opacity(0))
                            .foregroundColor(assignmentsForDate.isEmpty ? .primary : .black)
                            .cornerRadius(15)
                            .onTapGesture {
                                isShowingNewAssignmentView = true
                            }
                            .multilineTextAlignment(.center)

                        // Assignments for the date
                        if !assignmentsForDate.isEmpty {
                            VStack(alignment: .leading, spacing: 2) { // Reduced spacing
                                ForEach(assignmentsForDate.prefix(2)) { assignment in
                                    HStack(spacing: 2) { // Reduced spacing
                                        Circle()
                                            .fill(subjects[assignment.subject] ?? Color.primary)
                                            .frame(width: 10, height: 10)
                                            .padding(.trailing, -5) // Reduced padding

                                        Text(assignment.name)
                                            .font(.caption2)
                                            .foregroundColor(assignment.completed ? .green : .primary)
                                            .multilineTextAlignment(.leading)
                                            .lineLimit(nil)
                                            .frame(maxWidth: .infinity)
                                    }
                                }
                                if assignmentsForDate.count > 2 {
                                    Text("+\(assignmentsForDate.count - 2) more")
                                        .font(.caption2)
                                        .foregroundColor(.gray)
                                }
                            }
                            .padding(.top, 5)
                        }

                    }
                    .frame(maxWidth: .infinity, maxHeight: 150)
                }
            }
            .padding(.horizontal)
        }
    }
}

struct WeekView: View {
    @Binding var assignments: [Assignment]
    var subjects: [String: Color]
    @Binding var currentDate: Date
    @Binding var isShowingNewAssignmentView: Bool

    var body: some View {
        let weekDates = Calendar.current.datesOfWeek(for: currentDate)
        let columns = Array(repeating: GridItem(.flexible()), count: 7)

        VStack {
            // Create a grid for weekday labels and date numbers
            LazyVGrid(columns: columns, spacing: 5) {
                // Weekday labels
                ForEach(["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"], id: \.self) { day in
                    Text(day)
                        .font(.headline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                }

                // Dates of the week
                ForEach(weekDates, id: \.self) { date in
                    let assignmentsForDate = assignments.filter { Calendar.current.isDate($0.dueDate, inSameDayAs: date) }

                    VStack {
                        // Date number
                        Text("\(date.dayOfMonth)")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(10)
                            .frame(width: 60, height: 60)
                            .background(assignmentsForDate.isEmpty ? Color.clear : Color.blue.opacity(0))
                            .foregroundColor(assignmentsForDate.isEmpty ? .primary : .black)
                            .cornerRadius(15)
                            .onTapGesture {
                                isShowingNewAssignmentView = true
                            }
                            .multilineTextAlignment(.center)

                        // Assignments
                        if !assignmentsForDate.isEmpty {
                            ScrollView {
                                VStack(alignment: .leading, spacing: 2) { // Reduced spacing
                                    ForEach(assignmentsForDate) { assignment in
                                        HStack(spacing: 2) { // Reduced spacing
                                            Circle()
                                                .fill(subjects[assignment.subject] ?? Color.primary)
                                                .frame(width: 10, height: 10)
                                                .padding(.trailing, 2) // Reduced padding

                                            Text(assignment.name)
                                                .font(.caption2)
                                                .foregroundColor(assignment.completed ? .green : .primary)
                                                .multilineTextAlignment(.leading)
                                                .lineLimit(nil)
                                                .frame(maxWidth: .infinity)
                                        }
                                    }
                                }
                                .padding(.top, 5)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: 300) // Maintain max height for the date
                    .background(Color.clear)
                }
            }
            .padding(.horizontal)
        }
    }
}


// Extension for Calendar
extension Calendar {
    func datesOfWeek(for date: Date) -> [Date] {
        let calendar = Calendar.current
        let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date))!
        let endOfWeek = calendar.date(byAdding: .day, value: 6, to: startOfWeek)!
        return calendar.dates(from: startOfWeek, to: endOfWeek)
    }
    
    func dates(from start: Date, to end: Date) -> [Date] {
        var dates = [Date]()
        var currentDate = start
        
        while currentDate <= end {
            dates.append(currentDate)
            currentDate = self.date(byAdding: .day, value: 1, to: currentDate)!
        }
        
        return dates
    }
    
    func daysInMonth(_ date: Date) -> [Int] {
        let range = self.range(of: .day, in: .month, for: date)!
        return Array(range.lowerBound..<range.upperBound)
    }
    
    func firstDateOfMonth(_ date: Date) -> Date {
        return self.date(from: self.dateComponents([.year, .month], from: date))!
    }
}

// Extension for Date
extension Date {
    var dayOfMonth: Int {
        return Calendar.current.component(.day, from: self)
    }

    var formattedWeekDescription: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: self)
    }
}
