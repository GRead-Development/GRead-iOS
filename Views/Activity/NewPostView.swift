import SwiftUI

// --- NEW FILE ---
struct NewPostView: View {
    @ObservedObject var viewModel: ActivityFeedViewModel
    @Binding var isPresented: Bool
    
    @State private var postContent = ""
    @FocusState private var isEditorFocused: Bool
    
    var body: some View {
        NavigationView {
            VStack {
                // Main text editor
                TextEditor(text: $postContent)
                    .frame(maxHeight: .infinity)
                    .padding()
                    .focused($isEditorFocused)
                    .overlay(
                        postContent.isEmpty ?
                        Text("What's on your mind?")
                            .foregroundColor(.gray)
                            .padding()
                            .padding(.top, 8)
                            .allowsHitTesting(false)
                        : nil,
                        alignment: .topLeading
                    )
                    .onAppear {
                        // FIX: Added a delay before focusing the editor.
                        // This prevents the sheet animation from conflicting with
                        // the keyboard animation, resolving the "hang".
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                            isEditorFocused = true
                        }
                    }
                
                if let error = viewModel.errorMessage {
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.red)
                        .padding(.horizontal)
                }
                
                Spacer()
            }
            .navigationTitle("New Post")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: postUpdate) {
                        if viewModel.isPosting {
                            ProgressView()
                        } else {
                            Text("Post").bold()
                        }
                    }
                    .disabled(postContent.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || viewModel.isPosting)
                }
            }
        }
    }
    
    private func postUpdate() {
        Task {
            let success = await viewModel.postUpdate(content: postContent)
            if success {
                isPresented = false // Dismiss sheet on success
            }
        }
    }
}
