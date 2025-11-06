import Foundation
import SwiftUI
import Combine

@MainActor
class GroupsViewModel: ObservableObject {
    @Published var groups: [Group] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    func loadGroups() async {
        isLoading = true
        errorMessage = nil
        
        do {
            groups = try await APIService.shared.fetchGroups()
        } catch {
            errorMessage = error.localizedDescription
            print("Error loading groups: \(error)")
        }
        
        isLoading = false
    }

    
    func joinGroup(_ group: Group) async {
        guard UserDefaults.standard.string(forKey: "auth_token") != nil else {
            errorMessage = "Please log in to join groups"
            return
        }
        
        errorMessage = nil
        
        do {
            try await APIService.shared.joinGroup(groupId: group.id)
            await loadGroups()
        } catch {
            errorMessage = error.localizedDescription
            print("Error joining group: \(error)")
        }
    }
    
    func leaveGroup(_ group: Group) async {
        guard UserDefaults.standard.string(forKey: "auth_token") != nil else {
            errorMessage = "Please log in to leave groups"
            return
        }
        
        errorMessage = nil
        
        do {
            try await APIService.shared.leaveGroup(groupId: group.id)
            await loadGroups()
        } catch {
            errorMessage = error.localizedDescription
            print("Error leaving group: \(error)")
        }
    }
}
