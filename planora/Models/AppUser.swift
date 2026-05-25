struct AppUser: Identifiable, Equatable {
    let id: String        // Firebase Auth UID
    let name: String
    let email: String

    init(id: String, name: String, email: String) {
        self.id    = id
        self.name  = name
        self.email = email
    }

    init?(document: [String: Any], id: String) {
        guard
            let name  = document["name"]  as? String,
            let email = document["email"] as? String
        else { return nil }
        self.id    = id
        self.name  = name
        self.email = email
    }

    var toMap: [String: Any] {
        ["name": name, "email": email]
    }
}
