import Foundation
import SwiftUI
import Combine

@MainActor
class ProfileViewModel: ObservableObject {
    @Published var userStats: UserStats?
    @Published var isLoading = false
    
    func loadUserStats() async {
        guard let token = UserDefaults.standard.string(forKey: "auth_token"),
              let userId = UserDefaults.standard.object(forKey: "user_id") as? Int else {
            return
        }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            userStats = try await APIService.shared.fetchUserStats(userId: userId, token: token)
        } catch {
            print("Error loading stats: \(error)")
        }
    }
}
