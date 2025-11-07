import Foundation

struct UserStats: Codable {
    let displayName: String
    let points: Int
    let booksCompleted: Int
    let pagesRead: Int
    let booksAdded: Int
    
    enum CodingKeys: String, CodingKey {
        case displayName = "display_name"
        case points
        case booksCompleted = "books_completed"
        case pagesRead = "pages_read"
        case booksAdded = "books_added"
    }
}
