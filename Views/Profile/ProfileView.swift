import SwiftUI

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
