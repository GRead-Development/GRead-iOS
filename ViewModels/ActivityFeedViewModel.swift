import Combine
import Foundation
@MainActor
class ActivityFeedViewModel: ObservableObject {
    @Published var activities: [ActivityItem] = []
    @Published var isLoading = false
    
    private var currentPage = 1
    private var canLoadMore = true
    
    func loadInitialActivity() async {
        guard let token = UserDefaults.standard.string(forKey: "auth_token") else {
            print("❌ No auth token for activity feed")
            return
        }
        
        currentPage = 1
        canLoadMore = true
        isLoading = true
        defer { isLoading = false }
        
        do {
            activities = try await APIService.shared.fetchActivityFeed(page: currentPage, token: token)
            print("✅ Loaded \(activities.count) activities")
        } catch {
            print("❌ Error loading activity: \(error)")
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
            canLoadMore = false
        }
        
        isLoading = false
    }
}
