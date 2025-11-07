import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @Environment(\.dismiss) private var dismiss
    @State private var username = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: "books.vertical.fill")
                .font(.system(size: 80))
                .foregroundColor(.blue)
            
            Text("GRead")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Sign in to your account")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            VStack(spacing: 15) {
                TextField("Username", text: $username)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .textContentType(.username)
                
                SecureField("Password", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .textContentType(.password)
            }
            .padding(.horizontal, 40)
            .padding(.top, 20)
            
            if let error = errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .font(.caption)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            Button(action: login) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Text("Sign In")
                        .fontWeight(.semibold)
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
            .padding(.horizontal, 40)
            .padding(.top, 10)
            .disabled(isLoading || username.isEmpty || password.isEmpty)
            
            Spacer()
            Spacer()
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Cancel") {
                    dismiss()
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func login() {
        isLoading = true
        errorMessage = nil
        
        authManager.login(username: username, password: password) { result in
            isLoading = false
            
            switch result {
            case .success:
                dismiss()
            case .failure(let error):
                errorMessage = error.localizedDescription
            }
        }
    }
}
