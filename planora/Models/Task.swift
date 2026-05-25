import Foundation
import FirebaseFirestore

struct Task: Identifiable, Equatable {
    let id: String
    let userID: String
    var title: String
    var description: String
    var priority: TaskPriority
    var status: TaskStatus
    var dueDate: Date?
    let createdAt: Date
    var completedAt: Date?

    init(
        id: String = UUID().uuidString,
        userID: String,
        title: String,
        description: String = "",
        priority: TaskPriority = .medium,
        status: TaskStatus = .todo,
        dueDate: Date? = nil,
        createdAt: Date = Date(),
        completedAt: Date? = nil
    ) {
        self.id          = id
        self.userID      = userID
        self.title       = title
        self.description = description
        self.priority    = priority
        self.status      = status
        self.dueDate     = dueDate
        self.createdAt   = createdAt
        self.completedAt = completedAt
    }

    init?(document: [String: Any], id: String) {
        guard
            let userID            = document["userID"]            as? String,
            let title             = document["title"]             as? String,
            let priorityRaw       = document["priority"]          as? String,
            let priority          = TaskPriority(rawValue: priorityRaw),
            let statusRaw         = document["status"]            as? String,
            let status            = TaskStatus(rawValue: statusRaw),
            let createdAtStamp    = document["createdAt"]         as? Timestamp
        else { return nil }

        self.id          = id
        self.userID      = userID
        self.title       = title
        self.description = document["description"] as? String ?? ""
        self.priority    = priority
        self.status      = status
        self.createdAt   = createdAtStamp.dateValue()
        self.dueDate     = (document["dueDate"]     as? Timestamp)?.dateValue()
        self.completedAt = (document["completedAt"] as? Timestamp)?.dateValue()
    }

    var toMap: [String: Any] {
        var map: [String: Any] = [
            "userID":    userID,
            "title":     title,
            "description": description,
            "priority":  priority.rawValue,
            "status":    status.rawValue,
            "createdAt": Timestamp(date: createdAt),
        ]
        if let dueDate     = dueDate     { map["dueDate"]     = Timestamp(date: dueDate) }
        if let completedAt = completedAt { map["completedAt"] = Timestamp(date: completedAt) }
        return map
    }
}
