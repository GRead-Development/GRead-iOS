import SwiftUI

struct BookDetailView: View {
    let book: Book
    @StateObject private var viewModel: BookDetailViewModel
    @Environment(\.dismiss) private var dismiss
    
    init(book: Book) {
        self.book = book
        _viewModel = StateObject(wrappedValue: BookDetailViewModel(book: book))
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Book cover placeholder
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 300)
                    .overlay(
                        Image(systemName: "book.closed.fill")
                            .font(.system(size: 80))
                            .foregroundColor(.gray)
                    )
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(book.title)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    if let author = book.author {
                        Text("by \(author)")
                            .font(.title3)
                            .foregroundColor(.secondary)
                    }
                    
                    if let pages = book.pageCount {
                        Text("\(pages) pages")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    if let isbn = book.isbn {
                        Text("ISBN: \(isbn)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.horizontal)
                
                // Action buttons
                HStack(spacing: 12) {
                    Button(action: {
                        Task {
                            await viewModel.addToLibrary()
                        }
                    }) {
                        Label(viewModel.isInLibrary ? "Added" : "Add to Library",
                              systemImage: viewModel.isInLibrary ? "checkmark.circle.fill" : "plus.circle")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(viewModel.isInLibrary ? Color.green : Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .disabled(viewModel.isInLibrary || viewModel.isLoading)
                }
                .padding(.horizontal)
                
                if let content = book.content {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Description")
                            .font(.headline)
                        
                        Text(content.stripHTML())
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal)
                }
                
                Spacer(minLength: 20)
            }
            .padding(.vertical)
        }
        .navigationBarTitleDisplayMode(.inline)
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage ?? "An error occurred")
        }
    }
}
