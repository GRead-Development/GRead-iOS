import Foundation
import SwiftUI
import Combine

@MainActor
class ActivityFeedViewModel: ObservableObject {
    @Published var activities: [ActivityItem] = []
    @Published var isLoading = false
    @Published var isPosting = false
    @Published var errorMessage: String?
    
    private var currentPage = 1
    private var canLoadMore = true
    
    func loadInitialActivity() async {
        currentPage = 1
        canLoadMore = true
        activities = []
        await loadActivity()
    }
    
    func loadMoreActivity() async {
        guard !isLoading && canLoadMore else { return }
        currentPage += 1
        await loadActivity()
    }
    
    private func loadActivity() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let newActivities = try await APIService.shared.fetchActivities(page: currentPage)
            
            if newActivities.isEmpty {
                canLoadMore = false
            } else {
                let uniqueActivities = newActivities.filter { newActivity in
                    !activities.contains(where: { $0.id == newActivity.id })
                }
                activities.append(contentsOf: uniqueActivities)
            }
        } catch {
            errorMessage = error.localizedDescription
            print("Error loading activities: \(error)")
        }
        
        isLoading = false
    }
    
    func postUpdate(content: String) async -> Bool {
        guard let _ = UserDefaults.standard.string(forKey: "auth_token") else {
            errorMessage = "Please log in to post"
            return false
        }
        
        guard !content.isEmpty else {
            errorMessage = "Post content cannot be empty"
            return false
        }
        
        isPosting = true
        errorMessage = nil
        
        do {
            try await APIService.shared.createActivity(content: content)
            await loadInitialActivity()
            isPosting = false
            return true
        } catch {
            errorMessage = error.localizedDescription
            print("Error creating post: \(error)")
            isPosting = false
            return false
        }
    }
    
    func createPost(content: String) async -> Bool {
        return await postUpdate(content: content)
    }
}
