import SwiftUI

struct SearchView: View {
    @StateObject private var viewModel = SearchViewModel()
    @State private var searchText = ""
    
    var body: some View {
        NavigationView {
            VStack {
                if viewModel.isSearching {
                    ProgressView("Searching...")
                        .padding()
                } else if !searchText.isEmpty && viewModel.searchResults.isEmpty {
                    Text("No results found")
                        .foregroundColor(.gray)
                        .padding()
                } else if !viewModel.searchResults.isEmpty {
                    List(viewModel.searchResults) { book in
                        NavigationLink(destination: BookDetailView(book: book)) {
                            BookRowView(book: book)
                        }
                    }
                } else {
                    VStack(spacing: 20) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        Text("Search for books")
                            .font(.headline)
                            .foregroundColor(.gray)
                    }
                }
            }
            .navigationTitle("Search")
            .searchable(text: $searchText, prompt: "Search books")
            .onChange(of: searchText) { newValue in
                Task {
                    await viewModel.search(query: newValue)
                }
            }
        }
    }
}
