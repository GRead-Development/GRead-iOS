import Foundation
import SwiftUI
import Combine

@MainActor
class MyLibraryViewModel: ObservableObject {
    @Published var userBooks: [UserBook] = []
    @Published var isLoading = false
    @Published var showError = false
    @Published var errorMessage: String?
    
    func loadUserBooks() async {
        guard let _ = UserDefaults.standard.string(forKey: "auth_token") else {
            errorMessage = "Please log in to view your library"
            showError = true
            return
        }
        
        isLoading = true
        errorMessage = nil
        showError = false
        
        do {
            userBooks = try await APIService.shared.fetchUserBooks()
        } catch {
            errorMessage = error.localizedDescription
            showError = true
            print("Error loading user books: \(error)")
        }
        
        isLoading = false
    }
    
    func removeBooks(at offsets: IndexSet) {
        userBooks.remove(atOffsets: offsets)
    }
    
    func removeBook(_ userBook: UserBook) async {
        guard let _ = UserDefaults.standard.string(forKey: "auth_token") else {
            errorMessage = "Please log in to manage your library"
            showError = true
            return
        }
        
        errorMessage = nil
        
        do {
            try await APIService.shared.deleteUserBook(id: userBook.id)
            userBooks.removeAll { $0.id == userBook.id }
        } catch {
            errorMessage = error.localizedDescription
            showError = true
            print("Error deleting book: \(error)")
        }
    }
    
    func deleteBook(userBook: UserBook) async {
        await removeBook(userBook)
    }
}
