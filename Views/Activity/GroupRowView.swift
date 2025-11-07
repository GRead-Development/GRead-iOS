import SwiftUI

struct GroupRowView: View {
    let group: Group
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(group.name)
                .font(.headline)
            
            if !group.description.isEmpty {
                Text(group.description.stripHTML())
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            HStack {
                Image(systemName: "person.2.fill")
                    .font(.caption)
                    .foregroundColor(.secondary)
                if let status = group.status {
                    Text(status.capitalized)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.vertical, 4)
    }
}
