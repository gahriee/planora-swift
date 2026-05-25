protocol AuthRepositoryProtocol {
    var currentUser: AppUser? { get }
    func register(name: String, email: String, password: String) async throws -> AppUser
    func login(email: String, password: String) async throws -> AppUser
    func signOut() throws
    func observeAuthState(onChange: @escaping (AppUser?) -> Void)
}
