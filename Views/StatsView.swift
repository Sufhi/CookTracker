// MARK: - Imports
import SwiftUI

/// 統計・履歴を表示するビュー（プレースホルダー）
/// - 将来実装予定の統計機能
struct StatsView: View {
    
    // MARK: - Body
    var body: some View {
        NavigationView {
            VStack {
                Image(systemName: "chart.bar.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.brown.opacity(0.5))
                
                Text("統計")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .padding(.top)
                
                Text("この機能は次のフェーズで実装予定です")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding()
            }
            .navigationTitle("統計")
        }
    }
}

// MARK: - Preview
struct StatsView_Previews: PreviewProvider {
    static var previews: some View {
        StatsView()
    }
}