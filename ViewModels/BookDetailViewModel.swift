import Foundation
import SwiftUI
import Combine

@MainActor
class BookDetailViewModel: ObservableObject {
    @Published var book: Book
    @Published var isInLibrary = false
    @Published var isLoading = false
    @Published var showSuccess = false
    @Published var showError = false
    @Published var errorMessage: String?
    @Published var addToLibraryStatus: String?
    @Published var showingAddedAlert = false
    
    init(book: Book) {
        self.book = book
    }
    
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
    
    func addToLibrary() async {
        await addToLibrary(bookId: book.id, status: "reading")
    }
    
    func addToLibrary(bookId: Int, status: String) async {
        guard let _ = UserDefaults.standard.string(forKey: "auth_token") else {
            errorMessage = "Please log in to add books to your library"
            showError = true
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            _ = try await APIService.shared.addBookToLibrary(bookId: bookId, status: status)
            isInLibrary = true
            addToLibraryStatus = status
            showSuccess = true
            showingAddedAlert = true
        } catch {
            errorMessage = error.localizedDescription
            showError = true
            print("Error adding book to library: \(error)")
        }
        
        isLoading = false
    }
}
