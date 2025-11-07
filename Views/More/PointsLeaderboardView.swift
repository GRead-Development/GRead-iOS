import SwiftUI

struct PointsLeaderboardView: View {
    @StateObject private var viewModel = LeaderboardViewModel(type: "points")
    
    var body: some View {
        contentView
            .navigationTitle("Points Leaderboard")
            .onAppear {
                Task {
                    await viewModel.loadLeaderboard()
                }
            }
    }
    
    @ViewBuilder
    private var contentView: some View {
        if viewModel.isLoading {
            loadingView
        } else if viewModel.entries.isEmpty {
            emptyView
        } else {
            leaderboardList
        }
    }
    
    private var loadingView: some View {
        ProgressView("Loading leaderboard...")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var emptyView: some View {
        VStack(spacing: 20) {
            Image(systemName: "star.fill")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            Text("No Data Yet")
                .font(.headline)
                .foregroundColor(.gray)
            Text("Start contributing to see the points leaderboard!")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
    
    private var leaderboardList: some View {
        List {
            ForEach(Array(viewModel.entries.enumerated()), id: \.element.id) { index, entry in
                leaderboardRow(index: index, entry: entry)
            }
        }
        .listStyle(.plain)
    }
    
    private func leaderboardRow(index: Int, entry: LeaderboardDisplayEntry) -> some View {
        HStack {
            rankBadge(rank: index + 1)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(entry.userName)
                    .font(.body)
                    .fontWeight(.medium)
                
                Text("\(entry.score) points")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if index < 3 {
                medalIcon(rank: index + 1)
            }
        }
        .padding(.vertical, 4)
    }
    
    private func rankBadge(rank: Int) -> some View {
        Text("#\(rank)")
            .font(.headline)
            .foregroundColor(rank <= 3 ? .white : .secondary)
            .frame(width: 40, height: 40)
            .background(rank <= 3 ? rankColor(rank: rank) : Color.gray.opacity(0.2))
            .clipShape(Circle())
    }
    
    private func rankColor(rank: Int) -> Color {
        switch rank {
        case 1: return .yellow
        case 2: return .gray
        case 3: return .orange
        default: return .gray
        }
    }
    
    private func medalIcon(rank: Int) -> some View {
        Image(systemName: "medal.fill")
            .foregroundColor(rankColor(rank: rank))
            .font(.title2)
    }
}
