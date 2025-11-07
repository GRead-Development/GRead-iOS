import Foundation

struct UserBook: Codable, Identifiable, Hashable {
    let id: Int
    let book: Book
    var currentPage: Int
    var status: String
    
    // Manual Hashable implementation
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    // Manual Equatable implementation
    static func == (lhs: UserBook, rhs: UserBook) -> Bool {
        lhs.id == rhs.id
    }
    
    // MARK: - Computed Properties
    
    var progressPercentage: Int {
        guard let totalPages = book.pageCount, totalPages > 0 else {
            return 0
        }
        return Int((Double(currentPage) / Double(totalPages)) * 100)
    }
    
    var isCompleted: Bool {
        guard let totalPages = book.pageCount, totalPages > 0 else {
            return false
        }
        return currentPage >= totalPages
    }
}
