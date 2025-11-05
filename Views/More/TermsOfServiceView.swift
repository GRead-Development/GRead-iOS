import SwiftUI
struct TermsOfServiceView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Terms of Service")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Last Updated: January 2025")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                termsSection("Acceptance of Terms", content: """
                By using GRead, you agree to these Terms of Service. If you disagree with any part of these terms, you may not access the service.
                """)
                
                termsSection("User Accounts", content: """
                • You must be 13 years or older to use GRead
                • You are responsible for maintaining the security of your account
                • You may not use another user's account
                """)
                
                termsSection("User Content", content: """
                • You retain ownership of content you submit
                • You grant GRead a license to use your content as part of the service
                • You must not submit inappropriate, offensive, or copyrighted content
                """)
                
                termsSection("Prohibited Conduct", content: """
                • Harassment or abuse of other users
                • Spam or unsolicited advertising
                • Attempting to hack or compromise the service
                • Violating any applicable laws
                """)
                
                termsSection("Content Moderation", content: """
                GRead reserves the right to remove any content or suspend any account that violates these terms.
                """)
                
                termsSection("Disclaimer", content: """
                GRead is provided "as is" without warranties of any kind. We are not responsible for user-generated content.
                """)
                
                Button(action: {
                    if let url = URL(string: "https://gread.fun/terms-of-service") {
                        UIApplication.shared.open(url)
                    }
                }) {
                    Text("View Full Terms of Service")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .padding(.top)
            }
            .padding()
        }
        .navigationTitle("Terms of Service")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func termsSection(_ title: String, content: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
            Text(content)
                .font(.body)
                .foregroundColor(.secondary)
        }
    }
}
