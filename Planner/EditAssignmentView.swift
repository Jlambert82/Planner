import SwiftUI

struct EditAssignmentView: View {
    @Binding var assignment: Assignment
    var subjects: [String: Color] // Pass the list of subjects
    var onSave: (Assignment) -> Void

    @State private var newName: String = ""
    @State private var newDueDate: Date = Date()
    @State private var newSubject: String = ""
    @State private var newSubTopic: String = ""
    @State private var newNotes: String = "" // New state for notes

    @Environment(\.presentationMode) var presentationMode // For dismissing the view

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Assignment Details")) {
                    TextField("Assignment Name", text: $newName)

                    DatePicker("Due Date", selection: $newDueDate, displayedComponents: [.date, .hourAndMinute])

                    // Picker for Subject
                    Picker("Subject", selection: $newSubject) {
                        ForEach(subjects.keys.sorted(), id: \.self) { subject in
                            Text(subject).tag(subject)
                        }
                    }

                    // Picker for SubTopic (Assignment Type)
                    Picker("Assignment Type", selection: $newSubTopic) {
                        Text("Class Work").tag("Class Work")
                        Text("Homework").tag("Homework")
                        Text("Quizzes").tag("Quizzes")
                        Text("Tests").tag("Tests")
                    }

                    // Text Editor for Notes
                    TextEditor(text: $newNotes)
                        .frame(height: 100) // Set a fixed height for the text editor
                        .padding(4)
                        .background(Color(UIColor.systemGray5)) // Background color for the notes box
                        .cornerRadius(5)
                        .overlay(RoundedRectangle(cornerRadius: 5)
                                    .stroke(Color.gray.opacity(0.5), lineWidth: 1)) // Border for the notes box
                        .padding(.vertical, 8) // Add some vertical padding
                        .font(.body) // Font for the text editor
                        .foregroundColor(.primary) // Text color
                }

                // Save Button
                Button(action: {
                    assignment.name = newName
                    assignment.dueDate = newDueDate
                    assignment.subject = newSubject
                    assignment.subTopic = newSubTopic
                    assignment.notes = newNotes // Save the notes
                    onSave(assignment)
                    presentationMode.wrappedValue.dismiss() // Dismiss the view
                }) {
                    Text("Save")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .listRowBackground(Color.clear) // To keep the button clean within the form
            }
            .navigationTitle("Edit Assignment")
            .onAppear {
                newName = assignment.name
                newDueDate = assignment.dueDate
                newSubject = assignment.subject
                newSubTopic = assignment.subTopic
                newNotes = assignment.notes // Initialize notes from the assignment
            }
        }
    }
}
