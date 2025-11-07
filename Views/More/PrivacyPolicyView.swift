import SwiftUI
struct PrivacyPolicyView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Privacy Policy")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Last Updated: January 2025")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                privacySection("Information We Collect", content: """
                • Account information (username, email)
                • Reading progress and library data
                • Device information for app functionality
                """)
                
                privacySection("How We Use Your Information", content: """
                • To provide and maintain the GRead service
                • To track your reading progress
                • To improve our app and services
                """)
                
                privacySection("Data Security", content: """
                We implement appropriate security measures to protect your personal information.
                """)
                
                privacySection("Your Rights", content: """
                You can request to access, correct, or delete your personal data at any time.
                """)
                
                Button(action: {
                    if let url = URL(string: "https://gread.fun/privacy") {
                        UIApplication.shared.open(url)
                    }
                }) {
                    Text("View Full Privacy Policy")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .padding(.top)
            }
            .padding()
        }
        .navigationTitle("Privacy Policy")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func privacySection(_ title: String, content: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
            Text(content)
                .font(.body)
                .foregroundColor(.secondary)
        }
    }
}
