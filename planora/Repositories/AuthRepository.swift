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
            _Concurrency.Task {
                let snap = try? await self.db.collection(Constants.users)
                                             .document(firebaseUser.uid).getDocument()
                let user = snap.flatMap { AppUser(document: $0.data() ?? [:], id: $0.documentID) }
                await MainActor.run { onChange(user) }
            }
        }
    }
}
