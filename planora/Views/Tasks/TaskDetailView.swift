import SwiftUI

struct TaskDetailView: View {
    @EnvironmentObject var taskVM: TaskViewModel
    @State var task: Task
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        Form {
            Section("Details") {
                TextField("Title", text: $task.title)
                ZStack(alignment: .topLeading) {
                    if task.description.isEmpty {
                        Text("Description")
                            .foregroundColor(Color(.placeholderText))
                            .padding(.top, 8)
                            .padding(.leading, 4)
                    }
                    TextEditor(text: $task.description)
                        .frame(minHeight: 80)
                }
            }
            Section("Status & Priority") {
                Picker("Status", selection: $task.status) {
                    ForEach(TaskStatus.allCases, id: \.self) { s in
                        Text(s.label).tag(s)
                    }
                }
                Picker("Priority", selection: $task.priority) {
                    ForEach(TaskPriority.allCases, id: \.self) { p in
                        Text(p.label).tag(p)
                    }
                }
            }
        }
        .navigationTitle("Task Details")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Save") {
                    Swift.Task {
                        await taskVM.update(task)
                        dismiss()
                    }
                }
            }
        }
    }
}
