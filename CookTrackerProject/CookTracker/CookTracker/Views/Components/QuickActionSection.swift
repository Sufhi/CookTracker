// MARK: - Imports
import SwiftUI

/// クイックアクションセクション
/// - レシピ追加、補助タイマー、レシピ一覧への簡単アクセス
/// - ホーム画面でのメイン操作ボタン群
/// - 各機能への導線となるコンポーネント
struct QuickActionSection: View {
    @Binding var isShowingAddRecipe: Bool
    @Binding var isShowingTimer: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("クイックアクション")
                .font(.headline)
                .fontWeight(.semibold)
            
            HStack(spacing: 12) {
                Button(action: {
                    isShowingAddRecipe = true
                }) {
                    VStack(spacing: 8) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.brown)
                        
                        Text("レシピ追加")
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.brown.opacity(0.1))
                    )
                }
                .buttonStyle(.plain)
                
                Button(action: {
                    isShowingTimer = true
                }) {
                    VStack(spacing: 8) {
                        Image(systemName: "timer")
                            .font(.system(size: 30))
                            .foregroundColor(.brown)
                        
                        Text("補助タイマー")
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.brown.opacity(0.1))
                    )
                }
                .buttonStyle(.plain)
                
                Button(action: {
                    // レシピ一覧は後で実装
                }) {
                    VStack(spacing: 8) {
                        Image(systemName: "book.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.brown)
                        
                        Text("レシピ一覧")
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.brown.opacity(0.1))
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .gray.opacity(0.2), radius: 4, x: 0, y: 2)
        )
    }
}

// MARK: - Preview
struct QuickActionSection_Previews: PreviewProvider {
    static var previews: some View {
        @State var isShowingAddRecipe = false
        @State var isShowingTimer = false
        
        VStack {
            QuickActionSection(
                isShowingAddRecipe: $isShowingAddRecipe,
                isShowingTimer: $isShowingTimer
            )
            .padding()
            
            Text("プレビュー用")
                .padding()
        }
    }
}