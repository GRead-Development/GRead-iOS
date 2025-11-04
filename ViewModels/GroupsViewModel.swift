import Foundation
import SwiftUI
import Combine
@MainActor
class GroupsViewModel: ObservableObject {
    @Published var groups: [Group] = []
    @Published var isLoading = false
    
    func loadGroups() async {
        guard let token = UserDefaults.standard.string(forKey: "auth_token") else { return }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            groups = try await APIService.shared.fetchGroups(token: token)
        } catch {
            print("Error loading groups: \(error)")
        }
    }
}
