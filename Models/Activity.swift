import Foundation

struct ActivityItem: Identifiable, Codable {
    let id: Int
    let userId: Int
    let userName: String
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
        userName = try container.decodeIfPresent(String.self, forKey: .userName) ?? "Unknown User"
        userAvatar = try container.decodeIfPresent(String.self, forKey: .userAvatar)
        content = try container.decodeIfPresent(String.self, forKey: .content) ?? ""
        date = try container.decodeIfPresent(String.self, forKey: .date) ?? ""
        component = try container.decodeIfPresent(String.self, forKey: .component)
        type = try container.decodeIfPresent(String.self, forKey: .type)
    }
}
