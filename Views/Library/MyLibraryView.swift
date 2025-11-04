import SwiftUI

struct MyLibraryView: View {
    @StateObject private var viewModel = MyLibraryViewModel()
    
    var body: some View {
        NavigationView {
            Group {
                if viewModel.isLoading && viewModel.userBooks.isEmpty {
                    ProgressView("Loading library...")
                } else if viewModel.userBooks.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "books.vertical")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        Text("Your library is empty")
                            .font(.headline)
                            .foregroundColor(.gray)
                        Text("Add books from the directory to get started")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                } else {
                    List {
                        ForEach(viewModel.userBooks) { userBook in
                            NavigationLink(destination: MyBookDetailView(userBook: userBook)) {
                                MyBookRowView(userBook: userBook)
                            }
                        }
                        .onDelete(perform: viewModel.removeBooks)
                    }
                    .refreshable {
                        await viewModel.loadUserBooks()
                    }
                }
            }
            .navigationTitle("My Library")
            .onAppear {
                Task {
                    await viewModel.loadUserBooks()
                }
            }
        }
    }
}
