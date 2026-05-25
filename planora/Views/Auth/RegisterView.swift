import SwiftUI

struct RegisterView: View {
    @Binding var isLogin: Bool
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @StateObject private var authVM = AuthViewModel(authRepo: DIContainer().authRepo)
    
    var body: some View {
        VStack(spacing: 20) {
            AuthTextField(placeholder: "Name", text: $name)
            
            AuthTextField(placeholder: "Email", text: $email)
                .keyboardType(.emailAddress)
            
            AuthTextField(placeholder: "Password", text: $password, isSecure: true)
            
            if let error = authVM.errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .font(.caption)
            }
            
            Button {
                Task { await authVM.register(name: name, email: email, password: password) }
            } label: {
                if authVM.isLoading {
                    ProgressView().tint(.white)
                } else {
                    Text("Sign Up")
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.appPrimary)
            .foregroundColor(.white)
            .cornerRadius(10)
            
            Button("Already have an account? Log in") {
                withAnimation { isLogin = true }
            }
            .font(.caption)
        }
        .padding()
    }
}
