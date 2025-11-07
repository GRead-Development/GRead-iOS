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
    @Published var showingDeleteAlert = false
    
    init(userBook: UserBook) {
        self.userBook = userBook
    }
    
    func updateStatus(_ newStatus: String) async {
        guard let _ = UserDefaults.standard.string(forKey: "auth_token") else {
            errorMessage = "Please log in to update your books"
            showError = true
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            try await APIService.shared.updateUserBook(id: userBook.id, status: newStatus, currentPage: nil)
            userBook.status = newStatus
            showSuccess = true
        } catch {
            errorMessage = error.localizedDescription
            showError = true
            print("Error updating status: \(error)")
        }
        
        isLoading = false
    }
    
    func updateProgress(_ currentPage: Int) async {
        await updateProgress(currentPage: currentPage)
    }
    
    func updateProgress(currentPage: Int) async {
        guard let _ = UserDefaults.standard.string(forKey: "auth_token") else {
            errorMessage = "Please log in to update your progress"
            showError = true
            return
        }
        
        guard let pageCount = userBook.book.pageCount,
              currentPage >= 0 && currentPage <= pageCount else {
            errorMessage = "Invalid page number"
            showError = true
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            try await APIService.shared.updateUserBook(id: userBook.id, status: nil, currentPage: currentPage)
            userBook.currentPage = currentPage
            
            if currentPage == pageCount && userBook.status != "completed" {
                try await APIService.shared.updateUserBook(id: userBook.id, status: "completed", currentPage: nil)
                userBook.status = "completed"
            }
            
            showSuccess = true
        } catch {
            errorMessage = error.localizedDescription
            showError = true
            print("Error updating progress: \(error)")
        }
        
        isLoading = false
    }
}
