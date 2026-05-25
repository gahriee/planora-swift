import SwiftUI

struct LoginView: View {
    @Binding var isLogin: Bool
    @State private var email = ""
    @State private var password = ""
    @StateObject private var authVM = AuthViewModel(authRepo: DIContainer().authRepo)
    
    var body: some View {
        VStack(spacing: 20) {
            AuthTextField(placeholder: "Email", text: $email)
                .keyboardType(.emailAddress)
            
            AuthTextField(placeholder: "Password", text: $password, isSecure: true)
            
            if let error = authVM.errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .font(.caption)
            }
            
            Button {
                Task { await authVM.login(email: email, password: password) }
            } label: {
                if authVM.isLoading {
                    ProgressView().tint(.white)
                } else {
                    Text("Log In")
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.appPrimary)
            .foregroundColor(.white)
            .cornerRadius(10)
            
            Button("Don't have an account? Sign up") {
                withAnimation { isLogin = false }
            }
            .font(.caption)
        }
        .padding()
    }
}
