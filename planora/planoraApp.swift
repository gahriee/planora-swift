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
                .onChange(of: appState.currentUser) { user in
                    if let userID = user?.id {
                        taskVM.startObserving(userID: userID)
                    } else {
                        taskVM.stopObserving()
                    }
                }
                .onAppear {
                    if let userID = appState.currentUser?.id {
                        taskVM.startObserving(userID: userID)
                    }
                }
        }
    }
}
