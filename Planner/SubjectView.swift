import SwiftUI

struct SubjectView: View {
    @State private var isShowingNewAssignmentView = false
    @State private var selectedAssignment: Assignment?
    
    @Binding var assignments: [Assignment]
    @Binding var subjects: [String: Color]

    var body: some View {
        VStack {
            Text("Assignments by Subject")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)

            List {
                ForEach(subjects.keys.sorted(), id: \.self) { subject in
                    Section(header: Text("\(subject):")
                                .font(.system(size: 28))
                                .fontWeight(.semibold)
                                .foregroundColor(subjects[subject])
                                .padding(.bottom, 5)
                    ) {
                        createSubtopicSection(for: subject, subTopic: "Class Work", color: subjects[subject] ?? .primary)
                        createSubtopicSection(for: subject, subTopic: "Homework", color: subjects[subject] ?? .primary)
                        createSubtopicSection(for: subject, subTopic: "Quizzes", color: subjects[subject] ?? .primary)
                        createSubtopicSection(for: subject, subTopic: "Tests", color: subjects[subject] ?? .primary)
                    }
                    .listRowSeparator(.hidden)
                    .cornerRadius(10)
                }
            }
            .listStyle(PlainListStyle())
            .cornerRadius(10)
            .padding(.top, 10)

            // New Assignment Button
            Button(action: {
                isShowingNewAssignmentView.toggle()
            }) {
                Text("New Assignment")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(10)
                    .shadow(color: Color.black.opacity(0.2), radius: 3, x: 0, y: 2)
            }
            .padding(.horizontal)
            .padding(.bottom, 20)
        }
        .sheet(isPresented: $isShowingNewAssignmentView) {
            NewAssignmentView(assignments: $assignments, subjects: subjects) {
                isShowingNewAssignmentView = false
            }
        }
        .sheet(item: $selectedAssignment) { assignment in
            EditAssignmentView(assignment: $assignments[assignments.firstIndex(where: { $0.id == assignment.id })!],
                               subjects: subjects,
                               onSave: { updatedAssignment in
                                   if let index = assignments.firstIndex(where: { $0.id == updatedAssignment.id }) {
                                       assignments[index] = updatedAssignment
                                   }
                               })
        }
        .padding()
        .background(Color(UIColor.systemGroupedBackground))
    }

    // Function to create subtopic section
    private func createSubtopicSection(for subject: String, subTopic: String, color: Color) -> some View {
        let filteredAssignments = assignments.filter { $0.subject == subject && $0.subTopic == subTopic }

        if filteredAssignments.isEmpty {
            return AnyView(EmptyView())
        }

        return AnyView(
            Section {
                VStack(alignment: .leading) {
                    Text(subTopic)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(color)

                    ForEach(filteredAssignments) { assignment in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(assignment.name)
                                    .fontWeight(.regular)
                                    .strikethrough(assignment.completed, color: .gray) // Strikethrough if completed

                                Text(formattedDate(assignment.dueDate))
                                    .foregroundColor(.gray)
                                    .font(.subheadline)
                            }
                            Spacer()

                            // Completion Toggle
                            Button(action: {
                                markAsCompleted(assignment: assignment)
                            }) {
                                Text(assignment.completed ? "✓ Finished" : "Finish")
                                    .foregroundColor(assignment.completed ? .green : .blue)
                                    .padding(6)
                                    .background(RoundedRectangle(cornerRadius: 6).stroke(Color.blue, lineWidth: 1))
                            }
                            .buttonStyle(PlainButtonStyle()) // Prevents triggering other actions

                            // Edit Button
                            Button(action: {
                                selectedAssignment = assignment
                            }) {
                                Text("Edit")
                                    .foregroundColor(.blue)
                                    .padding(6)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 6)
                                            .stroke(Color.blue, lineWidth: 1)
                                    )
                            }
                        }
                        .padding(.vertical, 5)
                    }
                }
                .padding()
                .background(Color.white)
                .cornerRadius(10)
                .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 1)
            }
            .listRowBackground(Color.clear)
        )
    }

    // Function to mark an assignment as completed
    private func markAsCompleted(assignment: Assignment) {
        if let index = assignments.firstIndex(where: { $0.id == assignment.id }) {
            assignments[index].completed.toggle() // Toggle the completion status
        }
    }

    // Function to format the date
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}
