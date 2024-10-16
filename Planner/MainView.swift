import SwiftUI

struct MainView: View {
    @State private var assignments: [Assignment] = [
        Assignment(name: "Algebra Homework", dueDate: Date(), subject: "Math", subTopic: "Class Work", notes: "Complete exercises 1-10."),
        Assignment(name: "Day 11 Chap. Algebra HW", dueDate: Date(), subject: "Math", subTopic: "Class Work", notes: "Review chapter 11."),
        Assignment(name: "Science Project", dueDate: Date().addingTimeInterval(86400), subject: "Science", subTopic: "Class Work", notes: "Group project on ecosystems."),
        Assignment(name: "History Essay", dueDate: Date().addingTimeInterval(172800), subject: "History", subTopic: "Class Work", notes: "Essay on World War II."),
        Assignment(name: "Math Quiz", dueDate: Date().addingTimeInterval(86400 * 3), subject: "Math", subTopic: "Quizzes", notes: "Quiz covering chapters 1-3."),
        Assignment(name: "Biology Test", dueDate: Date().addingTimeInterval(86400 * 5), subject: "Science", subTopic: "Tests", notes: "Test on cell biology.")
    ]
    
    @State private var subjects: [String: Color] = [
        "Math": Color.blue,
        "Science": Color.green,
        "History": Color.red
    ]

    var body: some View {
        TabView {
            DashboardView(assignments: $assignments) // Added Dashboard tab
                .tabItem {
                    Image(systemName: "house")
                    Text("Dashboard")
                }

            CalendarView(assignments: $assignments, subjects: subjects)
                .tabItem {
                    Image(systemName: "calendar")
                    Text("Calendar")
                }
            
            SubjectView(assignments: $assignments, subjects: $subjects)
                .tabItem {
                    Image(systemName: "book")
                    Text("Assignments")
                }

            SettingsView(subjects: $subjects)
                .tabItem {
                    Image(systemName: "gearshape")
                    Text("Settings")
                }
        }
    }
}
