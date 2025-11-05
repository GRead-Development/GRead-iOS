import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @StateObject private var viewModel = ProfileViewModel()
    @State private var showLoginSheet = false
    
    var body: some View {
        NavigationView {
            if authManager.isAuthenticated {
                authenticatedProfileView
            } else {
                unauthenticatedProfileView
            }
        }
    }
    
    private var authenticatedProfileView: some View {
        List {
            Section {
                HStack {
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(authManager.displayName ?? viewModel.userStats?.displayName ?? "User")
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
            if authManager.isAuthenticated {
                Task {
                    await viewModel.loadUserStats()
                }
            }
        }
    }
    
    private var unauthenticatedProfileView: some View {
        VStack(spacing: 20) {
            Image(systemName: "person.circle")
                .font(.system(size: 80))
                .foregroundColor(.gray)
            
            Text("Not Logged In")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Log in to track your reading progress, join groups, and connect with other readers.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Button(action: {
                showLoginSheet = true
            }) {
                Text("Log In")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.horizontal, 40)
            .padding(.top, 20)
            
            Spacer()
        }
        .padding(.top, 60)
        .navigationTitle("Profile")
        .sheet(isPresented: $showLoginSheet) {
            LoginView()
                .environmentObject(authManager)
        }
    }
}
