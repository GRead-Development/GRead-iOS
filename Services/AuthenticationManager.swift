import Foundation
import SwiftUI
import Combine

@MainActor
class AuthenticationManager: ObservableObject {
    @Published var isAuthenticated = false
    @Published var authToken: String?
    @Published var userId: Int?
    @Published var displayName: String?
    
    private let userDefaults = UserDefaults.standard
    private let tokenKey = "auth_token"
    private let userIdKey = "user_id"
    private let displayNameKey = "display_name"
    
    init() {
        loadSavedAuth()
    }
    
    private func loadSavedAuth() {
        if let token = userDefaults.string(forKey: tokenKey),
           let userId = userDefaults.object(forKey: userIdKey) as? Int {
            self.authToken = token
            self.userId = userId
            self.displayName = userDefaults.string(forKey: displayNameKey)
            self.isAuthenticated = true
        }
    }
    
    func login(username: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let url = URL(string: "\(APIConfig.baseURL)/wp-json/jwt-auth/v1/token")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 30 // Add timeout
        
        let body: [String: String] = [
            "username": username,
            "password": password
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("❌ Login error: \(error.localizedDescription)")
                    completion(.failure(error))
                    return
                }
                
                guard let data = data else {
                    print("❌ No data received from login")
                    completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                    return
                }
                
                // Debug: Print the raw response
                if let responseString = String(data: data, encoding: .utf8) {
                    print("📥 Login response: \(responseString)")
                }
                
                do {
                    if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                        print("📦 Parsed JSON: \(json)")
                        
                        // Check for error in response
                        if let errorMessage = json["message"] as? String {
                            print("❌ Server error: \(errorMessage)")
                            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: errorMessage])))
                            return
                        }
                        
                        // Try to get token - it might be "token" or "data.token"
                        var token: String?
                        var userId: Int?
                        
                        // Check direct fields
                        if let directToken = json["token"] as? String {
                            token = directToken
                            userId = json["user_id"] as? Int
                        }
                        // Check data object (some JWT plugins use this format)
                        else if let dataObject = json["data"] as? [String: Any],
                                let dataToken = dataObject["token"] as? String {
                            token = dataToken
                            userId = dataObject["user_id"] as? Int
                        }
                        
                        guard let finalToken = token, let finalUserId = userId else {
                            print("❌ Missing token or user_id in response")
                            print("Available keys: \(json.keys)")
                            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response from server. Missing token or user_id."])))
                            return
                        }
                        
                        // Get display name with multiple fallbacks
                        let displayName = json["user_display_name"] as? String
                            ?? json["displayName"] as? String
                            ?? json["user_nicename"] as? String
                            ?? json["nicename"] as? String
                            ?? username
                        
                        print("✅ Login successful!")
                        print("   Token: \(finalToken.prefix(20))...")
                        print("   User ID: \(finalUserId)")
                        print("   Display Name: \(displayName)")
                        
                        self?.authToken = finalToken
                        self?.userId = finalUserId
                        self?.displayName = displayName
                        self?.isAuthenticated = true
                        
                        self?.userDefaults.set(finalToken, forKey: self?.tokenKey ?? "")
                        self?.userDefaults.set(finalUserId, forKey: self?.userIdKey ?? "")
                        self?.userDefaults.set(displayName, forKey: self?.displayNameKey ?? "")
                        
                        completion(.success(()))
                    } else {
                        print("❌ Response is not valid JSON object")
                        completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response format from server"])))
                    }
                } catch {
                    print("❌ JSON parsing error: \(error)")
                    completion(.failure(error))
                }
            }
        }.resume()
    }
    
    func logout() {
        authToken = nil
        userId = nil
        displayName = nil
        isAuthenticated = false
        userDefaults.removeObject(forKey: tokenKey)
        userDefaults.removeObject(forKey: userIdKey)
        userDefaults.removeObject(forKey: displayNameKey)
    }
}
