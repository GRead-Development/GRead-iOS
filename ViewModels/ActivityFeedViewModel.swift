import Foundation
import SwiftUI
import Combine

@MainActor
class ActivityFeedViewModel: ObservableObject {
    @Published var activities: [ActivityItem] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    func loadActivities() async {
        isLoading = true
        errorMessage = nil
        
        do {
            activities = try await APIService.shared.fetchActivities()
        } catch {
            errorMessage = error.localizedDescription
            print("Error loading activities: \(error)")
        }
        
        isLoading = false
    }
    
    func createPost(content: String) async -> Bool {
        guard let token = UserDefaults.standard.string(forKey: "auth_token") else {
            errorMessage = "Please log in to post"
            return false
        }
        
        guard !content.isEmpty else {
            errorMessage = "Post content cannot be empty"
            return false
        }
        
        errorMessage = nil
        
        do {
            try await APIService.shared.createActivity(content: content)
            // Reload activities to show new post
            await loadActivities()
            return true
        } catch {
            errorMessage = error.localizedDescription
            print("Error creating post: \(error)")
            return false
        }
    }
}
