//
//  ContentView.swift
//  CookTracker
//
//  Created by Claude on 2025/06/18.
//

import SwiftUI
import CoreData

/// メインコンテンツビュー
/// - タブベースのナビゲーション構造
struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    var body: some View {
        TabView {
            // ホーム画面
            SimpleHomeView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("ホーム")
                }
            
            // レシピ一覧
            RecipeListView()
                .tabItem {
                    Image(systemName: "book.fill")
                    Text("レシピ")
                }
            
            // 履歴・統計
            HistoryStatsView()
                .tabItem {
                    Image(systemName: "chart.bar.fill")
                    Text("履歴")
                }
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