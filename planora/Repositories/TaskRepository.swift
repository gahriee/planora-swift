import FirebaseFirestore

final class TaskRepository: TaskRepositoryProtocol {
    private let db = Firestore.firestore()

    func observeTasks(
        for userID: String,
        onChange: @escaping ([Task]) -> Void
    ) -> ListenerRegistration {
        db.collection(Constants.tasks)
            .whereField("userID", isEqualTo: userID)
            .addSnapshotListener { snapshot, _ in
                guard let documents = snapshot?.documents else { return }
                let tasks = documents.compactMap { Task(document: $0.data(), id: $0.documentID) }
                onChange(tasks)
            }
    }

    func createTask(_ task: Task) async throws {
        try await db.collection(Constants.tasks).document(task.id).setData(task.toMap)
    }

    func updateTask(_ task: Task) async throws {
        try await db.collection(Constants.tasks).document(task.id).setData(task.toMap, merge: true)
    }

    func deleteTask(id: String) async throws {
        try await db.collection(Constants.tasks).document(id).delete()
    }
}
