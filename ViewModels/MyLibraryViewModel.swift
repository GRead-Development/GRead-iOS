import Combine
import Foundation

@MainActor
class MyLibraryViewModel: ObservableObject {
    @Published var userBooks: [UserBook] = []
    @Published var isLoading = false
    
    // FIX: Added error properties to display feedback to the user
    @Published var showError = false
    @Published var errorMessage: String?
    
    func loadUserBooks() async {
        guard let token = UserDefaults.standard.string(forKey: "auth_token") else {
            errorMessage = "You must be logged in to view your library."
            showError = true
            return
        }
        
        isLoading = true
        showError = false
        errorMessage = nil
        defer { isLoading = false }
        
        do {
            userBooks = try await APIService.shared.fetchUserBooks(token: token)
        } catch {
            // FIX: Set error properties on failure
            print("Error loading user books: \(error)")
            errorMessage = "Failed to load library: \(error.localizedDescription)"
            showError = true
        }
    }
    
    func removeBook(_ userBook: UserBook) async {
        guard let token = UserDefaults.standard.string(forKey: "auth_token") else {
            errorMessage = "You must be logged in to remove books."
            showError = true
            return
        }
        
        do {
            try await APIService.shared.removeBookFromLibrary(bookId: userBook.book.id, token: token)
            // Remove from local array
            userBooks.removeAll { $0.id == userBook.id }
        } catch {
            errorMessage = "Failed to remove book: \(error.localizedDescription)"
            showError = true
        }
    }
}
