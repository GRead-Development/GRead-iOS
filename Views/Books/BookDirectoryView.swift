import SwiftUI

struct BookDirectoryView: View {
    @StateObject private var viewModel = BookDirectoryViewModel()
    
    var body: some View {
        NavigationView {
            Group {
                if viewModel.isLoading && viewModel.books.isEmpty {
                    ProgressView("Loading books...")
                } else if viewModel.books.isEmpty {
                    Text("No books available")
                        .foregroundColor(.gray)
                } else {
                    List(viewModel.books) { book in
                        NavigationLink(destination: BookDetailView(book: book)) {
                            BookRowView(book: book)
                        }
                    }
                    .refreshable {
                        await viewModel.loadBooks()
                    }
                }
            }
            .navigationTitle("Book Directory")
            .onAppear {
                Task {
                    await viewModel.loadBooks()
                }
            }
        }
    }
}
