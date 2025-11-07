import SwiftUI

struct ActivityFeedView: View {
    @StateObject private var viewModel = ActivityFeedViewModel()
    @State private var showNewPostSheet = false
    
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
                } else if viewModel.activities.isEmpty {
                    emptyActivityView
                } else {
                    List {
                        ForEach(viewModel.activities) { activity in
                            ActivityRowView(activity: activity)
                                .onAppear {
                                    if activity.id == viewModel.activities.last?.id {
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
                    Button(action: { showNewPostSheet = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 22))
                    }
                }
            }
            .sheet(isPresented: $showNewPostSheet) {
                // --- THIS IS THE FIX ---
                // You must pass the $showNewPostSheet binding to the NewPostView
                // so it knows how to dismiss itself.
                NewPostView(viewModel: viewModel, isPresented: $showNewPostSheet)
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

