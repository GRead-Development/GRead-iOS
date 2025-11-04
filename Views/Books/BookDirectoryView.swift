import SwiftUI

struct BookDirectoryView: View {
    @StateObject private var viewModel = BookDirectoryViewModel()
    
    var body: some View {
        NavigationView {
            // --- WRAP LIST IN VSTACK TO SHOW LOADING INDICATOR ---
            VStack {
                SwiftUI.Group {
                    if viewModel.isLoading && viewModel.books.isEmpty {
                        ProgressView("Loading books...")
                    } else if viewModel.books.isEmpty {
                        Text("No books available")
                            .foregroundColor(.gray)
                    } else {
                        List(viewModel.books) { book in
                            NavigationLink(destination: BookDetailView(book: book)) {
                                BookRowView(book: book)
                                // --- ADD ONAPPEAR TRIGGER ---
                                    .onAppear {
                                        // If this book is the last one in the list, load more
                                        if book.id == viewModel.books.last?.id {
                                            Task {
                                                await viewModel.loadMoreBooks()
                                            }
                                        }
                                    }
                            }
                        }
                        .refreshable {
                            // Use the new initial load function for pull-to-refresh
                            await viewModel.loadInitialBooks()
                        }
                    }
                }
                
                // --- SHOW A SPINNER AT THE BOTTOM WHILE LOADING MORE ---
                if viewModel.isLoading && !viewModel.books.isEmpty {
                    ProgressView()
                        .padding()
                }
            }
            .navigationTitle("Book Directory")
            .onAppear {
                // Only load initially if the list is empty
                if viewModel.books.isEmpty {
                    Task {
                        // Use the new initial load function
                        await viewModel.loadInitialBooks()
                    }
                }
            }
        }
    }
}
