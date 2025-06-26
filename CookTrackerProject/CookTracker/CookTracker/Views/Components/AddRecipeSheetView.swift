// MARK: - Imports
import SwiftUI

/// レシピ追加用のシートView
/// - 将来のフェーズでの実装を予告するプレースホルダー
/// - モーダル表示でのレシピ追加UI
struct AddRecipeSheetView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.brown.opacity(0.5))
                
                Text("レシピ追加")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .padding(.top)
                
                Text("この機能は次のフェーズで実装予定です")
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
struct AddRecipeSheetView_Previews: PreviewProvider {
    static var previews: some View {
        AddRecipeSheetView()
    }
}