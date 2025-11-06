import Foundation

struct LeaderboardEntry: Identifiable, Codable {
    let id: Int
    let userId: Int
    let displayName: String
    let value: Int
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case displayName = "display_name"
        case value
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decodeIfPresent(Int.self, forKey: .id) ?? 0
        userId = try container.decodeIfPresent(Int.self, forKey: .userId) ?? 0
        displayName = try container.decodeIfPresent(String.self, forKey: .displayName) ?? "Unknown User"
        value = try container.decodeIfPresent(Int.self, forKey: .value) ?? 0
    }
}

struct Leaderboard: Codable {
    let pointsLeaders: [LeaderboardEntry]
    let booksLeaders: [LeaderboardEntry]
    
    enum CodingKeys: String, CodingKey {
        case pointsLeaders = "points_leaders"
        case booksLeaders = "books_leaders"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        pointsLeaders = try container.decodeIfPresent([LeaderboardEntry].self, forKey: .pointsLeaders) ?? []
        booksLeaders = try container.decodeIfPresent([LeaderboardEntry].self, forKey: .booksLeaders) ?? []
    }
}
