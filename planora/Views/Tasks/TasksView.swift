import SwiftUI

struct TasksView: View {
    @EnvironmentObject var taskVM: TaskViewModel
    @State private var filter: TaskStatus? = nil
    @State private var searchText = ""
    @State private var showCreateSheet = false

    var filtered: [Task] {
        taskVM.tasks(filteredBy: filter).filter {
            searchText.isEmpty || $0.title.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        List {
            ForEach(filtered) { task in
                NavigationLink(destination: TaskDetailView(task: task)) {
                    TaskCard(task: task)
                }
                .swipeActions(edge: .trailing) {
                    Button(role: .destructive) {
                        Swift.Task { await taskVM.delete(id: task.id) }
                    } label: { Label("Delete", systemImage: "trash") }
                }
                .swipeActions(edge: .leading) {
                    Button {
                        Swift.Task { await taskVM.markDone(task) }
                    } label: { Label("Done", systemImage: "checkmark") }
                    .tint(.green)
                }
            }
        }
        .searchable(text: $searchText)
        .navigationTitle("Tasks")
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Picker("Filter", selection: $filter) {
                    Text("All").tag(TaskStatus?.none)
                    ForEach(TaskStatus.allCases, id: \.self) { s in
                        Text(s.label).tag(TaskStatus?.some(s))
                    }
                }
                .pickerStyle(.menu)
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button { showCreateSheet = true } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showCreateSheet) {
            CreateTaskSheet()
        }
    }
}
