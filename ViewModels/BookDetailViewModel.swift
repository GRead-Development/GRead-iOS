import Combine
import Foundation
import SwiftUI

@MainActor
class BookDetailViewModel: ObservableObject {
    @Published var isInLibrary = false
    @Published var isLoading = false
    @Published var showError = false
    @Published var errorMessage: String?
    
    let book: Book
    
    init(book: Book) {
        self.book = book
    }
    
    func addToLibrary() async {
        guard let token = UserDefaults.standard.string(forKey: "auth_token") else {
            errorMessage = "Not authenticated"
            showError = true
            return
        }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            try await APIService.shared.addBookToLibrary(bookId: book.id, token: token)
            isInLibrary = true
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }
}
