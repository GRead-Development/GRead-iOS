import Foundation
import SwiftUI
import Combine

@MainActor
class LeaderboardViewModel: ObservableObject {
    @Published var leaderboard: Leaderboard?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    func loadLeaderboard() async {
        isLoading = true
        errorMessage = nil
        
        do {
            leaderboard = try await APIService.shared.fetchLeaderboard()
        } catch {
            errorMessage = error.localizedDescription
            print("Error loading leaderboard: \(error)")
        }
        
        isLoading = false
    }
}
