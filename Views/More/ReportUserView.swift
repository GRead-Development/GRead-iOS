import SwiftUI

struct ReportUserView: View {
    let userId: Int
    let userName: String
    @Environment(\.dismiss) private var dismiss
    @State private var reason = ""
    @State private var description = ""
    @State private var isSubmitting = false
    @State private var showSuccess = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    let reportReasons = [
        "Harassment or bullying",
        "Inappropriate content",
        "Spam",
        "Impersonation",
        "Other"
    ]
    
    var body: some View {
        NavigationView {
            Form {
                Section("User") {
                    Text(userName)
                        .font(.headline)
                    Text("User ID: \(userId)")
                        .font(.caption)
                        .foregroundColor(.secondary)
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
                    .disabled(reason.isEmpty || description.isEmpty || isSubmitting)
                }
            }
            .navigationTitle("Report User")
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
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    private func submitReport() {
        guard let token = UserDefaults.standard.string(forKey: "auth_token") else {
            errorMessage = "You must be logged in to report users"
            showError = true
            return
        }
        
        isSubmitting = true
        
        Task {
            do {
                try await APIService.shared.reportUser(
                    userId: userId,
                    reason: reason,
                    description: description,
                    token: token
                )
                isSubmitting = false
                showSuccess = true
            } catch {
                isSubmitting = false
                errorMessage = error.localizedDescription
                showError = true
            }
        }
    }
}
