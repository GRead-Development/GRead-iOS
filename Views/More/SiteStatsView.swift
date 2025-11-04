import Foundation
import SwiftUI
import UIKit
struct SiteStatsView: View {
    @State private var totalBooks = 0
    @State private var totalUsers = 0
    @State private var isLoading = true
    
    var body: some View {
        List {
            Section("Community Stats") {
                StatItemView(label: "Total Books", value: "\(totalBooks)", icon: "books.vertical.fill")
                StatItemView(label: "Active Readers", value: "\(totalUsers)", icon: "person.3.fill")
            }
            
            Section("Your Contribution") {
                Text("Check the Profile tab to see your personal statistics")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .navigationTitle("Site Statistics")
        .onAppear {
            Task {
                await loadStats()
            }
        }
    }
    
    private func loadStats() async {
        // Implement API call to fetch site stats
        isLoading = false
    }
}
