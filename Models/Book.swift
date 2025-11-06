import Foundation

struct Book: Codable, Identifiable, Hashable {
    let id: Int
    let title: String
    let author: String?
    let isbn: String?
    let pageCount: Int?
    let content: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case author
        case isbn
        case pageCount = "page_count"
        case content
    }
    
    // Manual Hashable implementation
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    // Manual Equatable implementation
    static func == (lhs: Book, rhs: Book) -> Bool {
        lhs.id == rhs.id
    }
}
