import SwiftUI

struct CalendarView: View {
    @EnvironmentObject var taskVM: TaskViewModel
    @State private var selectedDate = Date()
    
    var tasks: [Task] {
        taskVM.tasks(for: selectedDate)
    }
    
    var body: some View {
        VStack {
            DatePicker("Select Date", selection: $selectedDate, displayedComponents: .date)
                .datePickerStyle(.graphical)
                .padding()
            
            List {
                if tasks.isEmpty {
                    EmptyStateView(title: "No tasks", message: "You have no tasks due on this date.", systemImage: "calendar")
                } else {
                    ForEach(tasks) { task in
                        NavigationLink(destination: TaskDetailView(task: task)) {
                            TaskCard(task: task)
                        }
                    }
                }
            }
        }
        .navigationTitle("Calendar")
    }
}
