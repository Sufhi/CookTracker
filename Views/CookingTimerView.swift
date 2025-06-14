// MARK: - Imports
import SwiftUI

/// 調理タイマー画面（プレースホルダー）
/// - 将来実装予定のタイマー機能
struct CookingTimerView: View {
    
    // MARK: - Properties
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - Body
    var body: some View {
        NavigationView {
            VStack {
                Image(systemName: "timer")
                    .font(.system(size: 60))
                    .foregroundColor(.brown.opacity(0.5))
                
                Text("調理タイマー")
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
            .navigationTitle("タイマー")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("閉じる") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Preview
struct CookingTimerView_Previews: PreviewProvider {
    static var previews: some View {
        CookingTimerView()
    }
}