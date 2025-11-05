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
                    if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let token = json["token"] as? String,
                       let userId = json["user_id"] as? Int {
                        
                        let displayName = json["user_display_name"] as? String ?? json["user_nicename"] as? String ?? username
                        
                        self?.authToken = token
                        self?.userId = userId
                        self?.displayName = displayName
                        self?.isAuthenticated = true
                        
                        self?.userDefaults.set(token, forKey: self?.tokenKey ?? "")
                        self?.userDefaults.set(userId, forKey: self?.userIdKey ?? "")
                        self?.userDefaults.set(displayName, forKey: self?.displayNameKey ?? "")
                        
                        completion(.success(()))
                    } else {
                        completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response from server"])))
                    }
                } catch {
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
