import Foundation
import SwiftUI
import Combine

@MainActor
class SearchViewModel: ObservableObject {
    @Published var searchResults: [Book] = []
    @Published var isSearching = false
    @Published var errorMessage: String?
    
    private var searchTask: Task<Void, Never>?
    
    func search(query: String) async {
        // Cancel previous search
        searchTask?.cancel()
        
        guard !query.isEmpty else {
            searchResults = []
            return
        }
        
        // Debounce search
        searchTask = Task {
            try? await Task.sleep(nanoseconds: 300_000_000) // 0.3 seconds
            
            guard !Task.isCancelled else { return }
            
            await performSearch(query: query)
        }
    }
    
    private func performSearch(query: String) async {
        isSearching = true
        errorMessage = nil
        
        do {
            searchResults = try await APIService.shared.searchBooks(query: query)
        } catch {
            errorMessage = error.localizedDescription
            print("Error searching books: \(error)")
            searchResults = []
        }
        
        isSearching = false
    }
}
