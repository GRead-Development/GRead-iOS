import Foundation
import SwiftUI
import Combine

@MainActor
class ProfileViewModel: ObservableObject {
    @Published var userStats: UserStats?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    func loadUserStats() async {
        guard let _ = UserDefaults.standard.string(forKey: "auth_token") else {
            errorMessage = "Please log in to view your stats"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            userStats = try await APIService.shared.fetchUserStats()
        } catch {
            errorMessage = error.localizedDescription
            print("Error loading user stats: \(error)")
        }
        
        isLoading = false
    }
}
