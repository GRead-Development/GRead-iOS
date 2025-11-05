import SwiftUI

struct BlockedUsersView: View {
    @State private var blockedUsers: [Int] = []
    @State private var mutedUsers: [Int] = []
    
    var body: some View {
        List {
            if !mutedUsers.isEmpty {
                Section("Muted Users") {
                    ForEach(mutedUsers, id: \.self) { userId in
                        HStack {
                            Image(systemName: "person.circle.fill")
                                .foregroundColor(.gray)
                            Text("User ID: \(userId)")
                            Spacer()
                            Button("Unmute") {
                                unmuteUser(userId)
                            }
                            .foregroundColor(.blue)
                        }
                    }
                }
            }
            
            if !blockedUsers.isEmpty {
                Section("Blocked Users") {
                    ForEach(blockedUsers, id: \.self) { userId in
                        HStack {
                            Image(systemName: "person.circle.fill")
                                .foregroundColor(.gray)
                            Text("User ID: \(userId)")
                            Spacer()
                            Button("Unblock") {
                                unblockUser(userId)
                            }
                            .foregroundColor(.blue)
                        }
                    }
                }
            }
            
            if mutedUsers.isEmpty && blockedUsers.isEmpty {
                Section {
                    VStack(spacing: 16) {
                        Image(systemName: "checkmark.circle")
                            .font(.system(size: 50))
                            .foregroundColor(.green)
                        Text("No blocked or muted users")
                            .font(.headline)
                        Text("Users you mute or block will appear here")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)
                }
            }
        }
        .navigationTitle("Blocked & Muted Users")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            loadUsers()
        }
    }
    
    private func loadUsers() {
        blockedUsers = UserDefaults.standard.array(forKey: "blockedUsers") as? [Int] ?? []
        mutedUsers = UserDefaults.standard.array(forKey: "mutedUsers") as? [Int] ?? []
    }
    
    private func unmuteUser(_ userId: Int) {
        mutedUsers.removeAll { $0 == userId }
        UserDefaults.standard.set(mutedUsers, forKey: "mutedUsers")
        UserDefaults.standard.synchronize()
    }
    
    private func unblockUser(_ userId: Int) {
        blockedUsers.removeAll { $0 == userId }
        UserDefaults.standard.set(blockedUsers, forKey: "blockedUsers")
        UserDefaults.standard.synchronize()
    }
}
