// MARK: - Imports
import SwiftUI

/// メインのタブビューを管理するルート画面
/// - ホーム、レシピ、統計画面へのナビゲーションを提供
struct ContentView: View {
    
    // MARK: - Body
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("ホーム")
                }
                .tag(0)
            
            RecipeListView()
                .tabItem {
                    Image(systemName: "book.fill")
                    Text("レシピ")
                }
                .tag(1)
            
            StatsView()
                .tabItem {
                    Image(systemName: "chart.bar.fill")
                    Text("統計")
                }
                .tag(2)
        }
        .accentColor(.brown)
    }
}

// MARK: - Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}