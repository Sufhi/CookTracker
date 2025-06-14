// MARK: - Imports
import SwiftUI

/// レシピ一覧を表示するビュー（プレースホルダー）
/// - 将来実装予定のレシピ管理機能
struct RecipeListView: View {
    
    // MARK: - Body
    var body: some View {
        NavigationView {
            VStack {
                Image(systemName: "book.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.brown.opacity(0.5))
                
                Text("レシピ一覧")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .padding(.top)
                
                Text("この機能は次のフェーズで実装予定です")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding()
            }
            .navigationTitle("レシピ")
        }
    }
}

// MARK: - Preview
struct RecipeListView_Previews: PreviewProvider {
    static var previews: some View {
        RecipeListView()
    }
}