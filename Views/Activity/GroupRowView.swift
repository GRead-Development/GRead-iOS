import SwiftUI
struct GroupRowView: View {
    let group: Group
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(group.name)
                .font(.headline)
            
            Text(group.description.stripHTML())
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(2)
            
            if let memberCount = group.memberCount {
                HStack {
                    Image(systemName: "person.2.fill")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(memberCount) members")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.vertical, 4)
    }
}
