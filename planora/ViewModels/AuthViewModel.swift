import SwiftUI

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
