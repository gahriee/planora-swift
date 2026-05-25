import FirebaseFirestore

protocol TaskRepositoryProtocol {
    func observeTasks(
        for userID: String,
        onChange: @escaping ([Task]) -> Void
    ) -> ListenerRegistration

    func createTask(_ task: Task) async throws
    func updateTask(_ task: Task) async throws
    func deleteTask(id: String) async throws
}
