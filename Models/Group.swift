struct Group: Identifiable, Codable {
    let id: Int
    let name: String
    let description: String
    let memberCount: Int?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case description
        case memberCount = "total_member_count"
    }
}
