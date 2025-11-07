import Foundation

struct UserBook: Identifiable {
    let id: Int
    let book: Book
    let currentPage: Int
    let status: String
    
    var progressPercentage: Int {
        guard let totalPages = book.pageCount, totalPages > 0 else { return 0 }
        return min(100, (currentPage * 100) / totalPages)
    }
    
    var isCompleted: Bool {
        guard let totalPages = book.pageCount, totalPages > 0 else { return false }
        return currentPage >= totalPages
    }
}
