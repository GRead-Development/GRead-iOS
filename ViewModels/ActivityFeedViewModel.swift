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
    
    func loadInitialActivity() async {
        guard let token = UserDefaults.standard.string(forKey: "auth_token") else {
            print("❌ No auth token for activity feed")
            errorMessage = "Authentication token not found."
            return
        }
        
        currentPage = 1
        canLoadMore = true
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        do {
            activities = try await APIService.shared.fetchActivityFeed(page: currentPage, token: token)
            print("✅ Loaded \(activities.count) activities")
            if activities.isEmpty {
                canLoadMore = false
            }
        } catch {
            print("❌ Error loading activity: \(error)")
            errorMessage = error.localizedDescription
        }
    }
    
    func loadMoreActivity() async {
        guard !isLoading && canLoadMore else { return }
        guard let token = UserDefaults.standard.string(forKey: "auth_token") else { return }
        
        isLoading = true
        currentPage += 1
        
        do {
            let newActivities = try await APIService.shared.fetchActivityFeed(page: currentPage, token: token)
            if newActivities.isEmpty {
                canLoadMore = false
            } else {
                activities.append(contentsOf: newActivities)
            }
        } catch {
            print("❌ Error loading more activity: \(error)")
            // Don't show an error, just stop loading more
            canLoadMore = false
        }
        
        isLoading = false
    }
    
    // NEW: Function to post an update
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
            // Success
            await loadInitialActivity() // Refresh the feed
            return true
        } catch {
            print("❌ Error posting update: \(error)")
            errorMessage = "Failed to post update: \(error.localizedDescription)"
            return false
        }
    }
}
