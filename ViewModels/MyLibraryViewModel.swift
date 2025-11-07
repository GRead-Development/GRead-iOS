import Foundation
import SwiftUI
import Combine

@MainActor
class MyLibraryViewModel: ObservableObject {
    @Published var userBooks: [UserBook] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    func loadUserBooks() async {
        guard let _ = UserDefaults.standard.string(forKey: "auth_token") else {
            errorMessage = "Please log in to view your library"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            userBooks = try await APIService.shared.fetchUserBooks()
        } catch {
            errorMessage = error.localizedDescription
            print("Error loading user books: \(error)")
        }
        
        isLoading = false
    }
    
    func deleteBook(userBook: UserBook) async {
        guard let _ = UserDefaults.standard.string(forKey: "auth_token") else {
            errorMessage = "Please log in to manage your library"
            return
        }
        
        errorMessage = nil
        
        do {
            try await APIService.shared.deleteUserBook(id: userBook.id)
            // Remove from local array
            userBooks.removeAll { $0.id == userBook.id }
        } catch {
            errorMessage = error.localizedDescription
            print("Error deleting book: \(error)")
        }
    }
}
