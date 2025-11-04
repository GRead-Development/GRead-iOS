import SwiftUI

struct MyLibraryView: View {
    @StateObject private var viewModel = MyLibraryViewModel()
    @State private var sortOption: LibrarySortOption = .title
    @State private var showCompleted = true
    @State private var showReading = true
    @State private var searchText = ""
    
    enum LibrarySortOption: String, CaseIterable {
        case title = "Title"
        case author = "Author"
        case progress = "Progress"
        
        var icon: String {
            switch self {
            case .title: return "textformat"
            case .author: return "person.fill"
            case .progress: return "chart.bar.fill"
            }
        }
    }
    
    var filteredAndSortedBooks: [UserBook] {
        var books = viewModel.userBooks
        
        if !showCompleted || !showReading {
            books = books.filter { book in
                if !showCompleted && book.isCompleted { return false }
                if !showReading && !book.isCompleted { return false }
                return true
            }
        }
        
        if !searchText.isEmpty {
            books = books.filter { book in
                book.book.title.localizedCaseInsensitiveContains(searchText) ||
                (book.book.author?.localizedCaseInsensitiveContains(searchText) ?? false)
            }
        }
        
        switch sortOption {
        case .title:
            books.sort { $0.book.title < $1.book.title }
        case .author:
            books.sort { ($0.book.author ?? "") < ($1.book.author ?? "") }
        case .progress:
            books.sort { $0.progressPercentage > $1.progressPercentage }
        }
        
        return books
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // --- MODIFICATION: Show error message if one exists ---
                if viewModel.showError, let errorMessage = viewModel.errorMessage {
                    VStack(spacing: 12) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.red)
                        Text("Error Loading Library")
                            .font(.headline)
                        Text(errorMessage)
                            .font(.subheadline)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                            .padding(.horizontal)
                        Button("Try Again") {
                            Task {
                                await viewModel.loadUserBooks()
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .padding(.top)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if viewModel.isLoading && viewModel.userBooks.isEmpty {
                    ProgressView("Loading library...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if viewModel.userBooks.isEmpty {
                    emptyLibraryView
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    filterBar
                    
                    if filteredAndSortedBooks.isEmpty {
                        Text("No books match your filters")
                            .foregroundColor(.gray)
                            .padding()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        List {
                            ForEach(filteredAndSortedBooks) { userBook in
                                NavigationLink(destination: MyBookDetailView(userBook: userBook)) {
                                    MyBookRowView(userBook: userBook)
                                }
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                    Button(role: .destructive) {
                                        Task {
                                            await viewModel.removeBook(userBook)
                                        }
                                    } label: {
                                        Label("Remove", systemImage: "trash")
                                    }
                                }
                            }
                        }
                        .listStyle(.plain)
                        .refreshable {
                            await viewModel.loadUserBooks()
                        }
                    }
                }
            }
            .navigationTitle("My Library")
            .searchable(text: $searchText, prompt: "Search your library")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Picker("Sort By", selection: $sortOption) {
                            ForEach(LibrarySortOption.allCases, id: \.self) { option in
                                Label(option.rawValue, systemImage: option.icon)
                                    .tag(option)
                            }
                        }
                    } label: {
                        Image(systemName: "arrow.up.arrow.down.circle")
                    }
                }
            }
            .onAppear {
                // Only load if not already loading and library is empty
                if !viewModel.isLoading && viewModel.userBooks.isEmpty {
                    Task {
                        await viewModel.loadUserBooks()
                    }
                }
            }
            // Removed the .alert modifier as errors are now handled inline
        }
    }
    
    private var filterBar: some View {
        HStack {
            Toggle(isOn: $showReading) {
                Label("Reading", systemImage: "book")
                    .font(.caption)
            }
            .toggleStyle(.button)
            .buttonStyle(.bordered)
            
            Toggle(isOn: $showCompleted) {
                Label("Completed", systemImage: "checkmark.circle")
                    .font(.caption)
            }
            .toggleStyle(.button)
            .buttonStyle(.bordered)
            .tint(.yellow)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color(uiColor: .systemGroupedBackground))
    }
    
    private var emptyLibraryView: some View {
        VStack(spacing: 20) {
            Image(systemName: "books.vertical")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            Text("Your library is empty")
                .font(.headline)
                .foregroundColor(.gray)
            Text("Add books from the Browse tab to get started")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            // This NavigationLink will work correctly as long as MyLibraryView
            // is hosted within the MainTabView.
            NavigationLink(destination: BookDirectoryView()) {
                Text("Browse Books")
                    .fontWeight(.semibold)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .padding()
    }
}

