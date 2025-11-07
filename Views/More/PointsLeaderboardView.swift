import SwiftUI

struct PointsLeaderboardView: View {
    @StateObject private var viewModel = LeaderboardViewModel(type: "points")
    
    var body: some View {
        List {
            if viewModel.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity)
            } else {
                ForEach(Array(viewModel.entries.enumerated()), id: \.element.id) { index, entry in
                    HStack {
                        Text("#\(index + 1)")
                            .font(.headline)
                            .foregroundColor(.secondary)
                            .frame(width: 40)
                        
                        VStack(alignment: .leading) {
                            Text(entry.displayName)
                                .font(.body)
                            Text("\(entry.value) points")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        if index == 0 {
                            Image(systemName: "crown.fill")
                                .foregroundColor(.yellow)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .navigationTitle("Points Leaderboard")
        .refreshable {
            await viewModel.loadLeaderboard()
        }
        .onAppear {
            Task {
                await viewModel.loadLeaderboard()
            }
        }
    }
}
