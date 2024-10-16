import SwiftUI
import UserNotifications

struct SettingsView: View {
    @State private var notificationsEnabled: Bool = true
    @State private var selectedTheme: String = "Light"
    @State private var iCloudSyncEnabled: Bool = true
    
    // Subjects state for managing subject list within settings
    @Binding var subjects: [String: Color]
    @State private var newSubject: String = ""
    @State private var newSubjectColor: Color = .clear

    // Notification settings
    @State private var notifyClassWork: Bool = true
    @State private var notifyHomework: Bool = true
    @State private var notificationTiming: String = "1 Hour Before"
    
    // Completed assignments preferences
    @State private var showAsGreen: Bool = false
    @State private var showAsStrikethrough: Bool = false

    var body: some View {
        NavigationView {
            Form {
                // General Settings Section
                Section(header: Text("GENERAL").font(.caption).foregroundColor(.gray)) {
                    Toggle(isOn: $notificationsEnabled) {
                        Text("Enable Notifications")
                    }
                    .onChange(of: notificationsEnabled) { value in
                        if value {
                            requestNotificationPermission()
                        }
                    }
                    
                    Picker("Theme", selection: $selectedTheme) {
                        Text("Light").tag("Light")
                        Text("Dark").tag("Dark")
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    
                    Toggle(isOn: $iCloudSyncEnabled) {
                        Text("Enable iCloud Sync")
                    }
                }
                
                // Notification Settings Section
                Section(header: Text("NOTIFICATIONS").font(.caption).foregroundColor(.gray)) {
                    Toggle(isOn: $notifyClassWork) {
                        Text("Notify for Class Work")
                    }
                    .onChange(of: notifyClassWork) { value in
                        if value {
                            scheduleNotification(type: "Class Work")
                        }
                    }
                    
                    Toggle(isOn: $notifyHomework) {
                        Text("Notify for Homework")
                    }
                    .onChange(of: notifyHomework) { value in
                        if value {
                            scheduleNotification(type: "Homework")
                        }
                    }
                    
                    Picker("Notification Timing", selection: $notificationTiming) {
                        Text("1 Hour Before").tag("1 Hour Before")
                        Text("1 Day Before - Morning").tag("1 Day Before - Morning")
                        Text("1 Day Before - Night").tag("1 Day Before - Night")
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }

                // Subjects Management Section
                Section(header: Text("MANAGE SUBJECTS").font(.caption).foregroundColor(.gray)) {
                    List {
                        ForEach(subjects.keys.sorted(), id: \.self) { subject in
                            HStack {
                                Text(subject)
                                Spacer()
                                Circle()
                                    .fill(subjects[subject] ?? Color.clear)
                                    .frame(width: 20, height: 20)
                                
                                // Delete button for removing subjects
                                Button(action: {
                                    deleteSubject(subject: subject)
                                }) {
                                    Image(systemName: "trash")
                                        .foregroundColor(.red)
                                }
                            }
                        }
                    }
                    
                    // Add new subject row
                    HStack {
                        TextField("New Subject", text: $newSubject)
                            .textFieldStyle(PlainTextFieldStyle())
                            .padding(8)
                            .background(Color(UIColor.systemGray6))
                            .cornerRadius(8)
                        
                        ColorPicker("", selection: $newSubjectColor)
                            .labelsHidden()
                            .frame(width: 44, height: 44)
                            .background(Color(UIColor.systemGray6))
                            .cornerRadius(22)
                        
                        Button(action: addSubject) {
                            Image(systemName: "plus")
                                .foregroundColor(.blue)
                                .padding()
                                .background(Color(UIColor.systemGray5))
                                .cornerRadius(8)
                        }
                        .disabled(newSubject.isEmpty)
                    }
                }
                
                // About Section
                Section(header: Text("ABOUT").font(.caption).foregroundColor(.gray)) {
                    Text("Version 1.0.0")
                    Text("Developer: Jason Lambert")
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
        }
        .navigationViewStyle(StackNavigationViewStyle()) // Full-page for iPhone/iPad
    }
    
    private func addSubject() {
        guard !newSubject.isEmpty else { return }
        subjects[newSubject] = newSubjectColor
        newSubject = ""
        newSubjectColor = .clear
    }
    
    private func deleteSubject(subject: String) {
        subjects.removeValue(forKey: subject)
    }
    
    // Request notification permissions
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Error requesting notifications permission: \(error)")
            }
        }
    }
    
    // Schedule notifications
    private func scheduleNotification(type: String) {
        let content = UNMutableNotificationContent()
        content.title = "\(type) Reminder"
        content.body = "Don't forget to complete your \(type.lowercased())!"
        content.sound = .default
        
        var triggerDate = Date()
        if notificationTiming == "1 Hour Before" {
            triggerDate = Calendar.current.date(byAdding: .hour, value: -1, to: Date()) ?? Date()
        } else if notificationTiming == "1 Day Before - Morning" {
            triggerDate = Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date()
            triggerDate = Calendar.current.date(bySettingHour: 8, minute: 0, second: 0, of: triggerDate) ?? Date()
        } else if notificationTiming == "1 Day Before - Night" {
            triggerDate = Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date()
            triggerDate = Calendar.current.date(bySettingHour: 20, minute: 0, second: 0, of: triggerDate) ?? Date()
        }

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: max(triggerDate.timeIntervalSinceNow, 1), repeats: false)
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(subjects: .constant(["Math": .blue, "Science": .green]))
    }
}

