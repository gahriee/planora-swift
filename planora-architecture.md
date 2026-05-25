# Planora — iOS To-Do App Architecture

**App:** Planora · **Platform:** iOS · **Language:** Swift 5.9 · **UI:** SwiftUI · **Pattern:** MVVM + Repository

> ✅ Swift 5.9 · Xcode 15.0 · Minimum Deployment Target: iOS 15.0 · macOS Ventura 13.6.1 (build machine)

---

## ⚙️ Environment & Compatibility Constraints

| Tool / Setting              | Required Version               | Notes                                               |
| --------------------------- | ------------------------------ | --------------------------------------------------- |
| **Swift**                   | **5.9** (swiftlang-5.9.0.128)  | Set explicitly in Build Settings                    |
| **Xcode**                   | **15.0**                       | Do NOT use Xcode 16 APIs                            |
| **macOS (build machine)**   | **Ventura 13.6.1**             | Minimum macOS required to run Xcode 15              |
| **iOS Deployment Target**   | **iOS 15.0**                   | `async/await`, `@Published`, `.searchable` all available ✅ |
| **SwiftUI**                 | SwiftUI 3 (iOS 15 baseline)    | No `@Observable` macro — use `ObservableObject`     |
| **Concurrency**             | `async/await`, `@MainActor`    | Available from iOS 15 ✅                            |
| **Package Manager**         | Swift Package Manager (SPM)    | No CocoaPods                                        |

### Xcode Project — Required Build Settings

```
SWIFT_VERSION                    = 5.9
IPHONEOS_DEPLOYMENT_TARGET       = 15.0
SWIFT_STRICT_CONCURRENCY         = targeted
```

> ⚠️ **Do not use** `@Observable` (iOS 17+), `SwiftData` (iOS 17+), `NavigationStack` (iOS 16+), `FirebaseFirestoreSwift` `@DocumentID`, or any API marked `@available(iOS 16, *)` or higher without an `#available` guard. Always check API availability before use.

---

## Philosophy

> Manual Firestore serialization over `FirebaseFirestoreSwift` — keeps the code portable, explicit, and Swift 5.9 safe.

| Concern          | Solution                                  | Built-in?           |
| ---------------- | ----------------------------------------- | ------------------- |
| State management | `ObservableObject` + `@Published`         | ✅ Yes              |
| Navigation       | `NavigationView` (iOS 15)                 | ✅ Yes              |
| Async data       | `async/await` + `Task`                    | ✅ Yes              |
| Realtime updates | Combine + Firestore snapshot listeners    | ✅ Combine built-in |
| Auth + Database  | Firebase                                  | ❌ External (SPM)   |

**Total added packages: 1** — `firebase-ios-sdk` (FirebaseAuth + FirebaseFirestore only). No `FirebaseFirestoreSwift`.

---

## 1. Features

| #   | Feature       | Description                                                  |
| --- | ------------- | ------------------------------------------------------------ |
| 1   | Auth          | Register and login with email and password                   |
| 2   | Dashboard     | Completion stats — totals, today, week, overdue, priority    |
| 3   | Calendar      | Pick a date, see tasks due on that day                       |
| 4   | Tasks         | Full task list with filter, search, swipe actions, CRUD      |
| 5   | Profile       | Show email, sign out                                         |

---

## 2. Project Structure

```
Planora/
├── PlanoraApp.swift                      # App entry point + DI wiring
│
├── Core/
│   ├── AppState.swift                    # @MainActor root state (auth user)
│   ├── DIContainer.swift                 # Dependency injection container
│   ├── AppRouter.swift                   # Auth gate + MainTabView
│   └── Constants.swift                   # Firestore collection names
│
├── Models/
│   ├── AppUser.swift
│   ├── Task.swift
│   └── Enums/
│       ├── TaskPriority.swift
│       └── TaskStatus.swift
│
├── Repositories/
│   ├── Protocols/
│   │   ├── AuthRepositoryProtocol.swift
│   │   └── TaskRepositoryProtocol.swift
│   ├── AuthRepository.swift
│   └── TaskRepository.swift
│
├── ViewModels/
│   ├── AuthViewModel.swift
│   ├── DashboardViewModel.swift
│   ├── CalendarViewModel.swift
│   └── TaskViewModel.swift
│
├── Views/
│   ├── Auth/
│   │   ├── AuthView.swift
│   │   ├── LoginView.swift
│   │   └── RegisterView.swift
│   ├── Dashboard/
│   │   └── DashboardView.swift
│   ├── Calendar/
│   │   └── CalendarView.swift
│   ├── Tasks/
│   │   ├── TasksView.swift
│   │   ├── TaskDetailView.swift
│   │   └── CreateTaskSheet.swift
│   └── Profile/
│       └── ProfileView.swift
│
├── Components/
│   ├── TaskCard.swift
│   ├── PriorityBadge.swift
│   ├── DueDateChip.swift
│   ├── StatusBadge.swift
│   ├── StatCard.swift
│   ├── EmptyStateView.swift
│   └── AuthTextField.swift
│
└── Utilities/
    ├── Theme.swift
    ├── Extensions/
    │   ├── Color+Hex.swift
    │   └── Date+Formatting.swift
    └── Errors/
        └── PlanoraError.swift
```

