import Foundation
import SwiftUI
import Combine

@MainActor
class MyLibraryViewModel: ObservableObject {
    @Published var userBooks: [UserBook] = []
    @Published var isLoading = false
    
    func loadUserBooks() async {
        guard let token = UserDefaults.standard.string(forKey: "auth_token") else { return }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            userBooks = try await APIService.shared.fetchUserBooks(token: token)
        } catch {
            print("Error loading user books: \(error)")
        }
    }
    
    func removeBooks(at offsets: IndexSet) {
        // Implement delete functionality
        userBooks.remove(atOffsets: offsets)
    }
}
