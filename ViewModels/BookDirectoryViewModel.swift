import Foundation
import SwiftUI
import Combine

@MainActor
class BookDirectoryViewModel: ObservableObject {
    @Published var books: [Book] = []
    @Published var isLoading = false
    
    // --- ADD PAGINATION STATE ---
    private var currentPage = 1
    private var canLoadMorePages = true

    // Renamed from loadBooks() to make its purpose clear
    func loadInitialBooks() async {
        // Reset state for a full refresh
        currentPage = 1
        canLoadMorePages = true
        isLoading = true
        defer { isLoading = false }
        
        do {
            // Fetch only the first page
            books = try await APIService.shared.fetchBooks(page: currentPage)
        } catch {
            print("Error loading books: \(error)")
        }
    }
    
    // --- ADD NEW FUNCTION TO LOAD MORE ---
    func loadMoreBooks() async {
        // Don't load more if we're already loading or if we've reached the end
        guard !isLoading && canLoadMorePages else { return }
        
        isLoading = true
        currentPage += 1 // Move to the next page
        
        do {
            // Fetch the next page
            let newBooks = try await APIService.shared.fetchBooks(page: currentPage)
            
            if newBooks.isEmpty {
                // We've reached the end
                canLoadMorePages = false
            } else {
                // Add the new books to the existing list
                books.append(contentsOf: newBooks)
            }
        } catch {
            // Handle cases where the API might return an error on the last page
            print("Error loading more books (likely end of list): \(error)")
            canLoadMorePages = false
        }
        
        isLoading = false
    }
}
