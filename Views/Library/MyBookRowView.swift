import SwiftUI

struct MyBookRowView: View {
    let userBook: UserBook
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(userBook.book.title)
                .font(.headline)
            
            if let author = userBook.book.author {
                Text(author)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            // Progress bar
            if let totalPages = userBook.book.pageCount, totalPages > 0 {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("\(userBook.currentPage) / \(totalPages) pages")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("\(userBook.progressPercentage)%")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(height: 8)
                                .cornerRadius(4)
                            
                            Rectangle()
                                .fill(userBook.isCompleted ? Color.yellow : Color.blue)
                                .frame(width: geometry.size.width * CGFloat(userBook.progressPercentage) / 100, height: 8)
                                .cornerRadius(4)
                        }
                    }
                    .frame(height: 8)
                }
            }
        }
        .padding(.vertical, 4)
    }
}
