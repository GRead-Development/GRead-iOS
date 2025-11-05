import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            ActivityFeedView()
                .tabItem {
                    Label("Activity", systemImage: "flame.fill")
                }
            
            MyLibraryView()
                .tabItem {
                    Label("My Library", systemImage: "book.fill")
                }
            
            SearchView()
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }
            
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.circle.fill")
                }
        }
    }
}
