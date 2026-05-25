import SwiftUI

struct PriorityBadge: View {
    let priority: TaskPriority

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: priority.iconName)
            Text(priority.label)
        }
        .font(.caption.bold())
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(priority.color.opacity(0.15))
        .foregroundColor(priority.color)
        .cornerRadius(8)
    }
}
