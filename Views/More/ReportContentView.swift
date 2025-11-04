import Foundation
import SwiftUI
import UIKit
struct ReportContentView: View {
    @State private var reportType = "Book Content"
    @State private var contentURL = ""
    @State private var reason = ""
    @State private var description = ""
    @State private var reporterEmail = ""
    @State private var isSubmitting = false
    @State private var showSuccess = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    let reportTypes = ["Book Content", "User Behavior", "Inappropriate Content", "Copyright Violation", "Other"]
    
    var body: some View {
        Form {
            Section("Report Type") {
                Picker("Type", selection: $reportType) {
                    ForEach(reportTypes, id: \.self) { type in
                        Text(type).tag(type)
                    }
                }
            }
            
            Section("Details") {
                TextField("Content URL or Book Title", text: $contentURL)
                
                TextField("Brief Reason", text: $reason)
                
                // --- FIX: Replaced .overlay with a ZStack for placeholder ---
                ZStack(alignment: .topLeading) {
                    TextEditor(text: $description)
                        .frame(minHeight: 120)

                    if description.isEmpty {
                        Text("Please provide details about the issue...")
                            .foregroundColor(Color(UIColor.placeholderText)) // Use standard placeholder color
                            .padding(.top, 8)
                            .padding(.leading, 5) // Standard padding for TextEditor
                            .allowsHitTesting(false) // Make placeholder non-interactive
                    }
                }
                // --- END FIX ---
            }
            
            Section("Your Contact (Optional)") {
                TextField("Email", text: $reporterEmail)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                
                Text("Provide your email if you'd like updates on this report")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Section {
                Button(action: submitReport) {
                    if isSubmitting {
                        HStack {
                            Spacer()
                            ProgressView()
                            Spacer()
                        }
                    } else {
                        Text("Submit Report")
                            .frame(maxWidth: .infinity)
                            .foregroundColor(.white)
                    }
                }
                .listRowBackground(Color.red)
                .disabled(isSubmitting || !isFormValid)
            }
            
            Section {
                Text("Reports are reviewed within 24-48 hours. Thank you for helping keep GRead safe and appropriate.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .navigationTitle("Report Content")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Report Submitted", isPresented: $showSuccess) {
            Button("OK") {
                clearForm()
            }
        } message: {
            Text("Thank you for your report. We take all reports seriously and will review this promptly.")
        }
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
    }
    
    private var isFormValid: Bool {
        !contentURL.isEmpty && !reason.isEmpty && !description.isEmpty
    }
    
    private func submitReport() {
        isSubmitting = true
        
        let emailSubject = "GRead Content Report: \(reportType)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let emailBody = """
        CONTENT REPORT
        
        Type: \(reportType)
        Content: \(contentURL)
        Reason: \(reason)
        
        Description:
        \(description)
        
        Reporter Email: \(reporterEmail.isEmpty ? "Not provided" : reporterEmail)
        
        Timestamp: \(Date())
        
        ---
        Sent from GRead iOS App
        """.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        
        if let url = URL(string: "mailto:reports@gread.fun?subject=\(emailSubject)&body=\(emailBody)") {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url) { success in
                    isSubmitting = false
                    if success {
                        showSuccess = true
                    } else {
                        errorMessage = "Could not open mail app. Please email reports@gread.fun"
                        showError = true
                    }
                }
            } else {
                isSubmitting = false
                errorMessage = "Please email reports@gread.fun with your concerns"
                showError = true
            }
        }
    }
    
    private func clearForm() {
        reportType = "Book Content"
        contentURL = ""
        reason = ""
        description = ""
        reporterEmail = ""
    }
}