---

## 3. Data Models (`Planora/Models/`)

Plain Swift structs with manual Firestore serialization — no `FirebaseFirestoreSwift`, no `@DocumentID`, no `Codable` dependency on Firebase.

### `AppUser.swift`

```swift
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
```

### `Task.swift`

```swift
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
```

### `TaskPriority.swift`

```swift
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
```

### `TaskStatus.swift`

```swift
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
```

---

## 4. Repository Protocols (`Planora/Repositories/Protocols/`)

Protocols keep ViewModels decoupled from Firebase — swap with mocks for testing.

```swift
// AuthRepositoryProtocol.swift
protocol AuthRepositoryProtocol {
    var currentUser: AppUser? { get }
    func register(name: String, email: String, password: String) async throws -> AppUser
    func login(email: String, password: String) async throws -> AppUser
    func signOut() throws
    func observeAuthState(onChange: @escaping (AppUser?) -> Void)
}

// TaskRepositoryProtocol.swift
protocol TaskRepositoryProtocol {
    func observeTasks(
        for userID: String,
        onChange: @escaping ([Task]) -> Void
    ) -> ListenerRegistration

    func createTask(_ task: Task) async throws
    func updateTask(_ task: Task) async throws
    func deleteTask(id: String) async throws
}
```

---

## 5. Repositories (`Planora/Repositories/`)

### `AuthRepository.swift`

```swift
import FirebaseAuth
import FirebaseFirestore

final class AuthRepository: AuthRepositoryProtocol {
    private let auth = Auth.auth()
    private let db   = Firestore.firestore()

    var currentUser: AppUser? {
        guard let user = auth.currentUser else { return nil }
        return AppUser(id: user.uid, name: user.displayName ?? "", email: user.email ?? "")
    }

    func register(name: String, email: String, password: String) async throws -> AppUser {
        let result = try await auth.createUser(withEmail: email, password: password)
        let user   = AppUser(id: result.user.uid, name: name, email: email)
        try await db.collection(Constants.users).document(user.id).setData(user.toMap)
        return user
    }

    func login(email: String, password: String) async throws -> AppUser {
        let result = try await auth.signIn(withEmail: email, password: password)
        let snap   = try await db.collection(Constants.users).document(result.user.uid).getDocument()
        guard let data = snap.data(), let user = AppUser(document: data, id: snap.documentID) else {
            throw PlanoraError.userNotFound
        }
        return user
    }

    func signOut() throws {
        try auth.signOut()
    }

    func observeAuthState(onChange: @escaping (AppUser?) -> Void) {
        auth.addStateDidChangeListener { [weak self] _, firebaseUser in
            guard let self, let firebaseUser else { onChange(nil); return }
            Task {
                let snap = try? await self.db.collection(Constants.users)
                                             .document(firebaseUser.uid).getDocument()
                let user = snap.flatMap { AppUser(document: $0.data() ?? [:], id: $0.documentID) }
                await MainActor.run { onChange(user) }
            }
        }
    }
}
```

### `TaskRepository.swift`

```swift
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
```

---

## 6. ViewModels (`Planora/ViewModels/`)

All ViewModels are `@MainActor` — no manual `DispatchQueue.main` calls.

### `AuthViewModel.swift`

```swift
@MainActor
final class AuthViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let authRepo: AuthRepositoryProtocol

    init(authRepo: AuthRepositoryProtocol) {
        self.authRepo = authRepo
    }

    func register(name: String, email: String, password: String) async -> AppUser? {
        isLoading = true; errorMessage = nil
        defer { isLoading = false }
        do {
            return try await authRepo.register(name: name, email: email, password: password)
        } catch {
            errorMessage = error.localizedDescription; return nil
        }
    }

    func login(email: String, password: String) async -> AppUser? {
        isLoading = true; errorMessage = nil
        defer { isLoading = false }
        do {
            return try await authRepo.login(email: email, password: password)
        } catch {
            errorMessage = error.localizedDescription; return nil
        }
    }

    func signOut() {
        try? authRepo.signOut()
    }
}
```

