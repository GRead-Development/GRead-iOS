import SwiftUI

struct MyBookDetailView: View {
    @StateObject private var viewModel: MyBookDetailViewModel
    @State private var currentPageInput: String
    
    init(userBook: UserBook) {
        _viewModel = StateObject(wrappedValue: MyBookDetailViewModel(userBook: userBook))
        _currentPageInput = State(initialValue: "\(userBook.currentPage)")
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Book info
                VStack(alignment: .leading, spacing: 8) {
                    Text(viewModel.userBook.book.title)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    if let author = viewModel.userBook.book.author {
                        Text("by \(author)")
                            .font(.title3)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.horizontal)
                
                // Progress section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Reading Progress")
                        .font(.headline)
                    
                    if let totalPages = viewModel.userBook.book.pageCount {
                        // Progress bar
                        VStack(alignment: .leading, spacing: 4) {
                            Text("\(viewModel.userBook.progressPercentage)% Complete")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            GeometryReader { geometry in
                                ZStack(alignment: .leading) {
                                    Rectangle()
                                        .fill(Color.gray.opacity(0.3))
                                        .frame(height: 12)
                                        .cornerRadius(6)
                                    
                                    Rectangle()
                                        .fill(viewModel.userBook.isCompleted ? Color.yellow : Color.blue)
                                        .frame(width: geometry.size.width * CGFloat(viewModel.userBook.progressPercentage) / 100, height: 12)
                                        .cornerRadius(6)
                                }
                            }
                            .frame(height: 12)
                        }
                        
                        // Update progress
                        HStack {
                            TextField("Current Page", text: $currentPageInput)
                                .keyboardType(.numberPad)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            
                            Text("/ \(totalPages)")
                                .foregroundColor(.secondary)
                            
                            Button("Update") {
                                if let page = Int(currentPageInput) {
                                    Task {
                                        await viewModel.updateProgress(currentPage: page)
                                    }
                                }
                            }
                            .buttonStyle(.borderedProminent)
                            .disabled(viewModel.isLoading)
                        }
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
                .padding(.horizontal)
                
                Spacer()
            }
            .padding(.vertical)
        }
        .navigationBarTitleDisplayMode(.inline)
        .alert("Success", isPresented: $viewModel.showSuccess) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Progress updated successfully!")
        }
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage ?? "An error occurred")
        }
    }
}
