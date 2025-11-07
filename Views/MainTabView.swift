import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            MyLibraryView()
                .tabItem {
                    Label("My Library", systemImage: "book.fill")
                }
                .tag(0)
            
            ActivityFeedView()
                .tabItem {
                    Label("Activity", systemImage: "list.bullet.rectangle")
                }
                .tag(1)
            
            BookDirectoryView()
                .tabItem {
                    Label("Browse", systemImage: "books.vertical")
                }
                .tag(2)
            
            SearchView()
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }
                .tag(3)
            
            MoreMenuView()
                .tabItem {
                    Label("More", systemImage: "ellipsis.circle")
                }
                .tag(4)
        }
    }
}
