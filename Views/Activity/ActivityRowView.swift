import SwiftUI

struct ActivityRowView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    let activity: ActivityItem
    @State private var showReportSheet = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "person.circle.fill")
                    .font(.title2)
                    .foregroundColor(.blue)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(activity.userName ?? "User")
                        .font(.headline)
                    
                    Text(activity.timeAgo)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                HStack(spacing: 12) {
                    activityTypeIcon
                    
                    if authManager.isAuthenticated && activity.userId != authManager.userId {
                        Menu {
                            Button(role: .destructive, action: { showReportSheet = true }) {
                                Label("Report User", systemImage: "exclamationmark.triangle")
                            }
                        } label: {
                            Image(systemName: "ellipsis")
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            
            Text(activity.formattedContent)
                .font(.body)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.vertical, 8)
        .sheet(isPresented: $showReportSheet) {
            ReportUserView(userId: activity.userId, userName: activity.userName ?? "User")
        }
    }
    
    private var activityTypeIcon: some View {
        SwiftUI.Group {
            switch activity.type {
            case "activity_update":
                Image(systemName: "text.bubble.fill")
                    .foregroundColor(.green)
            case "new_book":
                Image(systemName: "book.fill")
                    .foregroundColor(.orange)
            case "book_progress":
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .foregroundColor(.blue)
            default:
                Image(systemName: "circle.fill")
                    .foregroundColor(.gray)
            }
        }
        .font(.caption)
    }
}
