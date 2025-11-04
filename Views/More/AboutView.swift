import SwiftUI
struct AboutView: View {
    var body: some View {
        List {
            Section {
                HStack {
                    Spacer()
                    VStack(spacing: 12) {
                        Image(systemName: "books.vertical.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.blue)
                        
                        Text("GRead")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text("Version 1.0")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                }
                .padding(.vertical)
            }
            
            Section("About") {
                Text("GRead is a social reading platform where you can track your reading progress, discover new books, and connect with other readers.")
                    .font(.body)
            }
            
            Section("Developers") {
                Text("Bryce Davis")
                Text("Daniel Teberian")
            }
            
            Section("Website") {
                Button(action: {
                    if let url = URL(string: "https://gread.fun") {
                        UIApplication.shared.open(url)
                    }
                }) {
                    HStack {
                        Text("Visit gread.fun")
                        Spacer()
                        Image(systemName: "arrow.up.right.square")
                    }
                }
            }
            
            Section("Acknowledgments") {
                Text("Thank you to all our users and contributors who make GRead possible.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .navigationTitle("About GRead")
    }
}
