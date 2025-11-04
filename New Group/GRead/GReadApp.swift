import SwiftUI

// MARK: - Main App Entry Point
@main
struct GReadApp: App {
    @StateObject private var authManager = AuthenticationManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authManager)
        }
    }
}

// MARK: - Content View (Main Navigation)
struct ContentView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    
    var body: some View {
        Group {
            if authManager.isAuthenticated {
                MainTabView()
            } else {
                LoginView()
            }
        }
    }
}

// MARK: - Main Tab View
struct MainTabView: View {
    var body: some View {
        TabView {
            BookDirectoryView()
                .tabItem {
                    Label("Browse", systemImage: "books.vertical")
                }
            
            MyLibraryView()
                .tabItem {
                    Label("My Library", systemImage: "book")
                }
            
            SearchView()
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }
            
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.circle")
                }
        }
    }
}

// MARK: - Login View
struct LoginView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @State private var username = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image(systemName: "books.vertical.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.blue)
                
                Text("GRead")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                VStack(spacing: 15) {
                    TextField("Username", text: $username)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                    
                    SecureField("Password", text: $password)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                .padding(.horizontal)
                
                if let error = errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.caption)
                        .multilineTextAlignment(.center)
                }
                
                Button(action: login) {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Text("Login")
                            .fontWeight(.semibold)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
                .padding(.horizontal)
                .disabled(isLoading || username.isEmpty || password.isEmpty)
                
                Spacer()
            }
            .padding(.top, 50)
            .navigationBarHidden(true)
        }
    }
    
    private func login() {
        isLoading = true
        errorMessage = nil
        
        authManager.login(username: username, password: password) { result in
            isLoading = false
            
            switch result {
            case .success:
                break
            case .failure(let error):
                errorMessage = error.localizedDescription
            }
        }
    }
}

// MARK: - Book Directory View
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

// MARK: - Book Row View
struct BookRowView: View {
    let book: Book
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Placeholder for book cover
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.gray.opacity(0.3))
                .frame(width: 60, height: 90)
                .overlay(
                    Image(systemName: "book.closed")
                        .foregroundColor(.gray)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(book.title)
                    .font(.headline)
                    .lineLimit(2)
                
                if let author = book.author {
                    Text(author)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                if let pages = book.pageCount {
                    Text("\(pages) pages")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Book Detail View
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

// MARK: - My Library View
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

// MARK: - My Book Row View
struct MyBookRowView: View {
    let userBook: UserBook
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(userBook.book.title)
                .font(.headline)
            
            if let author = userBook.book.author {
                Text(author)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            // Progress bar
            if let totalPages = userBook.book.pageCount, totalPages > 0 {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("\(userBook.currentPage) / \(totalPages) pages")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("\(userBook.progressPercentage)%")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(height: 8)
                                .cornerRadius(4)
                            
                            Rectangle()
                                .fill(userBook.isCompleted ? Color.yellow : Color.blue)
                                .frame(width: geometry.size.width * CGFloat(userBook.progressPercentage) / 100, height: 8)
                                .cornerRadius(4)
                        }
                    }
                    .frame(height: 8)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - My Book Detail View
struct MyBookDetailView: View {
    @StateObject private var viewModel: MyBookDetailViewModel
    @State private var currentPageInput: String
    
    init(userBook: UserBook) {
        _viewModel = StateObject(wrappedValue: MyBookDetailViewModel(userBook: userBook))
        _currentPageInput = State(initialValue: "\(userBook.currentPage)")
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Book info
                VStack(alignment: .leading, spacing: 8) {
                    Text(viewModel.userBook.book.title)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    if let author = viewModel.userBook.book.author {
                        Text("by \(author)")
                            .font(.title3)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.horizontal)
                
                // Progress section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Reading Progress")
                        .font(.headline)
                    
                    if let totalPages = viewModel.userBook.book.pageCount {
                        // Progress bar
                        VStack(alignment: .leading, spacing: 4) {
                            Text("\(viewModel.userBook.progressPercentage)% Complete")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            GeometryReader { geometry in
                                ZStack(alignment: .leading) {
                                    Rectangle()
                                        .fill(Color.gray.opacity(0.3))
                                        .frame(height: 12)
                                        .cornerRadius(6)
                                    
                                    Rectangle()
                                        .fill(viewModel.userBook.isCompleted ? Color.yellow : Color.blue)
                                        .frame(width: geometry.size.width * CGFloat(viewModel.userBook.progressPercentage) / 100, height: 12)
                                        .cornerRadius(6)
                                }
                            }
                            .frame(height: 12)
                        }
                        
                        // Update progress
                        HStack {
                            TextField("Current Page", text: $currentPageInput)
                                .keyboardType(.numberPad)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            
                            Text("/ \(totalPages)")
                                .foregroundColor(.secondary)
                            
                            Button("Update") {
                                if let page = Int(currentPageInput) {
                                    Task {
                                        await viewModel.updateProgress(currentPage: page)
                                    }
                                }
                            }
                            .buttonStyle(.borderedProminent)
                            .disabled(viewModel.isLoading)
                        }
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
                .padding(.horizontal)
                
                Spacer()
            }
            .padding(.vertical)
        }
        .navigationBarTitleDisplayMode(.inline)
        .alert("Success", isPresented: $viewModel.showSuccess) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Progress updated successfully!")
        }
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage ?? "An error occurred")
        }
    }
}

// MARK: - Search View
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

// MARK: - Profile View
struct ProfileView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @StateObject private var viewModel = ProfileViewModel()
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    HStack {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.blue)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(viewModel.userStats?.displayName ?? "User")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            if let points = viewModel.userStats?.points {
                                Text("\(points) points")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding(.vertical, 8)
                }
                
                if let stats = viewModel.userStats {
                    Section("Statistics") {
                        StatRowView(label: "Books Completed", value: "\(stats.booksCompleted)")
                        StatRowView(label: "Pages Read", value: "\(stats.pagesRead)")
                        StatRowView(label: "Books Added", value: "\(stats.booksAdded)")
                    }
                }
                
                Section {
                    Button(action: {
                        authManager.logout()
                    }) {
                        HStack {
                            Spacer()
                            Text("Logout")
                                .foregroundColor(.red)
                            Spacer()
                        }
                    }
                }
            }
            .navigationTitle("Profile")
            .onAppear {
                Task {
                    await viewModel.loadUserStats()
                }
            }
        }
    }
}

struct StatRowView: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
            Spacer()
            Text(value)
                .fontWeight(.semibold)
        }
    }
}

// MARK: - String Extension
extension String {
    func stripHTML() -> String {
        return self.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
    }
}
