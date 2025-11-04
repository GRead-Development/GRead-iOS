import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            BookDirectoryView()
                .tabItem {
                    Label("Browse", systemImage: "books.vertical")
                }
            
            MyLibraryView()
                .tabItem {
                    Label("My Library", systemImage: "book")
                }
            
            SearchView()
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }
            
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.circle")
                }
        }
    }
}
