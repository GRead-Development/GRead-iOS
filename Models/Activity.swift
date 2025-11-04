import Foundation

struct ActivityItem: Identifiable, Codable {
    let id: Int
    let userId: Int
    let content: String
    let date: String
    let type: String
    let userName: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case content
        case date
        case type
        case userName = "user_name"
    }
    
    var formattedContent: String {
        content.stripHTML()
    }
    
    var timeAgo: String {
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
