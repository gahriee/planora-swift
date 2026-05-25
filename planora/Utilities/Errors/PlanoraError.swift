import Foundation

enum PlanoraError: Error, LocalizedError {
    case userNotFound
    
    var errorDescription: String? {
        switch self {
        case .userNotFound:
            return "User not found."
        }
    }
}
