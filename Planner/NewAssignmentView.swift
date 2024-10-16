import SwiftUI

struct NewAssignmentView: View {
    @Binding var assignments: [Assignment]
    @State private var assignmentName: String = ""
    
    // Default due date to today's date at 11:59 PM
    @State private var dueDate: Date = Calendar.current.date(bySettingHour: 23, minute: 59, second: 0, of: Date()) ?? Date()
    
    @State private var selectedSubject: String = "Math"
    @State private var selectedSubTopic: String = "Class Work" // Default to Class Work
    var subjects: [String: Color] // Dictionary to hold class names and their colors
    var onDismiss: () -> Void

    // Subtopics for the picker
    let subTopics = ["Class Work", "Homework", "Quizzes", "Tests"]

    // State for notes
    @State private var notes: String = ""

    var body: some View {
        NavigationView {
            Form {
                TextField("Assignment Name", text: $assignmentName)
                
                // Updated DatePicker to include both date and time
                DatePicker("Due Date", selection: $dueDate, displayedComponents: [.date, .hourAndMinute])
                
                Picker("Class", selection: $selectedSubject) {
                    ForEach(subjects.keys.sorted(), id: \.self) { subject in
                        HStack {
                            Circle()
                                .fill(subjects[subject] ?? .black) // Use the color for each subject
                                .frame(width: 20, height: 20) // Circle to represent the class color
                            Text(subject)
                                .foregroundColor(subjects[subject]) // Set the text color to match the subject color
                        }
                        .tag(subject) // Ensure each item has a tag for selection
                    }
                }
                
                Picker("Assignment Type", selection: $selectedSubTopic) {
                    ForEach(subTopics, id: \.self) { subTopic in
                        Text(subTopic).tag(subTopic)
                    }
                }
                
                // Notes box
                Section(header: Text("Notes")) {
                    TextEditor(text: $notes)
                        .frame(height: 100) // Set height for the TextEditor
                        .padding(5)
                        .background(Color(UIColor.systemGray6)) // Light gray background
                        .cornerRadius(8) // Rounded corners
                }
            }
            .navigationTitle("New Assignment")
            .navigationBarItems(leading: Button("Cancel") { onDismiss() },
                                trailing: Button("Add") {
                                    // Create new assignment
                                    let newAssignment = Assignment(name: assignmentName, dueDate: dueDate, subject: selectedSubject, subTopic: selectedSubTopic, notes: notes)
                                    
                                    // Append the new assignment to the list
                                    assignments.append(newAssignment)
                                    
                                    // Dismiss the view after adding the assignment
                                    onDismiss()
                                    
                                    // Clear the fields for future use (optional)
                                    assignmentName = ""
                                    dueDate = Calendar.current.date(bySettingHour: 23, minute: 59, second: 0, of: Date()) ?? Date()
                                    selectedSubject = subjects.keys.first ?? "Math" // Reset to the first available subject
                                    selectedSubTopic = "Class Work"
                                    notes = ""
                                }
                                .disabled(assignmentName.isEmpty)
            )
        }
    }
}

struct NewAssignmentView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleAssignments: [Assignment] = []
        let sampleSubjects: [String: Color] = [
            "Math": .blue,
            "Science": .green,
            "History": .red
        ]
        
        return NewAssignmentView(assignments: .constant(sampleAssignments), subjects: sampleSubjects) {
            // Dummy dismiss action for preview
        }
        .previewDevice("iPhone 14")
        .previewLayout(.sizeThatFits)
    }
}
