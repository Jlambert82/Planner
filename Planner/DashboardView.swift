import SwiftUI

struct DashboardView: View {
    @Binding var assignments: [Assignment] // Use your custom Assignment model
    
    var body: some View {
        let todayAssignments = assignmentsDueToday(assignments: assignments) // Moved here
        
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    
                    // Section for upcoming assignments due today
                    Section(header: Text("Upcoming Assignments (Due Today)")
                                .font(.headline)
                                .padding(.horizontal)) {
                        
                        if todayAssignments.isEmpty {
                            PlaceholderView(title: "No Assignments Due Today")
                        } else {
                            ForEach(todayAssignments) { assignment in
                                AssignmentCard(assignment: assignment)
                            }
                        }
                    }
                    
                    // Placeholder for courses overview section
                    Section(header: Text("Courses Overview")
                                .font(.headline)
                                .padding(.horizontal)) {
                        PlaceholderView(title: "No Courses")
                    }
                    
                    // Placeholder for quick stats section
                    Section(header: Text("Quick Stats")
                                .font(.headline)
                                .padding(.horizontal)) {
                        HStack {
                            StatCard(title: "Assignments Due", value: "\(todayAssignments.count)")
                            StatCard(title: "Courses", value: "0")
                        }
                        .padding()
                    }
                }
                .padding()
            }
            .navigationTitle("Dashboard")
            .navigationBarHidden(true) // Hide the navigation bar for full screen
        }
        .navigationViewStyle(StackNavigationViewStyle()) // Ensures full-screen on iPhones
    }
    
    // Helper function to filter assignments due today
    private func assignmentsDueToday(assignments: [Assignment]) -> [Assignment] {
        let today = Calendar.current.startOfDay(for: Date()) // Today's date at midnight
        return assignments.filter { Calendar.current.isDate($0.dueDate, inSameDayAs: today) }
    }
}

// Assignment card view to display individual assignments
struct AssignmentCard: View {
    var assignment: Assignment
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(assignment.name)
                .font(.headline)
            Text(assignment.subject)
                .font(.subheadline)
                .foregroundColor(.secondary)
            Text(assignment.notes)
                .font(.body)
                .foregroundColor(.gray)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(UIColor.systemGray6))
        .cornerRadius(10)
        .padding(.horizontal)
    }
}

// Placeholder view for empty sections
struct PlaceholderView: View {
    var title: String
    
    var body: some View {
        VStack {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, minHeight: 100)
        .background(Color(UIColor.systemGray5))
        .cornerRadius(10)
        .padding(.horizontal)
    }
}

// Quick stat card component
struct StatCard: View {
    var title: String
    var value: String
    
    var body: some View {
        VStack {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            Text(value)
                .font(.largeTitle)
                .bold()
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.green.opacity(0.2))
        .cornerRadius(10)
    }
}

// Preview for the dashboard
struct DashboardView_Previews: PreviewProvider {
    @State static var sampleAssignments: [Assignment] = [
        Assignment(name: "Math Homework", dueDate: Date(), subject: "Math", subTopic: "Homework", notes: "Solve exercises 1-10."),
        Assignment(name: "Science Project", dueDate: Date().addingTimeInterval(86400), subject: "Science", subTopic: "Class Work", notes: "Prepare ecosystem presentation."),
        Assignment(name: "History Essay", dueDate: Date().addingTimeInterval(172800), subject: "History", subTopic: "Essay", notes: "Write about WW2.")
    ]
    
    static var previews: some View {
        DashboardView(assignments: $sampleAssignments)
    }
}
