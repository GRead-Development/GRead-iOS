import Foundation
import SwiftUI
internal import UIKit
struct ContactUsView: View {
    @State private var name = ""
    @State private var email = ""
    @State private var subject = ""
    @State private var message = ""
    @State private var isSubmitting = false
    @State private var showSuccess = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        Form {
            Section("Your Information") {
                TextField("Name", text: $name)
                    .autocapitalization(.words)
                
                TextField("Email", text: $email)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
            }
            
            Section("Message") {
                TextField("Subject", text: $subject)
                
                TextEditor(text: $message)
                    .frame(minHeight: 150)
            }
            
            Section {
                Button(action: sendContactForm) {
                    if isSubmitting {
                        HStack {
                            Spacer()
                            ProgressView()
                            Spacer()
                        }
                    } else {
                        Text("Send Message")
                            .frame(maxWidth: .infinity)
                            .foregroundColor(.white)
                    }
                }
                .listRowBackground(Color.blue)
                .disabled(isSubmitting || !isFormValid)
            }
        }
        .navigationTitle("Contact Us")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Success", isPresented: $showSuccess) {
            Button("OK") {
                // Clear form
                name = ""
                email = ""
                subject = ""
                message = ""
            }
        } message: {
            Text("Your message has been sent. We'll get back to you soon!")
        }
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
    }
    
    private var isFormValid: Bool {
        !name.isEmpty && !email.isEmpty && !subject.isEmpty && !message.isEmpty && email.contains("@")
    }
    
    private func sendContactForm() {
        isSubmitting = true
        
        // Create mailto URL
        let emailSubject = "GRead iOS App: \(subject)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let emailBody = """
        Name: \(name)
        Email: \(email)
        
        Message:
        \(message)
        
        ---
        Sent from GRead iOS App
        """.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        
        if let url = URL(string: "mailto:support@gread.fun?subject=\(emailSubject)&body=\(emailBody)") {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url) { success in
                    isSubmitting = false
                    if success {
                        showSuccess = true
                    } else {
                        errorMessage = "Could not open mail app. Please email us at support@gread.fun"
                        showError = true
                    }
                }
            } else {
                isSubmitting = false
                errorMessage = "Please email us at support@gread.fun"
                showError = true
            }
        }
    }
}
