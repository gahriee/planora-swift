import SwiftUI

struct CreateTaskSheet: View {
    @EnvironmentObject var taskVM: TaskViewModel
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss

    @State private var title       = ""
    @State private var description = ""
    @State private var priority    = TaskPriority.medium
    @State private var dueDate     = Date()
    @State private var hasDueDate  = false

    var body: some View {
        NavigationView {
            Form {
                Section("Details") {
                    TextField("Title", text: $title)
                    // axis: .vertical is iOS 16+ — use TextEditor for iOS 15
                    ZStack(alignment: .topLeading) {
                        if description.isEmpty {
                            Text("Description")
                                .foregroundColor(Color(.placeholderText))
                                .padding(.top, 8)
                                .padding(.leading, 4)
                        }
                        TextEditor(text: $description)
                            .frame(minHeight: 80)
                    }
                }
                Section("Priority") {
                    Picker("Priority", selection: $priority) {
                        ForEach(TaskPriority.allCases, id: \.self) { p in
                            Text(p.label).tag(p)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                Section("Due Date") {
                    Toggle("Set due date", isOn: $hasDueDate)
                    if hasDueDate {
                        DatePicker("Due", selection: $dueDate, displayedComponents: .date)
                    }
                }
            }
            .navigationTitle("New Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        guard !title.trimmingCharacters(in: .whitespaces).isEmpty,
                              let userID = appState.currentUser?.id else { return }
                        let task = Task(
                            userID:      userID,
                            title:       title,
                            description: description,
                            priority:    priority,
                            dueDate:     hasDueDate ? dueDate : nil
                        )
                        Task { await taskVM.create(task) }
                        dismiss()
                    }
                }
            }
        }
    }
}
