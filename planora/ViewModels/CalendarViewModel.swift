import SwiftUI

@MainActor
final class CalendarViewModel: ObservableObject {
    @Published var selectedDate: Date = Date()

    private let taskVM: TaskViewModel

    init(taskVM: TaskViewModel) {
        self.taskVM = taskVM
    }

    var tasksForSelectedDate: [Task] {
        taskVM.tasks(for: selectedDate)
    }
}
