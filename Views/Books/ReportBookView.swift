internal import UIKit
import SwiftUI
import Foundation
struct ReportBookView: View {
    let book: Book
    @Environment(\.dismiss) private var dismiss
    @State private var reason = ""
    @State private var description = ""
    @State private var reporterEmail = ""
    @State private var isSubmitting = false
    @State private var showSuccess = false
    
    let reportReasons = [
        "Inappropriate content",
        "Copyright violation",
        "Incorrect information",
        "Spam or misleading",
        "Other"
    ]
    
    var body: some View {
        Form {
            Section("Book") {
                Text(book.title)
                    .font(.headline)
                if let author = book.author {
                    Text(author)
                        .foregroundColor(.secondary)
                }
            }
            
            Section("Report Reason") {
                Picker("Reason", selection: $reason) {
                    Text("Select a reason").tag("")
                    ForEach(reportReasons, id: \.self) { reason in
                        Text(reason).tag(reason)
                    }
                }
            }
            
            Section("Additional Details") {
                TextEditor(text: $description)
                    .frame(minHeight: 100)
            }
            
            Section("Contact (Optional)") {
                TextField("Your email", text: $reporterEmail)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
            }
            
            Section {
                Button(action: submitReport) {
                    if isSubmitting {
                        ProgressView()
                    } else {
                        Text("Submit Report")
                            .frame(maxWidth: .infinity)
                    }
                }
                .disabled(reason.isEmpty || description.isEmpty || isSubmitting)
            }
        }
        .navigationTitle("Report Book")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Cancel") {
                    dismiss()
                }
            }
        }
        .alert("Report Submitted", isPresented: $showSuccess) {
            Button("OK") {
                dismiss()
            }
        } message: {
            Text("Thank you for your report. We'll review it shortly.")
        }
    }
    
    private func submitReport() {
        isSubmitting = true
        
        let emailSubject = "Book Report: \(book.title)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let emailBody = """
        BOOK CONTENT REPORT
        
        Book ID: \(book.id)
        Title: \(book.title)
        Author: \(book.author ?? "Unknown")
        
        Reason: \(reason)
        
        Description:
        \(description)
        
        Reporter: \(reporterEmail.isEmpty ? "Anonymous" : reporterEmail)
        
        ---
        Sent from GRead iOS App
        """.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        
        if let url = URL(string: "mailto:reports@gread.fun?subject=\(emailSubject)&body=\(emailBody)") {
            UIApplication.shared.open(url) { _ in
                isSubmitting = false
                showSuccess = true
            }
        }
    }
}
