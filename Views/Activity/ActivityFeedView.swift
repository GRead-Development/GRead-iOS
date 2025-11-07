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
                        ForEach(filteredActivities) { activity in
                            ActivityRowView(activity: activity)
                                .onAppear {
                                    // Only trigger load more when we reach the 3rd-to-last item
                                    // and we're not already loading
                                    if let index = filteredActivities.firstIndex(where: { $0.id == activity.id }),
                                       index >= filteredActivities.count - 3,
                                       !viewModel.isLoading {
                                        Task {
                                            await viewModel.loadMoreActivity()
                                        }
                                    }
                                }
                        }
                        
                        if viewModel.isLoading {
                            HStack {
                                Spacer()
                                ProgressView()
                                Spacer()
                            }
                        }
                    }
                    .listStyle(.plain)
                    .refreshable {
                        await viewModel.loadInitialActivity()
                    }
                }
            }
            .navigationTitle("Activity Feed")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    NavigationLink(destination: GroupsView()) {
                        Image(systemName: "person.3.fill")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        if authManager.isAuthenticated {
                            showNewPostSheet = true
                        } else {
                            showLoginPrompt = true
                        }
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 22))
                    }
                }
            }
            .sheet(isPresented: $showNewPostSheet) {
                NewPostView(viewModel: viewModel, isPresented: $showNewPostSheet)
            }
            .alert("Login Required", isPresented: $showLoginPrompt) {
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Please log in to post updates.")
            }
            .onAppear {
                if viewModel.activities.isEmpty {
                    Task {
                        await viewModel.loadInitialActivity()
                    }
                }
            }
        }
    }
    
    private var emptyActivityView: some View {
        VStack(spacing: 20) {
            Image(systemName: "list.bullet.rectangle")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            Text("No Activity Yet")
                .font(.headline)
                .foregroundColor(.gray)
            Text("Follow other users or post an update to see activity here.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}
