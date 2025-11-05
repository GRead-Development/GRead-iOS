import SwiftUI

// MARK: - Main App Entry Point
@main
struct GReadApp: App {
    @StateObject private var authManager = AuthenticationManager()
    
    var body: some Scene {
        WindowGroup {
            LoginView()
       //     ContentView()
         //       .environmentObject(authManager)
        }
    }
}
