import Foundation

struct ActivityItem: Identifiable, Hashable {
    let id: Int
    let userId: Int
    let userName: String
    let avatarUrl: String?
    let content: String
    let action: String
    let date: String
    let type: String
    let dateFormatted: String?
    
    // Manual Hashable implementation
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    // Manual Equatable implementation
    static func == (lhs: ActivityItem, rhs: ActivityItem) -> Bool {
        lhs.id == rhs.id
    }
    
    // MARK: - Computed Properties
    
    var formattedContent: String {
        content.cleanHTML()
    }
    
    var displayAction: String {
        action.cleanHTML()
    }
    
    var displayUserName: String {
        userName.decodingHTMLEntities()
    }
    
    var timeAgo: String {
        // Use the date_formatted from server if available
        if let formatted = dateFormatted, !formatted.isEmpty {
            return formatted
        }
        
        // Fallback to client-side formatting
        guard let date = ISO8601DateFormatter().date(from: date) else {
            return "Recently"
        }
        
        let now = Date()
        let interval = now.timeIntervalSince(date)
        
        if interval < 60 {
            return "Just now"
        } else if interval < 3600 {
            let minutes = Int(interval / 60)
            return "\(minutes) minute\(minutes == 1 ? "" : "s") ago"
        } else if interval < 86400 {
            let hours = Int(interval / 3600)
            return "\(hours) hour\(hours == 1 ? "" : "s") ago"
        } else {
            let days = Int(interval / 86400)
            return "\(days) day\(days == 1 ? "" : "s") ago"
        }
    }
}