### `TaskViewModel.swift`

```swift
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

    // MARK: — Computed Filters

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

    // MARK: — Lifecycle

    func startObserving(userID: String) {
        listener = taskRepo.observeTasks(for: userID) { [weak self] updated in
            self?.tasks = updated.sorted { $0.createdAt > $1.createdAt }
        }
    }

    func stopObserving() { listener?.remove() }

    // MARK: — CRUD

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
```

### `DashboardViewModel.swift`

```swift
@MainActor
final class DashboardViewModel: ObservableObject {
    private let taskVM: TaskViewModel

    init(taskVM: TaskViewModel) {
        self.taskVM = taskVM
    }

    var total:     Int { taskVM.tasks.count }
    var today:     Int { taskVM.todayTasks.count }
    var thisWeek:  Int { taskVM.weekTasks.count }
    var overdue:   Int { taskVM.overdueTasks.count }
    var completed: Int { taskVM.completedTasks.count }

    var completionRate: Double {
        guard total > 0 else { return 0 }
        return Double(completed) / Double(total)
    }

    var byPriority: [TaskPriority: Int] {
        Dictionary(grouping: taskVM.tasks, by: \.priority).mapValues(\.count)
    }

    var recentCompletions: [Task] {
        taskVM.completedTasks
            .sorted { ($0.completedAt ?? .distantPast) > ($1.completedAt ?? .distantPast) }
            .prefix(5)
            .map { $0 }
    }
}
```

### `CalendarViewModel.swift`

```swift
@MainActor
final class CalendarViewModel: ObservableObject {
    @Published var selectedDate: Date = Date()

    private let taskVM: TaskViewModel

    init(taskVM: TaskViewModel) {
        self.taskVM = taskVM
    }

    var tasksForSelectedDate: [Task] {
        taskVM.tasks(for: selectedDate)
    }
}
```

---

## 7. Views — Key Screens

### `AppRouter.swift` — Auth Gate + Tab Shell

```swift
struct AppRouter: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        Group {
            if appState.currentUser != nil {
                MainTabView()
            } else {
                AuthView()
            }
        }
        .animation(.easeInOut, value: appState.currentUser != nil)
    }
}

struct MainTabView: View {
    var body: some View {
        TabView {
            NavigationView { DashboardView() }
                .tabItem { Label("Dashboard", systemImage: "square.grid.2x2") }

            NavigationView { CalendarView() }
                .tabItem { Label("Calendar", systemImage: "calendar") }

            NavigationView { TasksView() }
                .tabItem { Label("Tasks", systemImage: "checkmark.circle") }
        }
    }
}
```

### `TasksView.swift`

```swift
struct TasksView: View {
    @EnvironmentObject var taskVM: TaskViewModel
    @State private var filter: TaskStatus? = nil
    @State private var searchText = ""
    @State private var showCreateSheet = false

    var filtered: [Task] {
        taskVM.tasks(filteredBy: filter).filter {
            searchText.isEmpty || $0.title.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        List {
            ForEach(filtered) { task in
                NavigationLink(destination: TaskDetailView(task: task)) {
                    TaskCard(task: task)
                }
                .swipeActions(edge: .trailing) {
                    Button(role: .destructive) {
                        Task { await taskVM.delete(id: task.id) }
                    } label: { Label("Delete", systemImage: "trash") }
                }
                .swipeActions(edge: .leading) {
                    Button {
                        Task { await taskVM.markDone(task) }
                    } label: { Label("Done", systemImage: "checkmark") }
                    .tint(.green)
                }
            }
        }
        .searchable(text: $searchText)
        .navigationTitle("Tasks")
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Picker("Filter", selection: $filter) {
                    Text("All").tag(TaskStatus?.none)
                    ForEach(TaskStatus.allCases, id: \.self) { s in
                        Text(s.label).tag(TaskStatus?.some(s))
                    }
                }
                .pickerStyle(.menu)
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button { showCreateSheet = true } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showCreateSheet) {
            CreateTaskSheet()
        }
    }
}
```

### `CreateTaskSheet.swift`

