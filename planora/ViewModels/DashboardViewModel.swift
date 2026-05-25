import SwiftUI

@MainActor
final class DashboardViewModel: ObservableObject {
    private let taskVM: TaskViewModel

    init(taskVM: TaskViewModel) {
        self.taskVM = taskVM
    }

    var total:     Int { taskVM.tasks.count }
    var today:     Int { taskVM.todayTasks.count }
    var thisWeek:  Int { taskVM.weekTasks.count }
    var overdue:   Int { taskVM.overdueTasks.count }
    var completed: Int { taskVM.completedTasks.count }

    var completionRate: Double {
        guard total > 0 else { return 0 }
        return Double(completed) / Double(total)
    }

    var byPriority: [TaskPriority: Int] {
        Dictionary(grouping: taskVM.tasks, by: \.priority).mapValues(\.count)
    }

    var recentCompletions: [Task] {
        taskVM.completedTasks
            .sorted { ($0.completedAt ?? .distantPast) > ($1.completedAt ?? .distantPast) }
            .prefix(5)
            .map { $0 }
    }
}
