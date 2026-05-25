import SwiftUI

struct TaskCard: View {
    let task: Task

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(task.title)
                    .font(.headline)
                    .strikethrough(task.status == .done)
                    .foregroundColor(task.status == .done ? .secondary : .primary)
                Spacer()
                StatusBadge(status: task.status)
            }

            if !task.description.isEmpty {
                Text(task.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }

            HStack {
                PriorityBadge(priority: task.priority)
                Spacer()
                if let dueDate = task.dueDate {
                    DueDateChip(date: dueDate)
                }
            }
        }
        .padding(.vertical, 8)
    }
}