```swift
struct CreateTaskSheet: View {
    @EnvironmentObject var taskVM: TaskViewModel
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss

    @State private var title       = ""
    @State private var description = ""
    @State private var priority    = TaskPriority.medium
    @State private var dueDate     = Date()
    @State private var hasDueDate  = false

    var body: some View {
        NavigationView {
            Form {
                Section("Details") {
                    TextField("Title", text: $title)
                    // axis: .vertical is iOS 16+ — use TextEditor for iOS 15
                    ZStack(alignment: .topLeading) {
                        if description.isEmpty {
                            Text("Description")
                                .foregroundColor(Color(.placeholderText))
                                .padding(.top, 8)
                                .padding(.leading, 4)
                        }
                        TextEditor(text: $description)
                            .frame(minHeight: 80)
                    }
                }
                Section("Priority") {
                    Picker("Priority", selection: $priority) {
                        ForEach(TaskPriority.allCases, id: \.self) { p in
                            Text(p.label).tag(p)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                Section("Due Date") {
                    Toggle("Set due date", isOn: $hasDueDate)
                    if hasDueDate {
                        DatePicker("Due", selection: $dueDate, displayedComponents: .date)
                    }
                }
            }
            .navigationTitle("New Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        guard !title.trimmingCharacters(in: .whitespaces).isEmpty,
                              let userID = appState.currentUser?.id else { return }
                        let task = Task(
                            userID:      userID,
                            title:       title,
                            description: description,
                            priority:    priority,
                            dueDate:     hasDueDate ? dueDate : nil
                        )
                        Task { await taskVM.create(task) }
                        dismiss()
                    }
                }
            }
        }
    }
}
```

### `DashboardView.swift`

```swift
struct DashboardView: View {
    @EnvironmentObject var taskVM: TaskViewModel
    private var dash: DashboardViewModel { DashboardViewModel(taskVM: taskVM) }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    StatCard(title: "Total",    value: dash.total,    icon: "list.bullet")
                    StatCard(title: "Today",    value: dash.today,    icon: "sun.max")
                    StatCard(title: "This Week",value: dash.thisWeek, icon: "calendar.badge.clock")
                    StatCard(title: "Overdue",  value: dash.overdue,  icon: "exclamationmark.triangle", tint: .red)
                }

                Text("Completion Rate")
                    .font(.headline)
                ProgressView(value: dash.completionRate)
                    .tint(.accentColor)
                Text("\(Int(dash.completionRate * 100))% of \(dash.total) tasks done")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Text("Recent Completions").font(.headline)
                ForEach(dash.recentCompletions) { task in
                    TaskCard(task: task)
                }
            }
            .padding()
        }
        .navigationTitle("Dashboard")
    }
}
```

---

## 8. Dependency Injection (`Planora/Core/`)

### `DIContainer.swift`

```swift
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
```

### `AppState.swift`

```swift
@MainActor
final class AppState: ObservableObject {
    @Published var currentUser: AppUser?

    private let container: DIContainer

    init(container: DIContainer) {
        self.container = container
        container.authRepo.observeAuthState { [weak self] user in
            self?.currentUser = user
        }
    }
}
```

### `PlanoraApp.swift`

```swift
@main
struct PlanoraApp: App {
    @StateObject private var appState: AppState
    @StateObject private var taskVM: TaskViewModel

    init() {
        FirebaseApp.configure()
        let container = DIContainer()
        _appState = StateObject(wrappedValue: AppState(container: container))
        _taskVM   = StateObject(wrappedValue: TaskViewModel(taskRepo: container.taskRepo))
    }

    var body: some Scene {
        WindowGroup {
            AppRouter()
                .environmentObject(appState)
                .environmentObject(taskVM)
                .onReceive(NotificationCenter.default.publisher(for: .init("AuthChanged"))) { _ in
                    if let userID = appState.currentUser?.id {
                        taskVM.startObserving(userID: userID)
                    } else {
                        taskVM.stopObserving()
                    }
                }
        }
    }
}
```

---

## 9. Firestore Data Structure

```
users/
  {uid}/
    name:    String
    email:   String

tasks/
  {taskID}/
    userID:       String
    title:        String
    description:  String
    priority:     "low" | "medium" | "high"
    status:       "todo" | "inProgress" | "done"
    dueDate:      Timestamp?
    createdAt:    Timestamp
    completedAt:  Timestamp?
```

### Firestore Security Rules

```js
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    match /users/{uid} {
      allow read:  if request.auth != null;
      allow write: if request.auth.uid == uid;
    }

    match /tasks/{taskID} {
      allow read, write: if request.auth != null
        && resource.data.userID == request.auth.uid;
      allow create: if request.auth != null
        && request.resource.data.userID == request.auth.uid;
    }
  }
}
```

