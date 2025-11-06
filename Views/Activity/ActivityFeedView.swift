import SwiftUI

struct ActivityFeedView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @StateObject private var viewModel = ActivityFeedViewModel()
    @State private var showNewPostSheet = false
    @State private var showLoginPrompt = false
    
    // Load blocked/muted users
    private var blockedUsers: [Int] {
        UserDefaults.standard.array(forKey: "blockedUsers") as? [Int] ?? []
    }
    
    private var mutedUsers: [Int] {
        UserDefaults.standard.array(forKey: "mutedUsers") as? [Int] ?? []
    }
    
    // Filter out blocked and muted users
    private var filteredActivities: [ActivityItem] {
        viewModel.activities.filter { activity in
            !blockedUsers.contains(activity.userId) && !mutedUsers.contains(activity.userId)
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .padding()
                }
                
                if viewModel.isLoading && viewModel.activities.isEmpty {
                    ProgressView("Loading activity...")
                        .padding()
                } else if filteredActivities.isEmpty {
                    emptyActivityView
                } else {
                    List {
                        ForEach(filteredActivities.indices, id: \.self) { index in
                            let activity = filteredActivities[index]
                            ActivityRowView(activity: activity)
                                .onAppear {
                                    // FIXED: Better load-more triggering
                                    // Only load when we're near the end (last 3 items)
                                    if index >= filteredActivities.count - 3 {
                                        Task {
                                            await viewModel.loadMoreActivity()
                                        }
                                    }
                                }
                        }
                        
                        // Show loading indicator at the bottom when loading more
                        if viewModel.isLoading && !viewModel.activities.isEmpty {
                            HStack {
                                Spacer()
                                ProgressView()
                                Spacer()
                            }
                            .padding()
                        }
                    }
                    .listStyle(.plain)
                    .refreshable {
                        await viewModel.loadInitialActivity()
                    }
                }
            }
            .navigationTitle("Activity")
            .toolbar {
                if authManager.isAuthenticated {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            showNewPostSheet = true
                        } label: {
                            Image(systemName: "square.and.pencil")
                        }
                    }
                }
            }
            .sheet(isPresented: $showNewPostSheet) {
                NewPostView(viewModel: viewModel, isPresented: $showNewPostSheet)
            }
            .alert("Login Required", isPresented: $showLoginPrompt) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Please log in to post updates.")
            }
            .task {
                await viewModel.loadInitialActivity()
            }
        }
    }
    
    private var emptyActivityView: some View {
        VStack(spacing: 20) {
            Image(systemName: "flame.fill")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            Text("No Activity Yet")
                .font(.headline)
                .foregroundColor(.gray)
            Text("Be the first to post something!")
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
            
            if authManager.isAuthenticated {
                Button("Create Post") {
                    showNewPostSheet = true
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding()
    }
}
