// MARK: - Imports
import SwiftUI

/// シンプルなレシピ追加画面
/// - プレースホルダー実装
/// - 将来的にRecipeFormViewに置き換え予定
struct AddRecipeView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.brown.opacity(0.5))
                
                Text("レシピ追加")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("この機能は次のステップで実装予定です")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding()
                
                Spacer()
            }
            .navigationTitle("レシピ追加")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("やめる") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Preview
struct AddRecipeView_Previews: PreviewProvider {
    static var previews: some View {
        AddRecipeView()
    }
}