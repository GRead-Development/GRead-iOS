import SwiftUI

struct BookRowView: View {
    let book: Book
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(book.title)
                .font(.headline)
                .lineLimit(2)
            
            HStack {
                if let author = book.author {
                    Text(author)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                if let pages = book.pageCount {
                    Text("•")
                        .foregroundColor(.secondary)
                    Text("\(pages) pages")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.vertical, 8)
    }
}
