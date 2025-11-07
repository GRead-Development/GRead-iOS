import SwiftUI

struct GroupsView: View {
    @StateObject private var viewModel = GroupsViewModel()
    
    var body: some View {
        Group {
            if viewModel.isLoading && viewModel.groups.isEmpty {
                ProgressView("Loading groups...")
            } else if viewModel.groups.isEmpty {
                emptyGroupsView
            } else {
                List(viewModel.groups) { group in
                    GroupRowView(group: group)
                }
                .listStyle(.plain)
                .refreshable {
                    await viewModel.loadGroups()
                }
            }
        }
        .navigationTitle("Groups")
        .onAppear {
            if viewModel.groups.isEmpty {
                Task {
                    await viewModel.loadGroups()
                }
            }
        }
    }
    
    private var emptyGroupsView: some View {
        VStack(spacing: 20) {
            Image(systemName: "person.3.fill")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            Text("No Groups Yet")
                .font(.headline)
                .foregroundColor(.gray)
        }
        .padding()
    }
}
