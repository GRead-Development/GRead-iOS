import Foundation
import SwiftUI
import Combine

@MainActor
class MyBookDetailViewModel: ObservableObject {
    @Published var userBook: UserBook
    @Published var isLoading = false
    @Published var showSuccess = false
    @Published var showError = false
    @Published var errorMessage: String?
    
    init(userBook: UserBook) {
        self.userBook = userBook
    }
    
    func updateProgress(currentPage: Int) async {
        guard let token = UserDefaults.standard.string(forKey: "auth_token"),
              let totalPages = userBook.book.pageCount else { return }
        
        let validPage = min(max(0, currentPage), totalPages)
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            try await APIService.shared.updateProgress(
                bookId: userBook.book.id,
                currentPage: validPage,
                token: token
            )
            
            // Update local state
            userBook = UserBook(
                id: userBook.id,
                book: userBook.book,
                currentPage: validPage,
                status: userBook.status
            )
            
            showSuccess = true
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }
}
