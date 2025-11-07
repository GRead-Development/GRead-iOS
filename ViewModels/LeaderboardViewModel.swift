import Foundation
import SwiftUI
import Combine

struct LeaderboardDisplayEntry: Identifiable {
    let id: Int
    let userName: String
    let score: Int
}

@MainActor
class LeaderboardViewModel: ObservableObject {
    @Published var entries: [LeaderboardDisplayEntry] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    let type: String
    
    init(type: String) {
        self.type = type
    }
    
    func loadLeaderboard() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let leaderboard = try await APIService.shared.fetchLeaderboard()
            
            if type == "points" {
                entries = leaderboard.pointsLeaders.map { entry in
                    LeaderboardDisplayEntry(
                        id: entry.id,
                        userName: entry.displayName,
                        score: entry.value
                    )
                }
            } else {
                entries = leaderboard.booksLeaders.map { entry in
                    LeaderboardDisplayEntry(
                        id: entry.id,
                        userName: entry.displayName,
                        score: entry.value
                    )
                }
            }
        } catch {
            errorMessage = error.localizedDescription
            print("Error loading leaderboard: \(error)")
        }
        
        isLoading = false
    }
}
