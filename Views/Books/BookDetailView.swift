import SwiftUI

struct BookDetailView: View {
    let book: Book
    @StateObject private var viewModel: BookDetailViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showReportSheet = false
    
    init(book: Book) {
        self.book = book
        _viewModel = StateObject(wrappedValue: BookDetailViewModel(book: book))
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Book info section
                VStack(alignment: .leading, spacing: 12) {
                    Text(book.title)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    if let author = book.author {
                        HStack {
                            Image(systemName: "person.fill")
                                .foregroundColor(.secondary)
                                .font(.caption)
                            Text(author)
                                .font(.title3)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    HStack(spacing: 16) {
                        if let pages = book.pageCount {
                            Label("\(pages) pages", systemImage: "doc.text")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        if let isbn = book.isbn {
                            Label(isbn, systemImage: "barcode")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.top)
                
                // Action button
                Button(action: {
                    Task {
                        await viewModel.addToLibrary()
                    }
                }) {
                    HStack {
                        Image(systemName: viewModel.isInLibrary ? "checkmark.circle.fill" : "plus.circle")
                        Text(viewModel.isInLibrary ? "In Library" : "Add to Library")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(viewModel.isInLibrary ? Color.green : Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .disabled(viewModel.isInLibrary || viewModel.isLoading)
                .padding(.horizontal)
                
                // Description
                if let content = book.content, !content.isEmpty {
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
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showReportSheet = true }) {
                    Image(systemName: "exclamationmark.triangle")
                        .foregroundColor(.red)
                }
            }
        }
        .sheet(isPresented: $showReportSheet) {
            NavigationView {
                ReportBookView(book: book)
            }
        }
        .alert("Success", isPresented: $viewModel.showSuccess) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Book added to your library!")
        }
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage ?? "An error occurred")
        }
    }
}
