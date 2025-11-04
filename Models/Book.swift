import Foundation

struct Book: Identifiable, Codable {
    let id: Int
    let title: String
    let author: String?
    let isbn: String?
    let pageCount: Int?
    let content: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case content
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Decode ID
        id = try container.decode(Int.self, forKey: .id)
        
        // Decode title (WordPress returns rendered object)
        if let titleObj = try? container.decode([String: String].self, forKey: .title) {
            title = titleObj["rendered"] ?? ""
        } else {
            title = try container.decode(String.self, forKey: .title)
        }
        
        // Decode content
        if let contentObj = try? container.decode([String: String].self, forKey: .content) {
            content = contentObj["rendered"]
        } else {
            content = nil
        }
        
        // These will come from meta fields in real API
        author = nil
        isbn = nil
        pageCount = nil
    }
    
    init(id: Int, title: String, author: String?, isbn: String?, pageCount: Int?, content: String?) {
        self.id = id
        self.title = title
        self.author = author
        self.isbn = isbn
        self.pageCount = pageCount
        self.content = content
    }
}
