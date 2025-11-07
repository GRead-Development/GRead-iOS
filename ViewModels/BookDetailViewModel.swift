import Foundation
import SwiftUI
import Combine

@MainActor
class BookDetailViewModel: ObservableObject {
    @Published var book: Book?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showingAddedAlert = false
    @Published var addToLibraryStatus: String?
    
    func loadBook(id: Int) async {
        isLoading = true
        errorMessage = nil
        
        do {
            book = try await APIService.shared.fetchBook(id: id)
        } catch {
            errorMessage = error.localizedDescription
            print("Error loading book: \(error)")
        }
        
        isLoading = false
    }
    
    func addToLibrary(bookId: Int, status: String) async {
        guard let _ = UserDefaults.standard.string(forKey: "auth_token") else {
            errorMessage = "Please log in to add books to your library"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            _ = try await APIService.shared.addBookToLibrary(bookId: bookId, status: status)
            addToLibraryStatus = status
            showingAddedAlert = true
        } catch {
            errorMessage = error.localizedDescription
            print("Error adding book to library: \(error)")
        }
        
        isLoading = false
    }
}
