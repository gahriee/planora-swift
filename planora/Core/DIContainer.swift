import Foundation

final class DIContainer {
    let authRepo: AuthRepositoryProtocol
    let taskRepo: TaskRepositoryProtocol

    init(
        authRepo: AuthRepositoryProtocol = AuthRepository(),
        taskRepo: TaskRepositoryProtocol = TaskRepository()
    ) {
        self.authRepo = authRepo
        self.taskRepo = taskRepo
    }
}
