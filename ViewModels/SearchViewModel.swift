import Foundation
import SwiftUI
import Combine

@MainActor
class SearchViewModel: ObservableObject {
    @Published var searchResults: [Book] = []
    @Published var isSearching = false
    
    private var searchTask: Task<Void, Never>?
    
    func search(query: String) async {
        // Cancel previous search
        searchTask?.cancel()
        
        guard query.count >= 3 else {
            searchResults = []
            return
        }
        
        searchTask = Task {
            isSearching = true
            defer { isSearching = false }
            
            // Debounce
            try? await Task.sleep(nanoseconds: 500_000_000)
            
            guard !Task.isCancelled else { return }
            
            do {
                searchResults = try await APIService.shared.searchBooks(query: query)
            } catch {
                print("Search error: \(error)")
                searchResults = []
            }
        }
        
        await searchTask?.value
    }
}
