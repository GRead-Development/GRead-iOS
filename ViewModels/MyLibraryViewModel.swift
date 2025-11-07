import Combine
import Foundation
@MainActor
class MyLibraryViewModel: ObservableObject {
    @Published var userBooks: [UserBook] = []
    @Published var isLoading = false
    @Published var showError = false
    @Published var errorMessage: String?
    
    func loadUserBooks() async {
        guard let token = UserDefaults.standard.string(forKey: "auth_token") else { return }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            userBooks = try await APIService.shared.fetchUserBooks(token: token)
        } catch {
            print("Error loading user books: \(error)")
            errorMessage = error.localizedDescription
            showError = true
        }
    }
    
    func removeBook(_ userBook: UserBook) async {
        guard let token = UserDefaults.standard.string(forKey: "auth_token") else { return }
        
        do {
            try await APIService.shared.removeBookFromLibrary(bookId: userBook.book.id, token: token)
            // Remove from local array
            userBooks.removeAll { $0.id == userBook.id }
        } catch {
            errorMessage = "Failed to remove book"
            showError = true
        }
    }
}
