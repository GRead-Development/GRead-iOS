import SwiftUI
struct StatItemView: View {
    let label: String
    let value: String
    let icon: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 30)
            
            VStack(alignment: .leading) {
                Text(label)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)
            }
        }
    }
}
