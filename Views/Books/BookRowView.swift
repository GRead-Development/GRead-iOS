import SwiftUI

struct BookRowView: View {
    let book: Book
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Placeholder for book cover
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.gray.opacity(0.3))
                .frame(width: 60, height: 90)
                .overlay(
                    Image(systemName: "book.closed")
                        .foregroundColor(.gray)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(book.title)
                    .font(.headline)
                    .lineLimit(2)
                
                if let author = book.author {
                    Text(author)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                if let pages = book.pageCount {
                    Text("\(pages) pages")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.vertical, 4)
    }
}