---

## 10. Theme & Colors (`Planora/Utilities/Theme.swift`)

```swift
import SwiftUI

// Color+Hex.swift
extension Color {
    init(hex: UInt, alpha: Double = 1) {
        self.init(
            .sRGB,
            red:     Double((hex >> 16) & 0xff) / 255,
            green:   Double((hex >> 08) & 0xff) / 255,
            blue:    Double((hex >> 00) & 0xff) / 255,
            opacity: alpha
        )
    }
}

// Theme.swift — use Asset Catalog colors for Dark Mode support
extension Color {
    static let appPrimary    = Color("PrimaryColor")
    static let appSecondary  = Color("SecondaryColor")
    static let appBackground = Color("BackgroundColor")
    static let appSurface    = Color("SurfaceColor")
}
```

> Define `PrimaryColor`, `SecondaryColor`, `BackgroundColor`, and `SurfaceColor` in `Assets.xcassets` with light and dark variants for native Dark Mode support.

---

## 11. Module Responsibilities

| Module                     | Responsibility                                                            |
| -------------------------- | ------------------------------------------------------------------------- |
| `Models/`                  | Plain Swift structs — `init?(document:)`, `toMap`. Zero business logic.   |
| `Repositories/Protocols/`  | Contracts for data access — enables mocking in tests.                     |
| `Repositories/`            | Firebase I/O only — no business logic, no UI imports.                     |
| `ViewModels/`              | Business logic + state. `@MainActor`. No SwiftUI imports.                 |
| `Views/`                   | Presentation only. Reads `@Published`, calls ViewModel methods.           |
| `Components/`              | Reusable, stateless UI pieces.                                            |
| `Core/AppState`            | Single source of truth for auth session. Injected via `@EnvironmentObject`.|
| `Core/DIContainer`         | Wires repositories to ViewModels. Swap implementations for testing.       |

---

## 12. Swift Package Manager Dependencies

`File > Add Package Dependencies` in Xcode 15:

```
https://github.com/firebase/firebase-ios-sdk
```

**Products to link (target: Planora):**

| Product             | Used For                    |
| ------------------- | --------------------------- |
| `FirebaseAuth`      | Authentication              |
| `FirebaseFirestore` | Realtime database + streams |

> ❌ Do **not** add `FirebaseFirestoreSwift` — Firestore serialization is handled manually via `init?(document:)` and `toMap`.

---

## 13. System Requirements

| Requirement              | Version / Notes                                          |
| ------------------------ | -------------------------------------------------------- |
| **Swift**                | **5.9** — set `SWIFT_VERSION = 5.9` in Build Settings    |
| **Xcode**                | **15.0** — do not use Xcode 16 APIs                      |
| **macOS (build machine)**| **Ventura 13.6.1** minimum                               |
| **iOS Deployment Target**| **iOS 15.0** — guard all iOS 16+ APIs with `#available`  |
| **Firebase SDK**         | Latest compatible with Xcode 15 / Swift 5.9              |

---

## 14. GitHub & Setup

```bash
# 1. Create Xcode project
# Xcode 15 > New Project > iOS > App
# Interface: SwiftUI | Language: Swift | Min Deployment: iOS 15

# 2. Set Swift version explicitly
# Xcode > Build Settings > Swift Compiler > Swift Language Version > Swift 5.9

# 3. Add Firebase via SPM
# Xcode > File > Add Package Dependencies
# https://github.com/firebase/firebase-ios-sdk
# Add: FirebaseAuth, FirebaseFirestore (NOT FirebaseFirestoreSwift)

# 4. Push to GitHub
git init && git add . && git commit -m "initial commit"
git remote add origin https://github.com/yourusername/planora.git
git branch -M main && git push -u origin main

# 5. Configure Firebase
# - Create project at console.firebase.google.com
# - Add iOS app with your bundle ID
# - Download GoogleService-Info.plist → drag into Xcode project root
# - Enable Email/Password auth in Firebase Console
# - Create Firestore in production mode, apply rules from Section 9
```

### After Fresh Clone

```bash
git clone https://github.com/yourusername/planora.git
# Open Planora.xcodeproj in Xcode 15
# Xcode resolves SPM packages automatically
# Add your GoogleService-Info.plist (not committed — see .gitignore)
# Build and Run ⌘R
```

### `.gitignore` — Key Entries

```
GoogleService-Info.plist
*.xcuserstate
.DS_Store
build/
DerivedData/
*.xcworkspace/xcuserdata/
```
