struct LeaderboardEntry: Identifiable, Decodable {
    let id: Int
    let displayName: String
    let value: Int
    let profileURL: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case displayName = "display_name"
        case value
        case profileURL = "profile_url"
    }
}
