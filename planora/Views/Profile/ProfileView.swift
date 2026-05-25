import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var authVM = AuthViewModel(authRepo: DIContainer().authRepo)
    
    var body: some View {
        Form {
            Section("Account Details") {
                if let user = appState.currentUser {
                    Text(user.name)
                    Text(user.email)
                }
            }
            Section {
                Button("Sign Out", role: .destructive) {
                    authVM.signOut()
                }
            }
        }
        .navigationTitle("Profile")
    }
}
