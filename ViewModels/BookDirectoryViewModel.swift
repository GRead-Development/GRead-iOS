import Foundation
import SwiftUI
import Combine

@MainActor
class BookDirectoryViewModel: ObservableObject {
    @Published var books: [Book] = []
    @Published var isLoading = false
    
    func loadBooks() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            books = try await APIService.shared.fetchBooks()
        } catch {
            print("Error loading books: \(error)")
        }
    }
}
