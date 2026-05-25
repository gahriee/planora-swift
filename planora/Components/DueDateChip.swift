import SwiftUI

struct DueDateChip: View {
    let date: Date

    var isOverdue: Bool {
        date < Date() && !Calendar.current.isDateInToday(date)
    }

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "calendar")
            Text(date, style: .date)
        }
        .font(.caption)
        .foregroundColor(isOverdue ? .red : .secondary)
    }
}
