import Foundation

struct Group: Identifiable, Codable {
    let id: Int
    let name: String
    let description: String
    let memberCount: Int
    let avatarUrl: String?
    let status: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case description
        case memberCount = "member_count"
        case avatarUrl = "avatar_url"
        case status
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(Int.self, forKey: .id)
        name = try container.decodeIfPresent(String.self, forKey: .name) ?? "Unknown Group"
        description = try container.decodeIfPresent(String.self, forKey: .description) ?? ""
        memberCount = try container.decodeIfPresent(Int.self, forKey: .memberCount) ?? 0
        avatarUrl = try container.decodeIfPresent(String.self, forKey: .avatarUrl)
        status = try container.decodeIfPresent(String.self, forKey: .status)
    }
}
