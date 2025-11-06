import Combine
import Foundation

@MainActor
class ActivityFeedViewModel: ObservableObject {
    @Published var activities: [ActivityItem] = []
    @Published var isLoading = false
    @Published var isPosting = false
    @Published var errorMessage: String?
    
    private var currentPage = 1
    private var canLoadMore = true
    private var isLoadingMore = false  // ADDED to prevent multiple simultaneous loads
    
    func loadInitialActivity() async {
        let token = UserDefaults.standard.string(forKey: "auth_token")
        
        currentPage = 1
        canLoadMore = true
        isLoading = true
        isLoadingMore = false  // RESET
        errorMessage = nil
        defer { isLoading = false }
        
        do {
            activities = try await APIService.shared.fetchActivityFeed(page: currentPage, token: token)
            if activities.isEmpty {
                canLoadMore = false
            }
        } catch {
            print("Error loading activity: \(error)")
            errorMessage = error.localizedDescription
        }
    }
    
    func loadMoreActivity() async {
        // FIXED: Prevent multiple simultaneous load operations
        guard !isLoading && !isLoadingMore && canLoadMore else { return }
        let token = UserDefaults.standard.string(forKey: "auth_token")
        
        isLoadingMore = true
        defer { isLoadingMore = false }
        
        currentPage += 1
        
        do {
            let newActivities = try await APIService.shared.fetchActivityFeed(page: currentPage, token: token)
            if newActivities.isEmpty {
                canLoadMore = false
            } else {
                // FIXED: Safely append activities
                activities.append(contentsOf: newActivities)
            }
        } catch {
            print("Error loading more activity: \(error)")
            errorMessage = error.localizedDescription
            canLoadMore = false
            currentPage -= 1  // ADDED: Roll back page on error
        }
    }
    
    func postUpdate(content: String) async -> Bool {
        guard let token = UserDefaults.standard.string(forKey: "auth_token") else {
            errorMessage = "You must be logged in to post."
            return false
        }
        
        guard !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            errorMessage = "Post cannot be empty."
            return false
        }
        
        isPosting = true
        errorMessage = nil
        defer { isPosting = false }
        
        do {
            try await APIService.shared.postActivityUpdate(content: content, token: token)
            await loadInitialActivity()
            return true
        } catch {
            print("Error posting update: \(error)")
            errorMessage = "Failed to post update: \(error.localizedDescription)"
            return false
        }
    }
}
