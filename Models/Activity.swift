import Foundation

struct ActivityItem: Identifiable, Codable {
    let id: Int
    let userId: Int
    let userName: String?
    let userAvatar: String?
    let content: String
    let date: String
    let component: String?
    let type: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case userName = "user_name"
        case userAvatar = "user_avatar"
        case content
        case date
        case component
        case type
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(Int.self, forKey: .id)
        userId = try container.decodeIfPresent(Int.self, forKey: .userId) ?? 0
        userName = try container.decodeIfPresent(String.self, forKey: .userName)
        userAvatar = try container.decodeIfPresent(String.self, forKey: .userAvatar)
        content = try container.decodeIfPresent(String.self, forKey: .content) ?? ""
        date = try container.decodeIfPresent(String.self, forKey: .date) ?? ""
        component = try container.decodeIfPresent(String.self, forKey: .component)
        type = try container.decodeIfPresent(String.self, forKey: .type)
    }
    
    var formattedContent: String {
        return content.cleanHTML()
    }
    
    var timeAgo: String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        guard let activityDate = formatter.date(from: date) else {
            formatter.formatOptions = [.withInternetDateTime]
            guard let activityDate = formatter.date(from: date) else {
                return date
            }
            return calculateTimeAgo(from: activityDate)
        }
        
        return calculateTimeAgo(from: activityDate)
    }
    
    private func calculateTimeAgo(from date: Date) -> String {
        let now = Date()
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date, to: now)
        
        if let years = components.year, years > 0 {
            return "\(years)y ago"
        } else if let months = components.month, months > 0 {
            return "\(months)mo ago"
        } else if let days = components.day, days > 0 {
            return "\(days)d ago"
        } else if let hours = components.hour, hours > 0 {
            return "\(hours)h ago"
        } else if let minutes = components.minute, minutes > 0 {
            return "\(minutes)m ago"
        } else {
            return "Just now"
        }
    }
}
