import SwiftUI

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
