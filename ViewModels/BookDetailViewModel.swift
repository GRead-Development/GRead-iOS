import Foundation
import SwiftUI
import Combine

@MainActor
class BookDetailViewModel: ObservableObject {
    @Published var isInLibrary = false
    @Published var isLoading = false
    @Published var showSuccess = false
    @Published var showError = false
    @Published var errorMessage: String?
    
    let book: Book
    
    init(book: Book) {
        self.book = book
        checkIfInLibrary()
    }
    
    private func checkIfInLibrary() {
        // Check if book is already in library
        // This is a simple implementation - you may want to improve this
        // by checking against the actual library data
    }
    
    func addToLibrary() async {
        guard let token = UserDefaults.standard.string(forKey: "auth_token") else {
            errorMessage = "You must be logged in to add books"
            showError = true
            return
        }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            try await APIService.shared.addBookToLibrary(bookId: book.id, token: token)
            isInLibrary = true
            showSuccess = true
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }
}
