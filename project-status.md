# Planora - Project Status

## Current Phase: Phase 1 (Setup & Core Infrastructure)

### Phase 1: Project Setup & Core Infrastructure
- [x] Initialize Xcode Project (Swift 5.9, iOS 15.0 Deployment Target).
- [x] Configure `.gitignore` (ignore `GoogleService-Info.plist`, `build/`, `DerivedData/`, etc.).
- [x] Configure Swift Package Manager (Add `firebase-ios-sdk`: FirebaseAuth, FirebaseFirestore).
- [x] Set up Firebase Project in console (Auth & Firestore).
- [x] Add `GoogleService-Info.plist` to project root.
- [x] Configure `Assets.xcassets` (PrimaryColor, SecondaryColor, BackgroundColor, SurfaceColor).
- [x] Implement `Utilities/Theme.swift` and Color extensions.
- [x] Define `Core/Constants.swift` and `Utilities/Errors/PlanoraError.swift`.

### Phase 2: Data Models & Protocols
- [x] Implement Enums: `TaskPriority` and `TaskStatus`.
- [x] Implement Core Models: `AppUser` and `Task` (Ensure manual Firestore serialization with `init?(document:)` and `toMap`, avoiding `Codable`/`FirebaseFirestoreSwift`).
- [x] Define `Repositories/Protocols/AuthRepositoryProtocol.swift`.
- [x] Define `Repositories/Protocols/TaskRepositoryProtocol.swift`.

### Phase 3: Repositories & Dependency Injection
- [x] Implement `AuthRepository` (FirebaseAuth integration & user data fetching).
- [x] Implement `TaskRepository` (Firestore CRUD & snapshot listeners).
- [x] Set up Firestore Security Rules based on architecture specs.
- [x] Implement `Core/DIContainer` to manage repository injection.
- [x] Implement `Core/AppState` (`@MainActor` `ObservableObject` tracking auth state).
- [x] Configure app entry point (`PlanoraApp.swift`) with `DIContainer` and Firebase initialization.

### Phase 4: ViewModels (Business Logic)
- [x] Implement `AuthViewModel` (`register`, `login`, `signOut`).
- [x] Implement `TaskViewModel` (data fetching, CRUD operations, and filtered computed properties like `todayTasks`, `overdueTasks`, `completedTasks`).
- [x] Implement `DashboardViewModel` (calculate completion rates and metrics).
- [x] Implement `CalendarViewModel` (filter tasks by selected date).

### Phase 5: Reusable UI Components
- [x] Implement `TaskCard`.
- [x] Implement `PriorityBadge` and `StatusBadge`.
- [x] Implement `DueDateChip`.
- [x] Implement `StatCard`.
- [x] Implement `EmptyStateView`.
- [x] Implement `AuthTextField`.

### Phase 6: Core Features & Views
- [x] Build `AppRouter` (Auth gating logic) and `MainTabView` (Dashboard, Calendar, Tasks).
- [x] Build Auth Flow (`AuthView`, `LoginView`, `RegisterView`).
- [x] Build `DashboardView` (statistics grids, progress views).
- [x] Build `CalendarView` (date selection and corresponding tasks).
- [x] Build `TasksView` (list, search, status filtering, swipe actions).
- [x] Build `TaskDetailView`.
- [x] Build `CreateTaskSheet` (Forms for adding new tasks).
- [x] Build `ProfileView` (User details and sign out functionality).

## Notes
- Strict adherence to iOS 15 constraints.
- No usage of Xcode 16 or iOS 17 specific APIs (e.g. `@Observable`, `SwiftData`).
- All view models must be marked with `@MainActor`.
