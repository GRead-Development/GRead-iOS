import SwiftUI
struct MoreMenuView: View {
    var body: some View {
        NavigationView {
            List {
                Section("Community") {
                    NavigationLink(destination: PointsLeaderboardView()) {
                        Label("Points Leaderboard", systemImage: "star.fill")
                    }
                    
                    NavigationLink(destination: BooksLeaderboardView()) {
                        Label("Books Submitted", systemImage: "book.fill")
                    }
                    
                    NavigationLink(destination: SiteStatsView()) {
                        Label("Site Statistics", systemImage: "chart.bar.fill")
                    }
                }
                
                Section("Support") {
                    NavigationLink(destination: ContactUsView()) {
                        Label("Contact Us", systemImage: "envelope.fill")
                    }
                    
                    NavigationLink(destination: ReportContentView()) {
                        Label("Report Content", systemImage: "exclamationmark.triangle.fill")
                    }
                    
                    NavigationLink(destination: AboutView()) {
                        Label("About GRead", systemImage: "info.circle.fill")
                    }
                }
                
                Section("Legal") {
                    NavigationLink(destination: PrivacyPolicyView()) {
                        Label("Privacy Policy", systemImage: "hand.raised.fill")
                    }
                    
                    NavigationLink(destination: TermsOfServiceView()) {
                        Label("Terms of Service", systemImage: "doc.text.fill")
                    }
                }
            }
            .navigationTitle("More")
        }
    }
}
