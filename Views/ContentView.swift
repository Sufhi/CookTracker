// MARK: - Imports
import SwiftUI

/// メインのタブビューを管理するルート画面
/// - ホーム、レシピ、統計画面へのナビゲーションを提供
struct ContentView: View {
    
    // MARK: - Body
    var body: some View {
        TabView {
            NavigationView {
                SimpleHomeView()
            }
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
            
            NavigationView {
                VStack(spacing: 20) {
                    Image(systemName: "chart.bar.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.brown)
                    
                    Text("統計画面")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("統計機能は次回実装予定です")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .navigationTitle("統計")
            }
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
    }
}
