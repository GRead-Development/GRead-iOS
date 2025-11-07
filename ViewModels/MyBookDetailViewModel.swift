import Foundation
import SwiftUI
import Combine

@MainActor
class MyBookDetailViewModel: ObservableObject {
    @Published var userBook: UserBook
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showingDeleteAlert = false
    
    init(userBook: UserBook) {
        self.userBook = userBook
    }
    
    func updateStatus(_ newStatus: String) async {
        guard let _ = UserDefaults.standard.string(forKey: "auth_token") else {
            errorMessage = "Please log in to update your books"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            try await APIService.shared.updateUserBook(id: userBook.id, status: newStatus, currentPage: nil)
            userBook.status = newStatus // This line will compile after UserBook.status is changed to 'var'
        } catch {
            errorMessage = error.localizedDescription
            print("Error updating status: \(error)")
        }
        
        isLoading = false
    }
    
    func updateProgress(_ currentPage: Int) async {
        guard let _ = UserDefaults.standard.string(forKey: "auth_token") else {
            errorMessage = "Please log in to update your progress"
            return
        }
        
        // FIX 1: Safely unwrap optional 'userBook.book.pageCount'
        guard let pageCount = userBook.book.pageCount,
              currentPage >= 0 && currentPage <= pageCount else {
            errorMessage = "Invalid page number"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            try await APIService.shared.updateUserBook(id: userBook.id, status: nil, currentPage: currentPage)
            userBook.currentPage = currentPage // This line will compile after UserBook.currentPage is changed to 'var'
            
            // FIX 2: Use the unwrapped 'pageCount' variable from the guard statement
            if currentPage == pageCount && userBook.status != "completed" {
                try await APIService.shared.updateUserBook(id: userBook.id, status: "completed", currentPage: nil)
                userBook.status = "completed" // This line will compile after UserBook.status is changed to 'var'
            }
        } catch {
            errorMessage = error.localizedDescription
            print("Error updating progress: \(error)")
        }
        
        isLoading = false
    }
}
