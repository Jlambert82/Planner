import SwiftUI

struct Assignment: Identifiable {
    var id = UUID()
    var name: String
    var dueDate: Date
    var subject: String
    var subTopic: String
    var notes: String
    var completed: Bool = false // New property to track completion
}
