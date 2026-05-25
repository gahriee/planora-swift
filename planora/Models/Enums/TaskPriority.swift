import SwiftUI

enum TaskPriority: String, CaseIterable {
    case low, medium, high

    var label: String { rawValue.capitalized }

    var color: Color {
        switch self {
        case .low:    return Color(hex: 0x22C55E)
        case .medium: return Color(hex: 0xF59E0B)
        case .high:   return Color(hex: 0xEF4444)
        }
    }

    var iconName: String {
        switch self {
        case .low:    return "arrow.down"
        case .medium: return "minus"
        case .high:   return "arrow.up"
        }
    }
}
