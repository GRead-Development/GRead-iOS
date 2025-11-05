import Foundation

struct Book: Identifiable, Decodable {
    
    let id: Int
    let title: String
    let author: String?
    let isbn: String?
    let pageCount: Int?
    let content: String?
    
    // --- DEFINE NEW CODING KEYS ---
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case content
        case bookMeta = "book_meta" // Key from rest.php
    }
    
    // Keys for the nested book_meta object
    enum MetaCodingKeys: String, CodingKey {
        case author
        case isbn
        case pageCount = "page_count"
    }
    
    // --- UPDATE THE DECODER ---
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Decode ID
        id = try container.decode(Int.self, forKey: .id)
        
        // Decode title and clean HTML entities
        var rawTitle = ""
        if let titleObj = try? container.decode([String: String].self, forKey: .title) {
            rawTitle = titleObj["rendered"] ?? ""
        } else {
            rawTitle = try container.decode(String.self, forKey: .title)
        }
        // Clean HTML entities from title
        title = rawTitle.decodingHTMLEntities()
        
        // Decode content and clean HTML entities
        if let contentObj = try? container.decode([String: String].self, forKey: .content) {
            let rawContent = contentObj["rendered"] ?? ""
            content = rawContent.decodingHTMLEntities()
        } else {
            content = nil
        }
        
        // --- DECODE CUSTOM META FIELDS ---
        if let metaContainer = try? container.nestedContainer(keyedBy: MetaCodingKeys.self, forKey: .bookMeta) {
            // Decode author and clean HTML entities
            if let rawAuthor = try metaContainer.decodeIfPresent(String.self, forKey: .author) {
                author = rawAuthor.decodingHTMLEntities()
            } else {
                author = nil
            }
            isbn = try metaContainer.decodeIfPresent(String.self, forKey: .isbn)
            pageCount = try metaContainer.decodeIfPresent(Int.self, forKey: .pageCount)
        } else {
            // Fallback if book_meta is missing
            author = nil
            isbn = nil
            pageCount = nil
        }
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
