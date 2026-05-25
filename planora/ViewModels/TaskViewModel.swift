import SwiftUI
import FirebaseFirestore

@MainActor
final class TaskViewModel: ObservableObject {
    @Published var tasks: [Task] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let taskRepo: TaskRepositoryProtocol
    private var listener: ListenerRegistration?

    init(taskRepo: TaskRepositoryProtocol) {
        self.taskRepo = taskRepo
    }

    // MARK: - Computed Filters

    var pendingTasks: [Task]    { tasks.filter { $0.status != .done } }
    var completedTasks: [Task]  { tasks.filter { $0.status == .done } }

    var todayTasks: [Task] {
        tasks.filter {
            guard let due = $0.dueDate else { return false }
            return Calendar.current.isDateInToday(due)
        }
    }

    var overdueTasks: [Task] {
        tasks.filter {
            guard let due = $0.dueDate else { return false }
            return due < Date() && $0.status != .done
        }
    }

    var weekTasks: [Task] {
        let end = Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date()
        return tasks.filter {
            guard let due = $0.dueDate else { return false }
            return due >= Date() && due <= end
        }
    }

    func tasks(for date: Date) -> [Task] {
        tasks.filter {
            guard let due = $0.dueDate else { return false }
            return Calendar.current.isDate(due, inSameDayAs: date)
        }
    }

    func tasks(filteredBy status: TaskStatus?) -> [Task] {
        guard let status else { return tasks }
        return tasks.filter { $0.status == status }
    }

    // MARK: - Lifecycle

    func startObserving(userID: String) {
        listener = taskRepo.observeTasks(for: userID) { [weak self] updated in
            self?.tasks = updated.sorted { $0.createdAt > $1.createdAt }
        }
    }

    func stopObserving() { listener?.remove() }

    // MARK: - CRUD

    func create(_ task: Task) async {
        isLoading = true; defer { isLoading = false }
        do    { try await taskRepo.createTask(task) }
        catch { errorMessage = error.localizedDescription }
    }

    func update(_ task: Task) async {
        do    { try await taskRepo.updateTask(task) }
        catch { errorMessage = error.localizedDescription }
    }

    func delete(id: String) async {
        do    { try await taskRepo.deleteTask(id: id) }
        catch { errorMessage = error.localizedDescription }
    }

    func markDone(_ task: Task) async {
        var updated = task
        updated.status      = .done
        updated.completedAt = Date()
        await update(updated)
    }
}
