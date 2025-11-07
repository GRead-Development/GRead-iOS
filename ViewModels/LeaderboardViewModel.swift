import Combine
import Foundation
@MainActor
class LeaderboardViewModel: ObservableObject {
    @Published var entries: [LeaderboardEntry] = []
    @Published var isLoading = false
    
    private let type: String
    
    init(type: String) {
        self.type = type
    }
    
    func loadLeaderboard() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            entries = try await APIService.shared.fetchLeaderboard(type: type)
        } catch {
            print("Error loading leaderboard: \(error)")
        }
    }
}
