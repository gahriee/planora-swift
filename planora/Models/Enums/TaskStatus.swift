import SwiftUI

enum TaskStatus: String, CaseIterable {
    case todo, inProgress, done

    var label: String {
        switch self {
        case .todo:       return "To Do"
        case .inProgress: return "In Progress"
        case .done:       return "Done"
        }
    }

    var color: Color {
        switch self {
        case .todo:       return Color(hex: 0x94A3B8)
        case .inProgress: return Color(hex: 0x3B82F6)
        case .done:       return Color(hex: 0x22C55E)
        }
    }
}
