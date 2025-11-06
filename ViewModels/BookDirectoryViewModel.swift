import Foundation
import SwiftUI
import Combine

@MainActor
class BookDirectoryViewModel: ObservableObject {
    @Published var books: [Book] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    func loadBooks() async {
        isLoading = true
        errorMessage = nil
        
        do {
            books = try await APIService.shared.fetchBooks()
        } catch {
            errorMessage = error.localizedDescription
            print("Error loading books: \(error)")
        }
        
        isLoading = false
    }
}
