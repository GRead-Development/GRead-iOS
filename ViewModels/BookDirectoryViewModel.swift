import Foundation
import SwiftUI
import Combine

@MainActor
class BookDirectoryViewModel: ObservableObject {
    @Published var books: [Book] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private var currentPage = 1
    private var canLoadMore = true
    
    func loadInitialBooks() async {
        currentPage = 1
        canLoadMore = true
        books = []
        await loadBooks()
    }
    
    func loadMoreBooks() async {
        guard !isLoading && canLoadMore else { return }
        currentPage += 1
        await loadBooks()
    }
    
    private func loadBooks() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let newBooks = try await APIService.shared.fetchBooks()
            
            if newBooks.isEmpty {
                canLoadMore = false
            } else {
                let uniqueBooks = newBooks.filter { newBook in
                    !books.contains(where: { $0.id == newBook.id })
                }
                books.append(contentsOf: uniqueBooks)
            }
        } catch {
            errorMessage = error.localizedDescription
            print("Error loading books: \(error)")
        }
        
        isLoading = false
    }
}
