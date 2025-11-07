import Foundation
import SwiftUI
import Combine
import AuthenticationServices // Import for Sign in with Apple

@MainActor
class AuthenticationManager: ObservableObject {
    @Published var isAuthenticated = false
    @Published var authToken: String?
    @Published var userId: Int?
    
    private let userDefaults = UserDefaults.standard
    private let tokenKey = "auth_token"
    private let userIdKey = "user_id"
    
    init() {
        loadSavedAuth()
    }
    
    private func loadSavedAuth() {
        if let token = userDefaults.string(forKey: tokenKey),
           let userId = userDefaults.object(forKey: userIdKey) as? Int {
            self.authToken = token
            self.userId = userId
            self.isAuthenticated = true
        }
    }
    
    // MARK: - Login
    
    func login(username: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
        // Using WordPress JWT Authentication plugin
        let url = URL(string: APIConfig.jwtLogin)!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: String] = [
            "username": username,
            "password": password
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let data = data else {
                    completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                    return
                }
                
                do {
                    // Try to parse the successful login response
                    if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let token = json["token"] as? String,
                       let userId = json["user_id"] as? Int {
                        
                        self?.saveAuthData(token: token, userId: userId)
                        completion(.success(()))
                    } else if let jsonError = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                              let message = jsonError["message"] as? String {
                        // Try to parse a WordPress error message
                        let displayError = message.stripHTML() // Clean up HTML in error
                        completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: displayError])))
                    }
                    else {
                        // Fallback error
                        completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response from server"])))
                    }
                } catch {
                    completion(.failure(error))
                }
            }
        }.resume()
    }

    // MARK: - Registration
    
    /// Registers a new user via the BuddyPress REST API.
    /// Note: This does NOT log the user in. They must log in after registering.
    func register(username: String, email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let url = URL(string: APIConfig.bpRegister)!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // BuddyPress signup endpoint requires specific fields
        let body: [String: String] = [
            "user_login": username,
            "user_email": email,
            "password": password
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])))
                    return
                }
                
                // BuddyPress returns 201 Created on success
                if httpResponse.statusCode == 201 {
                    completion(.success(()))
                    return
                }
                
                // Handle errors
                if let data = data,
                   let jsonError = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let message = jsonError["message"] as? String {
                    let displayError = message.stripHTML()
                    completion(.failure(NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: displayError])))
                } else {
                    completion(.failure(NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Registration failed. Please try again."])))
                }
            }
        }.resume()
    }
    
    // MARK: - Sign in with Apple
    
    /// Handles the result from a Sign in with Apple request.
    func handleAppleSignIn(result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let authorization):
            guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
                  let identityTokenData = appleIDCredential.identityToken,
                  let identityToken = String(data: identityTokenData, encoding: .utf8)
            else {
                print("Error: Could not get Apple identity token.")
                return
            }
            
            // Get user's name (only provided on first sign-up)
            var fullName: String?
            if let nameComponents = appleIDCredential.fullName {
                fullName = PersonNameComponentsFormatter().string(from: nameComponents)
            }
            
            // Send this token to your WordPress backend
            Task {
                await exchangeAppleTokenForJWT(
                    identityToken: identityToken,
                    fullName: fullName,
                    email: appleIDCredential.email
                )
            }
            
        case .failure(let error):
            // Handle error (e.g., user canceled)
            print("Apple Sign In failed: \(error.localizedDescription)")
        }
    }
    
    /// Sends the Apple identity token to your custom WordPress endpoint.
    private func exchangeAppleTokenForJWT(identityToken: String, fullName: String?, email: String?) async {
        let url = URL(string: APIConfig.appleSignIn)!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        var body: [String: String?] = [
            "token": identityToken,
            "email": email
        ]
        
        // Only send name if it's the first time
        if let fullName = fullName {
            body["name"] = fullName
        }
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard (response as? HTTPURLResponse)?.statusCode == 200 else {
                print("Error: Apple Sign-In exchange failed.")
                return
            }
            
            // Your backend should return the *same* JWT response as the normal login
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
               let token = json["token"] as? String,
               let userId = json["user_id"] as? Int {
                
                self.saveAuthData(token: token, userId: userId)
            } else {
                print("Error: Invalid JWT response from Apple Sign-In endpoint.")
            }
            
        } catch {
            print("Error: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Auth Management
    
    /// Saves auth data to UserDefaults and updates state.
    private func saveAuthData(token: String, userId: Int) {
        self.authToken = token
        self.userId = userId
        self.isAuthenticated = true
        
        self.userDefaults.set(token, forKey: self.tokenKey)
        self.userDefaults.set(userId, forKey: self.userIdKey)
    }
    
    func logout() {
        authToken = nil
        userId = nil
        isAuthenticated = false
        userDefaults.removeObject(forKey: tokenKey)
        userDefaults.removeObject(forKey: userIdKey)
    }
}
