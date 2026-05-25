import SwiftUI
import FirebaseCore

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
